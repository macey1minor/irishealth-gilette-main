Class GC.RegLab2CernerBkrORUCancel Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='251.Regions:ORU_R01' targetDocType='251.Regions:ORU_R01' create='copy' language='objectscript' >
<code>
<![CDATA[ 
	//  Last Update: 07/02/2020 Al Johnson
	//  Last Moved to Prod:  07/08/2020 Al Johnson
    //  Created 04/20/2020 Al Johnson
    //
    //  Beaker version - schema changed from 22.RegLab to 231.Cerner
    //   Changed to version 251.Regions 10/15/2018
    //
    //  Beaker sending Cancel on ORU Result versus ORM Order
    //  Ensure OBR-7 date and time populated
    //  Populate ORC-16 cancel reason if missing
    //
    //  read Table = T_RegionsLab_OrderedConversion -if on table update OBR-4.2 with original value 4/19/2019
    //
    //  Change result cancel to order cancel - 07/02/2020 SD-40423 RFC SD-48154
]]></code>

<assign value='""' property='tempDateCancel' action='set' />
<assign value='""' property='tempDateResult' action='set' />

<if condition='(source.{PIDgrpgrp(1).ORCgrp(1).OBR:7}="0000")||(source.{PIDgrpgrp(1).ORCgrp(1).OBR:7}="")' >
<true>
<assign value='source.{MSH:7.1}' property='target.{PIDgrpgrp(1).ORCgrp(1).OBR:7}' action='set' />
<assign value='source.{MSH:7.1}' property='tempDateCancel' action='set' />
</true>
<false>
<assign value='source.{PIDgrpgrp(1).ORCgrp(1).OBR:7}' property='tempDateCancel' action='set' />
</false>
</if>

<if condition='(source.{PIDgrpgrp(1).ORCgrp(1).ORC:16}="")' >
<true>
<assign value='"LAB DUP"' property='target.{PIDgrpgrp(1).ORCgrp(1).ORC:16.1}' action='set' />
<assign value='"Duplicate"' property='target.{PIDgrpgrp(1).ORCgrp(1).ORC:16.2}' action='set' />
</true>
</if>

<code>
<![CDATA[ 
    //  Change result cancel to order cancel
]]></code>
<assign value='"ORM"' property='target.{MSH:9.1}' action='set' />
<assign value='"O01"' property='target.{MSH:9.2}' action='set' />
<assign value='"CA"' property='target.{PIDgrpgrp(1).ORCgrp(1).ORC:1}' action='set' />

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
    // result from Regions - update table with result date and cancel date
        set wTableData=(temptblORC12_"|"_temptblOBR16_"|"_temptblDateAdd_"|"_tempDateResult_"|"_tempDateCancel_"|") 
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
