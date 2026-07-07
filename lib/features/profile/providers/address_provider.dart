import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_test/features/profile/models/address_model.dart';

class AddressNotifier extends Notifier<List<AddressModel>> {
  @override
  List<AddressModel> build() {
    return [
      AddressModel(
        id: '1',
        label: 'Home',
        fullAddress:
            '၄၁ လမ်း၊ အမှတ် (၁၂)၊ မြေညီထပ်၊ ဗိုလ်တထောင်မြို့နယ်၊ ရန်ကုန်တိုင်းဒေသကြီး',
        latitude: 16.7761,
        longitude: 96.1649,
        isDefault: true,
      ),
      AddressModel(
        id: '2',
        label: 'Work',
        fullAddress:
            'ဆူးလေစတုရန်း၊ ၇ လွှာ၊ ကျောက်တံတားမြို့နယ်၊ ရန်ကုန်တိုင်းဒေသကြီး',
        latitude: 16.7731,
        longitude: 96.1585,
        isDefault: false,
      ),
    ];
  }

  void addAddress(AddressModel newAddress) {
    state = [...state, newAddress];
  }

  void setDefaultAddress(String id) {
    state = state.map((address) {
      if (address.id == id) {
        return address.copyWith(isDefault: true);
      } else {
        return address.copyWith(isDefault: false);
      }
    }).toList();
  }

  void removeAddress(String id) {
    state = state.where((address) => address.id != id).toList();
  }
}

final addressProvider = NotifierProvider<AddressNotifier, List<AddressModel>>(
  () {
    return AddressNotifier();
  },
);

