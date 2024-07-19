/// 
Class IIBAENSEMBLE.Bsvc.xRefImport Extends Ens.BusinessService [ ProcedureBlock ]
{

Parameter ADAPTER As %String = "Ens.InboundAdapter";

/// Not using the adapter at this point in order to provide flexibility, but will need to use the task manager to initiate the ProcessInput
/// Parameter ADAPTER = "EnsLib.File.InboundAdapter";
Property TargetConfigNames As %String(MAXLEN = 255);

Parameter SETTINGS As %String = "TargetConfigNames";

Method OnProcessInput(pInput As %RegisteredObject, pOutput As %RegisteredObject) As %Status
{
	s EnsSysDir = ##class(%File).ParentDirectoryName(##class(%File).ManagerDirectory())
	s xRefImportDir = EnsSysDir_"xRefImports\new\"
	s xRefWorkingDir = EnsSysDir_"xRefImports\working\"
	
	set tSC = 1
	
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
			
			if (tSC '= 1) {
				$$$LOGERROR("Could not move file "_tname_" to the working directory "_xRefWorkingDir)
				set tSC = 1
				Q
			}
			
			set tSC = ..SendMsg(tname,NewFileFullname)
		
		}
	}

	Quit tSC
}

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

Method SendMsg(tname As %String, NewFileFullname As %String) As %Status
{
	set pRequest = ##class(IIBAENSEMBLE.msg.xRefImport).%New()
	set pRequest.importType = $P($P(tname,".",1),"_",1)
	set pRequest.SessionId = $P($P(tname,".",1),"_",2)
	set pRequest.filetimestamp = $P($P(tname,".",1),"_",3)
	set pRequest.filename = NewFileFullname
		
	For i=1:1:$L(..TargetConfigNames,",") {
					
		S target=$P(..TargetConfigNames,",",i)
		$$$TRACE("Target #"_i_": "_target)
		If ( target '= "" ) {
			$$$TRACE("Sending request to "_target)
			Set tSC = ..SendRequestAsync(target,pRequest)
		}
	}
	Quit tSC
}

}
