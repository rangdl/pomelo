import 'package:auto_route/auto_route.dart';
import 'package:pomelo/services/js_engine/js_engine.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 统计页面（占位）
@RoutePage()
class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final js = JsEngine();
    return Scaffold(
      headers: [AppBar(title: const Text('统计'))],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart, size: 64, color: colorScheme.mutedForeground),
            const Gap(16),
            Text(
              '统计功能开发中',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.mutedForeground,
              ),
            ),
            const Gap(16),
            Button.text(
              child: Text('测试jsf'),
              onPressed: () async {
                final result2 = await js.jsRuntime.eval('console.log(123)');
                print(result2);
                final result = await js.evalAsync('''
  fetch('http://192.168.0.200/test/rang/md5.min.js', {
    method: 'get',
    timeout: 5000, // 毫秒
  })
  .then(response => {
    if (!response.ok) throw new Error('HTTP error ' + response.status);
    return response.text();
  })
  .then(data => data)
  .catch(err => err.message)
''');

                print(result);
              },
            ),
            const Gap(16),
            Button.text(
              child: Text('测试jsf-crypto'),
              onPressed: () {
                final result2 = js.jsRuntime.eval("__go_crypto_md5('123')");
                print(result2);
              },
            ),
          ],
        ),
      ),
    );
  }
}
