/// put new records from eDocs and send URL to Cener 
Class GC.eDocsScan.BSeDOCS Extends Ens.BusinessService
{

Parameter ADAPTER = "EnsLib.SQL.InboundAdapter";

Parameter REQUESTCLASSES As %String = "EnsLib.SQL.Snapshot";

Property TargetConfigName As %String(MAXLEN = 256);

// http://172.25.50.143:57773/csp/docbook/DocBook.UI.Page.cls?KEY=EGDV_prog#EGDV_prog_settings

Parameter SETTINGS As %String = "TargetConfigName";

Method OnProcessInput(pInput As EnsLib.SQL.Snapshot, Output pOutput As %RegisteredObject) As %Status
{
 set req=##class(GC.eDocsScan.eDocRecordDef).%New()
 set req.rank=pInput.Get("rank")
 set req.systemID=pInput.Get("systemID")
 set req.creationDate=pInput.Get("creationDate")
 set req.mrn=pInput.Get("mrn")
 set req.account=pInput.Get("account")
 set req.firstName=pInput.Get("firstName")
 set req.lastName=pInput.Get("lastName")
 set req.DOB=pInput.Get("DOB")
 set req.documentTypeID=pInput.Get("documentTypeID")
 set req.documentType=pInput.Get("documentType")
 set req.docDescription=pInput.Get("docDescription")
 set req.admitDate=pInput.Get("admitDate")
 set req.dischargeDate=pInput.Get("dischargeDate")
 set req.linkUrl=pInput.Get("linkUrl")
 set req.versionNbr=pInput.Get("versionNbr")
 set req.msgID=pInput.Get("msgID")
 set sc=..SendRequestAsync(..TargetConfigName,req)
 Quit sc
}

}
