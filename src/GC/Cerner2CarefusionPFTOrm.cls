Class GC.Cerner2CarefusionPFTOrm Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ORM_O01' targetDocType='231.Cerner:ORM_O01' create='copy' language='objectscript' >
<code>
<![CDATA[ 
	//  Last Updated 07/06/2018
	//  Last Updated in Prod: 07/06/2018 Al Johnson
	//  Create: 07/06/2018  Al Johnson 
	//  Description:  
	//	Store OBR:16 ordering doctor so result back can read and update message
	//   Store in table T_CarefusionPFT_OrderingProvider

]]></code>

<code>
<![CDATA[ 
    //  07/06/2018 - table ordering provider
    //
	//  Read table T_CarefusionPFT_OrderingProvider - Cerner OrderNbr is key to table
	//  to delete specific entry - do ##class(Ens.Util.LookupTable).%RemoveValue(wTableName,wTableKey)
	//  add / update - do ##class(Ens.Util.LookupTable).%UpdateValue(wTableName,wTableKey,wTableData)
	//
	//  table entire field - id and name for result messages
	//   extract just id to check for change
	]]></code>
	
<assign property='tempCernerOrder' value='source.{ORCgrp(1).ORC:2.1}' action='set' />
<assign property='tempORC12' value='source.{ORCgrp(1).ORC:12}' action='set' />
<assign property='tempOBR16' value='source.{ORCgrp(1).OBRgrp.OBR:16(1)}' action='set' />

<assign property='tempInORC12id' value='source.{ORCgrp(1).ORC:12.1}' action='set' />
<assign property='tempInOBR16id' value='source.{ORCgrp(1).OBRgrp.OBR:16(1).1}' action='set' />

<assign property='tempDateAdd' value='$ZDATE($NOW(),8)' action='set' />
<assign property='tempDateResult' value='""' action='set' />
<assign property='tempDateCancel' value='""' action='set' />
<if condition='(source.{ORCgrp(1).ORC:1}="CA")||(source.{ORCgrp(1).ORC:1}="DC")' >
<true>
<assign property='tempDateCancel' value='$ZDATE($NOW(),8)' action='set' />
</true>
</if>

<assign value='tempCernerOrder' property='wTableKey' action='set' />
<assign value='""' property='wTableData' action='set' />
<assign value='""' property='wtableresult' action='set' />
<assign value='..Lookup("T_CarefusionPFT_OrderingProvider",wTableKey)' property='wtableresult' action='set' />
<if condition='wtableresult=""' >
<true>
<code>
<![CDATA[
    // no entry found - so add new entry
        set wTableData=(tempORC12_"|"_tempOBR16_"|"_tempDateAdd_"|"_tempDateResult_"|"_tempDateCancel_"|") 
        set wTableName="T_CarefusionPFT_OrderingProvider"
        do ##class(Ens.Util.LookupTable).%UpdateValue(wTableName,wTableKey,wTableData)
	]]></code>
</true>
<false>
<assign value='$PIECE(wtableresult,"|",1)' property='temptblORC12' action='set' />
<assign value='$PIECE(temptblORC12,"^",1)' property='temptblORC12id' action='set' />
<assign value='$PIECE(wtableresult,"|",2)' property='temptblOBR16' action='set' />
<assign value='$PIECE(temptblOBR16,"^",1)' property='temptblOBR16id' action='set' />
<assign value='$PIECE(wtableresult,"|",3)' property='temptblDateAdd' action='set' />
<assign value='$PIECE(wtableresult,"|",4)' property='temptblDateResult' action='set' />
<assign value='$PIECE(wtableresult,"|",5)' property='temptblDateCancel' action='set' />

<if condition='(source.{ORCgrp(1).ORC:1}="CA")||(source.{ORCgrp(1).ORC:1}="DC")' >
<true>
<code>
<![CDATA[
    // cancel or discontinue - update table with cancel date
        set wTableData=(tempORC12_"|"_tempOBR16_"|"_temptblDateAdd_"|"_temptblDateResult_"|"_tempDateCancel_"|") 
        set wTableName="T_CarefusionPFT_OrderingProvider"
        do ##class(Ens.Util.LookupTable).%UpdateValue(wTableName,wTableKey,wTableData)	
	]]></code>
</true>
<false>
<if condition='(tempInORC12id = temptblORC12id)&amp;(tempInOBR16id = temptblOBR16id)' >
<false>
<code>
<![CDATA[
    // ordering doc on table differs from order - update table with orm data - update date add
        set wTableData=(tempORC12_"|"_tempOBR16_"|"_tempDateAdd_"|"_temptblDateResult_"|"_temptblDateCancel_"|") 
        set wTableName="T_CarefusionPFT_OrderingProvider"
        do ##class(Ens.Util.LookupTable).%UpdateValue(wTableName,wTableKey,wTableData)	
	]]></code>
</false>
</if>
</false>
</if>
</false>
</if>

</transform>
}

}
