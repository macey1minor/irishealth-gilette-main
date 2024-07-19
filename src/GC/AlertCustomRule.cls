/// 
Class GC.AlertCustomRule Extends Ens.Rule.Definition [ ProcedureBlock ]
{

Parameter RuleAssistClass = "EnsLib.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="" disabled="false">
<constraint name="msgClass" value="Ens.AlertRequest"></constraint>
<when condition="(DoesNotContain(Document.AlertText,&quot;timeout&quot;))&amp;&amp;(DoesNotContain(Document.AlertText,&quot;No Connection&quot;))&amp;&amp;(DoesNotContain(Document.AlertText,&quot;NOWAIT&quot;))">
<send transform="" target="Email.O.AlertEmailEnsemble"></send>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
