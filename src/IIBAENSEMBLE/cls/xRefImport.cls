Class IIBAENSEMBLE.cls.xRefImport Extends %Persistent
{

ClassMethod Test() As %Status
{
	h 5
	Quit $$$OK
}

ClassMethod ProcessNewFiles() As %Status
{
	#dim tSC As %Status = $$$OK
	
	s EnsSysDir = ##class(%File).ParentDirectoryName(##class(%File).ManagerDirectory())
	s xRefImportDir = ##class(%File).NormalizeDirectory(EnsSysDir_"xRefImports\new\")
	s xRefWorkingDir = ##class(%File).NormalizeDirectory(EnsSysDir_"xRefImports\working\")
	
	if '##class(%File).DirectoryExists(xRefImportDir) { 
		d ##class(%File).CreateDirectoryChain(xRefImportDir) 
	}
	if '##class(%File).DirectoryExists(xRefWorkingDir) { 
		d ##class(%File).CreateDirectoryChain(xRefWorkingDir) 
	}
	
	Set rset = ##class(%ResultSet).%New()
	set rset.ClassName = "%File"
	set rset.QueryName = "FileSet"
	Do rset.Execute(xRefImportDir,"*","",0)
	While (rset.Next()) {
		
		if ($ZB(##class(%File).Attributes(rset.Data("Name")),16,1)=0) {
		
			set tfilefullname = rset.Data("Name")
			set tname = ##class(%File).GetFilename(rset.Data("Name"))
			
			set NewFileFullname = xRefWorkingDir_tname
			set tSC = ##class(%File).Rename(tfilefullname,NewFileFullname)
			if $$$ISERR(tSC) Quit
						
			set tSC = ..NewFile(tname,NewFileFullname)
			if $$$ISERR(tSC) Quit
		
		}
	}

	Quit tSC
}

ClassMethod NewFile(tname As %String, NewFileFullname As %String) As %Status
{
	set importType = $P($P(tname,".",1),"_",1)
	set SessionId = $P($P(tname,".",1),"_",2)
	set filetimestamp = $P($P(tname,".",1),"_",3)
	set filename = NewFileFullname
		
	Set tSC = ..OnNewFile(importType, SessionId, filetimestamp, filename)
	
	Quit tSC
}

ClassMethod OnNewFile(importType As %String, SessionId As %String, filetimestamp As %String, filename As %String) As %Status
{
	d ##class(IIBAENSEMBLE.csp.Reference).initImportData(SessionId)
	
	set pFileStream = ##class(%FileCharacterStream).%New()
	Set pFileStream.Filename = filename
	
	set count = 0
	
	while 'pFileStream.AtEnd {
		d ##class(IIBAENSEMBLE.csp.Reference).collectImportData(pFileStream.ReadLine(),SessionId) 
		set count = count+1
	}
	
	if importType = "Replace" { d ##class(IIBAENSEMBLE.csp.Reference).removeExisting(SessionId) }
	
	kill pFileStream
	
	set ^CacheTempImportStatus(SessionId,"totalcount") = count
	
	set tSC = ..processImportData(SessionId)
	if $$$ISERR(tSC) Quit tSC
	
	set ^CacheTempImportStatus(SessionId,"status") = "Complete"
	
	Quit tSC
}

ClassMethod processImportData(SessionId As %String) As %Status
{
	set ^CacheTempImportStatus(SessionId,"status") = "Processing..."
	set RVCount = 0
	set tSC = 1
	set sPTName=""
	For  { Set sPTName=$O(^CacheTempaImport(SessionId,sPTName)) Q:sPTName=""
 	
		set oPT = ##class(IIBAENSEMBLE.csp.Reference).getPTobj(sPTName,^CacheTempaPTAttr(SessionId,sPTName,"PrincipalRole"),^CacheTempaPTAttr(SessionId,sPTName,"System"),.tSC)
		set sPTID=oPT.%Id()
 
		set sPV=""
		For  { Set sPV=$O(^CacheTempaImport(SessionId,sPTName,sPV)) Q:sPV=""

 			set oPV = ##class(IIBAENSEMBLE.csp.Reference).getPVobj(sPV, sPTID,.tSC)
			set sPVID=oPV.%Id()
 
			set sRTSystem=""
			For  { Set sRTSystem=$O(^CacheTempaImport(SessionId,sPTName,sPV,sRTSystem)) Q:sRTSystem=""
			
				set oRT = ##class(IIBAENSEMBLE.csp.Reference).getRTobj(sRTSystem, sPTID,.tSC)
				set sRTID=oRT.%Id()
 				set sRV=""
				For  { Set sRV=$O(^CacheTempaImport(SessionId,sPTName,sPV,sRTSystem,sRV)) Q:sRV=""
 					
 					set RVCount = RVCount + 1
 					set ^CacheTempImportStatus(SessionId,"rvcount") = RVCount
 					
 					set sRVID=##class(IIBAENSEMBLE.csp.Reference).getRVID(sRV, sPVID, sRTID)
					
					if sRVID="" {
						set tSC = ##class(IIBAENSEMBLE.csp.Reference).doRVUpSert(oPT, oRT, oPV, sRV,.tSC)
					}
				}	
			}
		}
	}
	
	Quit tSC
}

Storage Default
{
<Data name="xRefImportDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^IIBAENSEMBLE.cls.xRefImportD</DataLocation>
<DefaultData>xRefImportDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^IIBAENSEMBLE.cls.xRefImportD</IdLocation>
<IndexLocation>^IIBAENSEMBLE.cls.xRefImportI</IndexLocation>
<StreamLocation>^IIBAENSEMBLE.cls.xRefImportS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
