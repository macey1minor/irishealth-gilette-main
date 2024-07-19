Class GC.Cerner2RegLabORMpathSos Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ORM_O01' targetDocType='22.RegLab:ORM_O01' create='new' language='objectscript' >
<subtransform class='GC.Cerner2RegLabORMsub' targetObj='target' sourceObj='source' />
<code>
<![CDATA[
    // Created 11/10/2016  Al Johnson 
	// Last Updated 02/22/2017  Al Johnson
	//  Last moved to Prod 02/23/2017
	// Create: 11/10/2016 Copied and converted from Qcpr2RegLabORMpath 
	// Formats Orders for Path Procedures as required by Regions
	// Path orders send procedure code in OBR:4.1 (Cerner sending in OBR:4.2)
	// Send OBR:31 into new last NTE segment = Reason For Lab
	// unless there are order notes then those are last
	//  Cerner comments coming in OBX OBX|2|ST|COMT^Lab Order Instructions||Test Lab Order Instructions
	// For EP9911 (A-E)MOD,(A-E)SITE,(A-E)SITEMOD,(A-E)INFO changed to MOD,SITE,SITEMOD,INF
	// For 3682 3683 create NTE-2 Specimen Source with value from OBX with Specimen souce designated
]]></code>
<assign value='"Qcpr2RelLabORMpath"' property='target.{MSH:8}' action='set' />
<code>
<![CDATA[ 
	// ***************************** BASIC ORDER LOGIC ********************************
    // change discontinued (DC) orders to Cancel orders (CA)
    // moves alternate id to OBR4 second position
    // Change ASAP Priority to DD for Discharage Dependant
    // Copy OBR:4.2 to OBR:4.1
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
<assign value='""' property='target.{OBR:SpecimenSource}' action='clear' />
<code>
<![CDATA[ 
	// ***************************** PATHOLOGY ORDER LOGIC ********************************
]]></code>
<assign value='' property='target.{OBR:SpecimenReceivedDateTime}' action='clear' />
<assign value='""' property='target.{NTEi2(1)}' action='remove' />

<code>
<![CDATA[ 
	// find comment - notes in obx to create last nte segment
]]></code>
<assign value='""' property='holdcomment' action='set' />
<assign value='""' property='holdcommentdesc' action='set' />
<foreach property='source.{ORCgrp(1).OBRgrp.OBXgrp()}' key='k1' >
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1}="COMT"' >
<true>
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.2}' property='holdcommentdesc' action='set' />
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' property='holdcomment' action='set' />
</true>
</if>
</foreach>

<code>
<![CDATA[ 
	// ***************************** PATHOLOGY ORDER LOGIC Proc 3682 3683 ********************************
]]></code>
<if condition='..In(source.{ORCgrp(1).OBRgrp.OBR:4.2},"3682,3683")' >
<true>
<foreach property='source.{ORCgrp(1).OBRgrp.OBXgrp()}' key='k1' >
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"LMPD")' >
<true>
<assign value='"1"' property='target.{NTEi2(1):1}' action='set' />
<assign value='"LMP:"_target.{OBX(k1):5}' property='target.{NTEi2(1):3(1)}' action='set' />
</true>
</if>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"Specimen source")' >
<true>
<assign value='"2"' property='target.{NTEi2(2):1}' action='set' />
<assign value='"Specimen source-&gt;"_target.{OBX(k1):5}' property='target.{NTEi2(2):3(1)}' action='set' />
</true>
</if>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"PAPHX")' >
<true>
<assign value='"3"' property='target.{NTEi2(3):1}' action='set' />
<assign value='"History of Abnormal PAP/HPV-&gt;"_target.{OBX(k1):5}' property='target.{NTEi2(3):3(1)}' action='set' />
</true>
</if>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"MENSTRUAL")' >
<true>
<assign value='"4"' property='target.{NTEi2(4):1}' action='set' />
<assign value='"Menstrual status-&gt;"_target.{OBX(k1):5}' property='target.{NTEi2(4):3(1)}' action='set' />
</true>
</if>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"HORMONE")' >
<true>
<assign value='"5"' property='target.{NTEi2(5):1}' action='set' />
<assign value='"Hormones/Contraceptives-&gt;"_target.{OBX(k1):5}' property='target.{NTEi2(5):3(1)}' action='set' />
</true>
</if>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"TREATHX")' >
<true>
<assign value='"6"' property='target.{NTEi2(6):1}' action='set' />
<assign value='"Treatment History-&gt;"_target.{OBX(k1):5}' property='target.{NTEi2(6):3(1)}' action='set' />
</true>
</if>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"REFLEX")' >
<true>
<assign value='"7"' property='target.{NTEi2(7):1}' action='set' />
<assign value='"Reflex HPV Testing-&gt;"_target.{OBX(k1):5}' property='target.{NTEi2(7):3(1)}' action='set' />
</true>
</if>
<assign value='""' property='target.{OBX(k1)}' action='remove' />
</foreach>
</true>
</if>
<code>
<![CDATA[ 
	// ***************************** PATHOLOGY ORDER LOGIC Proc 09922 ********************************
]]></code>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBR:4.2},"09922")' >
<true>
<foreach property='source.{ORCgrp(1).OBRgrp.OBXgrp()}' key='k1' >
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"PATHCLINHX")' >
<true>
<assign value='"1"' property='target.{NTEi2(1):1}' action='set' />
<assign value='"Pertinent Clinical History/Evaluate for?-&gt;"_target.{OBX(k1):5}' property='target.{NTEi2(1):3(1)}' action='set' />
</true>
</if>
<assign value='""' property='target.{OBX(k1)}' action='remove' />
</foreach>
</true>
</if>
<code>
<![CDATA[ 
	// ***************************** PATHOLOGY ORDER LOGIC Proc RH9019 ********************************
]]></code>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBR:4.2},"RH9019")' >
<true>
<foreach property='source.{ORCgrp(1).OBRgrp.OBXgrp()}' key='k1' >
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"PATHSUSPECT")' >
<true>
<assign value='"1"' property='target.{NTEi2(1):1}' action='set' />
<assign value='"Suspicious Of?-&gt;"_target.{OBX(k1):5}' property='target.{NTEi2(1):3(1)}' action='set' />
</true>
</if>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"PATHCLINHX")' >
<true>
<assign value='"2"' property='target.{NTEi2(2):1}' action='set' />
<assign value='"Pertinent Clinical History/Evaluate for?-&gt;"_target.{OBX(k1):5}' property='target.{NTEi2(2):3(1)}' action='set' />
</true>
</if>
<assign value='""' property='target.{OBX(k1)}' action='remove' />
</foreach>
</true>
</if>

<code>
<![CDATA[ 
	// ***************************** PATHOLOGY ORDER LOGIC Proc 0471 ********************************
]]></code>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBR:4.2},"0471")' >
<true>
<assign value='"2"' property='target.{NTEi2(2):1}' action='set' />
<assign value='"Cytology specimen source-&gt;"_source.{ORCgrp(1).OBRgrp.OBR:15.2}' property='target.{NTEi2(2):3(1)}' action='set' />
<foreach property='source.{ORCgrp(1).OBRgrp.OBXgrp()}' key='k1' >
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"PATHCLINHX")' >
<true>
<assign value='"1"' property='target.{NTEi2(1):1}' action='set' />
<assign value='"Pertinent Clinical History/Evaluate for?-&gt;"_target.{OBX(k1):5}' property='target.{NTEi2(1):3(1)}' action='set' />
</true>
</if>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"CYTOSPECMOD")' >
<true>
<assign value='"2"' property='target.{NTEi2(3):1}' action='set' />
<assign value='"For Bronchoscopy specimens only, evaluate for:-&gt;"_target.{OBX(k1):5}' property='target.{NTEi2(3):3(1)}' action='set' />
</true>
</if>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"CYTOSPECADD")' >
<true>
<assign value='"3"' property='target.{NTEi2(4):1}' action='set' />
<assign value='"For Bronchoscopy specimens only, evaluate for:-&gt;"_target.{OBX(k1):5}' property='target.{NTEi2(4):3(1)}' action='set' />
</true>
</if>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"CYTOBRONCH")' >
<true>
<assign value='"4"' property='target.{NTEi2(5):1}' action='set' />
<assign value='"For Bronchoscopy specimens only, evaluate for:-&gt;"_target.{OBX(k1):5}' property='target.{NTEi2(5):3(1)}' action='set' />
</true>
</if>
<assign value='""' property='target.{OBX(k1)}' action='remove' />
</foreach>
</true>
</if>
<code>
<![CDATA[ 
	// ***************************** PATHOLOGY ORDER LOGIC Proc EP9907 ********************************
]]></code>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBR:4.2},"EP9907")' >
<true>
<assign value='"2"' property='target.{NTEi2(2):1}' action='set' />
<assign value='"Cytology FNA specimen source-&gt;"_source.{ORCgrp(1).OBRgrp.OBR:15.2}' property='target.{NTEi2(2):3(1)}' action='set' />
<foreach property='source.{ORCgrp(1).OBRgrp.OBXgrp(k1)}' key='k1' >
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"PATHCLINHX")' >
<true>
<assign value='"1"' property='target.{NTEi2(1):1}' action='set' />
<assign value='"Pertinent Clinical History/Evaluate for?-&gt;"_target.{OBX(k1):5}' property='target.{NTEi2(1):3(1)}' action='set' />
</true>
</if>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"CYTOSPECMOD")' >
<true>
<assign value='"3"' property='target.{NTEi2(3):1}' action='set' />
<assign value='"Specimen Modifier-&gt;"_target.{OBX(k1):5}' property='target.{NTEi2(3):3(1)}' action='set' />
</true>
</if>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"CYTOSPECADD")' >
<true>
<assign value='"4"' property='target.{NTEi2(4):1}' action='set' />
<assign value='"Specimen Addtl Info-&gt;"_target.{OBX(k1):5}' property='target.{NTEi2(4):3(1)}' action='set' />
</true>
</if>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"CYTOAIR")' >
<true>
<assign value='"5"' property='target.{NTEi2(5):1}' action='set' />
<assign value='"Number of air-dried slides-&gt;"_target.{OBX(k1):5}' property='target.{NTEi2(5):3(1)}' action='set' />
</true>
</if>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"CYTOFIXED")' >
<true>
<assign value='"6"' property='target.{NTEi2(6):1}' action='set' />
<assign value='"Number of fixed slides-&gt;"_target.{OBX(k1):5}' property='target.{NTEi2(6):3(1)}' action='set' />
</true>
</if>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"CYTOFLUID")' >
<true>
<assign value='"7"' property='target.{NTEi2(7):1}' action='set' />
<assign value='"Fluid collected?-&gt;"_target.{OBX(k1):5}' property='target.{NTEi2(7):3(1)}' action='set' />
</true>
</if>
<assign value='""' property='target.{OBX(k1)}' action='remove' />
</foreach>
</true>
</if>
<code>
<![CDATA[ 
	// ***************************** PATHOLOGY ORDER LOGIC Proc 0438 ********************************
]]></code>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBR:4.2},"0438")' >
<true>
<assign value='"2"' property='target.{NTEi2(2):1}' action='set' />
<assign value='"Flow Cytometry specimen source-&gt;"_source.{ORCgrp(1).OBRgrp.OBR:15.2}' property='target.{NTEi2(2):3(1)}' action='set' />
<foreach property='source.{ORCgrp(1).OBRgrp.OBXgrp(k1)}' key='k1' >
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"PATHCLINHX")' >
<true>
<assign value='"1"' property='target.{NTEi2(1):1}' action='set' />
<assign value='"Pertinent Clinical History/Evaluate for?-&gt;"_target.{OBX(k1):5}' property='target.{NTEi2(1):3(1)}' action='set' />
</true>
</if>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"BONEMOLE")' >
<true>
<assign value='"2"' property='target.{NTEi2(2):1}' action='set' />
<assign value='"Flow cytometry studies:-&gt;"_target.{OBX(k1):5}' property='target.{NTEi2(2):3(1)}' action='set' />
</true>
</if>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"BONECYTO")' >
<true>
<assign value='"3"' property='target.{NTEi2(3):1}' action='set' />
<assign value='"Cytogenetics-&gt;"_target.{OBX(k1):5}' property='target.{NTEi2(3):3(1)}' action='set' />
</true>
</if>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"BONECULT")' >
<true>
<assign value='"4"' property='target.{NTEi2(4):1}' action='set' />
<assign value='"Cultures:-&gt;"_target.{OBX(k1):5}' property='target.{NTEi2(4):3(1)}' action='set' />
</true>
</if>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"BONESTAIN")' >
<true>
<assign value='"5"' property='target.{NTEi2(5):1}' action='set' />
<assign value='"Stain:-&gt;"_target.{OBX(k1):5}' property='target.{NTEi2(5):3(1)}' action='set' />
</true>
</if>
<assign value='""' property='target.{OBX(k1)}' action='remove' />
</foreach>
</true>
</if>
<code>
<![CDATA[ 
	// ***************************** PATHOLOGY ORDER LOGIC Proc RH0357 ********************************
]]></code>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBR:4.2},"RH0357")' >
<true>
<foreach property='source.{ORCgrp(1).OBRgrp.OBXgrp()}' key='k1' >
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"CODE1")' >
<true>
<assign value='"1"' property='target.{NTEi2(1):1}' action='set' />
<assign value='"Pertinent Clinical History/Evaluate for?-&gt;"_target.{OBX(k1):5}' property='target.{NTEi2(1):3(1)}' action='set' />
</true>
</if>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"FLOWSTUDIES")' >
<true>
<assign value='"2"' property='target.{NTEi2(2):1}' action='set' />
<assign value='"Flow cytometry studies:-&gt;"_target.{OBX(k1):5}' property='target.{NTEi2(2):3(1)}' action='set' />
</true>
</if>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"CODE3")' >
<true>
<assign value='"3"' property='target.{NTEi2(3):1}' action='set' />
<assign value='"Cytogenetics-&gt;"_target.{OBX(k1):5}' property='target.{NTEi2(3):3(1)}' action='set' />
</true>
</if>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"CODE4")' >
<true>
<assign value='"4"' property='target.{NTEi2(4):1}' action='set' />
<assign value='"Cultures:-&gt;"_target.{OBX(k1):5}' property='target.{NTEi2(4):3(1)}' action='set' />
</true>
</if>
<assign value='""' property='target.{OBX(k1)}' action='remove' />
<code>
<![CDATA[ 
	// ***************************** PATHOLOGY ORDER LOGIC Proc EP9911 ********************************
]]></code>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBR:4.2},"EP9911")' >
<true>
<foreach property='source.{ORCgrp(1).OBRgrp.OBXgrp()}' key='k1' >
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"PATHCLINHX")' >
<true>
<assign value='"1"' property='target.{NTEi2(1):1}' action='set' />
<assign value='"Pertinent Clinical History/Evaluate for?-&gt;"_target.{OBX(k1):5}' property='target.{NTEi2(1):3(1)}' action='set' />
</true>
</if>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"CODE2")' >
<true>
<assign value='"2"' property='target.{NTEi2(2):1}' action='set' />
<assign value='"Container A Specimen Site (Tissue)-&gt;"_target.{OBX(k1):5}' property='target.{NTEi2(2):3(1)}' action='set' />
</true>
</if>
<assign value='""' property='target.{OBX(k1)}' action='remove' />
</foreach>
</true>
</if>
</foreach>
</true>
</if>
<code>
<![CDATA[ 
	// ***************************** PATHOLOGY ORDER LOGIC Proc EP9911 ********************************
]]></code>
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBR:4.2},"EP9911")' >
<true>
<assign value='"2"' property='target.{NTEi2(2):1}' action='set' />
<assign value='"Surgical Path specimen source-&gt;"_source.{ORCgrp(1).OBRgrp.OBR:15.3}' property='target.{NTEi2(2):3(1)}' action='set' />
<foreach property='source.{ORCgrp(1).OBRgrp.OBXgrp()}' key='k1' >
<if condition='..Contains(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3},"CLINHX")' >
<true>
<assign value='"1"' property='target.{NTEi2(1):1}' action='set' />
<assign value='"Pertinent Clinical History/Evaluate for?-&gt;"_target.{OBX(k1):5}' property='target.{NTEi2(1):3(1)}' action='set' />
</true>
</if>
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1} = "MOD"' >
<true>
<assign value='"3"' property='target.{NTEi2(3):1}' action='set' />
<assign value='"Container A Specimen Site(Info)-&gt;"_source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' property='target.{NTEi2(3):3(1)}' action='set' />
<assign value='""' property='target.{OBX(k1)}' action='remove' />
</true>
</if>
<if condition='(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1} = "SITE") &amp; ($LENGTH(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}) &gt; 0)' >
<true>
<assign value='" - "_source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' property='target.{NTEi2(3):3(1)}' action='append' />
<assign value='""' property='target.{OBX(k1)}' action='remove' />
</true>
</if>
<if condition='(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1} = "SITEMOD") &amp; ($LENGTH(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}) &gt; 0)' >
<true>
<assign value='" - "_source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' property='target.{NTEi2(3):3(1)}' action='append' />
<assign value='""' property='target.{OBX(k1)}' action='remove' />
</true>
</if>
<if condition='(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1} = "INFO") &amp; ($LENGTH(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}) &gt; 0)' >
<true>
<assign value='" - "_source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' property='target.{NTEi2(3):3(1)}' action='append' />
<assign value='""' property='target.{OBX(k1)}' action='remove' />
</true>
</if>
<assign value='""' property='target.{OBX(k1)}' action='remove' />
</foreach>
</true>
</if>
<code>
<![CDATA[     // ************ Remove blank NTE
  ]]></code>
<if condition='($LENGTH(target.{NTEi2(1):1}) &lt; 1)' >
<true>
<assign value='""' property='target.{NTEi2(1)}' action='remove' />
</true>
</if>
<code>
<![CDATA[     // ***************************  Add NTE at end for OBR:31 Information
     //  add NTE for OBX comment line extracted into holdcomment
     //  original $Extract(source.{ORCgrp(1).OBRgrp.OBXgrp(1).NTE:3(1)},1,20)
     //
     //   <assign value='$Extract(holdcomment,1,20)' property='target.{NTEi2(NTECOUNT):3(1)}' action='set' />
holdcomment
  ]]></code>
<assign value='"1"' property='NTECOUNT' action='set' />
<foreach property='target.{NTEi2()}' key='k4' >
<assign value='NTECOUNT+1' property='NTECOUNT' action='set' />
</foreach>

<if condition='($LENGTH(holdcomment) &lt; 1)' >
<false>
<assign value='holdcommentdesc_"-&gt;"_holdcomment' property='target.{NTEi2(NTECOUNT):3}' action='set' />
<assign value='NTECOUNT' property='target.{NTEi2(NTECOUNT):1}' action='set' />
<assign value='NTECOUNT+1' property='NTECOUNT' action='set' />
</false>
</if>

<assign value='NTECOUNT' property='target.{NTEi2(NTECOUNT):1}' action='set' />
<assign value='"Reason For Lab-&gt;"_source.{ORCgrp(1).OBRgrp.OBR:31(1).1}' property='target.{NTEi2(NTECOUNT):3}' action='set' />

</transform>
}

}
