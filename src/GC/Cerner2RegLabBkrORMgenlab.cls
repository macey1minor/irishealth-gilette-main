Class GC.Cerner2RegLabBkrORMgenlab Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ORM_O01' targetDocType='231.Cerner:ORM_O01' create='copy' language='objectscript' >
<subtransform class='GC.Cerner2RegLabBkrORMsub' targetObj='target' sourceObj='source' />
<code>
<![CDATA[ 
	//  Last Updated 03/28/2022 Al Johnson
	//  Last Moved to Prod: 03/29/2022 Al Johnson
	//  Create: 07/16/2018  Al Johnson 
	//  Description:  Epic Beaker replaces Sunquest
	//  Outpatient ADT will be created off ORM in Epic
	//  Sunquest - GC.Cerner2RegLabORMgenlab schema 22.Reglab
	//  Beaker - GC.Cerner2RegLabORMBkrgenlab schema 231.Cerner
	//	Uses subtransform CernerRegLabORMBkrSub
	//
	//  Send all OBX out as Cerner created
	//  Put back OBX delete - per testing session 9/18/2018
	//
	//  OBX:3.1 = COMT change to NTE segment
	//  OBX:3.1 = DONOTSEND - remove
	//
	//  delete obx and add back - may need to resequence 02/13/2019
	//  if date and time of last dose, split into 2 obx one for date and one for time 02/13/2019
	//  date of last dose - obx-2 = DT obx-3 = 12300122 02/25/2019
	//  time of last does - obx-2 = TM obx-3 = 12300142 02/25/2019
	//  chg time to 4 digits vs 6
	//
	//  ormsub changes obx-3 value of IS to ST.  2/13 OBX delete logic removed 02/19/2019
	//  remove commas in obx-5 NM type 3/11/2019
	//  time of last dose - obx-3 different based on orderable obr-4.1 3/11/2019
	//  get obx-3 date alias and obx-3 time alias off table T_RegionsLab_DateTimeLastDose
	//
	//  body type and source may be sent in either obr-15 or obx segments 3/26/2019
	//  read tables T_RegLab_SpecimenSource and T_RegLab_SpecimenType for Epic codes 3/26/2019
	//  Update OBR-15.1.2 with type and OBR-15.4 with source/site 3/26/2019
	//
	//  Remove OBX segments from Cerner for NAME, SDES, PLAB, TLPHN 4/8/2019
	//  Remove OBX segments from Cerner for "Attention to" 4/9/2019
	//
	//  Remove carriage return from OBX-5 4/17/2019
	//
	//  Some users have favorites loaded which are ordering old sunquest values 4/19/2019
	//  Change to Beaker, table value for result back in 4/19/2019
	//  Table = T_RegionsLab_OrderedConversion
	//
	//  OBX COMNT converted to NTE is not removing the carriage returns 4/24/2019
	//  Remove carriage return from NTE segments following PID 4/25/2019
	//
	//  Remove OBX for Legacy Order Question - Jira CNR-18307 6/12/2019
	//
	//  Resequence OBX segments so they start at 1 and no gaps - RFC SD-41677 4/28/2020
	//
	//  Covid19 orders Cerner questions limit to 100 characters.  Amy put in aliases for answers, expand in dtl 5/11/2020
	//  Covid19 additional types SD-43424 5/19/2020 RFC-43633
	//  Covid19 type COVIDYOUNGER3 - added space SD-43916
	//
	//  Covid19 update failing when obx lines deleted or inserted - needed to use tmpobxseq for obx index - RFC SD-44430 5/29/2020
	//
	//  Covid19 types COVIDGROUP, COVIDISOLATE and COVIDCHEMO 6/5/2020 SD-44923 RFC SD-44927
	//  Covid19 types change COVIDSURGICAL remove COVIDCHEMO 6/9/2020 RFC SD-44927
	//  Covid19 types changes Add COVIDTRAVEL and COVIDWELL, remove COVIDTRANSIT and COVIDGROUP 6/22/2020 SD-46565 RFC SD-46681
	//  Covid19 types change COVIDBEHAVIORAL 7/1/2020 SD-47724 RFC SD-47790
	//
	//  Covid19 types change verbiage in COVIDWORKER, COVIDOLDER3, COVIDYOUNGER3, COVIDTRAVEL and COVIDOTHER 8/7/2020 SD-51108 RFC SD-51305
	//
	//  Covid19 type change remove COVIDPREGNANT, add COVIDSCHOOL 8/12/2020 SD-51588 RFC SD-51636
	//
	//  Covid19 type change verbiage in COVIDOTHER add COVIDADMIT, COVIDIPEMERGENT, COVIDOLDER3EMT, COVIDYOUNGER3EMT 8/19/2020 SD-524099 RFC SD-52622
	//   the description in covidother has an ampersand - need to handle differently
	//
	//  Covid19 type change verbiage in COVIDWORKER, COVIDOLDER3, COVIDYOUNGER3, COVIDSCHOOL, COVIDSURGICAL, COVIDBEHAVIORAL, COVIDTRAVEL,
	//    COVIDWELL, COVIDOLDER3EMT, COVIDYOUNGER3EMT  Add COVIDNONWORKER, COVIDNONOLDER3, COVIDNONYOUNGER3  8/25/2020 SD-53080 RFC SD-53456
	//
	//  Covid19 type add COVIDRESEARCH 9/1/2020 SD-53612 RFC SD-53869
	//
	//  Covid19 type add COVIDEXPOSURE 9/16/2020 SD-55539 RFC SD-55606
	//
	//  Covid19 type add COVIDSURVEILLANCE 9/29/2020 SD-57246 RFC SD-57513
	//
	//  Covid19 type change COVIDOTHER 10/5/2020 SD-57979 RFC SD-58029
	//
	//  Covid19 type change COVIDWELL 10/22/2020 SD-59895 RFC SD-60094
	//
	//  New check for Inluenza A and B INFABADMIT, INFABLTC, INFABHIGHRISK, INFABLESSTHANTWO, INFABOTHER 11/10/2020 SD-61614 RFC SD-62660
	//
	//  Covid19 type change COVIDTRAVEL 11/13/2020 SD-62522 RFC SD-62660
	//
	//  Covid19 type change COVIDNONWORKER 12/30/2020 SD-67394 RFC SD-68228
	//
	//  Covid19 type change remove COVIDOLDER3EMT, COVIDYOUNGER3EMT, COVIDNONWORKER, COVIDNONOLDER3, COVIDNONYOUNGER3, COVIDRESEARCH,
	//    COVIDEXPOSURE, COVIDSURVEILLANCE, COVIDOLDER3, COVIDYOUNGER3, COVIDCONGREGATE, COVIDWELL, COVIDSCHOOL
	//    8/11/2021 SD-93827 RFC SD-95567
	//
	//  Covid19 type add COVIDSURVEILLANCE 9/08/2021 SSD-97136  RFC SD-97140
	//        Was in list to delete 8/11/2021 RFC SD-95567
	//
	//  Covid19 type change COVIDOTHER and COVIDWORKER 9/15/2021 RFC SD-97905
	//
	//  Covid19 type change COVIDWORKER 11/17/2021 SD-105971 RFC SD-106147
	//
	//  Covid19 type change COVIDWORKER 01/05/2022 SD-111200 RFC SD-111257
	//
	//  Covid19 type change COVIDWORKER 01/06/2022 SD-111435
	//
	//  Additional Source Codes to extract - 123000011 and 123000019 2/21/2022 SD-117053 RFC SD-120662
	//  Original Source Codes continue to remove obx and update obr, new codes do not remove obx
	//  Add 123000230 2/23/2022
	//  Add 123001061 3/15/2022
	//
	//  Future Order release logic obr-27.4 out of Cerner has wrong date/time 3/28/2022 SD-120953 RFC SD-121184
	// Covid19 type change COVIDSURGICAL 12/21/2022 SD-152399
	//
]]></code>

<assign value='"Cerner2RegLabORMgen"' property='target.{MSH:8}' action='set' />

<code>
<![CDATA[
     // *************************** Remove OBX from output OBX
]]></code>

<foreach property='target.{ORCgrp(1).OBRgrp.OBXgrp()}' key='k1' >
<assign value='' property='target.{ORCgrp(1).OBRgrp.OBXgrp(k1)}' action='remove' />
</foreach>

<code>
<![CDATA[
     // On NW new orders, that are OBR-27.6 RO routine and scheduled OBR-27.4 for 030000
     //  Move ORC-15 order effective date/time to OBR-27.4 timing start date/time
     //  Cerner sending orders out with date/time order was placed (i.e. followup orders, surgical orders) 11/5/2021
     //  New logic 3/22/2022
     //  Subroutine is executed first so somevalues change i.e. GCSH Periop change to GOR
]]></code>

<assign value='$EXTRACT(target.{ORCgrp(1).OBRgrp.OBR:27(1).4},9,14)' property='tobr27time' action='set' />
<if condition='(target.{ORCgrp(1).ORC:1}="NW")&amp;(tobr27time="030000")&amp;(target.{ORCgrp(1).OBRgrp.OBR:27(1).6}="RO")' >
<true>
<if condition='..In(target.{PV1:18},"Day Surgery,Outpatient,Outpatient in a Bed,Recurring,Virtual Care")' >
<true>
<assign value='target.{ORCgrp(1).ORC:15.1}' property='target.{ORCgrp(1).OBRgrp.OBR:27(1).4}' action='set' />
</true>
<false>
<if condition='(target.{PV1:2}="I")&amp;((target.{PV1:3.1}="GCSH Periop")||(target.{PV1:3.1}="GOR"))' >
<true>
<assign value='target.{ORCgrp(1).ORC:15.1}' property='target.{ORCgrp(1).OBRgrp.OBR:27(1).4}' action='set' />
</true>
</if>
</false>
</if>
</true>
</if>

<code>
<![CDATA[
     // Check orderable for Sunquest value - change to Beaker value
     // Table for result on initial NW order
]]></code>

<if condition='..In(target.{ORCgrp(1).OBRgrp.OBR:4.2},"UAMIC,UAC,UCIF,UAM,UA,URIS")' >
<true>
<if condition='target.{ORCgrp(1).ORC:1}="NW"' >
<true>
<assign value='target.{ORCgrp(1).OBRgrp.OBR:2.1}' property='holdordernbr' action='set' />
<assign value='target.{ORCgrp(1).OBRgrp.OBR:4.2}' property='holdordertest' action='set' />
<code>
<![CDATA[ 
    // write ordered prior to conversion - convert result back
        set wTableNameOrder="T_RegionsLab_OrderedConversion"
        do ##class(Ens.Util.LookupTable).%UpdateValue(wTableNameOrder,holdordernbr,holdordertest)	
	]]></code>
</true>
</if>

<if condition='(target.{ORCgrp(1).OBRgrp.OBR:4.2}="UAMIC")' >
<true>
<assign value='"RH0261"' property='target.{ORCgrp(1).OBRgrp.OBR:4.2}' action='set' />
<assign value='"Urinalysis with Micro (St. Paul Order Only)"' property='target.{ORCgrp(1).OBRgrp.OBR:4.3}' action='set' />
</true>
</if>

<if condition='(target.{ORCgrp(1).OBRgrp.OBR:4.2}="UAC")' >
<true>
<assign value='"RH0258"' property='target.{ORCgrp(1).OBRgrp.OBR:4.2}' action='set' />
<assign value='"Urinalysis with Micro, Culture if Positive (St. Paul Order Only)"' property='target.{ORCgrp(1).OBRgrp.OBR:4.3}' action='set' />
</true>
</if>

<if condition='(target.{ORCgrp(1).OBRgrp.OBR:4.2}="UCIF")' >
<true>
<assign value='"3307"' property='target.{ORCgrp(1).OBRgrp.OBR:4.2}' action='set' />
<assign value='"Urinalysis, Micro if Positive (Phalen Order Only)"' property='target.{ORCgrp(1).OBRgrp.OBR:4.3}' action='set' />
</true>
</if>

<if condition='(target.{ORCgrp(1).OBRgrp.OBR:4.2}="UAM")' >
<true>
<assign value='"LABS11919"' property='target.{ORCgrp(1).OBRgrp.OBR:4.2}' action='set' />
<assign value='"Urinalysis, Micro if Pos, Culture if Pos (Phalen Order Only)"' property='target.{ORCgrp(1).OBRgrp.OBR:4.3}' action='set' />
</true>
</if>

<if condition='(target.{ORCgrp(1).OBRgrp.OBR:4.2}="UA")' >
<true>
<assign value='"3308"' property='target.{ORCgrp(1).OBRgrp.OBR:4.2}' action='set' />
<assign value='"Urinalysis, No Micro"' property='target.{ORCgrp(1).OBRgrp.OBR:4.3}' action='set' />
</true>
</if>

<if condition='(target.{ORCgrp(1).OBRgrp.OBR:4.2}="URIS")' >
<true>
<assign value='"3308"' property='target.{ORCgrp(1).OBRgrp.OBR:4.2}' action='set' />
<assign value='"Urinalysis, No Micro"' property='target.{ORCgrp(1).OBRgrp.OBR:4.3}' action='set' />
</true>
</if>

</true>
</if>

<code>
<![CDATA[
     // Read table T_RegionsLab_AliasLastDose for Date and Time of Last Dose OBX-3 Alias values
]]></code>
<assign value='target.{ORCgrp(1).OBRgrp.OBR:4.2}' property='wTableAliasKey' action='set' />
<assign value='""' property='wDateAlias' action='set' />
<assign value='""' property='wTimeAlias' action='set' />
<assign value='""' property='wtablealiasresult' action='set' />
<assign value='..Lookup("T_RegionsLab_AliasLastDose",wTableAliasKey)' property='wtablealiasresult' action='set' />
<if condition='wtablealiasresult=""' >
<true>
<assign value='"MissingTableEntry"' property='wDateAlias' action='set' />
<assign value='"MissingTableEntry"' property='wTimeAlias' action='set' />
</true>
<false>
<assign value='$PIECE(wtablealiasresult,"|",1)' property='wDateAlias' action='set' />
<assign value='$PIECE(wtablealiasresult,"|",2)' property='wTimeAlias' action='set' />
</false>
</if>

<code>
<![CDATA[
     // if COMT - change to NTE
     // if DONOTSEND - remove
     // if Date and Time of Last Dose - split into 2 OBX - first date, then time
     // check for specimen source and type, hold values in work fields and remove obx segments
     // remove carriage return on NTE converted from OBX COMT - 04/24/2019
     //
     //  add obx back on source
]]></code>
<assign value='"0"' property='tmpobxseq' action='set' />

<assign value='""' property='holdtype' action='set' />
<assign value='""' property='holdsource' action='set' />

<foreach property='source.{ORCgrp(1).OBRgrp.OBXgrp()}' key='k1' >
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1} = "COMT"' >
<true>
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' property='holdcomment' action='set' />
<assign value='$REPLACE(holdcomment,"\.br\"," ")' property='holdcomment' action='set' />
<assign value='"1"' property='target.{ORCgrp(1).OBRgrp.NTE(1):1}' action='set' />
<assign value='holdcomment' property='target.{ORCgrp(1).OBRgrp.NTE(1):3(1)}' action='set' />
<assign value='""' property='target.{ORCgrp(1).OBRgrp.NTE(1):4}' action='set' />
</true>
<false>
<if condition='..In(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1},"DONOTSEND,NAME,SDES,PLAB,TLPHN,Attention to,CSF Evaluate For")' >
<false>
<assign value='tmpobxseq+1' property='tmpobxseq' action='set' />
<if condition='(..StartsWith(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.2},"Date and Time of Last Dose"))' >
<true>
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' property='tmpdatetime' action='set' />
<assign value='$EXTRACT(tmpdatetime,1,8)' property='tmpdate' action='set' />
<assign value='$EXTRACT(tmpdatetime,9,12)' property='tmptime' action='set' />

<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1)}' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq)}' action='set' />
<assign value='tmpobxseq' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq).OBX:1}' action='set' />
<assign value='"DT"' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq).OBX:2}' action='set' />
<assign value='wDateAlias' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq).OBX:3.1}' action='set' />
<assign value='"Date of Last Dose"' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq).OBX:3.2}' action='set' />
<assign value='tmpdate' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq).OBX:5}' action='set' />

<assign value='tmpobxseq+1' property='tmpobxseq' action='set' />
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1)}' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq)}' action='set' />
<assign value='tmpobxseq' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq).OBX:1}' action='set' />
<assign value='"TM"' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq).OBX:2}' action='set' />
<assign value='wTimeAlias' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq).OBX:3.1}' action='set' />
<assign value='"Time of Last Dose"' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq).OBX:3.2}' action='set' />
<assign value='tmptime' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq).OBX:5}' action='set' />

</true>
<false>

<if condition='..In(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1},"BFTYPE,CSFTYPE,SPECIMENTYPE")' >
<true>
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' property='holdtype' action='set' />
</true>
<false>
<if condition='..In(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1},"BFSOURCE,CSFSOURCE,GENSOURCE,SPECIMENSOURCE")' >
<true>
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' property='holdsource' action='set' />
</true>
<false>
<if condition='..In(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1},"123000011,123000019,123000230,123001061")' >
<true>
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' property='holdsource' action='set' />

<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' property='holdobx5in' action='set' />
<assign value='$REPLACE(holdobx5in,"\.br\"," ")' property='holdobx5in' action='set' />
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1)}' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq)}' action='set' />
<assign value='tmpobxseq' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq).OBX:1}' action='set' />
<assign value='holdobx5in' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq).OBX:5}' action='set' />

</true>
<false>
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5}' property='holdobx5in' action='set' />
<assign value='$REPLACE(holdobx5in,"\.br\"," ")' property='holdobx5in' action='set' />
<assign value='source.{ORCgrp(1).OBRgrp.OBXgrp(k1)}' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq)}' action='set' />
<assign value='tmpobxseq' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq).OBX:1}' action='set' />
<assign value='holdobx5in' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq).OBX:5}' action='set' />
</false>
</if>
</false>

</if>
</false>
</if>

</false>
</if>
</false>
</if>
</false>
</if>

<code>
<![CDATA[
     // OBX segments question specific to COVID19 test
     // OBX-3 = 138035^Lab COVID Patient Type
     // Change OBX-5 answer - 5/11/2020
     // OBX segments question specific to Influenza A and B
     // OBX-3 = 123000199
     // Change OBX-5 answer - 11/10/2020
]]></code>

<assign value='""' property='tmpanswer' action='set' />
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1} = "138035"' >
<true>
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5} = "COVIDWORKER"' >
<true>
<assign value='"Employee or Family Member of HP Family of Care/Gillette"' property='tmpanswer' action='set' />
<assign value='tmpanswer' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq).OBX:5}' action='set' />
</true>
</if>

<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5} = "COVIDSURGICAL"' >
<true>
<assign value='"Pre-procedure or pre-surgical testing for patients who are expected to be admitted to the hospital following the procedure or surgery"' property='tmpanswer' action='set' />
<assign value='tmpanswer' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq).OBX:5}' action='set' />
</true>
</if>

<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5} = "COVIDOTHER"' >
<true>
<assign value='"All other patients eligible for testing (Comment Required for Inpatient Setting)"' property='tmpanswer' action='set' />
<assign value='tmpanswer' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq).OBX:5}' action='set' />
</true>
</if>

<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5} = "COVIDISOLATE"' >
<true>
<assign value='"(Inpatient only) Instructed to self-isolate for 14 days by Department of Health"' property='tmpanswer' action='set' />
<assign value='tmpanswer' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq).OBX:5}' action='set' />
</true>
</if>

<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5} = "COVIDTRAVEL"' >
<true>
<assign value='"Travel testing for travel to states or countries that require testing for entry"' property='tmpanswer' action='set' />
<assign value='tmpanswer' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq).OBX:5}' action='set' />
</true>
</if>

<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5} = "COVIDADMIT"' >
<true>
<assign value='"(Inpatient only) Symptomatic Admit Likely"' property='tmpanswer' action='set' />
<assign value='tmpanswer' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq).OBX:5}' action='set' />
</true>
</if>

<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5} = "COVIDIPEMERGENT"' >
<true>
<assign value='"(Inpatient only) Emergent (not prescheduled) Pre-Op or AGP"' property='tmpanswer' action='set' />
<assign value='tmpanswer' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq).OBX:5}' action='set' />
</true>
</if>

<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5} = "COVIDBEHAVIORAL"' >
<true>
<assign value='"Behavioral Health pre-admission/Congregate Living re-admission"' property='tmpanswer' action='set' />
<assign value='tmpanswer' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq).OBX:5}' action='set' />
</true>
</if>

<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5} = "COVIDSURVEILLANCE"' >
<true>
<assign value='"Surveillance Testing"' property='tmpanswer' action='set' />
<assign value='tmpanswer' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq).OBX:5}' action='set' />
</true>
</if>

</true>
</if>

<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:3.1} = "123000199"' >
<true>
<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5} = "INFABADMIT"' >
<true>
<assign value='"Symptomatic patient being admitted"' property='tmpanswer' action='set' />
<assign value='tmpanswer' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq).OBX:5}' action='set' />
</true>
</if>

<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5} = "INFABLTC"' >
<true>
<assign value='"Long term care facility residents"' property='tmpanswer' action='set' />
<assign value='tmpanswer' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq).OBX:5}' action='set' />
</true>
</if>

<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5} = "INFABHIGHRISK"' >
<true>
<assign value='"Patients with high risk household contacts who are eligible for prophylaxis"' property='tmpanswer' action='set' />
<assign value='tmpanswer' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq).OBX:5}' action='set' />
</true>
</if>

<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5} = "INFABLESSTHANTWO"' >
<true>
<assign value='"Patients under 2 if diagnostic evaluation or clinical care impacted"' property='tmpanswer' action='set' />
<assign value='tmpanswer' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq).OBX:5}' action='set' />
</true>
</if>

<if condition='source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:5} = "INFABOTHER"' >
<true>
<assign value='"Other: (add comment)"' property='tmpanswer' action='set' />
<assign value='tmpanswer' property='target.{ORCgrp(1).OBRgrp.OBXgrp(tmpobxseq).OBX:5}' action='set' />
</true>
</if>

</true>
</if>

</foreach>

<code>
<![CDATA[
    // Populate OBR-15 with table values - Epic codes
    //  if bad read - send Gillette value
]]></code>

<if condition='target.{ORCgrp(1).OBRgrp.OBR:15.1.2}=""' >
<false>
<assign value='target.{ORCgrp(1).OBRgrp.OBR:15.1.2}' property='holdtype' action='set' />
</false>
</if>

<if condition='target.{ORCgrp(1).OBRgrp.OBR:15.4}=""' >
<false>
<assign value='target.{ORCgrp(1).OBRgrp.OBR:15.4}' property='holdsource' action='set' />
</false>
</if>

<assign value='""' property='wtablesourceresult' action='set' />
<assign value='""' property='wtabletyperesult' action='set' />

<if condition='holdsource=""' >
<false>
<assign value='..Lookup("T_RegionsLab_SpecimenSource",holdsource)' property='wtablesourceresult' action='set' />
<if condition='wtablesourceresult=""' >
<false>
<assign value='wtablesourceresult' property='holdsource' action='set' />
</false>
</if>
</false>
</if>

<if condition='holdtype=""' >
<false>
<assign value='..Lookup("T_RegionsLab_SpecimenType",holdtype)' property='wtabletyperesult' action='set' />
<if condition='wtabletyperesult=""' >
<false>
<assign value='wtabletyperesult' property='holdtype' action='set' />
</false>
</if>
</false>
</if>

<assign value='""' property='target.{ORCgrp(1).OBRgrp.OBR:15}' action='set' />
<assign value='holdtype' property='target.{ORCgrp(1).OBRgrp.OBR:15.1.2}' action='set' />
<assign value='holdsource' property='target.{ORCgrp(1).OBRgrp.OBR:15.4}' action='set' />

<code>
<![CDATA[
    // Epic Beaker Orders only accepts ST, TX, NM, DT, RP in OBX-2
    //  if condition='..In(source.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:2},"ST,TX,NM,DT,RP")' >
    //    <false>
    //   <assign value='"ST"' property='target.{ORCgrp(1).OBRgrp.OBXgrp(k1).OBX:2}' action='set' />
    //  </false>
    //
    //  Remove commas from obx-5 on type NM
]]></code>
<foreach property='target.{ORCgrp(1).OBRgrp.OBXgrp()}' key='k3' >
<if condition='..In(target.{ORCgrp(1).OBRgrp.OBXgrp(k3).OBX:2},"IS")' >
<true>
<assign value='"ST"' property='target.{ORCgrp(1).OBRgrp.OBXgrp(k3).OBX:2}' action='set' />
</true>
</if>
<if condition='..In(target.{ORCgrp(1).OBRgrp.OBXgrp(k3).OBX:2},"NM")' >
<true>
<assign value='target.{ORCgrp(1).OBRgrp.OBXgrp(k3).OBX:5(1)}' property='holdobx5' action='set' />
<assign value='$ZSTRIP(holdobx5,"*",",")' property='holdobx5a' action='set' />
<assign value='holdobx5a' property='target.{ORCgrp(1).OBRgrp.OBXgrp(k3).OBX:5(1)}' action='set' />
</true>
</if>
</foreach>

<code>
<![CDATA[
    //  Remove carriage return from NTE segments following PID - 04/25/2019
 ]]></code>
 <foreach property='target.{NTE()}' key='k4' >
 <foreach property='target.{NTE(k4):3()}' key='k5' >
 <assign value='target.{NTE(k4):3(k5)}' property='holdpidcomment' action='set' />
 <assign value='$REPLACE(holdpidcomment,"\.br\"," ")' property='holdpidcomment' action='set' />
 <assign value='holdpidcomment' property='target.{NTE(k4):3(k5)}' action='set' />
 </foreach>
 </foreach>

<code>
<![CDATA[     // *************************** Config Custom Questions for SDES
    // only create SDES when value for gen lab
]]></code>

<assign value='$ZCONVERT(target.{PID},"U" )' property='target.{PID}' action='set' />

<code>
<![CDATA[  
    // resequence obx segments
]]></code>

<assign value='"0"' property='tmpobxseq1' action='set' />
<foreach property='target.{ORCgrp(1).OBRgrp.OBXgrp()}' key='k6' >
<if condition='target.{ORCgrp(1).OBRgrp.OBXgrp(k6).OBX:1}&gt;"0"'>
<true>
<assign value='tmpobxseq1+1' property='tmpobxseq1' action='set' />
<assign value='tmpobxseq1' property='target.{ORCgrp(1).OBRgrp.OBXgrp(k6).OBX:1}' action='set' />
</true>
</if>
</foreach>

</transform>
}

}
