/// 
Class GC.RgnsLabBoRuleBeaker Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Sunquest Order Starts Alpha" disabled="true">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ORM_O01"></constraint>
<when condition="(HL7.{ORCgrp(1).OBRgrp.OBR:20}!=&quot;&quot;)&amp;&amp;(Substring(HL7.{ORCgrp(1).OBRgrp.OBR:20},1,1) In &quot;A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z&quot;)">
<return></return>
</when>
</rule>
<rule name="warning orm on pre reg" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ORM_O01"></constraint>
<when condition="(Document.{PV1:PatientType} StartsWith &quot;Pre&quot;)">
<send transform="" target="Email.O.AlertEmailRegLab"></send>
</when>
</rule>
<rule name="PreReg from Cerner Only Allow A05" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A01,ADT_A02,ADT_A03,ADT_A04,ADT_A06,ADT_A07,ADT_A08,ADT_A09,ADT_A10,ADT_A11,ADT_A12,ADT_A13,ADT_A14,ADT_A15,ADT_A16,ADT_A17,ADT_A21,ADT_A22,ADT_A23,ADT_A24,ADT_A25,ADT_A26,ADT_A28,ADT_A29,ADT_A31,ADT_A34,ADT_A38,ADT_A35,ADT_A44,ADT_ADSC"></constraint>
<when condition="(Document.{PV1:PatientType} StartsWith &quot;Pre&quot;)">
<return></return>
</when>
</rule>
<rule name="Only Allow Specific A05 " disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A05"></constraint>
<when condition="(Document.{PV1:PatientType} != (&quot;PreInpatient&quot;))&amp;&amp;(Document.{PV1:PatientType} != (&quot;PreDaySurgery&quot;))&amp;&amp;(Document.{PV1:PatientType} != (&quot;PreOutpatientinabed&quot;))&amp;&amp;(Document.{PV1:PatientType} != (&quot;PreOvernight Outpatient&quot;))">
<return></return>
</when>
</rule>
<rule name="ADTs from Cerner" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A01,ADT_A02,ADT_A03,ADT_A04,ADT_A05,ADT_A06,ADT_A07,ADT_A08,ADT_A09,ADT_A10,ADT_A11,ADT_A12,ADT_A13,ADT_A14,ADT_A15,ADT_A16,ADT_A17,ADT_A21,ADT_A22,ADT_A23,ADT_A24,ADT_A25,ADT_A26,ADT_A28,ADT_A29,ADT_A31,ADT_ADSC,ADT_A44,ADT_A38,ADT_A35,ADT_A34"></constraint>
<when condition="(Document.{PV1:3.4} In &quot;BRN,GCH,GCSH,LTC,MKO,MGC,MTK,PGC,STP&quot;)">
<send transform="GC.Cerner2RegLabBkrADT" target="RgnsLab.P.boBeakerAdt"></send>
<return></return>
</when>
</rule>
<rule name="Cerner Cancel Originated From Regions" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ORM_O01"></constraint>
<when condition="(HL7.{ORCgrp(1).ORC:1}=&quot;CA&quot;)&amp;&amp;(HL7.{ORCgrp(1).ORC:18.1}=&quot;ESI Default&quot;)">
<send transform="" target="File.O.ArchiveStopped"></send>
<return></return>
</when>
</rule>
<rule name="SN from Beaker table data" disabled="false">
<constraint name="docCategory" value="251.Regions"></constraint>
<constraint name="docName" value="ORM_O01"></constraint>
<when condition="HL7.{ORCgrp(1).ORC:1}=&quot;SN&quot;">
<send transform="GC.RegLab2CernerBkrORMLIOsn" target="HL7.O.CrRgnsLabBeakerOru"></send>
<return></return>
</when>
</rule>
<rule name="NA from Cerner" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ORM_O01"></constraint>
<when condition="HL7.{ORCgrp(1).ORC:1}=&quot;NA&quot;">
<send transform="GC.RegLab2CernerBkrORMLIOna,GC.Cerner2RegLabBkrORMgenlab" target="HL7.O.RgnsLabAdtOrmBeaker"></send>
<return></return>
</when>
</rule>
<rule name="SC Inprocess for LIO" disabled="false">
<constraint name="docCategory" value="251.Regions"></constraint>
<constraint name="docName" value="ORM_O01"></constraint>
<when condition="((HL7.{ORCgrp(1).ORC:1}=&quot;SC&quot;)&amp;&amp;(HL7.{ORCgrp(1).OBRuniongrp.OBRunion.OBR:2.1}=HL7.{ORCgrp(1).OBRuniongrp.OBRunion.OBR:3.1}))">
<send transform="" target="RgnsLab.P.boBeakerHang"></send>
<return></return>
</when>
</rule>
<rule name="ORM status from Regions" disabled="false">
<constraint name="docCategory" value="251.Regions"></constraint>
<constraint name="docName" value="ORM_O01"></constraint>
<when condition="1">
<send transform="GC.RegLab2CernerBkrORM" target="HL7.O.CrRgnsLabBeakerOru"></send>
<return></return>
</when>
</rule>
<rule name="Pathology ORM TO Regions" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ORM_O01"></constraint>
<when condition="HL7.{ORCgrp(1).OBRgrp.OBR:24}=&quot;AP&quot;">
<send transform="GC.Cerner2RegLabBkrORMpath" target="HL7.O.RgnsLabAdtOrmBeaker"></send>
<return></return>
</when>
</rule>
<rule name="Micro ORM TO Regions" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ORM_O01"></constraint>
<when condition="HL7.{ORCgrp(1).OBRgrp.OBR:24}=&quot;Micro&quot;">
<send transform="GC.Cerner2RegLabBkrORMmicro" target="HL7.O.RgnsLabAdtOrmBeaker"></send>
<return></return>
</when>
</rule>
<rule name="GenLab ORM TO Regions" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ORM_O01"></constraint>
<when condition="1">
<send transform="GC.Cerner2RegLabBkrORMgenlab" target="HL7.O.RgnsLabAdtOrmBeaker"></send>
</when>
</rule>
<rule name="Panel Result From Regions - OBR 50.1 value" disabled="true">
<constraint name="docCategory" value="251.Regions"></constraint>
<constraint name="docName" value="ORU_R01"></constraint>
<when condition="HL7.{PIDgrpgrp(1).ORCgrp(1).OBR:50.1}!=&quot;&quot;">
<send transform="GC.RegLab2CernerBkrORUPanel" target="HL7.O.CrRgnsLabBeakerOru"></send>
</when>
</rule>
<rule name="RegLab ORU Cancel change to ORM Cancel" disabled="true">
<constraint name="docCategory" value="251.Regions"></constraint>
<constraint name="docName" value="ORU_R01"></constraint>
<when condition="HL7.{PIDgrpgrp(1).ORCgrp(1).OBR:25}=&quot;X&quot;">
<send transform="GC.RegLab2CernerBkrORUCancel" target="HL7.O.CrRgnsLabBeakerOru"></send>
<return></return>
</when>
</rule>
<rule name="micro 2.5.1" disabled="false">
<constraint name="docCategory" value="251.Regions"></constraint>
<constraint name="docName" value="ORU_R01"></constraint>
<when condition="(Contains(HL7.{PIDgrpgrp(1).ORCgrp(1).OBR:24},&quot;MB&quot;))">
<send transform="GC.RegLab2CernerBkrORUmb" target="HL7.O.CrRgnsLabBeakerOru"></send>
<return></return>
</when>
</rule>
<rule name="copath result 2.5.1" disabled="false">
<constraint name="docCategory" value="251.Regions"></constraint>
<constraint name="docName" value="ORU_R01"></constraint>
<when condition="(Contains(HL7.{PIDgrpgrp(1).ORCgrp(1).OBR:24},&quot;COPATH&quot;))">
<send transform="GC.RegLab2CernerBkrORUCoPath" target="HL7.O.CrRgnsLabBeakerOru"></send>
<return></return>
</when>
</rule>
<rule name="SendOut" disabled="false">
<constraint name="docCategory" value="251.Regions"></constraint>
<constraint name="docName" value="ORU_R01"></constraint>
<when condition="(Contains(HL7.{PIDgrpgrp(1).ORCgrp(1).OBR:24},&quot;SO&quot;))">
<send transform="GC.RegLab2CernerBkrORUSendOut" target="HL7.O.CrRgnsLabBeakerOru"></send>
<return></return>
</when>
</rule>
<rule name="Specific Tests thru SendOut Logic 2.5.1" disabled="false">
<constraint name="docCategory" value="251.Regions"></constraint>
<constraint name="docName" value="ORU_R01"></constraint>
<when condition="HL7.{PIDgrpgrp(1).ORCgrp(1).OBR:4.1} In &quot;QFT4&quot;">
<send transform="GC.RegLab2CernerBkrORUQFT4" target="HL7.O.CrRgnsLabBeakerOru"></send>
<return></return>
</when>
</rule>
<rule name="GenLab 2.5.1" disabled="false">
<constraint name="docCategory" value="251.Regions"></constraint>
<constraint name="docName" value="ORU_R01"></constraint>
<when condition="1">
<send transform="GC.RegLab2CernerBkrORUGenlab" target="HL7.O.CrRgnsLabBeakerOru"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
