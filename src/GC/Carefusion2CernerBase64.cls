Class GC.Carefusion2CernerBase64 Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ORU_R01' targetDocType='231.Cerner:ORU_R01' create='copy' language='objectscript' >
<code>
<![CDATA[ 
	//  Last Updated 07/09/2018
	//  Last Updated in Prod: 02/03/2017 Al Johnson
	//  Create: 02/03/2017  Al Johnson 
	//  Description:  
	//	ORU from CarefusionPFT has both base64 report and discrete elements
	//  Carefusion2CernerBase64 will create ORU with only report
	//  Carefusion2CernerDiscrete will create ORU with only discrete OBX and append Carefusion Order with PDF
    //
    //  Copy the Cerner order id from ORC-2 to ORC-3 and OBR-2 to OBR-3.  07/09/2018
    //   Result on order without the PFT appended will go to the message center  07/09/2018
    //   Kristin wants the result for the report to go and not the discrete items  07/09/2018
    //  Copy OBR:7 if populated, else MSH:7 to OBR:22 resultstatuschangedate.  07/09/2018
    //  Copy OBR:7 if populated, else MSH:7 to OBR:27.4 quatitytimingstartdate.  07/09/2018
    //  Read T_CarefusionPFT_OrderingProvider.  Populate ORC-12 and OBR-16.  07/09/2018
]]></code>
<foreach property='target.{ORCgrp(1).OBXgrp()}' key='k1' >
<if condition='target.{ORCgrp(1).OBXgrp(k1).OBX:2}="ED"' >
<false>
<assign value='' property='target.{ORCgrp(1).OBXgrp(k1)}' action='remove' />
</false>
</if>
</foreach>
<code>
<![CDATA[ 
    //  Copy OBR:2 PlacerOrderID to OBR:3 FillerOrderID
    //  Populate OBR:22 and OBR:27.4
]]></code>

<assign value='source.{ORCgrp(1).ORC:2.1}' property='target.{ORCgrp(1).ORC:3.1}' action='set' />
<assign value='source.{ORCgrp(1).OBR:2.1}' property='target.{ORCgrp(1).OBR:3.1}' action='set' />

<assign value='""' property='tholdresultdate' action='set' />
<if condition='(source.{ORCgrp(1).OBR:7.1}="")' >
<true>
<assign value='source.{MSH:7.1}' property='tholdresultdate' action='set' />
</true>
<false>
<assign value='source.{ORCgrp(1).OBR:7.1}' property='tholdresultdate' action='set' />
</false>
</if>

<if condition='(source.{ORCgrp(1).OBR:22.1}="")' >
<true>
<assign value='tholdresultdate' property='target.{ORCgrp(1).OBR:22}' action='set' />
</true>
</if>

<if condition='(source.{ORCgrp(1).OBR:27.4}="")' >
<true>
<assign value='tholdresultdate' property='target.{ORCgrp(1).OBR:27.4}' action='set' />
</true>
</if>

<code>
<![CDATA[ 
    //  Check table T_CarefusionPFT_OrderingProvider for a change in ordering provider
    //  Change result message to table ordering provider
]]></code>
<assign value='source.{ORCgrp(1).OBR:2(1).1}' property='tempCernerOrder' action='set' />
<assign value='source.{ORCgrp(1).ORC:12(1)}' property='tempORC12' action='set' />
<assign value='source.{ORCgrp(1).OBR:16(1)}' property='tempOBR16' action='set' />
<assign value='source.{ORCgrp(1).ORC:12(1).1}' property='tempInORC12id' action='set' />
<assign value='source.{ORCgrp(1).OBR:16(1).1}' property='tempInOBR16id' action='set' />
<assign value='""' property='tempDateResult' action='set' />
<assign value='""' property='tempDateCancel' action='set' />
<assign value='tempCernerOrder' property='wTableKey' action='set' />
<assign value='""' property='wTableData' action='set' />
<assign value='""' property='wtableresult' action='set' />
<assign value='..Lookup("T_CarefusionPFT_OrderingProvider",wTableKey)' property='wtableresult' action='set' />
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
    // result from Carefusion - update table with result date
        set wTableData=(temptblORC12_"|"_temptblOBR16_"|"_temptblDateAdd_"|"_tempDateResult_"|"_temptblDateCancel_"|") 
        set wTableName="T_CarefusionPFT_OrderingProvider"
        do ##class(Ens.Util.LookupTable).%UpdateValue(wTableName,wTableKey,wTableData)	
]]></code>
<if condition='(tempInORC12id = temptblORC12id)&amp;(tempInOBR16id = temptblOBR16id)' >
<false>
<code>
<![CDATA[ 
    // ordering doc on table differs from Carefusion hl7 message
    //  update hl7 message
]]></code>
<assign value='temptblORC12' property='target.{ORCgrp(1).ORC:12(1)}' action='set' />
<assign value='temptblOBR16' property='target.{ORCgrp(1).OBR:16(1)}' action='set' />
</false>
</if>
</false>
</if>
</transform>
}

}
