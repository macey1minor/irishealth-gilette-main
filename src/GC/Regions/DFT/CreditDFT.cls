Class GC.Regions.DFT.CreditDFT Extends (%Persistent, %Populate, %XML.Adaptor, Ens.Response) [ ClassType = persistent, Inheritance = right ]
{

Property HL7MessageDate As %String;

Property MRN As %String;

Property Account As %String;

Property Name As %String;

Property CDM As %String;

Property Quantity As %String;

Property Amount As %String;

Property DateOfService As %String;

Property CPT As %String;

Property CPTModifiers As %String;

Storage Default
{
<Data name="CreditDFTDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>HL7MessageDate</Value>
</Value>
<Value name="3">
<Value>MRN</Value>
</Value>
<Value name="4">
<Value>Account</Value>
</Value>
<Value name="5">
<Value>Name</Value>
</Value>
<Value name="6">
<Value>CDM</Value>
</Value>
<Value name="7">
<Value>Quantity</Value>
</Value>
<Value name="8">
<Value>Amount</Value>
</Value>
<Value name="9">
<Value>DateOfService</Value>
</Value>
<Value name="10">
<Value>CPT</Value>
</Value>
<Value name="11">
<Value>CPTModifiers</Value>
</Value>
</Data>
<DataLocation>^GC.Regions.DFT.CreditDFTD</DataLocation>
<DefaultData>CreditDFTDefaultData</DefaultData>
<ExtentSize>2000000</ExtentSize>
<IdLocation>^GC.Regions.DFT.CreditDFTD</IdLocation>
<IndexLocation>^GC.Regions.DFT.CreditDFTI</IndexLocation>
<StreamLocation>^GC.Regions.DFT.CreditDFTS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
