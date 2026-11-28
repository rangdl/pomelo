import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/layout/window_class.dart';
import '../../../shared/ui/tokens.dart';
import '../../../shared/widgets/widgets.dart';

/// 设置页:分组卡片列表(iOS 设置风格)。
///
/// 一级页只保留入口，具体设置项拆到二级页（外观 / 播放 / 存储），
/// 避免设置项越加越长、需要长时间滚动。
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 超宽窗口限行宽,避免列表被拉满整屏。
    return CenteredMaxWidth(
      child: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          const SectionHeader('偏好设置'),
          GroupCard(
            children: [
              SettingsItem(
                icon: Icons.palette_rounded,
                title: '外观设置',
                subtitle: '主题模式、主题色与字体',
                onTap: () => context.push('/settings/appearance'),
              ),
              SettingsItem(
                icon: Icons.play_circle_outline_rounded,
                title: '播放设置',
                subtitle: '音质、音量、播放速度与定时器',
                onTap: () => context.push('/settings/playback'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader('插件设置'),
          GroupCard(
            children: [
              SettingsItem(
                icon: Icons.extension_rounded,
                title: '插件管理',
                subtitle: '安装、启停与更新插件（音源脚本自动兼容）',
                onTap: () => context.push('/plugins'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader('存储设置'),
          GroupCard(
            children: [
              SettingsItem(
                icon: Icons.folder_rounded,
                title: '存储管理',
                subtitle: '缓存占用、上限、数据目录与清理',
                onTap: () => context.push('/settings/storage'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader('关于'),
          GroupCard(
            children: [
              const SettingsItem(
                icon: Icons.info_outline_rounded,
                title: '柚子音乐',
                subtitle: '本地优先的 Flutter 音乐播放器',
              ),
              SettingsItem(
                icon: Icons.article_rounded,
                title: '运行日志',
                subtitle: '查看最近的错误与运行记录',
                onTap: () => context.push('/logs'),
              ),
              SettingsItem(
                icon: Icons.description_outlined,
                title: '开源许可',
                subtitle: '查看第三方库许可',
                onTap: () =>
                    showLicensePage(context: context, applicationName: '柚子音乐'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
