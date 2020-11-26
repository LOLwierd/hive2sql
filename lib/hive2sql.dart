library hive2sql;

import 'package:build/build.dart';
import 'package:hive2sql/src/Hive2SqlBuilder.dart';
import 'package:hive2sql/src/Hive2SqlGenerator.dart';
import 'package:source_gen/source_gen.dart';
export 'package:hive2sql/src/annotations.dart';

Builder hive2sqlBuilder(BuilderOptions options) => Hive2SqlBuilder();

Builder hive2sqlGenerator(BuilderOptions options) =>
    SharedPartBuilder([Hive2SqlGenerator()], 'hive2sql');
