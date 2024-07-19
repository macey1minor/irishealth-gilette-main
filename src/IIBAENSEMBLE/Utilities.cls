/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Utilities Extends %RegisteredObject
{

ClassMethod InvokeService(servicename As %String, value As %RegisteredObject = "")
{
	set Status = ##class(Ens.Director).CreateBusinessService(servicename,.service)
	if Status {
		do service.ProcessInput(value)
	}
}

ClassMethod InvokeSCBatch()
{
	set oref = ##class(IIBAENSEMBLE.SourceControlBatch).%New()
	set tSC = oref.SCBatch()
}

ClassMethod CycleInterface(InterfaceList As %String, InactivityThreshold As %Integer = 0) As %String [ Final ]
{
	
	
		
	// first find which interfaces are currently enabled.
	Set ProductionName=""
	Set ProductionStatus=""
	set status = ##class(Ens.Director).GetProductionStatus(.ProductionName,.ProductionStatus)
	
	set production=##class(Ens.Config.Production).%OpenId(ProductionName)
	
	
	for i=1:1:production.Items.Count() {
		
		s item=production.Items.GetAt(i)
		//W item.Name,!
		if ( $FIND(InterfaceList,item.Name) && (item.Enabled+0=1) ) {
			s InterfaceEnabled(item.Name)=item.Enabled+0
		}
	}
	

	// Second, for the enabled interfaces, get the last action information
	set rs=##class(%ResultSet).%New("Ens.Util.Statistics:EnumerateHostStatus")
 	Set r=rs.Execute()
 
	while rs.Next() {
		Set ifName=rs.Get("Name")
		If ($G(InterfaceEnabled(ifName))) {
			//Do ##class(Ens.Util.Log).LogInfo("IIBAENSEMBLE.Utilities","CycleInterface","Disable failed: "_ifName)
			s InterfaceEnabled(ifName)=rs.Get("LastActivity")
		}
	}

	
	s InterfaceName=""
	For {
		s InterfaceName=$O(InterfaceEnabled(InterfaceName))
		Q:InterfaceName=""
		
		s ifLastAction=InterfaceEnabled(InterfaceName)
	
		

		// Cycle the interface if the inactivity time has exceeded the threshold	
		Set CurrentTime=$ZDT($H,3)
		Set TimeDiff=""
		&sql(Select distinct {fn TimestampDiff(SQL_TSI_SECOND,:ifLastAction,:CurrentTime) } into :TimeDiff From IIBAENSEMBLE_Monitor.ItemStatus )
	
		If ( TimeDiff > (InactivityThreshold*60) ) {
			
			//Disable the Interface
			Try {
				set status = ##class(Ens.Director).EnableConfigItem(InterfaceName,0)
			} Catch errobj {
				Do ##class(Ens.Util.Log).LogError("IIBAENSEMBLE.Utilities","CycleInterface","Disable failed: "_errobj.Name)
			}
	

			// sleep for a few seconds to let things settle
			H 10
	
			// Enable the interface
			Try {
				set status = ##class(Ens.Director).EnableConfigItem(InterfaceName,1)
			} Catch errobj {
				Do ##class(Ens.Util.Log).LogError("IIBAENSEMBLE.Utilities","CycleInterface","Enable failed: "_errobj.Name)
			}
		
	
		}
	}
	
	Quit $$$OK
}

ClassMethod ClearQueue(QueueName As %String, startIndex As %Integer = "", endIndex As %Integer = "") As %Status
{
		
 
 Set rset = ##class(%ResultSet).%New("Ens.Queue:EnumerateItem")
 set tSC = rset.Execute(QueueName)

 set rownum=0
 While (rset.Next()) {
    
    if ((startIndex="")||(rset.Data("Index")>=startIndex))
    	&&((endIndex="")||(rset.Data("Index")<=endIndex)) {
    	set tSC = ##class(Ens.Queue).AbortItem(QueueName,rset.GetDataByName("Priority"),rset.GetDataByName("Index"))        
    	//if tSC '= 1 Quit
    	set rownum = rownum+1
    	//if rownum > 5 Quit
    }
 }
 Do rset.Close()
 
 w rownum,!
 
 Quit tSC
}

ClassMethod PurgeArchivedFiles(Path As %String, Mask As %String = "*.*", Keep As %Integer = 30)
{
	// Clean out Archive files older than 30 days
	Set rset = ##class(%ResultSet).%New()
	set rset.ClassName = "%File"
	set rset.QueryName = "FileSet"
	Do rset.Execute(Path,Mask)
	Set FileDelete = 1
	While (rset.Next()) {
		// only delete files - skip directories
		if ($ZB(##class(%File).Attributes(rset.Data("Name")),16,1)=0) {
			If $PIECE($HOROLOG,",") - $PIECE($ZDATETIMEH(rset.Data("DateCreated"),3,1),",") > Keep {
				Set FileDelete = ##class(%File).Delete(rset.Data("Name"))
				If FileDelete = 0 {
					do ##class(Ens.Util.Log).LogError("IIBAENSEMBLE.Utilities", "PurgeArchivedFiles", "File delete Failed: "_rset.Data("Name"))
				}
			}
		}
	}
	
	Do rset.Close()
}

ClassMethod ToggleItemStatus(ItemName As %String, NumberofAttempts As %Integer, WaitBtwnAttempts As %Integer, Enable As %Boolean)
{
	set i=0
	for {
		set tSC = ##class(Ens.Director).EnableConfigItem(ItemName,Enable)
		Quit:tSC=1
		set i = i +1
		Quit:i=NumberofAttempts
		hang WaitBtwnAttempts
	}
	
	set tSC = ##class(Ens.Director).UpdateProduction()
}

ClassMethod WriteJobsQueues()
{
		Set rs = ##class(%ResultSet).%New()
	set rs.ClassName = "Ens.Job"
	set rs.QueryName = "Enumerate"
	Do rs.Execute()
	
	set filename = ##class(%File).ManagerDirectory()_"Jobs"_##class(Ens.Util.Time).FormatDateTime("%Y%m%d%H%M%S")_".csv"
	set file = ##class(%File).%New(filename)
	Do file.Open("WSN")
	Do file.WriteLine("Job,ConfigName,Mode,Status,Detail,ActiveMessage,State")
	While rs.Next() {
		Do file.WriteLine(rs.Data("Job")_","_rs.Data("ConfigName")_","_rs.Data("Mode")_","_rs.Data("Status")_","_rs.Data("Detail")_","_rs.Data("ActiveMessage")_","_rs.Data("State"))
		
	}
	
	w "Jobs list written to: "_file.Name,!

		
	Do file.Close()
	
	
	
	Set rs = ##class(%ResultSet).%New()
	set rs.ClassName = "Ens.Queue"
	set rs.QueryName = "Enumerate"
	Do rs.Execute()
	
	set filename = ##class(%File).ManagerDirectory()_"Queues"_##class(Ens.Util.Time).FormatDateTime("%Y%m%d%H%M%S")_".csv"
	set file = ##class(%File).%New(filename)
	Do file.Open("WSN")
	Do file.WriteLine("Name,Count,Created")
	While rs.Next() {
		Do file.WriteLine(rs.Data("Name")_","_rs.Data("Count")_","_rs.Data("Created"))
		
	}
	
	w "Queues list written to: "_file.Name,!
	
	Do file.Close()
}

ClassMethod GetItemSettingObject(ItemName As %String, SettingName As %String, ByRef SettingObject As Ens.Config.Setting)
{
	set ItemID=""
	
	&sql(select ID into :ItemID from Ens_Config.Item where Name = :ItemName)
	
	set item = ##class(Ens.Config.Item).%OpenId(ItemID)
	
	for i=1:1:item.Settings.Count() {
		if item.Settings.GetAt(i).Name = SettingName set SettingObject = item.Settings.GetAt(i)	
	}
}

/// This Method queries HL7 message body IDs for Services and Operations from the Ens.MessageHeader table within the date range that is specified.
/// The Date range is by default T-1.  If sDate1 is supplied and sDate2 is not, the date ranges is sDate1.
/// If both sDate1 and sDate2 are supplied, the date range spans the two dates.
/// The archive path defaults to d:\archive\, but it can be overridden as the 3rd parameter if needed.
/// Once the message body IDs are acquired, the RawContect of each message is written to a file that is named CCYY-MM-DD.[ItemName].hl7.txt
ClassMethod ArchiveHL7(sDate1 As %String = "", sDate2 As %String = "", ArchivePath As %String = "D:\Archive\", sSource As %String = "", sTarget As %String = "") As %Status
{
	set InfoMsg = "Start Archive at: "_$ZDT($H)_" | "
	
	If ( $E(ArchivePath,$L(ArchivePath),$L(ArchivePath)) '= "\" ) {
		S ArchivePath=ArchivePath_"\"
	}
	
	//w ArchivePath,!
	
	If (sDate1="")&&(sDate2=""){
		set sDate1 = $ZD($H-1,3)
		set sDate2 = $ZD($H-1,3)
	} elseif (sDate1'="")&&(sDate2=""){
		set sDate2=sDate1
	}
	
	set InfoMsg = InfoMsg_"sDate1: "_sDate1_" | sDate2: "_sDate2_" | AchivePath: "_ArchivePath_" | "
	
	If (sDate1?4N1"-"2N1"-"2N)&&(sDate2?4N1"-"2N1"-"2N) {	
	
		set StartStamp = sDate1_" 00:00:00"
		set EndStamp = sDate2_" 23:59:59"
		//set EndStamp = sDate2_" 01:00:00"
	
		set SQL = ""
		Set rset = ##class(%ResultSet).%New()
		set rset.RuntimeMode = "1"
		
		set SQL = SQL_"SELECT MessageBodyId, MessageBodyClassName, SourceBusinessType, SourceConfigName, TargetBusinessType, TargetConfigName, TimeCreated "
		set SQL = SQL_"FROM Ens.MessageHeader "
		set SQL = SQL_"WHERE TimeCreated >= '"_StartStamp_"' "
		set SQL = SQL_"AND TimeCreated <= '"_EndStamp_"' "
		set SQL = SQL_"AND (SourceBusinessType = 1 OR TargetBusinessType = 3) "
		
		if sSource '= "" {
			set SQL = SQL_"AND SourceConfigName = '"_sSource_"' "
		}
		if sTarget '= "" {
			set SQL = SQL_"AND TargetConfigName = '"_sTarget_"' "
		}
		
		Do rset.Prepare(SQL)
		Do rset.Execute()
	
		Kill ^CacheTempMsgArchive($ZNSPACE)
		set ^CacheTempMsgArchive($ZNSPACE) = ""
	
		While (rset.Next()) {
		
		  If rset.Data("MessageBodyClassName") = "EnsLib.HL7.Message" {
	
			If rset.Data("SourceBusinessType")=1 {
				set ^CacheTempMsgArchive($ZNSPACE,rset.Data("SourceConfigName"),$P(rset.Data("TimeCreated")," ",1),rset.Data("MessageBodyId")) = ""
			} ElseIf rset.Data("TargetBusinessType")=3 {
				set ^CacheTempMsgArchive($ZNSPACE,rset.Data("TargetConfigName"),$P(rset.Data("TimeCreated")," ",1),rset.Data("MessageBodyId")) = ""
			}
			
		  }
		  
		}

	//w "end while",!

		Set ItemName=""
		For {
			Set ItemName=$O(^CacheTempMsgArchive($ZNSPACE,ItemName)) 
			Q:ItemName=""
	//w ItemName,!
			Set TimeCreated=""
			For {
				Set TimeCreated=$O(^CacheTempMsgArchive($ZNSPACE,ItemName,TimeCreated)) 
				Q:TimeCreated=""
			
				Set file=##class(%File).%New(ArchivePath_TimeCreated_"."_$ZNSPACE_"."_ItemName_".hl7.txt")
				If $ISOBJECT(file) = 1 {
				Do file.Open("WSN")
			
			//w file.Name,!
			
				Set MsgID=""
				For {
					Set MsgID=$O(^CacheTempMsgArchive($ZNSPACE,ItemName,TimeCreated,MsgID)) 
					Q:MsgID=""
			
					set hl7 = ##class(EnsLib.HL7.Message).%OpenId(MsgID)
				    If $ISOBJECT(hl7) = 1 {
						Do file.WriteLine(hl7.RawContent)
						//Do hl7.OutputToLibraryStream(file)
				    } else {
					    do ##class(Ens.Util.Log).LogWarning("IIBAENSEMBLE.Utilities", "ArchiveHL7", "Could not create hl7 object: "_MsgID) 
				    }
				}
			
				//Close file
				do file.Close()
				} else {
					do ##class(Ens.Util.Log).LogWarning("IIBAENSEMBLE.Utilities", "ArchiveHL7", "Could not create file: "_ArchivePath_TimeCreated_"."_ItemName_".hl7.txt") 
				}
			}		
		}
	} Else {
		set ErrorMsg = "Arhive HL7 Date 1: "_sDate1_" or 2: "_sDate2_" is not correctly formatted as ODBC date YYYY-MM-DD"
		do ##class(Ens.Util.Log).LogError("IIBAENSEMBLE.Utilities", "ArchiveHL7", ErrorMsg) 
	}
	
	set InfoMsg = InfoMsg_"End Archive at: "_$ZDT($H)
	
	do ##class(Ens.Util.Log).LogInfo("IIBAENSEMBLE.Utilities", "ArchiveHL7", InfoMsg) 

	Quit $$$OK
}

ClassMethod DisableAllBusinessServices()
{
	
	// *****  Get the name of the production    *******
	Set ProductionName=""
	Set ProductionStatus=""
	set status = ##class(Ens.Director).GetProductionStatus(.ProductionName,.ProductionStatus)
	
	// Get a list of the Enabled Business Services	
	set production=##class(Ens.Config.Production).%OpenId(ProductionName)
	
	for i=1:1:production.Items.Count() {
  
  		
  		s item=production.Items.GetAt(i)
  		s name=item.Name
  		If (item.BusinessType() = "1") {
  			  		
			if (item.Enabled+0 = 1 ) {
	  			W !,"....Disabling ",item.Name
	  			set status = ##class(Ens.Director).EnableConfigItem(name,0)
  			}

  			
  		}
	}
	
	// Update Production
	set upstatus = ##class(Ens.Director).UpdateProduction()
}

ClassMethod cspfileAppNameChange(filename As %String, newAppName As %String, oldAppName As %String = "/csp/YOURNAMESPACE/") As %Status
{
	
	
	set fileOriginal = ##class(%File).%New(filename)
	
	set tSC =  fileOriginal.Open("RS")
	Quit:$$$ISERR(tSC) tSC
	set dir = ##class(%File).GetDirectory(filename)
	set newfilename = "temp_"_##class(%File).GetFilename(filename)
	set fileNew = ##class(%File).%New(dir_newfilename)
	set tSC =  fileNew.Open("WSN")
	Quit:$$$ISERR(tSC) tSC
	While 'fileOriginal.AtEnd {
		set tSC = fileNew.WriteLine(##class(IIBAENSEMBLE.Functions).StringReplace(fileOriginal.ReadLine(),oldAppName,newAppName))
		Quit:$$$ISERR(tSC) 
	}
	Quit:$$$ISERR(tSC) tSC
	do fileNew.Close()
	do fileOriginal.Close()
	
	
	Quit tSC
}

ClassMethod buildInstallerSourceFiles(outputPath As %String = "") As %Status
{
	if outputPath = "" {
		s outputPath = ##class(%File).ParentDirectoryName(##class(%File).ManagerDirectory())
	}
	s outputPath = ##class(%File).NormalizeDirectory(outputPath)
	
	s outputFileClasses = outputPath_"iibasupport_cls.xml"
	s outputFileCSP = outputPath_"iibasupport_csp.xml"
	s outputFileModalBox = outputPath_"iiba_modalBox_csp.xml"
	s outputFileModalBoxTemp = outputPath_"temp_iiba_modalBox_csp.xml"
	s outputFileCustomImages = outputPath_"iiba_CustomImages_csp.xml"
	s outputFileCustomImagesTemp = outputPath_"temp_iiba_CustomImages_csp.xml"
	s outputFileExt = outputPath_"iiba_ext_csp.xml"
	s outputFileImg = outputPath_"iiba_img_csp.xml"
	s outputFileExtTemp = outputPath_"temp_iiba_ext_csp.xml"
	s outputFileImgTemp = outputPath_"temp_iiba_img_csp.xml"
	s outputFileCspItems = outputPath_"iiba_csp_items.xml"
	s outputFileCspItemsTemp = outputPath_"temp_iiba_csp_items.xml"
	s outputFileGlobals = outputPath_"iibasupport_globals.gof"
	s outputFileInstaller = outputPath_"installer_cls.xml"
	
	//for exporting globals
	//need to purge from Task Item Definitions all but: TaskItems, SupportPages, MsgClassDefUpdate after the import
	set GlobalList = "IIBAENSEMBL4D4.SupportPageD883D.gbl,IIBAENSEMBL521.TaskItemDefi72BD.gbl,IIBAENSEMBLE.Monitor.tblItemsD.gbl"
  	
	
	//Exporting Classes
	s tSC = $system.OBJ.ExportPackage("IIBAENSEMBLE",outputFileClasses,"",.err,)
	Quit:$$$ISERR(tSC) tSC
	
	//Exporting Installer
	s tSC = $system.OBJ.Export("IIBAENSEMBLE.Installer.cls",outputFileInstaller,"",.err,)
	Quit:$$$ISERR(tSC) tSC
	
	//Exporting CSP and web files like images and .js files
	//s tSC = $system.OBJ.ExportPattern("/csp/"_$ZNSPACE_"/*",outputFileCSP,"",.err,)
	s tDefaultApp = $SYSTEM.CSP.GetDefaultApp($NAMESPACE)
	s tSC = $system.OBJ.ExportPattern(tDefaultApp_"/modalbox/*",outputFileModalBox,"",.err,)
	Quit:$$$ISERR(tSC) tSC
	
	
	s tSC = $system.OBJ.ExportPattern(tDefaultApp_"/CustomImages/*",outputFileCustomImages,"",.err,)
	Quit:$$$ISERR(tSC) tSC
	
	
	s tSC = $system.OBJ.ExportPattern(tDefaultApp_"/ext/*",outputFileExt,"",.err,)
	Quit:$$$ISERR(tSC) tSC
	
	s tSC = $system.OBJ.ExportPattern(tDefaultApp_"/img/*",outputFileImg,"",.err,)
	Quit:$$$ISERR(tSC) tSC
	
	k items
	//s items("/csp/iibatest/calendar.html")=""
	s items(tDefaultApp_"/calendar2.js")=""
	s items(tDefaultApp_"/calendar.html")=""
	s items(tDefaultApp_"/date.js")=""
	s items(tDefaultApp_"/effects.js")=""
	//s items(tDefaultApp_"/IIBARWFDashboard.csp")=""
	s items(tDefaultApp_"/IIBASupport.csp")=""
	s items(tDefaultApp_"/IIBASupportDetail.csp")=""
	//s items("/csp/iibatest/IIBAWFTasks.csp")=""
	s items(tDefaultApp_"/prototype.js")=""
	s items(tDefaultApp_"/scriptaculous.js")=""
	s items(tDefaultApp_"/xp_progress.js")=""
	s tSC = $system.OBJ.ExportPattern(.items,outputFileCspItems,"",.err,)
	Quit:$$$ISERR(tSC) tSC
	
	w "CSP app name change beginning",!
	
	//rename the app name to the default so that it can be named to the appropriate namespace on import
	s tSC = ##class(IIBAENSEMBLE.Utilities).cspfileAppNameChange(outputFileModalBox,"/csp/YOURNAMESPACE/",tDefaultApp_"/")
	Quit:$$$ISERR(tSC) tSC
	
	//Change the name of the original file and replace it with the new temp file that was created by the app name change method
	set tSC = ##class(%File).Delete(outputFileModalBox)
	Quit:$$$ISERR(tSC) tSC
	set tSC = ##class(%File).Rename(outputFileModalBoxTemp,outputFileModalBox)
	Quit:$$$ISERR(tSC) tSC

	
	//rename the app name to the default so that it can be named to the appropriate namespace on import
	s tSC = ##class(IIBAENSEMBLE.Utilities).cspfileAppNameChange(outputFileCustomImages,"/csp/YOURNAMESPACE/",tDefaultApp_"/")
	Quit:$$$ISERR(tSC) tSC
	
	//Change the name of the original file and replace it with the new temp file that was created by the app name change method
	set tSC = ##class(%File).Delete(outputFileCustomImages)
	Quit:$$$ISERR(tSC) tSC
	set tSC = ##class(%File).Rename(outputFileCustomImagesTemp,outputFileCustomImages)
	Quit:$$$ISERR(tSC) tSC
	
	//rename the app name to the default so that it can be named to the appropriate namespace on import
	s tSC = ##class(IIBAENSEMBLE.Utilities).cspfileAppNameChange(outputFileExt,"/csp/YOURNAMESPACE/",tDefaultApp_"/")
	Quit:$$$ISERR(tSC) tSC
	
	//Change the name of the original file and replace it with the new temp file that was created by the app name change method
	set tSC = ##class(%File).Delete(outputFileExt)
	Quit:$$$ISERR(tSC) tSC
	set tSC = ##class(%File).Rename(outputFileExtTemp,outputFileExt)
	Quit:$$$ISERR(tSC) tSC
	
	//rename the app name to the default so that it can be named to the appropriate namespace on import
	s tSC = ##class(IIBAENSEMBLE.Utilities).cspfileAppNameChange(outputFileImg,"/csp/YOURNAMESPACE/",tDefaultApp_"/")
	Quit:$$$ISERR(tSC) tSC
	
	//Change the name of the original file and replace it with the new temp file that was created by the app name change method
	set tSC = ##class(%File).Delete(outputFileImg)
	Quit:$$$ISERR(tSC) tSC
	set tSC = ##class(%File).Rename(outputFileImgTemp,outputFileImg)
	Quit:$$$ISERR(tSC) tSC
	
	//rename the app name to the default so that it can be named to the appropriate namespace on import
	s tSC = ##class(IIBAENSEMBLE.Utilities).cspfileAppNameChange(outputFileCspItems,"/csp/YOURNAMESPACE/",tDefaultApp_"/")
	Quit:$$$ISERR(tSC) tSC
	
	//Change the name of the original file and replace it with the new temp file that was created by the app name change method
	set tSC = ##class(%File).Delete(outputFileCspItems)
	Quit:$$$ISERR(tSC) tSC
	set tSC = ##class(%File).Rename(outputFileCspItemsTemp,outputFileCspItems)
	Quit:$$$ISERR(tSC) tSC
	
	w "csp app name change complete",!
		
	//Exporting Globals with data for the configuration of the toolkit
	s tSC = ##class(%Library.Global).Export("IIBA",.GlobalList,outputFileGlobals,7,"V")
	Quit:$$$ISERR(tSC) tSC
	
	Quit tSC
}

ClassMethod Base64EncodeFromFile(pFilename As %String, ByRef tSC As %Status, ommitCRLF As %Boolean = 0) As %Stream.TmpBinary
{
	#DIM len as %String =5700 // Read the file in chunks of 5700 Bytes
	#DIM file as %FileBinaryStream =##class(%FileBinaryStream).%New()
	#DIM stream as %Stream.TmpBinary =##class(%Stream.TmpBinary).%New()
	
	quit:$G(pFilename)="" ""
	
	set file.Filename=pFilename
	set tSC=file.Rewind()
	if $$$ISERR(tSC) Quit ""

	while 'file.AtEnd {
		set:'ommitCRLF tSC=stream.Write($system.Encryption.Base64Encode(file.Read(.len)))
		set:ommitCRLF tSC=stream.Write($TR($system.Encryption.Base64Encode(file.Read(.len)),$C(13,10)))
		if $$$ISERR(tSC)
	}
	if $$$ISERR(tSC) Quit ""
	
	set tSC=stream.Rewind()
	if $$$ISERR(tSC) Quit ""
	
	
	Quit stream
}

/// Converts a stream containing Base64 encoded data into a file
ClassMethod Base64DecodeToFile(pStream As %Stream.TmpBinary, pFilename As %String) As %Status
{
	#DIM file as %FileBinaryStream =##class(%FileBinaryStream).%New()
	#DIM len as %String =5700 // Read the file in chunks of 5700 Bytes
	#DIM tSC as %Status
	
	quit:$G(pFilename)="" ""
	quit:'$ISOBJECT(pStream) ""
	
	set file.Filename=pFilename
	set tSC=file.Rewind()
	if $$$ISERR(tSC) Quit tSC
	d pStream.Rewind()

	While 'pStream.AtEnd {
		set tSC = file.Write($system.Encryption.Base64Decode(pStream.ReadLine())) 
		if $$$ISERR(tSC) Quit
	}
	if $$$ISERR(tSC) Quit tSC
	
	s tSC = file.%Save()
	if $$$ISERR(tSC) Quit tSC
	
	
	s file = ""
	
	Quit tSC
}

/// Converts a stream containing Base64 encoded data into a stream
ClassMethod Base64DecodeToStream(pStream As %Stream.TmpBinary, ByRef oStream As %GlobalBinaryStream) As %Status
{
	set oStream =##class(%GlobalBinaryStream).%New()
	#DIM tSC as %Status = $$$OK
	
	quit:'$ISOBJECT(pStream) ""
	
	While 'pStream.AtEnd {
		set tSC = oStream.Write($system.Encryption.Base64Decode(pStream.ReadLine())) 
		if $$$ISERR(tSC) Quit
	}
	if $$$ISERR(tSC) Quit tSC
	
	Quit tSC
}

ClassMethod EnQueueMsg(pRequest As %RegisteredObject, pSourceConfigName As %String, pTargetConfigName As %String, pSessionId As %String = "") As %Status
{
	Set tSC = ##class(Ens.MessageHeader).NewRequestMessage(.pRequestHeader,pRequest,.pSessionId) Quit:('tSC)
	Set pRequestHeader.SourceConfigName = pSourceConfigName
	Set pRequestHeader.TargetConfigName = pTargetConfigName
	Set pRequestHeader.SourceBusinessType = ^Ens.Runtime("ConfigItem",^Ens.Runtime("DispatchName",pSourceConfigName),"BusinessType")
	Set pRequestHeader.TargetBusinessType = ^Ens.Runtime("ConfigItem",^Ens.Runtime("DispatchName",pTargetConfigName),"BusinessType")
	Set pRequestHeader.TargetQueueName = ^Ens.Runtime("ConfigItem",^Ens.Runtime("DispatchName",pTargetConfigName),"QueueName")
	Set tSC = ##class(Ens.Queue).EnQueue(pRequestHeader) Quit:('tSC)
	Quit tSC
}

/// This method is used to create compressed files and place them in an archive folder. pUseDateRange defaults to 0. If a specified date range is desired change to 1 and enter StartDate and EndDate. 
/// The default date range is for the previous day.
/// pStartDate = Zip2.32: Do not operate on files modified prior to the specified date (mmddyyyy or yyyy-mm-dd)
/// pEndDate = Zip2.32: Do not operate on files modified after or at the specified date (mmddyyyy or yyyy-mm-dd)
/// Date format = mmddyyyy or yyyy-mm-dd. 
/// pArchiveDir = file path of the archive directory.
/// pFileName = file name of compressed records. Default is ZippedFile, pStartDate will be appended to filename
/// pFileType = type of files to be processed Ex: *.txt, *.csv. Default is all files (*). 
/// pZiplist = file path of directory to be compressed. 
ClassMethod ZipArchived(pUseDateRange As %Boolean = 0, pStartDate As %String = "", pEndDate As %String = "", pArchiveDir As %String = "", pFileName As %String = "", pFileType As %String = "", pZipList As %String = "") As %Status
{
	//This method will compress archive files and save as a .zip file
	//For file paths with spaces you must enclose each path in quotation marks and enclose the entire command in quotes as well
	#dim tSC As %Status = $$$OK
	#dim tprogram As %String = ""
	#dim tcommand As %String = ""
	#dim tziplist As %String = ""
	
	//Zip2.32 will compress all files in tziplist after this date (mmddyyyy or yyyy-mm-dd)
	if pUseDateRange = 1 {
		if ((pStartDate = "")||($L(pStartDate)< 8)) {
			Set tSC = $$$ERROR($$$GeneralError,"Error in Start Date")
			Quit tSC
		}
	
		//Zip2.32 will compress all files in tziplist prior to and including this date (mmddyyyy or yyyy-mm-dd)
		if ((pEndDate = "")||($L(pEndDate)< 8)) {
			Set tSC = $$$ERROR($$$GeneralError,"Error in End Date")
			Quit tSC
		}
		
	}

	Else {
		s pStartDate = $ZD($H-1,3)
		s pEndDate = $ZD($H,3)
	}
	
	//Zip program: Zip2.32
	set tprogram = """J:\Archive\zip\zip.exe"""
	
	if pArchiveDir = "" {
		s pArchiveDir = ##class(%File).ParentDirectoryName(##class(%File).ManagerDirectory())
	}
	
	s pArchiveDir = ##class(%File).NormalizeDirectory(pArchiveDir)
	
	if pFileName = "" {
		s pFileName = "ZippedFile"
	}
	
	//Enter archive directory for compressed files to be saved in. Include desired filename
	set tarchivedir = """"_pArchiveDir_pFileName_"_"_$ZSTRIP(pStartDate,"*P")_".zip"""
	
	//Enter the file type desired in the compression
	if pFileType = "" { 
		s pFileType = "*"
	}
	
	//Enter the directory containing files to be compressed
	if pZipList = "" {
		Set tSC = $$$ERROR($$$GeneralError,"Error in ZipList")
		Quit tSC
	}
	Else {
		s pZipList = ##class(%File).NormalizeDirectory(pZipList)
		set tziplist = """"_pZipList_pFileType_""""
	}
	
	//-m = delete files from tziplist directory. -t = Do not operate on files modified prior to the specified date. -tt = Do not operate on files modified after or at the specified date. 
	//-j = strip path from archived files. -r = recurse include subdirectories. -i = include only specified files
	set tcommand = "cmd /C """_tprogram_" -m -t "_pStartDate_" -tt "_pEndDate_" -j "_tarchivedir_" "_tziplist_""""
	
	s tSC = $ZF(-1, tcommand)
	if (tSC=0) {
		Set tSC = $$$OK
		Quit tSC
	}
	Elseif (tSC=2) {	
		Set tSC = $$$ERROR($$$GeneralError,"Unexpected end of zip file")
		Quit tSC
	}
	Elseif (tSC=3) {	
		Set tSC = $$$ERROR($$$GeneralError,"A generic error in the zipfile format was detected. Processing may have completed successfully anyway")
		Quit tSC
	}
	Elseif (tSC=4) {	
		Set tSC = $$$ERROR($$$GeneralError,"Zip was unable to allocate memory for one or more buffers during program initialization.")
		Quit tSC
	}
	Elseif (tSC=5) {	
		Set tSC = $$$ERROR($$$GeneralError,"A severe error in the zipfile format was detected. Processing probably failed immediately.")
		Quit tSC
	}
	Elseif (tSC=10) {	
		Set tSC = $$$ERROR($$$GeneralError,"Zip encountered an error while using a temp file")
		Quit tSC
	}
	Elseif (tSC=11) {	
		Set tSC = $$$ERROR($$$GeneralError,"Read or seek error")
		Quit tSC
	}
	Elseif (tSC=12) {	
		do ##class(Ens.Util.Log).LogInfo("IIBAENSEMBLE.Utilities", "ZipArchived", "Zip has nothing to do")
		Set tSC = $$$OK
		Quit tSC
	}
	Elseif (tSC=13) {	
		Set tSC = $$$ERROR($$$GeneralError,"Missing or empty zip file")
		Quit tSC
	}
	Elseif (tSC=14) {	
		Set tSC = $$$ERROR($$$GeneralError,"Error writing to a file")
		Quit tSC
	}
	Elseif (tSC=15) {	
		Set tSC = $$$ERROR($$$GeneralError,"Zip was unable to create a file to write to")
		Quit tSC
	}
	Elseif (tSC=16) {	
		Set tSC = $$$ERROR($$$GeneralError,"Bad command line parameters")
		Quit tSC
	}
	Elseif (tSC=18) {	
		Set tSC = $$$ERROR($$$GeneralError,"Zip could not open a specified file to read")
		Quit tSC
	}
	
	Quit tSC
}

}
