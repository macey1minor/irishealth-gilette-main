/// 
Class GC.GreatPlainsBsoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="CERT.CERT">
<ruleSet name="CernerMedDftForGreatPlain" effectiveBegin="" effectiveEnd="">
<rule name="">
<when condition="1">
<send transform="" target="File.O.ArchiveInbound"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="(HL7.{PID:PatientIdentifierList(1).ID}&gt;399999)&amp;&amp;(HL7.{PID:PatientIdentifierList(1).ID}&lt;600000)">
<send transform="" target="File.O.ArchiveStopped"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<when condition="1">
<send transform="GC.Cerner2GreatPlainsDFT,GC.Cerner2GreatPlainsSqlDFT" target="SQL.O.GreatPlainsDFT"></send>
<return></return>
</when>
</rule>
<rule name="OLD" disabled="true">
<constraint name="docCategory" value="23.QCPR"></constraint>
<when condition="HL7.{ZFT}!=&quot;&quot;">
<send transform="GCH.Qcpr2GreatPlainsDFT,GCH.Qcpr2GreatPlainsSqlDFT" target="GreatPlains.O.QCPR"></send>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
