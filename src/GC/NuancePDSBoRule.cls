/// 
Class GC.NuancePDSBoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="do not process yet" disabled="true">
<when condition="1">
<return></return>
</when>
</rule>
<rule name="MDM from Cerner" disabled="false">
<constraint name="docCategory" value="231.Cernerbase"></constraint>
<constraint name="docName" value="MFN_M02"></constraint>
<when condition="1">
<send transform="" target="HL7.O.NuancePDSMfn"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
