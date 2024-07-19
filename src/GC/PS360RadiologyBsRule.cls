/// 
Class GC.PS360RadiologyBsRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A34,ADT_A35,ADT_A44"></constraint>
<when condition="DoesNotContain(HL7.{MRG})">
<return></return>
</when>
</rule>
<rule name="Block Test Patients - ADT, ORM and ORU" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="Exists(&quot;T_CernerProd_TestPatients&quot;,HL7.{PID:PatientIdentifierList(1).ID})">
<return></return>
</when>
</rule>
<rule name="Archive" disabled="false">
<when condition="1">
<send transform="" target="File.O.ArchiveInbound"></send>
</when>
</rule>
<rule name="Block Prelim Results RFC SD-81257" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ORU_R01"></constraint>
<when condition="(HL7.{ORCgrp(1).OBR:25}=&quot;P&quot;)">
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="1">
<send transform="" target="PS360Radiology.P.bo"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
