Class EDW.dtl.Cerner2EdwADT Extends Ens.DataTransformDTL [ DependsOn = (EnsLib.HL7.Message, EDW.CernerAdtSqlParameters) ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EDW.CernerAdtSqlParameters' sourceDocType='231.Cerner:ADT_A01' create='new' language='objectscript' >
<code>
<![CDATA[ 
 	//  Author: Ellen
 	//  Create date: 09/03/20143
 	//  In PROD: not yet
 	//  Description: ADT data from QCPR to EDW for PROM survey.Nightly refresh from Affinity.
 	//  A01,A03( discharge),A04,A08,A11,A13,A28,A31 not all use A01 base but the fields I need work. 
 	//  Do not need to send A13 cancel Discharge 
 	//  Properites :Length must match exactly with SQL Proc or will not work.
 	//  Modified: na 
]]></code>
<assign value='source.{PID:PatientIdentifierList().ID}' property='target.Mrun' action='set' />
<assign value='source.{PID:PatientName().givenname}' property='target.PatientFirstName' action='set' />
<assign value='source.{PID:PatientName().familylastname}' property='target.PatientLastName' action='set' />
<assign value='source.{PID:PatientName().middleinitialorname}' property='target.PatientMiddleName' action='set' />
<assign value='source.{PID:Sex}' property='target.Sex' action='set' />
<if condition='source.{PID:DateTimeofBirth.timeofanevent} = "" ' >
<false>
<assign value='..SubString(source.{PID:DateTimeofBirth.timeofanevent},5,6)_"/"_..SubString(source.{PID:DateTimeofBirth.timeofanevent},7,8)_"/"_..SubString(source.{PID:DateTimeofBirth.timeofanevent},1,4)' property='target.Dob' action='set' />
</false>
</if>

</transform>
}

}
