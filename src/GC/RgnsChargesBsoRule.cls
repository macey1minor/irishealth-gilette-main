/// 
Class GC.RgnsChargesBsoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Archive">
<when condition="1">
<send transform="" target="File.O.ArchiveInbound"></send>
</when>
</rule>
<rule name="CDM from Reglab-Update Prod Cerner Table-Send CDM to Affinity" disabled="false">
<constraint name="source" value="HL7.S.RgnsLabDft"></constraint>
<constraint name="docCategory" value="22.RegLab"></constraint>
<constraint name="docName" value="GLT_CDM"></constraint>
<when condition="1">
<send transform="GC.Regions.RegionsCDMDeptLoadTBL" target="zzRegLab.O.Qmint02CdmDft"></send>
<return></return>
</when>
</rule>
<rule name="DOS &lt; 20170212" disabled="false">
<constraint name="source" value="HL7.S.RgnsLabDft"></constraint>
<constraint name="docCategory" value="22.RegLab"></constraint>
<constraint name="docName" value="GLT_DFT"></constraint>
<when condition="(HL7.{ZDF:ZDF6DOS}&lt;&quot;20170212&quot;)">
<send transform="" target="zzRegLab.O.Qmint02CdmDft"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="docCategory" value="22.RegLab"></constraint>
<constraint name="docName" value="GLT_DFT"></constraint>
<when condition="SubString(HL7.{ZDF:8},1,3) IN &quot;PAY,ADJ,CRE&quot;">
<send transform="" target="File.O.ArchiveStopped"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="docCategory" value="22.RegLab"></constraint>
<constraint name="docName" value="GLT_DFT"></constraint>
<when condition="(DoesNotStartWith(HL7.{ZDF:ZDF8ChargeCode},&quot;4&quot;))&amp;&amp;(HL7.{ZDF:ZDF11ExtAmount}!=&quot;0&quot;)&amp;&amp;(HL7.{ZDF:ZDF7ChargeCreditCode}=&quot;CR&quot;)&amp;&amp;(HL7.{ZDF:ZDF8ChargeCode}=&quot;CDM00011403&quot;)">
<send transform="GC.RegLab2CernerGDFTv1,GC.Regions2CernerCredit" target="Email.O.AlertEmailRegCredit"></send>
</when>
</rule>
<rule name="DFTs from Reglab" disabled="false">
<constraint name="docCategory" value="22.RegLab"></constraint>
<constraint name="docName" value="GLT_DFT"></constraint>
<when condition="(DoesNotStartWith(HL7.{ZDF:ZDF8ChargeCode},&quot;4&quot;))&amp;&amp;(HL7.{ZDF:ZDF11ExtAmount}!=&quot;0&quot;)">
<send transform="GC.RegLab2CernerGDFTv1" target="HL7.O.CrRgnsLabDft"></send>
<send transform="GC.Regions2CernerChargeList" target="File.O.RegionsCharges"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
