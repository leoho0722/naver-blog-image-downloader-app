## MODIFIED Requirements

### Requirement: WhatsNewFeature data model

The system SHALL define a sealed class `WhatsNewItem` in `lib/config/whats_new_registry.dart` with two common properties: `String titleKey` and `String descriptionKey`. It SHALL have two subtypes: `WhatsNewTextItem` (with `IconData icon`) and `WhatsNewImageItem` (with `String base64Image`). The `titleKey` and `descriptionKey` SHALL be identifiers used by the View layer to resolve localized strings via `AppLocalizations`.

#### Scenario: Text item with icon

- **GIVEN** a `WhatsNewTextItem` instance with icon, titleKey, and descriptionKey
- **WHEN** the instance is inspected
- **THEN** `icon` SHALL be non-null and `titleKey`/`descriptionKey` SHALL be accessible

#### Scenario: Image item with asset path

- **GIVEN** a `WhatsNewImageItem` instance with base64Image, titleKey, and descriptionKey
- **WHEN** the instance is inspected
- **THEN** `base64Image` SHALL be non-null and `titleKey`/`descriptionKey` SHALL be accessible

### Requirement: Onboarding steps registry

The system SHALL define a top-level `onboardingEntry` constant of type `WhatsNewEntry` in `lib/config/whats_new_registry.dart` containing exactly 4 items representing the app usage guide: (1) paste blog URL, (2) fetch all photos, (3) download and save, (4) browse photos. Items SHALL be `WhatsNewTextItem` instances by default, switchable to `WhatsNewImageItem` when image assets are available.

#### Scenario: Onboarding entry item count

- **GIVEN** the `onboardingEntry` constant
- **WHEN** its `items` list length is checked
- **THEN** it SHALL contain exactly 4 items

### Requirement: What's New version registry

The system SHALL define a top-level `whatsNewRegistry` constant of type `Map<String, WhatsNewEntry>` in `lib/config/whats_new_registry.dart` mapping version strings to their `WhatsNewEntry` instances. Version `'1.4.0'` SHALL have at least one entry.

#### Scenario: Registry lookup for existing version

- **GIVEN** the `whatsNewRegistry` map
- **WHEN** looking up key `'1.4.0'`
- **THEN** it SHALL return a non-null `WhatsNewEntry` with a non-empty items list

#### Scenario: Registry lookup for unknown version

- **GIVEN** the `whatsNewRegistry` map
- **WHEN** looking up a key that does not exist (e.g., `'99.0.0'`)
- **THEN** it SHALL return `null`

### Requirement: WhatsNewViewModel sealed state

`WhatsNewViewModel` SHALL use `@Riverpod(keepAlive: true)` and its `build()` method SHALL obtain content through `WhatsNewDataSource` instead of directly accessing registry constants. When `getOnboardingEntry()` returns `null` (first install but no onboarding content available), the ViewModel SHALL silently save the current version via `SettingsRepository.saveLastSeenVersion()` and return `WhatsNewHidden`. When `getWhatsNewEntry(version)` returns `null` (update but no changelog available), the same silent-save-and-hide behavior SHALL apply. The sealed state subtypes (`WhatsNewHidden`, `WhatsNewOnboarding`, `WhatsNewUpdate`) SHALL use `WhatsNewEntry` instead of `List<WhatsNewFeature>`.

#### Scenario: First install returns onboarding state

- **GIVEN** `SettingsRepository.loadLastSeenVersion()` returns `null` and `hasExistingData()` returns `false`
- **AND** `WhatsNewDataSource.getOnboardingEntry()` returns a non-null `WhatsNewEntry`
- **WHEN** `WhatsNewViewModel.build()` completes
- **THEN** the state SHALL be `WhatsNewOnboarding` with the entry from the data source
- **AND** a fire-and-forget log SHALL be recorded via `LogRepository` with the scenario details

#### Scenario: First install with null onboarding entry saves version and hides

- **GIVEN** `SettingsRepository.loadLastSeenVersion()` returns `null` and `hasExistingData()` returns `false`
- **AND** `WhatsNewDataSource.getOnboardingEntry()` returns `null`
- **WHEN** `WhatsNewViewModel.build()` completes
- **THEN** `saveLastSeenVersion` SHALL be called with the current version
- **AND** the state SHALL be `WhatsNewHidden`
- **AND** a fire-and-forget log SHALL be recorded via `LogRepository` indicating onboarding was skipped

#### Scenario: Upgrade returns what's new state

- **GIVEN** `SettingsRepository.loadLastSeenVersion()` returns a version different from current
- **AND** `WhatsNewDataSource.getWhatsNewEntry(currentVersion)` returns a non-null `WhatsNewEntry`
- **WHEN** `WhatsNewViewModel.build()` completes
- **THEN** the state SHALL be `WhatsNewUpdate`
- **AND** a fire-and-forget log SHALL be recorded via `LogRepository` with the scenario details

#### Scenario: Updated version with null entry saves version and hides

- **GIVEN** `SettingsRepository.loadLastSeenVersion()` returns a version different from current
- **AND** `WhatsNewDataSource.getWhatsNewEntry(currentVersion)` returns `null`
- **WHEN** `WhatsNewViewModel.build()` completes
- **THEN** `saveLastSeenVersion` SHALL be called with the current version
- **AND** the state SHALL be `WhatsNewHidden`
- **AND** a fire-and-forget log SHALL be recorded via `LogRepository` indicating what's new was skipped

#### Scenario: Same version returns hidden state

- **GIVEN** `SettingsRepository.loadLastSeenVersion()` returns the current app version
- **WHEN** `WhatsNewViewModel.build()` completes
- **THEN** the state SHALL be `WhatsNewHidden`
- **AND** a fire-and-forget log SHALL be recorded via `LogRepository` indicating same version

#### Scenario: PackageInfo unavailable returns hidden state

- **GIVEN** `PackageInfo.fromPlatform()` throws an exception
- **WHEN** `WhatsNewViewModel.build()` completes
- **THEN** the state SHALL be `WhatsNewHidden`
- **AND** a fire-and-forget log SHALL be recorded via `LogRepository` indicating version check failed

## ADDED Requirements

### Requirement: WhatsNewEntry wrapper class

The system SHALL define a `WhatsNewEntry` class in `lib/config/whats_new_registry.dart` with a `List<WhatsNewItem> items` property. The rendering format SHALL be determined by the runtime type of items: all `WhatsNewTextItem` renders as a scrollable list; any `WhatsNewImageItem` renders as a PageView carousel.

#### Scenario: Text-only entry renders as list

- **GIVEN** a `WhatsNewEntry` where all items are `WhatsNewTextItem`
- **WHEN** the Dialog renders
- **THEN** it SHALL display items in a scrollable list layout within a centered rounded Dialog

#### Scenario: Image entry renders as PageView

- **GIVEN** a `WhatsNewEntry` containing `WhatsNewImageItem` instances
- **WHEN** the Dialog renders
- **THEN** it SHALL display items in a PageView carousel with a page indicator and next/done button

### Requirement: WhatsNewDataSource abstraction

The system SHALL define an abstract class `WhatsNewDataSource` in `lib/config/whats_new_registry.dart` with two methods: `WhatsNewEntry? getOnboardingEntry()` and `WhatsNewEntry? getWhatsNewEntry(String version)`. A concrete `WhatsNewDataSourceImpl` SHALL implement this class by reading from `onboardingEntry` and `whatsNewRegistry` constants. The `WhatsNewViewModel` SHALL obtain content through a `WhatsNewDataSource` provider instead of directly accessing the registry constants. Future API integration SHALL be added within the same `WhatsNewDataSourceImpl` class, not as a separate implementation.

#### Scenario: Data source returns onboarding entry

- **GIVEN** a `WhatsNewDataSourceImpl` instance
- **WHEN** `getOnboardingEntry()` is called
- **THEN** it SHALL return the `onboardingEntry` constant

#### Scenario: Data source returns version entry

- **GIVEN** a `WhatsNewDataSourceImpl` instance
- **WHEN** `getWhatsNewEntry('1.4.0')` is called
- **THEN** it SHALL return the `WhatsNewEntry` for version `'1.4.0'` from the registry

#### Scenario: Data source returns null for unknown version

- **GIVEN** a `WhatsNewDataSourceImpl` instance
- **WHEN** `getWhatsNewEntry('99.0.0')` is called
- **THEN** it SHALL return `null`

### Requirement: PageView carousel dialog UI

The system SHALL render a PageView carousel when the `WhatsNewEntry` contains `WhatsNewImageItem` instances. Each page SHALL display: an image decoded from base64, a title below the image, and a description below the title. A page indicator (dots) SHALL show the current page position. All pages SHALL display a neutral "close" button that closes the Dialog. Swiping left/right SHALL navigate between pages.

#### Scenario: Multi-page carousel navigation

- **GIVEN** a `WhatsNewEntry` with 3 `WhatsNewImageItem` instances
- **WHEN** the user swipes left on page 1
- **THEN** the carousel SHALL advance to page 2 and the page indicator SHALL update

#### Scenario: Close button available on every page

- **GIVEN** a carousel showing any page (first, middle, or last)
- **WHEN** the user taps the close button
- **THEN** the Dialog SHALL close
