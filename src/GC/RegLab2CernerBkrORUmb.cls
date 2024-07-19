Class GC.RegLab2CernerBkrORUmb Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='251.Regions:ORU_R01' targetDocType='251.Regions:ORU_R01' create='copy' language='objectscript' >
<code>
<![CDATA[ 
	//  Last Update: 01/24/2022 Al Johnson
	//  Last Moved to Prod:  01/26/2022 Al Johnson
    //  Created 08/20/2018 Al Johnson
    //
    //  Beaker version - schema changed from 22.RegLab to 231.Cerner
    //   Changed to version 251.Regions 10/15/2018
    //
    //   copy Regions Message to Cerner output
    //   remove OBXgrp
    //   string together OBX result messages for Cerner
    //   write one OBX with new data
    //  12/12/2016  send TX in OBX-2, not ST. String has a limit of 255 characters so PowerChart display is bad.
    //  01/29/2107 check for OBX-5 This is considered a significant result. Clinical correlation is indicated. and set ABN abnormal result
    //
    //  03/23/2017 Populate OBR-22 with MSH-7 datetime of message
    //  03/23/2017 Populate OBR-27.4 with MSH-7 datetime of message
    //
    //  Check table T_RegionsLab_OrderingProvider for a change in ordering provider 11/22/2017
    //  Change result message to table ordering provider 11/22/2017
    //  Update table with result date 11/22/2017
    //
    //  01/02/2018 change ABN to 'A' for abnormal result
    //  11/27/2018 Beaker Epic sends test in OBR:4.1, take from there
    //  11/27/2018 Beaker Epic changed to send report in OBX - Cerner discrete as seperate viewer
    //  11/27/2018 Performing Lab not being sent in OBX:15
    //
    //  03/21/2019 Move NTE segments from OBR to after OBX
    //  03/21/2019 Include specific OBX NTE segments in OBX string
    //
    //  03/27/2019 Check OBX:3.1 for value.  If populated add OBX:3.2 to OBX:5 in new OBX
    //
    //  06/03/2021 Check Test for specific values and set OBX(1)-3.1 and 3.2  RFC SD-85921
    //             Anaerobic = ANAC Aerobic = AERC Extended Anaerobic = EANAC Extended Aerobic = EAERC
    //
    //  01/24/2022 Embed OBR NTE segments in data blob, add heading ADDITIONAL INFORMATION SD-110894 RFC SD-113789
]]></code>
<foreach property='target.{PIDgrpgrp(1).ORCgrp()}' key='k2' >
<assign value='source.{MSH:DateTimeOfMessage.Time}' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBR:22}' action='set' />
<assign value='source.{MSH:DateTimeOfMessage.Time}' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBR:27.4}' action='set' />
<if condition='(source.{PIDgrpgrp(1).ORCgrp(k2).OBR:ResultStatus} = "") || (source.{PIDgrpgrp(1).ORCgrp(k2).OBR:ResultStatus} = "I")' >
<true>
<assign value='"P"' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBR:ResultStatus}' action='set' />
</true>
</if>
<code>
<![CDATA[ 
    //  Remove OBX segments copied from source
    //  Set tempfield obx5 to check for obx3 update
]]></code>
<assign value='""' property='tempobx5' action='set' />
<foreach property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp()}' key='k1' >
<if condition='(..StartsWith(target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:ObservationValue(1)},"Test:"))' >
<true>
<assign value='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:ObservationValue(1)}' property='tempobx5' action='set' />
</true>
</if>
<assign value='' property='target.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1)}' action='remove' />
</foreach>
<code>
<![CDATA[ 
    //  String descriptions together, remove ~ from col 1 add performed at line
]]></code>
<assign value='""' property='tempabnormal' action='set' />
<assign value='""' property='holdOBXdesc' action='set' />
<assign value='""' property='holdOBXdesc1' action='set' />
<assign value='""' property='holdOBXdesc1a' action='set' />
<foreach property='source.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp()}' key='k1' >

<if condition='(source.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:3.1}="")' >
<true>
<assign value='$TR(source.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:5},"^"," ")' property='holdOBXdesc1' action='set' />
<assign value='(holdOBXdesc_"~"_holdOBXdesc1)' property='holdOBXdesc' action='set' />
</true>
<false>
<assign value='source.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:3.2}' property='holdOBXdesc1a' action='set' />
<assign value='$TR(source.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:5},"^"," ")' property='holdOBXdesc1' action='set' />
<assign value='(holdOBXdesc_"~"_holdOBXdesc1a_": "_holdOBXdesc1)' property='holdOBXdesc' action='set' />
</false>
</if>

<if condition='source.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).OBX:8(1)}=""' >
<false>
<assign value='"A"' property='tempabnormal' action='set' />
</false>
</if>
<foreach property='source.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).NTE()}' key='k4' >
<assign value='$TR(source.{PIDgrpgrp(1).ORCgrp(k2).OBXgrp(k1).NTE(k4):3},"^"," ")' property='holdOBXdesc1' action='set' />
<assign value='(holdOBXdesc_"~"_holdOBXdesc1)' property='holdOBXdesc' action='set' />
</foreach>
</foreach>
</foreach>
<code>
<![CDATA[ 
   set holdOBXdesc=$REPLACE(holdOBXdesc,"~","",1,1)
   
   //   <assign value='source.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX:15}' property='PERFlab' action='set' />
   //   <assign value='(holdOBXdesc_"~"_PERFlab)' property='holdOBXdesc' action='set' />
]]></code>

<assign value='""' property='target.{PIDgrpgrp(1).ORCgrp(1).OBR:4}' action='set' />
<assign value='source.{PIDgrpgrp(1).ORCgrp(1).OBR:4.1}' property='target.{PIDgrpgrp(1).ORCgrp(1).OBR:4.1}' action='set' />
<assign value='source.{PIDgrpgrp(1).ORCgrp(1).OBR:4.1}' property='target.{PIDgrpgrp(1).ORCgrp(1).OBR:4.2}' action='set' />
<assign value='"MB"' property='target.{PIDgrpgrp(1).ORCgrp(1).OBR:24}' action='set' />
<assign value='"1"' property='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX:SetIDOBX}' action='set' />
<assign value='"TX"' property='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX:ValueType}' action='set' />
<assign value='source.{PIDgrpgrp(1).ORCgrp(1).OBR:4.1}' property='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX:ObservationIdentifier.Identifier}' action='set' />
<assign value='source.{PIDgrpgrp(1).ORCgrp(1).OBR:4.1}' property='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX:ObservationIdentifier.Text}' action='set' />
<assign value='holdOBXdesc' property='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX:5}' action='set' />
<assign value='tempabnormal' property='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX:8}' action='set' />
<assign value='target.{PIDgrpgrp(1).ORCgrp(1).OBR:ResultStatus}' property='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX:11}' action='set' />
<assign value='source.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX:15}' property='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX:15}' action='set' />

<code>
<![CDATA[ 
   //  6/3/2021 set obx:3.1 and obx:3.2 different on specific reports
]]></code>
<if condition='tempobx5="Test:               Anaerobic Culture"' >
<true>
<assign value='"ANAC"' property='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX:ObservationIdentifier.Identifier}' action='set' />
<assign value='"ANAC"' property='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX:ObservationIdentifier.Text}' action='set' />
</true>
</if>

<if condition='tempobx5="Test:               Aerobic Culture"' >
<true>
<assign value='"AERC"' property='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX:ObservationIdentifier.Identifier}' action='set' />
<assign value='"AERC"' property='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX:ObservationIdentifier.Text}' action='set' />
</true>
</if>

<if condition='tempobx5="Test:               Anaerobic Culture Extended Incubation 14 Days"' >
<true>
<assign value='"EANAC"' property='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX:ObservationIdentifier.Identifier}' action='set' />
<assign value='"EANAC"' property='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX:ObservationIdentifier.Text}' action='set' />
</true>
</if>

<if condition='tempobx5="Test:               Aerobic Culture Extended Incubation 14 Days"' >
<true>
<assign value='"EAERC"' property='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX:ObservationIdentifier.Identifier}' action='set' />
<assign value='"EAERC"' property='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX:ObservationIdentifier.Text}' action='set' />
</true>
</if>

<code>
<![CDATA[ 
    //  Remove NTE segments following OBR - move to follow OBX
    //
    //  Embed NTE data in OBX data blob
]]></code>
<assign value='""' property='temphasnte' action='set' />
<assign value='""' property='tempnteseg2' action='set' />
<assign value='""' property='tempnteseg3' action='set' />
<assign value='"~ADDITIONAL INFORMATION~-------------------------------------------"' property='holdnteseg1' action='set' />

<foreach property='target.{PIDgrpgrp(1).ORCgrp()}' key='k5' >
<foreach property='target.{PIDgrpgrp(1).ORCgrp(k5).NTE()}' key='k6' >
<assign value='' property='target.{PIDgrpgrp(1).ORCgrp(k5).NTE(k6)}' action='remove' />
<assign value='"1"' property='temphasnte' action='set' />
<assign value='$TR(source.{PIDgrpgrp(1).ORCgrp(k5).NTE(k6):3},"^"," ")' property='tempnteseg3' action='set' />
<assign value='(tempnteseg2_"~"_tempnteseg3)' property='tempnteseg2' action='set' />
</foreach>
</foreach>

<if condition='temphasnte="1"' >
<true>
<assign value='(holdnteseg1_tempnteseg2)' property='tempnteseg2' action='set' />
<assign value='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX:5}' property='tempnteseg3' action='set' />
<assign value='tempnteseg3_tempnteseg2_"~"' property='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX:5}' action='set' />
</true>
</if>

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
