import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_test/features/auth/providers/auth_provider.dart';
import 'package:riverpod_test/features/profile/models/address_model.dart';

class AddressNotifier extends Notifier<List<AddressModel>> {
  Box get _box => Hive.box('user_addresses_box');
  String? _userId;

  @override
  List<AddressModel> build() {
    final authState = ref.watch(authProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          _userId = user.id.toString();
          List<AddressModel> addresses = [];

          final List<dynamic> dynamicList =
              _box.get(_userId) as List<dynamic>? ?? [];

          if (dynamicList.isNotEmpty) {
            addresses = dynamicList.map((item) {
              return AddressModel.fromJson(Map<String, dynamic>.from(item));
            }).toList();
          }
          return addresses;
        } else {
          _userId = null;
          return [];
        }
      },
      error: (err, stack) => [],
      loading: () => const [],
    );
  }

  void _saveListToHive(List<AddressModel> listToSave) {
    if (_userId == null) return;

    final dynamicListToSave = listToSave.map((addr) => addr.toJson()).toList();
    _box.put(_userId, dynamicListToSave);
  }

  void addAddress(AddressModel newAddress) {
    if (_userId == null) return;

    final isFirstAddress = state.isEmpty;
    final addressToSave = newAddress.copyWith(isDefault: isFirstAddress);

    // UI State ကို အရင် Update လုပ်ပါသည်
    final newState = [...state, addressToSave];
    state = newState;

    // 💡 ပြင်ဆင်ချက် ၂: လိပ်စာအသစ် ပါဝင်လာသော List အသစ်ကြီး တစ်ခုလုံးကို Hive သို့ သိမ်းပါသည်
    _saveListToHive(newState);
  }

  void setDefaultAddress(String id) {
    if (_userId == null) return;

    final newState = state.map((address) {
      return address.copyWith(isDefault: address.id == id);
    }).toList();

    state = newState;

    // Update ဖြစ်သွားသော List ကြီး တစ်ခုလုံးကို ပြန်သိမ်းပါသည်
    _saveListToHive(newState);
  }

  void removeAddress(String id) {
    if (_userId == null) return;

    var newState = state.where((address) => address.id != id).toList();

    // ဖျက်လိုက်သည့် လိပ်စာသည် Default ဖြစ်နေခဲ့လျှင် ကျန်သည့်အထဲမှ ပထမဆုံးကို Default ပြန်ပေးမည်
    if (newState.isNotEmpty && !newState.any((addr) => addr.isDefault)) {
      newState = newState.map((addr) {
        if (addr.id == newState.first.id) {
          return addr.copyWith(isDefault: true);
        }
        return addr;
      }).toList();
    }

    state = newState;

    // ဖျက်ပြီးသား List ကို ပြန်သိမ်းပါသည်
    _saveListToHive(newState);
  }
}

final addressProvider = NotifierProvider<AddressNotifier, List<AddressModel>>(
  () {
    return AddressNotifier();
  },
);
