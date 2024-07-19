/// Copyright 2008 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Reference.PrincipalValue Extends %Persistent
{

Property PValue As %String(MAXLEN = 256) [ Required ];

Relationship PrincipalType As PrincipalType [ Cardinality = one, Inverse = PrincipalValues, Required ];

Index PrincipalTypeIndex On PrincipalType;

Relationship RelatedValues As RelatedValue [ Cardinality = many, Inverse = PrincipalValue ];

Storage Default
{
<Data name="PrincipalValueDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Value</Value>
</Value>
<Value name="3">
<Value>PrincipalType</Value>
</Value>
<Value name="4">
<Value>PValue</Value>
</Value>
</Data>
<DataLocation>^IIBAENSEMBLE71D.PrincipalValueD</DataLocation>
<DefaultData>PrincipalValueDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^IIBAENSEMBLE71D.PrincipalValueD</IdLocation>
<IndexLocation>^IIBAENSEMBLE71D.PrincipalValueI</IndexLocation>
<Property name="%%CLASSNAME">
<Selectivity>99.9991%</Selectivity>
</Property>
<Property name="%%ID">
<Selectivity>1</Selectivity>
</Property>
<Property name="PValue">
<Selectivity>0.0137%</Selectivity>
</Property>
<Property name="PrincipalType">
<Selectivity>12.5000%</Selectivity>
</Property>
<StreamLocation>^IIBAENSEMBLE71D.PrincipalValueS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
