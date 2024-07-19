/// 
Class GC.RLSolutionsBoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="CERT.CERT">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Merges A34,A35,A44" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A34,ADT_A35,ADT_A44"></constraint>
<when condition="1">
<send transform="GC.Cerner2RLSolutionsMrg" target="HL7.O.RLSolutionsAdt"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A05"></constraint>
<when condition="1">
<return></return>
</when>
</rule>
<rule name="ADT to RLSolutions" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="1">
<send transform="GC.Cerner2RLSolutionsADT" target="HL7.O.RLSolutionsAdt"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
