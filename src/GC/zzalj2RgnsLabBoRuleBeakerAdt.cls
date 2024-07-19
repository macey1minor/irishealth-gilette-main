/// 
Class GC.zzalj2RgnsLabBoRuleBeakerAdt Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Outpatient from Cerner" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A01,ADT_A02,ADT_A03,ADT_A04,ADT_A05,ADT_A06,ADT_A07,ADT_A08,ADT_A09,ADT_A10,ADT_A11,ADT_A12,ADT_A13,ADT_A14,ADT_A15,ADT_A16,ADT_A17,ADT_A21,ADT_A22,ADT_A23,ADT_A24,ADT_A25,ADT_A26,ADT_A28,ADT_A29,ADT_A31,ADT_A34,ADT_A38,ADT_A35,ADT_A44,ADT_ADSC"></constraint>
<when condition="Document.{PV1:2}!=&quot;I&quot;">
<return></return>
</when>
</rule>
<rule name="ADTs from Cerner" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A01,ADT_A02,ADT_A03,ADT_A04,ADT_A05,ADT_A06,ADT_A07,ADT_A08,ADT_A09,ADT_A10,ADT_A11,ADT_A12,ADT_A13,ADT_A14,ADT_A15,ADT_A16,ADT_A17,ADT_A21,ADT_A22,ADT_A23,ADT_A24,ADT_A25,ADT_A26,ADT_A28,ADT_A29,ADT_A31,ADT_ADSC,ADT_A44,ADT_A38,ADT_A35,ADT_A34"></constraint>
<when condition="Document.{PV1:2}=&quot;I&quot;">
<send transform="" target="HL7.O.RgnsLabAdtOrmBeaker"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
