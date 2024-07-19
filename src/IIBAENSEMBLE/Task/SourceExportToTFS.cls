/// <b>Copyright 2015 by Nuvodia</b><br/>
/// <i>Modified by Paul Hegel and Jeremy Weeks</i><br/>
/// <i>on  1/8/2015</i>
/// This Class exports changed classes to Microsoft Visual Source Safe.
/// In order for this class to be used TFS Client must be installed
/// correctly configured on the Ensemble Server <br/>
/// Note: The global ^TFSSourceControldttm stores the last compile dttm which is
/// approximately the last date time the code would have been
/// committed<br/>
Class IIBAENSEMBLE.Task.SourceExportToTFS Extends %SYS.Task.Definition
{

Parameter TaskName = "SourceExportToTFS";

/// The CSP Application Folder name for the namespace (navigate to the namespace/prodcution)><br/>
/// example link: http://localhost:57773/csp/dev/EnsPortal.ProductionConfig.zen?$NAMESPACE=DEV&$NAMESPACE=DEV><br/>
/// use this portion of the link:><br/>
/// example: /csp/dev/><br/>
Property CSPApplicationName As %String;

/// This is the physical path of the CSP Application to find this go to CSP folder of the instance:<br/>
/// 1. To find the instance folder, in management portal click on About.  It's the same folder as the configuration file<br/>
/// 2. From there drill to the CSP folder and the namespace folder.<br/>
/// 	Pattern: [instance folder]\csp\[namespace]<br/>
/// 	Example: h:\ensemblesys\csp\iibasupport<br/>
Property CSPApplicationPath As %String;

/// Source Control (SC) Path within the source control application<br/>
/// example: $/iibaensemble/test<br/>
Property SCPath As %String;

/// Domain/Application Username that has full read/write access to the Source Control project<br/>
/// example: TFSService<br/>
/// domain example: DUVOISIN\TFSService<br/>
Property SCUser As %String;

/// Password of above SCUser<br/>
/// example: P@ssw0rd<br/>
/// TODO:  Future - move to use Ensemble Credential system.<br/>
Property SCPWord As %String;

/*
/// Use Ensemble Credentials
/// This is the ID name of the set of credentials values to be used to access the external system
Property Credentials As %String;

Property %CredentialsObj As Ens.Config.Credentials;
*/
/// This is the mapped directory from the Source Control or that will be mapped into a workspace for the SCUser <br/>
/// Use the location that you want mapped in source control's Workspace for this user
/// file system in this location will map to the SCPath above><br/>
/// Example:  d:\tfs\interface\test<br/>
Property ExportFilePath As %String;

/// TFS Collection Path (specific to team foundation server)<br/>
/// pattern: http://[tfs server]:8080/tfs/[collettion name]<br/>
/// example: http://devsql2012:8080/tfs/JerTest<br/>
Property TFSCollectionPath As %String;

Method OnTask() As %Status
{
  
 kill tFullList 
 //Initialize Source Control
 set tSC = ..InitializeSourceControl()
 Q:'tSC tSC
 
 //Load Class List 
 do $System.OBJ.GetClassList(.tList,"/mapped=0/system=0/percent=0")
  set class="" for  {
    set class=$o(tList(class)) quit:class=""
    if $P(class,".",1) '= "csp" {
    	set tFullList(class_".cls")=""
    }
  }
  //Load Rules
 set p="" for  {
    set p=$o(^Ens.Rule.RuleDefinitionD(p)) q:p=""
    set r="" for  {
      set r=$o(^Ens.Rule.RuleDefinitionD(p,r)) q:r=""
      set tFullList(p_"."_r_".rul")=""
    }
  }
   //Load HL7 Schemas 
 set cat="" for  {
 set cat=$o(^EnsHL7.Schema(cat)) quit:cat=""
  	set tFullList(cat_".hl7")=""
 }
   //CSP Application path Files - Load
 if ..CSPApplicationName '= "" { 
	 Set Path=..CSPApplicationPath, Mask="*.*"	
	 Set rset = ##class(%ResultSet).%New()
	 set rset.ClassName = "%File"
	 set rset.QueryName = "FileSet"
	 Do rset.Execute(Path,Mask)
	
	 While (rset.Next()) {
		// only files - skip directories
		if ($ZB(##class(%File).Attributes(rset.Data("Name")),16,1)=0) {
			set filename = ##class(%File).GetFilename(rset.Data("Name"))
			if $P(filename,".",2) = "csp" {
				set tFullList(..CSPApplicationName_filename)=""
	 		}
	 	}
	 }
	
	 Do rset.Close()
 }
 
 set name="", tSourceControldttm=""
  //Iterate over tFullList multivalue array starting with first since name =" "
 for {set name = $O(tFullList(name)) quit:name=""
 
  //Get the last time it was checked into source control from Global ^TFSSourceControldttm multivalue array.
  
 		set tSourceControldttm = $GET(^TFSSourceControldttm(name))
 		if tSourceControldttm'=##class(%RoutineMgr).TS(name) {
			
			//set tSC = ..ExportFile(name)
			
			set tSCBefore = ..OnBeforeCompile(name)
			set tSC = ..OnAfterCompile(name)
			//once code is committed to source control successfully set the new dttm on the global.
 			if (tSC && tSCBefore)
 			{
				set ^TFSSourceControldttm(name)=##class(%RoutineMgr).TS(name) 
				kill ^TFSSourceControldttm(name,"Error")
 			}	
 			else
 			{
	 			set ^TFSSourceControldttm(name,"Error")=tSCBefore_tSC	
 			}		
 		}
 }
	
 Quit $$$OK
}

/// Initializes the source control by setting the current directory, deleting log files for re-use, 
/// checking the workspace, creating workspace, if not exists and setting the working folder.
Method InitializeSourceControl() As %Status
{
	set tSC = $$$OK
	
	if ('##class(%File).DirectoryExists(..ExportFilePath))
	{
		set tSC = $$$ERROR("Directory: " _..ExportFilePath _" doesn't exist. Please verify the ExportFilePath settings are correct and the directory exsits on the server.")
		QUIT tSC
	}
	set cd = $system.Process.CurrentDirectory(..ExportFilePath)
	
	set tSC = ..DeleteLogFiles()
	//w "Log files deleted result: ", tSC,!
	
	set tSC = ..CheckWorkspace()
	//w "Check Workspace result: ", result,!

	if ('tSC){
		set tSC = ..SetWorkspace()
		//w "Set Workspace result: ", result,!
	}
	//q:'tSC tSC
	
	set tSC = ..SetWorkfolder()
	q tSC
}

/// Before loading any item we check to see if it exists in TFS and check it out if it does.
Method OnBeforeCompile(InternalName As %String) As %Status
{
	
	//set ^CacheTempMattsTrace2(1) = $ZDT($H)_": OnBeforeCompile for file: "_InternalName
	
	//set filename = ..ExternalName(InternalName)
	
	//set ^CacheTempMattsTrace2(1) = $ZDT($H)_": OnBeforeCompile for file: "_InternalName_" "_tSC
	
	// Try to checkout... 
	set checkoutStatus = ..SCCheckOut(InternalName)
	
	//Always export file so it can be added.
	//set ^CacheTempMattsTrace2(3) = tSC
	set tSC = ..ExportFile(InternalName)

	//if it fails then add
	if ('checkoutStatus)
	{	
		// file status was not successful, then it doesn't exist so we nee to add it.
		set tSC = ..SCAdd(InternalName)
	}
	Q tSC
}

/// After compiling an item we write this to an xml file so that we can check the changes into TFS.
Method OnAfterCompile(InternalName As %String) As %Status
{
	//set ^CacheTempMattsTrace2(2) = $ZDT($H)_": OnAfterCompile for file: "_InternalName
		
	//write it to file and check it in with the current user
	//set tSC = ..ExportFile(InternalName)
	//Q:tSC tSC
	
	set tSC = ..SCCheckIn(InternalName)
	if ('tSC)
	{
		set tSC = ..SCResolve(InternalName)	
		Q:'tSC // quit if it doesn't resolve
		
		set tSC = ..SCCheckIn(InternalName)	
	}
	Quit tSC
}

Method ExportFile(InternalName As %String) As %Status
{
	set filename = ..ExternalName(InternalName)
	 
	Set tSC = $system.OBJ.Export(InternalName,filename,"-d")
	set ^CacheTempMattsTrace2(10) = "exporting file: "_InternalName_tSC	
 	// 	w $system.Status.DisplayError(tSC)
 	
 	//Quit:$$$ISERR(tSC)
 	if $$$ISERR(tSC) Quit $$$ERROR($$$GeneralError,"Error occured in exporting file" _tSC)
 	
 	Quit tSC
}

Method SCName(InternalName As %String) As %String
{
	Set name=$TR($piece(InternalName,".",1,$length(InternalName,".")-1),"/",".")
	Set ext=$zconvert($piece(InternalName,".",$length(InternalName,".")),"l")
	
	Set SCName=..SCPath_"/"_ext_"."_name_".xml"
	
	Quit SCName
}

Method SCCheckOut(InternalName As %String) As %Status
{
	set filename = ..ExternalName(InternalName)
	set logpath = ..ExportFilePath _ "\log\"
	set cmd = "tf checkout "_filename_" /login:"_..SCUser_","_..SCPWord _" /lock:none  1>>"_logpath_"commandlog.txt 2>&1"
	set result = $ZF(-1,cmd)
	quit ..GetStatus(result, "SCCheckOut")
}

Method SCCheckIn(InternalName As %String) As %Status
{
	set filename = ..ExternalName(InternalName)
	set logpath = ..ExportFilePath _ "\log\"
	set cmd = "tf checkin "_filename_" /login:"_..SCUser_","_..SCPWord _" /noprompt  1>>"_logpath_"commandlog.txt 2>&1"
	set result = $ZF(-1,cmd)
	quit ..GetStatus(result, "SCCheckIn")
}

Method SCAdd(InternalName As %String) As %Status
{
	set filename = ..ExternalName(InternalName)
	set logpath = ..ExportFilePath _ "\log\"
	set cmd = "tf add "_filename_" /login:"_..SCUser_","_..SCPWord _" /noprompt  1>>"_logpath_"commandlog.txt 2>&1"
	set result = $ZF(-1,cmd)
	
	quit ..GetStatus(result, "SCAdd")
}

Method SCResolve(InternalName As %String) As %Status
{
	set filename = ..ExternalName(InternalName)
	set logpath = ..ExportFilePath _ "\log\"
	set cmd = "tf resolve "_filename_" /login:"_..SCUser_","_..SCPWord _" /auto:KeepYours /noprompt  1>>"_logpath_"commandlog.txt 2>&1"	set result = $ZF(-1,cmd)
	quit ..GetStatus(result, "SCCheckIn")
}

Method ExternalName(InternalName As %String) As %String
{
	Set name=$TR($piece(InternalName,".",1,$length(InternalName,".")-1),"/",".")
	Set ext=$zconvert($piece(InternalName,".",$length(InternalName,".")),"l")
	
	set filename = ..ExportFilePath_"\"_ext_"."_name_".xml"
		
	Quit filename
}

Method SCStatus(InternalName As %String) As %Status
{
	set SCName = ..SCName(InternalName)
	set logpath = ..ExportFilePath _ "\log\"
	set cmd = "tf status  "_SCName_" /login:"_..SCUser_","_..SCPWord _" /noprompt 1>>"_logpath_"commandlog.txt 2>&1"
	set result = $ZF(-1,cmd)
	quit ..GetStatus(result, "SCStatus")
}

Method SCGet(InternalName As %String) As %Status
{
	set SCName = ..SCName(InternalName)
	set logpath = ..ExportFilePath _ "\log\"
	set cmd = "tf get  "_SCName_" /login:"_..SCUser_","_..SCPWord _" /overwrite /noprompt 1>>"_logpath_"commandlog.txt 2>&1"
	set result = $ZF(-1,cmd)
	quit ..GetStatus(result, "SCGet")
}

Method CheckWorkspace() As %Status
{
	set computerName = $zu(110)
	set workspace = ..GetSCWorkspace()
	set logpath = ..ExportFilePath _ "\log\"
	set cmd = "tf workspaces /owner:"_ ..SCUser_ " /computer:" _computerName_ " /collection:"_ ..TFSCollectionPath _ " /login:"_..SCUser_","_..SCPWord _" " _workspace_" 1>>"_logpath_"workspacelog.txt 2>&1"
	set result = $ZF(-1,cmd)
	quit ..GetStatus(result, "CheckWorkspace")
}

Method SetWorkspace() As %Status
{
	set SCWorkspace = ..GetSCWorkspace()
	set logpath = ..ExportFilePath _ "\log\"
	set cmd = "tf workspace /collection:"_ ..TFSCollectionPath _" /new /noprompt /login:"_..SCUser_","_..SCPWord _" /permission:Public 1>>"_logpath_"workspacelog.txt 2>&1"
	set result = $ZF(-1,cmd)
	quit ..GetStatus(result, "SetWorkspace")
}

Method SetWorkfolder() As %Status
{
	set logpath = ..ExportFilePath _ "\log\"
	set SCWorkspace = ..GetSCWorkspace()
	set cmd = "dir >>"_logpath_"dir.txt"
	set result = $ZF(-1, cmd)		
	set cmd = "tf workfold /map "_ ..SCPath _" " _ ..ExportFilePath _" /login:"_..SCUser_","_..SCPWord _ " /workspace:"_ SCWorkspace _" 1>>"_logpath_"workfoldlog.txt 2>&1"
	set result = $ZF(-1, cmd)
	quit ..GetStatus(result, "SetWorkfolder")
}

Method GetSCWorkspace() As %String
{
	#DIM computerName as %String
	#DIM user as %String
	if ($LENGTH(..SCUser, "\")>1)
	{
		set user = $PIECE(..SCUser,"\",2)
	}else{
		set user = ..SCUser	
	}
	set computerName = $zu(110)
	return computerName_";"_user
}

Method DeleteLogFiles() As %Status
{
	set logfiles = ..ExportFilePath _ "\log\*.*"
	set tSC = ##class(%File).Delete(logfiles)
	return tSC
}

/// 	SCResult ****** Definition<br/>
/// 	=============== =============================================================================================<br/>
/// 	0 ------------- Success.<br/>
/// 	1 ------------- Partial success; this means at least something, or possibly everything, failed to succeed.<br/>
/// 	2 ------------- Unrecognized command.<br/>
/// 	100 ----------- Nothing succeeded.<br/>
Method GetStatus(SCresult As %String, MethodCalled As %String = "") As %Status
{
	quit $CASE(SCresult,
              0:$$$OK,
              1:$$$ERROR($$$GeneralError,"Partial success; this means at least something, or possibly everything, failed to succeed.", MethodCalled ),
              2:$$$ERROR($$$GeneralError,"Unrecognized command.", MethodCalled),
              100:$$$ERROR($$$GeneralError,"Nothing succeeded.", MethodCalled))
}

}
