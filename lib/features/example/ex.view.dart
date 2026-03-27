import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';

class ExView extends StatelessWidget {
  const ExView({super.key});
  @override
  Widget build(BuildContext context) {
    // return Fx.box().bg.black.child(Fx.text('page: $name'));
    return Fx(
      () => Scaffold(
        appBar: AppBar(
          title: Fx.text('示例'),
          // 以下两项确保在滚动后背景色不变
          // elevation: 0 是保持 AppBar 不变的关键
          elevation: 0,
          // 设置 forceMaterialTransparency 防止滚动时的透明度变化
          forceMaterialTransparency: true,
        ),
        body: Fx.list(gap: 8).children([
          Fx.listTile(title: Fx.text('示例1'), onTap: () => Fx.to('/ex/1')),
          Fx.listTile(title: Fx.text('示例2'), onTap: () => Fx.to('/ex/2')),
        ]),
      ),
    );
  }
}

class Ex1View extends StatelessWidget {
  const Ex1View({super.key});
  @override
  Widget build(BuildContext context) {
    // return Fx.box().bg.black.child(Fx.text('page: $name'));
    return Fx(
      () => Scaffold(
        appBar: AppBar(title: Fx.text('示例1')),
        body: Fx.col(
          alignItems: CrossAxisAlignment.start,
          children: [
            Fx.button('切换', onTap: () => Fx.toggleTheme()),
            Fx.button('toast', onTap: () => Fx.toast.success("Welcome back!")),
            Fx.button(
              'loader',
              onTap: () async {
                Fx.loader.show();
                await Future.delayed(Duration(seconds: 2));
                Fx.loader.hide();
              },
            ),
            Fx.button(
              'dialog-confirm',
              onTap: () async {
                final confirmed = await Fx.dialog.confirm(
                  title: "Delete item?",
                  content: "This action cannot be undone.",
                );
                Fx.toast.success("结果: $confirmed");
              },
            ),
            Fx.button(
              'dialog-alert',
              onTap: () async {
                await Fx.dialog.alert(
                  title: "Permission Required",
                  content: "Please enable camera access.",
                );
                Fx.toast.success("结束");
              },
            ),
            Fx.button(
              'modal',
              onTap: () async {
                Fx.modal(
                  context,
                  child: Fx.col(
                    children: [
                      Fx.text("Edit Profile").font.xl().bold(),
                      Fx.input(signal: flux('1'), placeholder: "Name"),
                      Fx.button("Save"),
                    ],
                  ).p(20),
                );
              },
            ),
            Fx.button(
              'bottomSheet',
              onTap: () async {
                Fx.bottomSheet(
                  context,
                  child: Fx.col(
                    children: [
                      Fx.text("Edit Profile").font.xl().bold(),
                      Fx.input(signal: flux('1'), placeholder: "Name"),
                      Fx.button("Save"),
                    ],
                  ).p(20),
                );
              },
            ),
            Fx.button(
              'snack',
              onTap: () async {
                Fx.snack(context, 'snacksnacksnack');
              },
            ),

            Fx.button('back', onTap: () => Fx.back()),
          ],
        ),
      ),
    );
  }
}

class Ex2View extends StatelessWidget {
  const Ex2View({super.key});
  @override
  Widget build(BuildContext context) {
    // return Fx.box().bg.black.child(Fx.text('page: $name'));
    return Fx(
      () => Scaffold(
        appBar: AppBar(title: Fx.text('示例2')),
        body: Fx.col(
          alignItems: CrossAxisAlignment.start,
          children: [Fx.button('back', onTap: () => Fx.back()).primary],
        ),
      ),
    );
  }
}
