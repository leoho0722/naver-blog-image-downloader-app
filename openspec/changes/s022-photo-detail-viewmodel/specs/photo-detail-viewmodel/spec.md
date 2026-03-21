## ADDED Requirements

### Requirement: Detail state properties

The `PhotoDetailViewModel` class SHALL extend `ChangeNotifier` and provide a constructor that accepts a `CacheRepository` instance via the `required` named parameter `cacheRepository`.

The ViewModel SHALL expose the following read-only properties:
- `photo` (PhotoEntity?) — the currently loaded photo entity
- `blogId` (String) — the blog identifier

#### Scenario: Initial state

- **WHEN** a new `PhotoDetailViewModel` is created
- **THEN** `photo` SHALL be `null`
- **AND** `blogId` SHALL be an empty string

### Requirement: Load photo detail

The `load` method SHALL accept a `PhotoEntity` and a `String blogId`, storing them for display.

#### Scenario: Load single photo

- **WHEN** `load` is called with a `PhotoEntity` and a `blogId`
- **THEN** `photo` SHALL hold the provided `PhotoEntity`
- **AND** `blogId` SHALL equal the provided blogId
- **AND** `notifyListeners` SHALL be called

### Requirement: Cached file retrieval

The `cachedFile` method SHALL delegate to `CacheRepository.cachedFile` to retrieve the full-resolution cached file for the loaded photo.

#### Scenario: Retrieve cached file for loaded photo

- **GIVEN** `photo` holds a `PhotoEntity` and `blogId` is set
- **WHEN** `cachedFile()` is called
- **THEN** the method SHALL call `CacheRepository.cachedFile` with the photo's filename and the current `blogId`
- **AND** SHALL return the resulting `Future<File?>`

#### Scenario: Cached file not found

- **GIVEN** the cached file does not exist on disk
- **WHEN** `cachedFile()` is called
- **THEN** the method SHALL return `null`
