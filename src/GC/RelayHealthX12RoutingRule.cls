/// 
Class GC.RelayHealthX12RoutingRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.MsgRouter.VDocRuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.MsgRouter.VDocRoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="">
<constraint name="source" value="X12.S.CrRelayHealth270"></constraint>
<constraint name="msgClass" value="EnsLib.EDI.X12.Document"></constraint>
<when condition="1">
<send transform="" target="X12.O.RelayHealth270"></send>
<send transform="" target="File.O.ArchiveInboundX12"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="source" value="X12.S.RelayHealth271"></constraint>
<constraint name="msgClass" value="EnsLib.EDI.X12.Document"></constraint>
<when condition="1">
<send transform="" target="X12.O.CrRelayHealth271"></send>
<send transform="" target="File.O.ArchiveInboundX12"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
