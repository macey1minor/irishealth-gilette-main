/// 
Class GC.zzNuanceEscriptionBsoHold2Rule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Archive" disabled="true">
<when condition="1">
<send transform="" target="File.O.ArchiveInbound"></send>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="source" value="zzBso.P.eDocsNuanceHold1"></constraint>
<when condition="1">
<send transform="" target="zzFile.O.eDOCSNuance"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
