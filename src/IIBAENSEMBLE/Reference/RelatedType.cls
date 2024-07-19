/// Copyright 2008 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Reference.RelatedType Extends %Persistent
{

Property System As %String(MAXLEN = 256) [ Required ];

Property DefaultValue As %String(MAXLEN = 256);

Property OneToOne As %Boolean [ InitialExpression = 0, Required ];

Property attrClass As %String(MAXLEN = 256);

Relationship PrincipalType As PrincipalType [ Cardinality = one, Inverse = RelatedTypes, Required ];

Relationship RelatedValues As RelatedValue [ Cardinality = many, Inverse = RelatedType ];

Method getAttrList() As %String
{
	set attrString = ""
	set count = 0
	Set rs = ##class(%ResultSet).%New()
	Do rs.Prepare("Select Name from %Dictionary.PropertyDefinition where parent = '"_..attrClass_"' Order by SequenceNumber")
	do rs.Execute()
	While rs.Next() {
		if $I(count) > 1 {
			s attrString = attrString_","
		} 
		s attrString = attrString_rs.Data("Name")
	}
	Quit attrString
}

Method attrImportValidateHeader(header As %String) As %Boolean
{
	if ..attrClass = "" Quit 0
	 
 	set lHeader = $LFS("PTName,RTSystem,PValue,RValue,"_..getAttrList())
	
	set lCSV = ##class(IIBAENSEMBLE.Functions).ParseCSV(header)
 
	Set ReturnVal=1
 
	for i=1:1:$LL(lHeader) { 
		if ($LL(lCSV)'=$LL(lHeader))||($LI(lCSV,i)'=$LI(lHeader,i)){
	 		Set ReturnVal=0
	 	}
	}
 
 
	Quit ReturnVal
}

Method getAttrData() As %ResultSet
{
	
	set attrString = ..getAttrList()
	
	//Create list from Class Name
	set MCL = $LFS(..attrClass,".")
	//Create a new sublist of all parts of the name except the last part
	set MCLt = $LI(MCL,1,$LL(MCL)-1)
	//Join the parts of that name back into a string delimited by _ except the last part
	set sClassTable = $LTS(MCLt,"_")
	//Add the last part in, but delimited by . 
	set sClassTable = sClassTable_"."_$LI(MCL,$LL(MCL))

	set SQL=""
	set SQL=SQL_"Select RelatedValue.id, PrincipalValue->PValue as "_..PrincipalType.System_", RValue as "_..System_", "_attrString_" from IIBAENSEMBLE_Reference.RelatedValue "
	set SQL=SQL_"LEFT OUTER JOIN "_sClassTable_" "
	set SQL=SQL_"ON attrId = "_$LI(MCL,$LL(MCL))_".id "
	set SQL=SQL_"WHERE RelatedType = "_..%Id()_" "
	set SQL=SQL_"ORDER BY "_..PrincipalType.System
	
	set rs = ##class(%ResultSet).%New()
	do rs.Prepare(SQL)
	do rs.Execute()
	
	Quit rs
}

Storage Default
{
<Data name="RelatedTypeDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>DefaultValue</Value>
</Value>
<Value name="3">
<Value>System</Value>
</Value>
<Value name="4">
<Value>OneToOne</Value>
</Value>
<Value name="5">
<Value>PrincipalType</Value>
</Value>
<Value name="6">
<Value>attrClass</Value>
</Value>
</Data>
<DataLocation>^IIBAENSEMBLE.Re71D.RelatedTypeD</DataLocation>
<DefaultData>RelatedTypeDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^IIBAENSEMBLE.Re71D.RelatedTypeD</IdLocation>
<IndexLocation>^IIBAENSEMBLE.Re71D.RelatedTypeI</IndexLocation>
<Property name="%%CLASSNAME">
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<Selectivity>1</Selectivity>
</Property>
<Property name="DefaultValue">
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="OneToOne">
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="PrincipalType">
<Selectivity>11.1111%</Selectivity>
</Property>
<Property name="System">
<Selectivity>3.8462%</Selectivity>
</Property>
<Property name="attrClass">
<Selectivity>25.0000%</Selectivity>
</Property>
<StreamLocation>^IIBAENSEMBLE.Re71D.RelatedTypeS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
