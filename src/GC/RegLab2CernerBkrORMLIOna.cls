Class GC.RegLab2CernerBkrORMLIOna Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ORM_O01' targetDocType='231.Cerner:ORM_O01' create='copy' language='objectscript' >
<code>
<![CDATA[ 
	//  Last Update: 03/17/2021 Al Johnson
	//  Last Moved to Prod:  06/29/2021 Al Johnson
    //  Created 03/17/2021 Al Johnson
    //
    //  ORC-1 = NA (Number Assigned - Lab Initiated Order)
    //  Regions sends two status messages - collected and inprocess
    //  On LIO they are changing the first status to SN, then the second is flowing out without Gillette order number
    //  Table data on SN so Cerner generated NA can update with Cerner order number
    //  Trap and hold second SC until it can read table and update inbound SC with Gillette number.
    //  Do this via rules and send to separate process
    //
    //  Update message with Regions Accession, OBR-20 to OBR-3
    //  Update OBR-20 with held Epic Order number
    //  Update table with Gillette Order number
    //
	//  Table = T_RegionsLab_LIO - key is Regions accession OBR-3.1 pipe delimiter and OBR-4.1 ordered
	//  RFC SD-85921
]]></code>
<assign value='source.{ORCgrp(1).OBRgrp.OBR:20}' property='target.{ORCgrp(1).OBRgrp.OBR:3}' action='set' />
<assign value='source.{ORCgrp(1).OBRgrp.OBR:20}' property='holdobr20in' action='set' />
<assign value='source.{ORCgrp(1).OBRgrp.OBR:4.2}' property='holdobr4' action='set' />
<assign value='""' property='target.{ORCgrp(1).OBRgrp.OBR:20}' action='set' />

<assign value='holdobr20in_"|"_holdobr4' property='holdobrtblkey' action='set' />

<assign value='source.{ORCgrp(1).OBRgrp.OBR:2}' property='holdobrgillnbr' action='set' />

<assign value='""' property='wtableresult' action='set' />
<assign value='""' property='wtabledata' action='set' />
<assign value='""' property='temptblbkrorder' action='set' />
<assign value='..Lookup("T_RegionsLab_LIO",holdobrtblkey)' property='wtableresult' action='set' />
<if condition='wtableresult=""' >
<true>
<code>
<![CDATA[ 
    // no entry found - so leave
	]]></code>
</true>
<false>
<assign value='$PIECE(wtableresult,"|",2)' property='target.{ORCgrp(1).OBRgrp.OBR:20}' action='set' />
<assign value='$PIECE(wtableresult,"|",1)' property='tfield1' action='set' />
<assign value='$PIECE(wtableresult,"|",2)' property='tfield2' action='set' />
<code>
<![CDATA[ 
    // table entry found get tabled data, update gillette nbr
        set wTableData=(tfield1_"|"_tfield2_"|"_holdobrgillnbr) 
        set wTableName="T_RegionsLab_LIO"
        do ##class(Ens.Util.LookupTable).%UpdateValue(wTableName,holdobrtblkey,wTableData)
]]></code>
</false>
</if>

</transform>
}

}
