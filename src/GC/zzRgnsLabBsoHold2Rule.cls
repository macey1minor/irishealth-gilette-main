/// 
Class GC.zzRgnsLabBsoHold2Rule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="QCPR Order Nbrs" disabled="false">
<constraint name="docCategory" value="22.RegLab"></constraint>
<constraint name="docName" value="ORU_R01"></constraint>
<when condition="1">
<send transform="" target="File.O.ArchiveStopped"></send>
<send transform="" target="zzRegLab.O.Qmint02OrmOru"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
