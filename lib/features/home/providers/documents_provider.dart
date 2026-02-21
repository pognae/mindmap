import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/document_model.dart';

final documentsProvider = FutureProvider<List<DocumentModel>>((ref) async {
  final client = Supabase.instance.client;
  final userId = client.auth.currentUser?.id;
  if (userId == null) return [];

  final res = await client
      .from('documents')
      .select()
      .eq('user_id', userId)
      .order('updated_at', ascending: false);

  return (res as List).map((e) => DocumentModel.fromJson(e as Map<String, dynamic>)).toList();
});
