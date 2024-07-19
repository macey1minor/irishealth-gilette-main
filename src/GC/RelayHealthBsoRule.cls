/// 
Class GC.RelayHealthBsoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="CernerAdtsforRelayHealth" effectiveBegin="" effectiveEnd="">
<rule name="blocking test patient msgs" disabled="false">
<constraint name="source" value="HL7.S.CrRelayHealthAdt"></constraint>
<when condition="(HL7.{PID:PatientIdentifierList(1).ID} In &quot;507424,515173,600000,600001&quot;)">
<return></return>
</when>
</rule>
<rule name="Archive">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="1">
<send transform="" target="File.O.ArchiveInbound"></send>
</when>
</rule>
<rule name="New for Cerner" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="1">
<send transform="" target="HL7.O.RelayHealthAdt"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
