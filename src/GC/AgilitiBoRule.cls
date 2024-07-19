/// 
Class GC.AgilitiBoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="CernerAdtsforAgiliti" effectiveBegin="" effectiveEnd="">
<rule name="Cerner Adt to Agiliti" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="1">
<send transform="GC.Cerner2AgilitiADT" target="SFTP.O.AgilitiAdt"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
