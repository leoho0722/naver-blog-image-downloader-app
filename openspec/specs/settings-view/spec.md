# settings-view Specification

## Purpose

TBD - created by archiving change 's028-settings-view'. Update Purpose after archive.

## Requirements

### Requirement: Cache size display

The `SettingsView` SHALL display a cache info tile with `title` set to "快取大小". The `additionalInfo` area SHALL show the formatted cache size value followed by a clear button (broom icon). The clear button SHALL trigger a confirmation dialog before clearing.

#### Scenario: Cache size shown with clear button

- **GIVEN** the SettingsView is rendered
- **WHEN** the cache section is displayed
- **THEN** a `CupertinoListTile` SHALL show "快取大小" as `title`, the formatted cache size and a broom-icon clear button in the trailing area

#### Scenario: Cache size updates after clearing

- **GIVEN** cache items have been cleared
- **WHEN** the clear operation completes
- **THEN** the displayed cache size SHALL update to reflect the new total


<!-- @trace
source: settings-ui-refinement
updated: 2026-03-22
code:
  - naver_blog_image_downloader/lib/ui/settings/widgets/settings_view.dart
  - naver_blog_image_downloader/lib/ui/blog_input/view_model/blog_input_view_model.dart
  - naver_blog_image_downloader/lib/amplifyconfiguration.dart
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
  - naver_blog_image_downloader/pubspec.lock
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_response.dart
  - naver_blog_image_downloader/lib/ui/settings/view_model/settings_view_model.dart
  - naver_blog_image_downloader/lib/routing/app_router.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/view_model/photo_detail_view_model.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_request.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/view_model/photo_gallery_view_model.dart
  - naver_blog_image_downloader/pubspec.yaml
  - naver_blog_image_downloader/lib/main.dart
  - naver_blog_image_downloader/ios/Podfile.lock
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
tests:
  - naver_blog_image_downloader/test/data/repositories/photo_repository_test.dart
  - naver_blog_image_downloader/test/ui/download/download_view_model_test.dart
  - naver_blog_image_downloader/test/ui/blog_input/blog_input_view_model_test.dart
-->

---
### Requirement: Clear all button

The cache tile trailing area SHALL contain a clear button with a broom icon (`Icons.cleaning_services`). Tapping the button SHALL display a confirmation dialog before clearing. The button SHALL be hidden when no cached blogs exist.

After the confirmation dialog is dismissed with `true`, the view SHALL check `mounted` before calling `viewModel.clearAllCache()`.

#### Scenario: Clear button tapped

- **GIVEN** cached blogs exist
- **WHEN** the user taps the clear button (broom icon)
- **THEN** a confirmation dialog SHALL appear asking for confirmation

#### Scenario: Clear confirmed with mounted check

- **GIVEN** the user confirms clearing in the dialog
- **WHEN** the dialog returns `true`
- **THEN** the view SHALL check `mounted` before calling `viewModel.clearAllCache()`

#### Scenario: Widget unmounted before confirmation

- **GIVEN** the confirmation dialog is open
- **WHEN** the widget is disposed before the user confirms
- **THEN** `viewModel.clearAllCache()` SHALL NOT be called


<!-- @trace
source: flutter-best-practices-compliance
updated: 2026-03-22
code:
  - naver_blog_image_downloader/lib/ui/download/widgets/download_view.dart
  - naver_blog_image_downloader/lib/data/models/fetch_result.dart
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_response.dart
  - naver_blog_image_downloader/lib/ui/core/app_error.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/view_model/photo_gallery_view_model.dart
  - naver_blog_image_downloader/lib/ui/settings/widgets/settings_view.dart
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
  - naver_blog_image_downloader/lib/data/repositories/cache_repository.dart
  - naver_blog_image_downloader/analysis_options.yaml
  - naver_blog_image_downloader/lib/ui/download/view_model/download_view_model.dart
  - naver_blog_image_downloader/lib/data/services/gallery_service.dart
  - naver_blog_image_downloader/lib/data/repositories/photo_repository.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
  - naver_blog_image_downloader/lib/main.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
tests:
  - naver_blog_image_downloader/test/ui/photo_gallery/photo_gallery_view_model_test.dart
  - naver_blog_image_downloader/test/widget_test.dart
  - naver_blog_image_downloader/test/data/repositories/photo_repository_test.dart
  - naver_blog_image_downloader/test/ui/blog_input/blog_input_view_model_test.dart
  - naver_blog_image_downloader/test/ui/download/download_view_model_test.dart
-->

---
### Requirement: Confirmation dialog

The `SettingsView` SHALL display an `AlertDialog` before executing the clear-all cache operation. The dialog SHALL contain a title describing the operation, a warning message body, a cancel button that dismisses the dialog without action, and a confirm button that executes the clear operation.

#### Scenario: User confirms deletion

- **GIVEN** the confirmation AlertDialog is displayed
- **WHEN** the user presses the confirm button
- **THEN** the clear-all operation SHALL be executed and the dialog SHALL be dismissed

#### Scenario: User cancels deletion

- **GIVEN** the confirmation AlertDialog is displayed
- **WHEN** the user presses the cancel button
- **THEN** the dialog SHALL be dismissed and no data SHALL be deleted


<!-- @trace
source: settings-ui-refinement
updated: 2026-03-22
code:
  - naver_blog_image_downloader/lib/ui/settings/widgets/settings_view.dart
  - naver_blog_image_downloader/lib/ui/blog_input/view_model/blog_input_view_model.dart
  - naver_blog_image_downloader/lib/amplifyconfiguration.dart
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
  - naver_blog_image_downloader/pubspec.lock
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_response.dart
  - naver_blog_image_downloader/lib/ui/settings/view_model/settings_view_model.dart
  - naver_blog_image_downloader/lib/routing/app_router.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/view_model/photo_detail_view_model.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_request.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/view_model/photo_gallery_view_model.dart
  - naver_blog_image_downloader/pubspec.yaml
  - naver_blog_image_downloader/lib/main.dart
  - naver_blog_image_downloader/ios/Podfile.lock
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
tests:
  - naver_blog_image_downloader/test/data/repositories/photo_repository_test.dart
  - naver_blog_image_downloader/test/ui/download/download_view_model_test.dart
  - naver_blog_image_downloader/test/ui/blog_input/blog_input_view_model_test.dart
-->

---
### Requirement: AppBar close button without back navigation

The `SettingsView` AppBar SHALL set `automaticallyImplyLeading` to `false` to hide the default back button on the left side.

The AppBar SHALL display a close icon button (`Icons.close`) in the `actions` area on the right side. When tapped, the close button SHALL call `Navigator.of(context).pop()` to dismiss the sheet.

#### Scenario: No back button on the left

- **GIVEN** the SettingsView is presented as a modal bottom sheet
- **WHEN** the page renders
- **THEN** the AppBar SHALL NOT display a back button on the left side

#### Scenario: Close button is visible on the right

- **GIVEN** the SettingsView is presented as a modal bottom sheet
- **WHEN** the page renders
- **THEN** the AppBar SHALL display a close icon button on the right side

#### Scenario: Tapping close button dismisses the sheet

- **GIVEN** the SettingsView is presented as a modal bottom sheet
- **WHEN** the user taps the close button
- **THEN** the sheet SHALL be dismissed via `Navigator.of(context).pop()`

<!-- @trace
source: add-settings-entry-to-home
updated: 2026-03-22
code:
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
  - naver_blog_image_downloader/lib/ui/settings/widgets/settings_view.dart
-->

---
### Requirement: Inset grouped list layout

The `SettingsView` body SHALL use a `ListView` containing `CupertinoListSection.insetGrouped` widgets to present settings items in iOS inset grouped style. The list SHALL occupy the full screen width. All `CupertinoListTile` items SHALL have a fixed height of 50 with cell content vertically centered. The cell content horizontal padding SHALL be 20 on both sides. The trailing text (cache size value) SHALL use the same font size as the title text.

#### Scenario: Settings displayed in inset grouped style

- **GIVEN** the SettingsView is rendered
- **WHEN** the body content is displayed
- **THEN** settings items SHALL be wrapped in `CupertinoListSection.insetGrouped` with header labels and the list SHALL fill the full screen width

#### Scenario: Cell height is fixed and content is vertically centered

- **GIVEN** the SettingsView is rendered
- **WHEN** any CupertinoListTile is displayed
- **THEN** the tile height SHALL be 50 and all content within the tile SHALL be vertically centered on the Y axis

#### Scenario: Cell horizontal padding

- **GIVEN** the SettingsView is rendered
- **WHEN** any CupertinoListTile is displayed
- **THEN** the cell content SHALL have 20 horizontal padding on both sides

#### Scenario: Trailing text font size matches title

- **GIVEN** the SettingsView is rendered
- **WHEN** the cache size value is displayed in the trailing area
- **THEN** the font size SHALL match the title text font size


<!-- @trace
source: settings-ui-refinement
updated: 2026-03-22
code:
  - naver_blog_image_downloader/lib/ui/settings/widgets/settings_view.dart
  - naver_blog_image_downloader/lib/ui/blog_input/view_model/blog_input_view_model.dart
  - naver_blog_image_downloader/lib/amplifyconfiguration.dart
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
  - naver_blog_image_downloader/pubspec.lock
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_response.dart
  - naver_blog_image_downloader/lib/ui/settings/view_model/settings_view_model.dart
  - naver_blog_image_downloader/lib/routing/app_router.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/view_model/photo_detail_view_model.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_request.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/view_model/photo_gallery_view_model.dart
  - naver_blog_image_downloader/pubspec.yaml
  - naver_blog_image_downloader/lib/main.dart
  - naver_blog_image_downloader/ios/Podfile.lock
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
tests:
  - naver_blog_image_downloader/test/data/repositories/photo_repository_test.dart
  - naver_blog_image_downloader/test/ui/download/download_view_model_test.dart
  - naver_blog_image_downloader/test/ui/blog_input/blog_input_view_model_test.dart
-->

---
### Requirement: Version number display

The `SettingsView` SHALL display the application version number in a dedicated `CupertinoListSection.insetGrouped` with header "關於". The version SHALL be shown as a `CupertinoListTile` with title "版本" and the version string as `additionalInfo`. The version SHALL be retrieved via `PackageInfo.fromPlatform()` from `package_info_plus` and managed as local widget state.

#### Scenario: Version number shown in About section

- **GIVEN** the SettingsView is rendered
- **WHEN** `PackageInfo.fromPlatform()` returns successfully
- **THEN** a `CupertinoListSection.insetGrouped` with header "關於" SHALL contain a tile showing "版本" as title and the version string as `additionalInfo`

<!-- @trace
source: settings-ui-refinement
updated: 2026-03-22
code:
  - naver_blog_image_downloader/lib/ui/settings/widgets/settings_view.dart
  - naver_blog_image_downloader/lib/ui/blog_input/view_model/blog_input_view_model.dart
  - naver_blog_image_downloader/lib/amplifyconfiguration.dart
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
  - naver_blog_image_downloader/pubspec.lock
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_response.dart
  - naver_blog_image_downloader/lib/ui/settings/view_model/settings_view_model.dart
  - naver_blog_image_downloader/lib/routing/app_router.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/view_model/photo_detail_view_model.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_request.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/view_model/photo_gallery_view_model.dart
  - naver_blog_image_downloader/pubspec.yaml
  - naver_blog_image_downloader/lib/main.dart
  - naver_blog_image_downloader/ios/Podfile.lock
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
tests:
  - naver_blog_image_downloader/test/data/repositories/photo_repository_test.dart
  - naver_blog_image_downloader/test/ui/download/download_view_model_test.dart
  - naver_blog_image_downloader/test/ui/blog_input/blog_input_view_model_test.dart
-->