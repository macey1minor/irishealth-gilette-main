/// 
Class GC.NowPowBoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="send all adt" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A01,ADT_A03,ADT_A04,ADT_A08,ADT_A02,ADT_A05,ADT_A06,ADT_A07,ADT_A13,ADT_A28,ADT_A31"></constraint>
<when condition="1">
<send transform="GC.Cerner2NowPowADT" target="HL7.O.NowPowAdt"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A34"></constraint>
<when condition="1">
<send transform="GC.Cerner2NowPowMRG" target="HL7.O.NowPowAdt"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
