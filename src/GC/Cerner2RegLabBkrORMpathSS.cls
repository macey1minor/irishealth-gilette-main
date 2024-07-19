Class GC.Cerner2RegLabBkrORMpathSS Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ORM_O01' targetDocType='231.Cerner:ORM_O01' create='copy' language='objectscript' >
<subtransform class='GC.Cerner2RegLabBkrORMsub' targetObj='target' sourceObj='source' />
<code>
<![CDATA[ 
    //  Last Update: 02/21/2022 Al Johnson
    //  Last Moved to Prod: 03/24/2022 Al Johnson
	//  Create: 07/16/2018  Al Johnson
	//  Description:  Epic Beaker replaces Sunquest
	//  Outpatient ADT will be created off ORM in Epic
	//  Sunquest - GC.Cerner2RegLabORMgenlab schema 22.Reglab
	//  Beaker - schema 231.Cerner  Results back from Regions - Beaker use schema 251.Regions
	//	Uses subtransform CernerRegLabORMBkrSub
	//
	//  kept from sunquest
	//  change discontinued (DC) orders to Cancel orders (CA)
    //  Change ASAP Priority to DD for Discharage Dependant
    //  clear OBR:14 specimen received date/time
	//
    //  new
    //  update OBR:15.1.2 with type and OBR:15.4 with soure - no modifier defined
    //    if modifier sent, prefix source with modifer and a space
    //   OBX:3.1 = SPECIMENTYPE  (sunquest=sdes)
    //   OBX:3.1 = SPECIMENSOURCE (sunquest=site)
	//  Send OBX to Beaker as Cerner configured.  Do not convert to NTE
	//  Send Specimen, Modifier and Site in OBR-15
	//
	// Change OBX COMT to NTE segment
	//
	//  remove commas in obx-5 NM type 3/11/2019
	//  remove carriage return from obx-5 4/17/2019
	//
	//  OBX COMNT converted to NTE is not removing the carriage returns 4/24/2019
	//
	//  Order LABS20249 questions too long for Cerner 01/12/2021 SD-68975 RFC SD-69432
	//
	//  Additional Source Codes to extract - create table to store T_RegionsLab_AP_SpecSource 2/21/2022 SD-117053
	//   Remove obx if SPECIMENSOURCE else Do not remove obx segment when updating obr with source code RFC SD-120662
	//  Change OBX to NTE on specific codes for surgical pathology orders.  OBX codes are SPECDESC1, SPECDESC2,
	//            SPECDESC3, SPECDESC4 and SPECDESC5  5/3/2022 CE-3126
	//     Link SPECDESC1 - SPECDESC5 to corresponding OBX with 123100100, 101, 102, 104 and 105 (103 skipped)
]]></code>

<assign value='"Cerner2RegLabORMpath"' property='target.{MSH:8}' action='set' />

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

<assign value='""' property='target.{ORCgrp(1).OBRgrp.OBR:SpecimenSource}' action='clear' />

<code>
<![CDATA[ 
	// find last NTE segment
]]></code>
<assign value='"0"' property='holdNTEseq' action='set' />
<foreach property='source.{ORCgrp(1).OBRgrp.NTE()}' key='k4' >
<assign value='k4' property='holdNTEseq' action='set' />
</foreach>

<![CDATA[ 
	// find comment and site description in obx segments
	//  leave comment as OBX for now - may change to NTE
	// remove carriage return on NTE converted from OBX COMT - 04/24/2019
	// change of OBX to NTE for SPECDESC1 - 5, store index of specific OBX to tie it to
]]></code>
<assign value='""' property='holdcomment' action='set' />
<assign value='""' property='holdcommentdesc' action='set' />
<assign value='""' property='holdsdes' action='set' />
<assign value='""' property='holdsite' action='set' />
<assign value='""' property='holdsite1' action='set' />
<assign value='""' property='holdmodifier' action='set' />
<assign value='""' property='holdmodifierdesc' action='set' />
<assign value='""' property='holdntedes' action='set' />

<assign value='""' property='holdspecdesc1' action='set' />
<assign value='""' property='holdspecdesc2' action='set' />
<assign value='""' property='holdspecdesc3' action='set' />
<assign value='""' property='holdspecdesc4' action='set' />
<assign value='""' property='holdspecdesc5' action='set' />

<foreach property='source.{ORCgrp(1).OBRgrp.OBXgrp()}' key='k1' >
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1}="COMT"' >
<true>
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' property='holdcomment' action='set' />
<assign value='$REPLACE(holdcomment,"\.br\"," ")' property='holdcomment' action='set' />
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.2}' property='holdcommentdesc' action='set' />
<assign value='' property='target.{ORCgrp(1).OBRgrp.OBXgrp(k1)}' action='remove' />

<assign property='holdNTEseq' value='holdNTEseq+1' action='set' />
<assign value='holdNTEseq' property='target.{ORCgrp(1).OBRgrp.NTE(holdNTEseq):1}' action='set' />
<assign value='holdcomment' property='target.{ORCgrp(1).OBRgrp.NTE(holdNTEseq):3(1)}' action='set' />
<assign value='""' property='target.{ORCgrp(1).OBRgrp.NTE(holdNTEseq):4}' action='set' />
</true>
</if>
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1}="SPECIMENTYPE"' >
<true>
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' property='holdsdes' action='set' />
<assign value='' property='target.{ORCgrp(1).OBRgrp.OBXgrp(k1)}' action='remove' />
</true>
</if>
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1}="123100100"' >
<true>
<assign value='k1' property='holdspecdesc1' action='set' />
</true>
</if>
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1}="123100101"' >
<true>
<assign value='k1' property='holdspecdesc2' action='set' />
</true>
</if>
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1}="123100102"' >
<true>
<assign value='k1' property='holdspecdesc3' action='set' />
</true>
</if>
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1}="123100104"' >
<true>
<assign value='k1' property='holdspecdesc4' action='set' />
</true>
</if>
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1}="123100105"' >
<true>
<assign value='k1' property='holdspecdesc5' action='set' />
</true>
</if>
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1}="SPECDESC1"' >
<true>
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' property='holdntedes' action='set' />
<assign value="1" property='target.{ORCgrp(1).OBRgrp.OBXgrp(holdspecdesc1).NTE(1):1}' action='set' />
<assign value='""' property='target.{ORCgrp(1).OBRgrp.OBXgrp(holdspecdesc1).NTE(1):2}' action='set' />
<assign value='holdntedes' property='target.{ORCgrp(1).OBRgrp.OBXgrp(holdspecdesc1).NTE(1):3}' action='set' />
<assign value='""' property='target.{ORCgrp(1).OBRgrp.OBXgrp(holdspecdesc1).NTE(1):4}' action='set' />
<assign value='' property='target.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX}' action='remove' />
</true>
</if>
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1}="SPECDESC2"' >
<true>
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' property='holdntedes' action='set' />
<assign value="1" property='target.{ORCgrp(1).OBRgrp.OBXgrp(holdspecdesc2).NTE(1):1}' action='set' />
<assign value='""' property='target.{ORCgrp(1).OBRgrp.OBXgrp(holdspecdesc2).NTE(1):2}' action='set' />
<assign value='holdntedes' property='target.{ORCgrp(1).OBRgrp.OBXgrp(holdspecdesc2).NTE(1):3}' action='set' />
<assign value='""' property='target.{ORCgrp(1).OBRgrp.OBXgrp(holdspecdesc2).NTE(1):4}' action='set' />
<assign value='' property='target.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX}' action='remove' />
</true>
</if>
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1}="SPECDESC3"' >
<true>
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' property='holdntedes' action='set' />
<assign value="1" property='target.{ORCgrp(1).OBRgrp.OBXgrp(holdspecdesc3).NTE(1):1}' action='set' />
<assign value='""' property='target.{ORCgrp(1).OBRgrp.OBXgrp(holdspecdesc3).NTE(1):2}' action='set' />
<assign value='holdntedes' property='target.{ORCgrp(1).OBRgrp.OBXgrp(holdspecdesc3).NTE(1):3}' action='set' />
<assign value='""' property='target.{ORCgrp(1).OBRgrp.OBXgrp(holdspecdesc3).NTE(1):4}' action='set' />
<assign value='' property='target.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX}' action='remove' />
</true>
</if>
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1}="SPECDESC4"' >
<true>
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' property='holdntedes' action='set' />
<assign value="1" property='target.{ORCgrp(1).OBRgrp.OBXgrp(holdspecdesc4).NTE(1):1}' action='set' />
<assign value='""' property='target.{ORCgrp(1).OBRgrp.OBXgrp(holdspecdesc4).NTE(1):2}' action='set' />
<assign value='holdntedes' property='target.{ORCgrp(1).OBRgrp.OBXgrp(holdspecdesc4).NTE(1):3}' action='set' />
<assign value='""' property='target.{ORCgrp(1).OBRgrp.OBXgrp(holdspecdesc4).NTE(1):4}' action='set' />
<assign value='' property='target.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX}' action='remove' />
</true>
</if>
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1}="SPECDESC5"' >
<true>
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' property='holdntedes' action='set' />
<assign value="1" property='target.{ORCgrp(1).OBRgrp.OBXgrp(holdspecdesc5).NTE(1):1}' action='set' />
<assign value='""' property='target.{ORCgrp(1).OBRgrp.OBXgrp(holdspecdesc5).NTE(1):2}' action='set' />
<assign value='holdntedes' property='target.{ORCgrp(1).OBRgrp.OBXgrp(holdspecdesc5).NTE(1):3}' action='set' />
<assign value='""' property='target.{ORCgrp(1).OBRgrp.OBXgrp(holdspecdesc5).NTE(1):4}' action='set' />
<assign value='' property='target.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX}' action='remove' />
</true>
</if>
<code>
<![CDATA[ 

<code>
<![CDATA[ 
	// find comment and site description in obx segments
	//  leave comment as OBX for now - may change to NTE
	// remove carriage return on NTE converted from OBX COMT - 04/24/2019
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
<assign value='$REPLACE(holdcomment,"\.br\"," ")' property='holdcomment' action='set' />
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.2}' property='holdcommentdesc' action='set' />
<assign value='' property='target.{ORCgrp(1).OBRgrp.OBXgrp(k1)}' action='remove' />

<assign property='holdNTEseq' value='holdNTEseq+1' action='set' />
<assign value='holdNTEseq' property='target.{ORCgrp(1).OBRgrp.NTE(holdNTEseq):1}' action='set' />
<assign value='holdcomment' property='target.{ORCgrp(1).OBRgrp.NTE(holdNTEseq):3(1)}' action='set' />
<assign value='""' property='target.{ORCgrp(1).OBRgrp.NTE(holdNTEseq):4}' action='set' />
</true>
</if>
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1}="SPECIMENTYPE"' >
<true>
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' property='holdsdes' action='set' />
<assign value='' property='target.{ORCgrp(1).OBRgrp.OBXgrp(k1)}' action='remove' />
</true>
</if>

<code>
<![CDATA[ 
	// specimen source change from if statement to table read T_RegionsLab_AP_SpecSource 2/21/2022
	//  remove if 'specimensource' else leave obx
]]></code>
<assign value='""' property='wtblAPsourceresult' action='set' />
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1}' property='wtblAPsourcekey' action='set' />

<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1}="SPECIMENSOURCE"' >
<true>
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' property='holdsite' action='set' />
<assign value='' property='target.{ORCgrp(1).OBRgrp.OBXgrp(k1)}' action='remove' />
</true>
<false>
<assign value='..Lookup("T_RegionsLab_AP_SpecSource",wtblAPsourcekey)' property='wtblAPsourceresult' action='set' />
<if condition='wtblAPsourceresult=""' >
<false>
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' property='holdsite' action='set' />
</false>
</if>
</false>
</if>

<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1} = "123102802"' >
<true>
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5} = "HPVHISTORY"' >
<true>
<assign value='"History of Cervical, Vaginal, or Vulvar CANCER with plan for HPV surveillance PER GYNECOLOGIC ONCOLOGY"' property='tmpanswer' action='set' />
<assign value='tmpanswer' property='target.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' action='set' />
</true>
</if>
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5} = "HPVABNORMAL"' >
<true>
<assign value='"Prior abnormal vaginal pap meriting recheck PER CCSM as based on expert opinion"' property='tmpanswer' action='set' />
<assign value='tmpanswer' property='target.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' action='set' />
</true>
</if>
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5} = "HPV25YEARS"' >
<true>
<assign value='"History of CIN 2, CIN 3 or AIS in the preceding 25 years"' property='tmpanswer' action='set' />
<assign value='tmpanswer' property='target.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' action='set' />
</true>
</if>
</true>
</if>

</foreach>

<code>
<![CDATA[ 
	//    leave NTE for now
	//    <assign value='""' property='target.{ORCgrp(1).OBRgrp.NTE(1)}' action='remove' />
]]></code>
<assign value='' property='target.{ORCgrp(1).OBRgrp.OBR:SpecimenReceivedDateTime}' action='clear' />
  
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
	// renumber OBX segments in case some were removed
	// remove commas from NM type 3/11/2019
	// remove carriage return from OBX-5 4/17/2019
]]></code>

<foreach property='target.{ORCgrp()}' key='k2' >
<assign value='""' property='holdobxseq' action='set' />
<foreach property='target.{ORCgrp(k2).OBRgrp.OBXgrp()}' key='k3' >
<assign property='holdobxseq' value='holdobxseq+1' action='set' />
<assign value='holdobxseq' property='target.{ORCgrp(k2).OBRgrp.OBXgrp(k3).OBX:SetIDOBX}' action='set' />
<if condition='..In(target.{ORCgrp(k2).OBRgrp.OBXgrp(k3).OBX:2},"NM")' >
<true>
<assign value='target.{ORCgrp(k2).OBRgrp.OBXgrp(k3).OBX:5(1)}' property='holdobx5' action='set' />
<assign value='$ZSTRIP(holdobx5,"*",",")' property='holdobx5a' action='set' />
<assign value='holdobx5a' property='target.{ORCgrp(k2).OBRgrp.OBXgrp(k3).OBX:5(1)}' action='set' />
</true>
</if>
<assign value='target.{ORCgrp(k2).OBRgrp.OBXgrp(k3).OBX:5(1)}' property='holdobx5b' action='set' />
<assign value='$REPLACE(holdobx5b,"\.br\"," ")' property='holdobx5b' action='set' />
<assign value='holdobx5b' property='target.{ORCgrp(k2).OBRgrp.OBXgrp(k3).OBX:5(1)}' action='set' />
</foreach>
</foreach>

</transform>
}

}
