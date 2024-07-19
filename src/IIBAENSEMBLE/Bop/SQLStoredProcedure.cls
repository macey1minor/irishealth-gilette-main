/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Bop.SQLStoredProcedure Extends Ens.BusinessOperation [ ProcedureBlock ]
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Parameter INVOCATION = "Queue";

Property SpMessageClass As %String;

Property StoredProcName As %String;

Parameter SETTINGS As %String = "SpMessageClass,StoredProcName";

Method OnMessage(pRequest As %Persistent, Output pResponse As Ens.Response) As %Status
{
	$$$TRACE("Processing a message.../"_..SpMessageClass_"/"_..StoredProcName)
	
	set snap = ##class(%ListOfObjects).%New()
	set Output = ##class(%ListOfDataTypes).%New()
	
	$$$TRACE("Getting sp/message class parameters: "_"Select Name, InitialExpression from %Dictionary.PropertyDefinition where parent = "_..SpMessageClass_" Order by SequenceNumber")
	Set rs = ##class(%ResultSet).%New()
	Do rs.Prepare("Select Name, InitialExpression from %Dictionary.PropertyDefinition where parent = '"_..SpMessageClass_"' Order by SequenceNumber")
	set tSC = rs.Execute() Quit:$$$ISERR(tSC) tSC
	
	set count = 1
	Set spValueList=""
	
	$$$TRACE("putting together the parameters")
	
	While (rs.Next()) {
		
		set propertyname = rs.Get("Name") 
		
		Set InitialExpression = rs.Get("InitialExpression")
		set pIOParms(count) = $ZOBJPROPERTY(pRequest,propertyname)
		if pIOParms(count) = "" { 
			set pIOParms(count) = $E(InitialExpression,2,$L(InitialExpression)-1) 
		}
		$$$TRACE(propertyname_"/"_pIOParms(count)_"/"_$LENGTH(pIOParms(count))_"/"_InitialExpression_"/"_count)
		Set spValueList=spValueList_",'"_pIOParms(count)_"'"
		set count = count + 1
		
		
	
	}
	
	
	set $P(xcall,",?",count)=""
	set $P(xcall,"?",1)=""
	set $P(xio,"i",count)=""


	set tStoredProc = "{ call "_..StoredProcName_"("_xcall_")}"
	$$$TRACE(tStoredProc_"/"_xio)
	$$$TRACE("Values: "_spValueList)
	Set status = ..Adapter.ExecuteProcedureParmArray(.snap,.Output,tStoredProc,xio,.pIOParms) 
	//Set status = ..Adapter.ExecuteProcedure(.snap,.Output,tStoredProc,xio,"123456","00409","Smith","Smith","Jim","HF","2007-01-01 01:01:01","F","XCHES","HFMR","00409","","","123456") 
	
	If $$$ISERR(status){Quit status}
	Quit $$$OK
}

}
