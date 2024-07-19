Class PRODPKG.FoundationProduction Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="PRODPKG.FoundationProduction" TestingEnabled="true" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="Email.O.AlertEmailMonitorIIBA" Category="alert,iiba" ClassName="IIBAENSEMBLE.Bop.SendEmail" PoolSize="1" Enabled="true" Foreground="false" Comment="Send emails using IIBA email msg class" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="ReplyCodeActions">E=D</Setting>
    <Setting Target="Adapter" Name="From">PRODiiba@gillettechildrens.com</Setting>
    <Setting Target="Adapter" Name="SMTPPort">25</Setting>
    <Setting Target="Adapter" Name="SMTPServer">smtprelay.gillette.int</Setting>
  </Item>
  <Item Name="File.S.IIBAAlertMonitor" Category="alert,iiba" ClassName="IIBAENSEMBLE.Monitor.AlertNotification" PoolSize="1" Enabled="true" Foreground="false" Comment="Monitors production for troubled items" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TargetConfigNames">Email.O.AlertEmailMonitorIIBA</Setting>
  </Item>
  <Item Name="BadMessageHandler" Category="" ClassName="EnsLib.HL7.Operation.FileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="Bad messages to  bad folder on arbitor" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="Filename">badmsg_%f_%Q%!+(_a).txt</Setting>
    <Setting Target="Adapter" Name="FilePath">\\HSCARB01\Ops\Dir_Prod\bad</Setting>
  </Item>
  <Item Name="Email.O.AlertEmailEnsemble" Category="alert" ClassName="GC.Utils.CustomEmailAlert" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="ReplyCodeActions">E=D</Setting>
    <Setting Target="Host" Name="SearchKeywords">Procedure Code|No Connection|timeout|study group|Exam is in a status|deadlock|BOOKING NUMBER DOES NOT EXIST|NOWAIT|</Setting>
    <Setting Target="Adapter" Name="From">PRODcustomAlert@gillettechildrens.com</Setting>
    <Setting Target="Adapter" Name="Recipient">minterface@gillettechildrens.com</Setting>
    <Setting Target="Adapter" Name="SMTPPort">25</Setting>
    <Setting Target="Adapter" Name="SMTPServer">smtprelay.gillette.int</Setting>
  </Item>
  <Item Name="File.O.ArchiveInbound" Category="" ClassName="EnsLib.HL7.Operation.FileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="Archive inbound messages" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="Filename">%f_%q(2)_%H.txt</Setting>
    <Setting Target="Adapter" Name="FilePath">\\HSCARB01\Ops\Dir_Prod\archive\0inbound</Setting>
  </Item>
  <Item Name="File.O.ArchiveProcessed" Category="Archive" ClassName="EnsLib.HL7.Operation.FileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="Archive inbound messages" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="Filename">%f_%q(2)_%H.txt</Setting>
    <Setting Target="Adapter" Name="FilePath">\\HSCARB01\Ops\Dir_Prod\archive\processed</Setting>
  </Item>
  <Item Name="File.O.ArchiveStopped" Category="Archive" ClassName="EnsLib.HL7.Operation.FileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="Archive stopped messages" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="Filename">%f_%q(2)_%H.txt</Setting>
    <Setting Target="Adapter" Name="FilePath">\\HSCARB01\Ops\Dir_Prod\archive\stopped</Setting>
  </Item>
  <Item Name="Ens.Alert" Category="alert" ClassName="EnsLib.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="This handles Alert routing logic." LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.AlertRule</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="Bo.P.AlertsCustom" Category="alert" ClassName="EnsLib.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="Filter for custom alerts" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.AlertCustomRule</Setting>
  </Item>
  <Item Name="HL7.O.AcuityAdt" Category="Acuity,Cerner" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="new ip = hhacupr01 10845 old = qmacupr01 9108" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="IPAddress">hhacupr01</Setting>
    <Setting Target="Adapter" Name="Port">10852</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="AlertRetryGracePeriod">120</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">:?R=S,:?E=S,:~=S,:I?=W,:T?=C</Setting>
    <Setting Target="Adapter" Name="ConnectTimeout">30</Setting>
    <Setting Target="Adapter" Name="ReadTimeout">120</Setting>
    <Setting Target="Adapter" Name="ReconnectRetry">0</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Adapter" Name="ResponseTimeout">119</Setting>
  </Item>
  <Item Name="HL7.S.CrAcuityADT" Category="Acuity,Cerner" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="Cerner ADT to Acuity ADT" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Acuity.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10820</Setting>
  </Item>
  <Item Name="HL7.S.CrMultiAdt" Category="edocSql,edocs,sql" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="All Cerner raw ADT go to here" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Cerner.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10800</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
  </Item>
  <Item Name="HL7.S.CrMultiSiu" Category="SIU for any Downstream" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="RT_SIU_Multi_OUT" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Cerner.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10817</Setting>
  </Item>
  <Item Name="HL7.O.NuanceEscriptionSIU" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="Cerner SIU to Nuance eScription" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="IPAddress">NUEXSHADOW01</Setting>
    <Setting Target="Adapter" Name="Port">10605</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">:?R=S,:?E=S,:~=S,:I?=W,:T?=C</Setting>
  </Item>
  <Item Name="HL7.S.CrNuanceEscriptionAdtSiu" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="Cerner ADT &amp; SIU to Nuance eScription" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">NuanceEscription.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10805</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
  </Item>
  <Item Name="HL7.O.NuanceEscriptionADT" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="Cerner ADT to Nuance eScription" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="IPAddress">NUEXSHADOW01</Setting>
    <Setting Target="Adapter" Name="Port">10604</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">:?R=S,:?E=S,:~=S,:I?=W,:T?=C</Setting>
  </Item>
  <Item Name="HL7.O.CrNuanceEscriptionMdm" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="RT_MDM_DICT_IN / RT_DICT_ESI_1" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="IPAddress">104.170.172.151</Setting>
    <Setting Target="Adapter" Name="Port">10708</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
  </Item>
  <Item Name="HL7.S.NuanceEscriptionMdm" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="MDM from Nuance to Cerner" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">22.Dictaphone</Setting>
    <Setting Target="Host" Name="TargetConfigNames">NuanceEscription.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10606</Setting>
    <Setting Target="Host" Name="AlertGracePeriod">60</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="BatchHandling">Indiv</Setting>
    <Setting Target="Adapter" Name="QSize">100</Setting>
    <Setting Target="Adapter" Name="ReadTimeout">30</Setting>
  </Item>
  <Item Name="HL7.O.RelayHealthAdt" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="ADT from Cerner to RelayHealth" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="IPAddress">170.138.163.132</Setting>
    <Setting Target="Adapter" Name="Port">11088</Setting>
  </Item>
  <Item Name="HL7.S.CrRelayHealthAdt" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="Cerner ADT to Relay Health" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">RelayHealth.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10815</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
  </Item>
  <Item Name="HL7.O.MuseAdtOrm" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="Cerner Orders &amp; ADT to GE Muse" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="IPAddress">MUSEINTPR01</Setting>
    <Setting Target="Adapter" Name="Port">9210</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="AlertRetryGracePeriod">120</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">:?R=F,:?E=S,:~=S,:?A=C,:*=S,:I?=W,:T?=C</Setting>
    <Setting Target="Adapter" Name="ConnectTimeout">15</Setting>
    <Setting Target="Adapter" Name="ReconnectRetry">15</Setting>
  </Item>
  <Item Name="HL7.S.CrMuseAdtOrm" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="Cerner ADT &amp; ORM to Ge Muse" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Muse.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10804</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
  </Item>
  <Item Name="HL7.S.MuseOru" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="ORU from GE Muse to Cerner" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">24.GE</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Muse.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">9212</Setting>
    <Setting Target="Host" Name="AlertGracePeriod">60</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="BatchHandling">Indiv</Setting>
    <Setting Target="Adapter" Name="QSize">100</Setting>
    <Setting Target="Adapter" Name="ReadTimeout">30</Setting>
  </Item>
  <Item Name="HL7.O.RgnsDietAdtOrm" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="Cerner ADT &amp; ORM to Regions Diet" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="IPAddress">10.200.10.66</Setting>
    <Setting Target="Adapter" Name="Port">9292</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">:?R=F,:?E=S,:~=S,:?A=C,:*=S,:I?=W,:T?=C</Setting>
    <Setting Target="Adapter" Name="ReadTimeout">30</Setting>
    <Setting Target="Host" Name="AlertRetryGracePeriod">120</Setting>
    <Setting Target="Adapter" Name="ConnectTimeout">30</Setting>
  </Item>
  <Item Name="HL7.S.CrRgnsDietAdtOrm" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="Cerner ADT &amp; ORM to Regions Diet" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">RgnsDiet.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10803</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
  </Item>
  <Item Name="HL7.O.CrMuseOru" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="GE Muse ORU to Cerner" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="IPAddress">104.170.172.151</Setting>
    <Setting Target="Adapter" Name="Port">10706</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="AlertRetryGracePeriod">120</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">:?R=S,:?E=S,:~=S,:I?=W,:T?=C</Setting>
    <Setting Target="Host" Name="RetryInterval">30</Setting>
    <Setting Target="Adapter" Name="ConnectTimeout">3</Setting>
    <Setting Target="Adapter" Name="ReadTimeout">120</Setting>
    <Setting Target="Adapter" Name="ReconnectRetry">0</Setting>
    <Setting Target="Adapter" Name="ResponseTimeout">120</Setting>
  </Item>
  <Item Name="HL7.O.ImageStreamAdt" Category="imagestream" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="9201" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="AlertRetryGracePeriod">600</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">:?R=S,:?E=S,:~=S,:I?=W,:T?=C</Setting>
    <Setting Target="Adapter" Name="IPAddress">172.25.43.212</Setting>
    <Setting Target="Adapter" Name="ReadTimeout">30</Setting>
    <Setting Target="Adapter" Name="StayConnected">600</Setting>
    <Setting Target="Adapter" Name="Port">9201</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
  </Item>
  <Item Name="HL7.O.CrEdocsScanORU" Category="edocsScan,ellen" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="10730  RT_ORU_EDOCSSCAN_IN" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Port">10730</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">:?R=S,:?E=S,:~=S,:I?=W,:T?=C</Setting>
    <Setting Target="Adapter" Name="IPAddress">104.170.172.150</Setting>
  </Item>
  <Item Name="SQL.S.eDocsScans" Category="ellen,edocsScan" ClassName="GC.eDocsScan.BSeDOCS" PoolSize="1" Enabled="true" Foreground="false" Comment="Manually scan edocs sent to Cerner as URL" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="TargetConfigName">eDocsScan.P.bs</Setting>
    <Setting Target="Adapter" Name="CallInterval">600</Setting>
    <Setting Target="Adapter" Name="DSN">eDocsScan_Prod2019</Setting>
    <Setting Target="Adapter" Name="Query">exec HL7.EdocsScan_To_Cerner</Setting>
    <Setting Target="Adapter" Name="Credentials">EnsembleSQL</Setting>
    <Setting Target="Adapter" Name="KeyFieldName"></Setting>
  </Item>
  <Item Name="HL7.O.CrPacsOru" Category="radiology" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="10704 RT_ORU_CARESTREAM_IN" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">:?R=S,:?E=S,:~=S,:I?=W,:T?=C</Setting>
    <Setting Target="Adapter" Name="ConnectTimeout">60</Setting>
    <Setting Target="Adapter" Name="Port">10704</Setting>
    <Setting Target="Adapter" Name="IPAddress">104.170.172.151</Setting>
  </Item>
  <Item Name="HL7.O.PacsAdtOrmOru" Category="radiology" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="This sends to a Broker, the Broker then sends to PACS" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">:?R=S,:?E=S,:~=S,:I?=W,:T?=C</Setting>
    <Setting Target="Adapter" Name="IPAddress">172.25.68.43</Setting>
    <Setting Target="Adapter" Name="Port">8600</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
  </Item>
  <Item Name="HL7.S.CrPacsAdtOrmOru" Category="radiology" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="10802 RT_ADTORMORU_CRSTREAM_OUT" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Pacs.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10802</Setting>
  </Item>
  <Item Name="HL7.S.PacsOru" Category="radiology" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="8602" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="AlertGracePeriod">120</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">231.Carestream</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Pacs.P.bs</Setting>
    <Setting Target="Adapter" Name="StayConnected">60</Setting>
    <Setting Target="Adapter" Name="Port">8602</Setting>
  </Item>
  <Item Name="HL7.O.CrPs360RadiologyOru" Category="radiology" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="10729 - RT_MDM_PSCRIBE_IN - Nuance product" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="AlertRetryGracePeriod">5</Setting>
    <Setting Target="Host" Name="QueueCountAlert">5</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">:?R=F,:?E=S,:~=S,:?A=C,:*=S,:I?=W,:T?=C</Setting>
    <Setting Target="Adapter" Name="ConnectTimeout">30</Setting>
    <Setting Target="Adapter" Name="Port">10729</Setting>
    <Setting Target="Adapter" Name="IPAddress">104.170.172.151</Setting>
  </Item>
  <Item Name="HL7.O.Ps360RadiologyOrmAdt" Category="radiology" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="10728 or try 10731" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="QueueCountAlert">15</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">:?R=F,:?E=S,:~=S,:?A=C,:*=S,:I?=W,:T?=C</Setting>
    <Setting Target="Adapter" Name="IPAddress">172.25.68.206</Setting>
    <Setting Target="Adapter" Name="Port">10728</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="Framing">MLLP*</Setting>
    <Setting Target="Host" Name="AlertRetryGracePeriod">120</Setting>
  </Item>
  <Item Name="HL7.S.CrPs360RadiologyOrmAdt" Category="radiology" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="10825  RT_ADTORM_PSCRIBE_OUT" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="AlertGracePeriod">60</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="Framing">MLLP</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">PS360Radiology.P.bs</Setting>
    <Setting Target="Adapter" Name="QSize">1</Setting>
    <Setting Target="Adapter" Name="Port">10825</Setting>
  </Item>
  <Item Name="HL7.S.Ps360RadiologyOru" Category="radiology" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="10826" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="AlertGracePeriod">60</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">PS360Radiology.P.bs</Setting>
    <Setting Target="Adapter" Name="QSize">100</Setting>
    <Setting Target="Adapter" Name="ReadTimeout">30</Setting>
    <Setting Target="Adapter" Name="Port">10826</Setting>
    <Setting Target="Host" Name="BatchHandling">Indiv</Setting>
  </Item>
  <Item Name="HL7.O.SprOrmOru" Category="radiology" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="10726" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">:?R=S,:?E=S,:~=S,:I?=W,:T?=C</Setting>
    <Setting Target="Adapter" Name="Port">10726</Setting>
    <Setting Target="Adapter" Name="IPAddress">63.226.160.111</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
  </Item>
  <Item Name="HL7.O.CrSprOru" Category="radiology" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="10705 - RT_ORU_SPR_IN" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="ReplyCodeActions"></Setting>
    <Setting Target="Adapter" Name="IPAddress">104.170.172.151</Setting>
    <Setting Target="Adapter" Name="Port">10705</Setting>
  </Item>
  <Item Name="HL7.S.SprOru" Category="radiology" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="10821" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="AlertGracePeriod">60</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Spr.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10821</Setting>
  </Item>
  <Item Name="HL7.S.CrSprOrmOru" Category="radiology" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="ORU for Zotec billing - 10809 - RT_ORMORU_SPR_OUT" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Spr.P.bs</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Adapter" Name="Port">10809</Setting>
  </Item>
  <Item Name="HL7.S.CrEdocsRadOru" Category="edocs,ellen,radiology" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="10713 RT_ORU_RADEDOCS_OUT  " LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">eDocsRad.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10713</Setting>
  </Item>
  <Item Name="File.O.eDOCSRad" Category="radiology,edocs,ellen" ClassName="GC.eDOCS.RadCreateTagDocBO" PoolSize="1" Enabled="true" Foreground="false" Comment="Radiology results with Multi OBX" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="ArchiveFilePath">\\HSCARB01\Ops\Dir_Prod\archive\eDOCS\</Setting>
    <Setting Target="Host" Name="TemplateFilePath">\\HSCARB01\Ops\Dir_Prod\Resources\eDOCS\IMG_eDOCS_V2015.template</Setting>
    <Setting Target="Host" Name="TargetFilePath">\\faplocal\local\eDocsImporter\CernerPowerscribe\Incoming\</Setting>
    <Setting Target="Adapter" Name="FilePath">\\faplocal\local\eDocsImporter\CernerPowerscribe\Incoming\</Setting>
  </Item>
  <Item Name="HL7.O.CrPyxisDftZpm" Category="Cerner, Pyxis" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="DFT and ZPM from Pyxis to Cerner" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="IPAddress">104.170.172.151</Setting>
    <Setting Target="Adapter" Name="Port">10701</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
  </Item>
  <Item Name="HL7.S.CrPyxisAdtRde" Category="Cerner, Pyxis" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Pyxis.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10801</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
  </Item>
  <Item Name="HL7.O.PyxisAdtRde" Category="Pyxis" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="Cerner ADT, RDE to Pyxis" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="IPAddress">10.100.46.5</Setting>
    <Setting Target="Adapter" Name="Port">9724</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="AlertRetryGracePeriod">120</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">:?R=F,:?E=S,:~=S,:?A=C,:*=S,:I?=W,:T?=C</Setting>
    <Setting Target="Adapter" Name="GetReply">0</Setting>
  </Item>
  <Item Name="HL7.S.CrPyxisMfn" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="Cerner MFN to Pyxis" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">231.CernerPyxis</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Pyxis.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10818</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
  </Item>
  <Item Name="HL7.S.PyxisDftZpm" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="Pyxis DFT &amp; ZPM to Cerner" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">23.Pyxis</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Pyxis.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10819</Setting>
    <Setting Target="Host" Name="AlertGracePeriod">600</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="BatchHandling">Indiv</Setting>
    <Setting Target="Adapter" Name="QSize">100</Setting>
    <Setting Target="Adapter" Name="ReadTimeout">30</Setting>
    <Setting Target="Adapter" Name="StayConnected">60000</Setting>
  </Item>
  <Item Name="HL7.S.CrEdocsNuanceOru" Category="Nuance,edocs" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="RT_ORU_EDOC_OUT" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">eDocsNuance.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10822</Setting>
  </Item>
  <Item Name="X12.O.CrRelayHealth271" Category="Cerner,RelayHealth,X12" ClassName="EnsLib.EDI.X12.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="RH to Cerner" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Framing">MLLP</Setting>
    <Setting Target="Adapter" Name="IPAddress">104.170.172.151</Setting>
    <Setting Target="Adapter" Name="Port">10727</Setting>
    <Setting Target="Host" Name="Separators">*:^~</Setting>
  </Item>
  <Item Name="X12.O.RelayHealth270" Category="Cerner,RelayHealth" ClassName="EnsLib.EDI.X12.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="Cerner to RH " LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="Framing">MLLP</Setting>
    <Setting Target="Host" Name="Separators">*:^~</Setting>
    <Setting Target="Adapter" Name="GetReply">1</Setting>
    <Setting Target="Adapter" Name="IPAddress">170.138.163.129</Setting>
    <Setting Target="Adapter" Name="Port">11101</Setting>
  </Item>
  <Item Name="X12.S.CrRelayHealth270" Category="Cerner,RelayHealth" ClassName="EnsLib.EDI.X12.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="DocSchemaCategory">HIPAA_5010</Setting>
    <Setting Target="Host" Name="LocalApplicationID">@:ZZ</Setting>
    <Setting Target="Host" Name="TargetConfigNames">RelayHealthX12.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10823</Setting>
  </Item>
  <Item Name="X12.S.RelayHealth271" Category="Cerner,RelayHealth" ClassName="EnsLib.EDI.X12.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="BatchReplyType">TA1</Setting>
    <Setting Target="Host" Name="DocSchemaCategory">HIPAA_5010</Setting>
    <Setting Target="Host" Name="Framing">Flexible</Setting>
    <Setting Target="Host" Name="TargetConfigNames">RelayHealthX12.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10824</Setting>
  </Item>
  <Item Name="HL7.O.CarefusionPFTOrm" Category="Cerner,CareFusion" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Adapter" Name="IPAddress">VYPFTPR01</Setting>
    <Setting Target="Adapter" Name="Port">10725</Setting>
  </Item>
  <Item Name="HL7.O.CrCarefusionPFTOru" Category="Cerner,CareFusion" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="false" Foreground="false" Comment="RT_VMAXX_ORU_IN / RT_VMAXX_ESI_1" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Adapter" Name="IPAddress">104.170.172.151</Setting>
    <Setting Target="Adapter" Name="Port">10710</Setting>
  </Item>
  <Item Name="HL7.S.CarefusionPFTOru" Category="CareFusion,Cerner" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="false" Foreground="false" Comment="ORU From CareFusionPFT/VMAXX to Cerner" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">CarefusionPFT.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10814</Setting>
  </Item>
  <Item Name="HL7.S.CrCarefusionPFTOrm" Category="CareFusion,Cerner" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="false" Foreground="false" Comment="RT_VMAXX_ORM_OUT" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">CarefusionPFT.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10812</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
  </Item>
  <Item Name="HL7.O.CrRgnsLabDft" Category="RgnsLab,Cerner" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="RT_DFT_RGNSLAB_IN / RT_RGNSDFT_ESI_1" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Adapter" Name="IPAddress">104.170.172.151</Setting>
    <Setting Target="Adapter" Name="Port">10703</Setting>
  </Item>
  <Item Name="HL7.S.RgnsLabDft" Category="Cerner,RgnsLab" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="BatchHandling">Indiv</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">22.RegLab</Setting>
    <Setting Target="Host" Name="TargetConfigNames">RgnsCharges.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">9287</Setting>
    <Setting Target="Adapter" Name="QSize">100</Setting>
    <Setting Target="Adapter" Name="ReadTimeout">30</Setting>
    <Setting Target="Host" Name="AlertGracePeriod">6000</Setting>
  </Item>
  <Item Name="File.O.eDOCSNuance" Category="edocs,Nuance,Cerner" ClassName="GC.eDOCS.NuanceCreateTagDocBO" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="ArchiveFilePath">\\HSCARB01\Ops\Dir_Prod\archive\eDOCS\</Setting>
    <Setting Target="Host" Name="TargetFilePath">\\faplocal\local\eDocsImporter\CernerInscribe\Incoming\</Setting>
    <Setting Target="Adapter" Name="FilePath">**use TargetFilePath**</Setting>
  </Item>
  <Item Name="Email.O.AlertEmailRegCredit" Category="Cerner,RgnsLab" ClassName="GC.Utils.CustomEmailRegDftXML" PoolSize="1" Enabled="true" Foreground="false" Comment="credits on misc cdm code" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="CustomSubject">Regions Credit CDM 00011403</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">E=D</Setting>
    <Setting Target="Adapter" Name="Cc"></Setting>
    <Setting Target="Adapter" Name="From">CernerPRODalert@gillettechildrens.com</Setting>
    <Setting Target="Adapter" Name="Recipient">desireeweise@gillettechildrens.com,
SMcCoy@gillettechildrens.com,
sunshinejlarrazabal@gillettechildrens.com,
MargaretMIdell@gillettechildrens.com</Setting>
    <Setting Target="Adapter" Name="SMTPPort">25</Setting>
    <Setting Target="Adapter" Name="SMTPServer">smtprelay.gillette.int</Setting>
  </Item>
  <Item Name="File.O.ArchiveInboundX12" Category="X12,Cerner,RelayHealth" ClassName="EnsLib.EDI.X12.Operation.FileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="Filename">%f_%q(2)_%H.txt</Setting>
    <Setting Target="Host" Name="Framing">MLLP</Setting>
    <Setting Target="Host" Name="Separators">*:^~</Setting>
    <Setting Target="Adapter" Name="FilePath">\\HSCARB01\Ops\Dir_Prod\archive\0inbound\X12</Setting>
  </Item>
  <Item Name="Email.O.RegionsDFTReportAttachment" Category="" ClassName="GC.Utils.CustomEmailRegDfAttachment" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="CustomSubject">Regions Charges</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">E=D</Setting>
    <Setting Target="Adapter" Name="Cc">saidsheikh@gillettechildrens.com</Setting>
    <Setting Target="Adapter" Name="From">CernerPRODalert@gillettechildrens.com</Setting>
    <Setting Target="Adapter" Name="Recipient">desireeweise@gillettechildrens.com,
MargaretMIdell@gillettechildrens.com,
SMcCoy@gillettechildrens.com,
sunshinejlarrazabal@gillettechildrens.com</Setting>
    <Setting Target="Adapter" Name="SMTPPort">25</Setting>
    <Setting Target="Adapter" Name="SMTPServer">smtprelay.gillette.int</Setting>
  </Item>
  <Item Name="File.RegionsDFTReport" Category="" ClassName="EnsLib.File.PassthroughService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="@Daily7AM">
    <Setting Target="Host" Name="TargetConfigNames">Email.O.RegionsDFTReportAttachment</Setting>
    <Setting Target="Adapter" Name="ArchivePath">\\HSCARB01\Ops\Dir_Prod\archive\fileTransfers\</Setting>
    <Setting Target="Adapter" Name="ConfirmComplete">0</Setting>
    <Setting Target="Adapter" Name="FileAccessTimeout">10</Setting>
    <Setting Target="Adapter" Name="FilePath">\\HSCARB01\Ops\Dir_Prod\Regions\DFT\</Setting>
    <Setting Target="Adapter" Name="FileSpec">RegionsCharges*</Setting>
    <Setting Target="Adapter" Name="WorkPath">\\HSCARB01\Ops\Dir_Prod\Working\</Setting>
  </Item>
  <Item Name="zResend.S.AljOrueDOCS" Category="" ClassName="EnsLib.HL7.Service.FileService" PoolSize="1" Enabled="false" Foreground="false" Comment="resend file to Nuance eDocs" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames"></Setting>
    <Setting Target="Host" Name="UseAckCommitCodes">0</Setting>
    <Setting Target="Adapter" Name="FileAccessTimeout">10</Setting>
    <Setting Target="Adapter" Name="FilePath">\\HSCARB01\Ops\Dir_Prod\In\Al\Charge-Send\</Setting>
  </Item>
  <Item Name="zzResend.S.AljOru" Category="" ClassName="EnsLib.HL7.Service.FileService" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">251.Regions</Setting>
    <Setting Target="Host" Name="TargetConfigNames">HL7.O.CrRgnsLabBeakerOru</Setting>
    <Setting Target="Host" Name="UseAckCommitCodes">0</Setting>
    <Setting Target="Adapter" Name="FileAccessTimeout">10</Setting>
    <Setting Target="Adapter" Name="FilePath">\\HSCARB01\Ops\Dir_Prod\In\Al\Regions-Micro-Results\</Setting>
  </Item>
  <Item Name="File.O.ArchiveEdocsScan" Category="edocsScan,Archive" ClassName="EnsLib.HL7.Operation.FileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="Archive eDocsScan ORU in HL7 format" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="Filename">eDocsScanORU_%q(2)_%H.txt</Setting>
    <Setting Target="Adapter" Name="FilePath">\\HSCARB01\Ops\Dir_Prod\archive\processed\eDocsScan</Setting>
  </Item>
  <Item Name="zzResend.S.AljOrm" Category="" ClassName="EnsLib.HL7.Service.FileService" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">RgnsLab.P.boBeaker</Setting>
    <Setting Target="Adapter" Name="FileAccessTimeout">10</Setting>
    <Setting Target="Adapter" Name="FilePath">\\HSCARB01\Ops\Dir_Prod\In\Al\PacsOrm\</Setting>
  </Item>
  <Item Name="zResend.S.AljOruPACS" Category="" ClassName="EnsLib.HL7.Service.FileService" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">PS360Radiology.P.bs</Setting>
    <Setting Target="Host" Name="UseAckCommitCodes">0</Setting>
    <Setting Target="Adapter" Name="FilePath">\\HSCARB01\Ops\Dir_Prod\In\Al\PacsOru\</Setting>
  </Item>
  <Item Name="HL7.S.CrImageStreamAdt" Category="imagestream" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="Port 10806 ADT Cerner to ImageStream; RT_ADT_IMAGESTRM_OUT" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">ImageStream.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10806</Setting>
  </Item>
  <Item Name="RgnsDiet.P.bs" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="Cerner ADT and ORM" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.RgnsDietBsRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="RgnsDiet.P.bo" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="Route Cerner ADT &amp; ORM to Regions Diet" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.RgnsDietBoRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="RelayHealth.P.bs" Category="Cerner,RelayHealth" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="RelayHealth ADT" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.RelayHealthBsRule</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
  </Item>
  <Item Name="RelayHealth.P.bo" Category="Cerner,RelayHealth" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="RelayHealth ADT" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.RelayHealthBoRule</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
  </Item>
  <Item Name="RgnsCharges.P.bs" Category="RgnsLab,Cerner" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.RgnsChargesBsRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="RgnsCharges.P.bo" Category="RgnsLab,Cerner" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.RgnsChargesBoRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="PS360Radiology.P.bs" Category="radiology,Cerner" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="Radiology PowerScribe 360" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation">d-z</Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.PS360RadiologyBsRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="PS360Radiology.P.bo" Category="radiology" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="Radiology PowerScribe 360" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation">d-z</Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.PS360RadiologyBoRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="Pacs.P.bs" Category="radiology,Cerner" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.PacsBsRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="Pacs.P.bo" Category="radiology" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.PacsBoRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="NuanceEscription.P.bs" Category="Cerner,Nuance" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.NuanceEscriptionBsRule</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
  </Item>
  <Item Name="NuanceEscription.P.bo" Category="Nuance,Cerner" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.NuanceEscriptionBoRule</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
  </Item>
  <Item Name="eDocsScan.P.bs" Category="edocsScan,ellen" ClassName="EnsLib.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="BusinessRuleName">GC.eDocsScanBsRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="eDocsNuance.P.bs" Category="Nuance,Cerner,edocs" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.EdocsNuanceBsRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
  </Item>
  <Item Name="eDocsNuance.P.bo" Category="Nuance,Cerner,edocs" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.EdocsNuanceBoRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
  </Item>
  <Item Name="CarefusionPFT.P.bs" Category="Cerner,CareFusion" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.CarefusionPFTBsRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
  </Item>
  <Item Name="CarefusionPFT.P.bo" Category="Cerner,CareFusion" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.CarefusionPFTBoRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
  </Item>
  <Item Name="Acuity.P.bs" Category="Cerner,Acuity" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="Cerner ADT messages" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.AcuityBsRule</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
  </Item>
  <Item Name="Acuity.P.bo" Category="Cerner,Acuity" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="Cerner ADT messages" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.AcuityBoRule</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
  </Item>
  <Item Name="Pyxis.P.bs" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.PyxisBsRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="Pyxis.P.bo" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.PyxisBoRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="eDocsRad.P.bs" Category="radiology,edocs" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="Rad ORU" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.eDocsRadBsRule</Setting>
  </Item>
  <Item Name="eDocs.P.bo" Category="ellen,radiology,edocs" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="ADT and Result DOC And Tag" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.eDocsBoRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="Cerner.P.bs" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.CernerBsRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="ImageStream.P.bs" Category="Cerner,imagestream" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="ImageStream messages from Cerner" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="Validation">dm-z</Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.ImageStreamBsRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
  </Item>
  <Item Name="ImageStream.P.bo" Category="Cerner,imagestream" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="ImageStream messages from Cerner" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation">dm-z</Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.ImageStreamBoRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
  </Item>
  <Item Name="Muse.P.bo" Category="Cerner,Muse" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="Route Cerner ADT &amp; ORM to Ge Muse" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.MuseBoRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="Muse.P.bs" Category="Cerner,Muse" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.MuseBsRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
    <Setting Target="Host" Name="BusinessPartner"></Setting>
  </Item>
  <Item Name="RelayHealthX12.P.bs" Category="Cerner,RelayHealth" ClassName="EnsLib.MsgRouter.VDocRoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.RelayHealthX12RoutingRule</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
  </Item>
  <Item Name="Spr.P.bo" Category="radiology" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.SprBoRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="Spr.P.bs" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.SprBsRule</Setting>
    <Setting Target="Host" Name="AlertOnError">0</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
  </Item>
  <Item Name="HL7.O.PowershareOru" Category="radiology" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="Signed ORU from PS360 and SPR and sends to Nuance" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="AlertOnError">1</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">:?R=F,:?E=S,:~=S,:?A=C,:*=S,:I?=W,:T?=C</Setting>
    <Setting Target="Adapter" Name="IPAddress">172.25.68.116</Setting>
    <Setting Target="Adapter" Name="Port">10831</Setting>
    <Setting Target="Host" Name="AlertRetryGracePeriod">10</Setting>
  </Item>
  <Item Name="Powershare.P.bo" Category="radiology" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.PowershareBoRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="Powershare.P.bs" Category="radiology" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.PowershareBsRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="HL7.S.CrPowershareOru" Category="radiology" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="RT_ORU_POWERSHARE_OUT" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Powershare.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10833</Setting>
  </Item>
  <Item Name="Email.O.AlertEmailRegLab" Category="alert,RgnsLab" ClassName="GC.Utils.CustomEmailHL7" PoolSize="1" Enabled="true" Foreground="false" Comment="Alert RegLab ORM &apos;Pre&apos; inpatient etc" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="CustomSubject">RegionsLab ORM for PRE patient type</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">E=D</Setting>
    <Setting Target="Adapter" Name="Cc">saidsheikh@gillettechildrens.com</Setting>
    <Setting Target="Adapter" Name="From">CernerPRODalert@gillettechildrens.com</Setting>
    <Setting Target="Adapter" Name="Recipient">alewis@gillettechildrens.com</Setting>
    <Setting Target="Adapter" Name="SMTPPort">25</Setting>
    <Setting Target="Adapter" Name="SMTPServer">smtprelay.gillette.int</Setting>
  </Item>
  <Item Name="HL7.O.RLSolutionsAdt" Category="Cerner,RLSolutions" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="RLSolutions - Occurence Safety Events" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">:?R=S,:?E=S,:~=S,:I?=W,:T?=C</Setting>
    <Setting Target="Adapter" Name="IPAddress">RLAPPPR01</Setting>
    <Setting Target="Adapter" Name="Port">4500</Setting>
    <Setting Target="Host" Name="AlertOnError">1</Setting>
    <Setting Target="Host" Name="AlertRetryGracePeriod">7</Setting>
  </Item>
  <Item Name="RLSolutions.P.bo" Category="Cerner,RLSolutions" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.RLSolutionsBoRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="RLSolutions.P.bs" Category="Cerner,RLSolutions" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.RLSolutionsBsRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="AlertOnError">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="HL7.S.CrRLSolutionsAdt" Category="Cerner,RLSolutions" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="AlertOnError">1</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">RLSolutions.P.bs</Setting>
    <Setting Target="Host" Name="UseAckCommitCodes">0</Setting>
    <Setting Target="Adapter" Name="Port">10836</Setting>
  </Item>
  <Item Name="File.O.ArchiveFileTransfers" Category="CureSMA" ClassName="EnsLib.File.PassthroughOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="Filename">%f_%Q%!+(_a).txt</Setting>
    <Setting Target="Adapter" Name="FilePath">\\HSCARB01\Ops\Dir_Prod\archive\HttpFiles\</Setting>
  </Item>
  <Item Name="CureSMAHttp.P.bs" Category="CureSMA" ClassName="EnsLib.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.CureSMAHttpBsRule</Setting>
  </Item>
  <Item Name="HTTP.S.CrCureSMAccd" Category="CureSMA" ClassName="GC.Cerner.HTTP.GenericServiceRev1" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="AlertOnError">1</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="CSPNoCharSetConvert">1</Setting>
    <Setting Target="Host" Name="KeepCSPPartition">0</Setting>
    <Setting Target="Host" Name="OneWay">1</Setting>
    <Setting Target="Host" Name="TargetConfigName">CureSMAHttp.P.bs</Setting>
    <Setting Target="Adapter" Name="Charset"></Setting>
    <Setting Target="Adapter" Name="Port">10734</Setting>
    <Setting Target="Adapter" Name="QSize">0</Setting>
    <Setting Target="Adapter" Name="StayConnected">-1</Setting>
  </Item>
  <Item Name="HTTP.O.CureSMAccd" Category="CureSMA" ClassName="GC.Cerner.HTTP.GenericOperationRev1" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="ReadRawMode">0</Setting>
    <Setting Target="Adapter" Name="URL">https://curesma-api.rexdb.net/api/ccda/</Setting>
    <Setting Target="Adapter" Name="SSLConfig">CureSMA.SSL.Config</Setting>
  </Item>
  <Item Name="HL7.O.CrRgnsLabBeakerOru" Category="RgnsLab,Cerner" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Adapter" Name="IPAddress">104.170.172.151</Setting>
    <Setting Target="Adapter" Name="Port">10732</Setting>
  </Item>
  <Item Name="HL7.O.RgnsLabAdtOrmBeaker" Category="RgnsLab,Cerner" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="AlertRetryGracePeriod">120</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">:?R=S,:?E=S,:~=S,:I?=W,:T?=C</Setting>
    <Setting Target="Adapter" Name="ConnectTimeout">30</Setting>
    <Setting Target="Adapter" Name="IPAddress">10.200.10.66</Setting>
    <Setting Target="Adapter" Name="Port">19010</Setting>
  </Item>
  <Item Name="RgnsLab.P.boBeakerAdt" Category="RgnsLab,Cerner" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.RgnsLabBoRuleBeakerAdt</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="RgnsLab.P.boBeaker" Category="RgnsLab,Cerner" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.RgnsLabBoRuleBeaker</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="AlertOnError">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="RgnsLab.P.bsBeaker" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.RgnsLabBsRuleBeaker</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="HL7.S.CrRgnsLabBeakerOrm" Category="RgnsLab,Cerner" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="AlertOnError">1</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">RgnsLab.P.bsBeaker</Setting>
    <Setting Target="Adapter" Name="Port">10834</Setting>
  </Item>
  <Item Name="HL7.S.RgnsLabBeakerOru" Category="RgnsLab,Cerner" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="BatchHandling">Indiv</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">251.Regions</Setting>
    <Setting Target="Host" Name="TargetConfigNames">RgnsLab.P.bsBeaker</Setting>
    <Setting Target="Host" Name="UseAckCommitCodes">0</Setting>
    <Setting Target="Adapter" Name="Port">19011</Setting>
    <Setting Target="Adapter" Name="ReadTimeout">30</Setting>
  </Item>
  <Item Name="zzHTTP2Cert.O.CureSMA" Category="" ClassName="GC.Cerner.HTTP.GenericOperationRev1" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="FailureTimeout">15</Setting>
    <Setting Target="Host" Name="RetryInterval">15</Setting>
    <Setting Target="Adapter" Name="ConnectTimeout">20</Setting>
    <Setting Target="Adapter" Name="HTTPPort">11738</Setting>
    <Setting Target="Adapter" Name="HTTPServer">172.25.68.31</Setting>
    <Setting Target="Adapter" Name="SSLCheckServerIdentity">0</Setting>
  </Item>
  <Item Name="SQL.O.eDocsAdt2Prod2019" Category="edocs,edocSql,sql" ClassName="IIBAENSEMBLE.Bop.SQLStoredProcedureParam" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="FailureTimeout">600</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">E*90011=F,E*900=WF,E#6022=R,E=D</Setting>
    <Setting Target="Host" Name="SpMessageClass">GC.eDOCSsql.ADTParameters</Setting>
    <Setting Target="Host" Name="StoredProcName">docsadm.sp_hl7_event</Setting>
    <Setting Target="Adapter" Name="Credentials">EnsembleSQL</Setting>
    <Setting Target="Adapter" Name="DSN">Ensemble2eDOCProd2019SQL64</Setting>
    <Setting Target="Adapter" Name="StayConnected">120</Setting>
  </Item>
  <Item Name="HL7.O.MneasAdt" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment=" Pointclickcare ADT for Minn Medicaid patients old ip 216.230.101.28 port 9110" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Adapter" Name="IPAddress">integration-external.ainqapps.com</Setting>
    <Setting Target="Adapter" Name="Port">21500</Setting>
    <Setting Target="Adapter" Name="SSLConfig">MNEas.TLS.Config</Setting>
    <Setting Target="Adapter" Name="StayConnected">120</Setting>
  </Item>
  <Item Name="Mneas.P.bo" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.MneasBoRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="Mneas.P.bs" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.MneasBsRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="AlertOnError">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="HL7.S.CrMneasAdt" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Mneas.P.bs</Setting>
    <Setting Target="Host" Name="UseAckCommitCodes">0</Setting>
    <Setting Target="Adapter" Name="Port">10837</Setting>
  </Item>
  <Item Name="File.O.RegionsChargesv3" Category="" ClassName="GC.Regions.DFT.PassthroughOperationv3" PoolSize="1" Enabled="true" Foreground="false" Comment="Update-create csv file - new fields 7/22/19" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ReplyCodeActions">E=D</Setting>
    <Setting Target="Host" Name="TargetFileName">RegionsChargesDelimited.csv</Setting>
    <Setting Target="Host" Name="TargetFilePath">\\HSCARB01\Ops\Dir_Prod\Regions\DFT\</Setting>
    <Setting Target="Adapter" Name="FilePath">**Use TargetFilePath**</Setting>
  </Item>
  <Item Name="HL7.O.NowPowAdt" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="NowPow Family Services" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Adapter" Name="IPAddress">10.253.1.117</Setting>
    <Setting Target="Adapter" Name="Port">10248</Setting>
  </Item>
  <Item Name="NowPow.P.bo" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.NowPowBoRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="NowPow.P.bs" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.NowPowBsRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="HL7.S.CrNowPowAdt" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">NowPow.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10840</Setting>
  </Item>
  <Item Name="HL7.O.OberdAdtSiu" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Adapter" Name="IPAddress">50.56.11.142</Setting>
    <Setting Target="Adapter" Name="Port">11160</Setting>
  </Item>
  <Item Name="Oberd.P.boSiu" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.OberdBoSiuRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="Oberd.P.bo" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.OberdBoRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="Oberd.P.bs" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.OberdBsRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="HL7.S.CrOberdAdtSiu" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Oberd.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10839</Setting>
  </Item>
  <Item Name="Email.O.AlertEmailSprORU" Category="alert" ClassName="GC.Utils.CustomEmailHL7" PoolSize="1" Enabled="true" Foreground="false" Comment="SPR ORU unaliased radiologist" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="CustomSubject">Midwest ORU OBR-32 unaliased radiologist</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">E=D</Setting>
    <Setting Target="Adapter" Name="Cc"></Setting>
    <Setting Target="Adapter" Name="From">CernerPRODalert@gillettechildrens.com</Setting>
    <Setting Target="Adapter" Name="Recipient">JValiant@gillettechildrens.com</Setting>
    <Setting Target="Adapter" Name="SMTPPort">25</Setting>
    <Setting Target="Adapter" Name="SMTPServer">smtprelay.gillette.int</Setting>
  </Item>
  <Item Name="zALJ.O.eDOCShl7" Category="" ClassName="EnsLib.HL7.Operation.FileOperation" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="FilePath">\\HSCARB01\Ops\Dir_Prod\Out\AleDocs\</Setting>
    <Setting Target="Host" Name="Filename">aljeDOCSreplay</Setting>
  </Item>
  <Item Name="zALJeDOCS.P.bo" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="Validation">dm-z</Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.aljEdocsNuanceBoRule</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="Email.O.AlertEmaileDocs" Category="" ClassName="GC.Utils.CustomEmailHL7" PoolSize="1" Enabled="true" Foreground="false" Comment="eDocs Addendums" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="CustomSubject">eDocs Addendum</Setting>
    <Setting Target="Adapter" Name="From">CernerPRODalert@gillettechildrens.com</Setting>
    <Setting Target="Adapter" Name="Recipient">saidsheikh@gillettechildrensc.com</Setting>
    <Setting Target="Adapter" Name="SMTPPort">25</Setting>
    <Setting Target="Adapter" Name="SMTPServer">smtprelay.gillette.int</Setting>
  </Item>
  <Item Name="HL7.O.CrClevelandClinicOru" Category="clevelandclinic" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="AlertOnError">1</Setting>
    <Setting Target="Host" Name="AlertRetryGracePeriod">120</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">:?R=S,:?E=S,:~=S,:I?=W,:T?=C</Setting>
    <Setting Target="Adapter" Name="IPAddress">104.170.172.151</Setting>
    <Setting Target="Adapter" Name="Port">10841</Setting>
  </Item>
  <Item Name="ClevelandClinic.P.bo" Category="clevelandclinic" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.ClevelandClinicBoRule</Setting>
  </Item>
  <Item Name="ClevelandClinic.P.bs" Category="clevelandclinic" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.ClevelandClinicBsRule</Setting>
  </Item>
  <Item Name="File.S.ClevelandClinicOru" Category="clevelandclinic" ClassName="EnsLib.HL7.Service.FileService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">231.ClevelandClinic</Setting>
    <Setting Target="Host" Name="TargetConfigNames">ClevelandClinic.P.bs</Setting>
    <Setting Target="Host" Name="UseAckCommitCodes">0</Setting>
    <Setting Target="Adapter" Name="FileAccessTimeout">10</Setting>
    <Setting Target="Adapter" Name="FilePath">\\HSCARB01\Ops\Dir_Prod\In\ClevelandClinic\</Setting>
    <Setting Target="Adapter" Name="ConfirmComplete">1</Setting>
  </Item>
  <Item Name="HL7.S.CrMultiMfn" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Cerner.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10835</Setting>
  </Item>
  <Item Name="HL7.S.CrNuancePDSMfn" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">NuancePDS.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10843</Setting>
  </Item>
  <Item Name="HL7.O.NuancePDSMfn" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">:?R=S,:?E=S,:~=S,:I?=W,:T?=C</Setting>
    <Setting Target="Adapter" Name="Port">10844</Setting>
    <Setting Target="Adapter" Name="IPAddress">NuPCAFBPR01</Setting>
  </Item>
  <Item Name="NuancePDS.P.bo" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.NuancePDSBoRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="NuancePDS.P.bs" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.NuancePDSBsRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="zResend.S.ClevelandClinicMaxSizeOru" Category="clevelandclinic" ClassName="EnsLib.HL7.Service.FileService" PoolSize="1" Enabled="true" Foreground="false" Comment="Bypass DTL Send Fixed HL7 Cleveland Max Size Report" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">HL7.O.CrClevelandClinicOru</Setting>
    <Setting Target="Adapter" Name="FilePath">\\HSCARB01\Ops\Dir_Prod\In\ClevelandClinicFix\</Setting>
    <Setting Target="Host" Name="UseAckCommitCodes">0</Setting>
  </Item>
  <Item Name="HL7.O.CrNatusOru" Category="Cerner,Natus" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="AlertOnError">1</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">:?R=S,:?E=S,:~=S,:I?=W,:T?=C</Setting>
    <Setting Target="Adapter" Name="IPAddress">104.170.172.151</Setting>
    <Setting Target="Adapter" Name="Port">10736</Setting>
  </Item>
  <Item Name="HL7.O.NatusOrm" Category="Cerner,Natus" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">:?R=F,:?E=S,:~=S,:?A=C,:*=S,:I?=W,:T?=C</Setting>
    <Setting Target="Adapter" Name="IPAddress">nusleepwkint</Setting>
    <Setting Target="Adapter" Name="Port">10737</Setting>
  </Item>
  <Item Name="Natus.P.bo" Category="Cerner,Natus" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.NatusBoRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="Natus.P.bs" Category="Cerner,Natus" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.NatusBsRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="HL7.S.CrNatusOrm" Category="Cerner,Natus" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Natus.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10846</Setting>
  </Item>
  <Item Name="HL7.S.NatusOru" Category="Cerner,Natus" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Natus.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10847</Setting>
    <Setting Target="Adapter" Name="ReadTimeout">5</Setting>
  </Item>
  <Item Name="RgnsLab.P.boBeakerHang" Category="RgnsLab,Cerner" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="hang msg up to 10 seconds b4 processing" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.RgnsLabBoRuleBeakerHang</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="HL7.O.AgilitiAdt" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="false" Foreground="false" Comment="Cerner to Agiliti 172.25.249.23" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="AlertRetryGracePeriod">120</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">:?R=S,:?E=S,:~=S,:I?=W,:T?=C</Setting>
    <Setting Target="Adapter" Name="IPAddress">UHSAPP01</Setting>
    <Setting Target="Adapter" Name="Port">4200</Setting>
    <Setting Target="Adapter" Name="ReadTimeout">30</Setting>
  </Item>
  <Item Name="Agiliti.P.bo" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.AgilitiBoRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="Agiliti.P.bs" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.AgilitiBsRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="HL7.S.CrAgilitiAdt" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="Cerner to UHS (RT_ADT_AGILITI_OUT)" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Agiliti.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10807</Setting>
  </Item>
  <Item Name="HL7.O.NuanceDAXAdt" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">:?R=S,:?E=S,:~=S,:I?=W,:T?=C</Setting>
    <Setting Target="Adapter" Name="IPAddress">104.239.208.119</Setting>
    <Setting Target="Adapter" Name="Port">10329</Setting>
  </Item>
  <Item Name="HL7.O.NuanceDAXSiu" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">:?R=S,:?E=S,:~=S,:I?=W,:T?=C</Setting>
    <Setting Target="Adapter" Name="IPAddress">104.239.208.119</Setting>
    <Setting Target="Adapter" Name="Port">10331</Setting>
  </Item>
  <Item Name="NuanceDAX.P.bo" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.NuanceDAXBoRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="NuanceDAX.P.bs" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.NuanceDAXBsRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="HL7.S.CrNuanceDAXAdtSiu" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="RT_ADTSIU_NUANCEDAX_OUT" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">NuanceDAX.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10849</Setting>
  </Item>
  <Item Name="HL7.O.PharmacyKeeperRds" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">:?R=S,:?E=S,:~=S,:I?=W,:T?=C</Setting>
    <Setting Target="Adapter" Name="IPAddress">52.7.237.160</Setting>
    <Setting Target="Adapter" Name="Port">10851</Setting>
  </Item>
  <Item Name="SFTP.O.AgilitiAdt" Category="" ClassName="EnsLib.HL7.Operation.FTPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Filename">%q_%N.txt</Setting>
    <Setting Target="Adapter" Name="Credentials">AgilitiSFTP</Setting>
    <Setting Target="Adapter" Name="FTPPort">2222</Setting>
    <Setting Target="Adapter" Name="FTPServer">adt.agilitihealth.com</Setting>
    <Setting Target="Adapter" Name="FilePath">/uploads</Setting>
    <Setting Target="Adapter" Name="SFTPPrivateKeyFile">c:\Gillette\Agiliti\Gillette.key</Setting>
    <Setting Target="Adapter" Name="SFTPPublicKeyFile">c:\Gillette\Agiliti\Gillette.pem</Setting>
    <Setting Target="Adapter" Name="SSLConfig">!SFTP</Setting>
  </Item>
  <Item Name="PharmacyKeeper.P.bo" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.PharmacyKeeperBoRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="PharmacyKeeper.P.bs" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.PharmacyKeeperBsRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="HL7.S.CrPharmacyKeeperRds" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="RT_RDS_PHARMACYKEEPER_OUT" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="AlertOnError">1</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">PharmacyKeeper.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10850</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
  </Item>
  <Item Name="HL7.O.BreezeSuiteOrm" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="AlertOnError">1</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Adapter" Name="IPAddress">PFTPR01</Setting>
    <Setting Target="Adapter" Name="Port">10856</Setting>
  </Item>
  <Item Name="BreezeSuite.P.bo" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.BreezeSuiteBoRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="BreezeSuite.P.bs" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">GC.BreezeSuiteBsRule</Setting>
    <Setting Target="Host" Name="AlertOnBadMessage">1</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="HL7.O.CrBreezeSuiteOru" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="AlertOnError">1</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Adapter" Name="Port">10855</Setting>
    <Setting Target="Adapter" Name="IPAddress">104.170.172.151</Setting>
  </Item>
  <Item Name="HL7.S.CrBreezeSuiteOrm" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="AlertOnError">1</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">BreezeSuite.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10853</Setting>
  </Item>
  <Item Name="HL7.S.BreezeSuiteOru" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">BreezeSuite.P.bs</Setting>
    <Setting Target="Adapter" Name="Port">10854</Setting>
    <Setting Target="Host" Name="AlertOnError">1</Setting>
  </Item>
  <Item Name="HL7.S.CadwellORU" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Cadwell.CadwellBsRule</Setting>
    <Setting Target="Adapter" Name="Port">10857</Setting>
  </Item>
  <Item Name="Cadwell.CadwellBsRule" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">Cadwell.CadwellBsRule</Setting>
  </Item>
  <Item Name="Cadwell.CadwellBoRule" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">Cadwell.CadwellBoRule</Setting>
  </Item>
  <Item Name="HL7.O.CadwellOrm" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="IPAddress">172.25.68.5</Setting>
    <Setting Target="Adapter" Name="Port">32124</Setting>
  </Item>
  <Item Name="HL7.O.CrCadwellOru" Category="" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="IPAddress">104.170.172.150</Setting>
    <Setting Target="Adapter" Name="Port">10859</Setting>
  </Item>
  <Item Name="HL7.S.Cr.CadwellOrm" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">231.Cerner</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Cadwell.CadwellBsRule</Setting>
    <Setting Target="Adapter" Name="Port">10858</Setting>
  </Item>
</Production>
}

}
