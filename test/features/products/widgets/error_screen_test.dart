import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_test/features/products/widgets/error_screen.dart';

void main() {
  group('ErrorPlaceholder Widget Tests', () {
    testWidgets('Should display the correct error message', (
      WidgetTester tester,
    ) async {
      // 1. Arrange: ယာယီ (dummy) MaterialApp ထဲတွင် widget ကို တည်ဆောက် (render) ပါ
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorPlaceholder(
              errorMessage: 'No internet connection',
              onTryAgain: () {},
            ),
          ),
        ),
      );

      // 2. Assert: ကျွန်ုပ်တို့၏ ကိုယ်ပိုင် error message သည် မျက်နှာပြင်တွင် ပေါ်/မပေါ် စစ်ဆေးပါ
      expect(find.text('No internet connection'), findsOneWidget);

      // သင့်၏ ပုံသေ ခေါင်းစဉ်စာသား (default title) ပေါ်/မပေါ်ကိုလည်း စစ်ဆေးနိုင်ပါသည်
      expect(find.text('Oops! Something went wrong'), findsOneWidget);
    });

    testWidgets('Should trigger onTryAgain when the button is tapped', (
      WidgetTester tester,
    ) async {
      // 1. Arrange: ခလုတ်ကို နှိပ်လိုက်ခြင်း ရှိ/မရှိ ခြေရာခံရန် variable တစ်ခု ဖန်တီးပါ
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorPlaceholder(
              errorMessage: 'Failed to load',
              onTryAgain: () {
                // ခလုတ်ကို နှိပ်လိုက်သောအခါ ၎င်းသည် true သို့ ပြောင်းလဲသွားပါမည်!
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      // 2. Act: "Try Again" ခလုတ်ကို ရှာဖွေပြီး အသုံးပြုသူမှ နှိပ်လိုက်သကဲ့သို့ ပုံစံတူလုပ်ဆောင်ပါ
      final tryAgainButton = find.text('Try Again');
      await tester.tap(tryAgainButton);

      // ခလုတ်နှိပ်ပြီးနောက် UI ကို ပြန်လည်တည်ဆောက်ရန် (rebuild) testing ပတ်ဝန်းကျင်ကို ညွှန်ကြားရပါမည်
      await tester.pump();

      // 3. Assert: ခလုတ်နှိပ်ခြင်းက ကျွန်ုပ်တို့၏ function ကို တကယ် အလုပ်လုပ်စေခြင်း ရှိ/မရှိ စစ်ဆေးအတည်ပြုပါ
      expect(wasTapped, true);
    });
  });
}
