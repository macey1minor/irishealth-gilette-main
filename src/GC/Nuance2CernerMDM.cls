Class GC.Nuance2CernerMDM Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='22.Dictaphone:MDM_T02' targetDocType='22.Dictaphone:MDM_T02' create='copy' language='objectscript' >
<code>
<![CDATA[ 
	//  Last Updated 11/28/2017 Al Johnson
	//  Last Updated in Prod: 11/29/2017 Al Johnson
	//  Create: 03/16/2017  Al Johnson 
	//  Description:
	//  Check PV1-18 patient type for OPMSG (phone encounter) or PV1-18 starting with PRE (preoutpatient etc)
	//  These encounters should not have transcriptions.
	//  Force these to error inbound to Cerner by appending the PV1-18 to the fin
	//  Remove the PV1 on all the MDM messages  
	//	Uses subtransform Qcpr2RegLabORMSub  also for ORC and OBR
	//
	//  Add PV1-18 value Prior Auth to list   9/18/2017
	//
	//  Jira 8354 Allow OPMSG (phone encounter fin) on document ids 21,22, 24 and 25
	//       telephone conversation note, letters, chartchecks and labchecks 9/28/2017
	//
	//  Jira 8354 Only allow document types 21,22,24 and 25 on OPMSG per Janet Rude 10/06/2017
	//  Jira 8354 If no fin - force error by inserting 'NOFIN' per Janet Rude 10/06/2017
	//  Jira 8354 Include type 12 confidential note with 21,22,24 and 25 per Janet 10/06/2017
	//  Jira 8354  type 12 may come in against other fins but allow against OPMSG
	//  Jira CNR-9229 Documents that have future dates - are incorrectly filing in Cerner Power Chart.  11/28/2017
	//     We are requesting to Block and error - the Nuance Inscribe documents that have a future date on them.
	//    Change fin to 'FUTURE' same as nofin logic 11/28/2017
]]></code>

<code>
<![CDATA[
    //  10/06/2017 force all transcriptions to have a fin or error in Cerner
]]></code>
<assign value='"NOFIN"' property='tmpfinnbr' action='set' />
<if condition='(target.{PID:PatientAccountNumber}="")'>
<true>
<assign value='tmpfinnbr' property='target.{PID:PatientAccountNumber}' action='set' />
</true>
</if>

<code>
<![CDATA[
    //  03/16/2017 error if against PREadmits PREOutpatient etc
]]></code>
<if condition='($EXTRACT(target.{PV1:PatientType},1,3)="PRE")' >
<true>
<assign value='target.{PID:PatientAccountNumber}' property='tmpaccount' action='set' />
<assign value='target.{PV1:PatientType}' property='tmppattype' action='set' />
<assign value='tmpaccount_"-"_tmppattype' property='target.{PID:PatientAccountNumber}' action='set' />
</true>
</if>

<code>
<![CDATA[
    //  09/28/2017 allow 12,21,22,24 and 25 against OPMSG, error all others
]]></code>
<if condition='(target.{PV1:PatientType}="OPMSG")' >
<true>
<if condition='..In(source.{TXA:2.1},"12,21,22,24,25")' >
<false>
<assign value='target.{PID:PatientAccountNumber}' property='tmpaccount' action='set' />
<assign value='target.{PV1:PatientType}' property='tmppattype' action='set' />
<assign value='tmpaccount_"-"_tmppattype' property='target.{PID:PatientAccountNumber}' action='set' />
</false>
</if>
</true>
</if>

<code>
<![CDATA[
    //  10/06/2017 only allow 21,22,24 and 25 against OPMSG
    //   type 12 may come against other fins
]]></code>
<if condition='..In(source.{TXA:2.1},"21,22,24,25")' >
<true>
<if condition='(target.{PV1:PatientType}="OPMSG")' >
<false>
<assign value='target.{PID:PatientAccountNumber}' property='tmpaccount' action='set' />
<assign value='target.{PV1:PatientType}' property='tmppattype' action='set' />
<assign value='tmpaccount_"-"_tmppattype' property='target.{PID:PatientAccountNumber}' action='set' />
</false>
</if>
</true>
</if>

<code>
<![CDATA[
    //  09/18/2017 error if against Prior Auth
]]></code>
<if condition='($EXTRACT(target.{PV1:PatientType},1,10)="Prior Auth")' >
<true>
<assign value='target.{PID:PatientAccountNumber}' property='tmpaccount' action='set' />
<assign value='"PriorAuth"' property='tmppattype' action='set' />
<assign value='tmpaccount_"-"_tmppattype' property='target.{PID:PatientAccountNumber}' action='set' />
</true>
</if>

<code>
<![CDATA[
    //  11/28/2017 force ESI error if future date - compare TXA-4 against today
]]></code>
<assign value='"FUTURE"' property='tmpfinnbr' action='set' />
<assign value='..SubString(source.{TXA:4.1},1,8)' property='holdTXA4' action='set' />
<assign value='..SubString(source.{MSH:7.1},1,8)' property='holdMSH7' action='set' />
<if condition='(holdTXA4)&gt;(holdMSH7)'>
<true>
<assign value='tmpfinnbr' property='target.{PID:PatientAccountNumber}' action='set' />
</true>
</if>

<assign value='""' property='target.{PV1}' action='remove' />

</transform>
}

}
