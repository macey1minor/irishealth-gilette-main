/// Copyright 2008 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Reference.RelatedValue Extends %Persistent
{

Property RValue As %String(MAXLEN = 256) [ Required ];

Relationship PrincipalValue As PrincipalValue [ Cardinality = one, Inverse = RelatedValues, Required ];

Index PrincipalValueIndex On PrincipalValue;

Relationship RelatedType As RelatedType [ Cardinality = one, Inverse = RelatedValues, Required ];

Index RelatedTypeIndex On RelatedType;

Property attrId As %Integer;

Method attrUpSert(attrName As %String, attrValue As %String)
{
	set obj = $ZOBJCLASSMETHOD(..RelatedType.attrClass,"%OpenId",..attrId)
	if '$ISOBJECT(obj) set obj = $ZOBJCLASSMETHOD(..RelatedType.attrClass,"%New")
	
	
	set $ZOBJPROPERTY(obj, attrName) = attrValue
	
	do obj.%Save()
	
	set ..attrId = obj.%Id()
	
	do ..%Save()
}

Method attrUpSertJSON(Attributes As %String)
{
	set obj = $ZOBJCLASSMETHOD(..RelatedType.attrClass,"%OpenId",..attrId)
	if '$ISOBJECT(obj) set obj = $ZOBJCLASSMETHOD(..RelatedType.attrClass,"%New")
	
	
	
	set Attributes = $TR(Attributes,"{}""")
	
	for i=1:1:$L(Attributes,",") {
		
		set attrPair = $TR($P(Attributes,",",i),"{}""")
		set attrName = $ZSTRIP($P(attrPair,":",1),"<>W")
		set attrValue = $ZSTRIP($P(attrPair,":",2),"<>W")
		if (attrName '= "id")
			&&(attrName '= "RValue")
			&&(attrName '= "PValue")
			&&(attrName '= ..RelatedType.System)
			&&(attrName '= ..RelatedType.PrincipalType.System)
			&&(attrName '= "") {
			set $ZOBJPROPERTY(obj, attrName) = attrValue
			do ##class(IIBAENSEMBLE.csp.Reference).AuditChanges("attrUpSertJSON","attrPair:"_attrPair,..PrincipalValue.PrincipalType.%Id(),..RelatedType.%Id(),..PrincipalValue.%Id(),..%Id())
		}
	}
	
	do obj.%Save()
	
	set ..attrId = obj.%Id()
	
	do ..%Save()
}

Method attr() As %RegisteredObject
{
	set obj = $ZOBJCLASSMETHOD(..RelatedType.attrClass,"%OpenId",..attrId)
	Quit obj
}

ClassMethod attrImport(sRTID As %String, pFileStream As %GlobalCharacterStream) As %String
{
	Set HeaderLine = pFileStream.ReadLine()
	
	s ^CacheTempTrace = ""
	s ^CacheTempTrace = sRTID_"^"_HeaderLine
	
	set oRT = ##class(IIBAENSEMBLE.Reference.RelatedType).%OpenId(sRTID)
	
	if '$ISOBJECT(oRT) Quit "{success:false, resultstring:'Related Type Id: "_sRTID_" failed to open.'}"
	
	if 'oRT.attrImportValidateHeader(HeaderLine) {
		Quit "{success:false, resultstring:'Header row failed validation.'}"
	}
		
	while 'pFileStream.AtEnd {
		
		Set tLine = pFileStream.ReadLine()
		
		set lCSV = ##class(IIBAENSEMBLE.Functions).ParseCSV(tLine)
 
 		set sPTName=$LI(lCSV,1)
 		set sRTSystem = $LI(lCSV,2)
 		set sPV = $LI(lCSV,3)
 		set sRV = $LI(lCSV,4)
 		
 		//This condition causes the routine to skip attributes that are not for this Related Type in case you have multiple RT atttributes in one file
 		if (sPTName=oRT.PrincipalType.Name)&&(sRTSystem=oRT.System) {
 		
	 		s attrNameValuePairs = "{"
	 		s attrNameList = $LFS(oRT.getAttrList())
	 		
	 		for i=1:1:$LL(attrNameList) {
		 		if i > 1 s attrNameValuePairs=attrNameValuePairs_","
		 		s attrNameValuePairs = attrNameValuePairs_$LI(attrNameList,i)_":"_$LI(lCSV,4+i)
	 		}
 			set attrNameValuePairs=attrNameValuePairs_"}"
 			
	 		set sRVID=""
	
			&sql(select ID into :sRVID from IIBAENSEMBLE_Reference.RelatedValue where RValue = :sRV AND PrincipalValue->PValue = :sPV AND RelatedType = :sRTID)
			if SQLCODE '= 0 s sRVID = ""
		
			set oRV = ##class(IIBAENSEMBLE.Reference.RelatedValue).%OpenId(sRVID)
		
			if $ISOBJECT(oRV) do oRV.attrUpSertJSON(attrNameValuePairs)
 		}	
	}
	Quit "{success:true, resultstring:'Import completed successfully.'}"
}

Method attrDelete() As %Status
{
	set tSC = 1
	if ..RelatedType.attrClass '= "" {
	
	set tSC = $ZOBJCLASSMETHOD(..RelatedType.attrClass,"%DeleteId",..attrId)
	if tSC {
		set ..attrId = ""
		do ..%Save()
	}
	
	}
	Quit tSC
}

Storage Default
{
<Data name="RelatedValueDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Value</Value>
</Value>
<Value name="3">
<Value>PrincipalValue</Value>
</Value>
<Value name="4">
<Value>RelatedType</Value>
</Value>
<Value name="5">
<Value>RValue</Value>
</Value>
<Value name="6">
<Value>attrId</Value>
</Value>
</Data>
<DataLocation>^IIBAENSEMBLE.R71D.RelatedValueD</DataLocation>
<DefaultData>RelatedValueDefaultData</DefaultData>
<ExtentSize>39887</ExtentSize>
<IdLocation>^IIBAENSEMBLE.R71D.RelatedValueD</IdLocation>
<IndexLocation>^IIBAENSEMBLE.R71D.RelatedValueI</IndexLocation>
<Property name="%%CLASSNAME">
<Selectivity>99.9991%</Selectivity>
</Property>
<Property name="%%ID">
<Selectivity>1</Selectivity>
</Property>
<Property name="PrincipalValue">
<Selectivity>0.0156%</Selectivity>
</Property>
<Property name="RValue">
<Selectivity>0.0063%</Selectivity>
</Property>
<Property name="RelatedType">
<Selectivity>1.7241%</Selectivity>
</Property>
<Property name="attrId">
<Selectivity>7.6923%</Selectivity>
</Property>
<StreamLocation>^IIBAENSEMBLE.R71D.RelatedValueS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
