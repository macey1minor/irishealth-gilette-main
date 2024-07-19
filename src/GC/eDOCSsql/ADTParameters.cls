Class GC.eDOCSsql.ADTParameters Extends Ens.Request
{

// --------------------------------------------------------------

// Create By: Ellen Leichtman on 07/28/2014

//  Last Updated DEV 09/02/2014

//  Last Updated PROD : not in Prod

//  Modified BY: None

//  Modified Date: None

//  ModifiedDesc: None

/// Last Updated in Prod - never
/// Description: Send ADT eDoc ( was cyberdocs)      
/// PROD:  SQLDATA06\PRODSQL04
/// DEV SQL  server: (SQLDATA06\PRODSQL04).
/// Database: EHRDev
/// Stored:  proc will be called EHRDev.docsadm.sp_hl7_event
/// Table: NA, handled by Vendors
/// 
Property MSHf10msgControlID As %String(EXTERNALSQLTYPE = 12, MAXLEN = 255);

Property EVNf1transactionType As %String(EXTERNALSQLTYPE = 12, MAXLEN = 6);

Property MRGf1mrNumber As %String(EXTERNALSQLTYPE = 12, MAXLEN = 255);

Property PIDf3mergeToMRNumber As %String(EXTERNALSQLTYPE = 12, MAXLEN = 255);

Property Pidf5s1patientName As %String(EXTERNALSQLTYPE = 12, MAXLEN = 255);

Property PIDf7DOB As %String(EXTERNALSQLTYPE = 12, MAXLEN = 20);

Property PIDf8sex As %String(EXTERNALSQLTYPE = 12, MAXLEN = 1);

Property PIDf18visitID As %String(EXTERNALSQLTYPE = 12, MAXLEN = 255);

Property PV1f2visitType As %String(EXTERNALSQLTYPE = 12, MAXLEN = 15);

// sample 20140724093757

Property PV1f44admitDate As %String(EXTERNALSQLTYPE = 12, MAXLEN = 20);

// sample 20140724235959

Property PV1F45dischargeDate As %String(EXTERNALSQLTYPE = 12, MAXLEN = 20);

Storage Default
{
<Data name="ADTParametersDefaultData">
<Subscript>"ADTParameters"</Subscript>
<Value name="1">
<Value>EVNf1transactionType</Value>
</Value>
<Value name="2">
<Value>MSHf10msgControlID</Value>
</Value>
<Value name="3">
<Value>MRGf1mrNumber</Value>
</Value>
<Value name="4">
<Value>PIDf3mergeToMRNumber</Value>
</Value>
<Value name="5">
<Value>Pidf5s1patientName</Value>
</Value>
<Value name="6">
<Value>PIDf7DOB</Value>
</Value>
<Value name="7">
<Value>PIDf8sex</Value>
</Value>
<Value name="8">
<Value>PIDf18visitID</Value>
</Value>
<Value name="9">
<Value>PV1f2visitType</Value>
</Value>
<Value name="10">
<Value>PV1f44admitDate</Value>
</Value>
<Value name="11">
<Value>PV1F45dischargeDate</Value>
</Value>
</Data>
<DefaultData>ADTParametersDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
