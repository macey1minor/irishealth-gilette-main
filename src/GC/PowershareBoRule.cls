/// 
Class GC.PowershareBoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="CERT.CERT">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="SPR and PS360 results to Powershare" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ORU_R01"></constraint>
<when condition="HL7.{ORCgrp(1).OBR:25} In &quot;A,C,F&quot;">
<send transform="" target="HL7.O.PowershareOru"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
