/// 
Class GC.NatusBoRule Extends Ens.Rule.Definition [ ProcedureBlock ]
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ORM_O01"></constraint>
<when condition="HL7.{ORCgrp(1).ORC:1}=&quot;CM&quot;">
<return></return>
</when>
</rule>
<rule name="block discontinues - allow if discharged or SLEEP" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ORM_O01"></constraint>
<when condition="(HL7.{ORCgrp(1).ORC:1}=&quot;DC&quot;)&amp;&amp;(HL7.{PV1:45} = &quot;&quot;)&amp;&amp;(HL7.{ORCgrp(1).OBRgrp.OBR:4.1} != &quot;SLEEP&quot;)">
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ORU_R01"></constraint>
<when condition="Exists(&quot;T_CernerProd_TestPatients&quot;,HL7.{PID:PatientIdentifierList(1).ID})">
<send transform="GC.Natus2CernerBase64" target="HL7.O.CrNatusOru"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ORM_O01"></constraint>
<when condition="1">
<send transform="" target="HL7.O.NatusOrm"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="true">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ORU_R01"></constraint>
<when condition="(HL7.{ORCgrp(1).OBR:4.1} = &quot;VEEG&quot;)&amp;&amp;(HL7.{PV1:2} = &quot;O&quot;)">
<send transform="GC.Natus2CernerBase64" target="HL7.O.CrNatusOru"></send>
<return></return>
</when>
</rule>
<rule name="Block Specific Reports" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ORU_R01"></constraint>
<when condition="(HL7.{ORCgrp(1).OBXgrp(1).OBX:3.1} = &quot;MD Consecutive Day&quot;)||(HL7.{ORCgrp(1).OBXgrp(1).OBX:3.1} = &quot;MD Day 1 w Baseline&quot;)||(HL7.{ORCgrp(1).OBXgrp(1).OBX:3.1} = &quot;MD Final Day&quot;)||(HL7.{ORCgrp(1).OBXgrp(1).OBX:3.1} = &quot;MD NL EEG Report&quot;)">
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ORU_R01"></constraint>
<when condition="(HL7.{ORCgrp(1).OBR:4.1} = &quot;EEG&quot;)||(HL7.{ORCgrp(1).OBR:4.1} = &quot;EEGWS&quot;)||(HL7.{ORCgrp(1).OBR:4.1} = &quot;NUCEEG&quot;)||(HL7.{ORCgrp(1).OBR:4.1} = &quot;SLEEP&quot;)||(HL7.{ORCgrp(1).OBR:4.1} = &quot;VEEG&quot;)">
<send transform="GC.Natus2CernerBase64" target="HL7.O.CrNatusOru"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
