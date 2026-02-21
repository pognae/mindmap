import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env 없음: .env.example을 복사해 SUPABASE_URL, SUPABASE_ANON_KEY 설정 후 실행
  }
  final url = dotenv.env['SUPABASE_URL'] ?? '';
  final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  if (url.isEmpty || anonKey.isEmpty) {
    runApp(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              '.env 파일을 만들고 SUPABASE_URL, SUPABASE_ANON_KEY 를 설정하세요.\n.env.example 참고.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ));
    return;
  }
  await Supabase.initialize(url: url, anonKey: anonKey);
  runApp(const ProviderScope(child: MindmapApp()));
}
