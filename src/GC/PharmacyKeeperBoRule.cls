/// 
Class GC.PharmacyKeeperBoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="RDS from Cerner" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="RDS_O01"></constraint>
<when condition="1">
<send transform="" target="HL7.O.PharmacyKeeperRds"></send>
<return></return>
</when>
</rule>
<rule name="RDE from Cerner" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="RDE_O01"></constraint>
<when condition="1">
<send transform="" target="HL7.O.PharmacyKeeperRds"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
