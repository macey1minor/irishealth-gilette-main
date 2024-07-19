/// 
Class GC.AcuityADTBsRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="PV1.3 table lookup" disabled="false">
<constraint name="source" value="HL7.S.CrAcuityADT"></constraint>
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A01,ADT_A02,ADT_A03,ADT_A04,ADT_A05,ADT_A06,ADT_A07,ADT_A08,ADT_A11,ADT_A13,ADT_A21,ADT_A22,ADT_A17,ADT_A18,ADT_A34,ADT_A35"></constraint>
<when condition="1">
<send transform="" target="Bso.P.AcuityADT"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
