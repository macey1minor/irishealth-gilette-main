/// 
Class GC.PacsBsoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="" disabled="false">
<constraint name="source" value="HL7.S.CrPacsAdtOrmOru"></constraint>
<when condition="(HL7.{PID:PatientIdentifierList(1).ID} In &quot;507424,515173,600001&quot;)">
<return></return>
</when>
</rule>
<rule name="Archive">
<when condition="1">
<send transform="" target="File.O.ArchiveInbound"></send>
</when>
</rule>
<rule name="Remove Merge Missing MRG Segment" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A34,ADT_A35,ADT_A44"></constraint>
<when condition="DoesNotContain(HL7.{MRG})">
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
<rule name="" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A34"></constraint>
<when condition="1">
<send transform="GC.Cerner2PacsA34toA40" target="HL7.O.PacsAdtOrmOru"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="source" value="HL7.S.CrPacsAdtOrmOru"></constraint>
<when condition="1">
<send transform="" target="HL7.O.PacsAdtOrmOru"></send>
</when>
</rule>
<rule name="ORU with URL" disabled="false">
<constraint name="source" value="HL7.S.PacsOru"></constraint>
<when condition="1">
<send transform="" target="HL7.O.CrPacsOru"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
