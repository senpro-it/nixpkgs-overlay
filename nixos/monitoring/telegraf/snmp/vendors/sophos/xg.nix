{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.senpro;
  telegrafOptions = import ../../../options.nix { inherit lib; };
  deviceCfg = cfg.monitoring.telegraf.inputs.snmp.vendors.sophos.xg;
  snmpCfg = cfg.monitoring.telegraf.inputs.snmp;

in {
  options.senpro.monitoring.telegraf.inputs.snmp.vendors.sophos.xg =
    telegrafOptions.mkSnmpV3Options ''
      Whether to enable the Sophos XG/XGS monitoring via SNMP.
    '';

  config = {
    services.telegraf.extraConfig.inputs.snmp = lib.mkIf (snmpCfg.enable && deviceCfg.endpoints.self.enable) (
      map (agent: telegrafOptions.sanitizeToml {
        name = "sophos.xg";
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
          { name = "contact"; oid = "SNMPv2-MIB::sysContact.0"; }
          { name = "description"; oid = "SNMPv2-MIB::sysDescr.0"; }
          { name = "deviceType"; oid = "SFOS-FIREWALL-MIB::sfosDeviceType.0"; }
          { name = "diskCapacity"; oid = "SFOS-FIREWALL-MIB::sfosDiskCapacity.0"; }
          { name = "diskPercentUsage"; oid = "SFOS-FIREWALL-MIB::sfosDiskPercentUsage.0"; }
          { name = "fwVersion"; oid = "SFOS-FIREWALL-MIB::sfosDeviceFWVersion.0"; }
          { name = "host"; oid = "SFOS-FIREWALL-MIB::sfosDeviceName.0"; is_tag = true; }
          { name = "licenseBaseFWStatus"; oid = "SFOS-FIREWALL-MIB::sfosBaseFWLicRegStatus.0"; }
          { name = "licenseBaseFWExpiry"; oid = "SFOS-FIREWALL-MIB::sfosBaseFWLicExpiryDate.0"; }
          { name = "licenseNetProtectionStatus"; oid = "SFOS-FIREWALL-MIB::sfosNetProtectionLicRegStatus.0"; }
          { name = "licenseNetProtectionExpiry"; oid = "SFOS-FIREWALL-MIB::sfosNetProtectionLicExpiryDate.0"; }
          { name = "licenseWebProtectionStatus"; oid = "SFOS-FIREWALL-MIB::sfosWebProtectionLicRegStatus.0"; }
          { name = "licenseWebProtectionExpiry"; oid = "SFOS-FIREWALL-MIB::sfosWebProtectionLicExpiryDate.0"; }
          { name = "licenseMailProtectionStatus"; oid = "SFOS-FIREWALL-MIB::sfosMailProtectionLicRegStatus.0"; }
          { name = "licenseMailProtectionExpiry"; oid = "SFOS-FIREWALL-MIB::sfosMailProtectionLicExpiryDate.0"; }
          { name = "licenseWebServerProtectionStatus"; oid = "SFOS-FIREWALL-MIB::sfosWebServerProtectionLicRegStatus.0"; }
          { name = "licenseWebServerProtectionExpiry"; oid = "SFOS-FIREWALL-MIB::sfosWebServerProtectionLicExpiryDate.0"; }
          { name = "licenseSandstromProtectionStatus"; oid = "SFOS-FIREWALL-MIB::sfosSandstromLicRegStatus.0"; }
          { name = "licenseSandstromProtectionExpiry"; oid = "SFOS-FIREWALL-MIB::sfosSandstromLicExpiryDate.0"; }
          { name = "licenseEnhancedSupportStatus"; oid = "SFOS-FIREWALL-MIB::sfosEnhancedSupportLicRegStatus.0"; }
          { name = "licenseEnhancedSupportExpiry"; oid = "SFOS-FIREWALL-MIB::sfosEnhancedSupportLicExpiryDate.0"; }
          { name = "licenseEnhancedSupportPlusStatus"; oid = "SFOS-FIREWALL-MIB::sfosEnhancedPlusLicRegStatus.0"; }
          { name = "licenseEnhancedSupportPlusExpiry"; oid = "SFOS-FIREWALL-MIB::sfosEnhancedPlusLicExpiryDate.0"; }
          { name = "licenseCentralOrchestrationStatus"; oid = "SFOS-FIREWALL-MIB::sfosCentralOrchestrationLicRegStatus.0"; }
          { name = "licenseCentralOrchestrationExpiry"; oid = "SFOS-FIREWALL-MIB::sfosCentralOrchestrationLicExpiryDate.0"; }
          { name = "memoryCapacity"; oid = "SFOS-FIREWALL-MIB::sfosMemoryCapacity.0"; }
          { name = "memoryPercentUsage"; oid = "SFOS-FIREWALL-MIB::sfosMemoryPercentUsage.0"; }
          { name = "serviceApache"; oid = "SFOS-FIREWALL-MIB::sfosApacheService.0"; }
          { name = "serviceAS"; oid = "SFOS-FIREWALL-MIB::sfosASService.0"; }
          { name = "serviceAV"; oid = "SFOS-FIREWALL-MIB::sfosAVService.0"; }
          { name = "serviceDatabase"; oid = "SFOS-FIREWALL-MIB::sfosDatabaseservice.0"; }
          { name = "serviceDGD"; oid = "SFOS-FIREWALL-MIB::sfosDgdService.0"; }
          { name = "serviceDNS"; oid = "SFOS-FIREWALL-MIB::sfosDNSService.0"; }
          { name = "serviceDRouting"; oid = "SFOS-FIREWALL-MIB::sfosDroutingService.0"; }
          { name = "serviceFTP"; oid = "SFOS-FIREWALL-MIB::sfosFtpService.0"; }
          { name = "serviceGarner"; oid = "SFOS-FIREWALL-MIB::sfosGarnerService.0"; }
          { name = "serviceHA"; oid = "SFOS-FIREWALL-MIB::sfosHAService.0"; }
          { name = "serviceHTTP"; oid = "SFOS-FIREWALL-MIB::sfosHttpService.0"; }
          { name = "serviceIMAP4"; oid = "SFOS-FIREWALL-MIB::sfosImap4Service.0"; }
          { name = "serviceIPS"; oid = "SFOS-FIREWALL-MIB::sfosIPSService.0"; }
          { name = "serviceIPSec"; oid = "SFOS-FIREWALL-MIB::sfosIPSecVpnService.0"; }
          { name = "serviceNetwork"; oid = "SFOS-FIREWALL-MIB::sfosNetworkService.0"; }
          { name = "serviceNTP"; oid = "SFOS-FIREWALL-MIB::sfosNtpService.0"; }
          { name = "servicePOP3"; oid = "SFOS-FIREWALL-MIB::sfosPoP3Service.0"; }
          { name = "serviceSSHd"; oid = "SFOS-FIREWALL-MIB::sfosSSHdService.0"; }
          { name = "serviceSSLVPN"; oid = "SFOS-FIREWALL-MIB::sfosSSLVpnService.0"; }
          { name = "serviceTomcat"; oid = "SFOS-FIREWALL-MIB::sfosTomcatService.0"; }
          { name = "swapCapacity"; oid = "SFOS-FIREWALL-MIB::sfosSwapCapacity.0"; }
          { name = "swapPercentUsage"; oid = "SFOS-FIREWALL-MIB::sfosSwapPercentUsage.0"; }
          { name = "uptime"; oid = "SFOS-FIREWALL-MIB::sfosUpTime.0"; }
        ];
        table = [
          { name = "sophos.xg.ifTable"; oid = "IF-MIB::ifTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
            { oid = "IF-MIB::ifDescr"; is_tag = true; }
          ]; }
          { name = "sophos.xg.ifXTable"; oid = "IF-MIB::ifXTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
            { oid = "IF-MIB::ifName"; is_tag = true; }
          ]; }
          { name = "sophos.xg.ipAddrTable"; oid = "IP-MIB::ipAddrTable"; inherit_tags = [ "host" ]; field = [
            { oid = "IP-MIB::ipAdEntIfIndex"; is_tag = true; }
          ]; }
          { name = "sophos.xg.vpnIpsecTable"; oid = "SFOS-FIREWALL-MIB::sfosIPSecVpnTunnelTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
            { oid = "SFOS-FIREWALL-MIB::sfosIPSecVpnConnName"; is_tag = true; }
            { oid = "SFOS-FIREWALL-MIB::sfosIPSecVpnConnType"; is_tag = true; }
            { oid = "SFOS-FIREWALL-MIB::sfosIPSecVpnActivated"; is_tag = true; }
          ]; }
          { name = "sophos.xg.processorTable"; oid = "HOST-RESOURCES-MIB::hrProcessorTable"; index_as_tag = true; inherit_tags = [ "host" ]; }
        ];
      }) deviceCfg.endpoints.self.agents
    );
  };
}
