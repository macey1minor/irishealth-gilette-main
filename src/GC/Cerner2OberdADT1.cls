Class GC.Cerner2OberdADT1 Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ADT_A01' targetDocType='231.Cerner:ADT_A01' create='new' language='objectscript' >
<code>
<![CDATA[ 
	//  Last Updated: 07/24/2020 Al Johnson
	//  Last Updated in Prod: 07/28/2020 Al Johnson
	//  Create: 11/11/2019  Al Johnson
	//
	//  Description:  New Interface - ADT to Oberd
	//   Used to direct surveys for specific doctors and schedules
	//
	//  Demographic Spec for ADT shows PID and IN1
	//  Events A28 add, A29 delete, A31 update, A18 merge
	//  Only send primary insurance - testing 11/13/19
	//
	//  Send Preferred Language in PID-15 01/30/2020
	//   Modobject in Cerner changed to send OBX with PREFERRED_LA  this value is aliased
	//   PID-15.1 is sent with aliased Primary Language
	//   PID-15.5 is unaliased (text) of Preferred Language
	//   SIU does not have OBX in Cerner schema so modobject sending text in PID-15.5
	//     Crosswalk to alias is Ensemble table T_Oberd_Language_Preferred
	//   ADT A34 Merge also does not have OBX segments - Oberd is taking language off each ADT and SIU
	//
	//  Send Phone Email Text?: in PID-20 3/10/2020
	//   Value is sent in OBX = PHON_EMAI_TX
	//
	//  On Cerner upgrade, Cerner didnot convert multiple emails correctly.   7/24/2020 SD-49862 RFC SD-49907
	//  If multiples sent, need to take the first email in PID-11.
	//
]]></code>
<assign value='source.{MSH}' property='target.{MSH}' action='set' />
<assign value='source.{MSH:3.1}' property='target.{MSH:3.2}' action='set' />
<assign value='source.{MSH:4.1}' property='target.{MSH:4.2}' action='set' />
<assign value='source.{MSH:5.1}' property='target.{MSH:5.2}' action='set' />
<assign value='source.{MSH:6.1}' property='target.{MSH:6.2}' action='set' />

<code>
<![CDATA[
    // Oberd MSH spec
    // A18 Merge
    // A28 Patient Add
    // A29 Patient Delete
    // A31 Patient Update
]]></code>
<assign value='source.{MSH:9.2}' property='tmsh92' action='set' />
<if condition='(tmsh92="A01")||(tmsh92="A04")||(tmsh92="A05")||(tmsh92="A08")' >
<true>
<assign value='"A31"' property='target.{MSH:9.2}' action='set' />
</true>
</if>

<code>
<![CDATA[
    // Oberd PID spec
    // PID:2 patient id
    // PID:5 name
    // PID:7 date of birth
    // PID:8 gender
    // PID:11 address
    // PID:13.1 home phone
    // PID:13.4 email
    // PID:14.1 cell phone
    // IN1:4 insurance company
    // IN1:15 insurance plan type 
]]></code>

<assign value='source.{PID:3}' property='target.{PID:2}' action='set' />
<assign value='source.{PID:3}' property='target.{PID:3}' action='set' />
<assign value='source.{PID:5}' property='target.{PID:5}' action='set' />
<assign value='source.{PID:7}' property='target.{PID:7}' action='set' />
<assign value='source.{PID:8}' property='target.{PID:8}' action='set' />
<assign value='source.{PID:18}' property='target.{PID:18}' action='set' />
<assign value='""' property='target.{PID:19}' action='set' />

<assign value='""' property='tmpemail' action='set' />

<foreach property='source.{PID:11()}' key='k1' >
<if condition='source.{PID:11(k1).7}="E-mail"' >
<true>
<if condition='tmpemail=""' >
<true>
<assign value='source.{PID:11(k1).1}' property='tmpemail' action='set' />
</true>
</if>
</true>
<false>
<if condition='source.{PID:11(k1).7}="Home"' >
<true>
<assign value='source.{PID:11(k1)}' property='target.{PID:11(1)}' action='set' />
</true>
</if>
</false>
</if>
</foreach>

<assign value='tmpemail' property='target.{PID:13(1).4}' action='set' />

<foreach property='source.{PID:13()}' key='k2' >
<if condition='source.{PID:13(k2).2}="Home"' >
<true>
<assign value='source.{PID:13(k2).1}' property='target.{PID:13(1).1}' action='set' />
</true>
<false>
<if condition='source.{PID:13(k2).2}="CP"' >
<true>
<assign value='source.{PID:13(k2).1}' property='target.{PID:14(1).1}' action='set' />
</true>
</if>
</false>
</if>
</foreach>

<code>
<![CDATA[
    // Oberd testing 11/13/19 only send primary insurance
    // <foreach property='source.{IN1grp()}' key='k3' >
    // <assign value='source.{IN1grp(k3).IN1}' property='target.{IN1grp(k3).IN1}' action='set' />
    // </foreach>
]]></code>
<assign value='source.{IN1grp(1).IN1}' property='target.{IN1grp(1).IN1}' action='set' />

<code>
<![CDATA[
    // Send Prefferd Language
    //  1. off OBX PREFERRED_LA
    //  2. Crosswalk PID-15.5 preferred text to alias
    //  3. send primary language PID-15.1
    // Send Phone Email Text?:
    //  1. off OBX PHON_EMAI_TX send in PID-20
]]></code>

<assign value='""' property='tmplang' action='set' />
<assign value='""' property='tmpphnemltxt' action='set' />
<foreach property='source.{OBX()}' key='k4' >
<if condition='source.{OBX(k4):3}="PREFERRED_LA"' >
<true>
<assign value='source.{OBX(k4):5(1)}' property='tmplang' action='set' />
</true>
</if>
<if condition='source.{OBX(k4):3}="PHON_EMAI_TX"' >
<true>
<assign value='source.{OBX(k4):5(1)}' property='tmpphnemltxt' action='set' />
</true>
</if>
</foreach>

<assign value='tmpphnemltxt' property='target.{PID:20}' action='set' />

<if condition='tmplang=""' >
<true>
<assign value='""' property='wTableData' action='set' />
<assign value='""' property='wtableresult' action='set' />
<assign value='source.{PID:15.5}' property='wTableKey' action='set' />
<assign value='..Lookup("T_Oberd_Language_Preferred",wTableKey)' property='wtableresult' action='set' />
<if condition='wtableresult=""' >
<true>
<assign value='source.{PID:15.1}' property='tmplang' action='set' />
</true>
<false>
<assign value='wtableresult' property='tmplang' action='set' />
</false>
</if>
</true>
</if>

<assign value='tmplang' property='target.{PID:15}' action='set' />

</transform>
}

}
