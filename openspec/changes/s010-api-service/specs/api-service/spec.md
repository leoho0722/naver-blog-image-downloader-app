## ADDED Requirements

### Requirement: ApiService class with injectable http.Client

The file `lib/data/services/api_service.dart` SHALL define an `ApiService` class that accepts an `http.Client` instance via its constructor.

- `ApiService` SHALL store the injected `http.Client` as a private final field.
- The constructor SHALL require a single positional parameter of type `http.Client`.

#### Scenario: ApiService is instantiated with a client

- **WHEN** an `ApiService` is created with a mock `http.Client`
- **THEN** it SHALL be successfully instantiated without errors

#### Scenario: ApiService uses the injected client for requests

- **WHEN** `fetchPhotos` is called
- **THEN** the service SHALL use the injected `http.Client` to make HTTP requests

### Requirement: fetchPhotos sends HTTP POST to Lambda API

The `ApiService` SHALL provide a `fetchPhotos` method that sends an HTTP POST request to the Lambda API endpoint.

- `fetchPhotos` SHALL accept a `String blogUrl` parameter.
- `fetchPhotos` SHALL send a POST request to `${AppConfig.baseUrl}/api/photos`.
- The request body SHALL be a JSON-encoded map containing a `url` key with the `blogUrl` value.
- The request SHALL include a `Content-Type: application/json` header.
- `fetchPhotos` SHALL return a `Future<PhotoDownloadResponse>`.

#### Scenario: Successful response is parsed

- **GIVEN** the Lambda API returns a 200 status code with a valid JSON body
- **WHEN** `fetchPhotos` is called with a valid blog URL
- **THEN** it SHALL return a `PhotoDownloadResponse` parsed from the response body

#### Scenario: Request is sent with correct URL and headers

- **GIVEN** an `ApiService` instance
- **WHEN** `fetchPhotos` is called
- **THEN** the POST request SHALL be sent to `${AppConfig.baseUrl}/api/photos` with `Content-Type: application/json` header

### Requirement: HttpException thrown on non-200 response

The `fetchPhotos` method SHALL throw an `HttpException` when the API returns a non-200 status code.

- The `HttpException` message SHALL include the HTTP status code.
- The method SHALL NOT attempt to parse the response body on non-200 responses.

#### Scenario: Server error returns 500

- **GIVEN** the Lambda API returns a 500 status code
- **WHEN** `fetchPhotos` is called
- **THEN** it SHALL throw an `HttpException`

#### Scenario: Client error returns 400

- **GIVEN** the Lambda API returns a 400 status code
- **WHEN** `fetchPhotos` is called
- **THEN** it SHALL throw an `HttpException`

### Requirement: ApiService unit tests

The file `test/data/services/api_service_test.dart` SHALL contain unit tests for `ApiService` using `mocktail` to mock `http.Client`.

- Tests SHALL verify successful JSON parsing on 200 responses.
- Tests SHALL verify `HttpException` is thrown on non-200 responses.
- Tests SHALL verify the correct URL, headers, and body are sent.

#### Scenario: All test cases pass

- **WHEN** the test suite is executed
- **THEN** all test cases SHALL pass without failures
