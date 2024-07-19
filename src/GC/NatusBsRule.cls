/// 
Class GC.NatusBsRule Extends Ens.Rule.Definition [ ProcedureBlock ]
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Archive All" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="1">
<send transform="" target="File.O.ArchiveInbound"></send>
</when>
</rule>
<rule name="Block No OBX Result" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ORU_R01"></constraint>
<when condition="DoesNotContain(HL7.{ORCgrp(1).OBXgrp(1).OBX})">
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="1">
<send transform="" target="Natus.P.bo"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
