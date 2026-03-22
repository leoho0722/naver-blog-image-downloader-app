# naver-url-validator Specification

## Purpose

TBD - created by archiving change 'blog-input-clipboard-paste'. Update Purpose after archive.

## Requirements

### Requirement: Validate Naver Blog URL format

The `NaverUrlValidator` SHALL provide a static method that accepts a string and returns `true` if the string is a valid Naver Blog URL. A valid URL MUST start with `https://blog.naver.com/` (desktop) or `https://m.blog.naver.com/` (mobile). URLs starting with `http://` (non-HTTPS) SHALL be rejected as invalid.

#### Scenario: Valid desktop URL

- **GIVEN** the input is `https://blog.naver.com/example_post`
- **WHEN** the validator is called
- **THEN** it SHALL return `true`

#### Scenario: Valid mobile URL

- **GIVEN** the input is `https://m.blog.naver.com/example_post`
- **WHEN** the validator is called
- **THEN** it SHALL return `true`

#### Scenario: HTTP URL rejected

- **GIVEN** the input is `http://blog.naver.com/example_post`
- **WHEN** the validator is called
- **THEN** it SHALL return `false`

#### Scenario: Non-Naver URL rejected

- **GIVEN** the input is `https://example.com/some-page`
- **WHEN** the validator is called
- **THEN** it SHALL return `false`

#### Scenario: Empty string rejected

- **GIVEN** the input is an empty string
- **WHEN** the validator is called
- **THEN** it SHALL return `false`

#### Scenario: Non-URL text rejected

- **GIVEN** the input is plain text without a URL scheme
- **WHEN** the validator is called
- **THEN** it SHALL return `false`

<!-- @trace
source: blog-input-clipboard-paste
updated: 2026-03-22
code:
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
  - naver_blog_image_downloader/lib/ui/core/naver_url_validator.dart
tests:
  - naver_blog_image_downloader/test/ui/core/naver_url_validator_test.dart
-->