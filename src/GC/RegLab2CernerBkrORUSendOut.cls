Class GC.RegLab2CernerBkrORUSendOut Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 0;

Parameter REPORTERRORS = 0;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='251.Regions:ORU_R01' targetDocType='251.Regions:ORU_R01' create='copy' language='objectscript' >
<code>
<![CDATA[ 
	//  Last Update: 07/01/2021 Al Johnson
	//  Last Moved to Prod:  07/06/2021 Al Johnson
    //  Created 11/05/2018 Al Johnson
    //
    //  Beaker version - schema changed from 22.RegLab to 231.Cerner
    //   Changed to version 251.Regions 11/05/2018
    //
    //   OBR-24 = SO SendOuts (Regions changed from Quest to Arup Lab)
    //   Check for OBX Change in Sequence
    //    If tied to previous OBX change to NTE segment
    //    If standalone change to subtype RC
    //  Populate OBR-22 with MSH-7 datetime of message 03/23/2017
    //  Populate OBR-27.4 with MSH-7 datetime of message 03/23/2017
    //  Check table T_RegionsLab_OrderingProvider for a change in ordering provider 11/22/2017
    //  Change result message to table ordering provider 11/22/2017
    //  Update table with result date 11/22/2017
    //
    //  Change OBX=2 SN (structured numeric) to ST (string) consolidate result value OBX-5.1 and 5.2 02/25/2019
    //
    //  Change verbiage "See Scanned Result"  SD-86137 RFC = SD-89052
    //
]]></code>
<code>
<![CDATA[ 
    //  Update FreeText OBX as ST or NTE segment
    //  Change verbiage of "See Scanned Result" - copy so change both source and target at start
]]></code>

<assign value='"See Scanned Result"' property='tempobx5' action='set' />
<assign value='"See scanned report located in Cerner Notes Lab folder, Documentation or eDocs."' property='tempobx5new' action='set' />
<foreach property='target.{PIDgrpgrp(1).ORCgrp()}' key='k4' >
<foreach property='target.{PIDgrpgrp(1).ORCgrp(k4).OBXgrp()}' key='k5' >
<if condition='(target.{PIDgrpgrp(1).ORCgrp(k4).OBXgrp(k5).OBX:ObservationValue(1)})=tempobx5' >
<true>
<assign value='tempobx5new' property='target.{PIDgrpgrp(1).ORCgrp(k4).OBXgrp(k5).OBX:ObservationValue(1)}' action='set' />
</true>
</if>
</foreach>
</foreach>

<foreach property='target.{PIDgrpgrp(1).ORCgrp()}' key='k2' >
<assign value='source.{MSH:DateTimeOfMessage.Time}' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBR:22}' action='set' />
<assign value='source.{MSH:DateTimeOfMessage.Time}' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBR:27.4}' action='set' />
<assign value='0' property='tmpnte' action='set' />
<foreach property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp()}' key='k1' >
<if condition='k1="1"' >
<true>
<assign value='0' property='tmpnte' action='set' />
</true>
<false>
<if condition='(source.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:SetIDOBX})=(source.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1-1).OBX:SetIDOBX})' >
<true>
<assign value='tmpnte+1' property='tmpnte' action='set' />
<assign value='' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1)}' action='remove' />
<assign value='source.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:SetIDOBX}' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).NTE(tmpnte):SetIDNTE}' action='set' />
<assign value='"NTE"' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).NTE(tmpnte):SourceofComment}' action='set' />
<assign value='source.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:ObservationValue(1)}' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).NTE(tmpnte):Comment(1)}' action='set' />
<if condition='source.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:ObservationValue(1)}=tempobx5' >
<true>
<assign value='tempobx5new' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).NTE(tmpnte):Comment(1)}' action='set' />
</true>
</if>
</true>
<false>
<assign value='0' property='tmpnte' action='set' />
</false>
</if>
</false>
</if>
</foreach>
</foreach>

<code>
<![CDATA[ 
    //  02/25/2019 change SN to ST consolidate OBX-5.1 and 5.2 values
]]></code>
   
<foreach property='target.{PIDgrpgrp(1).ORCgrp()}' key='k10' >
<foreach property='target.{PIDgrpgrp(1).ORCgrp(k10).OBXgrp()}' key='k11' >
<if condition='target.{PIDgrpgrp(1).ORCgrp(k10).OBXgrp(k11).OBX:2}="SN"' >
<true>
<assign value='"ST"' property='target.{PIDgrpgrp(1).ORCgrp(k10).OBXgrp(k11).OBX:2}' action='set' />
<assign value='""' property='hold51' action='set' />
<assign value='""' property='hold52' action='set' />
<assign value='target.{PIDgrpgrp(1).ORCgrp(k10).OBXgrp(k11).OBX:5(1).1}' property='hold51' action='set' />
<assign value='target.{PIDgrpgrp(1).ORCgrp(k10).OBXgrp(k11).OBX:5(1).2}' property='hold52' action='set' />
<assign value='hold51_hold52' property='target.{PIDgrpgrp(1).ORCgrp(k10).OBXgrp(k11).OBX:5(1)}' action='set' />
</true>
</if>
</foreach>
</foreach>

<code>
<![CDATA[ 
    //  Check table T_RegionsLab_OrderingProvider for a change in ordering provider 11/22/2017
    //  Change result message to table ordering provider 11/22/2017
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