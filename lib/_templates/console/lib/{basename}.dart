// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// The dasic library.
///
/// This is an awesome library. More dartdocs go here.
library <%= basename %>;

import 'dart:io';
import 'dart:math';

import 'package:logging/logging.dart';
import 'package:logging_handlers/logging_handlers_shared.dart';

import 'package:validate/validate.dart';
import "package:yaml/yaml.dart" as yaml;

import 'package:args/args.dart';

part "cmdline/Application.dart";
part "cmdline/Config.dart";
part "cmdline/Options.dart";