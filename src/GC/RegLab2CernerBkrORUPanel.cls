Class GC.RegLab2CernerBkrORUPanel Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='251.Regions:ORU_R01' targetDocType='251.Regions:ORU_R01' create='new' language='objectscript' >
<code>
<![CDATA[ 
	//  Last Update: 12/30/2020 Al Johnson
	//  Last Moved to Prod:  01/07/2021 Al Johnson
    //  Created 03/06/2019 Al Johnson
    //
    //  Ensemble rule should only pass in if a value in OBR-50
    //  Go ahead and check for it anyway
    //
    //  Create ORU result on parent / panel
    //  Change OBR:4.1 to OBR:50.1
    //  Add OBX segment, type ST with verbiage in OBX-5
    //  Send thru MSH, PID, PV1, ORC and OBR
    //
    //  Check table T_RegionsLab_OrderingProvider for a change in ordering provider 11/22/2017
    //  Change result message to table ordering provider
    //
    //  Create OBX for specific tests EP2032, EP2018, EP2014 3/11/2019
    //  Create OBX for specific tests EP2029, EP2022, EP2021 3/26/2019
    //  Create OBX for specific tests EP2003, BFT, CSFT, EP2019, HEMPL 3/28/2019
    //  Create OBX for specific tests CTBAL 4/17/2019
    //  Create OBX for specific tests EP1019 4/21/2020
    //  Create OBX for specific tests EP2031 10/19/2020 SD-59574 RFC SD-59652
    //  Create OBX for specific tests EP2049 12/30/2020 SD-67403 RFC SD-68045
]]></code>

<assign value='source.{MSH}' property='target.{MSH}' action='set' />
<assign value='source.{PIDgrpgrp(1).PIDgrp.PID}' property='target.{PIDgrpgrp(1).PIDgrp.PID}' action='set' />
<assign value='source.{PIDgrpgrp(1).PIDgrp.PV1grp.PV1}' property='target.{PIDgrpgrp(1).PIDgrp.PV1grp.PV1}' action='set' />
<assign value='source.{PIDgrpgrp(1).ORCgrp(1).ORC}' property='target.{PIDgrpgrp(1).ORCgrp(1).ORC}' action='set' />
<assign value='source.{PIDgrpgrp(1).ORCgrp(1).OBR}' property='target.{PIDgrpgrp(1).ORCgrp(1).OBR}' action='set' />

<foreach property='target.{PIDgrpgrp(1).ORCgrp()}' key='k1' >
<if condition='target.{PIDgrpgrp(1).ORCgrp(k1).OBR:50.1}=""' >
<false>
<if condition='target.{PIDgrpgrp(1).ORCgrp(k1).OBR:4.1}=target.{PIDgrpgrp(1).ORCgrp(k1).OBR:50.1}' >
<false>
<assign value='target.{PIDgrpgrp(1).ORCgrp(k1).OBR:50.1}' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBR:4.1}' action='set' />
<assign value='""' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBR:3}' action='set' />

<if condition='target.{PIDgrpgrp(1).ORCgrp(k1).OBR:50.1}="EP2032"' >
<true>
<assign value='"1"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:1}' action='set' />
<assign value='"ST"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:2}' action='set' />
<assign value='"TYHDRESULT"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:3.1}' action='set' />
<assign value='"Please see Results Review for Ab Screen, RH (D) Type and ABO Type results"' property='tmpdesc' action='set' />
<assign value='tmpdesc' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:5(1)}' action='set' />
</true>
</if>

<if condition='target.{PIDgrpgrp(1).ORCgrp(k1).OBR:50.1}="EP2018"' >
<true>
<assign value='"1"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:1}' action='set' />
<assign value='"ST"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:2}' action='set' />
<assign value='"EP2018RESULT"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:3.1}' action='set' />
<assign value='"Please see Results Review for Aerobic and Anaerobic Culture reports"' property='tmpdesc' action='set' />
<assign value='tmpdesc' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:5(1)}' action='set' />
</true>
</if>

<if condition='target.{PIDgrpgrp(1).ORCgrp(k1).OBR:50.1}="EP2014"' >
<true>
<assign value='"1"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:1}' action='set' />
<assign value='"ST"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:2}' action='set' />
<assign value='"EP2014RESULT"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:3.1}' action='set' />
<assign value='"Please see Results Review for Extended Aerobic and Anaerobic Culture reports"' property='tmpdesc' action='set' />
<assign value='tmpdesc' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:5(1)}' action='set' />
</true>
</if>

<if condition='target.{PIDgrpgrp(1).ORCgrp(k1).OBR:50.1}="EP2029"' >
<true>
<assign value='"1"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:1}' action='set' />
<assign value='"ST"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:2}' action='set' />
<assign value='"EP2029RESULT"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:3.1}' action='set' />
<assign value='"Please see Results Review for Tuberculin Culture Panel reports"' property='tmpdesc' action='set' />
<assign value='tmpdesc' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:5(1)}' action='set' />
</true>
</if>

<if condition='target.{PIDgrpgrp(1).ORCgrp(k1).OBR:50.1}="EP2022"' >
<true>
<assign value='"1"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:1}' action='set' />
<assign value='"ST"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:2}' action='set' />
<assign value='"EP2022RESULT"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:3.1}' action='set' />
<assign value='"Please see Results Review for Enteric Stool Pathogens Panel reports"' property='tmpdesc' action='set' />
<assign value='tmpdesc' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:5(1)}' action='set' />
</true>
</if>

<if condition='target.{PIDgrpgrp(1).ORCgrp(k1).OBR:50.1}="EP2021"' >
<true>
<assign value='"1"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:1}' action='set' />
<assign value='"ST"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:2}' action='set' />
<assign value='"EP2021RESULT"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:3.1}' action='set' />
<assign value='"Please see Results Review for Blood Culture and Molecular Blood Culture Identification reports"' property='tmpdesc' action='set' />
<assign value='tmpdesc' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:5(1)}' action='set' />
</true>
</if>

<if condition='target.{PIDgrpgrp(1).ORCgrp(k1).OBR:50.1}="EP2003"' >
<true>
<assign value='"1"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:1}' action='set' />
<assign value='"ST"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:2}' action='set' />
<assign value='"EP2003RESULT"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:3.1}' action='set' />
<assign value='"Please see Results Review for Cortisol Baseline and Post results"' property='tmpdesc' action='set' />
<assign value='tmpdesc' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:5(1)}' action='set' />
</true>
</if>

<if condition='target.{PIDgrpgrp(1).ORCgrp(k1).OBR:50.1}="BFT"' >
<true>
<assign value='"1"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:1}' action='set' />
<assign value='"ST"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:2}' action='set' />
<assign value='"BFTRESULT"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:3.1}' action='set' />
<assign value='"Please see Results Review/Body Fluids for requested results"' property='tmpdesc' action='set' />
<assign value='tmpdesc' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:5(1)}' action='set' />
</true>
</if>

<if condition='target.{PIDgrpgrp(1).ORCgrp(k1).OBR:50.1}="CSFT"' >
<true>
<assign value='"1"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:1}' action='set' />
<assign value='"ST"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:2}' action='set' />
<assign value='"CSFTRESULT"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:3.1}' action='set' />
<assign value='"Please see Results Review/CSF for requested results"' property='tmpdesc' action='set' />
<assign value='tmpdesc' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:5(1)}' action='set' />
</true>
</if>

<if condition='target.{PIDgrpgrp(1).ORCgrp(k1).OBR:50.1}="EP2019"' >
<true>
<assign value='"1"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:1}' action='set' />
<assign value='"ST"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:2}' action='set' />
<assign value='"EP2019RESULT"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:3.1}' action='set' />
<assign value='"Please see Results Review/Hematology for results"' property='tmpdesc' action='set' />
<assign value='tmpdesc' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:5(1)}' action='set' />
</true>
</if>

<if condition='target.{PIDgrpgrp(1).ORCgrp(k1).OBR:50.1}="HEMPL"' >
<true>
<assign value='"1"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:1}' action='set' />
<assign value='"ST"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:2}' action='set' />
<assign value='"HEMPLRESULT"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:3.1}' action='set' />
<assign value='"Please see Results Review/Hematology for results"' property='tmpdesc' action='set' />
<assign value='tmpdesc' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:5(1)}' action='set' />
</true>
</if>

<if condition='target.{PIDgrpgrp(1).ORCgrp(k1).OBR:50.1}="CTBAL"' >
<true>
<assign value='"1"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:1}' action='set' />
<assign value='"ST"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:2}' action='set' />
<assign value='"CTBALRESULT"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:3.1}' action='set' />
<assign value='"Please see Results Review/Body Fluids for results"' property='tmpdesc' action='set' />
<assign value='tmpdesc' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:5(1)}' action='set' />
</true>
</if>

<if condition='target.{PIDgrpgrp(1).ORCgrp(k1).OBR:50.1}="EP1019"' >
<true>
<assign value='"1"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:1}' action='set' />
<assign value='"ST"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:2}' action='set' />
<assign value='"EP1019RESULT"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:3.1}' action='set' />
<assign value='"Please see Results Review/Chemistry for results"' property='tmpdesc' action='set' />
<assign value='tmpdesc' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:5(1)}' action='set' />
</true>
</if>

<if condition='target.{PIDgrpgrp(1).ORCgrp(k1).OBR:50.1}="EP2031"' >
<true>
<assign value='"1"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:1}' action='set' />
<assign value='"ST"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:2}' action='set' />
<assign value='"EP2031RESULT"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:3.1}' action='set' />
<assign value='"Please see Results Review/Transfusion Medicine for results"' property='tmpdesc' action='set' />
<assign value='tmpdesc' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:5(1)}' action='set' />
</true>
</if>

<if condition='target.{PIDgrpgrp(1).ORCgrp(k1).OBR:50.1}="EP2049"' >
<true>
<assign value='"1"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:1}' action='set' />
<assign value='"ST"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:2}' action='set' />
<assign value='"EP2049RESULT"' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:3.1}' action='set' />
<assign value='"Please see Results Review/Microbiology for COVID and Influenza results"' property='tmpdesc' action='set' />
<assign value='tmpdesc' property='target.{PIDgrpgrp(1).ORCgrp(k1).OBXgrp(1).OBX:5(1)}' action='set' />
</true>
</if>

</false>
</if>
</false>
</if>
</foreach>
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
    // since we are creating result - do not update ordering doc table
    // actual result will handle
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

</transform>
}

}
