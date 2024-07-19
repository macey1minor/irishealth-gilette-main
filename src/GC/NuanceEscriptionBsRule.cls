/// 
Class GC.NuanceEscriptionBsRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="A34,35,44 Missing MRG Segment" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A34,ADT_A35,ADT_A44"></constraint>
<when condition="DoesNotContain(HL7.{MRG})">
<return></return>
</when>
</rule>
<rule name="no MRN person add / update" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A28,ADT_A31"></constraint>
<when condition="(HL7.{PID:PatientIdentifierList(1).ID}=&quot;&quot;)">
<return></return>
</when>
</rule>
<rule name="Block Test Patients - ADT" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A01,ADT_A02,ADT_A03,ADT_A04,ADT_A05,ADT_A06,ADT_A07,ADT_A08,ADT_A09,ADT_A10,ADT_A11,ADT_A12,ADT_A13,ADT_A14,ADT_A15,ADT_A16,ADT_A17,ADT_A21,ADT_A22,ADT_A23,ADT_A24,ADT_A25,ADT_A26,ADT_A28,ADT_A29,ADT_A31,ADT_A34,ADT_A35,ADT_A38,ADT_A44,ADT_ADSC"></constraint>
<when condition="Exists(&quot;T_CernerProd_TestPatients&quot;,HL7.{PID:PatientIdentifierList(1).ID})">
<return></return>
</when>
</rule>
<rule name="Block Test Patients - SIU" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="SIU_S12,SIU_S13,SIU_S14,SIU_S15,SIU_S17,SIU_S26"></constraint>
<when condition="Exists(&quot;T_CernerProd_TestPatients&quot;,HL7.{PIDgrp(1).PID:PatientIdentifierList(1).ID})">
<return></return>
</when>
</rule>
<rule name="Block Test Patients - MDM from Nuance" disabled="false">
<constraint name="docCategory" value="22.Dictaphone"></constraint>
<constraint name="docName" value="MDM_T02,MDM_T04"></constraint>
<when condition="Exists(&quot;T_CernerProd_TestPatients&quot;,HL7.{PID:PatientIDInternalID(1).ID})">
<return></return>
</when>
</rule>
<rule name="Archive">
<when condition="1">
<send transform="" target="File.O.ArchiveInbound"></send>
</when>
</rule>
<rule name="Block Inpatient SIU" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="SIU_S12,SIU_S13,SIU_S14,SIU_S15,SIU_S17,SIU_S26"></constraint>
<when condition="HL7.{PIDgrp(1).PV1:PatientClass}=&quot;I&quot;">
<return></return>
</when>
</rule>
<rule name="ADT-SIU from Cerner" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="1">
<send transform="" target="NuanceEscription.P.bo"></send>
<return></return>
</when>
</rule>
<rule name="MDM from Dictaphone" disabled="false">
<constraint name="docCategory" value="22.Dictaphone"></constraint>
<when condition="1">
<send transform="" target="NuanceEscription.P.bo"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
