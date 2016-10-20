part of stagedive;

/// Commandline options
class Options {
    static const APPNAME                      = 'stagedive';

    static const _ARG_EXTENSION               = 'extension';
    static const _ARG_HELP                    = 'help';
    static const _ARG_LOGLEVEL                = 'loglevel';
    static const _ARG_SETTINGS                = 'settings';

    static const String _ARG_NEW_PROJECT_DIR  = 'newprojectdir';
    static const String _ARG_TEMPLATE_PROJECT = 'templateproject';
    static const String _ARG_TEMPLATE         = 'template';

    static const String _ARG_LIST_TEMPLATES   = 'list';
    //static const String _ARG_           //

    final ArgParser _parser;

    Options() : _parser = Options._createParser();

    ArgResults parse(final List<String> args) {
        Validate.notNull(args);
        return _parser.parse(args);
    }

    void showUsage() {
        print("Usage: $APPNAME -n <new project folder> -p <template project> -t <template name>");
        _parser.usage.split("\n").forEach((final String line) {
            print("    $line");
        });

        print("");
        print("Sample:");
        print("");
        print("    Generate project in example/console:");
        print("        '$APPNAME -n example/console -p stagedive -t console'");
        print("");
    }

    // -- private -------------------------------------------------------------

    static ArgParser _createParser() {
        final ArgParser parser = new ArgParser()

            ..addFlag(_ARG_SETTINGS,             abbr: 's', negatable: false, help: "Prints settings")

            ..addFlag(_ARG_HELP,                 abbr: 'h', negatable: false, help: "Shows this message")

            ..addFlag(_ARG_LIST_TEMPLATES,       abbr: 'l', negatable: false, help: "List available templates")

            ..addOption(_ARG_NEW_PROJECT_DIR,    abbr: 'n', help: "New project folder")

            ..addOption(_ARG_TEMPLATE_PROJECT,   abbr: 'p', help: "Template project (e.g. stagedive)")

            ..addOption(_ARG_TEMPLATE,           abbr: 't', help: "Template name (e.g. console)")

            ..addOption(_ARG_LOGLEVEL,           abbr: 'v', help: "Sets the appropriate loglevel", allowed: ['info', 'debug', 'warning'])

            ..addOption(_ARG_EXTENSION,          abbr: 'e', help: "Template extension, stripped during copy", defaultsTo: '')

        ;

        return parser;
    }
}
