/// Route ADT to ImageStream from Affinity
/// updated June 2 - stop all messages as there is not a test enviroment. 
Class GC.zzImageStreamBoRule Extends Ens.Rule.Definition [ ProcedureBlock ]
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssistCompatible";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="QCPR ADT Feed ImageStream" disabled="false">
<constraint name="source" value="zzQmint02.S.ImageStreamAdt"></constraint>
<when condition="1">
<send transform="" target="HL7.O.ImageStreamAdt"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="msgClass" value="EnsLib.HL7.Message"></constraint>
<when condition="1">
<send transform="" target="File.O.ArchiveInbound"></send>
</when>
</rule>
<rule name="" disabled="true">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="(HL7.{PID:PatientIdentifierList(1).ID}&gt;399999)&amp;&amp;(HL7.{PID:PatientIdentifierList(1).ID}&lt;600000)">
<send transform="" target="File.O.ArchiveStopped"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="source" value="HL7.S.CrImageSteamAdt"></constraint>
<when condition="1">
<send transform="" target="HL7.O.ImageStreamAdt"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
