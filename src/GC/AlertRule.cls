/// 07/11/11 updated source names
Class GC.AlertRule Extends Ens.Rule.Definition [ ProcedureBlock ]
{

Parameter RuleAssistClass = "EnsLib.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="" disabled="false">
<when condition="1">
<send transform="" target="Bo.P.AlertsCustom"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
