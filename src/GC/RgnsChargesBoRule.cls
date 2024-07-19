/// 
Class GC.RgnsChargesBoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="" disabled="false">
<constraint name="docCategory" value="22.RegLab"></constraint>
<constraint name="docName" value="GLT_DFT"></constraint>
<when condition="(HL7.{ZDF:ZDF11ExtAmount}!=&quot;0&quot;)&amp;&amp;(HL7.{ZDF:ZDF7ChargeCreditCode}=&quot;CR&quot;)&amp;&amp;((HL7.{ZDF:ZDF8ChargeCode}=&quot;CDM00011403&quot;)||(HL7.{ZDF:ZDF8ChargeCode}=&quot;30084999001&quot;))">
<send transform="GC.RegLab2CernerGDFTv4,GC.Regions2CernerCredit" target="Email.O.AlertEmailRegCredit"></send>
</when>
</rule>
<rule name="DFTs from Reglab" disabled="true">
<constraint name="docCategory" value="22.RegLab"></constraint>
<constraint name="docName" value="GLT_DFT"></constraint>
<when condition="(HL7.{ZDF:ZDF11ExtAmount}!=&quot;0&quot;)">
<send transform="GC.RegLab2CernerGDFTv2" target="HL7.O.CrRgnsLabDft"></send>
<send transform="GC.Regions2CernerChargeListv2" target="File.O.RegionsCharges"></send>
<return></return>
</when>
</rule>
<rule name="DFTs from Reglab" disabled="false">
<constraint name="docCategory" value="22.RegLab"></constraint>
<constraint name="docName" value="GLT_DFT"></constraint>
<when condition="(HL7.{ZDF:ZDF11ExtAmount}!=&quot;0&quot;)">
<send transform="GC.RegLab2CernerGDFTv4" target="HL7.O.CrRgnsLabDft"></send>
<send transform="GC.Regions2CernerChargeListv4" target="File.O.RegionsChargesv3"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
