/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Bop.ClassToCSV Extends Ens.BusinessOperation [ ProcedureBlock ]
{

Parameter ADAPTER = "EnsLib.File.OutboundAdapter";

Parameter INVOCATION = "Queue";

Property FileName As %String;

Property ClassName As %String;

Parameter SETTINGS As %String = "FileName,ClassName";

Method OnMessage(pRequest As %Persistent, Output pResponse As Ens.Response) As %Status
{
	
	$$$TRACE("Getting sp/message class parameters: "_"Select Name, InitialExpression from %Dictionary.PropertyDefinition where parent = '"_..ClassName_"' Order by SequenceNumber")
	Set rs = ##class(%ResultSet).%New()
	Do rs.Prepare("Select Name, InitialExpression from %Dictionary.PropertyDefinition where parent = '"_..ClassName_"' Order by SequenceNumber")
	set tSC = rs.Execute() Quit:$$$ISERR(tSC) tSC
	
	$$$TRACE("putting together the parameters")
	
	Set Separator=","
	set propertyname = "", propertyvalue = "", tTextLine = "", count = 1
	set HeaderList="",tHeaderLine=""
	
	While (rs.Next()) {
		
		set propertyname = rs.Get("Name") 
		
		set propertyvalue = $ZOBJPROPERTY(pRequest,propertyname)
		
		$$$TRACE(propertyname_": "_propertyvalue)
		
		set $LIST(tPropList,count) = $C(34)_$LTS($LFS(propertyvalue,$C(34)),$C(34)_$C(34))_$C(34)
		set $LIST(HeaderList,count) = $C(34)_propertyname_$C(34)
		
		set count = count + 1
	
	}
	
	if $LISTDATA(tPropList,1) = 1 { set tTextLine = $LTS(tPropList,Separator) }
	if $LISTDATA(HeaderList,1) = 1 { set tHeaderLine = $LTS(HeaderList,Separator) }
	
	s CurFileName=##class(Ens.Util.File).CreateTimestamp("",..FileName)
	
	$$$TRACE("Write Header? "_tHeaderLine)
	If ( '..Adapter.Exists(CurFileName) ) {
		$$$TRACE("Printing Header: "_tHeaderLine)
		Set tSC=..Adapter.PutLine(CurFileName, tHeaderLine)
	}

	$$$TRACE("write data to "_CurFileName_": "_tTextLine)
	Set tSC=..Adapter.PutLine(CurFileName, tTextLine)
	
	
	
	Quit tSC
}

}
