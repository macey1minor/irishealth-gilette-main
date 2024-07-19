Class GC.Cerner2eDocsSqlADT Extends Ens.DataTransformDTL [ DependsOn = (EnsLib.HL7.Message, GC.eDOCSsql.ADTParameters) ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='GC.eDOCSsql.ADTParameters' sourceDocType='231.Cerner:ADT_A01' create='new' language='objectscript' >
<code>
<![CDATA[ 
 	//  Author: Ellen
 	//  Create date: 09/03/2014 
 	//  In PROD:03/23/2015
 	//  Description:	Currently Charge data from Ensemble
 	//  Modified: 02/07/2015 EJL. Check for Discharge date length < 4 or blank. Sometimes sending in double quotes.
 	//  Modified: 02/16/2017 EJL. Check for Blank PV1 44 and use PV2 8.1 if blank
 	//  Description: Send ADT patient and visit data to eDOC.
 	//  A01,A03,A04,A08,A11,A13,A28,A31 not all use A01 base but the fields I need work. 
 	//  A13 clear Discharge date
 	//  Properites :Length must match exactly with SQL Proc or will not work.
]]></code>
<assign value='source.{EVN:EventTypeCode}' property='target.EVNf1transactionType' action='set' />
<assign value='source.{MSH:MessageControlID}' property='target.MSHf10msgControlID' action='set' />
<assign value='source.{PID:PatientIdentifierList().ID}' property='target.MRGf1mrNumber' action='set' />
<assign value='source.{PID:PatientIdentifierList().ID}' property='target.PIDf3mergeToMRNumber' action='set' />
<if condition='source.{PID:PatientName().middleinitialorname} = "" ' >
<true>
<assign value='""' property='tmpComma' action='set' />
</true>
<false>
<assign value='","' property='tmpComma' action='set' />
</false>
</if>
<assign value='source.{PID:PatientName.familylastname}_","_source.{PID:PatientName.givenname}_tmpComma_source.{PID:PatientName.middleinitialorname}' property='target.Pidf5s1patientName' action='set' />
<if condition='source.{PID:DateTimeofBirth.timeofanevent} = "" ' >
<false>
<assign value='..SubString(source.{PID:DateTimeofBirth.timeofanevent},5,6)_"/"_..SubString(source.{PID:DateTimeofBirth.timeofanevent},7,8)_"/"_..SubString(source.{PID:DateTimeofBirth.timeofanevent},1,4)' property='target.PIDf7DOB' action='set' />
</false>
</if>
<assign value='source.{PID:Sex}' property='target.PIDf8sex' action='set' />
<assign value='source.{PID:PatientAccountNumber.ID}' property='target.PIDf18visitID' action='set' />
<assign value='source.{PV1:PatientClass}' property='target.PV1f2visitType' action='set' />
<if condition='source.{PV1:AdmitDateTime} = "" ' >
<false>
<assign value='..SubString(source.{PV1:AdmitDateTime},5,6)_"/"_..SubString(source.{PV1:AdmitDateTime},7,8)_"/"_..SubString(source.{PV1:AdmitDateTime},1,4)' property='target.PV1f44admitDate' action='set' />
</false>
<true>
<if condition='source.{PV2:ExpectedAdmitDateTime} = "" ' >
<false>
<assign value='..SubString(source.{PV2:ExpectedAdmitDateTime},5,6)_"/"_..SubString(source.{PV2:ExpectedAdmitDateTime},7,8)_"/"_..SubString(source.{PV2:ExpectedAdmitDateTime},1,4)' property='target.PV1f44admitDate' action='set' />
</false>
</if>
</true>
</if>
<if condition='($LENGTH(source.{PV1:DischargeDateTime}) &lt; 4 ) || (source.{PV1:DischargeDateTime} = "")' >
<false>
<assign value='..SubString(source.{PV1:DischargeDateTime},5,6)_"/"_..SubString(source.{PV1:DischargeDateTime},7,8)_"/"_..SubString(source.{PV1:DischargeDateTime},1,4)' property='target.PV1F45dischargeDate' action='set' />
</false>
</if>
<if condition='source.{MSH:MessageType.triggerevent} = "A13"' >
<true>
<assign value='""' property='target.PV1F45dischargeDate' action='set' />
</true>
</if>
</transform>
}

}
