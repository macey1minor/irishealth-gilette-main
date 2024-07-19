Class GC.RegLab2CernerBkrORM Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='251.Regions:ORM_O01' targetDocType='251.Regions:ORM_O01' create='copy' language='objectscript' >
<code>
<![CDATA[ 
	//  Last Update: 04/19/2019 Al Johnson
	//  Last Moved to Prod:  05/01/2019 Al Johnson
    //  Created 01/08/2019 Al Johnson
    //
    //  Check for Parent (ordered item) in OBR-50
    //  Panels are resulted on components
    //  Change OBR:4.1 to OBR:50.1 if valued and differnet
    //  If changing OBR:4.1 and status, add NTE segment
    //
    //  do not change obr-25 - send thru value from regions - 3/5/2019
    //  remove NTE segment, build ORU for panel off ORU for components - 3/11/2019
    //
	//  read Table = T_RegionsLab_OrderedConversion -if on table update OBR-4.2 with original value 4/19/2019
]]></code>

<foreach property='target.{ORCgrp()}' key='k1' >
<if condition='target.{ORCgrp(k1).OBRuniongrp.OBRunion.OBR:50.1}=""' >
<false>
<if condition='target.{ORCgrp(k1).OBRuniongrp.OBRunion.OBR:4.1}= target.{ORCgrp(k1).OBRuniongrp.OBRunion.OBR:50.1}' >
<false>
<assign value='target.{ORCgrp(k1).OBRuniongrp.OBRunion.OBR:50.1}' property='target.{ORCgrp(k1).OBRuniongrp.OBRunion.OBR:4.1}' action='set' />
<assign value='""' property='target.{ORCgrp(k1).OBRuniongrp.OBRunion.OBR:3}' action='set' />
</false>
</if>
</false>
</if>
</foreach>

<foreach property='target.{ORCgrp()}' key='k4' >
<assign value='target.{ORCgrp(k4).OBRuniongrp.OBRunion.OBR:2.1}' property='wTableKeyOrdered' action='set' />
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
<assign value='wtableresultordered' property='target.{ORCgrp(k4).OBRuniongrp.OBRunion.OBR:4.1}' action='set' />
</false>
</if>
</foreach>

</transform>
}

}
