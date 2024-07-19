/// 
Class GC.EdwBoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Remove Test Patients" disabled="false">
<when condition="(HL7.{PID:PatientIdentifierList(1).ID} In &quot;507424,515173,600000,600001,613174&quot;)">
<return></return>
</when>
</rule>
<rule name="ADT for DimPerson" disabled="false">
<constraint name="docName" value="ADT_A01,ADT_A03,ADT_A04,ADT_A05,ADT_A08,ADT_A13,ADT_A28,ADT_A38"></constraint>
<when condition="1">
<send transform="EDW.dtl.Cerner2EdwADT" target="SQL.O.EdwAdt"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}