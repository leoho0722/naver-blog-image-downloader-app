## ADDED Requirements

### Requirement: PhotoDownloadRequest DTO defined

The file `lib/data/models/dtos/photo_download_request.dart` SHALL define a `PhotoDownloadRequest` class for serializing API request parameters to JSON.

- `PhotoDownloadRequest` SHALL provide a `toJson()` method that returns a `Map<String, dynamic>`.

#### Scenario: Request serialized to JSON

- **WHEN** `toJson()` is called on a `PhotoDownloadRequest` instance
- **THEN** it SHALL return a `Map<String, dynamic>` containing all request parameters

#### Scenario: Request fields are accessible

- **WHEN** a `PhotoDownloadRequest` is created with valid parameters
- **THEN** all parameters SHALL be accessible as properties on the instance

### Requirement: PhotoDownloadResponse DTO defined

The file `lib/data/models/dtos/photo_download_response.dart` SHALL define a `PhotoDownloadResponse` class for deserializing API response JSON.

- `PhotoDownloadResponse` SHALL have a `blogTitle` property of type `String`.
- `PhotoDownloadResponse` SHALL have a `photos` property of type `List<PhotoDto>`.
- `PhotoDownloadResponse` SHALL provide a `factory PhotoDownloadResponse.fromJson(Map<String, dynamic> json)` constructor.

#### Scenario: Response deserialized from JSON

- **WHEN** `PhotoDownloadResponse.fromJson(json)` is called with a valid JSON map containing `blogTitle` and a list of photo objects
- **THEN** it SHALL return a `PhotoDownloadResponse` instance with the correct `blogTitle` and a `List<PhotoDto>` matching the JSON data

#### Scenario: Response with empty photo list

- **WHEN** `PhotoDownloadResponse.fromJson(json)` is called with a valid JSON map containing an empty photo list
- **THEN** the `photos` property SHALL be an empty `List<PhotoDto>`

### Requirement: PhotoDto DTO defined with toEntity conversion

The file `lib/data/models/dtos/photo_download_response.dart` SHALL define a `PhotoDto` class for deserializing individual photo data from API response JSON.

- `PhotoDto` SHALL provide a `factory PhotoDto.fromJson(Map<String, dynamic> json)` constructor.
- `PhotoDto` SHALL provide a `toEntity()` method that returns a `PhotoEntity`.

#### Scenario: PhotoDto deserialized from JSON

- **WHEN** `PhotoDto.fromJson(json)` is called with a valid JSON map
- **THEN** it SHALL return a `PhotoDto` instance with all photo properties populated

#### Scenario: PhotoDto converted to PhotoEntity

- **WHEN** `toEntity()` is called on a `PhotoDto` instance
- **THEN** it SHALL return a `PhotoEntity` with matching property values mapped from the DTO

#### Scenario: PhotoDto toEntity preserves optional fields

- **WHEN** `toEntity()` is called on a `PhotoDto` that has `width` and `height` values
- **THEN** the returned `PhotoEntity` SHALL contain the same `width` and `height` values
