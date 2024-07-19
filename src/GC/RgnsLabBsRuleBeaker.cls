/// 
Class GC.RgnsLabBsRuleBeaker Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Block Test Patients - ADT and ORM" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="Exists(&quot;T_CernerProd_TestPatients&quot;,HL7.{PID:PatientIdentifierList(1).ID})">
<return></return>
</when>
</rule>
<rule name="Block Test Patients - ORM" disabled="false">
<constraint name="docCategory" value="251.Regions"></constraint>
<constraint name="docName" value="ORM_O01"></constraint>
<when condition="Exists(&quot;T_CernerProd_TestPatients&quot;,HL7.{PIDgrp.PID:PatientIdentifierList(1).IDNumber})">
<return></return>
</when>
</rule>
<rule name="Block Test Patients - ORU" disabled="false">
<constraint name="docCategory" value="251.Regions"></constraint>
<constraint name="docName" value="ORU_R01"></constraint>
<when condition="Exists(&quot;T_CernerProd_TestPatients&quot;,HL7.{PIDgrpgrp(1).PIDgrp.PID:PatientIdentifierList(1).IDNumber})">
<return></return>
</when>
</rule>
<rule name="A34,35,44 Missing MRG Segment" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A34,ADT_A35,ADT_A44"></constraint>
<when condition="DoesNotContain(HL7.{MRG})">
<return></return>
</when>
</rule>
<rule name="Archive">
<when condition="1">
<send transform="" target="File.O.ArchiveInbound"></send>
</when>
</rule>
<rule name="Schema 231 From Cerner" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="1">
<send transform="" target="RgnsLab.P.boBeaker"></send>
<return></return>
</when>
</rule>
<rule name="Schema 251 From Regions" disabled="false">
<constraint name="docCategory" value="251.Regions"></constraint>
<when condition="1">
<send transform="" target="RgnsLab.P.boBeaker"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
