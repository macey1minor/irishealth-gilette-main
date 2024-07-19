Class GC.RegLab2CernerBkrORUGenlab Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='251.Regions:ORU_R01' targetDocType='251.Regions:ORU_R01' create='copy' language='objectscript' >
<code>
<![CDATA[ 
	//  Last Update: 12/06/2021 Al Johnson
	//  Last Moved to Prod:  12/06/2021 Al Johnson
    //  Created 08/20/2018 Al Johnson
    //
    //  Beaker version - schema changed from 22.RegLab to 231.Cerner
    //   Changed to version 251.Regions 10/15/2018
    //
    //   Check for OBX subtype FT FreeText
    //    If tied to previous OBX change to NTE segment
    //    If standalone change to subtype RC
    //  Populate OBR-22 with MSH-7 datetime of message 03/23/2017
    //  Populate OBR-27.4 with MSH-7 datetime of message 03/23/2017
    //  Schema changed so NTE segment is repeating - add index for NTE under OBX 04/17/2017
    //  Check table T_RegionsLab_OrderingProvider for a change in ordering provider 11/22/2017
    //  Change result message to table ordering provider 11/22/2017
    //  Update table with result date 11/22/2017
    //  Consolidate consecutive OBX segments for CSFD 01/02/2018
    //  Change OBX=2 SN (structured numeric) to ST (string) consolidate result value OBX-5.1 and 5.2 9/28/2018
    //  Beaker sends parent id in OBR-4.1 and individual items in OBX-3.1 (sunquest was .2) 9/28/2018
    //
    //  Beaker sending OBX-2 type of CWE, Regions truncating to CW - change to CE
    //
    //  Results for 123007300 or 123007301 will almost always be resulted with a comment and not a numeric
    //   in that case nm and blank - change nte to obx
    //
    //  for OBX-3.1 values of PROD_CD, UNIT_ID, PROD_STAT, EXP_DTTM, BLOOD_TYPE_BARCODE 02/19/2019
    //  prefix with the orderable from OBR-4.1 and an underscore 02/19/2019
    //  Change OBX type TX to ST on Blood Products 02/19/2019
    //
    //  Beaker is sending the same alias for total volume on genlab and sendout
    //  Change on genlab from 123003048 to G123003048  03/18/2019
    //  Change on genlab from 123002092 to G123002092  03/25/2019
    //
    //  read Table = T_RegionsLab_OrderedConversion -if on table update OBR-4.2 with original value 4/19/2019
    //
    //  Remap specific OBX results on CG8 ^ Blood Gas, Poct for specimen sites Venous and Arterial - CNR-20438 RFC SD-48926 7/9/2020
    //
    //  Check for Unsolicited Covid19 result from Regions - add NTE line - SD-48732 RFC SD-48883 7/13/2020
    //
    //  Check for Unsolicited Covid19 result from Regions (LAB1482 same as orig LAB1477) - add NTE line - CNR-20524 7/22/2020 RFC SD-50386
    //
    //  Add OBX-3.1 UNIT_VOLUME to Blood Product logic from 2/19/2019 SD-61446 RFC SD-61956
    //
    //  Add EP2048 Check for unsolicited COVID result - add note 12/06/2021 RFC SD-108101
]]></code>
<code>
<![CDATA[ 
    //  Update FreeText OBX as ST or NTE segment
    //  01/02/2018 cosolidate CSFD OBX segments
    //             Also consolidate if CE followed by FT for CSFD
    //  07/09/2020 set switches for CG8-Venous and CG8-Arterial
]]></code>

<foreach property='target.{PIDgrpgrp(1).ORCgrp()}' key='k2' >
<assign value='source.{MSH:DateTimeOfMessage.Time}' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBR:22}' action='set' />
<assign value='source.{MSH:DateTimeOfMessage.Time}' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBR:27.4}' action='set' />
<assign value='0' property='tmpnte' action='set' />
<assign value='""' property='HldOBXval1' action='set' />
<assign value='""' property='HldOBXval2' action='set' />
<assign value='""' property='tmpCG8' action='set' />
<assign value='""' property='tmpCG8obx' action='set' />

<if condition='target.{PIDgrpgrp(1).ORCgrp(k2).OBR:4.1}="CG8"' >
<true>
<assign value='"X"' property='tmpCG8' action='set' />
</true>
</if>

<foreach property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp()}' key='k1' >
<if condition='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:ValueType}="FT"' >
<true>
<if condition='k1="1"' >
<true>
<assign value='"ST"' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:ValueType}' action='set' />
</true>
<false>
<if condition='(target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:SetIDOBX})=(target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1-1).OBX:SetIDOBX})' >
<true>
<assign value='tmpnte+1' property='tmpnte' action='set' />
<assign value='' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1)}' action='remove' />
<assign value='source.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:SetIDOBX}' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).NTE(tmpnte):SetIDNTE}' action='set' />
<assign value='"RC"' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).NTE(tmpnte):SourceofComment}' action='set' />
<assign value='source.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:ObservationValue(1)}' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).NTE(tmpnte):Comment(1)}' action='set' />
</true>
<false>
<assign value='"ST"' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:ValueType}' action='set' />
</false>
</if>
</false>
</if>
</true>
<false>
<code>
<![CDATA[ 
    //  09/28/2018 change SN to ST consolidate OBX-5.1 and 5.2 values
]]></code>
<if condition='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:ValueType}="SN"' >
<true>
<assign value='"ST"' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:ValueType}' action='set' />
<assign value='""' property='hold51' action='set' />
<assign value='""' property='hold52' action='set' />
<assign value='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:5(1).1}' property='hold51' action='set' />
<assign value='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:5(1).2}' property='hold52' action='set' />
<assign value='hold51_hold52' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:5(1)}' action='set' />
</true>
<false>
<if condition='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:ValueType}="CW"' >
<true>
<assign value='"CE"' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:ValueType}' action='set' />
</true>
</if>
</false>
</if>
<code>
<![CDATA[ 
    //  01/02/2018 consolidate consecutive CSFD even if CE followed by FT
]]></code>
<if condition='(target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:3.2}="CSFD") &amp; (target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1+1).OBX:3.2}="CSFD")' >
<true>
<assign value='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:5(1)}' property='HldOBXval1' action='set' />
<assign value='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1+1).OBX:5(1)}' property='HldOBXval2' action='set' />
<assign value='HldOBXval1_" "_HldOBXval2' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:5}' action='set' />
<assign value='' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1+1).OBX}' action='remove' />
</true>
</if>
</false>
</if>
<code>
<![CDATA[ 
    //  10/30/2018 check for 123007300 or 123007301 followed by NTE
]]></code>
<if condition='(target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:3.1}="123007300")||(target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:3.1}="123007301")' >
<true>
<if condition='(target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:5(1)}="")' >
<true>
<if condition='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).NTE(1):3(1)}=""' >
<false>
<assign value='"ST"' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:ValueType}' action='set' />
<assign value='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).NTE(1):3(1)}' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:5(1)}' action='set' />
<assign value='' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).NTE(1)}' action='remove' />
</false>
</if>
</true>
</if>
</true>
</if>
<code>
<![CDATA[ 
    //  02/19/2019 for OBX-3.1 values of PROD_CD, UNIT_ID, PROD_STAT, EXP_DTTM, BLOOD_TYPE_BARCODE
    //  02/19/2019 prefix with the orderable from OBR-4.1 and an underscore
]]></code>
<if condition='..In(target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:3.1},"PROD_CD,UNIT_ID,PROD_STAT,EXP_DTTM,BLOOD_TYPE_BARCODE,UNIT_VOLUME")' >
<true>
<assign value='target.{PIDgrpgrp(1).ORCgrp(k2).OBR:4.1}' property='hldobr4' action='set' />
<assign value='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:3.1}' property='hldobx3' action='set' />
<assign value='hldobr4_"_"_hldobx3' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:3.1}' action='set' />
<if condition='(target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:2}="TX")' >
<true>
<assign value='"ST"' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:2}' action='set' />
</true>
</if>
</true>
</if>

<code>
<![CDATA[ 
    //  03/18/2019 for OBX-3.1 Genlab value of 123003048 change to G123003048
    //  03/25/2019 for OBX-3.1 Genlab value of 123002092 change to G123002092
 ]]></code>
<if condition='(target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:3.1}="123003048")' >
<true>
<assign value='"G123003048"' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:3.1}' action='set' />
</true>
</if>
<if condition='(target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:3.1}="123002092")' >
<true>
<assign value='"G123002092"' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:3.1}' action='set' />
</true>
</if>

<code>
<![CDATA[ 
    //  07/09/2020 set CG8 Venous/Arterial switch
 ]]></code>
 <if condition='(target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:5}="Arterial")' >
<true>
<assign value='"A"' property='tmpCG8obx' action='set' />
</true>
<false>
<if condition='(target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:5}="Venous")' >
<true>
<assign value='"V"' property='tmpCG8obx' action='set' />
</true>
</if>
</false>
</if>

</foreach>
</foreach>

<code>
<![CDATA[ 
    //  07/09/2020 change specific obx segments for CG8 Venous/Arterial
 ]]></code>
 <if condition='tmpCG8="X"' >
 <true>
 <foreach property='target.{PIDgrpgrp(1).ORCgrp()}' key='k5' >
<foreach property='target.{PIDgrpgrp(1).ORCgrp(k5).OBXgrp()}' key='k6' >
<if condition='tmpCG8obx="A"' >
<true>
<if condition='target.{PIDgrpgrp(1).ORCgrp(k5).OBXgrp(k6).OBX:3.1}="123002472"' >
<true>
<assign value='"123003331"' property='target.{PIDgrpgrp(1).ORCgrp(k5).OBXgrp(k6).OBX:3.1}' action='set' />
</true>
</if>
</true>
<false>
<if condition='tmpCG8obx="V"' >
<true>
<if condition='target.{PIDgrpgrp(1).ORCgrp(k5).OBXgrp(k6).OBX:3.1}="123002472"' >
<true>
<assign value='"123002966"' property='target.{PIDgrpgrp(1).ORCgrp(k5).OBXgrp(k6).OBX:3.1}' action='set' />
</true>
</if>
<if condition='target.{PIDgrpgrp(1).ORCgrp(k5).OBXgrp(k6).OBX:3.1}="123002987"' >
<true>
<assign value='"123002974"' property='target.{PIDgrpgrp(1).ORCgrp(k5).OBXgrp(k6).OBX:3.1}' action='set' />
</true>
</if>
<if condition='target.{PIDgrpgrp(1).ORCgrp(k5).OBXgrp(k6).OBX:3.1}="123002988"' >
<true>
<assign value='"123002975"' property='target.{PIDgrpgrp(1).ORCgrp(k5).OBXgrp(k6).OBX:3.1}' action='set' />
</true>
</if>
<if condition='target.{PIDgrpgrp(1).ORCgrp(k5).OBXgrp(k6).OBX:3.1}="123002989"' >
<true>
<assign value='"123002976"' property='target.{PIDgrpgrp(1).ORCgrp(k5).OBXgrp(k6).OBX:3.1}' action='set' />
</true>
</if>
<if condition='target.{PIDgrpgrp(1).ORCgrp(k5).OBXgrp(k6).OBX:3.1}="123002468"' >
<true>
<assign value='"123002467"' property='target.{PIDgrpgrp(1).ORCgrp(k5).OBXgrp(k6).OBX:3.1}' action='set' />
</true>
</if>
</true>
</if>
</false>
</if>

</foreach>
</foreach>
</true>
</if>

<code>
<![CDATA[ 
    //  Check for unsolicited COVID result - add note 07/13/2020
    //  Add EP2048 to unsolicted COVID results - 12/06/2021
]]></code>
<assign value='"Patients Epic medical record is source system for this result.  Please call lab with any questions."' property='tmpcovidnte' action='set' />
<assign value='source.{PIDgrpgrp(1).ORCgrp(1).OBR:2.1}' property='tempCernerOrdCovid' action='set' />
<assign value='source.{PIDgrpgrp(1).ORCgrp(1).OBR:3.1}' property='tempRegionsOrdCovid' action='set' />
<assign value='source.{PIDgrpgrp(1).ORCgrp(1).OBR:4.1}' property='tmpcovidtest' action='set' />
<if condition='(tmpcovidtest="LAB1477") || (tmpcovidtest="LAB1482") || (tmpcovidtest="EP2048")' >
<true>
<if condition='(tempCernerOrdCovid = tempRegionsOrdCovid)||(tempCernerOrdCovid = "")' >
<true>
<assign value='(target.{PIDgrpgrp(1).ORCgrp(1).NTE(*)}+1)' property='NewNTE' action='set' />
<assign value='NewNTE' property='target.{PIDgrpgrp(1).ORCgrp(1).NTE(NewNTE):1}' action='set' />
<assign value='"L"' property='target.{PIDgrpgrp(1).ORCgrp(1).NTE(NewNTE):2}' action='set' />
<assign value='tmpcovidnte' property='target.{PIDgrpgrp(1).ORCgrp(1).NTE(NewNTE):3}' action='set' />
</true>
</if>
</true>
</if>

<code>
<![CDATA[ 
    //  Check table T_RegionsLab_OrderingProvider for a change in ordering provider
    //  Change result message to table ordering provider
]]></code>
<assign value='source.{PIDgrpgrp(1).ORCgrp(1).OBR:2.1}' property='tempCernerOrder' action='set' />
<assign value='source.{PIDgrpgrp(1).ORCgrp(1).ORC:12(1)}' property='tempORC12' action='set' />
<assign value='source.{PIDgrpgrp(1).ORCgrp(1).OBR:16(1)}' property='tempOBR16' action='set' />
<assign value='source.{PIDgrpgrp(1).ORCgrp(1).ORC:12(1).1}' property='tempInORC12id' action='set' />
<assign value='source.{PIDgrpgrp(1).ORCgrp(1).OBR:16(1).1}' property='tempInOBR16id' action='set' />
<assign value='""' property='tempDateResult' action='set' />
<assign value='""' property='tempDateCancel' action='set' />
<assign value='tempCernerOrder' property='wTableKey' action='set' />
<assign value='""' property='wTableData' action='set' />
<assign value='""' property='wtableresult' action='set' />
<assign value='..Lookup("T_RegionsLab_OrderingProvider",wTableKey)' property='wtableresult' action='set' />
<if condition='wtableresult=""' >
<true>
<code>
<![CDATA[ 
    // no entry found - so send to Cerner as received
]]></code>
</true>
<false>
<code>
<![CDATA[ 
    // table entry found - change ordering doc in message
]]></code>
<assign value='$PIECE(wtableresult,"|",1)' property='temptblORC12' action='set' />
<assign value='$PIECE(temptblORC12,"^",1)' property='temptblORC12id' action='set' />
<assign value='$PIECE(wtableresult,"|",2)' property='temptblOBR16' action='set' />
<assign value='$PIECE(temptblOBR16,"^",1)' property='temptblOBR16id' action='set' />
<assign value='$PIECE(wtableresult,"|",3)' property='temptblDateAdd' action='set' />
<assign value='$PIECE(wtableresult,"|",4)' property='temptblDateResult' action='set' />
<assign value='$PIECE(wtableresult,"|",5)' property='temptblDateCancel' action='set' />
<assign value='$ZDATE($NOW(),8)' property='tempDateResult' action='set' />
<code>
<![CDATA[ 
    // result from Regions - update table with result date
        set wTableData=(temptblORC12_"|"_temptblOBR16_"|"_temptblDateAdd_"|"_tempDateResult_"|"_temptblDateCancel_"|") 
        set wTableName="T_RegionsLab_OrderingProvider"
        do ##class(Ens.Util.LookupTable).%UpdateValue(wTableName,wTableKey,wTableData)	
]]></code>
<if condition='(tempInORC12id = temptblORC12id)&amp;(tempInOBR16id = temptblOBR16id)' >
<false>
<code>
<![CDATA[ 
    // ordering doc on table differs from regions hl7 message
    //  update hl7 message
    //
    //  if multiple orc do fornext to updated each orc/obr
]]></code>
<foreach property='target.{PIDgrpgrp(1).ORCgrp()}' key='k3' >
<assign value='temptblORC12' property='target.{PIDgrpgrp(1).ORCgrp(k3).ORC:12(1)}' action='set' />
<assign value='temptblOBR16' property='target.{PIDgrpgrp(1).ORCgrp(k3).OBR:16(1)}' action='set' />
</foreach>
</false>
</if>
</false>
</if>

<code>
<![CDATA[ 
    //  Check table T_RegionsLab_OrderedConversion for a change in original orderable
    //  Change result message to table value
]]></code>

<foreach property='target.{PIDgrpgrp(1).ORCgrp()}' key='k4' >
<assign value='target.{PIDgrpgrp(1).ORCgrp(k4).OBR:2.1}' property='wTableKeyOrdered' action='set' />
<assign value='""' property='wtableresultordered' action='set' />
<assign value='..Lookup("T_RegionsLab_OrderedConversion",wTableKeyOrdered)' property='wtableresultordered' action='set' />
<if condition='wtableresultordered=""' >
<true>
<code>
<![CDATA[ 
    // no entry found - so send to Cerner as received
]]></code>
</true>
<false>
<code>
<![CDATA[ 
    // table entry found - change ordered in message
]]></code>
<assign value='wtableresultordered' property='target.{PIDgrpgrp(1).ORCgrp(k4).OBR:4.1}' action='set' />
</false>
</if>
</foreach>

</transform>
}

}
