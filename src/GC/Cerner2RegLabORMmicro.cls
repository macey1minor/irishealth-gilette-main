Class GC.Cerner2RegLabORMmicro Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ORM_O01' targetDocType='22.RegLab:ORM_O01' create='new' language='objectscript' >
<subtransform class='GC.Cerner2RegLabORMsub' targetObj='target' sourceObj='source' />
<code>
<![CDATA[ 
	//  Last Updated 11/23/2016
	//  Last Updated in Prod: 01/23/2016 Al Johnson
	//  Create: 11/23/2016  Al Johnson 
	//  Description:  
	//	Uses subtransform Qcpr2RegLabORMSub  also for ORC and OBR
	//  Version of Lab Orders for Microbiology - original source GCH.QCPR2RegLabORM
	// ***************************** START ORDER LOGIC ********************************
    // for new orders
    // -- ? get calcium ionized labels to print in PICU put L in OBR 11 specimen Action Code
    // change discontinued (DC) orders to Cancel orders (CA)
    // moves alternate id to OBR4 second position
    // Change ASAP Priority to DD for Discharage Dependant
    // Clear Specimen Source
    // Config Custom Questions for BB SDES CSFT and BFT
    // Dont send blank OBX
    // only send first 20 characters of NTE comment

]]></code>
<assign value='"Qcpr2RegLabORM2"' property='target.{MSH:8}' action='set' />
<code>
<![CDATA[ 
	// ***************************** START ORDER LOGIC ********************************
    // for new orders
    // get calcium ionized labels to print in PICU put L in OBR 11 specimen Action Code
    // change discontinued (DC) orders to Cancel orders (CA)
    // moves alternate id to OBR4 second position
    // Change ASAP Priority to DD for Discharage Dependant
    // Clear Specimen Source
    //
    // <if condition='(..Contains(source.{ORCgrp(1).OBRgrp.OBR:UniversalServiceID.identifier},"CAWB")) &amp; (..Contains(source.{PV1:AssignedPatientLocation.nurseunitStation},"0IC")) ' >
    //  <true>
    //  <assign value='"L"' property='target.{OBR:SpecimenActionCode}' action='set' />
    //
    //   <assign value='""' property='target.{OBR:SpecimenSource}' action='clear' /> 
]]></code>

<if condition='..Contains(source.{ORCgrp(1).ORC:OrderControl},"DC")' >
<true>
<assign value='"CA"' property='target.{ORC:OrderControl}' action='set' />
</true>
</if>

<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBR:Quantitytiming(1).priority},"ASAP")' >
<true>
<assign value='"DD"' property='target.{OBR:Quantitytiming(1).priority}' action='set' />
</true>
</if>

<code>
<![CDATA[  	// *****************************  OBX LOGIC ********************************
]]></code>

<code>
<![CDATA[ 
	// find comment and site description in obx segments
]]></code>
<assign value='""' property='holdcomment' action='set' />
<assign value='""' property='holdcommentdesc' action='set' />
<assign value='""' property='holdsdes' action='set' />
<assign value='""' property='holdsite' action='set' />
<assign value='""' property='holdmodifier' action='set' />
<assign value='""' property='holdmodifierdesc' action='set' />
<foreach property='source.{ORCgrp(1).OBRgrp.OBXgrp()}' key='k1' >
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1}="COMT"' >
<true>
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' property='holdcomment' action='set' />
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.2}' property='holdcommentdesc' action='set' />
</true>
</if>
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1}="SDES"' >
<true>
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' property='holdsdes' action='set' />
</true>
</if>
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1}="SITE"' >
<true>
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' property='holdsite' action='set' />
</true>
</if>
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1}="MODIFIER"' >
<true>
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' property='holdmodifier' action='set' />
</true>
</if>
</foreach>

<code>
<![CDATA[     // *************************** Remove OBX from output OBX
]]></code>
<foreach property='target.{OBX()}' key='k1' >
<assign value='' property='target.{OBX(k1)}' action='remove' />
</foreach>

<code>
<![CDATA[     // *************************** Config Custom Questions for SDES
    // create SDES whether blank or not - others only if values
]]></code>

<assign value='"1"' property='target.{OBX(1):SetIDOBX}' action='set' />
<assign value='"ST"' property='target.{OBX(1):2}' action='set' />
<assign value='"SDES"' property='target.{OBX(1):3}' action='set' />
<assign value='holdsdes' property='target.{OBX(1):5}' action='set' />
<assign value='""' property='target.{OBX(1):ProducersID}' action='set' />


<if condition='($LENGTH(holdsite) &lt; 1)' >
<false>
<assign value='"2"' property='target.{OBX(2):SetIDOBX}' action='set' />
<assign value='"ST"' property='target.{OBX(2):2}' action='set' />
<assign value='"SDES"' property='target.{OBX(2):3.1}' action='set' />
<assign value='"SITE"' property='target.{OBX(2):3.2}' action='set' />
<assign value='holdsite' property='target.{OBX(2):5}' action='set' />
<assign value='""' property='target.{OBX(2):ProducersID}' action='set' />
</false>
</if>

<if condition='($LENGTH(holdmodifier) &lt; 1)' >
<false>
<assign value='"3"' property='target.{OBX(3):SetIDOBX}' action='set' />
<assign value='"ST"' property='target.{OBX(3):2}' action='set' />
<assign value='"SDES"' property='target.{OBX(3):3.1}' action='set' />
<assign value='"MODIFIER"' property='target.{OBX(3):3.2}' action='set' />
<assign value='holdmodifier' property='target.{OBX(3):5}' action='set' />
<assign value='""' property='target.{OBX(3):ProducersID}' action='set' />
</false>
</if>

<code>
<![CDATA[     // *************************** Config Specimen Source  for CSFT and BFT
    //
    //  check on this code 
    //  <if condition='..In(source.{ORCgrp(1).OBRgrp.OBR:4.2},"CSFT,BFT") ' >
    //  <true>
    //  <assign value='(target.{OBX(*)}+1)' property='OBXnum' action='set' />
    //  <assign value='OBXnum' property='target.{OBX(OBXnum):1}' action='set' />
    //  <assign value='"ST"' property='target.{OBX(OBXnum):2}' action='set' />
    //  <assign value='"SOURC"' property='target.{OBX(OBXnum):3}' action='set' />
    //  <assign value='source.{ORCgrp(1).OBRgrp.OBR:15.2}' property='target.{OBX(OBXnum):5(1)}' action='set' />
    //  </true>
    //  </if>
]]></code>

<code>
<![CDATA[     // *************************** Remove blank NTE
   // only send first 20 characters of NTE comment per Todd 9/8/20
]]></code>
<if condition='($LENGTH(holdcomment) &lt; 1)' >
<true>
<assign value='""' property='target.{NTEi2(1)}' action='remove' />
</true>
<false>
<assign value='holdcommentdesc' property='target.{NTEi2(1):1}' action='set' />
<assign value='$Extract(holdcomment,1,20)' property='target.{NTEi2(1):3(1)}' action='set' />
</false>
</if>

<assign value='$ZCONVERT(target.{PID},"U" )' property='target.{PID}' action='set' />

</transform>
}

}
