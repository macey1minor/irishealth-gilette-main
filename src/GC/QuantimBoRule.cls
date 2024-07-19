/// 
Class GC.QuantimBoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="blocking test patient msgs" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="(HL7.{PID:PatientIdentifierList(1).ID} In &quot;507424,515173,600000,600001,613174&quot;)">
<return></return>
</when>
</rule>
<rule name="Adt" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A01,ADT_A03,ADT_A04,ADT_A06,ADT_A07,ADT_A08,ADT_A11,ADT_A13,ADT_A28,ADT_A31"></constraint>
<when condition="1">
<send transform="GC.CernerADT2QuantimADT" target="HL7.O.QuantimADT"></send>
<return></return>
</when>
</rule>
<rule name="ADTMerge" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A34"></constraint>
<when condition="1">
<send transform="GC.CernerADTMrg2QuantimADTMrg" target="HL7.O.QuantimADT"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
