part of stagedive;

/**
 * Defines default-configurations.
 * Most of these configs can be overwritten by commandline args.
 */
class Config {
    final Logger _logger = new Logger("stagedive.Config");

    static const String _CONFIG_FOLDER     = ".stagedive";
    static const String _MANIFEST          = "manifest";

    final ArgResults _argResults;
    final Map<String,dynamic> _settings = new Map<String,dynamic>();

    Config(this._argResults) {

        _settings[Options._ARG_LOGLEVEL]            = 'info';

        _settings[Options._ARG_NEW_PROJECT_DIR]     = '';
        _settings[Options._ARG_TEMPLATE_PROJECT]    = '';
        _settings[Options._ARG_TEMPLATE]            = '';
        _settings[Options._ARG_STRIP_EXTENSION]     = '';

        _settings[Config._MANIFEST]                 = 'manifest.yaml';

        _overwriteSettingsWithConfigFile();
        _overwriteSettingsWithArgResults();
    }

    String get configfolder => _CONFIG_FOLDER;

    String get configfile => "config.yaml";

    String get loglevel => _settings[Options._ARG_LOGLEVEL];

    String get newprojectdir => _settings[Options._ARG_NEW_PROJECT_DIR];
    String get templateproject => _settings[Options._ARG_TEMPLATE_PROJECT];
    String get template => _settings[Options._ARG_TEMPLATE];

    /// Returns the specified extension and makes sure that the extension starts with a dot
    String get strip_extension {
        final String extension = _settings[Options._ARG_STRIP_EXTENSION];
        if(extension.isEmpty) { return extension; }
        return extension.startsWith(".") ? extension : ".${extension}";
    }

    String get manifestfile => _settings[Config._MANIFEST];

    List<String> get dirstoscan => _argResults.rest;

    Map<String,String> get settings {
        final Map<String,String> settings = new Map<String,String>();

        settings["loglevel"]                                = loglevel;

        settings["Config folder"]                           = configfolder;
        settings["Config file"]                             = configfile;

        settings["New project folder"]                      = newprojectdir.isNotEmpty ? newprojectdir : "<not set>";
        settings["Template project"]                        = templateproject.isNotEmpty ? templateproject : "<not set>";
        settings["Templatename"]                            = template.isNotEmpty ? template : "<not set>";

        settings["Strip this extension"]                    = strip_extension.isNotEmpty ? strip_extension : "<not set>";

        settings["Manifest file"]                           = manifestfile;


        if(dirstoscan.length > 0) {
            settings["Template location"]                   = dirstoscan.join(", ");
        }

        return settings;
    }


    void printSettings() {

        int getMaxKeyLength() {
            int length = 0;
            settings.keys.forEach((final String key) => length = max(length,key.length));
            return length;
        }

        final int maxKeyLeght = getMaxKeyLength();

        String prepareKey(final String key) {
            return "${key[0].toUpperCase()}${key.substring(1)}:".padRight(maxKeyLeght + 1);
        }

        print("Settings:");
        settings.forEach((final String key,final String value) {
            print("    ${prepareKey(key)} $value");
        });
    }

    // -- private -------------------------------------------------------------

    void _overwriteSettingsWithArgResults() {

        if(_argResults.wasParsed(Options._ARG_LOGLEVEL)) {
            _settings[Options._ARG_LOGLEVEL] = _argResults[Options._ARG_LOGLEVEL];
        }

        if(_argResults.wasParsed(Options._ARG_NEW_PROJECT_DIR)) {
            _settings[Options._ARG_NEW_PROJECT_DIR] = _argResults[Options._ARG_NEW_PROJECT_DIR];
        }

        if(_argResults.wasParsed(Options._ARG_TEMPLATE_PROJECT)) {
            _settings[Options._ARG_TEMPLATE_PROJECT] = _argResults[Options._ARG_TEMPLATE_PROJECT];
        }

        if(_argResults.wasParsed(Options._ARG_TEMPLATE)) {
            _settings[Options._ARG_TEMPLATE] = _argResults[Options._ARG_TEMPLATE];
        }

        if (_argResults.wasParsed(Options._ARG_STRIP_EXTENSION)) {
            _settings[Options._ARG_STRIP_EXTENSION] = _argResults[Options._ARG_STRIP_EXTENSION];
        }
    }

    void _overwriteSettingsWithConfigFile() {
        final File file = new File("${configfolder}${path.separator}${configfile}");
        if(!file.existsSync()) {
            return;
        }
        final yaml.YamlMap map = yaml.loadYaml(file.readAsStringSync());
        _settings.keys.forEach((final String key) {
            if(map != null && map.containsKey(key)) {
                _settings[key] = map[key];
                //print("Found $key in $configfile: ${map[key]}");
            }
        });
    }
}