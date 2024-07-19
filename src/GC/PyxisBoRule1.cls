/// 
Class GC.PyxisBoRule1 Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="RDE_O01"></constraint>
<when condition="1">
<send transform="GC.Cerner2PyxisRDE" target="HL7.O.PyxisAdtRde"></send>
<return></return>
</when>
</rule>
<rule name="Merge A35 &amp; send A03 for dead FIN" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A35"></constraint>
<when condition="1">
<send transform="GC.Cerner2PyxisMerge" target="HL7.O.PyxisAdtRde"></send>
<send transform="GC.Cerner2PyxisMrg2ADT03" target="HL7.O.PyxisAdtRde"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A01,ADT_A02,ADT_A03,ADT_A04,ADT_A05,ADT_A06,ADT_A07,ADT_A08,ADT_A09,ADT_A10,ADT_A11,ADT_A12,ADT_A13,ADT_A14,ADT_A38"></constraint>
<when condition="1">
<send transform="GC.Cerner2PyxisADT" target="HL7.O.PyxisAdtRde"></send>
<return></return>
</when>
</rule>
<rule name="Filtering out item update MFN" disabled="false">
<constraint name="docCategory" value="231.CernerPyxis"></constraint>
<constraint name="docName" value="MFN"></constraint>
<when condition="(Document.{MFEgrp(1).MFE:1}=&quot;MUP&quot;)">
<send transform="" target="File.O.ArchiveStopped"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="docCategory" value="231.CernerPyxis"></constraint>
<constraint name="docName" value="MFN"></constraint>
<when condition="1">
<send transform="" target="HL7.O.PyxisAdtRde"></send>
<return></return>
</when>
</rule>
<rule name="ZPM Unload going to Cerner from Pyxis" disabled="true">
<constraint name="docCategory" value="23.Pyxis"></constraint>
<constraint name="docName" value="ZPM"></constraint>
<when condition="(HL7.{MSH.MessageType}=&quot;ZPM&quot;)&amp;&amp;(HL7.{ZPM.PocketCode}=&quot;U&quot;)">
<send transform="GC.PyxisZPMUnload2Cerner" target="HL7.O.CrPyxisDftZpm"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="docCategory" value="23.Pyxis"></constraint>
<when condition="1">
<send transform="" target="HL7.O.CrPyxisDftZpm"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
