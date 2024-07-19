Class GC.RegLab2CernerORUGenlab Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='22.RegLab:ORU_R01' targetDocType='22.RegLab:ORU_R01' create='copy' language='objectscript' >
<code>
<![CDATA[ 
	//  Last Update: 01/02/2018 Al Johnson
	//  Last Moved to Prod:  01/10/2018
    //  Created 02/05/2017 Al Johnson
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
]]></code>
<code>
<![CDATA[ 
    //  Update FreeText OBX as ST or NTE segment
    //  01/02/2018 cosolidate CSFD OBX segments
    //             Also consolidate if CE followed by FT for CSFD
]]></code>
<assign value='source.{MSH:DateTimeofMessage.timeofanevent}' property='target.{OBR:22}' action='set' />
<assign value='source.{MSH:DateTimeofMessage.timeofanevent}' property='target.{OBR:27.4}' action='set' />
<assign value='0' property='tmpnte' action='set' />
<assign property='HldOBXval1' value='""' action='set' />
<assign property='HldOBXval2' value='""' action='set' />
<foreach property='target.{OBXgrp()}' key='k1' >
<if condition='target.{OBXgrp(k1).OBX:ValueType}="FT"' >
<true>
<if condition='k1="1"' >
<true>
<assign value='"ST"' property='target.{OBXgrp(k1).OBX:ValueType}' action='set' />
</true>
<false>
<if condition='(target.{OBXgrp(k1).OBX:SetIDOBX})=(target.{OBXgrp(k1-1).OBX:SetIDOBX})' >
<true>
<assign value='tmpnte+1' property='tmpnte' action='set' />
<assign value='' property='target.{OBXgrp(k1)}' action='remove' />
<assign value='source.{OBXgrp(k1).OBX:SetIDOBX}' property='target.{OBXgrp(k1).NTE(tmpnte):SetIDNotesandComments}' action='set' />
<assign value='"RC"' property='target.{OBXgrp(k1).NTE(tmpnte):SourceofComment}' action='set' />
<assign value='source.{OBXgrp(k1).OBX:ObservationValue}' property='target.{OBXgrp(k1).NTE(tmpnte):Comment(1)}' action='set' />
</true>
<false>
<assign value='"ST"' property='target.{OBXgrp(k1).OBX:ValueType}' action='set' />
</false>
</if>
</false>
</if>
</true>
<false>
<code>
<![CDATA[ 
    //  01/02/2018 consolidate consecutive CSFD even if CE followed by FT
]]></code>
<if condition='(target.{OBXgrp(k1).OBX:3.2}="CSFD") &amp; (target.{OBXgrp(k1+1).OBX:3.2}="CSFD")'>
<true>
<assign property='HldOBXval1' value='target.{OBXgrp(k1).OBX:5(1)}' action='set' />
<assign property='HldOBXval2' value='target.{OBXgrp(k1+1).OBX:5(1)}' action='set' />
<assign property='target.{OBXgrp(k1).OBX:5}' value='HldOBXval1_" "_HldOBXval2' action='set' />
<assign property='target.{OBXgrp(k1+1).OBX}' value='' action='remove' />
</true>
</if>
</false>
</if>
</foreach>

<code>
<![CDATA[
    //  Check table T_RegionsLab_OrderingProvider for a change in ordering provider
    //  Change result message to table ordering provider
]]></code>

<assign property='tempCernerOrder' value='source.{OBR:2(1).1}' action='set' />

<assign property='tempORC12' value='source.{ORC:12(1)}' action='set' />
<assign property='tempOBR16' value='source.{OBR:16(1)}' action='set' />
<assign property='tempInORC12id' value='source.{ORC:12(1).1}' action='set' />
<assign property='tempInOBR16id' value='source.{OBR:16(1).1}' action='set' />

<assign property='tempDateResult' value='""' action='set' />
<assign property='tempDateCancel' value='""' action='set' />

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

<assign property='tempDateResult' value='$ZDATE($NOW(),8)' action='set' />
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
]]></code>
  <assign property='target.{ORC:12(1)}' value='temptblORC12' action='set' />
  <assign property='target.{OBR:16(1)}' value='temptblOBR16' action='set' />
</false>
</if>

</false>
</if>

</transform>
}

}
