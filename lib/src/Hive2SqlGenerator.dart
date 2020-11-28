import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:hive2sql_annotations/annotations.dart';
import 'package:source_gen/source_gen.dart';

final _hiveFieldChecker = const TypeChecker.fromRuntime(Hive2SQLField);
final _nullableChecker = const TypeChecker.fromRuntime(NullableSQL);
final _primaryChecker = const TypeChecker.fromRuntime(PK);
final getFileName = RegExp(r'.*\/(.*).dart');
final getParameterType = RegExp(r'.*\((.*) .*');

class Hive2SqlGenerator extends GeneratorForAnnotation<Hive2SQLType> {
  @override
  FutureOr<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    return _generateWidgetSource(
        element as ClassElement, annotation, buildStep);
  }

  Future<String> _generateWidgetSource(ClassElement element,
      ConstantReader annotation, BuildStep buildStep) async {
    // print(getParameterType
    // .firstMatch(element.getNamedConstructor('fromJson').toString())
    // .group(1));
    var fileName = getFileName.firstMatch(buildStep.inputId.path).group(1);
    var parameterType = getParameterType
            .firstMatch(element.getNamedConstructor('fromJson').toString())
            ?.group(1) ??
        'var';
    var tableName = fileName.toString();
    tableName =
        tableName.replaceFirst(tableName[0], tableName[0].toLowerCase()) + 's';
    var fields =
        "String createTable = '''CREATE TABLE IF NOT EXISTS ${tableName}(\n";

    var toMap = _generateToMap(element.fields, fileName);

    for (var f in element.fields) {
      var isPrimaryKey = false;
      if (_hiveFieldChecker.hasAnnotationOfExact(f)) {
        var field;
        if (_primaryChecker.hasAnnotationOfExact(f)) {
          isPrimaryKey = true;
        }
        switch (f.declaration.toString().split(' ')[0]) {
          case 'String':
            {
              if (isPrimaryKey) {
                field =
                    "${f.declaration.toString().split(" ")[1]} TEXT PRIMARY KEY,\n";
                break;
              }
              _nullableChecker.hasAnnotationOfExact(f)
                  ? field = "${f.declaration.toString().split(" ")[1]} TEXT,\n"
                  : field =
                      "${f.declaration.toString().split(" ")[1]} TEXT NOT NULL,\n";
            }
            break;
          case 'int':
            {
              if (isPrimaryKey) {
                field =
                    "${f.declaration.toString().split(" ")[1]} INTEGER PRIMARY KEY,\n";
                break;
              }
              _nullableChecker.hasAnnotationOfExact(f)
                  ? field =
                      "${f.declaration.toString().split(" ")[1]} INTEGER,\n"
                  : field =
                      "${f.declaration.toString().split(" ")[1]} INTEGER NOT NULL,\n";
            }
            break;
          case 'double':
            {
              if (isPrimaryKey) {
                field =
                    "${f.declaration.toString().split(" ")[1]} REAL PRIMARY KEY,\n";
                break;
              }
              _nullableChecker.hasAnnotationOfExact(f)
                  ? field = "${f.declaration.toString().split(" ")[1]} REAL,\n"
                  : field =
                      "${f.declaration.toString().split(" ")[1]} REAL NOT NULL,\n";
            }
            break;
          case 'bool':
            {
              if (isPrimaryKey) {
                field =
                    "${f.declaration.toString().split(" ")[1]} INTEGER PRIMARY KEY,\n";
                break;
              }
              _nullableChecker.hasAnnotationOfExact(f)
                  ? field =
                      "${f.declaration.toString().split(" ")[1]} INTEGER,\n"
                  : field =
                      "${f.declaration.toString().split(" ")[1]} INTEGER NOT NULL,\n";
            }
            break;
          default:
            {
              field = f.declaration.toString();
            }
        }
        fields = fields + field;
      }
    }
    return fields + ");''';" + toMap;
  }

  String _generateToMap(List fields, String fileName) {
    var varName = fileName;
    varName = varName.replaceFirst(varName[0], varName[0].toLowerCase());
    var toMap =
        'Map<String, dynamic> toMap(${fileName} ${varName}){var map = <String, dynamic>{';
    for (var f in fields) {
      if (_hiveFieldChecker.hasAnnotationOfExact(f)) {
        var tempToMap;
        var fieldName = f.declaration.toString().split(' ')[1];

        switch (f.declaration.toString().split(' ')[0]) {
          case 'String':
            {
              tempToMap = '"$fieldName" : $varName.$fieldName ?? "N/A",';
            }
            break;
          default:
            {
              tempToMap = '"$fieldName" : $varName.$fieldName ?? 0,';
            }
        }
        toMap = toMap + tempToMap;
      }
    }
    return toMap + '};' + 'return map;}';
  }
}
