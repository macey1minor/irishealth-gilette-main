Class GC.RegLab2CernerORUCoPath Extends Ens.DataTransformDTL
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<?xml version="1.0" ?>
<transform targetClass='EnsLib.HL7.Message' targetDocType='22.RegLab:ORU_R01' sourceClass='EnsLib.HL7.Message' sourceDocType='22.RegLab:ORU_R01' create='copy' language='objectscript'>
<code>
<![CDATA[ 
	//  Last Updated: 11/22/2017 Al Johnson
	//  Last Moved to Prod: 11/29/2017 
    //  Created 03/23/2017 Al Johnson
    //
    //  Populate OBR-22 with MSH-7 datetime of message 03/23/2017
    //  Populate OBR-27.4 with MSH-7 datetime of message 03/23/2017
    //
    //  Check table T_RegionsLab_OrderingProvider for a change in ordering provider 11/22/2017
    //  Change result message to table ordering provider 11/22/2017
    //  Update table with result date 11/22/2017
]]>
</code>

<assign value='source.{MSH:DateTimeofMessage.timeofanevent}' property='target.{OBR:22}' action='set' />
<assign value='source.{MSH:DateTimeofMessage.timeofanevent}' property='target.{OBR:27.4}' action='set' />

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
