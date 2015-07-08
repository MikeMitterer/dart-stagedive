part of stagedive;

/// Commandline options
class Options {
    static const APPNAME                    = 'stagedive';

    static const _ARG_HELP                  = 'help';
    static const _ARG_LOGLEVEL              = 'loglevel';
    static const _ARG_SETTINGS              = 'settings';

    static const String _ARG_PROJECT_DIR    = 'projectfolder';
    static const String _ARG_LIST_TEMPLATES = 'list';

    final ArgParser _parser;

    Options() : _parser = Options._createParser();

    ArgResults parse(final List<String> args) {
        Validate.notNull(args);
        return _parser.parse(args);
    }

    void showUsage() {
        print("Usage: $APPNAME [options] <template folder>");
        _parser.usage.split("\n").forEach((final String line) {
            print("    $line");
        });

        print("");
        print("Sample:");
        print("");
        print("    Generate project in example/console:");
        print("        '$APPNAME -p example/console packages/stagedive/_templates/console/'");
        print("");
    }

    // -- private -------------------------------------------------------------

    static ArgParser _createParser() {
        final ArgParser parser = new ArgParser()

            ..addFlag(_ARG_SETTINGS,         abbr: 's', negatable: false, help: "Prints settings")

            ..addFlag(_ARG_HELP,             abbr: 'h', negatable: false, help: "Shows this message")

            ..addFlag(_ARG_LIST_TEMPLATES,   abbr: 'l', negatable: false, help: "List available templates")

            ..addOption(_ARG_PROJECT_DIR,    abbr: 'p', help: "Project folder")

            ..addOption(_ARG_LOGLEVEL,       abbr: 'v', help: "Sets the appropriate loglevel", allowed: ['info', 'debug', 'warning'])

        ;

        return parser;
    }
}
