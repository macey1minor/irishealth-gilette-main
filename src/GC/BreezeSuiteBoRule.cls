/// 
Class GC.BreezeSuiteBoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="report only" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ORU_R01"></constraint>
<when condition="1">
<send transform="" target="HL7.O.CrBreezeSuiteOru"></send>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ORM_O01"></constraint>
<when condition="1">
<send transform="" target="HL7.O.BreezeSuiteOrm"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
