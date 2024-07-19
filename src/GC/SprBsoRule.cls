/// 
Class GC.SprBsoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Archive">
<when condition="1">
<send transform="" target="File.O.ArchiveInbound"></send>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="source" value="Bs.P.Spr"></constraint>
<when condition="1">
<send transform="" target="HL7.O.SprOrmOru"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="source" value="HL7.S.SprOru"></constraint>
<when condition="1">
<send transform="" target="HL7.O.CrSprOru"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
