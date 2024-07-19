/// 
Class GC.zzSprBsoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="" disabled="false">
<constraint name="source" value="zzQmint02.S.SPROrmOru"></constraint>
<when condition="1">
<send transform="" target="zzHL7.O.SprOrmOru"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="source" value="zzSPR.S.oruCarestream2Qmint02"></constraint>
<when condition="1">
<send transform="" target="zzSPR.O.oruCarestream2Qmint02"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
