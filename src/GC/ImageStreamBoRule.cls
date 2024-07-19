/// Route ADT to ImageStream from Affinity
/// updated June 2 - stop all messages as there is not a test enviroment. 
Class GC.ImageStreamBoRule Extends Ens.Rule.Definition [ ProcedureBlock ]
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="1">
<send transform="" target="HL7.O.ImageStreamAdt"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
