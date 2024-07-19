/// Copyright 2007 by Inland Imaging Business Associates
/// This Class exports changed classes to Microsoft Visual Source Safe.
/// In order for this class to be used VSS must be correctly configured on the Ensemble Server
/// The ssbat.bat file must exist in the root of the namespace mgr directory
/// A folder named vss must exist in the root of the namespace mgr directory
Class IIBAENSEMBLE.Task.SourceExporttoVSS Extends %SYS.Task.Definition
{

Parameter TaskName = "SourceExporttoVSS";

/// example: /csp/healthshare/iibasupport/
Property CSPApplicationName As %String;

/// example: h:\ensemblesys\csp\iibasupport
Property CSPApplicationPath As %String;

/// example: /iibaensemble/test
Property VSSFolder As %String;

/// example: iibaensemble
Property VSSUser As %String;

/// example: iibaensemble
Property VSSPWord As %String;

/// NameSpace Directory - example: e:\ensemblesys\mgr\IIBARIS
Property NameSpaceDir As %String;

Method OnTask() As %Status
{
  
 kill tFullList 
 
 
 do $System.OBJ.GetClassList(.tList,"/mapped=0/system=0/percent=0")
  set class="" for  {
    set class=$o(tList(class)) quit:class=""
    if $P(class,".",1) '= "csp" {
    	set tFullList(class_".cls")=""
    }
  }
 
 set p="" for  {
    set p=$o(^Ens.Rule.RuleDefinitionD(p)) q:p=""
    set r="" for  {
      set r=$o(^Ens.Rule.RuleDefinitionD(p,r)) q:r=""
      set tFullList(p_"."_r_".rul")=""
    }
  }
  
 set cat="" for  {
 set cat=$o(^EnsHL7.Schema(cat)) quit:cat=""
  	set tFullList(cat_".hl7")=""
 }
 
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
 
 for {set name = $O(tFullList(name)) quit:name=""

 		set tSourceControldttm = $GET(^SourceControldttm(name))
 		if tSourceControldttm'=##class(%RoutineMgr).TS(name) {
			
			//set tSC = ..ExportFile(name)
			
			set tSC = ..OnBeforeCompile(name)
			set tSC = ..OnAfterCompile(name)
 			
			set ^SourceControldttm(name)=##class(%RoutineMgr).TS(name) 			
 		}
 }
	
 Quit $$$OK
}

/// Before loading any item we check to see if it exists in VSS and check it out if it does.
Method OnBeforeCompile(InternalName As %String) As %Status
{
	
	set ^CacheTempMattsTrace2(1) = $ZDT($H)_": OnBeforeCompile for file: "_InternalName
	/*
	status - 
		0 means exists and is Not checkedout
		1 means exists and is checked out
		100 means doesn't exist

	check out - 
		0 means success
		100 means already checked out
		100 means doesn't exist
			
	check in - 
		0 means success
		100 means checked out by other user
		100 means file doesn't exist
	*/
	
	
	set filename = ..ExternalName(InternalName)
	set VSSName = ..VSSName(InternalName)
	
	set tSC = $ZF(-1,"ss status "_VSSName_" -I-")
	set ^CacheTempMattsTrace2(1) = $ZDT($H)_": OnBeforeCompile for file: "_InternalName_" "_tSC
	
	///*	
	//if tSC = 0, the file exists and is checked in so we check it out
	if tSC = 0 {
		set tSC = ..VSSCheckOut(VSSName)
	//if tSC = 100, the file doesn't exist so we write it, add it, and check it out
	} Elseif tSC = 100 {
		//write it to file
		set ^CacheTempMattsTrace2(3) = tSC
		set tSC = ..ExportFile(InternalName)

		//change current project, add, and checkout
		if tSC { set tSC = ..VSSAdd(InternalName) }	
	//if tSC = 1, the file exists but is checked out, we quit with an error message
	} Elseif tSC = 1 {
		Quit $$$ERROR($$$GeneralError,"File is checked out of Source Control and cannot be compiled")
	}
	
	if tSC = 0 {
		Quit $$$OK
	} Else {
		Quit $$$ERROR($$$GeneralError,"File failed checkout: "_tSC)
	}
}

/// After compiling an item we write this to an xml file so that we can check the changes into VSS.
Method OnAfterCompile(InternalName As %String) As %Status
{
	set ^CacheTempMattsTrace2(2) = $ZDT($H)_": OnAfterCompile for file: "_InternalName
	
	set VSSName = ..VSSName(InternalName)
	
	// this condition added to skip hl7 files for now...
	Set ext=$zconvert($piece(InternalName,".",$length(InternalName,".")),"l")
		
	//write it to file and check it in with the current user
	set tSC = ..ExportFile(InternalName)
	if tSC { set tSC = ..VSSCheckIn(VSSName) }
	
	if tSC = 0 {
		Quit $$$OK
	} Else {
		Quit $$$ERROR($$$GeneralError,"File failed checkin: "_tSC)
	}
}

Method ExportFile(InternalName As %String) As %String
{
	set filename = ..ExternalName(InternalName)
	

	 
	Set tSC=$system.OBJ.Export(InternalName,filename,"-d")
	set ^CacheTempMattsTrace2(10) = "exporting file: "_InternalName_tSC	
 	// 	w $system.Status.DisplayError(tSC)
 	
 	//Quit:$$$ISERR(tSC)
 	if $$$ISERR(tSC) Quit $$$ERROR($$$GeneralError,"Error occured in exporting file")
 	
 	Quit tSC
}

Method VSSCheckOut(VSSName As %String) As %String
{
	set tSC = $ZF(-1,"ssbat.bat checkout "_VSSName_" "_..VSSUser_"")
	Quit tSC
}

Method VSSCheckIn(VSSName As %String) As %String
{
	set tSC = $ZF(-1,"ssbat.bat checkin "_VSSName_" "_..VSSUser_"")
	Quit tSC
}

Method VSSAdd(InternalName As %String) As %String
{
	set filename = ..ExternalName(InternalName)
	
	set tSC = $ZF(-1,"ss Cp $/"_..VSSFolder_"/"_$ZNSPACE_" -I- -Y"_..VSSUser_","_..VSSPWord_"")
	set ^CacheTempMattsTrace2(4) = tSC
	set tSC = $ZF(-1,"ss add "_filename_" -I- -K -Y"_..VSSUser_","_..VSSPWord_"")
	set ^CacheTempMattsTrace2(5) = tSC
	Quit tSC
}

Method VSSName(InternalName As %String) As %String
{
	Set name=$TR($piece(InternalName,".",1,$length(InternalName,".")-1),"/",".")
	Set ext=$zconvert($piece(InternalName,".",$length(InternalName,".")),"l")
	
	Set VSSName="$"_..VSSFolder_"/"_$ZNSPACE_"/"_ext_"."_name_".xml"
	
	Quit VSSName
}

Method ExternalName(InternalName As %String) As %String
{
	Set name=$TR($piece(InternalName,".",1,$length(InternalName,".")-1),"/",".")
	Set ext=$zconvert($piece(InternalName,".",$length(InternalName,".")),"l")
	
	set filename = ..NameSpaceDir_"\vss\"_ext_"."_name_".xml"
		
	Quit filename
}

}
