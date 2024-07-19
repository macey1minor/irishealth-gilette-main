Class GC.Muse2CernerORU Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='24.GE:ORU_R01' targetDocType='24.GE:ORU_R01' create='copy' language='objectscript' >
<code>
<![CDATA[ 
	//  Last Update: 07/10/2018 Al Johnson
	//  Last Moved to Prod:  07/10/2018
    //  Created 05/10/2017 Al Johnson
    //   Muse results for Cerner are being received against old QCPR orders and orderables
    //   Change orderable OBR-4.1 to "EKG" if seven digit QCPR order - OBR-2.1
    //
    //  Copy the Cerner order id from OBR-2 to OBR-3.  07/10/2018
    //  Copy OBR:7 if populated, else MSH:9 to OBR:22 resultstatuschangedate.  07/10/2018
    //  Copy OBR:7 if populated, else MSH:9 to OBR:27.4 quatitytimingstartdate.  07/10/2018
    //  Remove OBR:32 princialresultinterpretor, OBR:33 assistantresultintpretor, OBR:34 technician and OBR:35 transcriptionist
    //    all 3 fields only have a name and not formatted to spec
]]></code>
<code>
<![CDATA[ 
    //  7 digit order number is from QCPR
]]></code>
<if condition='($LENGTH(target.{OBR(1):2(1).1})=7)' >
<true>
<assign value='"EKG"' property='target.{OBR(1):4.1}' action='set' />
</true>
</if>

<code>
<![CDATA[ 
    //  Copy OBR:2 PlacerOrderID to OBR:3 FillerOrderID
    //  Populate OBR:22 and OBR:27.4
    //  Remove OBR:32 princialresultinterpretor, OBR:33 assistantresultintpretor, OBR:34 technician and OBR:35 transcriptionist
    //    all 4 fields only have a name and not formatted to spec
    //  Populate OBR:22 and OBR:27.4
]]></code>
<assign value='source.{OBR(1):2.1}' property='target.{OBR(1):3.1}' action='set' />

<assign value='""' property='target.{OBR(1):32}' action='set' />
<assign value='""' property='target.{OBR(1):33}' action='set' />
<assign value='""' property='target.{OBR(1):34}' action='set' />
<assign value='""' property='target.{OBR(1):35}' action='set' />

<assign value='""' property='tholdresultdate' action='set' />
<if condition='(source.{OBR(1):7.1}="")' >
<true>
<assign value='source.{MSH:7.1}' property='tholdresultdate' action='set' />
</true>
<false>
<assign value='source.{OBR(1):7.1}' property='tholdresultdate' action='set' />
</false>
</if>

<if condition='(source.{OBR(1):22.1}="")' >
<true>
<assign value='tholdresultdate' property='target.{OBR(1):22}' action='set' />
</true>
</if>

<if condition='(source.{OBR(1):27.4}="")' >
<true>
<assign value='tholdresultdate' property='target.{OBR(1):27.4}' action='set' />
</true>
</if>

</transform>
}

}
