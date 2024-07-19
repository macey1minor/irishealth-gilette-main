/// Created 10/01/2014
/// Created By Ellen Leichtman
/// 
Class GC.eDocsRadBsRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Block Test Patients - ORU" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="Exists(&quot;T_CernerProd_TestPatients&quot;,HL7.{PID:PatientIdentifierList(1).ID})">
<return></return>
</when>
</rule>
<rule name="Archive">
<when condition="1">
<send transform="" target="File.O.ArchiveInbound"></send>
</when>
</rule>
<rule name="Radiology Results to Edocs" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="1">
<send transform="" target="eDocs.P.bo"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
