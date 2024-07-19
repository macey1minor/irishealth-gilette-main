/// 
Class GC.eDocsScanBsoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.MsgRouter.VDocRoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Resend for reports that Libby aliased" disabled="true">
<constraint name="source" value="Bso.P.eDocsScan"></constraint>
<when condition="1">
<send transform="GC.eDocsScan.EDocs2OruUrlToProdBpResend" target="HL7.O.CrEdocsScanORU"></send>
<return></return>
</when>
</rule>
<rule name="Resent to fix incorrect URL" disabled="true">
<constraint name="source" value="Bso.P.eDocsScan"></constraint>
<when condition="1">
<send transform="GC.eDocsScan.EDocs2OruUrlCorrectionBp" target="HL7.O.CrEdocsScanORU"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="source" value="SQL.S.eDocsScans"></constraint>
</rule>
<send transform="GC.eDocsScan.EDocs2ORU" target="HL7.O.CrEdocsScanORU,File.O.ArchiveEdocsScan"></send>
<return></return>
</ruleSet>
</ruleDefinition>
}

}
