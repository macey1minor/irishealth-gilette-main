Class GC.Cerner2RegLabBkrORMmicro Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ORM_O01' targetDocType='231.Cerner:ORM_O01' create='copy' language='objectscript' >
<subtransform class='GC.Cerner2RegLabBkrORMsub' targetObj='target' sourceObj='source' />
<code>
<![CDATA[ 
	//  Last Updated 03/28/2022
	//  Last Updated in Prod: 03/29/2022 Al Johnson
	//  Create: 11/02/2018  Al Johnson 
	//  Description:  Epic Beaker replaces Sunquest
	//  Outpatient ADT will be created off ORM in Epic
	//  Sunquest - GC.Cerner2RegLabORMgenlab schema 22.Reglab
	//  Beaker - schema 231.Cerner  Results back from Regions - Beaker use schema 251.Regions
	//	Uses subtransform CernerRegLabORMBkrSub
	//
	//  kept from sunquest
    //  change discontinued (DC) orders to Cancel orders (CA)
    //  Change ASAP Priority to DD for Discharage Dependant
    //  create NTE from OBX:3.1 COMT
    //  remove all OBX segments
    //  shift PID to uppercase
    //
    //  new
    //  update OBR:15.1.2 with type and OBR:15.4 with soure - no modifier defined
    //    if modifier sent, prefix source with modifer and a space
    //   OBX:3.1 = SPECIMENTYPE  (sunquest=sdes)
    //   OBX:3.1 = SPECIMENSOURCE (sunquest=site)
    //
    //  Future Order release logic obr-27.4 out of Cerner has wrong date/time 3/28/2022 SD-120953 RFC SD-121184
    //
]]></code>

<code>
<![CDATA[
     // On NW new orders, that are OBR-27.6 RO routine and scheduled OBR-27.4 for 030000
     //  Move ORC-15 order effective date/time to OBR-27.4 timing start date/time
     //  Cerner sending orders out with date/time order was placed (i.e. followup orders, surgical orders) 11/5/2021
     // new logic 3/22/2022
]]></code>
<assign value='$EXTRACT(target.{ORCgrp(1).OBRgrp.OBR:27(1).4},9,14)' property='tobr27time' action='set' />
<if condition='(target.{ORCgrp(1).ORC:1}="NW")&amp;(tobr27time="030000")&amp;(target.{ORCgrp(1).OBRgrp.OBR:27(1).6}="RO")' >
<true>
<if condition='..In(target.{PV1:18},"Day Surgery,Outpatient,Outpatient in a Bed,Recurring,Virtual Care")' >
<true>
<assign value='target.{ORCgrp(1).ORC:15.1}' property='target.{ORCgrp(1).OBRgrp.OBR:27(1).4}' action='set' />
</true>
<false>
<if condition='(target.{PV1:2}="I")&amp;((target.{PV1:3.1}="GCSH Periop")||(target.{PV1:3.1}="GOR"))' >
<true>
<assign value='target.{ORCgrp(1).ORC:15.1}' property='target.{ORCgrp(1).OBRgrp.OBR:27(1).4}' action='set' />
</true>
</if>
</false>
</if>
</true>
</if>

<assign value='"Cerner2RegLabMicro"' property='target.{MSH:8}' action='set' />
<code>
<![CDATA[ 
	// ***************************** START ORDER LOGIC ********************************
    // kept from orig sunquest logic
    // change discontinued (DC) orders to Cancel orders (CA)
    // Change ASAP Priority to DD for Discharage Dependant
    // Clear Specimen Source
]]></code>
<if condition='..Contains(source.{ORCgrp(1).ORC:OrderControl},"DC")' >
<true>
<assign value='"CA"' property='target.{ORCgrp(1).ORC:OrderControl}' action='set' />
</true>
</if>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBR:QuantityTiming(1).priority},"ASAP")' >
<true>
<assign value='"DD"' property='target.{ORCgrp(1).OBRgrp.OBR:QuantityTiming(1).priority}' action='set' />
</true>
</if>
<code>
<![CDATA[  	// *****************************  OBX LOGIC ********************************
]]></code>
<code>
<![CDATA[ 
	// find comment and site description in obx segments
]]></code>
<assign value='""' property='holdcomment' action='set' />
<assign value='""' property='holdcommentdesc' action='set' />
<assign value='""' property='holdsdes' action='set' />
<assign value='""' property='holdsite' action='set' />
<assign value='""' property='holdsite1' action='set' />
<assign value='""' property='holdmodifier' action='set' />
<assign value='""' property='holdmodifierdesc' action='set' />
<foreach property='source.{ORCgrp(1).OBRgrp.OBXgrp()}' key='k1' >
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1}="COMT"' >
<true>
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' property='holdcomment' action='set' />
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.2}' property='holdcommentdesc' action='set' />
</true>
</if>
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1}="SPECIMENTYPE"' >
<true>
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' property='holdsdes' action='set' />
</true>
</if>
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1}="SPECIMENSOURCE"' >
<true>
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' property='holdsite' action='set' />
</true>
</if>
</foreach>

<code>
<![CDATA[     // *************************** Remove OBX from output OBX
]]></code>
<foreach property='target.{ORCgrp(1).OBRgrp.OBXgrp()}' key='k1' >
<assign value='' property='target.{ORCgrp(1).OBRgrp.OBXgrp(k1)}' action='remove' />
</foreach>

<code>
<![CDATA[  
    // create OBR-15 specimen, modifier and site
]]></code>
<assign value='""' property='target.{ORCgrp(1).OBRgrp.OBR:SpecimenSource}' action='clear' />
<assign value='holdsdes' property='target.{ORCgrp(1).OBRgrp.OBR:15.1.2}' action='set' />
<if condition='($LENGTH(holdmodifier) &lt; 1)' >
<true>
<assign value='holdsite' property='target.{ORCgrp(1).OBRgrp.OBR:SpecimenSource.bodysite}' action='set' />
</true>
<false>
<assign value='holdmodifier_" "_holdsite' property='target.{ORCgrp(1).OBRgrp.OBR:SpecimenSource.bodysite}' action='set' />
</false>
</if>

<code>
<![CDATA[
     // Create NTERemove blank NTE
]]></code>
<if condition='($LENGTH(holdcomment) &lt; 1)' >
<false>
<assign value='"1"' property='target.{ORCgrp(1).OBRgrp.NTE(1):1}' action='set' />
<assign value='holdcommentdesc' property='target.{ORCgrp(1).OBRgrp.NTE(1):2}' action='set' />
<assign value='holdcomment' property='target.{ORCgrp(1).OBRgrp.NTE(1):3(1)}' action='set' />
</false>
</if>
<assign value='$ZCONVERT(target.{PID},"U" )' property='target.{PID}' action='set' />
</transform>
}

}
