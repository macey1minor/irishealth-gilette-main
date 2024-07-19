Include Ensemble

/// <b>Copyright 2015 by Nuvodia</b><br/>
/// <i>Modified by Paul Hegel and Jeremy Weeks</i><br/>
/// <i>on  1/8/2015</i><br/>
/// This Class exports changed classes to Microsoft Visual Source Safe.<br/>
/// In order for this class to be used TFS Client must be installed<br/>
/// correctly configured on the Ensemble Server<br/>
Class IIBAENSEMBLE.Task.SourceExportToSVN Extends %SYS.Task.Definition
{

Parameter TaskName = "SourceExportToSVN";

/// The CSP Application Folder name for the namespace (navigate to the namespace/prodcution)<br/>
/// example link: http://localhost:57773/csp/dev/EnsPortal.ProductionConfig.zen?$NAMESPACE=DEV&$NAMESPACE=DEV<br/>
/// use this portion of the link:<br/>
/// example: /csp/dev/<br/>
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
Property SCPWord As %String;

/*
/// Use Ensemble Credentials
/// This is the ID name of the set of credentials values to be used to access the external system
Property Credentials As %String;

Property %CredentialsObj As Ens.Config.Credentials;
*/
/// This is the mapped directory from the Source Control or that will be mapped into a workspace for the SCUser 
/// Use the location that you want mapped in source control's Workspace for this user
/// file system in this location will map to the SCPath above
/// Example:  d:\tfs\interface\test
Property ExportFilePath As %String;

Property SVNCommand As %String;

Method OnTask() As %Status
{
	#dim tFullList
	kill tFullList 
	s tFullList = "" // tFullList will store all the class files we may need to check-in to SVN
	#dim tSC AS %Status = $$$OK
	//Initialize Source Control
	set tSC = ..InitializeSourceControl()
 
	//Load Class List
	s tSC = ..LoadClassList(.tFullList)
 
	//Load Rules
	s tSC = ..LoadRulesList(.tFullList) 
 
	//Load HL7 Schemas 
	s tSC = ..LoadHL7Schema(.tFullList)
 
	//CSP Application path Files - Load
	s tSC = ..LoadCSPApplications(.tFullList)
 
 	s tSC = ..UpdateSourceControl(.tFullList)

	
 Quit tSC
}

Method UpdateSourceControl(ByRef pFullList) As %Status
{
	w "Enter UpdateSourceControl",!
	#dim tSC As %Status = $$$OK
	#dim name As %String = ""
	#dim tSourceControldttm As %String = ""
 	//Iterate over tFullList multivalue array starting with first since name =" "
 	for {
	 	set name = $O(pFullList(name)) quit:name=""
		//Get the last time it was checked into source control from Global ^SourceControlDttm multivalue array.
  		set tSourceControldttm = $GET(^SourceControldttm(name))
 		if tSourceControldttm'=##class(%RoutineMgr).TS(name) 
 		{
			//set tSC = ..ExportFile(name)
			set tSC = ..OnBeforeCompile(name)
			set tSC = ..OnAfterCompile(name)
			//once code is committed to source control set the new dttm on the global.
			set ^SourceControldttm(name)=##class(%RoutineMgr).TS(name) 			
 		}
 }
 Q tSC
}

Method LoadCSPApplications(ByRef pFullList) As %Status
{
	#dim tSC As %Status = $$$OK
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
					w "Add "_..CSPApplicationName_filename,!
				}
			}
		}
		Do rset.Close()
 	}
	Q tSC
}

Method LoadHL7Schema(ByRef pFullList) As %Status
{
	#dim tSC = $$$OK
	set cat=""
	for
	{
 		set cat=$o(^EnsHL7.Schema(cat)) quit:cat=""
  		set pFullList(cat_".hl7")=""
  		w "Add HL7 "_cat_".hl7",!
 	}
 
	Q tSC
}

Method LoadRulesList(ByRef pFullList) As %Status
{
	#dim tSC as %Status = $$$OK
	set p="" for  {
    set p=$o(^Ens.Rule.RuleDefinitionD(p)) q:p=""
    set r="" for  {
    	set r=$o(^Ens.Rule.RuleDefinitionD(p,r)) q:r=""
    	set pFullList(p_"."_r_".rul")=""
    	w "Add rule "_p_"."_r_".rul",!
    }
  }
  Q tSC
}

Method LoadClassList(ByRef pFullList) As %Status
{
	s tSC = $$$OK

 	do $System.OBJ.GetClassList(.tList,"/mapped=0/system=0/percent=0")
 	set class="" for  {
    set class=$o(tList(class)) quit:class=""
    if $P(class,".",1) '= "csp" {
    	set pFullList(class_".cls")=""
    	w "Add class "_class_".cls",!
    }
  }
  Q tSC
}

Method InitializeSourceControl() As %Status
{
	#dim tSC = $$$OK
	s ..SCUser = ##class(Ens.Config.Credentials).GetValue("Assembla","Username")
	s ..SCPWord = ##class(Ens.Config.Credentials).GetValue("Assembla","Password")
	// s ..ExportFilePath = "C:\Users\nmilleville\Documents\ensemble"
	s ..ExportFilePath = "H:\temp\jmp\SVN"
	s ..SVNCommand = "c:\""program files""\tortoisesvn\bin\svn"
	d ..SCCheckOut()
	s ..ExportFilePath = "H:\temp\jmp\SVN\TEST"

	q tSC
}

/// Before loading any item we check to see if it exists in SVN and check it out if it does.
Method OnBeforeCompile(InternalName As %String) As %Status
{
	// Try to checkout... 
	//#dim checkoutStatus = ..SCCheckOut(InternalName)
	
	//Always export file so it can be added.
	set tSC = ..ExportFile(InternalName)

	//if it fails then add
	if (1)
	{	
		// file status was not successful, then it doesn't exist so we nee to add it.
		set tSC = ..SCAdd(InternalName)
	}
	Q tSC
}

/// After compiling an item we write this to an xml file so that we can check the changes into TFS.
Method OnAfterCompile(InternalName As %String) As %Status
{
	set tSC = ..SCCheckIn(InternalName)
	
	Quit tSC
}

Method ExportFile(InternalName As %String) As %Status
{
	set filename = ..ExternalName(InternalName)
	 
	Set tSC = $system.OBJ.Export(InternalName,filename,"-d")
	w "exporting file: "_InternalName_tSC,!	
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

Method SCCheckOut() As %Status
{
	set logpath = ..ExportFilePath _ "\log\"
	#dim tSVNRepoPath = "https://subversion.assembla.com/svn/jointman/Ensemble"
	set cmd = ..SVNCommand_" checkout --username "_..SCUser_" --password "_..SCPWord_" "_tSVNRepoPath_" "_..ExportFilePath
	
	w cmd,!
	set result = $ZF(-1,cmd)
	w result,!
	quit ..GetStatus(result)
}

Method SCCheckIn(InternalName As %String) As %Status
{
	set filename = ..ExternalName(InternalName)
	set logpath = ..ExportFilePath _ "\log\"
	set cmd = ..SVNCommand_" commit -m ""Nightly checkin "_$ZDT($H)_""" --username "_..SCUser_" --password "_..SCPWord_" "_filename
	w cmd,!
	set result = $ZF(-1,cmd)
	w result,!
	quit ..GetStatus(result)
}

Method SCAdd(InternalName As %String) As %Status
{
	set filename = ..ExternalName(InternalName)
	set logpath = ..ExportFilePath _ "\log\"
	set cmd = ..SVNCommand_" add --username "_..SCUser_" --password "_..SCPWord_" "_filename
	w cmd,!
	set result = $ZF(-1,cmd)
	w result,!
	quit ..GetStatus(result)
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
	quit ..GetStatus(result)
}

Method SCGet(InternalName As %String) As %Status
{
	set SCName = ..SCName(InternalName)
	set logpath = ..ExportFilePath _ "\log\"
	set cmd = "tf get  "_SCName_" /login:"_..SCUser_","_..SCPWord _" /overwrite /noprompt 1>>"_logpath_"commandlog.txt 2>&1"
	set result = $ZF(-1,cmd)
	quit ..GetStatus(result)
}

Method CheckWorkspace() As %Status
{
	set logpath = ..ExportFilePath _ "\log\"
	//set cmd = "tf workspaces /owner:"_ ..SCUser_ " /collection:"_ ..TFSCollectionPath _ " /login:"_..SCUser_","_..SCPWord _" 1>>"_logpath_"workspacelog.txt 2>&1"
	set result = $ZF(-1,cmd)
	quit ..GetStatus(result)
}

Method SetWorkspace() As %Status
{
	set logpath = ..ExportFilePath _ "\log\"
	//set cmd = "tf workspace /new /collection:"_ ..TFSCollectionPath _ " /login:"_..SCUser_","_..SCPWord _" /permission:Public 1>>"_logpath_"workspacelog.txt 2>&1"
	set result = $ZF(-1,cmd)
	quit ..GetStatus(result)
}

Method SetWorkfolder() As %Status
{
	set logpath = ..ExportFilePath _ "\log\"
	//set cmd = "tf workfold /map "_ ..SCPath _" " _ ..ExportFilePath _" /login:"_..SCUser_","_..SCPWord _" 1>>"_logpath_"workfoldlog.txt 2>&1"
	set result = $ZF(-1, cmd)
	quit ..GetStatus(result)
}

Method DeleteLogFiles() As %Status
{
	set logfiles = ..ExportFilePath _ "\log\*.*"
	set tSC = ##class(%File).Delete(logfiles)
	return tSC
}

/// 	SCResult		Definition
/// 	============	=============================================================================================
/// 	0				Success.
/// 	1				Partial success; this means at least something, or possibly everything, failed to succeed.
/// 	2				Unrecognized command.
/// 	100				Nothing succeeded.
Method GetStatus(SCresult As %String) As %Status
{
	quit $CASE(SCresult,
              0:$$$OK,
              1:$$$ERROR($$$GeneralError,"Partial success; this means at least something, or possibly everything, failed to succeed."),
              2:$$$ERROR($$$GeneralError,"Unrecognized command."),
              100:$$$ERROR($$$GeneralError,"Nothing succeeded."))
}

}
