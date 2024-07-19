/// 
Class IIBAENSEMBLE.AlertRule Extends Ens.Rule.Definition [ ProcedureBlock ]
{

Parameter RuleAssistClass = "EnsLib.MsgRouter.VDocRuleAssistCompatible";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="IIBAENSEMBLE.Context" production="">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="">
<constraint name="source" value="BenTest.Bsvc.TCP"></constraint>
<constraint name="msgClass" value="Ens.AlertRequest"></constraint>
<when condition="1">
<send transform="NorthIdahoMt.Transforms.ErrorAlert" target="IIBAENSEMBLE.Bop.SendEmail"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
