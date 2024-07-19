/// 
Class GC.PyxisBsRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Block Test Patients - ADT and RDE" disabled="true">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="Exists(&quot;T_CernerProd_TestPatients&quot;,HL7.{PID:PatientIdentifierList(1).ID})">
<return></return>
</when>
</rule>
<rule name="Block Test Patients - DFT" disabled="false">
<constraint name="docCategory" value="23.Pyxis"></constraint>
<when condition="Exists(&quot;T_CernerProd_TestPatients&quot;,HL7.{PID:PatientIDInternalID(1).ID})">
<return></return>
</when>
</rule>
<rule name="Ignore messages with Missing PID segment. " disabled="false">
<constraint name="docCategory" value="23.Pyxis"></constraint>
<when condition="HL7.{PID:PatientIDInternalID(1).ID}=&quot;&quot;">
<send transform="" target="File.O.ArchiveStopped"></send>
<return></return>
</when>
</rule>
<rule name="Archive">
<when condition="1">
<send transform="" target="File.O.ArchiveInbound"></send>
</when>
</rule>
<rule name="From HL7..S.CrPyxisAdtRde" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="1">
<send transform="" target="Pyxis.P.bo"></send>
<return></return>
</when>
</rule>
<rule name="From HL7.S.CrPyxisMfn" disabled="false">
<constraint name="docCategory" value="231.CernerPyxis"></constraint>
<when condition="1">
<send transform="" target="Pyxis.P.bo"></send>
<return></return>
</when>
</rule>
<rule name="From HL7.S.PyxisDftZpm" disabled="false">
<constraint name="docCategory" value="23.Pyxis"></constraint>
<when condition="1">
<send transform="" target="Pyxis.P.bo"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
