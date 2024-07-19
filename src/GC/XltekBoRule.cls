/// Use orm to get patient informaton for Xltek sleep study. Format as XML
Class GC.XltekBoRule Extends Ens.Rule.Definition [ ProcedureBlock ]
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssistCompatible";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="ORM and Cancel to A03" disabled="false">
<constraint name="msgClass" value="EnsLib.HL7.Message"></constraint>
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="1">
<send transform="GC.Cerner2XltekORM" target="File.O.XltekAdtOrm"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
