/// 
Class GC.MiicBsRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="CERT.CERT">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Archive">
<when condition="1">
<send transform="" target="File.O.ArchiveInbound"></send>
<return></return>
</when>
</rule>
<rule name="Block PROD Patients" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="((HL7.{PID:PatientidentifierList(1).ID}&lt;200000)||((HL7.{PID:PatientidentifierList(1).ID}&gt;299999)&amp;&amp;(HL7.{PID:PatientidentifierList(1).ID}&lt;900000)))">
<send transform="" target="File.O.ArchiveStopped"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
