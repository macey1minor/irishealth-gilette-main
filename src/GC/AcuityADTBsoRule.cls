/// 
Class GC.AcuityADTBsoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Block enctr type: Outpatient Message" disabled="false">
<when condition="HL7.{PV1:PatientType}=&quot;Outpatient Message&quot;">
<return></return>
</when>
</rule>
<rule name="Archive - 01052018 - Alj" disabled="false">
<when condition="1">
<send transform="" target="File.O.ArchiveInbound"></send>
</when>
</rule>
<rule name="Blocking test patient msgs" disabled="false">
<constraint name="source" value="Bso.P.AcuityADT"></constraint>
<when condition="(HL7.{PID:PatientIdentifierList(1).ID} In &quot;507424,515173,600000,600001&quot;)">
<return></return>
</when>
</rule>
<rule name="PV1.3 table lookup" disabled="false">
<constraint name="source" value="Bs.P.AcuityADT"></constraint>
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A01,ADT_A02,ADT_A03,ADT_A04,ADT_A05,ADT_A06,ADT_A07,ADT_A08,ADT_A11,ADT_A13,ADT_A21,ADT_A22,ADT_A17"></constraint>
<when condition="1">
<send transform="GC.CernerAdt2AcuityAdt" target="HL7.O.AcuityAdt"></send>
<return></return>
</when>
</rule>
<rule name="Merge" disabled="false">
<constraint name="source" value="HL7.S.CrAcuityADT"></constraint>
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A34,ADT_A35"></constraint>
<when condition="1">
<send transform="GC.Cerner2AcuityADTMrg" target="HL7.O.AcuityAdt"></send>
<send transform="GC.AcuityMRGtoADTa08" target="HL7.O.AcuityAdt"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}