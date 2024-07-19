Class GC.RegLab2CernerORUbb Extends Ens.DataTransformDTL
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<?xml version="1.0" ?>
<transform targetClass='EnsLib.HL7.Message' targetDocType='22.RegLab:ORU_R01' sourceClass='EnsLib.HL7.Message' sourceDocType='22.RegLab:ORU_R01' create='new' language='objectscript'>
<code>
<![CDATA[ 
	//  Last Updated: 01/02/2018 Al Johnson 
	//  Last Updated in Prod:  01/10/2018
	// 	Create: 08/26/2015 copy from GCH.RegLab2QcprORU changed specific to Blood Bank
	// 
	// updated results format for OBX sections
	// combine obx if the OBX_1 have the same value
	// Combine OBX_5 into one NTE if same OBX_3 code
	// added logic for Blood Bank
	//  Send performing lab information in last OBX as COMM only if sent by lab
	// remove leading zero from QCPR order number 
	// remove prefix of E if it exists in ordering doctor dont need to pad
	//
    //  Populate OBR-22 with MSH-7 datetime of message 03/23/2017
    //  Populate OBR-27.4 with MSH-7 datetime of message 03/23/2017
    //
    //  Check table T_RegionsLab_OrderingProvider for a change in ordering provider 11/22/2017
    //  Change result message to table ordering provider 11/22/2017
    //  Update table with result date 11/22/2017
    //
    //  Consolidate consecutive OBX segments for %ABR 01/02/2018
]]>
</code>
<assign property='target.{MSH}' value='source.{MSH}' action='set'/>
<assign property='target.{MSH:ReceivingApplication}' value='"OCRR"' action='set'/>
<assign property='target.{MSH:ReceivingFacility}' value='"GCS"' action='set'/>
<assign property='target.{MSH:ProcessingID}' value='"P"' action='set'/>
<assign property='target.{MSH:Security}' value='"Reg2CernerORUbb"' action='set'/>
<assign property='target.{PID}' value='source.{PID}' action='set'/>

<code>
<![CDATA[ 
	// *****************************  ORDER LOGIC ********************************
]]>
</code>
<assign property='target.{ORC}' value='source.{ORC}' action='set'/>
<assign property='target.{OBR}' value='source.{OBR}' action='set'/>

<assign value='source.{MSH:DateTimeofMessage.timeofanevent}' property='target.{OBR:22}' action='set' />
<assign value='source.{MSH:DateTimeofMessage.timeofanevent}' property='target.{OBR:27.4}' action='set' />

<code>
<![CDATA[ 
	// ***************************** Result Status ********************************
]]>
</code>
<if condition='(source.{OBR:ResultStatus} = "") || (source.{OBR:ResultStatus} = "I")'>
<true>
<assign property='target.{OBR:ResultStatus}' value='"P"' action='set'/>
</true>
</if>
<code>
<![CDATA[ 
	// ***************************** priority changes ********************************
]]>
</code>

<if condition='(source.{OBR:QuantityTiming(1).priority} = "")'>
<true>
<assign property='target.{OBR:QuantityTiming(1).priority}' value='"RO"' action='set'/>
</true>
</if>

<code>
<![CDATA[ 
	// *****************************  RESULT LOGIC ********************************
]]>
</code>
<foreach property='source.{OBXgrp()}' key='k1'>
<assign property='target.{OBXgrp(k1).OBX}' value='source.{OBXgrp(k1).OBX}' action='set'/>
</foreach>

<code>
<![CDATA[ 
	// *****************************  Combine OBX_5 with same OBX_3 ********************************
]]>
</code>
<assign property='Result' value='""' action='set'/>
<assign property='Cnt' value='"1"' action='set'/>
<assign property='CNT2' value='"1"' action='set'/>
<assign property='TestName' value='source.{OBXgrp(1).OBX:3.2}' action='set'/>

<assign property='HldOBXval1' value='""' action='set' />
<assign property='HldOBXval2' value='""' action='set' />

<code>
<![CDATA[ 
	// *****************************  Blood Bank Results ********************************
]]>
</code>
<if condition='source.{OBR:24} = "BB" '>
<true>
<assign property='CntBB' value='"0"' action='set'/>
<foreach property='source.{OBXgrp()}' key='k1'>
<if condition='target.{OBXgrp(k1).OBX:3.2} = "%UN" '>
<true>
<assign property='CntBB' value='CntBB + "1"' action='set'/>
<assign property='target.{OBXgrp(k1).OBX:ObservationIdentifier.text}' value='target.{OBXgrp(k1).OBX:ObservationIdentifier.text}_CntBB' action='set'/>
</true>
</if>
<if condition='(target.{OBXgrp(k1).OBX:3.2}="%ABR") &amp; (target.{OBXgrp(k1+1).OBX:3.2}="%ABR")'>
<true>
<assign property='HldOBXval1' value='target.{OBXgrp(k1).OBX:5(1)}' action='set' />
<assign property='HldOBXval2' value='target.{OBXgrp(k1+1).OBX:5(1)}' action='set' />
<assign property='target.{OBXgrp(k1).OBX:5}' value='HldOBXval1_" "_HldOBXval2' action='set' />
<assign property='target.{OBXgrp(k1+1).OBX}' value='' action='remove' />
</true>
</if>
<if condition='..In(target.{OBXgrp(k1).OBX:3.2},"%CT,%ST,%TS,%UDIV,%XM") '>
<true>
<assign property='target.{OBXgrp(k1).OBX:ObservationIdentifier.text}' value='target.{OBXgrp(k1).OBX:ObservationIdentifier.text}_CntBB' action='set'/>
</true>
</if>
</foreach>
</true>
</if>
<code>
<![CDATA[ 
	// ******Send performing lab information in last OBX as COMM only if sent by lab ************
	]]>
</code>
<code>
<![CDATA[
    // commented out add of performed at obx creation
    // <assign property='Obxcnt' value='"1"' action='set'/>
    // <assign property='Plab' value='"none"' action='set'/>
    // <foreach property='source.{OBXgrp()}' key='k1'>
    // <assign property='Obxcnt' value='Obxcnt +"1"' action='set'/>
    // <if condition='source.{OBXgrp(k1).OBX:15} = "" '>
    // <false>
    // <assign property='Plab' value='source.{OBXgrp(k1).OBX:15}' action='set'/>
    // </false>
    // </if>
    // </foreach>
    // <if condition='Plab = "none" '>
    // <false>
    // <assign property='target.{OBXgrp(Obxcnt).OBX:1}' value='Obxcnt' action='set'/>
    // <assign property='target.{OBXgrp(Obxcnt).OBX:2}' value='"ST"' action='set'/>
    // <assign property='target.{OBXgrp(Obxcnt).OBX:3}' value='"COMM"' action='set'/>
    // <assign property='target.{OBXgrp(Obxcnt).OBX:5}' value='Plab' action='set'/>
    // </false>
    //</if>
	]]>
</code>


<code>
<![CDATA[
    //  Check table T_RegionsLab_OrderingProvider for a change in ordering provider 11/22/2017
    //  Change result message to table ordering provider 11/22/2017
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
