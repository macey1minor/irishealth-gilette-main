/// 
Class GC.RgnsChargesBsRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="CDM from Reglab-Update Prod Cerner Table- Stop Send CDM to Affinity" disabled="false">
<constraint name="docCategory" value="22.RegLab"></constraint>
<constraint name="docName" value="GLT_CDM"></constraint>
<when condition="1">
<send transform="GC.Regions.RegionsCDMDeptLoadTBL" target="File.O.ArchiveInbound"></send>
<return></return>
</when>
</rule>
<rule name="Archive">
<when condition="1">
<send transform="" target="File.O.ArchiveInbound"></send>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="docCategory" value="22.RegLab"></constraint>
<constraint name="docName" value="GLT_DFT"></constraint>
<when condition="SubString(HL7.{ZDF:8},1,3) IN &quot;PAY,ADJ,CRE&quot;">
<send transform="" target="File.O.ArchiveStopped"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="docCategory" value="22.RegLab"></constraint>
<constraint name="docName" value="GLT_DFT"></constraint>
<when condition="1">
<send transform="" target="RgnsCharges.P.bo"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
