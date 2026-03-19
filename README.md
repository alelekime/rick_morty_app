# Rick and Morty Characters App

A SwiftUI app that shows characters from the Rick and Morty API, with search, filtering, pagination, and a detail screen.

## Features

- Character list from the Rick and Morty API  
- Search by name with debounce to avoid too many requests  
- Status filter (`All`, `Alive`, `Dead`, `Unknown`)  
- Paginated loading with a `Load More` button  
- Character detail screen (image, status, origin, location, episodes)  
- Loading, empty, and error states  
- Basic rate-limit handling with retry  
- Unit tests for the service layer and ViewModel  

## How to Run

1. Clone the repository  
2. Open `rick_morty.xcodeproj` in Xcode  
3. Select an iOS Simulator (iOS 17+)  
4. Run the app (⌘ + R)  

## How to Test

1. Open the project in Xcode  
2. Run tests with (⌘ + U)  

## Requirements

- iOS 17+  

## Technical Notes

- SwiftUI  
- MVVM architecture  
- `URLSession`  
- Logging: `OSLog`  
- Swift Testing  
- No third-party libraries  

## Architecture

The project uses a simple MVVM structure with separate UI, logic, and service layers.

The goal was to keep things easy to understand and test, without adding unnecessary complexity. Each layer has a clear responsibility, and the ViewModel and service can be tested without depending on the UI.

### UI Layer

The UI is built with SwiftUI and is responsible for displaying data and handling user interaction.

- `CharactersView` shows the list with search and filters  
- `CharacterListItem` renders each row  
- `CharacterDetailView` shows the selected character  

The views are focused on rendering.

### Logic Layer

The logic is mainly handled by `CharactersViewModel`.

It manages:

- fetching characters and details  
- search and filter state  
- pagination  
- loading and error states  
- empty state handling  
- retry behavior  

When search or filter changes, pagination resets to page 1 so the results always match the current input.

### Pagination

Pagination is handled step by step using a `Load More` action. When more data is available, the next page is requested and added to the list.

### Search Behavior

Search uses a debounce before sending requests. This helps avoid calling the API on every keystroke.

### Service Layer

The service layer handles building requests, calling the API, and decoding responses.

It uses `URLSession` to fetch data from:  
https://rickandmortyapi.com/api/character

The ViewModel depends on a protocol (`CharacterServiceProtocol`) instead of creating the service directly. The real implementation is injected at runtime, and tests use a mock version.

Basic error handling is also done here (invalid responses, HTTP errors). For filtered searches, a `404` is treated as an empty result so the UI can show a proper empty state instead of an error.

For `429 Too Many Requests`, the service returns the HTTP status error and the ViewModel handles it as a specific rate-limit case. The app presents a alert with a retry option.

## Testing

The project uses Swift Testing for unit tests.

Current coverage focuses on:

- ViewModel behavior (search resets pagination)  
- Service decoding  

## Observability

The app uses `OSLog` in the service layer to log request URLs, status codes, and errors. This helps during debugging without adding extra tools.

## Security Considerations

- All requests use HTTPS  
- No sensitive data is stored locally  
- Query parameters are built using `URLComponents`  
- The API is public, so no authentication is required  

## Priorities

If I had more time, I would prioritize the following next:

1. Add caching for API responses and remote images  

2. Improve error handling and retry behavior (I would make failures more user-friendly, distinguish common network scenarios more clearly, and expand the current retry behavior beyond rate-limit cases)  

3. Increase code coverage to around 80% with a combination of unit, integration, and UI tests  

4. Add VoiceOver labels, dynamic type behavior, tap target sizes, and improve overall screen readability to make the app more inclusive  

5. Add automatic infinite scrolling  
