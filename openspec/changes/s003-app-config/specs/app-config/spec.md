## ADDED Requirements

### Requirement: AppConfig class defined

The file `lib/config/app_config.dart` SHALL define an `AppConfig` abstract final class that provides application configuration values as static constants.

- `AppConfig` SHALL be declared as `abstract final class` to prevent instantiation and inheritance.
- `AppConfig` SHALL define a `static const String baseUrl` property containing the Lambda API base URL.

#### Scenario: Base URL is accessible

- **WHEN** `AppConfig.baseUrl` is referenced
- **THEN** it SHALL return a non-empty `String` representing a valid URL

#### Scenario: AppConfig cannot be instantiated

- **WHEN** an attempt is made to instantiate `AppConfig`
- **THEN** the Dart compiler SHALL reject the code at compile time

### Requirement: Constants class defined

The file `lib/utils/constants.dart` SHALL define a `Constants` abstract final class that provides shared application constants.

- `Constants` SHALL be declared as `abstract final class` to prevent instantiation and inheritance.
- `Constants` SHALL define the application name as a `static const String`.

#### Scenario: Application name constant is accessible

- **WHEN** `Constants.appName` is referenced
- **THEN** it SHALL return a non-empty `String`

#### Scenario: Constants cannot be instantiated

- **WHEN** an attempt is made to instantiate `Constants`
- **THEN** the Dart compiler SHALL reject the code at compile time
