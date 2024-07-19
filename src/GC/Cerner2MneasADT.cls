Class GC.Cerner2MneasADT Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ADT_A01' targetDocType='231.MNEAS:ADT_A01' create='new' language='objectscript' >
<code>
<![CDATA[ 
	//  Last Updated: 12/15/2020 Al Johnson
	//  Last Updated in Prod: 12/22/2020 Al Johnson
	//  Create: 05/17/2019  Al Johnson
	//
	//  Description:  New Interface - ADT to State of Minnesota for Medicaid patients
	//  Send all segments per Mneas
	//
	//  Remove Z segments
	//  Remove NK1 segments - until Gillette fixes / cleans up
	//  Blank out GT1-2 - remove fhir id
	//  Remove multiple doctors in PD1-4, send npi
	//  Copy Fin into PV1-19
	//
	//  Created Custom Schema - 231.MNEAS added segment CON to A01 definition (4/24/2020) sd-43697 RFC SD-39265
	//
	//  Cerner Modobject mobj_mneas_out changed to send NPI in PD1 EMR-135 (cert), EMR-136 (prod)RFC SD-66825
]]></code>
<assign value='source.{MSH}' property='target.{MSH}' action='set' />
<assign value='source.{EVN}' property='target.{EVN}' action='set' />
<assign value='source.{PID}' property='target.{PID}' action='set' />
<assign value='source.{NTE()}' property='target.{NTE()}' action='set' />
<assign value='source.{PD1}' property='target.{PD1}' action='set' />

<assign value='"1"' property='target.{CON:1}' action='set' />
<assign value='"001"' property='target.{CON:2}' action='set' />
<if condition='source.{MSH:14}="NO"' >
<true>
<assign value='"A"' property='target.{CON:11}' action='set' />
</true>
<false>
<if condition='source.{MSH:14}="YES"' >
<true>
<assign value='"R"' property='target.{CON:11}' action='set' />
</true>
</if>
</false>
</if>

<assign value='""' property='temppd1doc1' action='set' />
<assign value='""' property='temppd1doc2' action='set' />
<assign value='""' property='temppd1doc3' action='set' />
<assign value='""' property='temppd1doc4' action='set' />
<assign value='""' property='temppd1doc5' action='set' />
<assign value='""' property='temppd1doc6' action='set' />
<assign value='""' property='temppd1doc7' action='set' />
<foreach property='source.{PD1:4()}' key='k3' >
<if condition='(source.{PD1:4(k3).13}="National Provider Identifier")||(source.{PD1:4(k3).13}="NPI")' >
<true>
<assign value='source.{PD1:4(k3).1}' property='temppd1doc1' action='set' />
<assign value='source.{PD1:4(k3).2}' property='temppd1doc2' action='set' />
<assign value='source.{PD1:4(k3).3}' property='temppd1doc3' action='set' />
<assign value='source.{PD1:4(k3).4}' property='temppd1doc4' action='set' />
<assign value='source.{PD1:4(k3).5}' property='temppd1doc5' action='set' />
<assign value='source.{PD1:4(k3).6}' property='temppd1doc6' action='set' />
<assign value='source.{PD1:4(k3).7}' property='temppd1doc7' action='set' />
</true>
</if>
</foreach>
<assign value='(source.{PD1:4(*)})' property='PD1PCPcnt' action='set' />
<if condition='PD1PCPcnt &gt; 0' >
<true>
<assign value='""' property='target.{PD1:4}' action='set' />
<assign value='temppd1doc1' property='target.{PD1:4(1).1}' action='set' />
<assign value='temppd1doc2' property='target.{PD1:4(1).2}' action='set' />
<assign value='temppd1doc3' property='target.{PD1:4(1).3}' action='set' />
<assign value='temppd1doc4' property='target.{PD1:4(1).4}' action='set' />
<assign value='temppd1doc5' property='target.{PD1:4(1).5}' action='set' />
<assign value='temppd1doc6' property='target.{PD1:4(1).6}' action='set' />
<assign value='temppd1doc7' property='target.{PD1:4(1).7}' action='set' />
<assign value='"NPI"' property='target.{PD1:4(1).9}' action='set' />
<assign value='"NPI"' property='target.{PD1:4(1).13}' action='set' />
</true>
</if>

<assign value='source.{PV1}' property='target.{PV1}' action='set' />
<assign value='source.{PID:18}' property='target.{PV1:19}' action='set' />
<assign value='source.{PV2}' property='target.{PV2}' action='set' />
<assign value='source.{OBX()}' property='target.{OBX()}' action='set' />
<assign value='source.{AL1grp()}' property='target.{AL1grp()}' action='set' />
<assign value='source.{DG1()}' property='target.{DG1()}' action='set' />
<assign value='source.{DRG()}' property='target.{DRG()}' action='set' />
<assign value='source.{PR1grp()}' property='target.{PR1grp()}' action='set' />
<assign value='source.{GT1(1)}' property='target.{GT1(1)}' action='set' />
<code>
<![CDATA[ 
    //  Remove fhir id
    ]]></code>
<if condition='target.{GT1(1):GuarantorNumber(1).ID}=""' >
<false>
<assign value='""' property='target.{GT1(1):GuarantorNumber(1).ID}' action='set' />
</false>
</if>
<code>
<![CDATA[ 
    //  Only send Minnesota Medicaid insurance IN1-2.1 = 2875642
    ]]></code>
<code>
<![CDATA[ 
    //  Only send Minnesota Medicaid insurance IN1-2.1 = 2875642
    //  4/2/2020 Covid19 - send all insurances
    //
    //  <foreach property='source.{IN1grp()}' key='k1' >
    //  <if condition='source.{IN1grp(k1).IN1:2.1}="2875642"' >
    //  <true>
    //  <assign value='tmpidx+1' property='tmpidx' action='set' />
    //  <assign value='source.{IN1grp(k1).IN1}' property='target.{IN1grp(tmpidx).IN1}' action='set' />
    //  <assign value='source.{IN1grp(k1).IN2}' property='target.{IN1grp(tmpidx).IN2}' action='set' />
    //  <foreach property='source.{IN1grp(k1).IN3grp()}' key='k2' >
    //  <assign value='source.{IN1grp(k1).IN3grp(k2).IN3}' property='target.{IN1grp(tmpidx).IN3grp(k2).IN3}' action='set' />
    //  </foreach>
    //  </true>
    //  </if>
    //  </foreach>
    ]]></code>
<assign value='"0"' property='tmpidx' action='set' />
<foreach property='source.{IN1grp()}' key='k1' >
<assign value='tmpidx+1' property='tmpidx' action='set' />
<assign value='source.{IN1grp(k1).IN1}' property='target.{IN1grp(tmpidx).IN1}' action='set' />
<assign value='source.{IN1grp(k1).IN2}' property='target.{IN1grp(tmpidx).IN2}' action='set' />
<foreach property='source.{IN1grp(k1).IN3grp()}' key='k2' >
<assign value='source.{IN1grp(k1).IN3grp(k2).IN3}' property='target.{IN1grp(tmpidx).IN3grp(k2).IN3}' action='set' />
</foreach>
</foreach>
<assign value='source.{ACC()}' property='target.{ACC()}' action='set' />
<assign value='source.{UB1}' property='target.{UB1}' action='set' />
<assign value='source.{UB2}' property='target.{UB2}' action='set' />
</transform>
}

}
