/// 
Class GC.PS360RadiologyBsoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="" disabled="false">
<constraint name="source" value="HL7.S.CrPs360RadiologyOrmAdt"></constraint>
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A34"></constraint>
<when condition="DoesNotContain(HL7.{MRG})">
<return></return>
</when>
</rule>
<rule name="" disabled="true">
<constraint name="source" value="HL7.S.CrPs360RadiologyOrmAdt"></constraint>
<when condition="HL7.{PID:PatientIdentifierList(1).ID} In &quot;507424,515173,600000,600001&quot;">
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="source" value="HL7.S.Ps360RadiologyOru"></constraint>
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ORU_R01"></constraint>
<when condition="(HL7.{PID:PatientIdentifierList(1).ID} In &quot;507424,515173,600000,600001&quot;)&amp;&amp;(HL7.{ORCgrp(1).OBR:25}=&quot;&quot;)">
<send transform="" target="File.O.ArchiveStopped"></send>
<return></return>
</when>
</rule>
<rule name="Archive">
<when condition="1">
<send transform="" target="File.O.ArchiveInbound"></send>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="source" value="HL7.S.CrPs360RadiologyOrmAdt"></constraint>
<when condition="1">
<send transform="" target="HL7.O.Ps360RadiologyOrmAdt"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="source" value="HL7.S.Ps360RadiologyOru"></constraint>
<when condition="1">
<send transform="GC.PS360toCernerORU" target="HL7.O.CrPs360RadiologyOru"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="source" value="zzResend.S.AljOru"></constraint>
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ORU_R01"></constraint>
<when condition="1">
<send transform="GC.Ps3602CernerORUfix" target="HL7.O.CrPs360RadiologyOru"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
