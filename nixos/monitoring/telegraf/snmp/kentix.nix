let
  kentixFuncs = {
    ##
    # Returns a list of generated oid/name pairs.
    #
    # @param name:    Name of the sensor prefix
    # @param num:     Amount of sensors to generate
    # @param ext:     Specify object to merge with the generated one
    # @return         A list (aka. array) of oid-name pairs.
    #
    # Note: If you need 0-prefixing, make it part of the name!
    ##
    genSensorListExt = name: num: obj: map (n: {
      oid = "KAM-PRO::${name}${builtins.toString (n + 1)}.0";
      name = "${name}${builtins.toString (n + 1)}";
    } // obj) (builtins.genList (x: x) num);
    ## Same as above, but does not take an additional object.
    genSensorList = name: num: (kentixFuncs.genSensorListExt name num {});

    ## Generate tagged Sensors
    mkMultisensor = num: kentixFuncs.genSensorListExt "sensorname0" num { is_tag = true; };
    ## Generate temperatures
    mkTemperature = num: kentixFuncs.genSensorList "temperature0" num;
    # Generate humidity
    mkHumidity = num: kentixFuncs.genSensorList "humidity0" num;
    # Generate dewpoint
    mkDewpoint = num: kentixFuncs.genSensorList "dewpoint0" num;
    ## Generate alarm pairs
    mkAlarm = num: kentixFuncs.genSensorList "alarm" num;
    ## Generate CO2 pairs
    mkCo2 = num: kentixFuncs.genSensorList "co0" num;
    ## Generate Motion
    mkMotion = num: kentixFuncs.genSensorList "motion0" num;
    # Generate pairs for Digital IN 1
    mkDigiIn1 = num: kentixFuncs.genSensorList "digitalin10" num;
    # Generate pairs for Digital IN 2
    mkDigiIn2 = num: kentixFuncs.genSensorList "digitalin20" num;
    # Generate pairs for Digital OUT 2
    mkDigiOut2 = num: kentixFuncs.genSensorList "digitalout20" num;
    ## Generate Initialization error pairs
    mkInitErrors = num: kentixFuncs.genSensorList "comError0" num;
    # WIP: Force a table.
    /*
    mkSensorTable' = g: [{
      name_override = "kentix.sensors.group${g}.sensorname";
      oid = "KAM-PRO::sensorname${g}";
      is_tag = true;
    }] ++ (map(key: {
      name_override = "kentix.sensors.group${g}.${key}";
      oid = "KAM-PRO::${key}${g}";
    }) [
      "temperature", "humidity", "dewpoint",
      "co2", "motion",
      "digitalin1", "digitalin2",
      "digitalout2",
      "comError"
    ]);
    mkSensorTable groups: map(g: (mkSensorTable' g) groups);
    // i.e. mkSensorTable ["01", "02"]
    */
  };

in kentixFuncs
