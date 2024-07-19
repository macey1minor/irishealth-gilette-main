Class GC.Cerner2OberdMRG Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ADT_A34' targetDocType='231.Cerner:ADT_A34' create='new' language='objectscript' >
<code>
<![CDATA[ 
	//  Last Updated: 07/24/2020 Al Johnson
	//  Last Updated in Prod: 07/28/2020 Al Johnson
	//  Create: 11/11/2019  Al Johnson
	//
	//  Description:  New Interface - ADT Merge to Oberd
	//   Used to direct surveys for specific doctors and schedules
	//
	//  Demographic Spec for ADT shows PID and IN1
	//  Events A28 add, A29 delete, A31 update, A18 merge
	//
	//  Send Preferred Language in PID-15 01/30/2020
	//   Modobject in Cerner changed to send OBX with PREFERRED_LA  this value is aliased
	//   PID-15.1 is sent with aliased Primary Language
	//   PID-15.5 is unaliased (text) of Preferred Language
	//   SIU does not have OBX in Cerner schema so modobject sending text in PID-15.5
	//     Crosswalk to alias is Ensemble table T_Oberd_Language_Preferred
	//   ADT A34 Merge also does not have OBX segments - Oberd is taking language off each ADT and SIU
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
<assign value='"A18"' property='target.{MSH:9.2}' action='set' />

<assign value='source.{MRG}' property='target.{MRG}' action='set' />
<assign value='source.{MRG:1.1}' property='target.{MRG:1}' action='set' />

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

<assign value='tmpemail' property='target.{PID:13(1).4}' action='set' />

<code>
<![CDATA[
    // Send Prefferd Language
    //  **  off OBX PREFERRED_LA  (No OBX for MRG in schema)
    //  2. Crosswalk PID-15.5 preferred text to alias
    //  3. send primary language PID-15.1
]]></code>

<assign value='""' property='tmplang' action='set' />

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

<assign value='tmplang' property='target.{PID:15}' action='set' />

</transform>
}

}
