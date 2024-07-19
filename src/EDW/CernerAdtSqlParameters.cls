Class EDW.CernerAdtSqlParameters Extends Ens.Request
{

// --------------------------------------------------------------

// Create By: Ellen Leichtman on 10/29/2014

//  Last Updated DEV 10/29/2014

//  Last Updated PROD : 10/30/2014

//  Modified BY: None

//  Modified Date: None

//  ModifiedDesc: None

/// Last Updated in Prod - never
/// Description: Send ADT to EDW used with Patient Surveys   
/// PROD:  gcshspdbpr01\edwprod
/// DEV SQL  server: GCSHSPDBTE01\EDWDev
/// Database:[EDW]
/// Stored:  proc will be called ODS_POC.[HL7].[EDW_O_QcrpADT] 
/// Table: [edw].[DimLivePatient]
/// 
Property Mrun As %String(EXTERNALSQLTYPE = 12, MAXLEN = 50);

Property PatientFirstName As %String(EXTERNALSQLTYPE = 12, MAXLEN = 50);

Property PatientLastName As %String(EXTERNALSQLTYPE = 12, MAXLEN = 50);

Property PatientMiddleName As %String(EXTERNALSQLTYPE = 12, MAXLEN = 50);

Property Dob As %String(EXTERNALSQLTYPE = 12, MAXLEN = 20);

Property Sex As %String(EXTERNALSQLTYPE = 12, MAXLEN = 1);

Storage Default
{
<Data name="CernerAdtSqlParametersDefaultData">
<Subscript>"CernerAdtSqlParameters"</Subscript>
<Value name="1">
<Value>Mrun</Value>
</Value>
<Value name="2">
<Value>PatientFirstName</Value>
</Value>
<Value name="3">
<Value>PatientLastName</Value>
</Value>
<Value name="4">
<Value>PatientMiddleName</Value>
</Value>
<Value name="5">
<Value>Dob</Value>
</Value>
<Value name="6">
<Value>Sex</Value>
</Value>
</Data>
<DefaultData>CernerAdtSqlParametersDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
