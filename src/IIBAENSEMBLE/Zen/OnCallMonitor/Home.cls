/// Created using the page template: Title Page
Class IIBAENSEMBLE.Zen.OnCallMonitor.Home Extends %ZEN.Component.page [ DependsOn = IIBAENSEMBLE.Zen.ToolkitHeader ]
{

/// Class name of application this page belongs to.
Parameter APPLICATION = "IIBAENSEMBLE.Zen.Toolkit";

/// Displayed name of this page.
Parameter PAGENAME = "OnCallMonitor";

/// Domain used for localization.
Parameter DOMAIN = "ZENToolKIT";

Property showMessages As %Boolean [ InitialExpression = 0 ];

Property show24hours As %Boolean [ InitialExpression = 0 ];

Property showToday As %Boolean [ InitialExpression = 1 ];

Property startDTTM As %String [ InitialExpression = {$ZDATE($HOROLOG,3,1)_" 00:00:00.000"} ];

Property endDTTM As %String [ InitialExpression = {$ZDATETIME($HOROLOG,3,1)_".999"} ];

Property DTTM24hours As %String [ InitialExpression = {$ZDATETIME($HOROLOG-1_","_$P($HOROLOG,",",2),3,1)} ];

Property todayDTTM As %String [ InitialExpression = {$ZDATE($HOROLOG,3,1)_" 00:00:00.000"} ];

/// This Style block contains page-specific CSS style definitions.
XData Style
{
<style type="text/css">
/* style for table */
#OnCallMonitorTable {
	background: #004C8F;
	color: black;
	font-family: Verdana;
	font-size: .9em;
	padding: 8px;
	border-bottom: 1px solid black;
	text-align: center;
}
#OnCallMonitorNav {
	background: #004C8F;
	border-top: 8px solid #004C8F;
	border-left: 8px solid #004C8F;
	border-right: 8px solid #004C8F;
	text-align: center;
}

</style>
}

/// This XML block defines the contents of this page.
XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns:ZENToolKIT="http://www.intersystems.com/toolkitheader" title="IIBA Support On-Call" id="maintitle">

<ZENToolKIT:ToolkitHeader id="title" title="On-Call Monitor"/>

<fieldSet id="OnCallFormGroup" hidden="false" width="100%" >

    <expando caption="Monitor" framed="true" animate="true" expanded="false" onexpand="zenPage.SetFilters();">
    <spacer height="5px"/>
    <hgroup id="hgrp1">
    <spacer width="5px"/>
    <csMenuBar id="mainMenu" width="5.7%">
  <csMenuBarItem caption="Options" contextKey="O" id="menu">
    <contextMenu id="fileMenu" >
      <csMenuItem id="CheckMsg" caption="Has Message" key="Ctrl-A"
                  contextKey="a" onclick="zenPage.UpdateQuery('msg');" toggleMode="true"/>
      <csMenuItem id="24hrs" caption="Last 24 hours"
                  key="Ctrl-Z" contextKey="z"
                  onclick="zenPage.UpdateQuery('hrs');" toggleMode="true" toggleState="0"/>
      <csMenuItem id="today" caption="Today"
                  key="Ctrl-E" contextKey="t"
                  onclick="zenPage.UpdateQuery('today');" toggleMode="true" toggleState="1"/>
      <csMenuItem id="LogErrors" caption="Hide"
                  key="Ctrl-L" contextKey="h"
                  onclick="zenPage.LogErrors();"/>
      <csMenuItem id="ClearErrors" caption="UnHide"
                  key="Ctrl-Y" contextKey="y"
                  onclick="zenPage.ClearErrors();"/>
      	
     </contextMenu>
  </csMenuBarItem>
  </csMenuBar>
  <hgroup id="hgrp2" align="center">
    <spacer width="670px"/>
    <dateText id="startdttm" title="Start Date/Time" timeCaption="Time: " size="18px" value='' showTime="true" onchange="zenPage.UpdateQuery('TFM');"/>
    <spacer width="2px"/>
	<html id="htmltext1">TO:</html> 
  	<spacer width="2px"/>
  	<dateText id="enddttm" title="End Date/Time" timeCaption="Time: " size="18px" value='' showTime="true" onchange="zenPage.UpdateQuery('TFM');" />
  </hgroup>
  </hgroup>
	<spacer height="5px"/>
	<tableNavigator id="OnCallMonitorNav" tablePaneId="OnCallMonitorTable" />
 	
 	<hgroup valign="top">
 	
    <tablePane 
   id="OnCallMonitorTable" 
   	useSnapshot="true"
	showZebra="true"
	valueColumn="details"
	pageSize="20"
	maxRows="10000"
	showQuery="false"
	nowrap="true" 
	enableToggleSelect="true"
	queryClass="IIBAENSEMBLE.Zen.OnCallMonitor.Home" 
	queryName="ErrorQuery"
	initialExecute="false"
	showFilters="false"
	ondblclick=""
	multiSelect="true"
	rowSelect="true"
	showRowNumbers="true"
	showRowSelector="false"


		
	>
<column header="ID" colName="ID" width="1px" filterType="text" filterOp="=" hidden="true" />
<column id="NameSpace" header="NameSpace" colName="Namespace" width="100px" filterType="enum" filterEnum="" filterOp="=" hidden="false" />
<column id="BusinessItem" header="Business Item" colName="ConfigName" width="435px" filterOp="=" filterType="text" hidden="false" />
<column header="Type" width="50px" colName="Type" filterType="text" filterOp="=" style="color: red;"/>
<column header="Entry Date" width="200px" colName="TimeLogged" filterType="text" filterOp="="/>
<column header="Identifier" width="300px" colName="SourceClass" filterType="text" filterOp="="/>
<column header="Error Message" width="485px" colName="Text" filterType="text" onclick="//alert('#(%query.ID)#');" filterOp="="/>
<column header="SessionId" width="75px" colName="SessionId" hidden="true"/>
<column colName="MessageId" hidden="true"/>
<column header="" width="55px" linkCaption="Details" link="javascript:zenPage.launchErrors('#(%query.ID)#','#(%query.Namespace)#');" style="color: green;"/>
<column id="MsgResend" header="" width="55px" linkCaption="Resend" link="javascript:zenPage.ResendErrors('#(%query.SessionId)#','#(%query.Namespace)#','#(%query.MessageId)#');" style="color: blue;" hidden="true"/>
<column id="MsgLog" hidden="true" header="" width="25px" linkCaption="Log" link="javascript:zenPage.LogErrors('#(%query.MessageId)#','#(%query.Namespace)#','#(%query.SessionId)#');" style="color: blue;"/>    
<column colName="details" hidden="true"/>
<column id="ItemStatus" header=" " colName="Status" OnDrawCell="DrawItemStatus" width="20px"/>

    </tablePane>
    </hgroup>
    
	<iframe id="MsgiFrame" src="" width="100%" height="0px" frameAlign="center" dragEnabled="true" scrolling="yes" hidden="false" />
	 
	</expando>
	</fieldSet>
</page>
}

Method DrawItemStatus(pTable As %ZEN.Component.tablePane, pName As %String, pSeed As %String) As %Status
{
	//find item status to set light indicator
	set tStatus = $P(%query(pName),"~",1)
	set tNameSpace = $P(%query(pName),"~",2)
	if tStatus="OK" {
    	&html<
    		<a href='/csp/#(tNameSpace)#/EnsPortal.ProductionConfig.zen?$NAMESPACE=#(tNameSpace)#' target='_blank'><img src='customimages/aGreenLight.jpg'/></a>
    	>
	}elseif tStatus="Error" {
		&html<
    		<a href='/csp/#(tNameSpace)#/EnsPortal.ProductionConfig.zen?$NAMESPACE=#(tNameSpace)#' target='_blank'><img src='customimages/RedLight.jpg'/></a>
    	>
	}else{
		&html<
    		<a href='/csp/#(tNameSpace)#/EnsPortal.ProductionConfig.zen?$NAMESPACE=#(tNameSpace)#' target='_blank'><img src='customimages/YellowLight.jpg'/></a>
    	>
	
	}
	
	Quit $$$OK
}

ClientMethod ClearErrors() [ Language = javascript ]
{
   var pAlert = confirm("Are you sure you want to clear Unhide logged errors?");
   
   if (pAlert == 1)
   {
	 zenPage.ClearErrorsLog();   
   }
   var table = zenPage.getComponentById('OnCallMonitorTable');
   table.executeQuery();
}

ClientMethod LogErrors(id, gtNS, sId) [ Language = javascript ]
{
	//alert(id+"/"+gtNS+"/"+"/"+sId);
	var rows = zenPage.getComponentById('OnCallMonitorTable').getProperty('selectedRows').split(',');
	var reason = prompt("Please enter log reason for error "+id, "benign error");
	for (i = 0; i < rows.length; i++) {
		if (rows[i].split('~',1)!=""){
			
			var id = rows[i].replace(/~/gi,',').split(',')[0];
			var gtNS = rows[i].replace(/~/gi,',').split(',')[1];
			var sId = rows[i].replace(/~/gi,',').split(',')[2];
					
			switch(reason){
				case "":
					text = "log reason cannot be blank";
					break;
				case null:
					break;
				default:
					this.LogError(id,gtNS,reason,sId);
					break; 
    			
			}	
		}
	}
	
		
	var page = zenPage.getComponentById('MsgiFrame');
	page.setProperty('src',"");
	var table = zenPage.getComponentById('OnCallMonitorTable');
	table.executeQuery();
}

ClientMethod ResendErrors(id, gtNS, mId) [ Language = javascript ]
{
	this.SendMessage(id,gtNS,"RESEND",mId);
	var table = zenPage.getComponentById('OnCallMonitorTable');
	table.executeQuery();
}

ClientMethod getiFrameMsg(id, gtNS) [ Language = javascript ]
{
	var page = zenPage.getComponentById('MsgiFrame');
	page.setProperty('src',"/csp/"+gtNS+"/EnsPortal.MessageContents.zen?HeaderClass=Ens.MessageHeader&HeaderId="+id);
}

ClientMethod UpdateQuery(pAction) [ Language = javascript ]
{
	
	if (pAction == 'msg'){
		
		var id = zenPage.getComponentById('CheckMsg');
		var toggleState = "";
		if (this.showMessages == id.getProperty('toggleState')){
			
			if (this.showMessages == 0){
				toggleState = 1;
				id.setProperty('toggleState',1);
				zenPage.getComponentById('MsgiFrame').setProperty('height','300px');
			}else{
				toggleState = 0;
				id.setProperty('toggleState',0);
				zenPage.getComponentById('MsgiFrame').setProperty('height','0px');
			}
			
		}else{
			
			toggleState = id.getProperty('toggleState');
			
			}
				
		this.showMessages = toggleState;
		
		if (id.getProperty('toggleState') == 1){
			var page = zenPage.getComponentById('BusinessItem');
			page.setProperty('link',"javascript:zenPage.getiFrameMsg('#(%query.SessionId)#','#(%query.Namespace)#');");
			var page = zenPage.getComponentById('MsgResend');
			page.setProperty('hidden',false);
			zenPage.getComponentById('MsgiFrame').setProperty('height','300px');
		}else{
			var page = zenPage.getComponentById('BusinessItem');
			page.setProperty('link',"");
			var page = zenPage.getComponentById('MsgResend');
			page.setProperty('hidden',true);
			var page = zenPage.getComponentById('MsgiFrame');
			page.setProperty('src',"");
			zenPage.getComponentById('MsgiFrame').setProperty('height','0px');
		}
	}
	if (pAction == 'hrs'){
		var id = zenPage.getComponentById('24hrs');
		var toggleState = "";
		if (this.show24hours == id.getProperty('toggleState')){
			
			if (this.show24hours == 0){
				toggleState = 1;
				id.setProperty('toggleState',1);
			}else{
				toggleState = 0;
				id.setProperty('toggleState',0);
			}
			
		}else{
			
			
			toggleState = id.getProperty('toggleState');
			
			}
			
		if (toggleState == 1){
			zenPage.getComponentById('today').setProperty('toggleState',0);
			zenPage.getComponentById('startdttm').setProperty('value',this.DTTM24hours);
			this.startDTTM = this.DTTM24hours;
			this.show24hours = toggleState;
			this.showToday = 0;
		}else{
			zenPage.getComponentById('today').setProperty('toggleState',1);
			zenPage.getComponentById('startdttm').setProperty('value',this.todayDTTM);
			this.show24hours = toggleState;
			this.startDTTM = this.todayDTTM;
			this.showToday = 1;
			}
				
		
		
			
	}
	if (pAction == 'TFM'){
		var startDTTM = zenPage.getComponentById('startdttm').getProperty('value');
		var endDTTM = zenPage.getComponentById('enddttm').getProperty('value');
		this.startDTTM = startDTTM;
		this.endDTTM = endDTTM;
		zenPage.getComponentById('24hrs').setProperty('toggleState',0);
		this.show24hours = 0;
		this.showToday = 0;
		zenPage.getComponentById('today').setProperty('toggleState',0);
		
		
	}
	if (pAction == 'today'){
		var id = zenPage.getComponentById('today');
		var toggleState = "";
		if (this.showToday == id.getProperty('toggleState')){
			
			if (this.showToday == 0){
				toggleState = 1;
				id.setProperty('toggleState',1);
			}else{
				toggleState = 0;
				id.setProperty('toggleState',0);
			}
			
			}else{
			
			
			toggleState = id.getProperty('toggleState');
			
			}
			
		if (toggleState == 0){
			zenPage.getComponentById('24hrs').setProperty('toggleState',1);
			zenPage.getComponentById('startdttm').setProperty('value',this.DTTM24hours);
			this.show24hours = 1;
			this.startDTTM = this.DTTM24hours;
			this.showToday = toggleState;
		}else{
			zenPage.getComponentById('24hrs').setProperty('toggleState',0);
			zenPage.getComponentById('startdttm').setProperty('value',this.todayDTTM);
			this.show24hours = 0;
			this.startDTTM = this.todayDTTM;
			this.showToday = toggleState;
			
		}
		
		
	}
	var table = zenPage.getComponentById('OnCallMonitorTable');
	table.executeQuery();
}

ClientMethod launchErrors(id, gtNS) [ Language = javascript ]
{
	//alert(id);
	zenPage.launchPopupWindow(
    'IIBAENSEMBLE.Zen.OnCallMonitor.ErrorStack.cls?ID='+id+'&NS='+gtNS+'',
    '',
    'status,scrollbars,resizable,width=500,height=450,modal=yes');
}

ClientMethod SetFilters() [ Language = javascript ]
{
	
	zenPage.getComponentById('startdttm').setProperty('value',this.startDTTM);
	zenPage.getComponentById('mainMenu').setProperty('hidden',false);		
	zenPage.getComponentById('enddttm').setProperty('value',this.endDTTM);
	zenPage.getComponentById('OnCallMonitorTable').executeQuery();
}

Query ErrorQuery() As %Query(ROWSPEC = "Namespace:%String,ConfigName:%String,Text:%String,ID:%String,SourceClass:%String,TimeLogged:%String,SessionId:%String,MessageId:%String,details:%String,Status:%String")
{
}

ClassMethod ErrorQueryExecute(ByRef qHandle As %Binary) As %Status
{
                K NamespaceList
                K SystemInfo
               
                s qCurrentNamespace = $SYSTEM.SYS.NameSpace()
                s qNamespace = ""
                s datetimebegin = %page.startDTTM
                s datetimeend = %page.endDTTM
                s showMessages = " GROUP BY MessageId"
                s tStatus = ""
                s thostTemp = ""
                If (qNamespace="") {
                                d ##class(Ens.Director).GetSystemProductionSummary(.SystemInfo)
                }
                
                s Namespace=""
                s pSC = $$$OK
                
                F  {
                                s Namespace=$O(SystemInfo(Namespace))
                                Q:Namespace=""
                                Continue:$O(SystemInfo(Namespace,""))=""
                                
                                
                                	zn Namespace
                               		
                               		//get host status
									s dt2days = $ZDATETIME($HOROLOG-2_","_$P($HOROLOG,",",2),3,1)
        							&sql(DELETE IIBAENSEMBLE_Zen_OnCallMonitor.ErrorLogging where InputDateTime < :dt2days)
                            		do ..GetItemStatus(.hostTemp)
                               		
                                	set rs = ""
                                	
                                	if %page.showMessages = 1 { s showMessages = " AND SessionId IS NOT NULL GROUP BY SessionId"}
                                	if %page.show24hours = 1 { s datetimebegin = %page.DTTM24hours}
                                
                                	set tSQL = "SELECT * FROM Ens_Util.Log WHERE Type = 'Error' AND ConfigName IS NOT NULL AND TimeLogged BETWEEN '"_datetimebegin_"' AND '"_datetimeend_"'"_showMessages_""
                                	
                                	//unique on messageid
                                	set rs = ##class(%ResultSet).%New()
                                	s pSC = rs.Prepare(tSQL) q:'pSC
                                	s pSC = rs.Execute() q:'pSC
                                                                	                            	
                                	While rs.Next() {
                                               	
                                               	s tConfigName = rs.%GetData(2)
                                               	
                                               if (tConfigName '="") {
	                                               	s tStatus = $GET(hostTemp(rs.%GetData(2)))
	                                            }
	                                            
                                               	s tText = rs.%GetData(9)
                                               	s tID = rs.%GetData(1)
                                               	s tSource = rs.%GetData(6)
                                               	s tLogged = rs.%GetData(10)
                                               	s tSessionId = rs.%GetData(5)
                                               	s tMessageId = rs.%GetData(4)
                                               	s tDetails = tMessageId_"~"_Namespace_"~"_tSessionId
                                               	
                                               	if ##class(IIBAENSEMBLE.Zen.OnCallMonitor.ErrorLogging).IdKeyExists(tMessageId,.id) = 0 {
	                                            	
		                                            	
		                                            	Set iRow=$I(qHandle("row")),qHandle("row",iRow)=$LB(Namespace,tConfigName,tText,tID,tSource,tLogged,tSessionId,tMessageId,tDetails,tStatus_"~"_Namespace)
	                                               	
                                               	}
                                                	
                                	}
                                	
                                
                                	
                                
                               
                }
               
                
                s qHandle("row")=0
                
                zn qCurrentNamespace
                
                Quit $$$OK
}

ClassMethod ClearErrorsLog() As %Status [ ZenMethod ]
{
	 K NamespaceList
     K SystemInfo
                
     s qCurrentNamespace = $SYSTEM.SYS.NameSpace()
     s qNamespace = ""
     If (qNamespace="") {
     	d ##class(Ens.Director).GetSystemProductionSummary(.SystemInfo)
     }
                
     s Namespace=""
     s tSC = $$$OK
                
     F  {
     	s Namespace=$O(SystemInfo(Namespace))
        Q:Namespace=""
        Continue:$O(SystemInfo(Namespace,""))=""
                                
                                
        zn Namespace
	
		s tRS = ##class(%ResultSet).%New()
		s tSQL = "SELECT %ID FROM IIBAENSEMBLE_Zen_OnCallMonitor.ErrorLogging"
		s tSC = tRS.Prepare(tSQL)
		s tSC = tRS.Execute()
	
		While tRS.Next(){
		
			s tSC = ##class(IIBAENSEMBLE.Zen.OnCallMonitor.ErrorLogging).%DeleteId(tRS.%GetData(1))
			
		}
     }
     
    zn qCurrentNamespace
     	
	Q tSC
}

ClassMethod GetItemStatus(Output pHostArray As %String) As %Status
{
 Set hRS=##class(%ResultSet).%New("Ens.Util.Statistics:EnumerateHostStatus")
 Set r=hRS.Execute()
 while hRS.Next() {
 	Set pHostArray(hRS.%GetData(1)) = hRS.%GetData(3)
 }
 quit
}

ClassMethod ErrorQueryClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = ErrorQueryExecute ]
{
                Kill qHandle
                Quit $$$OK
}

ClassMethod ErrorQueryFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = ErrorQueryExecute ]
{
                K Row s Row=""
                If ""=$G(qHandle("row")) Set AtEnd=1 Quit $$$OK
                
                s qHandle("row")=$O(qHandle("row",qHandle("row")))
                if (qHandle("row")="") {
                                set AtEnd=1
                } else {
                                s Row=qHandle("row",qHandle("row"))
                }
                
                Quit $$$OK
}

ClassMethod GetErrorCount(pAll As %Boolean = 1, Output pCount As %String) As %Status [ ZenMethod ]
{
	
    
    s tCount = 0
    s x = 0
    s tLogged = 0
    s qCurrentNamespace = $SYSTEM.SYS.NameSpace()
    s qNamespace = ""
    s datetimebegin = $ZDATE($HOROLOG,3,1)_" 00:00:00.000"
    s datetimeend = $ZDATE($HOROLOG,3,1)_" 23:59:59.999"
    s dt24hr = $ZDATETIME($HOROLOG-1_","_$P($HOROLOG,",",2),3,1)
                
    If (qNamespace="") {
         d ##class(Ens.Director).GetSystemProductionSummary(.SystemInfo)
    }
                
    s Namespace=""
                
    F  {
                                	
        s Namespace=$O(SystemInfo(Namespace))
        Q:Namespace=""
        Continue:$O(SystemInfo(Namespace,""))=""
                                
        zn Namespace
        
        &sql(DELETE IIBAENSEMBLE_Zen_OnCallMonitor.ErrorLogging where InputDateTime < :dt24hr)
        
        if pAll = 1 {                       
        	&sql(SELECT COUNT(DISTINCT MessageId) into :tCount FROM Ens_Util.Log WHERE Type = 2 AND TimeLogged BETWEEN :datetimebegin AND :datetimeend)
        	&sql(SELECT COUNT(*) into :tLogged FROM IIBAENSEMBLE_Zen_OnCallMonitor.ErrorLogging WHERE InputDateTime BETWEEN :datetimebegin AND :datetimeend)
        	set tCount = tCount - tLogged
        }else{
        	&sql(SELECT COUNT(DISTINCT SessionId) into :tCount FROM Ens_Util.Log WHERE Type = 2 AND TimeLogged BETWEEN :datetimebegin AND :datetimeend AND SessionId IS NOT NULL)
        	&sql(SELECT COUNT(*) into :tLogged FROM IIBAENSEMBLE_Zen_OnCallMonitor.ErrorLogging WHERE InputDateTime BETWEEN :datetimebegin AND :datetimeend AND SessionId IS NOT NULL)
        	set tCount = tCount - tLogged
        }
        
        
        s x = tCount + x 
        
        }
    
    
    s pCount = x     
    
    
    zn qCurrentNamespace
           
	Quit $$$OK
}

Method SendMessage(pId As %String, pNameSpace As %String, pLogReason As %String, pMessageId As %String) As %Status [ ZenMethod ]
{
	s tCurrNS = $ZNSPACE
	s tSC = $$$OK
	zn pNameSpace
	//do ##class(Ens.MessageHeader).ResendDuplicatedMessage(pId)
	s tSC = ..LogError(pMessageId,pNameSpace,pLogReason,pId)
	s tSC = ##class(Ens.MessageHeader).ResubmitMessage(pId)	
	zn tCurrNS
	//&js<alert('Not sure how this works :) '+'#(pId)#');>
	Quit tSC
}

ClassMethod LogError(pId As %String, pNameSpace As %String, pLogReason As %String, pSessionId As %String) As %Status [ ZenMethod ]
{
	s tCurrNS = $ZNSPACE
	s tSC = $$$OK
	zn pNameSpace
	s tLogError = ##class(IIBAENSEMBLE.Zen.OnCallMonitor.ErrorLogging).%New()
	s tLogError.InputDateTime = $ZDATETIME($HOROLOG,3,1)
	s tLogError.LogReason = pLogReason
	s tLogError.SessionId = pSessionId
	s tLogError.NameSpace = pNameSpace
	s tLogError.MessageId = pId
	s tSC = tLogError.%Save()
	zn tCurrNS
	Quit tSC
}

}
