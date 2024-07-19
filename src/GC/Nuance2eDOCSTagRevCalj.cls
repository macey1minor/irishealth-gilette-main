Class GC.Nuance2eDOCSTagRevCalj Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ORU_R01' targetDocType='231.Cerner:ORU_R01' create='copy' language='objectscript' >
<code>
<![CDATA[ 
	// Last Updated: 03/04/2020 Al Johnson
	// Moved to Prod: 05/14/2019
	// Create: 
	//    Description: 
	//  Check for Symbol font and / or missing \generator so hdgs inserted incorrectly
	//  Update table so any updates automatically reprocess after any correction
	//   Version to identify which to replay
]]></code>
<assign value='source.{PID:PatientIdentifierList().ID}' property='tempMRN' action='set' />
<assign value='source.{PID:PatientName().familylastname.familyname}_","_source.{PID:PatientName().givenname}' property='tempNAME' action='set' />
<assign value='source.{PID:18}' property='tempFIN' action='set' />

<assign value='..SubString(source.{ORCgrp(1).OBR:7},5,6)_"/"_..SubString(source.{ORCgrp(1).OBR:7},7,8)_"/"_..SubString(source.{ORCgrp(1).OBR:7},1,4)' property='tempDOS' action='set' />

<assign value='source.{ORCgrp(1).OBR:4.1}' property='tempDOCTYPE' action='set' />

<assign value='""' property='tmprtfdoc' action='set' />
<foreach property='source.{ORCgrp(1).OBXgrp().OBX}' key='k3' >
<code>
<![CDATA[
     // extract the obx into 3 pieces delimited by '{\rtf1\' and '}|'
     //  perform actions on middle - remove ~^^RTF^^
     //  leave off last } when reconstructing obx-5.5
     //  add back delimiters when recreating obx segment
     //
     //  <assign value='$LENGTH(source.{ORCgrp(1).OBXgrp(k3).OBX:5(1).5})' property='tmprtflength' action='set' />
     //  <assign value='$EXTRACT(source.{ORCgrp(1).OBXgrp(k3).OBX:5(1).5},2,tmprtflength-1)' property='tmprtfdoc1' action='set' />
     //
     ]]></code>
     
<assign value='""' property='holdobxseg' action='set' />
<assign value='source.{ORCgrp(1).OBXgrp(k3).OBX}' property='holdobxseg' action='set' />
<assign value='""' property='holdobxseg1' action='set' />
<assign value='""' property='holdobxseg1a' action='set' />
<assign value='""' property='holdobxseg2' action='set' />
<assign value='""' property='holdobxseg2a' action='set' />
<assign value='""' property='holdobxseg3' action='set' />

<assign value='$PIECE(holdobxseg,"{\rtf1\",1)' property='holdobxseg1' action='set' />
<assign value='$PIECE(holdobxseg,"{\rtf1\",2)' property='holdobxseg1a' action='set' />

<assign value='$PIECE(holdobxseg1a,"}|",1)' property='holdobxseg2' action='set' />
<assign value='$PIECE(holdobxseg1a,"}|",2)' property='holdobxseg3' action='set' />

<assign value='$REPLACE(holdobxseg2,"~^^RTF^^","")' property='holdobxseg2' action='set' />
<assign value='$REPLACE(holdobxseg2,"/.br/","/ ")' property='holdobxseg2' action='set' />
<assign value='("{\rtf1\"_holdobxseg2_"}")' property='holdobxseg2a' action='set' />
     
<assign value='""' property='tmprtflength' action='set' />
<assign value='""' property='tmprtfdoc1' action='set' />
<assign value='$LENGTH(holdobxseg2a)' property='tmprtflength' action='set' />
<assign value='$EXTRACT(holdobxseg2a,2,tmprtflength-1)' property='tmprtfdoc1' action='set' />

<assign value='tmprtfdoc_tmprtfdoc1' property='tmprtfdoc' action='set' />

<assign value='""' property='tmpNote' action='set' />

<foreach property='source.{ORCgrp(1).OBXgrp(k3).NTE()}' key='k7' >
<if condition='source.{ORCgrp(1).OBXgrp(k3).NTE(k7):SourceOfComment(1)} = "SIGN LINE"' >
<true>
<assign value='source.{ORCgrp(1).OBXgrp(k3).NTE(k7):Comment(1)}' property='tmpNote' action='set' />
<assign value='tmpNote_"\line\line"' property='tmpNote' action='set' />
<assign value='$REPLACE(tmpNote,"\.br\","\par ")' property='tmpNote' action='set' />
<assign value='tmprtfdoc_tmpNote' property='tmprtfdoc' action='set' />
</true>
</if>
</foreach>
</foreach>

<code>
<![CDATA[ 
	// $FIND returns next character posistion following returned column
	// inserting hdg after 1st {\*\generator TX_RTF32 18.0.541.501;}
	//  <assign value='"{"_tmprtfdoc_"}"' property='target.zFindingsComb' action='set' />
	//
	//  Addendums out of Cerner are using a different font table than the original document out of Nuance Escription
	//   Original goes into symbol font and appears to be foreign language
	//   Out of Nuance - fcharset2\E\fprq2{\E\*\E\panose 05050102010706020507}Symbol;}
	//   Out of Cerner - {\f2\froman\fcharset2\fprq2 Symbol;}
	//    Change \f2\froman\fcharset2\fprq2 Symbol; TO \f2\froman\fcharset0\fprq2 Times New Roman;
	//   03/21/2017  Symbol is occuring on fonts other than f2
	//   03/21/2017 Change \froman\fcharset2\fprq2 Symbol; TO \froman\fcharset0\fprq2 Times New Roman;
	//   03/04/2020 Change all occurences of Symbol to Times New Roman
	//   03/04/2020 <assign value='$REPLACE(target.zFindingsComb,"\froman\fcharset2\fprq2 Symbol;","\froman\fcharset0\fprq2 Times New Roman;")' property='target.zFindingsComb' action='set' />
]]></code>

<assign value='"0"' property='tmpgeneratorpos' action='set' />
<assign value='"0"' property='tmpsymbolpos' action='set' />

<assign value='"0"' property='tmpfindsymbol' action='set' />
<assign value='"0"' property='tmpfindgen' action='set' />

<assign value='$FIND(tmprtfdoc,"\generator")' property='tmpgeneratorpos' action='set' />
<if condition='tmpgeneratorpos=0' >
<true>
<assign value='$FIND(tmprtfdoc,"\sectd")' property='tmpgeneratorpos' action='set' />
<if condition='tmpgeneratorpos=0' >
<true>
<assign value='"0"' property='tmpfindgen' action='set' />
</true>
<false>
<assign value='"2"' property='tmpfindgen' action='set' />
</false>
</if>
</true>
<false>
<assign value='"1"' property='tmpfindgen' action='set' />
</false>
</if>

<assign value='$FIND(tmprtfdoc,"\froman\fcharset2\fprq2 Symbol;")' property='tmpsymbolpos' action='set' />
<if condition='tmpsymbolpos=0' >
<true>
<assign value='$FIND(tmprtfdoc,"Symbol;")' property='tmpsymbolpos' action='set' />
<if condition='tmpsymbolpos=0' >
<true>
<assign value='"0"' property='tmpfindsymbol' action='set' />
</true>
<false>
<assign value='"2"' property='tmpfindsymbol' action='set' />
</false>
</if>
</true>
<false>
<assign value='"1"' property='tmpfindsymbol' action='set' />
</false>
</if>

<assign value='""' property='tmpOBXcount' action='set'/>
<assign property='tmpOBXcount' value='(source.{ORCgrp(1).OBXgrp(*)})' action='set'/>

<assign value='tmpfindgen_"-"_tmpfindsymbol' property='target.{MSH:14}' action='set' />
<assign value='tmpOBXcount' property='target.{MSH:16}' action='set' />

<code>
<![CDATA[ 
     // $$$TRACE("obxcount= "_OBXcount)
     // $$$TRACE("symbol find= "_tmpfindsymbol_" hdgfind= "_tmpfindgen)
     // $$$TRACE("HdgPos= "_tmpgeneratorpos_" totallength= "_tmprtftotallength_" sectd= "_tmpsectdpos)
     // $$$TRACE("font2symb= "_tmpfprq2sympos_" totalsymbolcnt= "_tmptotalsymbolcnt)
]]></code>

</transform>
}

}
