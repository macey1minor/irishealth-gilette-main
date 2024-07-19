Class GC.RegLab2CernerORM Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='22.RegLab:ORM_O01' targetDocType='22.RegLab:ORM_O01' create='copy' language='objectscript' >
<code>
<![CDATA[ 
	//  Last Updated 11/22/2017
	//  Last Updated in Prod: 11/29/2017 Al Johnson
	//  Create: 11/22/2017  Al Johnson 
	//  Description: 
	//  Check incoming order messages from Regions - exception SN send Order Number
	//  Replace ordering doctor from table T_RegionsLab_OrderingProvider 11/22/2017
	//  Update table with result date 11/22/2017 
]]></code>

<assign property='tempCernerOrder' value='source.{OBR:2(1).1}' action='set' />

<assign property='tempORC12' value='source.{ORC:12(1)}' action='set' />
<assign property='tempOBR16' value='source.{OBR:16(1)}' action='set' />
<assign property='tempInORC12id' value='source.{ORC:12(1).1}' action='set' />
<assign property='tempInOBR16id' value='source.{OBR:16(1).1}' action='set' />

<assign property='tempDateResult' value='""' action='set' />
<assign property='tempDateCancel' value='""' action='set' />

<if condition='(source.{ORC:1}="SN")' >
<false>
<code>
<![CDATA[
    // SN Send Number- no Cerner order - so send to Cerner as received
]]></code>
	

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
    // if cancel - update cancel date in table
]]></code>
<assign value='$PIECE(wtableresult,"|",1)' property='temptblORC12' action='set' />
<assign value='$PIECE(temptblORC12,"^",1)' property='temptblORC12id' action='set' />
<assign value='$PIECE(wtableresult,"|",2)' property='temptblOBR16' action='set' />
<assign value='$PIECE(temptblOBR16,"^",1)' property='temptblOBR16id' action='set' />
<assign value='$PIECE(wtableresult,"|",3)' property='temptblDateAdd' action='set' />
<assign value='$PIECE(wtableresult,"|",4)' property='temptblDateResult' action='set' />
<assign value='$PIECE(wtableresult,"|",5)' property='temptblDateCancel' action='set' />

<code>
<![CDATA[
    // OC Order Cancel - update cancel date in table
]]></code>
<if condition='(source.{ORC:1}="OC")' >
<true>
<assign property='tempDateCancel' value='$ZDATE($NOW(),8)' action='set' />
<code>
<![CDATA[
    // cancel or discontinue - update table with cancel date
        set wTableData=(temptblORC12_"|"_temptblOBR16_"|"_temptblDateAdd_"|"_temptblDateResult_"|"_tempDateCancel_"|") 
        set wTableName="T_RegionsLab_OrderingProvider"
        do ##class(Ens.Util.LookupTable).%UpdateValue(wTableName,wTableKey,wTableData)	
]]></code>
</true>
</if>

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
</false>
</if>

</transform>
}

}
