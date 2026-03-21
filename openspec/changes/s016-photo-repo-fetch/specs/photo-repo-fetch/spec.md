## ADDED Requirements

### Requirement: PhotoRepository construction

The `PhotoRepository` class SHALL accept four required dependencies via its constructor: `ApiService`, `FileDownloadService`, `GalleryService`, and `CacheRepository`. All dependencies SHALL be stored as private final fields.

#### Scenario: All dependencies injected

- **WHEN** a `PhotoRepository` is constructed with all four dependencies
- **THEN** the instance SHALL be created without error

#### Scenario: Dependencies accessible internally

- **WHEN** `fetchPhotos` is called on a properly constructed `PhotoRepository`
- **THEN** it SHALL use the injected `ApiService` and `CacheRepository` to perform the operation

### Requirement: BlogId derivation in fetchPhotos

The `fetchPhotos(String blogUrl)` method SHALL derive a `blogId` by calling `CacheRepository.blogId(blogUrl)` before making the API call.

#### Scenario: BlogId derived from URL

- **WHEN** `fetchPhotos` is called with a blog URL
- **THEN** `CacheRepository.blogId` SHALL be called with the same URL to derive the blogId

### Requirement: API call and DTO to Entity conversion

The `fetchPhotos(String blogUrl)` method SHALL call `ApiService.fetchPhotos(blogUrl)` to retrieve the API response, then convert each `PhotoDto` in the response to a `PhotoEntity` using the `toEntity(blogTitle)` method, where `blogTitle` is obtained from the API response.

#### Scenario: Successful API call and conversion

- **WHEN** `fetchPhotos` is called and the API returns a valid response
- **THEN** each `PhotoDto` SHALL be converted to a `PhotoEntity` with the blog title from the response
- **AND** the resulting list SHALL contain the same number of entities as DTOs

#### Scenario: Empty photo list from API

- **WHEN** the API returns an empty list of photos
- **THEN** `fetchPhotos` SHALL return a `Result.ok` containing a `FetchResult` with an empty photo list

### Requirement: Cache status check in fetchPhotos

After converting DTOs to entities, `fetchPhotos` SHALL extract all filenames from the photo entities and call `CacheRepository.isBlogFullyCached(blogId, filenames)` to determine the cache status.

#### Scenario: Blog is fully cached

- **WHEN** all photo filenames exist in the cache
- **THEN** the `FetchResult.isFullyCached` field SHALL be `true`

#### Scenario: Blog is not fully cached

- **WHEN** one or more photo filenames are missing from the cache
- **THEN** the `FetchResult.isFullyCached` field SHALL be `false`

### Requirement: Result wrapping

The `fetchPhotos` method SHALL return `Result<FetchResult>`. On success, it SHALL return `Result.ok(fetchResult)`. On any exception, it SHALL catch the exception and return `Result.error(e)`.

#### Scenario: Successful fetch returns Result.ok

- **WHEN** the entire fetchPhotos flow completes without exception
- **THEN** a `Result.ok` containing the `FetchResult` SHALL be returned

#### Scenario: API error returns Result.error

- **WHEN** `ApiService.fetchPhotos` throws an exception
- **THEN** `fetchPhotos` SHALL return `Result.error` wrapping the exception

#### Scenario: Cache check error returns Result.error

- **WHEN** `CacheRepository.isBlogFullyCached` throws an exception
- **THEN** `fetchPhotos` SHALL return `Result.error` wrapping the exception
