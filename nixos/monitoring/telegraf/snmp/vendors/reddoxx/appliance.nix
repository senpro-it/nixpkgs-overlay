{ config, lib, pkgs, ... }:

with lib;

let
  /* Shared Telegraf option helpers. */
  telegrafOptions = import ../../../options.nix { inherit lib; };
  /* Global SNMP input toggle. */
  snmpCfg = config.senpro.monitoring.telegraf.inputs.snmp;
  /* REDDOXX appliance config subtree. */
  deviceCfg = config.senpro.monitoring.telegraf.inputs.snmp.vendors.reddoxx;

  /* Build the Telegraf SNMP input for one appliance.
     @param agent: SNMP agent address.
     @return Sanitized Telegraf input configuration.
  */
  mkSnmpInput = agent: telegrafOptions.sanitizeToml {
    name = "reddoxx";
    path = [ "${pkgs.mib-library}/opt/mib-library/" ];
    agents = [ agent ];
    timeout = "20s";
    version = 3;
    sec_level = "${deviceCfg.credentials.security.level}";
    sec_name = "${deviceCfg.credentials.security.username}";
    auth_protocol = "${deviceCfg.credentials.authentication.protocol}";
    auth_password = "${deviceCfg.credentials.authentication.password}";
    priv_protocol = "${deviceCfg.credentials.privacy.protocol}";
    priv_password = "${deviceCfg.credentials.privacy.password}";
    retries = 5;
    field = [
      { name = "SmtpReceiverConnectionsIn"; oid = "REDDOXX-MIB::smtpReceiverConnectionsIn"; conversion = "int"; }
      { name = "SmtpReceiverConnectionsOut"; oid = "REDDOXX-MIB::smtpReceiverConnectionsOut"; conversion = "int"; }
      { name = "SmtpReceiverMessagesReceivedIn"; oid = "REDDOXX-MIB::smtpReceiverMessagesReceivedIn"; conversion = "int"; }
      { name = "SmtpReceiverMessagesReceivedOut"; oid = "REDDOXX-MIB::smtpReceiverMessagesReceivedOut"; conversion = "int"; }
      { name = "SmtpReceiverBytesReceivedIn"; oid = "REDDOXX-MIB::smtpReceiverBytesReceivedIn"; conversion = "int"; }
      { name = "SmtpReceiverBytesReceivedOut"; oid = "REDDOXX-MIB::smtpReceiverBytesReceivedOut"; conversion = "int"; }
      { name = "SmtpReceiverActiveConnections"; oid = "REDDOXX-MIB::smtpReceiverActiveConnections"; conversion = "int"; }
      { name = "RejectedMessagesBecauseIpBlacklisted"; oid = "REDDOXX-MIB::rejectedMessagesBecauseIpBlacklisted"; conversion = "int"; }
      { name = "RejectedMessagesBecauseAntiSpoofing"; oid = "REDDOXX-MIB::rejectedMessagesBecauseAntiSpoofing"; conversion = "int"; }
      { name = "RejectedMessagesBecauseSpf"; oid = "REDDOXX-MIB::rejectedMessagesBecauseSpf"; conversion = "int"; }
      { name = "ValidDkimSignatures"; oid = "REDDOXX-MIB::validDkimSignatures"; conversion = "int"; }
      { name = "InvalidDkimSignatures"; oid = "REDDOXX-MIB::invalidDkimSignatures"; conversion = "int"; }
      { name = "SmtpSenderConnectionsIn"; oid = "REDDOXX-MIB::smtpSenderConnectionsIn"; conversion = "int"; }
      { name = "SmtpSenderConnectionsOut"; oid = "REDDOXX-MIB::smtpSenderConnectionsOut"; conversion = "int"; }
      { name = "SmtpSenderMessagesSentIn"; oid = "REDDOXX-MIB::smtpSenderMessagesSentIn"; conversion = "int"; }
      { name = "SmtpSenderMessagesSentOut"; oid = "REDDOXX-MIB::smtpSenderMessagesSentOut"; conversion = "int"; }
      { name = "SmtpSenderBytesSentIn"; oid = "REDDOXX-MIB::smtpSenderBytesSentIn"; conversion = "int"; }
      { name = "SmtpSenderBytesSentOut"; oid = "REDDOXX-MIB::smtpSenderBytesSentOut"; conversion = "int"; }
      { name = "SmtpSenderActiveConnections"; oid = "REDDOXX-MIB::smtpSenderActiveConnections"; conversion = "int"; }
      { name = "MessagesWaitingForProcessing"; oid = "REDDOXX-MIB::messagesWaitingForProcessing"; conversion = "int"; }
      { name = "MessagesWaitingForDelivery"; oid = "REDDOXX-MIB::messagesWaitingForDelivery"; conversion = "int"; }
      { name = "ArchiveQueueLength"; oid = "REDDOXX-MIB::archiveQueueLength"; conversion = "int"; }
      { name = "RssMemoryUsageApplianceManager"; oid = "REDDOXX-MIB::rssMemoryUsageApplianceManager"; conversion = "int"; }
      { name = "RssMemoryUsageMailDepot"; oid = "REDDOXX-MIB::rssMemoryUsageMailDepot"; conversion = "int"; }
      { name = "RssMemoryUsageSystemManager"; oid = "REDDOXX-MIB::rssMemoryUsageSystemManager"; conversion = "int"; }
      { name = "RssMemoryyUsageComplianceLog"; oid = "REDDOXX-MIB::rssMemoryyUsageComplianceLog"; conversion = "int"; }
      { name = "RssMemoryUsageSpamfinder"; oid = "REDDOXX-MIB::rssMemoryUsageSpamfinder"; conversion = "int"; }
      { name = "RssMemoryUsageClamav"; oid = "REDDOXX-MIB::rssMemoryUsageClamav"; conversion = "int"; }
      { name = "RssMemoryUsageMongoDB"; oid = "REDDOXX-MIB::rssMemoryUsageMongoDB"; conversion = "int"; }
      { name = "RssMemoryUsageHaProxy"; oid = "REDDOXX-MIB::rssMemoryUsageHaProxy"; conversion = "int"; }
      { name = "RssMemoryUsageMailSealer"; oid = "REDDOXX-MIB::rssMemoryUsageMailSealer"; conversion = "int"; }
      { name = "RssMemoryUsageSmtpReceiver"; oid = "REDDOXX-MIB::rssMemoryUsageSmtpReceiver"; conversion = "int"; }
      { name = "RssMemoryUsageSmtpSender"; oid = "REDDOXX-MIB::rssMemoryUsageSmtpSender"; conversion = "int"; }
      { name = "RssMemoryUsageLogManager"; oid = "REDDOXX-MIB::rssMemoryUsageLogManager"; conversion = "int"; }
      { name = "RssMemoryUsageReddcryptGateway"; oid = "REDDOXX-MIB::rssMemoryUsageReddcryptGateway"; conversion = "int"; }
      { name = "RssMemoryUsageMailDepotIndex"; oid = "REDDOXX-MIB::rssMemoryUsageMailDepotIndex"; conversion = "int"; }
      { name = "CpuUsageApplianceManager"; oid = "REDDOXX-MIB::cpuUsageApplianceManager"; conversion = "int"; }
      { name = "CpuUsageMailDepot"; oid = "REDDOXX-MIB::cpuUsageMailDepot"; conversion = "int"; }
      { name = "CpuUsageSystemManager"; oid = "REDDOXX-MIB::cpuUsageSystemManager"; conversion = "int"; }
      { name = "CpuUsageComplianceLog"; oid = "REDDOXX-MIB::cpuUsageComplianceLog"; conversion = "int"; }
      { name = "CpuUsageSpamfinder"; oid = "REDDOXX-MIB::cpuUsageSpamfinder"; conversion = "int"; }
      { name = "CpuUsageClamav"; oid = "REDDOXX-MIB::cpuUsageClamav"; conversion = "int"; }
      { name = "CpuUsageMongoDB"; oid = "REDDOXX-MIB::cpuUsageMongoDB"; conversion = "int"; }
      { name = "CpuUsageHaProxy"; oid = "REDDOXX-MIB::cpuUsageHaProxy"; conversion = "int"; }
      { name = "CpuUsageMailSealer"; oid = "REDDOXX-MIB::cpuUsageMailSealer"; conversion = "int"; }
      { name = "CpuUsageSmtpReceiver"; oid = "REDDOXX-MIB::cpuUsageSmtpReceiver"; conversion = "int"; }
      { name = "CpuUsageSmtpSender"; oid = "REDDOXX-MIB::cpuUsageSmtpSender"; conversion = "int"; }
      { name = "CpuUsageLogManager"; oid = "REDDOXX-MIB::cpuUsageLogManager"; conversion = "int"; }
      { name = "CpuUsageReddcryptGateway"; oid = "REDDOXX-MIB::cpuUsageReddcryptGateway"; conversion = "int"; }
      { name = "CpuUsageMailDepotIndex"; oid = "REDDOXX-MIB::cpuUsageMailDepotIndex"; conversion = "int"; }
      { name = "UptimeApplianceManager"; oid = "REDDOXX-MIB::uptimeApplianceManager"; conversion = "int"; }
      { name = "UptimeMailDepot"; oid = "REDDOXX-MIB::uptimeMailDepot"; conversion = "int"; }
      { name = "UptimeSystemManager"; oid = "REDDOXX-MIB::uptimeSystemManager"; conversion = "int"; }
      { name = "UptimeComplianceLog"; oid = "REDDOXX-MIB::uptimeComplianceLog"; conversion = "int"; }
      { name = "UptimeSpamfinder"; oid = "REDDOXX-MIB::uptimeSpamfinder"; conversion = "int"; }
      { name = "UptimeClamav"; oid = "REDDOXX-MIB::uptimeClamav"; conversion = "int"; }
      { name = "UptimeMongoDB"; oid = "REDDOXX-MIB::uptimeMongoDB"; conversion = "int"; }
      { name = "UptimeHaProxy"; oid = "REDDOXX-MIB::uptimeHaProxy"; conversion = "int"; }
      { name = "UptimeMailSealer"; oid = "REDDOXX-MIB::uptimeMailSealer"; conversion = "int"; }
      { name = "UptimeSmtpReceiver"; oid = "REDDOXX-MIB::uptimeSmtpReceiver"; conversion = "int"; }
      { name = "UptimeSmtpSender"; oid = "REDDOXX-MIB::uptimeSmtpSender"; conversion = "int"; }
      { name = "UptimeLogManager"; oid = "REDDOXX-MIB::uptimeLogManager"; conversion = "int"; }
      { name = "UptimeReddcryptGateway"; oid = "REDDOXX-MIB::uptimeReddcryptGateway"; conversion = "int"; }
      { name = "UptimeMailDepotIndex"; oid = "REDDOXX-MIB::uptimeMailDepotIndex"; conversion = "int"; }
      { name = "OpenFilesTotal"; oid = "REDDOXX-MIB::openFilesTotal"; conversion = "int"; }
      { name = "OpenFilesContainer"; oid = "REDDOXX-MIB::openFilesContainer"; conversion = "int"; }
      { name = "OpenFilesIndex"; oid = "REDDOXX-MIB::openFilesIndex"; conversion = "int"; }

      /* Default MIB OIDs (reused from (...).vendor.sophos.xg) */
      { name = "contact"; oid = "SNMPv2-MIB::sysContact.0"; }
      { name = "description"; oid = "SNMPv2-MIB::sysDescr.0"; }
      { name = "location"; oid = "SNMPv2-MIB::sysLocation.0"; }
      { name = "host"; oid = "SNMPv2-MIB::sysName.0"; is_tag = true; }
      { name = "uptime"; oid = "SNMPv2-MIB::sysUpTime.0"; }
      /* Missing:
         diskCapacity, diskPercentUsage,
         memoryCapacity (via defaults?), memoryPercentage
      */
    ];
    table = [
      {
        name = "reddoxx.storage";
        oid = "HOST-RESOURCES-MIB::hrStorageTable";
        index_as_tag = true;
        inherit_tags = ["host"];
        field = [
          {
            oid = "HOST-RESOURCES-MIB::hrStorageType";
            is_tag = true;
          }
          {
            oid = "HOST-RESOURCES-MIB::hrStorageDescr";
            is_tag = true;
          }
          {
            oid = "HOST-RESOURCES-MIB::hrStorageSize";
          }
          {
            oid = "HOST-RESOURCES-MIB::hrStorageUsed";
          }
        ];
      }
      {
        name = "reddoxx.ifTable";
        oid = "IF-MIB::ifTable";
        index_as_tag = true;
        inherit_tags = [ "host" ];
        field = [
          { oid = "IF-MIB::ifDescr"; is_tag = true; }
        ];
      }
      {
        name = "reddoxx.ifXTable";
        oid = "IF-MIB::ifXTable";
        index_as_tag = true;
        inherit_tags = [ "host" ];
        field = [
          { oid = "IF-MIB::ifName"; is_tag = true; }
        ];
      }
      { name = "reddoxx.ipAddrTable"; oid = "IP-MIB::ipAddrTable"; inherit_tags = [ "host" ]; }
      {
        name = "reddoxx.cpu";
        oid = "HOST-RESOURCES-MIB::hrProcessorTable";
        index_as_tag = true;
        inherit_tags = [ "host" ];
        field = [{
          oid = "HOST-RESOURCES-MIB::hrProcessorFrwID";
          is_tag = true;
        }];
      }
    ];
  };

  /* Assemble all configured SNMP inputs for REDDOXX appliances. */
  snmpInputs = lib.optionals deviceCfg.endpoints.self.enable
    (map mkSnmpInput deviceCfg.endpoints.self.agents);

in {
  /* REDDOXX appliance SNMP options. */
  options.senpro.monitoring.telegraf.inputs.snmp.vendors.reddoxx =
    telegrafOptions.mkSnmpV3Options ''
      Whether to enable REDDOXX monitoring via SNMP.
    '';

  config = {
    services.telegraf.extraConfig.inputs.snmp = lib.mkIf snmpCfg.enable snmpInputs;
  };
}
