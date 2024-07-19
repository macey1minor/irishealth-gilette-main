/// Use orm to get patient informaton for Xltek sleep study. Format as XML
Class GC.XltekBsoRule Extends Ens.Rule.Definition [ ProcedureBlock ]
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssistCompatible";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Stop &amp; Archive Orders w/CM or XO" disabled="false">
<constraint name="source" value="HL7.S.CrXltekOrm"></constraint>
<when condition="(HL7.{ORCgrp(1).ORC:OrderControl}=&quot;CM&quot;)||(HL7.{ORCgrp(1).ORC:OrderControl}=&quot;XO&quot;)">
<send transform="" target="File.O.ArchiveStopped"></send>
<return></return>
</when>
</rule>
<rule name="Archive" disabled="false">
<constraint name="msgClass" value="EnsLib.HL7.Message"></constraint>
<when condition="1">
<send transform="" target="File.O.ArchiveInbound"></send>
</when>
</rule>
<rule name="ORM and Cancel to A03" disabled="false">
<constraint name="source" value="HL7.S.CrXltekOrm"></constraint>
<constraint name="msgClass" value="EnsLib.HL7.Message"></constraint>
<when condition="1">
<send transform="GC.Cerner2XltekORM" target="File.O.XltekAdtOrm"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
