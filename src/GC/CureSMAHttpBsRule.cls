/// 
Class GC.CureSMAHttpBsRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="CureSMA ccd docs" effectiveBegin="" effectiveEnd="">
<rule name="" disabled="false">
<constraint name="source" value="HTTP.S.CrCureSMAccd"></constraint>
<when condition="1">
<send transform="" target="File.O.ArchiveFileTransfers"></send>
<send transform="" target="HTTP.O.CureSMAccd"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
