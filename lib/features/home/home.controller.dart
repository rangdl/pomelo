import 'package:fluxy/fluxy.dart';
import 'home.repository.dart';

class HomeController extends FluxController {
  final currentIndex = flux(0, key: 'current_index');

  final repo = HomeRepository();
  final count = flux(0, key: 'counter_home');
  final status = flux("Booting...");

  @override
  void onInit() async {
    super.onInit();
    status.value = await repo.sync();
  }

  void increment() => count.value++;
}
