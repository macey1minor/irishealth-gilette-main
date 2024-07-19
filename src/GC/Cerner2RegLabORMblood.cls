Class GC.Cerner2RegLabORMblood Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
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
	//  Version of Lab Orders for Blood Bank - original source GCH.QCPR2RegLabORM
	// ***************************** START ORDER LOGIC ********************************
    // for new orders
    // -- et calcium ionized labels to print in PICU put L in OBR 11 specimen Action Code
    // change discontinued (DC) orders to Cancel orders (CA)
    // Change ASAP Priority to DD for Discharage Dependant
    // -- Clear Specimen Source
    // Config Custom Questions for BB SDES CSFT and BFT
    // Dont send blank OBX
    // only send first 20 characters of NTE comment
    // source uses schema 231.Cerner - target 22.RegLab - be careful of OBX qualifiers

]]></code>
<assign value='"Cerner2RegLabORMblood"' property='target.{MSH:8}' action='set' />
<code>
<![CDATA[ 
	// ***************************** START ORDER LOGIC ********************************
    // for new orders
    // get calcium ionized labels to print in PICU put L in OBR 11 specimen Action Code
    // change discontinued (DC) orders to Cancel orders (CA)
    // moves alternate id to OBR4 second position
    // Change ASAP Priority to DD for Discharage Dependant
    // Clear Specimen Source
    // <if condition='(..Contains(source.{ORCgrp(1).OBRgrp.OBR:UniversalServiceID.identifier},"CAWB")) &amp; (..Contains(source.{PV1:AssignedPatientLocation.nurseunitStation},"0IC")) ' >
    // <true>
    // <assign value='"L"' property='target.{OBR:SpecimenActionCode}' action='set' />
    //
    // <assign value='""' property='target.{OBR:SpecimenSource}' action='clear' />
    
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
	// remove obx segments from target - subtransform copied all
	// will rebuild for blood bank orders
]]></code>

<foreach property='target.{OBX()}' key='k1' >
<assign value='' property='target.{OBX(k1)}' action='remove' />
</foreach>

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

<assign value='0' property='oc' action='set' />
<foreach property='source.{ORCgrp(1).OBRgrp.OBXgrp()}' key='k1' >
<assign value='oc + 1' property='oc' action='set' />
<code>
<![CDATA[     // *************************** Config Custom Questions  for BB
]]></code>
<if condition='$Extract(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1},1,2) = "BB" ' >
<true>
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1} = "BB%UO" ' >
<true>
<assign value='"1"' property='target.{OBX(1):1}' action='set' />
<assign value='"ST"' property='target.{OBX(1):2}' action='set' />
<assign value='"%UO"' property='target.{OBX(1):3}' action='set' />
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5(1)}' property='target.{OBX(1):5(1)}' action='set' />
</true>
</if>
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1} = "BB%PI11" ' >
<true>
<if condition='source.{ORCgrp(1).OBRgrp.OBR:4.1} = "TRBC" ' >
<true>
<assign value='"5"' property='target.{OBX(5):1}' action='set' />
<assign value='"ST"' property='target.{OBX(5):2}' action='set' />
<assign value='"%PI"' property='target.{OBX(5):3}' action='set' />
<assign value='"REQ: "_source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5(1)}' property='target.{OBX(5):5(1)}' action='set' />
</true>
<false>
<assign value='"2"' property='target.{OBX(2):1}' action='set' />
<assign value='"ST"' property='target.{OBX(2):2}' action='set' />
<assign value='"%PI"' property='target.{OBX(2):3}' action='set' />
<assign value='"REQ: "_source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5(1)}' property='target.{OBX(2):5(1)}' action='set' />
</false>
</if>
</true>
</if>
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1} = "BBC11" ' >
<true>
<assign value='"2"' property='target.{OBX(2):1}' action='set' />
<assign value='"ST"' property='target.{OBX(2):2}' action='set' />
<assign value='"%PI"' property='target.{OBX(2):3}' action='set' />
<assign value='"CONSENT: "_source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5(1)}' property='target.{OBX(2):5(1)}' action='set' />
</true>
</if>
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:ObservationIdentifier.identifier} = "BBC12" ' >
<true>
<assign value='"3"' property='target.{OBX(3):1}' action='set' />
<assign value='"ST"' property='target.{OBX(3):2}' action='set' />
<assign value='"%PI"' property='target.{OBX(3):3}' action='set' />
<assign value='"INDCT: "_source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5(1)}' property='target.{OBX(3):5(1)}' action='set' />
</true>
</if>
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:ObservationIdentifier.identifier} = "BBC13" ' >
<true>
<assign value='"4"' property='target.{OBX(4):1}' action='set' />
<assign value='"ST"' property='target.{OBX(4):2}' action='set' />
<assign value='"%PI"' property='target.{OBX(4):3}' action='set' />
<assign value='"RATE: "_source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5(1)}' property='target.{OBX(4):5(1)}' action='set' />
</true>
</if>
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:ObservationIdentifier.identifier} = "BB%PI1A" ' >
<true>
<assign value='"5"' property='target.{OBX(5):1}' action='set' />
<assign value='"ST"' property='target.{OBX(5):2}' action='set' />
<assign value='"%PI"' property='target.{OBX(5):3}' action='set' />
<assign value='"IRR: "_source.{OBX(k1):5(1)}' property='target.{OBX(5):5(1)}' action='set' />
</true>
</if>
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:ObservationIdentifier.identifier} = "BBNUO" ' >
<true>
<assign value='"1"' property='target.{OBX(1):1}' action='set' />
<assign value='"ST"' property='target.{OBX(1):2}' action='set' />
<assign value='"%PI"' property='target.{OBX(1):3}' action='set' />
<assign value='"ML "_source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5(1)}' property='target.{OBX(1):5(1)}' action='set' />
</true>
</if>
<if condition='(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:ObservationIdentifier.identifier} = "BBNU") &amp; (..DoesNotContain(source.{OBX(k1):5(1)},"CC")) ' >
<true>
<assign value='"1"' property='target.{OBX(1):1}' action='set' />
<assign value='"ST"' property='target.{OBX(1):2}' action='set' />
<assign value='"%UO"' property='target.{OBX(1):3}' action='set' />
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5(1)}' property='target.{OBX(1):5(1)}' action='set' />
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5(1).2}' property='target.{OBX(1):5(1).2}' action='set' />
</true>
</if>
<if condition='(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:ObservationIdentifier.identifier} = "BBP113") &amp; (source.{OBX(k1):5(1)} &gt; "0") ' >
<true>
<assign value='"1"' property='target.{OBX(1):1}' action='set' />
<assign value='"ST"' property='target.{OBX(1):2}' action='set' />
<assign value='"%PI"' property='target.{OBX(1):3}' action='set' />
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5(1)}_" ML PEDS UNITS"' property='target.{OBX(1):5(1)}' action='set' />
</true>
</if>
</true>
<false>
<code>
<![CDATA[     // *************************** Config Custom Questions for SDES
]]></code>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:ObservationIdentifier.identifier},"SDES")' >
<true>
<if condition='($LENGTH(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:ObservationIdentifier.text}) &lt; 1)' >
<true>
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX}' property='target.{OBX(1)}' action='set' />
<assign value='"1"' property='target.{OBX(1):SetIDOBX}' action='set' />
<assign value='"MAS1"' property='target.{OBX(1):ProducersID}' action='set' />
</true>
</if>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:ObservationIdentifier.text},"SITE")' >
<true>
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX}' property='target.{OBX(2)}' action='set' />
<assign value='"2"' property='target.{OBX(2):SetIDOBX}' action='set' />
<assign value='"MAS2"' property='target.{OBX(2):ProducersID}' action='set' />
</true>
</if>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:ObservationIdentifier.text},"MODIFIER")' >
<true>
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX}' property='target.{OBX(3)}' action='set' />
<assign value='"3"' property='target.{OBX(3):SetIDOBX}' action='set' />
<assign value='"MAS3"' property='target.{OBX(3):ProducersID}' action='set' />
</true>
</if>
</true>
<false>
<assign property='tempOBX' value='""' />
<assign property='tempOBX3type' value='""' />
<assign  property='tempOBX3type' value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1}' action='set' /> 
<if condition='(tempOBX3type = "Requested Start Date/Time") || (tempOBX3type = "COMT")' >
<false>
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX}' property='target.{OBX(k1)}' action='set' />
</false>
</if>
</false>
</if>
</false>
</if>
<code>
<![CDATA[     // *************************** Config Specimen Source  for CSFT and BFT
]]></code>
<if condition='..In(source.{ORCgrp(1).OBRgrp.OBR:4.2},"CSFT,BFT") ' >
<true>
<assign value='(target.{OBX(*)}+1)' property='OBXnum' action='set' />
<assign value='OBXnum' property='target.{OBX(OBXnum):1}' action='set' />
<assign value='"ST"' property='target.{OBX(OBXnum):2}' action='set' />
<assign value='"SOURC"' property='target.{OBX(OBXnum):3}' action='set' />
<assign value='source.{ORCgrp(1).OBRgrp.OBR:15.2}' property='target.{OBX(OBXnum):5(1)}' action='set' />
</true>
</if>
<code>
<![CDATA[     // *************************** Remove blank OBX
]]></code>
<if condition='target.{OBX(k1):ObservationValue} = ""' >
<true>
<assign value='' property='target.{OBX(k1)}' action='remove' />
</true>
</if>
</foreach>

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
