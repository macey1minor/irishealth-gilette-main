/// 
Class GC.RsnaBoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="CERT.CERT">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
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
<rule name="Orm Oru" disabled="false">
<constraint name="source" value="HL7.S.CrRsnaOrmOru"></constraint>
<when condition="1">
<send transform="" target="HL7.O.RsnaAdtOrmOru"></send>
<return></return>
</when>
</rule>
<rule name="ADT A18 ORM ORU from CrRsna" disabled="false">
<constraint name="source" value="HL7.S.CrRsnaOrmOru"></constraint>
<constraint name="docCategory" value="23.RSNA"></constraint>
<constraint name="docName" value="ADT_A18,ORM_O01,ORU_R01"></constraint>
<when condition="1">
<send transform="" target="HL7.O.RsnaAdtOrmOru"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
