# blog-input-viewmodel

## Overview

BlogInputViewModel manages the blog URL input, photo fetching, and UI state for the blog input screen. It extends ChangeNotifier and delegates photo fetching to PhotoRepository.

## File

`lib/ui/blog_input/view_model/blog_input_view_model.dart`

### Requirement: URL input state management

BlogInputViewModel SHALL extend `ChangeNotifier`.

BlogInputViewModel SHALL call `notifyListeners()` after every state change.

BlogInputViewModel SHALL expose the following read-only properties:
- `blogUrl` (String) — the current URL input value
- `isLoading` (bool) — whether a fetch operation is in progress
- `errorMessage` (String?) — the error message if the last operation failed
- `fetchResult` (FetchResult?) — the result of the last successful fetch

BlogInputViewModel SHALL provide an `onUrlChanged(String url)` method. When `onUrlChanged` is called, it SHALL update `blogUrl` to the provided value and call `notifyListeners()`.

#### Scenario: initial state

Given a newly created BlogInputViewModel,
then `blogUrl` SHALL be an empty string,
and `isLoading` SHALL be `false`,
and `errorMessage` SHALL be `null`,
and `fetchResult` SHALL be `null`.

#### Scenario: URL value updated

Given a BlogInputViewModel,
when `onUrlChanged("https://blog.naver.com/test/123")` is called,
then `blogUrl` SHALL equal `"https://blog.naver.com/test/123"`.

### Requirement: empty URL validation

When `fetchPhotos()` is called and `blogUrl` is an empty string, BlogInputViewModel SHALL set `errorMessage` to a non-null value and SHALL NOT call `PhotoRepository.fetchPhotos`.

#### Scenario: fetch with empty URL

Given a BlogInputViewModel with `blogUrl` as empty string,
when `fetchPhotos()` is called,
then `errorMessage` SHALL be set to a non-null error message,
and `PhotoRepository.fetchPhotos` SHALL NOT be invoked.

### Requirement: fetch photos with loading state

When `fetchPhotos()` is called with a non-empty `blogUrl`, BlogInputViewModel SHALL:
1. Set `isLoading` to `true` and clear `errorMessage`
2. Call `PhotoRepository.fetchPhotos(blogUrl)`
3. On `Result.ok`, store the `FetchResult` in `fetchResult`
4. On `Result.error`, store the error message in `errorMessage`
5. Set `isLoading` to `false`

BlogInputViewModel SHALL prevent concurrent fetch requests by checking `isLoading` before initiating a new request.

#### Scenario: successful fetch

Given a BlogInputViewModel with a valid `blogUrl`,
when `fetchPhotos()` is called and PhotoRepository returns `Result.ok(fetchResult)`,
then `fetchResult` SHALL contain the returned FetchResult,
and `isLoading` SHALL be `false`,
and `errorMessage` SHALL be `null`.

#### Scenario: fetch failure

Given a BlogInputViewModel with a valid `blogUrl`,
when `fetchPhotos()` is called and PhotoRepository returns `Result.error(exception)`,
then `errorMessage` SHALL contain the error message,
and `isLoading` SHALL be `false`,
and `fetchResult` SHALL remain `null`.

#### Scenario: duplicate fetch prevention

Given a BlogInputViewModel where `isLoading` is `true`,
when `fetchPhotos()` is called again,
then a second `PhotoRepository.fetchPhotos` call SHALL NOT be initiated.

### Requirement: reset state

BlogInputViewModel SHALL provide a `reset()` method that clears `fetchResult`, `errorMessage`, and resets `blogUrl` to an empty string.

#### Scenario: reset after successful fetch

Given a BlogInputViewModel with a non-null `fetchResult`,
when `reset()` is called,
then `fetchResult` SHALL be `null`,
and `errorMessage` SHALL be `null`,
and `blogUrl` SHALL be an empty string.
