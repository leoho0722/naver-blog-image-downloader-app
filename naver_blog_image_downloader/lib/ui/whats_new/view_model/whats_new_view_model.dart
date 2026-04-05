import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/whats_new_registry.dart';
import '../../../data/repositories/log_repository.dart';
import '../../../data/repositories/settings_repository.dart';

part 'whats_new_view_model.g.dart';

// region State

/// 「版本新功能」與「首次安裝引導」的顯示狀態。
///
/// 使用 sealed class 區分三種情境：不顯示、顯示引導、顯示新功能。
sealed class WhatsNewState {
  /// 建立 [WhatsNewState]。
  const WhatsNewState();
}

/// 不需要顯示任何 Dialog 的狀態。
class WhatsNewHidden extends WhatsNewState {
  /// 建立 [WhatsNewHidden]。
  const WhatsNewHidden();
}

/// 首次安裝時顯示操作引導的狀態。
class WhatsNewOnboarding extends WhatsNewState {
  /// 建立 [WhatsNewOnboarding]。
  ///
  /// [version] 為當前 App 版本號。
  /// [steps] 為引導步驟列表。
  const WhatsNewOnboarding({required this.version, required this.steps});

  /// 當前 App 版本號。
  final String version;

  /// 引導步驟列表。
  final List<WhatsNewFeature> steps;
}

/// App 更新後顯示新功能介紹的狀態。
class WhatsNewUpdate extends WhatsNewState {
  /// 建立 [WhatsNewUpdate]。
  ///
  /// [version] 為當前 App 版本號。
  /// [features] 為該版本的新功能列表。
  const WhatsNewUpdate({required this.version, required this.features});

  /// 當前 App 版本號。
  final String version;

  /// 該版本的新功能列表。
  final List<WhatsNewFeature> features;
}

// endregion

// region ViewModel

/// 版本新功能與首次安裝引導的 ViewModel。
///
/// 負責判斷使用者狀態（首次安裝 / 更新 / 同版本），
/// 並在 [build] 中回傳對應的 [WhatsNewState]。
///
/// 使用 `keepAlive: true` 確保 Dialog 顯示期間 provider 不被回收，
/// 避免 [dismiss] 時取得新的 notifier 導致版本號未寫入。
@Riverpod(keepAlive: true)
class WhatsNewViewModel extends _$WhatsNewViewModel {
  /// 判斷是否需要顯示新功能介紹或首次安裝引導。
  ///
  /// 邏輯：
  /// - `lastSeenVersion == null`（首次安裝）→ [WhatsNewOnboarding]
  /// - `lastSeenVersion == currentVersion`（同版本）→ [WhatsNewHidden]
  /// - `lastSeenVersion != currentVersion`（更新）→ 查 [whatsNewRegistry]，
  ///   有內容回傳 [WhatsNewUpdate]，無內容靜默寫入版本並回傳 [WhatsNewHidden]
  ///
  /// 回傳對應的 [WhatsNewState]。
  @override
  Future<WhatsNewState> build() async {
    final repo = ref.read(settingsRepositoryProvider);

    // PackageInfo 在測試環境或無 plugin 的環境中會拋出 MissingPluginException，
    // 此時靜默回傳 Hidden 狀態，不阻斷主畫面渲染。
    final PackageInfo info;
    try {
      info = await PackageInfo.fromPlatform();
    } on Exception {
      return const WhatsNewHidden();
    }

    final currentVersion = info.version;
    final lastSeenVersion = repo.loadLastSeenVersion();

    if (lastSeenVersion == null) {
      // 區分「真正首次安裝」與「從舊版升級」：
      // 舊版使用者即使沒有 lastSeenVersion，也會有 cache_metadata、
      // themeMode、locale 或其他 Flutter plugin 寫入的 SharedPreferences key。
      if (repo.hasExistingData()) {
        // 從舊版升級：視同版本更新，查 registry 顯示新功能
        final features = whatsNewRegistry[currentVersion];
        if (features != null && features.isNotEmpty) {
          return WhatsNewUpdate(version: currentVersion, features: features);
        }
        // Registry 無該版本：靜默寫入版本，不顯示
        await repo.saveLastSeenVersion(currentVersion);
        return const WhatsNewHidden();
      }

      // 真正首次安裝：顯示操作引導
      return WhatsNewOnboarding(
        version: currentVersion,
        steps: onboardingSteps,
      );
    }

    // 同版本：不顯示
    if (lastSeenVersion == currentVersion) {
      return const WhatsNewHidden();
    }

    // 版本更新：查 registry 取得新功能列表
    final features = whatsNewRegistry[currentVersion];
    if (features != null && features.isNotEmpty) {
      return WhatsNewUpdate(version: currentVersion, features: features);
    }

    // Registry 無該版本資料：靜默寫入版本，不顯示
    await repo.saveLastSeenVersion(currentVersion);
    return const WhatsNewHidden();
  }

  /// 使用者關閉 Dialog 後呼叫，將當前版本寫入持久化儲存。
  ///
  /// 儲存後更新狀態為 [WhatsNewHidden]，
  /// 並以 fire-and-forget 方式記錄頁面導航日誌。
  Future<void> dismiss() async {
    final currentState = state.value;
    if (currentState == null || currentState is WhatsNewHidden) return;

    final version = switch (currentState) {
      WhatsNewOnboarding(:final version) => version,
      WhatsNewUpdate(:final version) => version,
      _ => null,
    };

    if (version != null) {
      final repo = ref.read(settingsRepositoryProvider);
      await repo.saveLastSeenVersion(version);
      state = const AsyncData(WhatsNewHidden());
      ref
          .read(logRepositoryProvider)
          .logPageNavigation(screenName: 'whats_new_dismissed');
    }
  }
}

// endregion
