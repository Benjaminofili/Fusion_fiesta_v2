import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/system_alert.dart';
import '../models/support_message.dart';
import '../models/gallery_item.dart';
import '../models/feedback_entry.dart';
import '../models/certificate.dart';
import 'admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final SupabaseClient _supabase;

  AdminRepositoryImpl(this._supabase);

  @override
  Stream<List<SystemAlert>> getSystemAlertsStream() {
    return _supabase
        .from('system_alerts')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false) // Newest first
        .map((data) {
          // Filter locally if needed, or row-level-security handles it
          final unresolved =
              data.where((json) => json['is_resolved'] == false).toList();

          return unresolved.map((json) {
            return SystemAlert(
              id: json['id'],
              title: json['title'],
              message: json['message'] ?? '',
              // Parse Supabase Enum string to Dart Enum
              type: _parseAlertType(json['type']),
              severity: _parseAlertSeverity(json['severity']),
              timestamp: DateTime.parse(json['created_at']),
              isResolved: json['is_resolved'] ?? false,
            );
          }).toList();
        });
  }

  @override
  Future<void> resolveAlert(String id) async {
    await _supabase
        .from('system_alerts')
        .update({'is_resolved': true}).eq('id', id);
  }

  @override
  Future<List<SupportMessage>> getSupportMessages() async {
    try {
      final response = await _supabase
          .from('support_messages')
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        return SupportMessage(
          id: json['id'],
          senderName: json['sender_name'],
          email: json['email'],
          subject: json['subject'],
          message: json['message'],
          receivedAt: DateTime.parse(json['created_at']),
          isReplied: json['is_replied'] ?? false,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching messages: $e');
      return [];
    }
  }

  @override
  Future<void> replyToMessage(String id, String replyContent) async {
    // In a real app, this might trigger an Edge Function to send an email.
    // Here we just update the DB record.
    await _supabase
        .from('support_messages')
        .update({'is_replied': true}).eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // Gallery Moderation
  // ---------------------------------------------------------------------------
  @override
  Future<List<GalleryItem>> getAllGalleryItems() async {
    final response = await _supabase
        .from('gallery_items')
        .select()
        .order('uploaded_at', ascending: false);

    return (response as List)
        .map((json) => GalleryItem.fromJson(json))
        .toList();
  }

  @override
  Future<void> toggleGalleryHighlight(String id, bool isHighlighted) async {
    // Works only if the column exists in DB; otherwise, backend will error.
    await _supabase
        .from('gallery_items')
        .update({'is_highlighted': isHighlighted}).eq('id', id);
  }

  @override
  Future<void> deleteGalleryItem(String id) async {
    // Try to fetch file path to clean up storage; ignore failures silently.
    String? filePath;
    try {
      final row = await _supabase
          .from('gallery_items')
          .select('file_path')
          .eq('id', id)
          .maybeSingle();
      if (row != null) filePath = row['file_path'] as String?;
    } catch (_) {}

    // Delete the row
    await _supabase.from('gallery_items').delete().eq('id', id);

    // Attempt storage cleanup if we have a path
    if (filePath != null && filePath.isNotEmpty) {
      try {
        await _supabase.storage.from('gallery_images').remove([filePath]);
      } catch (_) {}
    }
  }

  // ---------------------------------------------------------------------------
  // Feedback Moderation
  // ---------------------------------------------------------------------------
  @override
  Future<List<FeedbackEntry>> getFlaggedFeedback() async {
    final data = await _supabase.from('feedback').select();
    final entries =
        (data as List).map((json) => FeedbackEntry.fromJson(json)).toList();
    // If the column exists, keep only flagged; else return empty list
    return entries.where((f) => f.isFlagged).toList();
  }

  @override
  Future<void> dismissFeedback(String id) async {
    // Mark as not flagged when column exists; ignore failures otherwise
    await _supabase.from('feedback').update({'is_flagged': false}).eq('id', id);
  }

  @override
  Future<void> deleteFeedback(String id) async {
    await _supabase.from('feedback').delete().eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // Certificate Oversight
  // ---------------------------------------------------------------------------
  @override
  Future<List<Certificate>> getAllCertificates() async {
    final data = await _supabase
        .from('certificates')
        .select()
        .order('issued_at', ascending: false);
    return (data as List).map((json) => Certificate.fromJson(json)).toList();
  }

  @override
  Future<void> revokeCertificate(String id) async {
    // Prefer soft-revoke if status column exists; fall back to delete on error
    try {
      await _supabase.from('certificates').update({
        'status': 'revoked',
        'revocation_reason': 'revoked_by_admin'
      }).eq('id', id);
    } catch (_) {
      await _supabase.from('certificates').delete().eq('id', id);
    }
  }

  // --- Helpers for Enums ---
  AlertType _parseAlertType(String? val) {
    return AlertType.values.firstWhere(
      (e) => e.name == val,
      orElse: () => AlertType.technical,
    );
  }

  AlertSeverity _parseAlertSeverity(String? val) {
    return AlertSeverity.values.firstWhere(
      (e) => e.name == val,
      orElse: () => AlertSeverity.low,
    );
  }
}
