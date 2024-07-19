/// 
Class GC.PharmacyKeeperBsRule Extends Ens.Rule.Definition
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
<rule name="RDS " disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="RDS_O01"></constraint>
<when condition="1">
<send transform="" target="PharmacyKeeper.P.bo"></send>
<return></return>
</when>
</rule>
<rule name="RDE" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="RDE_O01"></constraint>
<when condition="1">
<send transform="" target="PharmacyKeeper.P.bo"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
