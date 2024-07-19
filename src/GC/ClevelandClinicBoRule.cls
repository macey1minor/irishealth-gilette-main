/// 
Class GC.ClevelandClinicBoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="report only" disabled="false">
<constraint name="docCategory" value="231.ClevelandClinic"></constraint>
<constraint name="docName" value="ORU_R01"></constraint>
<when condition="1">
<send transform="GC.ClevelandClinic2CernerBase64" target="HL7.O.CrClevelandClinicOru"></send>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
