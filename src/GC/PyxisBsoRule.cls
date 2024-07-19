/// 
Class GC.PyxisBsoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Blocking test patient msgs" disabled="false">
<constraint name="source" value="HL7.S.CrPyxisAdtRde"></constraint>
<when condition="(HL7.{PID:PatientIdentifierList(1).ID} In &quot;507424,515173,600000,600001&quot;)">
<return></return>
</when>
</rule>
<rule name="Al - Temp" disabled="true">
<constraint name="source" value="HL7.S.CrPyxisAdtRde"></constraint>
<constraint name="docCategory" value="231.CernerPyxis"></constraint>
<constraint name="docName" value="ADT_A03"></constraint>
<when condition="1">
<return></return>
</when>
</rule>
<rule name="Archive">
<when condition="1">
<send transform="" target="File.O.ArchiveInbound"></send>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="source" value="HL7.S.CrPyxisAdtRde"></constraint>
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="RDE_O01"></constraint>
<when condition="1">
<send transform="GC.Cerner2PyxisRDE" target="HL7.O.PyxisAdtRde"></send>
<return></return>
</when>
</rule>
<rule name="Merge A35 &amp; send A03 for dead FIN" disabled="false">
<constraint name="source" value="HL7.S.CrPyxisAdtRde"></constraint>
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A35"></constraint>
<when condition="1">
<send transform="GC.Cerner2PyxisMerge" target="HL7.O.PyxisAdtRde"></send>
<send transform="GC.Cerner2PyxisMrg2ADT03" target="HL7.O.PyxisAdtRde"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="source" value="HL7.S.CrPyxisAdtRde"></constraint>
<when condition="1">
<send transform="" target="HL7.O.PyxisAdtRde"></send>
<return></return>
</when>
</rule>
<rule name="Filtering out item update MFN" disabled="false">
<constraint name="source" value="HL7.S.CrPyxisMfn"></constraint>
<when condition="(Document.{MFEgrp(1).MFE:1}=&quot;MUP&quot;)">
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="source" value="HL7.S.CrPyxisMfn"></constraint>
<when condition="1">
<send transform="" target="HL7.O.PyxisAdtRde"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="source" value="HL7.S.PyxisDftZpm"></constraint>
<when condition="1">
<send transform="" target="HL7.O.CrPyxisDftZpm"></send>
<return></return>
</when>
</rule>
<rule name="ZPM Unload going to Cerner from Pyxis" disabled="true">
<constraint name="source" value="HL7.S.PyxisDftZpm"></constraint>
<when condition="(HL7.{MSH.MessageType}=&quot;ZPM&quot;)&amp;&amp;(HL7.{ZPM.PocketCode}=&quot;U&quot;)">
<send transform="GC.PyxisZPMUnload2Cerner" target="HL7.O.CrPyxisDftZpm"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
