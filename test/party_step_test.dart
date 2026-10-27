import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iturrieta_book/features/booking/party_step.dart';
import 'package:iturrieta_book/l10n/app_localizations.dart';
import 'package:iturrieta_book/models/shift_availability.dart';

void main() {
  testWidgets('a group above the online maximum is asked to call', (tester) async {
    final notes = TextEditingController();
    addTearDown(notes.dispose);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PartyStep(
            adults: 21,
            children: 0,
            notesController: notes,
            shift: const ShiftAvailability(
              shiftId: 's',
              shiftName: 'Lunch',
              startTime: '13:00',
              endTime: '16:00',
              lastBookingTime: '14:30',
              maxCovers: 80,
              minGroup: 1,
              maxGroup: 40,
              taken: 0,
              remaining: 80,
              isClosed: false,
            ),
            settings: const RestaurantSettings(
              menuPriceAdult: 45,
              menuPriceChild: 16,
              depositPerPerson: 10,
              depositMinGroup: 8,
              maxGroupOnline: 20,
              cancelFreeHours: 48,
              contactPhone: '+34685721593',
            ),
            onAdults: (_) {},
            onChildren: (_) {},
            onNotes: (_) {},
            onContinue: () {},
            onBack: () {},
            onCall: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('please call us'), findsOneWidget);
    expect(find.text('Continue'), findsNothing);
  });
}
