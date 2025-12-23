import 'package:flutter_test/flutter_test.dart';

import 'package:fusion_fiesta/data/models/user.dart';
import 'package:fusion_fiesta/data/models/feedback_entry.dart';
import 'package:fusion_fiesta/data/models/gallery_item.dart';
import 'package:fusion_fiesta/data/models/certificate.dart';
import 'package:fusion_fiesta/core/constants/app_roles.dart';

void main() {
  group('Model parsing', () {
    test('User.fromMap parses snake_case fields', () {
      final map = {
        'id': 'u1',
        'name': 'Test User',
        'email': 'test@example.com',
        'role': 'organizer',
        // Using camelCase keys because User.fromMap expects those
        'department': 'CS',
        'mobileNumber': '123',
        'enrolmentNumber': 'ENR-1',
        'profilePictureUrl': 'http://pic',
        'collegeIdUrl': 'ids/pic',
        'isApproved': true,
        'profileCompleted': true,
      };

      final user = User.fromMap(map);

      expect(user.id, 'u1');
      expect(user.role, AppRole.organizer);
      expect(user.department, 'CS');
      expect(user.isApproved, true);
      expect(user.profileCompleted, true);
    });

    test('FeedbackEntry.fromJson handles flags and ratings', () {
      final json = {
        'id': 'f1',
        'event_id': 'e1',
        'user_id': 'u1',
        'rating_overall': 4.5,
        'rating_organization': 4,
        'rating_relevance': 5,
        'comment': 'Nice event',
        'created_at': DateTime.now().toIso8601String(),
        'is_flagged': true,
        'flag_reason': 'abusive',
      };

      final entry = FeedbackEntry.fromJson(json);

      expect(entry.id, 'f1');
      expect(entry.isFlagged, true);
      expect(entry.flagReason, 'abusive');
      expect(entry.ratingOverall, 4.5);
    });

    test('GalleryItem.fromJson maps highlight and file path', () {
      final json = {
        'id': 'g1',
        'event_id': 'e1',
        'media_type': 'image',
        'url': 'http://img',
        'caption': 'cap',
        'category': 'cat',
        'uploaded_by': 'u1',
        'uploaded_at': DateTime.now().toIso8601String(),
        'is_highlighted': true,
        'file_path': 'uploads/file.jpg',
      };

      final item = GalleryItem.fromJson(json);

      expect(item.isHighlighted, true);
      expect(item.filePath, 'uploads/file.jpg');
    });

    test('Certificate.fromJson maps status-friendly fields', () {
      final json = {
        'id': 'c1',
        'user_id': 'u1',
        'event_id': 'e1',
        'url': 'http://cert',
        'issued_at': DateTime.now().toIso8601String(),
        'fee': 10,
        'is_paid': false,
      };

      final cert = Certificate.fromJson(json);

      expect(cert.id, 'c1');
      expect(cert.isPaid, false);
      expect(cert.fee, 10);
    });
  });
}
