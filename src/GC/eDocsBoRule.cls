/// Created 10/01/2014
/// Created By Ellen Leichtman
/// 
Class GC.eDocsBoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Remove Test Patients" disabled="true">
<when condition="(HL7.{PID:PatientIdentifierList(1).ID} In &quot;507424,515173,600000,600001&quot;)">
<return></return>
</when>
</rule>
<rule name="Merge MRN to SameMRN" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A34"></constraint>
<when condition="HL7.{PID:3(1).1}=HL7.{MRG:1(1).1}">
<send transform="" target="File.O.ArchiveStopped"></send>
<return></return>
</when>
</rule>
<rule name="Merge" disabled="false">
<constraint name="docName" value="ADT_A34"></constraint>
<when condition="1">
<send transform="GC.Cerner2eDocsSqlADT40" target="SQL.O.eDocsAdt2Prod2019"></send>
<return></return>
</when>
</rule>
<rule name="A01,A03,A04,A08,A11,A13,A28,A31" disabled="false">
<constraint name="docName" value="ADT_A01,ADT_A03,ADT_A04,ADT_A08,ADT_A11,ADT_A13,ADT_A28,ADT_A31"></constraint>
<when condition="1">
<send transform="GC.Cerner2eDocsSqlADT" target="SQL.O.eDocsAdt2Prod2019"></send>
<return></return>
</when>
</rule>
<rule name="Radiology Results to Edocs" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ORU_R01"></constraint>
<when condition="(HL7.{ORCgrp(1).OBR:25} DoesNotContain &quot;P&quot;) DoesNotContain &quot;P&quot;">
<send transform="GC.Cerner2eDOCSRadTag" target="File.O.eDOCSRad"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
