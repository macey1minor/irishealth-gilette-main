Class GC.Natus2CernerBase64 Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ORU_R01' targetDocType='231.Cerner:ORU_R01' create='new' language='objectscript' >
<code>
<![CDATA[ 
	//  Last Updated 07/20/2021
	//  Last Updated in Prod: 07/20/2021 Al Johnson
	//  Create: 02/12/2021  Al Johnson 
	//  Description:  
	//	ORU from Natus SleepWorks base64 report
	//  Set specific values necessary to create / update report in Cerner
    //
    //  Copy the Cerner order id from ORC-2 to ORC-3 and OBR-2 to OBR-3.
    //
    //  Looks like a combination of filler and placer order change will create a new line in powerchart
    //  Doesnot appear to be a limit on size of pdf name, but needs to be unique
    //
    //  Powerchart left under SleepStudyOrder OBR-8.1 Oberservation End DateTime
    //  Powerchart right result date SleepStudyOrder OBR-8.1 Oberservation End DateTime
    //  Powerchart right left of pdf name OBR-7.1 Observation DateTime
    //  Powerchart new line on left side - change in filler ordernbr OBR-3.1
    //
    //  Crosswalk OBX-3.1 to Cerner value, update OBR-4.2 with crosswalk
    //  Create pdf using crosswalk value, cerner order and .pdf
    //  If no filler order number, copy Gillette placer order to filler order
    //  Leave OBR-4.1 as ordered - EEG orders have some differences for OBR-4.1
    //  Add second field on table parsed out by |, if no value use OBX-3.1 for OBR-4.1
    //
    //  Two reports will be sent multiple times and need to create new entries
    //  MD Consecutive Day and VEEG Daily Tech Summary will be generated each day of study
    //  OBR-7 start date appears to carry original order start
    //  OBR-8 end date appears to carry report date (2nd, 3rd etc)
    //  Shawn Hepler from Natus is backdating OBR-7 on the reports to reflect actual date of report
    //  Take OBR-7, update OBR-8, append filler order ORC-3 and OBR-3, append pdf name OBX-3.5
    //  Move OBR-7 to OBR-8 on all reports 5/7/2021
    //
    //  Add table T_Natus_Techs_Doctors for field OBR-32 7/7/2021
    //
    //  Add cEEG DAILY Tech Summary to reports sent multiple times - make unique 7/20/2021
]]></code>

<code>
<![CDATA[ 
    //  target is new so copy segments
]]></code>
<assign value='source.{MSH}' property='target.{MSH}' action='set' />
<assign value='source.{PID}' property='target.{PID}' action='set' />
<assign value='source.{PV1}' property='target.{PV1}' action='set' />
<assign value='source.{ORCgrp(1).ORC}' property='target.{ORCgrp(1).ORC}' action='set' />
<assign value='source.{ORCgrp(1).OBR}' property='target.{ORCgrp(1).OBR}' action='set' />

<assign value='""' property='holdresult' action='set' />
<foreach property='source.{ORCgrp(1).OBXgrp()}' key='k1' >
<if condition='source.{ORCgrp(1).OBXgrp(k1).OBX:2}="ED"' >
<true>
<assign value='source.{ORCgrp(1).OBXgrp(k1)}' property='target.{ORCgrp(1).OBXgrp(1)}' action='set' />
<assign value='source.{ORCgrp(1).OBXgrp(k1).OBX:3.1}' property='holdresult' action='set' />
</true>
</if>
</foreach>

<code>
<![CDATA[ 
    //  MSH set contributer source NATUS set MSH-5 MMF
    //  Copy placer order (Gillette) to filler order  (-2 to -3)
    //  Set OBR-24 = MDOC
    //  OBR-25 result status
    //  Set OBX-3.1 ReportN, OBX-3.5 pdf attachment, OBX-4 = 1
    //      OBX-5.1 null, 5.2 APPLICATION, 5.3 PDF, 5.4 BASE64
    //  Change OBR-4.1 = to report from OBX-3.1
    //  Crosswalk OBX-3.1 received, update OBR-4.2 with crosswalk value
    //  Use crosswalk on psf name
    //  Leave OBX-3.1 as received
    //
    //  Reports MD Consecutive Day and VEEG Daily Tech Summary
    //  5/7/2021 copy obr-7 to obr-8 on all
    //  Append ORC-3, OBR-3 and OBX-3.5 pdf name only only on the two reports
    //
]]></code>
<assign value='"NATUS"' property='target.{MSH:3}' action='set' />
<assign value='"NATUS"' property='target.{MSH:4}' action='set' />
<assign value='"MMF"' property='target.{MSH:5}' action='set' />

<assign value='""' property='hldobr7' action='set' />
<assign value='source.{ORCgrp(1).OBR:7}' property='target.{ORCgrp(1).OBR:8}' action='set' />
<if condition='(holdresult="MD Consecutive Day")||(holdresult="VEEG Daily Tech Summary")||(holdresult="cEEG DAILY Tech Summary")' >
<true>
<assign value='source.{ORCgrp(1).OBR:7}' property='hldobr7' action='set' />
</true>
</if>

<assign value='source.{ORCgrp(1).ORC:2.1}' property='target.{ORCgrp(1).ORC:2}' action='set' />
<assign value='source.{ORCgrp(1).ORC:2.1}_hldobr7' property='target.{ORCgrp(1).ORC:3}' action='set' />
<assign value='source.{ORCgrp(1).OBR:2.1}' property='target.{ORCgrp(1).OBR:2}' action='set' />
<assign value='source.{ORCgrp(1).OBR:2.1}_hldobr7' property='target.{ORCgrp(1).OBR:3}' action='set' />

<assign value='""' property='holdorder' action='set' />
<assign value='source.{ORCgrp(1).OBR:2.1}' property='holdorder' action='set' />

<assign value='"MDOC"' property='target.{ORCgrp(1).OBR:24}' action='set' />

<assign value='holdresult' property='wTableKey' action='set' />
<assign value='""' property='wtableresult' action='set' />
<assign value='..Lookup("T_Natus_Documents",wTableKey)' property='wtableresult' action='set' />
<if condition='wtableresult=""' >
<true>
<code>
<![CDATA[ 
    // no entry found - so send to Cerner as received
]]></code>
<assign value='holdresult' property='wtableresult' action='set' />
</true>
<false>
<code>
<![CDATA[ 
    // table entry found - change orderable description in message
]]></code>
    </false>
    </if>
 
<assign value='""' property='wtableresult1' action='set' />
<assign value='""' property='wtableresult2' action='set' />
<assign value='$PIECE(wtableresult,"|",1)' property='wtableresult1' action='set' />
<assign value='$PIECE(wtableresult,"|",2)' property='wtableresult2' action='set' />
<code>
<![CDATA[ 
    // 2nd parse is obr-4.1 if no table entry use obx-3.1 (holdresult)
]]></code>
<if condition='wtableresult2=""' >
<true>
<assign value='holdresult' property='target.{ORCgrp(1).OBR:4.1}' action='set' />
</true>
<false>
<assign value='wtableresult2' property='target.{ORCgrp(1).OBR:4.1}' action='set' />
</false>
</if>

<code>
<![CDATA[ 
    //  Read table using name in OBR-32, update id with Gillette Organization Doctor
    //  Note Cerner schema definition for OBR-32 does not match data (i.e. name)
    //
    //  <assign value='source.{ORCgrp(1).OBR:32.2}' property='templastname' action='set' />
    //  <assign value='source.{ORCgrp(1).OBR:32.3}' property='tempfirstname' action='set' />
    //  <assign value='templastname_"|"_tempfirstname' property='wTableKeyName' action='set' />
]]></code>
<assign value='source.{ORCgrp(1).OBR:32.1}' property='wTableKeyName' action='set' />
<assign value='""' property='wtableresultTname' action='set' />
<assign value='..Lookup("T_Natus_Techs_Doctors",wTableKeyName)' property='wtableresultTname' action='set' />
<if condition='wtableresultTname=""' >
<true>
<code>
<![CDATA[ 
    // no entry found - so send to Cerner as received
]]></code>
<assign value='""' property='target.{ORCgrp(1).OBR:32.1}' action='set' />
</true>
<false>
<code>
<![CDATA[ 
    // table entry found - change obr-32.1 id in message
]]></code>
<assign value='wtableresultTname' property='target.{ORCgrp(1).OBR:32.1}' action='set' />
</false>
</if>

<assign value='wtableresult1_"_"_holdorder_hldobr7_".pdf"' property='target.{ORCgrp(1).OBXgrp(1).OBX:3.5}' action='set' />
<assign value='wtableresult1' property='target.{ORCgrp(1).OBR:4.2}' action='set' />

<assign value='"1"' property='target.{ORCgrp(1).OBXgrp(1).OBX:4}' action='set' />

<assign value='""' property='target.{ORCgrp(1).OBXgrp(1).OBX:5.1}' action='set' />
<assign value='"APPLICATION"' property='target.{ORCgrp(1).OBXgrp(1).OBX:5.2}' action='set' />
<assign value='"PDF"' property='target.{ORCgrp(1).OBXgrp(1).OBX:5.3}' action='set' />
<assign value='"BASE64"' property='target.{ORCgrp(1).OBXgrp(1).OBX:5.4}' action='set' />
<assign value='""' property='target.{ORCgrp(1).OBXgrp(1).OBX:11}' action='set' />

</transform>
}

}
