Class GC.Cerner2XltekORM Extends Ens.DataTransformDTL [ ClassType = "", DependsOn = (EnsLib.HL7.Message, GC.Xltek.ORMXML), ProcedureBlock ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='GC.Xltek.ORMXML' sourceDocType='231.Cerner:ORM_O01' create='new' language='objectscript' >
<code>
<![CDATA[ 
    // Desc: Sleep Orders sent to XLTEK Transformed to XML
    
                // Created: 12/01/09 Mary Schopfer Last Updated 12/11/2012
                // GC.Xltek.ORMXML inherits from 23.Cernerbase override ORM
                // ORC:2 = CA send out as ADT A03
                // Change code to word for SEX
                // send QES appt ID as order number if QES_1 is blank
                // send PID:18_#_SCH:1 in VisitNumberField 
                // send PID:18_QES#_SCH:2 if SCH:1 is blank
]]></code>
<code>
<![CDATA[ 
    // cancel send out as ADT A03 otherwise send as ORM O01
]]></code>
<if condition='(source.{ORCgrp(1).ORC:OrderControl} = "CA" )|| (source.{ORCgrp(1).ORC:OrderControl} = "DC" )' >
<true>
<assign value='"ADT"' property='target.HL7Message.MSH.MessageTypeID' action='set' />
<assign value='"A03"' property='target.HL7Message.MSH.TriggerEventID' action='set' />
</true>
<false>
<assign value='"ORM"' property='target.HL7Message.MSH.MessageTypeID' action='set' />
<assign value='"O01"' property='target.HL7Message.MSH.TriggerEventID' action='set' />
</false>
</if>

<assign value='source.{PID:PatientIdentifierList().ID}' property='target.HL7Message.PID.PatientIDInternal' action='set' />
<assign value='source.{PID:PatientName().familylastname}' property='target.HL7Message.PID.PatientLastName' action='set' />
<assign value='source.{PID:PatientName().givenname}' property='target.HL7Message.PID.PatientFirstName' action='set' />
<assign value='source.{PID:DateTimeOfBirth.timeofanevent}' property='target.HL7Message.PID.PatientDateTimeofBirth' action='set' />
<if condition='source.{PID:Sex} = "F"' >
<true>
<assign value='"Female"' property='target.HL7Message.PID.PatientSex' action='set' />
</true>
</if>
<if condition='source.{PID:Sex} = "M"' >
<true>
<assign value='"Male"' property='target.HL7Message.PID.PatientSex' action='set' />
</true>
</if>
<if condition='source.{PID:Sex} = "U"' >
<true>
<assign value='""' property='target.HL7Message.PID.PatientSex' action='set' />
</true>
</if>
<assign value='source.{PID:PatientAddress().streetaddress}' property='target.HL7Message.PID.PatientStreetAddress' action='set' />
<assign value='source.{PID:PatientAddress().city}' property='target.HL7Message.PID.PatientCity' action='set' />
<assign value='source.{PID:PatientAddress().stateorprovince}' property='target.HL7Message.PID.PatientStateorProvince' action='set' />
<assign value='source.{PID:PatientAddress().ziporpostalcode}' property='target.HL7Message.PID.PatientZiporPostalCode' action='set' />
<assign value='source.{PID:PatientAddress().country}' property='target.HL7Message.PID.PatientCountry' action='set' />
<assign value='source.{ORCgrp(1).OBRgrp.OBR:UniversalServiceID.text}' property='target.HL7Message.PID.ChartNo' action='set' />
<assign value='source.{PV1:ReferringDoctor.givenname}' property='target.HL7Message.PV1.ReferringPhysicianFirstName' action='set' />
<assign value='source.{PV1:ReferringDoctor.familylastname}' property='target.HL7Message.PV1.ReferringPhysicianLastName' action='set' />
<assign value='source.{PID:PatientAccountNumber.ID}_"#"_source.{ORCgrp(1).ORC:PlacerOrderNumber().entityidentifier}' property='target.HL7Message.PV1.VisitNumber' action='set' />
<assign value='source.{PID:13.1}' property='target.HL7Message.PID.PatientHomePhone' action='set' />
<assign value='source.{ORCgrp(1).OBRgrp.OBR:OrderingProvider(1).familylastname}_","_source.{ORCgrp(1).OBRgrp.OBR:OrderingProvider(1).givenname}_" #"_source.{ORCgrp(1).OBRgrp.OBR:OrderingProvider(1).IDnumberST}' property='target.HL7Message.PID.BillingID' action='set' />
<assign value='""' property='target.HL7Message.OBX.ObservationValue' action='set' />
<foreach property='source.{PID:PhoneNumberHome()}' key='k1' >
<if condition='source.{PID:PhoneNumberHome(k1).3} = "PH" ' >
<true>
<assign value='source.{PID:PhoneNumberHome(k1).1}' property='target.HL7Message.PID.PatientHomePhone' action='set' />
</true>
</if>
</foreach>
<assign value='source.{ORCgrp(1).ORC:PlacerOrderNumber}' property='target.HL7Message.ORC' action='set' />

</transform>
}

}
