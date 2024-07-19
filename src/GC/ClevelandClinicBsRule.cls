/// 
Class GC.ClevelandClinicBsRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Archive" disabled="false">
<when condition="1">
<send transform="" target="File.O.ArchiveInbound"></send>
</when>
</rule>
<rule name="Block Test Patients" disabled="true">
<constraint name="docCategory" value="231.ClevelandClinic"></constraint>
<when condition="Exists(&quot;T_CernerProd_TestPatients&quot;,Substring(HL7.{PID:PatientIdentifierList(1).ID},3,8))">
<send transform="" target="File.O.ArchiveStopped"></send>
<return></return>
</when>
</rule>
<rule name="Cert MRN Range" disabled="false">
<constraint name="docCategory" value="231.ClevelandClinic"></constraint>
<when condition="1">
<send transform="" target="ClevelandClinic.P.bo"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
