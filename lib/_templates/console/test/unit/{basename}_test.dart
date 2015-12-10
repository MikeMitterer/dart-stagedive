// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library <%= basename %>.test;

import 'package:test/test.dart';
import 'package:<%= basename %>/<%= basename %>.dart';

main() {
  group('A group of tests', () {

    setUp(() { });

    test('First Test', () {
      expect(true, isTrue);
    });
  });
}
