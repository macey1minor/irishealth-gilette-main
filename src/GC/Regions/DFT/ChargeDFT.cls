/// Sample class that gets used to build a request message from a line of delimited values 
/// in a text file<br><br>
/// 
/// v1.0 apc 08/2009 Birth of class, based on code from DRL<br><br>
/// 
/// Note the inherited Delimiter parameter, defaults to "|". Override here to change this<br>
/// Define the names of the pieces in each record, specifying the 
/// piece using the COLNUM dataype parameter. Make sure they are unique and > 0.<br><br>
/// TODO:<br>
/// - Consider making the delimiter a config parameter<br>
/// - Create more datatypes? I.e. date, integer, timestamp etc. <br>
Class GC.Regions.DFT.ChargeDFT Extends GC.Shared.Delimited
{

Property MRN As %String;

Property Name As %String;

Property Fin As %String;

Property MSHMRNFind As %String;

Property TransactionID As %String;

Property TransactionDate As %String;

Property PostingDate As %String;

Property TransactionType As %String;

Property CDM As %String;

Property Quantity As %String;

Property AmountExtended As %String;

Property AmountUnit As %String;

Property DeptCode As %String;

Property PerformingDoc As %String;

Property OrderedByDoc As %String;

Property CPT As %String;

Property CPTModifiers As %String;

Property HL7MessageDate As %String;

Property RegionsCDMDesc As %String;

Property RegionsCDMDept As %String;

Property RegionsCDMRevCode As %String;

Property RegionsCDMStatus As %String;

Property RegionsSentCPT As %String;

Property RegionsSentCPTMod As %String;

Storage Default
{
<Data name="ChargeDFTDefaultData">
<Subscript>"ChargeDFT"</Subscript>
<Value name="1">
<Value>MRN</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>Fin</Value>
</Value>
<Value name="4">
<Value>MSHMRNFind</Value>
</Value>
<Value name="5">
<Value>TransactionID</Value>
</Value>
<Value name="6">
<Value>TransactionDate</Value>
</Value>
<Value name="7">
<Value>PostingDate</Value>
</Value>
<Value name="8">
<Value>TransactionType</Value>
</Value>
<Value name="9">
<Value>CDM</Value>
</Value>
<Value name="10">
<Value>Quantity</Value>
</Value>
<Value name="11">
<Value>AmountExtended</Value>
</Value>
<Value name="12">
<Value>AmountUnit</Value>
</Value>
<Value name="13">
<Value>DeptCode</Value>
</Value>
<Value name="14">
<Value>PerformingDoc</Value>
</Value>
<Value name="15">
<Value>OrderedByDoc</Value>
</Value>
<Value name="16">
<Value>CPT</Value>
</Value>
<Value name="17">
<Value>CPTModifiers</Value>
</Value>
<Value name="18">
<Value>HL7MessageDate</Value>
</Value>
<Value name="19">
<Value>RegionsCDMDesc</Value>
</Value>
<Value name="20">
<Value>RegionsCDMDept</Value>
</Value>
<Value name="21">
<Value>RegionsCDMRevCode</Value>
</Value>
<Value name="22">
<Value>RegionsCDMStatus</Value>
</Value>
<Value name="23">
<Value>RegionsSentCPT</Value>
</Value>
<Value name="24">
<Value>RegionsSentCPTMod</Value>
</Value>
</Data>
<DefaultData>ChargeDFTDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
