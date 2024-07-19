/// 
Class IIBAENSEMBLE.Bproc.xRefImport Extends Ens.BusinessProcess [ ClassType = persistent, ProcedureBlock ]
{

Method OnRequest(pRequest As IIBAENSEMBLE.msg.xRefImport, Output pResponse As Ens.Response) As %Status
{
	d ##class(IIBAENSEMBLE.csp.Reference).initImportData(pRequest.SessionId)
	
	set pFileStream = ##class(%FileCharacterStream).%New()
	Set pFileStream.Filename = pRequest.filename
	
	set count = 0
	
	while 'pFileStream.AtEnd {
		d ##class(IIBAENSEMBLE.csp.Reference).collectImportData(pFileStream.ReadLine(),pRequest.SessionId) 
		set count = count+1
	}
	
	if pRequest.importType = "Replace" { d ##class(IIBAENSEMBLE.csp.Reference).removeExisting(pRequest.SessionId) }
	
	kill pFileStream
	
	set ^CacheTempImportStatus(pRequest.SessionId,"totalcount") = count
	
	set tSC = ..processImportData(pRequest.SessionId)
	
	if tSC {
		set ^CacheTempImportStatus(pRequest.SessionId,"status") = "Complete"
		//set tSC = ##class(%File).Delete(pRequest.filename)
	}
	
	Quit tSC
}

Method processImportData(SessionId As %String) As %Status
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
<Type>%Storage.Persistent</Type>
}

}
