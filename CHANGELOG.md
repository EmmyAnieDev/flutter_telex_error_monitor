# Changelog

## 0.0.5

### Added
- Improved error handling for different platforms (Web, Android, iOS).
- Added detection for HTTP, network, and layout overflow errors.
- Standardized error messages across all platforms.

### Fixed
- Resolved issue where layout overflow errors didn't display a meaningful location.
- Fixed inconsistent error reporting on Android vs Web.

## 0.0.2

### New Features
- Added Telex integration with webhook URL support
- Added custom app name configuration
- Enhanced error reporting format
- Improved stack trace analysis
- Added specialized handling for layout overflow errors
- Added custom handling for network errors
- Improved documentation

### Bug Fixes
- Fixed issues with error message formatting
- Improved error location extraction
- Fixed handling of asynchronous errors

## 0.0.1

* Initial release with basic error tracking functionality
* Flutter framework error capturing through FlutterError.onError
* Asynchronous error capturing with runZonedGuarded
* Basic FastAPI backend integration