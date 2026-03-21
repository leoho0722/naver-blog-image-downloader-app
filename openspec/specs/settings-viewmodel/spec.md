# settings-viewmodel

## Overview

SettingsViewModel manages cache information display and cache clearing operations for the settings screen. It extends ChangeNotifier and delegates cache operations to CacheRepository.

## File

`lib/ui/settings/view_model/settings_view_model.dart`

### Requirement: settings state properties

SettingsViewModel SHALL extend `ChangeNotifier`.

SettingsViewModel SHALL call `notifyListeners()` after every state change.

SettingsViewModel SHALL expose the following read-only properties:
- `totalCacheSize` (int) — the total cache size in bytes
- `allMetadata` (List&lt;BlogCacheMetadata&gt;) — metadata for all cached blogs
- `formattedCacheSize` (String) — human-readable cache size string
- `isLoading` (bool) — whether a load or clear operation is in progress

#### Scenario: initial state

Given a newly created SettingsViewModel,
then `totalCacheSize` SHALL be `0`,
and `allMetadata` SHALL be an empty list,
and `formattedCacheSize` SHALL be `"0 B"`,
and `isLoading` SHALL be `false`.

### Requirement: load cache info

SettingsViewModel SHALL provide a `loadCacheInfo()` method.

When `loadCacheInfo` is called, it SHALL:
1. Set `isLoading` to `true`
2. Call `CacheRepository.totalCacheSize()` and store the result in `totalCacheSize`
3. Call `CacheRepository.allMetadata()` and store the result in `allMetadata`
4. Set `isLoading` to `false`
5. Call `notifyListeners()`

#### Scenario: load cache info successfully

Given a SettingsViewModel,
when `loadCacheInfo()` is called and CacheRepository returns totalCacheSize of 157286400 and 3 metadata entries,
then `totalCacheSize` SHALL be `157286400`,
and `allMetadata` SHALL contain 3 items,
and `isLoading` SHALL be `false`.

### Requirement: formatted cache size

The `formattedCacheSize` getter SHALL convert `totalCacheSize` bytes to a human-readable string with appropriate units (B, KB, MB, GB) and one decimal place.

The formatting rules SHALL be:
- Less than 1024 bytes: display as "{n} B"
- Less than 1024 * 1024 bytes: display as "{n.d} KB"
- Less than 1024 * 1024 * 1024 bytes: display as "{n.d} MB"
- Otherwise: display as "{n.d} GB"

#### Scenario: format zero bytes

Given a SettingsViewModel with `totalCacheSize` of `0`,
then `formattedCacheSize` SHALL be `"0 B"`.

#### Scenario: format kilobytes

Given a SettingsViewModel with `totalCacheSize` of `1536`,
then `formattedCacheSize` SHALL be `"1.5 KB"`.

#### Scenario: format megabytes

Given a SettingsViewModel with `totalCacheSize` of `157286400`,
then `formattedCacheSize` SHALL be `"150.0 MB"`.

### Requirement: clear all cache

SettingsViewModel SHALL provide a `clearAllCache()` method.

When `clearAllCache` is called, it SHALL:
1. Call `CacheRepository.clearAll()`
2. Call `loadCacheInfo()` to refresh the displayed cache information

#### Scenario: clear all cache

Given a SettingsViewModel with cached data,
when `clearAllCache()` is called,
then `CacheRepository.clearAll()` SHALL be invoked,
and `loadCacheInfo()` SHALL be called to refresh data.

### Requirement: clear blog cache

SettingsViewModel SHALL provide a `clearBlogCache(String blogId)` method.

When `clearBlogCache` is called, it SHALL:
1. Call `CacheRepository.clearBlog(blogId)`
2. Call `loadCacheInfo()` to refresh the displayed cache information

#### Scenario: clear specific blog cache

Given a SettingsViewModel with multiple cached blogs,
when `clearBlogCache("abc123")` is called,
then `CacheRepository.clearBlog("abc123")` SHALL be invoked,
and `loadCacheInfo()` SHALL be called to refresh data.
