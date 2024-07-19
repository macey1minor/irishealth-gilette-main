/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Monitor.AlertNotification Extends Ens.BusinessMetric [ ProcedureBlock ]
{

Property TargetConfigNames As %String;

Parameter SETTINGS As %String = "TargetConfigNames";

ClassMethod OnGetConnections(Output pArray As %String, item As Ens.Config.Item)
{
	Set (tValue,tIndex)="" 
	For { 
		Set tIndex = item.Settings.Next(tIndex) Quit:tIndex=""
		Set tSetting = item.Settings.GetAt(tIndex)
		If tSetting.Name="TargetConfigNames" {
			Set tValue=tSetting.Value
		}
	}
	
	For i=1:1:$L(tValue,",") { 
		Set tOne=$P(tValue,",",i)
		If (tOne '= "" ) {
			Set pArray(tOne)=""
		}
	}
	Quit
}

Method OnCalculateMetrics() As %Status
{

	//To Do
	
		/* 
		Author: Ben Graham, (Schedule logic: Matt Simpson)
		Date: Nov 2006
		
		Purpose: Alert users of interface exceptions specified in the monitoring table
		
		Notes:
			- Each type of condition has separate code (if block) that checks the alert conditon.
			    When a new type is added, you must also add a code block for evaluatting the condition.
		
		General Logic:
			Get the name of the production
			Get list of interfaces items in the production
			Get all availble statistics for the production
			Get list of interfaces (items) and parameters to be monitored (Active only)
			
			For each item
				For each parameter
					If parameter schedule indicates the parameter should be checked now
						Get info regarding last status change and alert reported
					
						If the status has changed
							record the new status and the time the changed was identified
						
						Else
							If there is an alert condition
								If the condition persisted longer than the alert duration
									If the time since the last alert is greater than the alert duration
										Report the alert
										Update the alert Time
									End
								End
							End
						End
					End
				End
			End
	
	
		4/18/2007 - Adding Holiday Processing. bg
		
		4/19/2007 - Adding Actions to be performed on an alert. bg
		
		10/4/2007 - Adding troubled boolean flag in status table to indicate current troubled items. ms
		
		11/20/2007 - Adding Alert Exceptions - Define date/time exceptions for alerts
		
		
	
	*/
	
	// *****  Get the name of the production    *******
	Set ProductionName=""
	Set ProductionStatus=""
	set status = ##class(Ens.Director).GetProductionStatus(.ProductionName,.ProductionStatus)

	$$$TRACE("1.Production: "_ProductionName)
	
	// *****  Get list of items and metrics  ********
	
	K HostStatus
	K troubled
	$$$TRACE("2.Collecting List of items...")
	// Get the list of interfaces (items) from the production class
	set production=##class(Ens.Config.Production).%OpenId(ProductionName)
	
	for i=1:1:(production.Items.Count()+0) {
  
  		// collect item settings
  		s item=production.Items.GetAt(i)
 
  		s name=item.Name
  		S HostStatus(name)=item.Category_"^"_item.ClassName_"^"_i
  		S HostStatus(name,"Category")=item.Category
  		S HostStatus(name,"RunningStatus")=item.Enabled+0
  		S HostStatus(name,"ClassName")=item.ClassName
  		S HostStatus(name,"ID")=i 
  		
 	}

	 
	$$$TRACE("3.Collecting statistics...")
 	set rs=##class(%ResultSet).%New("Ens.Util.Statistics:EnumerateHostStatus")
 	Set r=rs.Execute()
 
	while rs.Next() {
		Set name=rs.Get("Name")
		// $$$TRACE("--> Statistics for: "_name)
 		Set HostStatus(name,"Status")=rs.Get("Status")
  		Set HostStatus(name,"AdapterState")=rs.Get("AdapterState")
  		Set HostStatus(name,"LastAction")=rs.Get("LastActivity")
  		Set HostStatus(name,"ElapsedTime")=rs.Get("ElapsedTime")
  		set HostStatus(name,"Queue")=rs.Get("Queue")+0
  		Set HostStatus(name,"Count")=rs.Get("Count")+0
	}

	$$$TRACE("4.Get list of items and parameters that are monitored")
	K ParamList
	Set rs=##class(%ResultSet).%New()
	set ParamSelect = ""
	set ParamSelect = ParamSelect_"Select "
	set ParamSelect = ParamSelect_"p.ID, p.Active, p.AlertDuration, p.ItemName, p.NotificationEmail, p.EmailText, p.Parameter, p.Threshold, p.ThresholdDuration, p.HolidayOnly, p.Holidays, "
	set ParamSelect = ParamSelect_"s.HourStart, s.HourEnd, s.M, s.T, s.W, s.Th, s.F, s.Sa, s.Su "
	set ParamSelect = ParamSelect_"from IIBAENSEMBLE_Monitor.ItemParameters P "
	set ParamSelect = ParamSelect_"inner join IIBAENSEMBLE_Monitor.tblSchedules S "
	set ParamSelect = ParamSelect_"on P.ID = S.ParameterID "
	set ParamSelect = ParamSelect_"where P.Active=1 order by P.ItemName"
	Do rs.Prepare(ParamSelect)
	Do rs.Execute()
	
	While(rs.Next(.sc)) {
		
		If ($System.Status.IsOK(sc) )  {
			Set Name=rs.Data("ItemName")
			Set ParamList(Name)=1
			Set Parameter=rs.Data("Parameter")
			Set ParamList(Name,Parameter,"ID")=rs.Data("ID")
			Set ParamList(Name,Parameter,"Threshold")=rs.Data("Threshold")
			Set ParamList(Name,Parameter,"ThresholdDuration")=rs.Data("ThresholdDuration")
			Set ParamList(Name,Parameter,"AlertDuration")=rs.Data("AlertDuration")
			Set ParamList(Name,Parameter,"Schedule","HourStart")=rs.Data("HourStart")
			Set ParamList(Name,Parameter,"Schedule","HourEnd")=rs.Data("HourEnd")
			Set ParamList(Name,Parameter,"Schedule",0)=rs.Data("Su")
			Set ParamList(Name,Parameter,"Schedule",1)=rs.Data("M")
			Set ParamList(Name,Parameter,"Schedule",2)=rs.Data("T")
			Set ParamList(Name,Parameter,"Schedule",3)=rs.Data("W")
			Set ParamList(Name,Parameter,"Schedule",4)=rs.Data("Th")
			Set ParamList(Name,Parameter,"Schedule",5)=rs.Data("F")
			Set ParamList(Name,Parameter,"Schedule",6)=rs.Data("Sa")
			Set ParamList(Name,Parameter,"EMail")=rs.Data("NotificationEmail")
			Set ParamList(Name,Parameter,"EMailText")=rs.Data("EmailText")
			Set ParamList(Name,Parameter,"HolidayOnly")=rs.Data("HolidayOnly")
			Set ParamList(Name,Parameter,"Holidays")=rs.Data("Holidays")

		}
	}
	
	// *** Now check current status - and report alerts ***
	$$$TRACE("6.Check for Alerts that need to be reported")
	//New SQLCODE,%ROWCOUNT
	
	//Traverse through the list of names in the parameter list
	Set Name=""
	For {
		Set Name=$O(ParamList(Name)) 
		Q:Name=""
		
		
		$$$TRACE("6-5. Checking Alert Exceptions")
		S AlertException=0
		//s aers=##class(%ResultSet).%New()
		//d aers.Prepare("select count (*) AS AlertException from IIBAENSEMBLE_Monitor.AlertExceptions where ItemName = :Name and GETDATE() between StartDttm and EndDttm")
		//d aers.Execute()
		//d aers.Next()
		//s AlertException=aers.Data("AlertException")
		&sql(select count (*) INTO :AlertException from IIBAENSEMBLE_Monitor.AlertExceptions 
			where ItemName = :Name and 
			GETDATE() between StartDttm and EndDttm)
		$$$TRACE("Alert Exception: "_AlertException)

		
			
		If ( AlertException < 1 ) {
			
			
					
			// For each item, traverse through the list of conditions that need to be monitored
			Set AlertMessage=""
			//set AlertMessage="http://ensembletest01/csp/iibasupport/IIBAInterfaceStatus.csp?InterfaceName="_Name
			//set AlertMessage="http://ensembletest01/csp/iibasupport/IIBASystemStatus.csp"
			Set AlertSubject=""
			Set AlertEmailList=""
			Set Parameter=""
			Set AlertActions=""

			For {
				Set Parameter=$O(ParamList(Name,Parameter))
				Q:Parameter=""
			
				Set today=$ZDATE($H,8)
				Set CheckAlertFlag=0
				// Is this alert for Holidays only?
				if (ParamList(Name,Parameter,"HolidayOnly")=1) {
				
					if ($DATA(^ZAlert.Holiday(today))>0) {
						$$$TRACE("Holiday alert only: Today is a holiday- Holiday List: "_ParamList(Name,Parameter,"Holidays"))
						Set TodayHoliday=^ZAlert.Holiday(today)
						If ( $LF($LFS(ParamList(Name,Parameter,"Holidays"),"^"),TodayHoliday)>0) {
							$$$TRACE("This Holiday is defined for this parameter")
							Set CheckAlertFlag=1
						}
					} else {
						// do nothing - at this point I need to go the next parameter...
						$$$TRACE("This is a holiday only alert, but today is not a holiday")
						Set CheckAlertFlag=0
					}
				} elseif ($DATA(^ZAlert.Holiday(today))>0) {
					$$$TRACE("Today is a holiday- Holiday List: "_ParamList(Name,Parameter,"Holidays"))
					Set TodayHoliday=^ZAlert.Holiday(today)
					If ( $LF($LFS(ParamList(Name,Parameter,"Holidays"),"^"),TodayHoliday)>0) {
						$$$TRACE("This Holiday is defined for this parameter")
						Set CheckAlertFlag=1
					}
				} else {
					$$$TRACE("Need to do normal checking of this alert")
					Set CheckAlertFlag=1
				}
			
				//  ******* Need to check the alert if flag is set *****
				If (CheckAlertFlag=1) {
				$$$TRACE("Checking the Alert...")
			
				// For each Parameter, check the schedule to determine if this alert should be used now
				if ($P($H,",",2)>(3600*ParamList(Name,Parameter,"Schedule","HourStart")))
					&($P($H,",",2)<(3600*ParamList(Name,Parameter,"Schedule","HourEnd")))
					&(ParamList(Name,Parameter,"Schedule",$ZD($H,10))=1) {

					Set LastStatus=""
					Set TimeLastStatus=""
					Set TimeLastAlert=""
			
					// Get info regarding last time the status changed and alert was reported
					&sql(Select Top 1 LastStatus,TimeLastStatus,TimeLastAlert 
						into :LastStatus,:TimeLastStatus,:TimeLastAlert
						From IIBAENSEMBLE_Monitor.ItemStatus
						Where ItemName=:Name and Parameter=:Parameter)
					
					$$$TRACE("7.Query for ItemStatus info for: "_Name_"/"_Parameter_" SQLCODE: "_SQLCODE_" ROWCOUNT: "_%ROWCOUNT)
			
					s LastCount=0
					if (Parameter="CountChange") {
						Set CurrentStatus=$G(HostStatus(Name,"Count"))
						s LastCount=LastStatus
						W !,"Current Count is: "_CurrentStatus
					} else {
						Set CurrentStatus=$G(HostStatus(Name,Parameter))
					}
					Set CurrentTime=$ZDT($H,3)

					If ( SQLCODE=0 ) {
				
						$$$TRACE("8.Check for a status change...("_Name_","_Parameter_": Last Status: "_LastStatus_","_TimeLastStatus_", Current Status: "_CurrentStatus_")")
						// Each condition is checked explicility - this is easier to maintain.
						//     When adding a new type of condition - a relavant section will need to be added.
					
						If ((Parameter="Queue") ||( Parameter="Count") || (Parameter="CountChange"))  {
							If ( ( CurrentStatus > ParamList(Name,Parameter,"Threshold") )  && ( LastStatus > ParamList(Name,Parameter,"Threshold") ) ) {
								Set LastStatus=CurrentStatus
							} ElseIf ( ( CurrentStatus < ParamList(Name,Parameter,"Threshold") )  && ( LastStatus < ParamList(Name,Parameter,"Threshold") ) ) {
								Set LastStatus=CurrentStatus
							}
						}
									
						$$$TRACE("9.Check for a status change...("_Name_","_Parameter_": Last Status: "_LastStatus_","_TimeLastStatus_", Current Status: "_CurrentStatus_")")
				
						If ( CurrentStatus'=LastStatus ) {
						// The Status has changed: record the the change, and coclude the processing of this item/parameter.
							s InfoText=ParamList(Name,Parameter,"EMailText")
							&sql( Update IIBAENSEMBLE_Monitor.ItemStatus Set
									LastStatus=:CurrentStatus,
									TimeLastStatus=:CurrentTime,
									EmailText=:InfoText
								Where
									ItemName=:Name and
									Parameter=:Parameter  )
						} Else {
							// The Status has not changed: Check for alerts that need to be reported
							$$$TRACE("10.Checking for alert conditions...")
							S Message=""
							If ( Parameter="RunningStatus" ) {
								If (  CurrentStatus=ParamList(Name,Parameter,"Threshold") ) {
									S Message= ProductionName_":   Item "_Name_" RunningStatus is "_$CASE(CurrentStatus,1:"Enabled",:"Disabled")
								
								}
							} ElseIf ( Parameter="Status") {
								If (  CurrentStatus=ParamList(Name,Parameter,"Threshold") ) {
									S Message= ProductionName_":   Item "_Name_" Status is "_CurrentStatus
								
								}
							} ElseIf ( Parameter="Queue") {
				
								If (  CurrentStatus>ParamList(Name,Parameter,"Threshold") ) {
									S Message= ProductionName_":  Item "_Name_" Queue size is "_HostStatus(Name,"Queue")
								
								}
							} ElseIf ( Parameter="Count") {
				
								If (  CurrentStatus>=ParamList(Name,Parameter,"Threshold") ) {
									S Message= ProductionName_":  Item "_Name_" Count size is "_HostStatus(Name,"Count")
								
								}	
							} ElseIf ( Parameter="AdapterState" ) {
								// W Name,"--> Current Status is: ",CurrentStatus,"  condition: ",ParamList(Name,Parameter,"Threshold"),!
								If ( (CurrentStatus'="") & ( CurrentStatus'[ParamList(Name,Parameter,"Threshold") ) ) {
								//If ( $FIND(CurrentStatus,ParamList(Name,Parameter,"Threshold"))>0 ) {
									S Message= ProductionName_":  Item "_Name_" Adapter State is: "_CurrentStatus
								
								}
						
							} ElseIf ( Parameter="LastAction") {
								Set TimeDiff=""
								Set LastAction=$P(CurrentStatus,".",1)
								&sql(Select distinct {fn TimestampDiff(SQL_TSI_SECOND,:TimeLastStatus,:CurrentTime) } 
									into :TimeDiff
									From IIBAENSEMBLE_Monitor.ItemStatus )
								If TimeDiff>ParamList(Name,Parameter,"Threshold") {
									if (TimeDiff > 3600 ) {
										S H=TimeDiff\3600
										S M=TimeDiff#3600\60
										If ($LENGTH(M)=1) {
											S M="0"_M
										}
										S dTimeDiff=H_":"_M_" Hours"
									} Elseif ( TimeDiff > 60 ) {
										S M=TimeDiff\60
										S S=TimeDiff#60
										If ( $LENGTH(S)=1) {
											S S="0"_S
										}
										S dTimeDiff=M_":"_S_" Minutes"
									} Else {
										s dTimeDiff=TimeDiff_" Seconds"
									}
									
									S Message=ProductionName_": Item "_Name_"- "_dTimeDiff_" have elapsed since the last transaction."
								
								}

							} ElseIf ( Parameter="CountChange") {
									
								// Implementation in progress
								// Logic for change in message count:
								// - Time difference since last status
								// - Message count since last status
								//
								// If ( TimeDiff>duration)
								//     Update status
								//     If CountChange exceeds threshold
								//        alert
								//     }
								// }
								
								S StatusDiff=0
								&sql(Select distinct {fn TimestampDiff(SQL_TSI_SECOND,:TimeLastStatus,:CurrentTime) } 
									into :StatusDiff
									From IIBAENSEMBLE_Monitor.ItemStatus )
								
								
								If (StatusDiff > ParamList(Name,Parameter,"ThresholdDuration")) {	
								
									//Update status with current count
									s NameSpace=$ZNSPACE
									s InfoText=ParamList(Name,Parameter,"EMailText")
									&sql( Update IIBAENSEMBLE_Monitor.ItemStatus Set
										LastStatus=:CurrentStatus,
										TimeLastStatus=:CurrentTime,
										EmailText=:InfoText
									Where
										ItemName=:Name and
										NameSpace=:NameSpace and
										Parameter=:Parameter  )
								}
									s CountChange=CurrentStatus-LastCount
									$$$TRACE("Count Change: "_CountChange)
									s threshold=ParamList(Name,Parameter,"Threshold")
									if ($E(threshold)="<") {
										if ((CountChange>=0) && (CountChange<$E(threshold,2,$L(threshold)))) {
											s Message=ProductionName_": Item "_Name_" - The Message count is lower than expected ("_threshold_")"
											set troubled(Name,Parameter) = 1
													
											Try {
												set status = ##class(Ens.Director).EnableConfigItem(Name,0,0)
												Job ##class(Ens.Director).UpdateProduction()
												$$$TRACE("Count Change disabling: "_Name)
											} Catch errobj {
												Do ##class(Ens.Util.Log).LogError("IIBAENSEMBLE.Utilities","CycleInterface","Disable failed: "_errobj.Name)
											}
	

											// sleep for a few seconds to let things settle
											H 10
	
											// Enable the interface
											Try {
												set status = ##class(Ens.Director).EnableConfigItem(Name,1,0)
												Job ##class(Ens.Director).UpdateProduction()
												$$$TRACE("Count Change enabling: "_Name)
											} Catch errobj {
												Do ##class(Ens.Util.Log).LogError("IIBAENSEMBLE.Utilities","CycleInterface","Enable failed: "_errobj.Name)
											}
										}
									} elseif ($E(threshold)=">") {
										if (CountChange>$E(threshold,2,$L(threshold))) {
											s Message=ProductionName_": Item "_Name_" - The Message count is higher than expected ("_threshold_")"
											set troubled(Name,Parameter) = 1
										}
									}
								
									
								$$$TRACE("Count Change Message: "_Message)
								//s Message=""
									
								
								
							}
					
							If ( Message '= "" ) {
						
								$$$TRACE("11.Alert Condition has been identified... ")
								S StatusDiff=0
								&sql(Select distinct {fn TimestampDiff(SQL_TSI_SECOND,:TimeLastStatus,:CurrentTime) } 
									into :StatusDiff
									From IIBAENSEMBLE_Monitor.ItemStatus )
						
								$$$TRACE("12.Time since last status: "_StatusDiff)
								If (StatusDiff > ParamList(Name,Parameter,"ThresholdDuration")) {
									//Add this item to the troubled array for updating the troubled column after the loop is done
									set troubled(Name,Parameter) = 1
								
									S AlertDiff=0
									&sql(Select distinct {fn TimestampDiff(SQL_TSI_SECOND,:TimeLastAlert,:CurrentTime) }
										into :AlertDiff
										From IIBAENSEMBLE_Monitor.ItemStatus )
							
									$$$TRACE("13.  Time since last alert: "_AlertDiff_" / Parameter setting: "_ParamList(Name,Parameter,"AlertDuration"))
									If ( AlertDiff="") {
										Set AlertDiff=86400
									}
								
							
									If ( AlertDiff > ParamList(Name,Parameter,"AlertDuration") ) {
										// We have an alert that needs to be reported
										// W "-------------------------",!
										// W "Email: "_ParamList(Name,Parameter,"EMail"),!
										// W "Subject: Ens Alert: "_Name_"/"_Parameter,!
										// W "Message Body: ",Message,!
										$$$TRACE("14.Codition to report: "_Name_"/"_Parameter_": "_ParamList(Name,Parameter,"EMail")_"  "_Message)
								
										If ( AlertSubject="" ) {
											Set AlertSubject="Ens Alert "_Name_": "_Parameter
										} Else {
											Set AlertSubject=AlertSubject_", "_Parameter
										}
								
										If ( AlertEmailList="" ) {
											Set AlertEmailList=ParamList(Name,Parameter,"EMail")
									
										} Else {
											S ePtr=0
											WHILE $LISTNEXT($LISTFROMSTRING(ParamList(Name,Parameter,"EMail"),","),ePtr,Email) {
												IF ( AlertEmailList'[Email ) {
													Set AlertEmailList=AlertEmailList_","_Email
												}
											}
										}
								
										Set AlertMessage=AlertMessage_$C(13,10)_Message
										Set:ParamList(Name,Parameter,"EMailText")'="" AlertMessage=AlertMessage_$C(13,10)_ParamList(Name,Parameter,"EMailText")
										
										s NameSpace=$ZNSPACE
										$$$TRACE("15.Updating ItemStatus Table ("_Name_","_NameSpace_","_Parameter_") with:  "_CurrentTime_"/"_Message)
										s EmailText=ParamList(Name,Parameter,"EMailText")
										&sql( Update IIBAENSEMBLE_Monitor.ItemStatus Set
												TimeLastAlert=:CurrentTime,
												LastAlert=:Message,
												EmailText=:EmailText
											Where 
												ItemName=:Name and
												NameSpace=:NameSpace and
												Parameter=:Parameter )
											
											
										$$$TRACE("16. Update list of actions")
										Set Ars=##class(%ResultSet).%New()
										Do Ars.Prepare("Select ActionID from IIBAENSEMBLE_Monitor.ItemAction where ItemID="_ParamList(Name,Parameter,"ID") )
										Do Ars.Execute()
										While (Ars.Next()) {
											Set Action=Ars.Data("ActionID")
											$$$TRACE("Action: "_Action)
											If ( AlertActions="" ) {
												Set AlertActions=$LB(Action)
											} Else {
												if ( $LF(AlertActions,Action)<1) {
													Set AlertActions=AlertActions_$LB(Action)
												}
											}
										
										}
										close Ars

									}
								}
							}
						}
			
					} Elseif ( SQLCODE=100) {
				
						// Row does not exist - add to the status table
						$$$LOGINFO(ProductionName_": Monitoring Service : Row missing in ItemStatus Table for "_Name_"/"_Parameter_"/"_CurrentStatus_"/"_CurrentTime_" : Action - Row added")
						S NameSpace=$ZNSPACE
						s EmailText=ParamList(Name,Parameter,"EMailText")
						&sql(Insert into IIBAENSEMBLE_Monitor.ItemStatus 
							(NameSpace,ItemName,Parameter,LastStatus,TimeLastStatus,EmailText) values
							(:NameSpace,:Name,:Parameter,:CurrentStatus,:CurrentTime,:EmailText) )
					}
				}
			
				//  *** End of need to check alert because flag is set
				}
			}
		
	
			// do we have alerts to report?
			If ( AlertEmailList'="" ) {
			
			
			
				Set i=0
				WHILE $LISTNEXT($LISTFROMSTRING(AlertEmailList,","),i,Email) {
				
					$$$TRACE("16.Alert for "_Email_"  Subject: "_AlertSubject)
					Set EmailRequest=""
					Set EmailRequest= ##class(IIBAENSEMBLE.msg.EmailSendRequest).%New()
					Set EmailRequest.Subject=AlertSubject
					Set EmailRequest.Text=AlertMessage

					Set EmailRequest.Destination=Email
				
					For j=1:1:$L(..TargetConfigNames,",") {
						S target=$P(..TargetConfigNames,",",j)
						If ( target '= "" ) {
							Do ..SendRequestAsync(target,EmailRequest)
						}
					}
				}
			}

		}
	}
	
	//Update Troubled Column in Status Table
		
	set rs = ##class(%ResultSet).%New()
	do rs.Prepare("Select distinct ID, ItemName, Parameter from IIBAENSEMBLE_Monitor.ItemStatus")
	do rs.Execute()
	
	While rs.Next() {
			
		set ID = "", Name="", Parameter=""
		S NameSpace=$ZNSPACE
		set ID = rs.Data("ID"), Name = rs.Data("ItemName"), Parameter = rs.Data("Parameter")
		if $DATA(troubled(Name,Parameter)) = 0 {
			&sql(UPDATE IIBAENSEMBLE_Monitor.ItemStatus SET Troubled = 0 WHERE NameSpace=:NameSpace and ItemName=:Name and Parameter=:Parameter)
		} elseif $DATA(troubled(Name,Parameter)) '= 0 {
			&sql(UPDATE IIBAENSEMBLE_Monitor.ItemStatus SET Troubled = 1 WHERE NameSpace=:NameSpace and ItemName=:Name and Parameter=:Parameter)
		}
	}


	
	
	Quit $$$OK
}

}
