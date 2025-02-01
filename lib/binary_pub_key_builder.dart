import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';

Builder binaryPublicKeyBuilder(BuilderOptions options) => BinaryPublicKeyBuilder();

class BinaryPublicKeyBuilder implements Builder {
  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final input = buildStep.inputId;
    final output = AssetId(
      input.package,
      input.path.replaceFirst('.pem', '.g.dart'),
    );

    var contents = await buildStep.readAsString(input);
    var lines = contents.split('\n').where((line) => line.isNotEmpty && !line.startsWith('---')).toList();
    var b64String = lines.join('');
    var bytes = base64.decode(b64String);

    final outputBuffer = StringBuffer('// Generated file. Do not edit\n');
    var varName = input.pathSegments.last.replaceFirst(input.extension, '');
    outputBuffer.writeln('const $varName = [');
    var count = 0;
    for (var b in bytes) {
      if (count % 10 == 0) {
        outputBuffer.write('  ');
      }
      outputBuffer.write('0x${b.toRadixString(16)}, ');
      count++;
      if (count % 10 == 0) {
        outputBuffer.writeln();
      }
    }
    outputBuffer.writeln('];');

    await buildStep.writeAsString(output, outputBuffer.toString());
  }

  @override
  Map<String, List<String>> get buildExtensions {
    return const {
      '.pem': ['.g.dart'],
    };
  }
}
