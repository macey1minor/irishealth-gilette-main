Class GC.ClevelandClinic2CernerBase64 Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.ClevelandClinic:ORU_R01' targetDocType='231.Cerner:ORU_R01' create='new' language='objectscript' >
<code>
<![CDATA[ 
	//  Last Updated 04/28/2020
	//  Last Updated in Prod: 05/07/2020 Al Johnson
	//  Create: 04/28/2020  Al Johnson 
	//  Description:  
	//	ORU from Cleveland Clinic base64 report
	//  Cleveland Clinic is monitoring inpatient sleep studies
    //
    //  no Gillette order OBR-2 placer order
    //
    //  started with logic from vyaire-carefusion pft
    //   Result on order without the PFT appended will go to the message center  07/09/2018
    //  Copy OBR:7 if populated, else MSH:7 to OBR:22 resultstatuschangedate.  07/09/2018
    //  Copy OBR:7 if populated, else MSH:7 to OBR:27.4 quatitytimingstartdate.  07/09/2018
]]></code>

<code>
<![CDATA[ 
    //  format MSH, remove GC from mrn
]]></code>
<assign value='source.{MSH}' property='target.{MSH}' action='set' />
<assign value='"CLEVELANDCLINIC"' property='target.{MSH:3}' action='set' />
<assign value='"MMF"' property='target.{MSH:5}' action='set' />

<assign value='source.{PID}' property='target.{PID}' action='set' />
<assign value='""' property='target.{PID:3}' action='set' />
<assign value='source.{PID:3(1).1}' property='target.{PID:3}' action='set' />
<assign value='$REPLACE(target.{PID:3},"GC","")' property='target.{PID:3}' action='set' />

<code>
<![CDATA[ 
    //  format file name for obx
]]></code>
<assign value='source.{ORCgrp(1).OBR}' property='target.{ORCgrp(1).OBR}' action='set' />
<assign value='source.{ORCgrp(1).OBR:3.1}' property='tmpfillerorder' action='set' />
<assign value='source.{ORCgrp(1).OBR:4.1}' property='tmpobr4' action='set' />
<assign value='"MDOC"' property='target.{ORCgrp(1).OBR:24}' action='set' />
<assign value='tmpfillerorder_".pdf"' property='tmpfilename' action='set' />

<code>
<![CDATA[ 
    //  Get Cleveland Clinic Gillette doctor number off table
    //   read table using doctor last name
    //   Remove OBR-16 ordering doc
]]></code>

<assign value='""' property='target.{ORCgrp(1).OBR:16}' action='set' />
    
<assign value='source.{ORCgrp(1).OBR:32.2}' property='wTableKey' action='set' />
<assign value='""' property='wtableresult' action='set' />
<assign value='..Lookup("T_ClevelandClinic_Docs",wTableKey)' property='wtableresult' action='set' />
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
    // table entry found - change doc id in message
]]></code>
    <assign value='wtableresult' property='target.{ORCgrp(1).OBR:32}' action='set' />
    </false>
    </if>

<code>
<![CDATA[ 
    //  Populate OBR:22 and OBR:27.4
    //  There is no Gillette OrderID
    //  Create ORC if not sent
]]></code>
<if condition='source.{ORCgrp(1).ORC}=""' >
<true>
<assign value='source.{ORCgrp(1).OBR:3.1}' property='target.{ORCgrp(1).ORC:3}' action='set' />
</true>
<false>
<assign value='source.{ORCgrp(1).ORC:3.1}' property='target.{ORCgrp(1).ORC:3}' action='set' />
</false>
</if>
<assign value='"RE"' property='target.{ORCgrp(1).ORC:1}' action='set' />

<assign value='"1"' property='target.{ORCgrp(1).OBR:1}' action='set' />
<assign value='source.{ORCgrp(1).OBR:3.1}' property='target.{ORCgrp(1).OBR:3}' action='set' />
<assign value='""' property='tholdresultdate' action='set' />
<if condition='(source.{ORCgrp(1).OBR:7.1}="")' >
<true>
<assign value='source.{MSH:7.1}' property='tholdresultdate' action='set' />
</true>
<false>
<assign value='source.{ORCgrp(1).OBR:7.1}' property='tholdresultdate' action='set' />
</false>
</if>
<if condition='(source.{ORCgrp(1).OBR:22.1}="")' >
<true>
<assign value='tholdresultdate' property='target.{ORCgrp(1).OBR:22}' action='set' />
</true>
</if>
<if condition='(source.{ORCgrp(1).OBR:27.4}="")' >
<true>
<assign value='tholdresultdate' property='target.{ORCgrp(1).OBR:27.4}' action='set' />
</true>
</if>

<code>
<![CDATA[ 
    // Cleveland Clinic sends a number of OBX segments - only send the base64 report
    //  The type is ED encapsulated data
    // NTE segment following OBR if NTE-3 = PMC, change OBR-4.1 = PMC1
    //  PMC = Patient Management Conference
    //  All other values pass thru
    //  EEGPMU1 = Non Invasive PMU Evaluation
    //  EEGPMU2 = Invasive PMU Evaluation
    //  VEEG1 = Non Invasive Video - EEG Monitoring Report
    //  VEEG2 = Invasive Video - EEG Monitoring Report
]]></code>

<foreach property='source.{ORCgrp(1).NTE()}' key='k2' >
<if condition='source.{ORCgrp(1).NTE(k2):3(1)}="PMC"' >
<true>
<assign value='"PMC1"' property='tmpobr4' action='set' />
<assign value='"PMC1"' property='target.{ORCgrp(1).OBR:4.1}' action='set' />
<assign value='tmpfillerorder_"-PMC1.pdf"' property='tmpfilename' action='set' />
</true>
</if>
</foreach>

<code>
<![CDATA[ 
    // Cleveland Clinic sends a number of OBX segments - only send the base64 report
    //  The type is ED encapsulated data
]]></code>

<assign value='"0"' property='tmpobxseq' action='set' />
<foreach property='source.{ORCgrp(1).OBXgrp()}' key='k1' >
<if condition='source.{ORCgrp(1).OBXgrp(k1).OBX:2}="ED"' >
<true>
<assign value='tmpobxseq + 1' property='tmpobxseq' action='set' />
<assign value='source.{ORCgrp(1).OBXgrp(k1).OBX}' property='target.{ORCgrp(1).OBXgrp(tmpobxseq).OBX}' action='set' />
<assign value='tmpobxseq' property='target.{ORCgrp(1).OBXgrp(tmpobxseq).OBX:1}' action='set' />
<assign value='""' property='target.{ORCgrp(1).OBXgrp(tmpobxseq).OBX:3}' action='set' />
<assign value='tmpobr4' property='target.{ORCgrp(1).OBXgrp(tmpobxseq).OBX:3.1}' action='set' />
<assign value='tmpobr4' property='target.{ORCgrp(1).OBXgrp(tmpobxseq).OBX:3.2}' action='set' />
<assign value='tmpfilename' property='target.{ORCgrp(1).OBXgrp(tmpobxseq).OBX:3.5}' action='set' />
<assign value='""' property='target.{ORCgrp(1).OBXgrp(tmpobxseq).OBX:5.1}' action='set' />
<assign value='"APPLICATION"' property='target.{ORCgrp(1).OBXgrp(tmpobxseq).OBX:5.2}' action='set' />
<assign value='"PDF"' property='target.{ORCgrp(1).OBXgrp(tmpobxseq).OBX:5.3}' action='set' />
<assign value='"BASE64"' property='target.{ORCgrp(1).OBXgrp(tmpobxseq).OBX:5.4}' action='set' />
<assign value='"1"' property='target.{ORCgrp(1).OBXgrp(tmpobxseq).OBX:4}' action='set' />
</true>
</if>
</foreach>

</transform>
}

}
