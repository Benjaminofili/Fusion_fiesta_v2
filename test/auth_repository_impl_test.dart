import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'package:fusion_fiesta/data/repositories/auth_repository_impl.dart';
import 'package:fusion_fiesta/core/errors/app_failure.dart';
import 'package:fusion_fiesta/core/constants/app_roles.dart';

class MockSupabaseClient extends Mock implements supabase.SupabaseClient {}

class MockGoTrueClient extends Mock implements supabase.GoTrueClient {}

class MockSupabaseQueryBuilder extends Mock
    implements supabase.SupabaseQueryBuilder {}

class MockPostgrestFilterBuilderList extends Mock
    implements supabase.PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

class MockPostgrestTransformBuilderMap extends Mock
    implements supabase.PostgrestTransformBuilder<Map<String, dynamic>> {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri());
  });

  group('AuthRepositoryImpl', () {
    late MockSupabaseClient client;
    late MockGoTrueClient auth;
    late MockSupabaseQueryBuilder profilesBuilder;
    late MockPostgrestFilterBuilderList profilesFilter;
    late MockPostgrestTransformBuilderMap profilesSingle;
    late AuthRepositoryImpl repo;

    setUp(() {
      client = MockSupabaseClient();
      auth = MockGoTrueClient();
      profilesBuilder = MockSupabaseQueryBuilder();
      profilesFilter = MockPostgrestFilterBuilderList();
      profilesSingle = MockPostgrestTransformBuilderMap();
      repo = AuthRepositoryImpl(client);
    });

    test('blocks unapproved non-visitor users on sign in', () async {
      const email = 'org@example.com';
      const password = 'Pass123!';
      const userId = 'user-1';

      when(() => client.auth).thenReturn(auth);
      when(() => auth.signInWithPassword(
            email: email,
            password: password,
          )).thenAnswer(
        (_) => Future.value(
          supabase.AuthResponse(
            session: null,
            user: supabase.User(
              id: userId,
              appMetadata: const {},
              userMetadata: const {},
              aud: '',
              createdAt: '',
            ),
          ),
        ),
      );

      when(() => client.from('profiles')).thenReturn(profilesBuilder);
      when(() => profilesBuilder.select()).thenReturn(profilesFilter);
      when(() => profilesFilter.eq('id', userId)).thenReturn(profilesFilter);
      when(() => profilesFilter.single()).thenReturn(profilesSingle);
      when(() => profilesSingle.timeout(any())).thenAnswer(
        (_) => Future.value({
          'id': userId,
          'email': email,
          'name': 'Org',
          'role': 'organizer',
          'is_approved': false,
          'profile_completed': true,
        }),
      );

      expect(
        () => repo.signIn(email, password),
        throwsA(
          isA<AppFailure>().having(
            (e) => e.message,
            'message',
            contains('pending approval'),
          ),
        ),
      );
    });

    test('allows visitor sign in even if not approved', () async {
      const email = 'visitor@example.com';
      const password = 'Pass123!';
      const userId = 'visitor-1';

      when(() => client.auth).thenReturn(auth);
      when(() => auth.signInWithPassword(
            email: email,
            password: password,
          )).thenAnswer(
        (_) => Future.value(
          supabase.AuthResponse(
            session: null,
            user: supabase.User(
              id: userId,
              appMetadata: const {},
              userMetadata: const {},
              aud: '',
              createdAt: '',
            ),
          ),
        ),
      );

      when(() => client.from('profiles')).thenReturn(profilesBuilder);
      when(() => profilesBuilder.select()).thenReturn(profilesFilter);
      when(() => profilesFilter.eq('id', userId)).thenReturn(profilesFilter);
      when(() => profilesFilter.single()).thenReturn(profilesSingle);
      when(() => profilesSingle.timeout(any())).thenAnswer(
        (_) => Future.value({
          'id': userId,
          'email': email,
          'name': 'Visitor',
          'role': 'visitor',
          'is_approved': false,
          'profile_completed': true,
        }),
      );

      final user = await repo.signIn(email, password);

      expect(user.id, userId);
      expect(user.role, AppRole.visitor);
      expect(user.isApproved, false);
    });
  });
}
