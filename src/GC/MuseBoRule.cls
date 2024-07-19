/// 
Class GC.MuseBoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Adt and Orm" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="1">
<send transform="" target="HL7.O.MuseAdtOrm"></send>
<return></return>
</when>
</rule>
<rule name="Oru" disabled="false">
<constraint name="docCategory" value="24.GE"></constraint>
<when condition="1">
<send transform="GC.Muse2CernerORU" target="HL7.O.CrMuseOru"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
