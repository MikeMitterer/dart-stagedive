part of stagedive;

class _TemplateInfo {
    final String package;
    final String version;
    final String templatePath;

    _TemplateInfo(this.package, this.version, this.templatePath);

    String get basename => path.basename(templatePath);
}

class _Manifest {
    /// Field for Template-Name in Manifest
    static const String TEMPLATENAME = "templatename";

    /// Field to determine if this template is private (not available if using pub-cache)
    static const String PRIVATE_TEMPLATE = "keeptemplateprivate";

}
class Application {
    final Logger _logger = new Logger("stagedive.Application");

    /// If using config.yaml for additional packages - this is the default package-name for such packages
    static const String _LOCAL_PACKAGE_NAME = "local";

    /// If using config.yaml we have no version - use this instead
    static const String _LOCAL_PACKAGE_VERSION = "<not defined>";

    /// Commandline options
    final Options options;

    Application() : options = new Options();

    void run(List<String> args) {
        try {
            final ArgResults argResults = options.parse(args);
            final Config config = new Config(argResults);

            _configLogging(config.loglevel);

            if (argResults.wasParsed(Options._ARG_HELP) || (config.dirstoscan.length == 0 && args.length == 0)) {
                options.showUsage();
                return;
            }

            if (argResults.wasParsed(Options._ARG_SETTINGS)) {
                config.printSettings();
                return;
            }

            if (argResults.wasParsed(Options._ARG_LIST_TEMPLATES)) {
                _listTemplates(config);
                return;
            }

            bool foundOptionToWorkWith = false;

            if (config.newprojectdir.isNotEmpty && config.templateproject.isNotEmpty && config.template.isNotEmpty) {
                foundOptionToWorkWith = true;
                _generateTemplate(config);
            }

            if (!foundOptionToWorkWith) {
                options.showUsage();
            }
        }

        on FormatException
        catch (error) {
            _logger.shout(error);
            options.showUsage();
        }
    }


    // -- private -------------------------------------------------------------

    void _listTemplates(final Config config) {
        Validate.notNull(config);

        final List<_TemplateInfo> templateInfos = _getTemplateInfos(config);

        templateInfos.forEach((final _TemplateInfo templateinfo) {
            final File manifest = new File("${templateinfo.templatePath}${path.separator}manifest.yaml");
            if(manifest.existsSync()) {
                final yaml.YamlMap map = yaml.loadYaml(manifest.readAsStringSync());

                final String indention = config.loglevel == "debug" ? "    " : "";
                final String name = map[_Manifest.TEMPLATENAME];
                final String sampleName = ("'${name}'").padRight(25);
                _logger.info("${indention}${sampleName} Package: ${templateinfo.package.padRight(15)}"
                                                        "Template name: ${templateinfo.basename.padRight(15)}"
                                                        "Version: ${templateinfo.version}");
            }
        });
    }

    void _generateTemplate(final Config config) {
        Validate.notNull(config);

        final List<_TemplateInfo> templateInfos = _getTemplateInfos(config);

        _TemplateInfo templateinfo;
        try {

            templateinfo = templateInfos.firstWhere( (final _TemplateInfo check) {
                //_logger.info("${check.package.name},${check.basename} - ${config.templateproject},${config.template}");
                return check.package == config.templateproject && check.basename == config.template;
            });

        } on Error {
            _logger.shout("Could not find a Template for ${config.templateproject}${path.separator}${config.template}");
            return;
        }

        final String targetFolder = config.newprojectdir;

        final Directory dirTemplate = new Directory(templateinfo.templatePath.replaceFirst(new RegExp("${path.separator}\$"), ""));
        if (!dirTemplate.existsSync()) {
            _logger.shout("${dirTemplate.path} does not exist!");
            return;
        }

        final File manifest = new File("${dirTemplate.path}${path.separator}manifest.yaml");
        if (!manifest.existsSync()) {
            _logger.shout("Could not find a manifest.yaml in ${dirTemplate.path}");
        }

        if (targetFolder.isEmpty) {
            _logger.shout("Please specify your target folder (option -d)");
            return;
        }

        // e.g. example/sample1
        final Directory dirTargetBase = new Directory(targetFolder.replaceFirst(new RegExp("${path.separator}\$"), ""));
        if (!dirTargetBase.existsSync()) {
            dirTargetBase.createSync(recursive: true);
        }

        final List<Setting> settings = new List<Setting>();
        final String basename = path.basename(dirTargetBase.path);

        settings.add(new Setting("basename",basename));
        settings.addAll((new SettingsFromManifest(manifest)).settings);

        Setting name;
        try {
            name = settings.firstWhere((final Setting setting) => setting.key == _Manifest.TEMPLATENAME);
        } on Error {
            _logger.shout("Invalid manifest-file. (No name specified!)");
            return;
        }

        final List<Question> questions = (new QuestionsFromManifest(manifest)).questions;
        final Prompter prompter = new Prompter();

        try {
            prompter.ask(questions);

        } on ArgumentError catch(e) {
            _logger.shout(e.message);
            return;
        }

        settings.addAll(prompter.settings);

        _logger.fine("Source-BaseFolder ${dirTemplate.path}");
        _logger.fine("Target-BaseFolder ${dirTargetBase.path}");


        dirTemplate.listSync(recursive: true)
            // exclude manifest
            .where((final FileSystemEntity entity) => !entity.path.endsWith("${path.separator}manifest.yaml"))
                .forEach((final FileSystemEntity entity) {

                    final String entityPath = entity.path.replaceFirst("${dirTemplate.path}${path.separator}", "");
                    //_logger.info("EntityPath: ${entityPath} (Orig: ${entity.path})");

                    if (FileSystemEntity.isDirectorySync(entity.path)) {
                        final Directory dirTarget = new Directory("${dirTargetBase.path}${path.separator}$entityPath");
                        //_logger.info("DirTarget: ${dirTarget.path}");

                        if (!dirTarget.existsSync()) {
                            dirTarget.createSync(recursive: true);
                            //_logger.info("${dirTarget.path} created...");
                        }
                    }
                    else {
                        final File src = new File(entity.path);
                        final String targetFilename = _setVarInTargetFilename(settings,"${dirTargetBase.path}${path.separator}${entityPath}");
                        final File target = new File(targetFilename);

                        _logger.fine("Copy: ${src.path} -> ${target.path}");

                        try {
                            String contents = src.readAsStringSync();

                            settings.forEach((final Setting setting) {
                                contents = contents.replaceAll(new RegExp("<%= ${setting.key} %>",multiLine: true,caseSensitive: false),setting.value);
                            });

                            target.writeAsStringSync(contents);

                        } on FileSystemException {
                            // OK - if readAsString does not work - just copy it!
                            src.copySync(target.path);
                        }
                    }
        });

        _logger.info("'${name.value}' created! (${dirTargetBase.path})");
    }

    void _configLogging(final String loglevel) {
        Validate.notBlank(loglevel);

        hierarchicalLoggingEnabled = false; // set this to true - its part of Logging SDK

        // now control the logging.
        // Turn off all logging first
        switch (loglevel) {
            case "fine":
            case "debug":
                Logger.root.level = Level.FINE;
                break;

            case "warning":
                Logger.root.level = Level.SEVERE;
                break;

            default:
                Logger.root.level = Level.INFO;
        }

        Logger.root.onRecord.listen(new LogPrintHandler(messageFormat: "%m"));
    }

    String _setVarInTargetFilename(final List<Setting> settings, String filename) {
        settings.forEach((final Setting setting) {
            if(filename.indexOf("{${setting.key}") != -1) {
                filename = filename.replaceAll("{${setting.key}}",setting.value);
            }
        });

        return filename;
    }

    List<_TemplateInfo> _getTemplateInfos(final Config config) {
        final List<_TemplateInfo> templates = new List<_TemplateInfo>();

        final PubCache cache = new PubCache();
        _logger.fine(PubCache.getSystemCacheLocation().absolute);

        void _scan(final String packagename,final String packageversion, final Directory dirTemplates) {
            if(!dirTemplates.existsSync()) {
                _logger.shout("${dirTemplates.path} does not exists!");
                return;
            }

            dirTemplates.listSync()
            .where((final FileSystemEntity entity) => FileSystemEntity.isDirectorySync(entity.path))
            .forEach((final FileSystemEntity entity) {

                final File manifest = new File("${entity.path}${path.separator}manifest.yaml");
                if(manifest.existsSync()) {
                    final yaml.YamlMap map = yaml.loadYaml(manifest.readAsStringSync());

                    final String name = map[_Manifest.TEMPLATENAME];

                    // Add it only if TEMPLATENAME (templatename) is available
                    if(name != null) {
                        final bool isPrivate = map[_Manifest.PRIVATE_TEMPLATE] != null && map[_Manifest.PRIVATE_TEMPLATE] == true;

                        // final String sampleName = ("'${name}'").padRight(30);
                        //_logger.info("${sampleName} - Package: ${package.name}, Version: ${package.version}, Path: ${entity.absolute.path}");

                        if(isPrivate == false || packagename == _LOCAL_PACKAGE_NAME) {
                            templates.add(new _TemplateInfo(packagename,packageversion.toString(),entity.path));
                        }
                    }
                }
            });
        }

        String packageName = "";
        cache.getPackageRefs().forEach((final PackageRef ref) {
            if(packageName != ref.name) {
                packageName = ref.name;
                final PackageRef latest = cache.getLatestVersion(packageName);
                final Package package = latest.resolve();
                final Directory dirTemplates = new Directory("${package.location.absolute.path}${path.separator}lib${path.separator}${path.separator}_templates");

                _logger.fine("Scanning ${package.location.absolute.path}...");
                if(dirTemplates.existsSync()) {
                    _scan(package.name,package.version.toString(),dirTemplates);
                }
            }
        });

        final File conf = new File("${config.configfolder}${path.separator}${config.configfile}");
        if(conf.existsSync()) {
            final yaml.YamlMap map = yaml.loadYaml(conf.readAsStringSync());
            if(map["templatefolder"] != null /*&& path.basename(map["templatefolder"]) == "_templates"*/) {
                final List<String> folders = new List<String>();
                if(map["templatefolder"] is String) {

                    folders.add(map["templatefolder"]);

                } else if(map["templatefolder"] is yaml.YamlList) {

                    final yaml.YamlList list = map["templatefolder"];
                    list.forEach((final element) => folders.add(element.toString()));
                }
                folders.forEach((final String foldername) {
                    final Directory dirTemplates = new Directory(foldername);
                    _scan(_LOCAL_PACKAGE_NAME,_LOCAL_PACKAGE_VERSION,dirTemplates);
                });
            }
        }
        return templates;
    }
}
