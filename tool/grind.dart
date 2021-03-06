import 'package:grinder/grinder.dart';

main(final List<String> args) => grind(args);

@Task()
@Depends(test)
build() {
}

@Task()
@Depends(analyze)
test() {
    // new TestRunner().testAsync(files: "test/unit");
    // new TestRunner().testAsync(files: "test/integration");

    // Alle test mit @TestOn("content-shell") im header
    // new TestRunner().test(files: "test/unit",platformSelector: "content-shell");
    // new TestRunner().test(files: "test/integration",platformSelector: "content-shell");
}

@Task()
analyze() {
    final List<String> libs = [
        "lib/stagedive.dart",
        "bin/stagedive.dart"
    ];

    libs.forEach((final String lib) => Analyzer.analyze(lib));
    // Analyzer.analyze("test");
}
@Task()
clean() => defaultClean();
