/// 
Class GC.CarefusionPFTBsoRule Extends Ens.Rule.Definition
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
<rule name="" disabled="false">
<constraint name="source" value="HL7.S.CrCarefusionPFTOrm"></constraint>
<when condition="(HL7.{PID:PatientIdentifierList(1).ID} In &quot;507424,515173,600000,600001&quot;)">
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="source" value="HL7.S.CrCarefusionPFTOrm"></constraint>
<when condition="1">
<send transform="" target="HL7.O.CarefusionPFTOrm"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="source" value="HL7.S.CarefusionPFTOru"></constraint>
<when condition="1">
<send transform="GC.Carefusion2CernerBase64" target="HL7.O.CrCarefusionPFTOru"></send>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="source" value="HL7.S.CarefusionPFTOru"></constraint>
<when condition="1">
<send transform="GC.Carefusion2CernerDicrete" target="HL7.O.CrCarefusionPFTOru"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
