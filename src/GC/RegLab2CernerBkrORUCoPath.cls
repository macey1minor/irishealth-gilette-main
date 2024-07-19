Class GC.RegLab2CernerBkrORUCoPath Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='251.Regions:ORU_R01' targetDocType='251.Regions:ORU_R01' create='copy' language='objectscript' >
<code>
<![CDATA[ 
	//  Last Update: 11/28/2018 Al Johnson
	//  Last Moved to Prod:  03/05/2019 Al Johnson
    //  Created 08/20/2018 Al Johnson
    //
    //  Beaker version - schema changed from 22.RegLab to 231.Cerner
    //   Changed to version 251.Regions 11/05/2018
    //
    //  Populate OBR-22 with MSH-7 datetime of message 03/23/2017
    //  Populate OBR-27.4 with MSH-7 datetime of message 03/23/2017
    //
    //  Check table T_RegionsLab_OrderingProvider for a change in ordering provider 11/22/2017
    //  Change result message to table ordering provider 11/22/2017
    //  Update table with result date 11/22/2017
    //
    //  Rebuild all OBX - sequence=1, id=test, subid=orig id 11/28/2018
    //  Insert new OBX Header on OBX-3 change of data 11/28/2018
    //
]]></code>

<foreach property='target.{PIDgrpgrp(1).ORCgrp()}' key='k2' >
<assign value='source.{MSH:DateTimeOfMessage.Time}' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBR:22}' action='set' />
<assign value='source.{MSH:DateTimeOfMessage.Time}' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBR:27.4}' action='set' />
<assign value='"CoPath"' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBR:24}' action='set' />
<code>
<![CDATA[ 
    //  Remove OBX segments copied from source
]]></code>
<foreach property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp()}' key='k1' >
<assign value='' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1)}' action='remove' />
</foreach>

<code>
<![CDATA[ 
    //  Insert Heading Line on change of OBX-3
    //  Do not create on first grouping LAB AP CASE REPORT
    //  Do not create LAB AP EMBEDDED IMAGES if no data
]]></code>
<assign value='""' property='holdnewobx3' action='set' />
<assign value='"0"' property='tmpseq' action='set' />

<foreach property='source.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp()}' key='k4' >
<if condition='source.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k4).OBX:3.2}="LAB AP CASE REPORT"' >
<true>
<assign value='source.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k4).OBX:3.2}' property='holdnewobx3' action='set' />
<assign value='tmpseq+1' property='tmpseq' action='set' />
<assign value='source.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k4)}' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(tmpseq)}' action='set' />
<assign value='tmpseq' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(tmpseq).OBX:4}' action='set' />
<assign value='target.{PIDgrpgrp(1).ORCgrp(k2).OBR:4.1}' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(tmpseq).OBX:3.1}' action='set' />
<assign value='target.{PIDgrpgrp(1).ORCgrp(k2).OBR:4.1}' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(tmpseq).OBX:3.2}' action='set' />
<assign value='"1"' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(tmpseq).OBX:1}' action='set' />
<assign value='"ST"' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(tmpseq).OBX:2}' action='set' />
</true>
<false>
<if condition='source.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k4).OBX:3.2}=holdnewobx3' >
<true>
<assign value='tmpseq+1' property='tmpseq' action='set' />
<assign value='source.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k4)}' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(tmpseq)}' action='set' />
<assign value='tmpseq' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(tmpseq).OBX:4}' action='set' />
<assign value='target.{PIDgrpgrp(1).ORCgrp(k2).OBR:4.1}' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(tmpseq).OBX:3.1}' action='set' />
<assign value='target.{PIDgrpgrp(1).ORCgrp(k2).OBR:4.1}' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(tmpseq).OBX:3.2}' action='set' />
<assign value='"1"' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(tmpseq).OBX:1}' action='set' />
<assign value='"ST"' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(tmpseq).OBX:2}' action='set' />
</true>

<false>
<if condition='(source.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k4).OBX:3.2}="LAB AP EMBEDDED IMAGES")&amp;(source.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k4).OBX:5}="")' >
<false>
<assign value='tmpseq+1' property='tmpseq' action='set' />
<assign value='source.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k4).OBX}' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(tmpseq).OBX}' action='set' />
<assign value='tmpseq' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(tmpseq).OBX:4}' action='set' />
<assign value='$LENGTH(source.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k4).OBX:3.2})' property='tmplgth' action='set' />
<assign value='$EXTRACT(source.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k4).OBX:3.2},8,tmplgth)' property='holdOBX3desc' action='set' />
<assign value='holdOBX3desc' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(tmpseq).OBX:5}' action='set' />
<assign value='target.{PIDgrpgrp(1).ORCgrp(k2).OBR:4.1}' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(tmpseq).OBX:3.1}' action='set' />
<assign value='target.{PIDgrpgrp(1).ORCgrp(k2).OBR:4.1}' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(tmpseq).OBX:3.2}' action='set' />
<assign value='"1"' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(tmpseq).OBX:1}' action='set' />
<assign value='"ST"' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(tmpseq).OBX:2}' action='set' />
<assign value='source.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k4).OBX:3.2}' property='holdnewobx3' action='set' />

<assign value='tmpseq+1' property='tmpseq' action='set' />
<assign value='source.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k4)}' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(tmpseq)}' action='set' />
<assign value='tmpseq' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(tmpseq).OBX:4}' action='set' />
<assign value='target.{PIDgrpgrp(1).ORCgrp(k2).OBR:4.1}' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(tmpseq).OBX:3.1}' action='set' />
<assign value='target.{PIDgrpgrp(1).ORCgrp(k2).OBR:4.1}' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(tmpseq).OBX:3.2}' action='set' />
<assign value='"1"' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(tmpseq).OBX:1}' action='set' />
<assign value='"ST"' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(tmpseq).OBX:2}' action='set' />
</false>
</if>

<code>
<![CDATA[ 
  // set holdk1=k1
  //  set holdk3=k3
  // set holdk5=(target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k4).OBX})
  // $$$TRACE("holdobxcnt= "_holdobxcnt)
  // $$$TRACE("holdnewobx3= "_holdnewobx3_" obx= "_holdk5)
]]></code>
</false>
</if>
</false>
</if>
</foreach>
</foreach>

<code>
<![CDATA[ 
    //  Check table T_RegionsLab_OrderingProvider for a change in ordering provider 11/22/2017
    //  Change result message to table ordering provider 11/22/2017
]]></code>
<assign value='source.{PIDgrpgrp(1).ORCgrp(1).OBR:2.1}' property='tempCernerOrder' action='set' />
<assign value='source.{PIDgrpgrp(1).ORCgrp(1).ORC:12(1)}' property='tempORC12' action='set' />
<assign value='source.{PIDgrpgrp(1).ORCgrp(1).OBR:16(1)}' property='tempOBR16' action='set' />
<assign value='source.{PIDgrpgrp(1).ORCgrp(1).ORC:12(1).1}' property='tempInORC12id' action='set' />
<assign value='source.{PIDgrpgrp(1).ORCgrp(1).OBR:16(1).1}' property='tempInOBR16id' action='set' />
<assign value='""' property='tempDateResult' action='set' />
<assign value='""' property='tempDateCancel' action='set' />
<assign value='tempCernerOrder' property='wTableKey' action='set' />
<assign value='""' property='wTableData' action='set' />
<assign value='""' property='wtableresult' action='set' />
<assign value='..Lookup("T_RegionsLab_OrderingProvider",wTableKey)' property='wtableresult' action='set' />
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
    // table entry found - change ordering doc in message
]]></code>
<assign value='$PIECE(wtableresult,"|",1)' property='temptblORC12' action='set' />
<assign value='$PIECE(temptblORC12,"^",1)' property='temptblORC12id' action='set' />
<assign value='$PIECE(wtableresult,"|",2)' property='temptblOBR16' action='set' />
<assign value='$PIECE(temptblOBR16,"^",1)' property='temptblOBR16id' action='set' />
<assign value='$PIECE(wtableresult,"|",3)' property='temptblDateAdd' action='set' />
<assign value='$PIECE(wtableresult,"|",4)' property='temptblDateResult' action='set' />
<assign value='$PIECE(wtableresult,"|",5)' property='temptblDateCancel' action='set' />
<assign value='$ZDATE($NOW(),8)' property='tempDateResult' action='set' />
<code>
<![CDATA[ 
    // result from Regions - update table with result date
        set wTableData=(temptblORC12_"|"_temptblOBR16_"|"_temptblDateAdd_"|"_tempDateResult_"|"_temptblDateCancel_"|") 
        set wTableName="T_RegionsLab_OrderingProvider"
        do ##class(Ens.Util.LookupTable).%UpdateValue(wTableName,wTableKey,wTableData)	
]]></code>
<if condition='(tempInORC12id = temptblORC12id)&amp;(tempInOBR16id = temptblOBR16id)' >
<false>
<code>
<![CDATA[ 
    // ordering doc on table differs from regions hl7 message
    //  update hl7 message
    //
    //  if multiple orc do fornext to updated each orc/obr
]]></code>
<foreach property='target.{PIDgrpgrp(1).ORCgrp()}' key='k3' >
<assign value='temptblORC12' property='target.{PIDgrpgrp(1).ORCgrp(k3).ORC:12(1)}' action='set' />
<assign value='temptblOBR16' property='target.{PIDgrpgrp(1).ORCgrp(k3).OBR:16(1)}' action='set' />
</foreach>
</false>
</if>
</false>
</if>
</transform>
}

}
