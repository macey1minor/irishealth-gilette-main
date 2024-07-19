/// Copyright 2008 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Reference.PrincipalType Extends %Persistent
{

Property Name As %String(MAXLEN = 256) [ Required ];

Property System As %String(MAXLEN = 256) [ Required ];

/// Reg#1 - Bug#2 - Phegel - Add initial expression so it has a default Reference
/// Resource access....
Property Resource As %String [ InitialExpression = "Reference" ];

Property PrincipalRole As %String(MAXLEN = 256, VALUELIST = ",source,target") [ Required ];

Relationship PrincipalValues As PrincipalValue [ Cardinality = many, Inverse = PrincipalType ];

Relationship RelatedTypes As RelatedType [ Cardinality = many, Inverse = PrincipalType ];

Storage Default
{
<Data name="PrincipalTypeDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>DefaultValue</Value>
</Value>
<Value name="3">
<Value>Name</Value>
</Value>
<Value name="4">
<Value>PrincipalRole</Value>
</Value>
<Value name="5">
<Value>System</Value>
</Value>
<Value name="6">
<Value>Resource</Value>
</Value>
</Data>
<DataLocation>^IIBAENSEMBLE71D.PrincipalTypeD</DataLocation>
<DefaultData>PrincipalTypeDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^IIBAENSEMBLE71D.PrincipalTypeD</IdLocation>
<IndexLocation>^IIBAENSEMBLE71D.PrincipalTypeI</IndexLocation>
<Property name="%%CLASSNAME">
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<Selectivity>1</Selectivity>
</Property>
<Property name="Name">
<Selectivity>11.1111%</Selectivity>
</Property>
<Property name="PrincipalRole">
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="Resource">
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="System">
<Selectivity>25.0000%</Selectivity>
</Property>
<StreamLocation>^IIBAENSEMBLE71D.PrincipalTypeS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
