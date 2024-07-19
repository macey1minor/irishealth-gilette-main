/// 
Class GC.MuseBsoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Filter out A34 wo mrg segment" disabled="false">
<constraint name="source" value="Bs.P.Muse"></constraint>
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A34"></constraint>
<when condition="DoesNotContain(HL7.{MRG})">
<return></return>
</when>
</rule>
<rule name="blocking test patient msgs" disabled="false">
<constraint name="source" value="Bs.P.Muse"></constraint>
<when condition="(HL7.{PID:PatientIdentifierList(1).ID} In &quot;507424,515173,600000,600001&quot;)">
<return></return>
</when>
</rule>
<rule name="Archive">
<when condition="1">
<send transform="" target="File.O.ArchiveInbound"></send>
</when>
</rule>
<rule name="Adt and Orm" disabled="false">
<constraint name="source" value="Bs.P.Muse"></constraint>
<when condition="1">
<send transform="" target="HL7.O.MuseAdtOrm"></send>
<return></return>
</when>
</rule>
<rule name="ORU on Old Qcpr Orders" disabled="false">
<constraint name="source" value="HL7.S.MuseOru"></constraint>
<when condition="LENGTH(HL7.{OBR(1):2(1).1})=7">
<send transform="GC.Muse2CernerORU" target="HL7.O.CrMuseOru"></send>
<return></return>
</when>
</rule>
<rule name="ORU on Cerner Orders" disabled="false">
<constraint name="source" value="HL7.S.MuseOru"></constraint>
<when condition="1">
<send transform="" target="HL7.O.CrMuseOru"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
