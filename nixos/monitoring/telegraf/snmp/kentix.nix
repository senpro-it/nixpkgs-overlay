let
  kentixFuncs = {
    /* Returns a list of generated oid/name pairs.
       @param name: Name of the sensor prefix.
       @param num: Amount of sensors to generate.
       @param obj: Attribute set merged into each generated entry.
       @return List of oid/name pairs.
       Note: If you need 0-prefixing, make it part of the name.
    */
    genSensorListExt = name: num: obj: map (n: {
      oid = "KAM-PRO::${name}${builtins.toString (n + 1)}.0";
      name = "${name}${builtins.toString (n + 1)}";
    } // obj) (builtins.genList (x: x) num);
    /* Generate oid/name pairs without extra attributes.
       @param name: Name of the sensor prefix.
       @param num: Amount of sensors to generate.
       @return List of oid/name pairs.
    */
    genSensorList = name: num: (kentixFuncs.genSensorListExt name num {});

    /* Generate tagged multisensor identifiers.
       @param num: Amount of multisensors.
       @return List of tagged sensor entries.
    */
    mkMultisensor = num: kentixFuncs.genSensorListExt "sensorname0" num { is_tag = true; };
    /* Generate temperature sensor entries.
       @param num: Amount of temperature sensors.
       @return List of temperature entries.
    */
    mkTemperature = num: kentixFuncs.genSensorList "temperature0" num;
    /* Generate humidity sensor entries.
       @param num: Amount of humidity sensors.
       @return List of humidity entries.
    */
    mkHumidity = num: kentixFuncs.genSensorList "humidity0" num;
    /* Generate dewpoint sensor entries.
       @param num: Amount of dewpoint sensors.
       @return List of dewpoint entries.
    */
    mkDewpoint = num: kentixFuncs.genSensorList "dewpoint0" num;
    /* Generate alarm sensor entries.
       @param num: Amount of alarm sensors.
       @return List of alarm entries.
    */
    mkAlarm = num: kentixFuncs.genSensorList "alarm" num;
    /* Generate CO2 sensor entries.
       @param num: Amount of CO2 sensors.
       @return List of CO2 entries.
    */
    mkCo2 = num: kentixFuncs.genSensorList "co0" num;
    /* Generate motion sensor entries.
       @param num: Amount of motion sensors.
       @return List of motion entries.
    */
    mkMotion = num: kentixFuncs.genSensorList "motion0" num;
    /* Generate digital input 1 entries.
       @param num: Amount of digital input 1 sensors.
       @return List of digital input 1 entries.
    */
    mkDigiIn1 = num: kentixFuncs.genSensorList "digitalin10" num;
    /* Generate digital input 2 entries.
       @param num: Amount of digital input 2 sensors.
       @return List of digital input 2 entries.
    */
    mkDigiIn2 = num: kentixFuncs.genSensorList "digitalin20" num;
    /* Generate digital output 2 entries.
       @param num: Amount of digital output 2 sensors.
       @return List of digital output 2 entries.
    */
    mkDigiOut2 = num: kentixFuncs.genSensorList "digitalout20" num;
    /* Generate initialization error entries.
       @param num: Amount of initialization error sensors.
       @return List of initialization error entries.
    */
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
