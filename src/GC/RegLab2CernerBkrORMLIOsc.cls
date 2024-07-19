Class GC.RegLab2CernerBkrORMLIOsc Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='251.Regions:ORM_O01' targetDocType='251.Regions:ORM_O01' create='copy' language='objectscript' >
<code>
<![CDATA[ 
	//  Last Update: 03/18/2021 Al Johnson
	//  Last Moved to Prod:  06/29/2021 Al Johnson
    //  Created 03/18/2021 Al Johnson
    //
    //  This dtl is to cover the SC inprocess status message missing the Gillette order number
    //  The SN, NA process should create the table entry, but Regions is sending this with the SN message
    //
    //  Read table, if updated entry with Gillette order does not exist, wait and read again
    //  Limit number of waits so system does not hang
    //  If no table entry after limit, send as received
    //
	//  Table = T_RegionsLab_LIO - key is Regions accession OBR-3.1 pipe delimiter and OBR-4.1 ordered
	//  RFC SD-85921
]]></code>

<assign value='target.{ORCgrp(1).OBRuniongrp.OBRunion.OBR:2.1}' property='holdobr2' action='set' />
<assign value='target.{ORCgrp(1).OBRuniongrp.OBRunion.OBR:3.1}' property='holdobr3' action='set' />
<assign value='target.{ORCgrp(1).OBRuniongrp.OBRunion.OBR:4.1}' property='holdobr4' action='set' />
<assign value='target.{ORCgrp(1).OBRuniongrp.OBRunion.OBR:20}' property='holdobr20' action='set' />
<assign value='holdobr3_"|"_holdobr4' property='holdobrtblkey' action='set' />

<code>
<![CDATA[ 
    // <assign value='$ZDATETIME($NOW(),8,1,0)' property='tmpdatetime' action='set' />
    // $$$TRACE("Wait1 "_tmpdatetime)
    // collected / sn and inprocess sent together - initial wait 10 sec for na update
    
    Hang 10
    
]]></code>

<code>
<![CDATA[ 
    // <assign value='$ZDATETIME($NOW(),8,1,0)' property='tmpdatetime' action='set' />
    // $$$TRACE("EndWait1 "_tmpdatetime)
]]></code>

<assign value='""' property='tGilletteOrder' action='set' />

<assign value='""' property='wtableresult' action='set' />
<assign value='""' property='wtabledata' action='set' />
<assign value='..Lookup("T_RegionsLab_LIO",holdobrtblkey)' property='wtableresult' action='set' />

<if condition='wtableresult=""' >
<true>
<code>
<![CDATA[ 
    // $$$TRACE("No table entry")
    // no entry found - SN never received - send thru as is
	]]></code>
<assign value='""' property='wtableresult' action='set' />
</true>
<false>
<code>
<![CDATA[ 
    // $$$TRACE("Table entry found")
    // table entry found - check for Gillette order, if not updated wait and retry (updated by NA)    
]]></code>
<assign value='$PIECE(wtableresult,"|",3)' property='tGilletteOrder' action='set' />
<if condition='tGilletteOrder=""' >
<true>
<code>
<![CDATA[ 
    // <assign value='$ZDATETIME($NOW(),8,1,0)' property='tmpdatetime' action='set' />
    // $$$TRACE("Wait2 "_tmpdatetime)
    // wait an additional 10 seconds - reread
   Hang 10
]]></code>
<assign value='""' property='wtableresult' action='set' />
<assign value='..Lookup("T_RegionsLab_LIO",holdobrtblkey)' property='wtableresult' action='set' />
</true>
</if>
</false>
</if>

<assign value='$PIECE(wtableresult,"|",3)' property='tGilletteOrder' action='set' />
<assign value='tGilletteOrder' property='target.{ORCgrp(1).OBRuniongrp.OBRunion.OBR:2}' action='set' />
<if condition='tGilletteOrder=""' >
<true>
<assign value='holdobr2' property='target.{ORCgrp(1).OBRuniongrp.OBRunion.OBR:2}' action='set' />
</true>
</if>

</transform>
}

}
