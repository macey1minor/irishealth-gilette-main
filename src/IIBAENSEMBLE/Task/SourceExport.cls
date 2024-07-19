/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Task.SourceExport Extends %SYS.Task.Definition
{

Parameter TaskName = "SourceExporttoFile";

Property CSPApplicationName As %String;

Property CSPApplicationPath As %String;

Property ExportPath As %String;

Property VersionsToKeep As %Integer [ InitialExpression = 3 ];

/*
	*** C001 11/7/2019 BHK - add options to:
		- disable timestamping (IncludeTimeStamp)
		- export all items, regardless of whether ^SourceControldttm() item matches %RoutineMgr.TS() output for item
		- toggle deletion of files in ExportPath
	to allow for exporting of classes, one-time, for an indirect (manual) xport-to-SourceControl context
*/
Property IncludeTimeStamp As %Boolean [ InitialExpression = 1 ];

Property ExportAll As %Boolean [ InitialExpression = 0 ];

Property DeleteFiles As %Boolean [ InitialExpression = 1 ];

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
 		// *** C001
 		//if tSourceControldttm'=##class(%RoutineMgr).TS(name) {
	 	if ( (..ExportAll=1) ||(tSourceControldttm'=##class(%RoutineMgr).TS(name)) ) {
			set tSC = ..ExportFile(name)
			set ^SourceControldttm(name)=##class(%RoutineMgr).TS(name) 			
 		}
	 
 }
	
 Quit ..FinalCommit()
}

Method FinalCommit() As %Status
{
	//This is here to be over-ridden in sub class if needed.
	Quit $$$OK
}

Method ExportFile(InternalName As %String) As %String
{
	set filename = ..ExternalName(InternalName,..IncludeTimeStamp)	// *** C001
	set ^CacheTempMattsTrace2(8) = InternalName
	set ^CacheTempMattsTrace2(9) = filename
	
	//do ..DeletePreviousVersions(filename) // *** C001
	do:(..DeleteFiles=1) ..DeletePreviousVersions(filename)
	 
	Set tSC=$system.OBJ.Export(InternalName,filename,"-d")
	
	set ^CacheTempMattsTrace2(10) = "exporting file: "_InternalName_tSC	
 	
 	if $$$ISERR(tSC) Quit $$$ERROR($$$GeneralError,"Error occured in exporting file")
 	
 	Quit tSC
}

Method ExternalName(InternalName As %String, AddTimeStamp As %String = "") As %String
{
	Set name=$TR($piece(InternalName,".",1,$length(InternalName,".")-1),"/",".")
	Set ext=$zconvert($piece(InternalName,".",$length(InternalName,".")),"l")
	
	if AddTimeStamp = 0 {
		Set filename=..ExportPath_ext_"."_name_".xml"
	} else {
		Set filename=..ExportPath_ext_"."_name_"."_##class(Ens.Util.Time).FormatDateTime("%Y%m%d%H%M%S")_".xml"
	}
		
	Quit filename
}

Method DeletePreviousVersions(filename As %String)
{
	Set Path=..ExportPath, mask=##class(%File).GetFilename(filename)
	
	set mlist=""
	
	for i=1:1:$LENGTH(mask,".")-2 {
		set $LI(mlist,i)=$P(mask,".",i)
	}
	
	set mask = $LTS(mlist,".")
	set mask = mask_".*"
	
	
 	Set rset = ##class(%ResultSet).%New()
 	set rset.ClassName = "%File"
 	set rset.QueryName = "FileSet"
 	Do rset.Execute(Path,mask,"DateModified")
 	set filecount = 0
	
	set ^CacheTempMattsTrace2(5) = mask
	
 	While (rset.Next()) {
	// only files - skip directories
		if ($ZB(##class(%File).Attributes(rset.Data("Name")),16,1)=0) {
			set filecount = filecount +1
			set gfilenames(filecount) = rset.Data("Name")
 		}	
 	}
 	set ^CacheTempMattsTrace2(6) = filecount
 	set ^CacheTempMattsTrace2(11) = ..VersionsToKeep
 	set deletecount = 0
 	while filecount >= ..VersionsToKeep {
	 	set deletecount = deletecount + 1
	 	set ^CacheTempMattsTrace2("delete",deletecount) = gfilenames(deletecount)
	 	do ##class(%File).Delete(gfilenames(deletecount))
	 	set filecount = filecount - 1
 	}
 	set ^CacheTempMattsTrace2(12) = deletecount
}

}
