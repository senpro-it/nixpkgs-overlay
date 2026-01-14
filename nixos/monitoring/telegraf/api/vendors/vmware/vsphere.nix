{ config, lib, mkInputConfig, telegrafOptions, ... }:

with lib;

let
  /* vSphere API config subtree. */
  vsphereCfg = config.senpro.monitoring.telegraf.inputs.api.vendors.vmware.vsphere;
  /* Default realtime collection settings. */
  vsphereRealtimeDefaults = {
    interval = "60s";
    name_prefix = "vmware.";
    host_metric_include = [
      "cpu.corecount.contention.average"
      "cpu.usage.average"
      "cpu.reservedCapacity.average"
      "cpu.usagemhz.minimum"
      "cpu.usagemhz.maximum"
      "cpu.usage.minimum"
      "cpu.usage.maximum"
      "cpu.capacity.provisioned.average"
      "cpu.capacity.usage.average"
      "cpu.capacity.demand.average"
      "cpu.capacity.contention.average"
      "cpu.corecount.provisioned.average"
      "cpu.corecount.usage.average"
      "cpu.usagemhz.average"
      "disk.throughput.contention.average"
      "disk.throughput.usage.average"
      "mem.decompressionRate.average"
      "mem.granted.average"
      "mem.active.average"
      "mem.shared.average"
      "mem.zero.average"
      "mem.swapused.average"
      "mem.vmmemctl.average"
      "mem.compressed.average"
      "mem.compressionRate.average"
      "mem.reservedCapacity.average"
      "mem.capacity.provisioned.average"
      "mem.capacity.usable.average"
      "mem.capacity.usage.average"
      "mem.capacity.entitlement.average"
      "mem.capacity.contention.average"
      "mem.usage.minimum"
      "mem.overhead.minimum"
      "mem.consumed.minimum"
      "mem.granted.minimum"
      "mem.active.minimum"
      "mem.shared.minimum"
      "mem.zero.minimum"
      "mem.swapused.minimum"
      "mem.consumed.average"
      "mem.usage.maximum"
      "mem.overhead.maximum"
      "mem.consumed.maximum"
      "mem.granted.maximum"
      "mem.overhead.average"
      "mem.shared.maximum"
      "mem.zero.maximum"
      "mem.swapused.maximum"
      "mem.vmmemctl.maximum"
      "mem.usage.average"
      "mem.active.maximum"
      "mem.vmmemctl.minimum"
      "net.throughput.contention.summation"
      "net.throughput.usage.average"
      "net.throughput.usable.average"
      "net.throughput.provisioned.average"
      "power.power.average"
      "power.powerCap.average"
      "power.energy.summation"
      "vmop.numShutdownGuest.latest"
      "vmop.numPoweroff.latest"
      "vmop.numSuspend.latest"
      "vmop.numReset.latest"
      "vmop.numRebootGuest.latest"
      "vmop.numStandbyGuest.latest"
      "vmop.numPoweron.latest"
      "vmop.numCreate.latest"
      "vmop.numDestroy.latest"
      "vmop.numRegister.latest"
      "vmop.numUnregister.latest"
      "vmop.numReconfigure.latest"
      "vmop.numClone.latest"
      "vmop.numDeploy.latest"
      "vmop.numChangeHost.latest"
      "vmop.numChangeDS.latest"
      "vmop.numChangeHostDS.latest"
      "vmop.numVMotion.latest"
      "vmop.numSVMotion.latest"
      "vmop.numXVMotion.latest"
    ];
    vm_metric_include = [
      "cpu.demandEntitlementRatio.latest"
      "cpu.usage.average"
      "cpu.ready.summation"
      "cpu.run.summation"
      "cpu.system.summation"
      "cpu.swapwait.summation"
      "cpu.costop.summation"
      "cpu.demand.average"
      "cpu.readiness.average"
      "cpu.maxlimited.summation"
      "cpu.wait.summation"
      "cpu.usagemhz.average"
      "cpu.latency.average"
      "cpu.used.summation"
      "cpu.overlap.summation"
      "cpu.idle.summation"
      "cpu.entitlement.latest"
      "datastore.maxTotalLatency.latest"
      "disk.usage.average"
      "disk.read.average"
      "disk.write.average"
      "disk.maxTotalLatency.latest"
      "mem.llSwapUsed.average"
      "mem.swapin.average"
      "mem.vmmemctltarget.average"
      "mem.activewrite.average"
      "mem.overhead.average"
      "mem.vmmemctl.average"
      "mem.zero.average"
      "mem.swapoutRate.average"
      "mem.active.average"
      "mem.llSwapOutRate.average"
      "mem.swapout.average"
      "mem.llSwapInRate.average"
      "mem.swapinRate.average"
      "mem.granted.average"
      "mem.latency.average"
      "mem.overheadMax.average"
      "mem.swapped.average"
      "mem.compressionRate.average"
      "mem.swaptarget.average"
      "mem.shared.average"
      "mem.zipSaved.latest"
      "mem.overheadTouched.average"
      "mem.zipped.latest"
      "mem.consumed.average"
      "mem.entitlement.average"
      "mem.usage.average"
      "mem.decompressionRate.average"
      "mem.compressed.average"
      "net.multicastRx.summation"
      "net.transmitted.average"
      "net.received.average"
      "net.usage.average"
      "net.broadcastTx.summation"
      "net.broadcastRx.summation"
      "net.packetsRx.summation"
      "net.pnicBytesRx.average"
      "net.multicastTx.summation"
      "net.bytesTx.average"
      "net.bytesRx.average"
      "net.droppedRx.summation"
      "net.pnicBytesTx.average"
      "net.droppedTx.summation"
      "net.packetsTx.summation"
      "power.power.average"
      "power.energy.summation"
      "rescpu.runpk1.latest"
      "rescpu.runpk15.latest"
      "rescpu.maxLimited5.latest"
      "rescpu.actpk5.latest"
      "rescpu.samplePeriod.latest"
      "rescpu.runav1.latest"
      "rescpu.runav15.latest"
      "rescpu.sampleCount.latest"
      "rescpu.actpk1.latest"
      "rescpu.runpk5.latest"
      "rescpu.runav5.latest"
      "rescpu.actav15.latest"
      "rescpu.actav1.latest"
      "rescpu.actpk15.latest"
      "rescpu.actav5.latest"
      "rescpu.maxLimited1.latest"
      "rescpu.maxLimited15.latest"
      "sys.osUptime.latest"
      "sys.uptime.latest"
      "sys.heartbeat.latest"
      "virtualDisk.write.average"
      "virtualDisk.read.average"
    ];
    datastore_metric_exclude = [ "*" ];
    cluster_metric_exclude = [ "*" ];
    datacenter_metric_exclude = [ "*" ];
    collect_concurrency = 4;
    discover_concurrency = 4;
    insecure_skip_verify = true;
  };
  /* Default historical collection settings. */
  vsphereHistoricalDefaults = {
    interval = "300s";
    name_prefix = "vmware.";
    datastore_metric_include = [
      "datastore.numberReadAveraged.average"
      "datastore.throughput.contention.average"
      "datastore.throughput.usage.average"
      "datastore.write.average"
      "datastore.read.average"
      "datastore.numberWriteAveraged.average"
      "disk.used.latest"
      "disk.provisioned.latest"
      "disk.capacity.latest"
      "disk.capacity.contention.average"
      "disk.capacity.provisioned.average"
      "disk.capacity.usage.average"
    ];
    cluster_metric_include = [
      "cpu.corecount.contention.average"
      "cpu.usage.average"
      "cpu.reservedCapacity.average"
      "cpu.usagemhz.minimum"
      "cpu.usagemhz.maximum"
      "cpu.usage.minimum"
      "cpu.usage.maximum"
      "cpu.capacity.provisioned.average"
      "cpu.capacity.usage.average"
      "cpu.capacity.demand.average"
      "cpu.capacity.contention.average"
      "cpu.corecount.provisioned.average"
      "cpu.corecount.usage.average"
      "cpu.usagemhz.average"
      "disk.throughput.contention.average"
      "disk.throughput.usage.average"
      "mem.decompressionRate.average"
      "mem.granted.average"
      "mem.active.average"
      "mem.shared.average"
      "mem.zero.average"
      "mem.swapused.average"
      "mem.vmmemctl.average"
      "mem.compressed.average"
      "mem.compressionRate.average"
      "mem.reservedCapacity.average"
      "mem.capacity.provisioned.average"
      "mem.capacity.usable.average"
      "mem.capacity.usage.average"
      "mem.capacity.entitlement.average"
      "mem.capacity.contention.average"
      "mem.usage.minimum"
      "mem.overhead.minimum"
      "mem.consumed.minimum"
      "mem.granted.minimum"
      "mem.active.minimum"
      "mem.shared.minimum"
      "mem.zero.minimum"
      "mem.swapused.minimum"
      "mem.consumed.average"
      "mem.usage.maximum"
      "mem.overhead.maximum"
      "mem.consumed.maximum"
      "mem.granted.maximum"
      "mem.overhead.average"
      "mem.shared.maximum"
      "mem.zero.maximum"
      "mem.swapused.maximum"
      "mem.vmmemctl.maximum"
      "mem.usage.average"
      "mem.active.maximum"
      "mem.vmmemctl.minimum"
      "net.throughput.contention.summation"
      "net.throughput.usage.average"
      "net.throughput.usable.average"
      "net.throughput.provisioned.average"
      "power.power.average"
      "power.powerCap.average"
      "power.energy.summation"
      "vmop.numShutdownGuest.latest"
      "vmop.numPoweroff.latest"
      "vmop.numSuspend.latest"
      "vmop.numReset.latest"
      "vmop.numRebootGuest.latest"
      "vmop.numStandbyGuest.latest"
      "vmop.numPoweron.latest"
      "vmop.numCreate.latest"
      "vmop.numDestroy.latest"
      "vmop.numRegister.latest"
      "vmop.numUnregister.latest"
      "vmop.numReconfigure.latest"
      "vmop.numClone.latest"
      "vmop.numDeploy.latest"
      "vmop.numChangeHost.latest"
      "vmop.numChangeDS.latest"
      "vmop.numChangeHostDS.latest"
      "vmop.numVMotion.latest"
      "vmop.numSVMotion.latest"
      "vmop.numXVMotion.latest"
    ];
    host_metric_exclude = [ "*" ];
    vm_metric_exclude = [ "*" ];
    collect_concurrency = 4;
    discover_concurrency = 4;
    insecure_skip_verify = true;
  };
  /* Merge realtime defaults with user overrides. */
  vsphereRealtimeSettings = vsphereRealtimeDefaults // vsphereCfg.realtime;
  /* Merge historical defaults with user overrides. */
  vsphereHistoricalSettings = vsphereHistoricalDefaults // vsphereCfg.historical;
  /* Build the Telegraf vsphere input configuration.
     @param settings: Merged settings for a vsphere input.
     @return Sanitized settings with credentials injected.
  */
  mkVsphereConfig = settings: mkInputConfig (settings // {
    vcenters = vsphereCfg.sdk.endpoints;
    username = vsphereCfg.sdk.username;
    password = vsphereCfg.sdk.password;
  });
  /* Sanitized Telegraf config for realtime collection. */
  vsphereRealtimeConfig = mkVsphereConfig vsphereRealtimeSettings;
  /* Sanitized Telegraf config for historical collection. */
  vsphereHistoricalConfig = mkVsphereConfig vsphereHistoricalSettings;

in {
  /* vSphere API input options. */
  options.senpro.monitoring.telegraf.inputs.api.vendors.vmware.vsphere = {
    enable = mkEnableOption ''
      Whether to enable the vSphere monitoring.
    '';
    sdk = {
      username = mkOption {
        type = types.str;
        example = "Administrator@vsphere.local";
        description = ''
          Username of the login user for vSphere.
        '';
      };
      password = mkOption {
        type = types.str;
        example = "C8TK9UHEKLSv7BcJPKpEu5ij8de3HEHa";
        description = ''
          Password of the login user for vSphere.
        '';
      };
      endpoints = mkOption {
        type = types.listOf types.str;
        example = literalExpression ''
          [ "https://vcenter.local/sdk" ]
        '';
        description = ''
          vSphere instances which should be monitored. Note the `/sdk` at the end, which is essentially to connect to the right endpoint.
        '';
      };
    };
    realtime = telegrafOptions.mkInputSettingsOption telegrafOptions.vsphereInput
      "Options for the vSphere realtime input.";
    historical = telegrafOptions.mkInputSettingsOption telegrafOptions.vsphereInput
      "Options for the vSphere historical input.";
  };

  config = {
    services.telegraf.extraConfig.inputs.vsphere = lib.mkIf vsphereCfg.enable [
      vsphereRealtimeConfig
      vsphereHistoricalConfig
    ];
  };
}
