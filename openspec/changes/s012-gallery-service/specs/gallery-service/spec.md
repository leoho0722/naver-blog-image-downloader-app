## ADDED Requirements

### Requirement: GalleryService saveToGallery method

The file `lib/data/services/gallery_service.dart` SHALL define a `GalleryService` class that provides a `saveToGallery` method for saving images to the device gallery.

- `saveToGallery` SHALL accept a `String filePath` parameter specifying the path of the image file to save.
- `saveToGallery` SHALL call `Gal.putImage(filePath)` to save the image to the system gallery.
- `saveToGallery` SHALL return a `Future<void>`.

#### Scenario: Image saved successfully

- **GIVEN** a valid file path pointing to an image file
- **WHEN** `saveToGallery` is called with the file path
- **THEN** `Gal.putImage` SHALL be invoked with the same file path

#### Scenario: Save fails due to invalid file

- **GIVEN** an invalid file path
- **WHEN** `saveToGallery` is called
- **THEN** the exception from `Gal.putImage` SHALL propagate to the caller

### Requirement: GalleryService requestPermission method

The `GalleryService` class SHALL provide a `requestPermission` method for requesting gallery access permission.

- `requestPermission` SHALL call `Gal.requestAccess()` to request gallery access from the operating system.
- `requestPermission` SHALL return a `Future<bool>` indicating whether permission was granted.

#### Scenario: Permission granted

- **GIVEN** the user grants gallery access permission
- **WHEN** `requestPermission` is called
- **THEN** it SHALL return `true`

#### Scenario: Permission denied

- **GIVEN** the user denies gallery access permission
- **WHEN** `requestPermission` is called
- **THEN** it SHALL return `false`
