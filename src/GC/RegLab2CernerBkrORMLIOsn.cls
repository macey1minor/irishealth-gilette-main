Class GC.RegLab2CernerBkrORMLIOsn Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='251.Regions:ORM_O01' targetDocType='251.Regions:ORM_O01' create='copy' language='objectscript' >
<code>
<![CDATA[ 
	//  Last Update: 03/17/2021 Al Johnson
	//  Last Moved to Prod:  06/29/2021 Al Johnson
    //  Created 03/17/2021 Al Johnson
    //
    //  ORC-1 = SN (Send Number - Lab Initiated Order)
    //  Regions sends two status messages - collected and inprocess
    //  On LIO they are changing the first status to SN, then the second is flowing out without Gillette order number
    //  Table data on SN so Cerner generated NA can update with Cerner order number
    //  Trap and hold second SC until it can read table and update inbound SC with Gillette number.
    //  Do this via rules and send to separate process
    //
	//  Table = T_RegionsLab_LIO - key is Regions accession OBR-3.1 pipe delimiter and OBR-4.1 ordered
	//  Possible that the same test could be run on same specimen (accession number if result is strange - would have new epic order nbr)
	//  So update table if record is found
	//  RFC SD-85921
]]></code>

<assign value='""' property='holdobr3' action='set' />
<assign value='""' property='holdobr4' action='set' />
<assign value='""' property='holdobr20' action='set' />
<assign value='""' property='holdobrtblkey' action='set' />
<assign value='target.{ORCgrp(1).OBRuniongrp.OBRunion.OBR:3.1}' property='holdobr3' action='set' />
<assign value='target.{ORCgrp(1).OBRuniongrp.OBRunion.OBR:4.1}' property='holdobr4' action='set' />
<assign value='target.{ORCgrp(1).OBRuniongrp.OBRunion.OBR:20}' property='holdobr20' action='set' />
<assign value='holdobr3_"|"_holdobr4' property='holdobrtblkey' action='set' />

<assign value='$ZDATE($NOW(),8)' property='tempDateAdd' action='set' />

<assign value='""' property='wtableresult' action='set' />
<assign value='""' property='wtabledata' action='set' />
<assign value='..Lookup("T_RegionsLab_LIO",holdobrtblkey)' property='wtableresult' action='set' />
<if condition='wtableresult=""' >
<true>
<code>
<![CDATA[ 
    // no entry found - so add new entry
        set wTableData=(tempDateAdd_"|"_holdobr20_"|") 
        set wTableName="T_RegionsLab_LIO"
        do ##class(Ens.Util.LookupTable).%UpdateValue(wTableName,holdobrtblkey,wTableData)
	]]></code>
</true>
<false>
<code>
<![CDATA[ 
    // table entry found - update with new epic order number, remove original gillette nbr
        set wTableData=(tempDateAdd_"|"_holdobr20_"|")
        set wTableName="T_RegionsLab_LIO"
        do ##class(Ens.Util.LookupTable).%UpdateValue(wTableName,holdobrtblkey,wTableData)
]]></code>
</false>
</if>

</transform>
}

}
