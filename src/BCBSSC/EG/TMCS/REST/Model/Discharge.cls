Class BCBSSC.EG.TMCS.REST.Model.Discharge Extends (Ens.Request, %JSON.Adaptor) [ Inheritance = right ]
{

/// Because we do not want extra properties to throw errors.
Parameter %JSONIGNOREINVALIDFIELD = 1;

/// Subscriber identifier shared by AMMS and CES.  Should be 12 characters long.
/// </br> @example: 505050502
Property subscriberId As %String(MAXLEN = 20) [ Required ];

/// AMMS Patient ID - identifies a specific patient who receives services covered by the subscriber's plan.
/// </br> @example: 001
Property patientId As %String(MAXLEN = 5) [ Required ];

/// Internal identifier for an authorization.  Should be 13 characters long.
/// </br> @example: 2327007192563
Property authorizationNumber As %String(MAXLEN = "") [ Required ];

/// Format: CCYY-MM-DD or CCYYMMDD
/// </br> @example: 2023-08-17
Property admitDate As %String;

/// Format: CCYY-MM-DD or CCYYMMDD
/// </br> @example: 2023-08-17 or 20230817
Property dischargeDate As %String [ Required ];

/// This is really "discharged to location"
///  001: ACF,AMA,EXP,HMC,HME,HMH,HSP,ICF,IOP,MTF,OPR,PHP,REH,RTC,SNF
///       ACUTE CARE FACILITY,AGAINST MEDICAL ADVICE,EXPIRED,HOME CARE,HOME,HOME MENTAL HEALTH CARE,HOSPICE,INTERMEDIATE CARE FACILITY,INTENSIVE OUTPATIENT(PSYCH/CD),MTF MILITARY TREATMET FACILITY,OUTPATIENT REHABILITATION,PARTIAL HOSPITALIZATION,REHABILITATION FACILITY,RESIDENTIAL TREATMENT CENTER,SKILLED NURSING FACILITY
Property dischargeStatus As %String;

/// Source name, used along with discharge status and RPN to map to the value TMCS needs.
Property source As %String(MAXLEN = 100);

Property LastUpdatedUser As %String(%JSONINCLUDE = "OUTPUTONLY") [ ReadOnly, SqlComputeCode = { Set {*}=$Username}, SqlComputed, SqlComputeOnChange = (%%INSERT, %%UPDATE) ];

Storage Default
{
<Data name="DischargeDefaultData">
<Subscript>"Discharge"</Subscript>
<Value name="1">
<Value>subscriberId</Value>
</Value>
<Value name="2">
<Value>patientId</Value>
</Value>
<Value name="3">
<Value>rpn</Value>
</Value>
<Value name="4">
<Value>authorizationNumber</Value>
</Value>
<Value name="5">
<Value>admitDate</Value>
</Value>
<Value name="6">
<Value>dischargeDate</Value>
</Value>
<Value name="7">
<Value>dischargeStatus</Value>
</Value>
<Value name="8">
<Value>source</Value>
</Value>
<Value name="9">
<Value>LastUpdatedUser</Value>
</Value>
</Data>
<DefaultData>DischargeDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

/// Revision number of this class
Parameter SrcVer = 5;

}
