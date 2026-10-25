# WidgetForge

WidgetForge is an iOS app for composing data-driven home screen widgets on an integer grid canvas.

It gives people a way to arrange counts, lists, metrics, status values, progress, headers, and app tiles into widget layouts without hardcoding each presentation. Publisher apps write small capability manifests into a shared App Group container. WidgetForge reads those manifests, saves the chosen layout, and the WidgetKit extension renders it on the home screen.

## Architecture

`WidgetForgeKit` contains the shared model, layout validation, theme catalog, rendering views, manifest and layout storage, sample data, and intent context. The SwiftUI app target provides the gallery, editor, theme picker, and App Intents. The widget extension uses an `AppIntentTimelineProvider` to load a selected saved layout and the current manifests before rendering a WidgetKit timeline entry.

## Notable engineering decisions

- Layout cells use integer origins and spans. `LayoutValidator` checks positive spans, canvas bounds, and pairwise half-open rectangle intersection so touching cells are allowed but overlap is rejected.
- The editor's `PlacementSolver` exposes the same placement rules as query methods. It enumerates legal origins for a proposed span and can re-place a cell while excluding that cell from the obstacle set.
- A saved layout persists a stable theme identifier, not an encoded visual object. `ThemeCatalog` resolves that identifier at render time, which keeps the layout model independent from colors, typography, card treatment, and backgrounds.
- The theme catalog has fifteen token-based themes, including classic dark, glass, aurora, terminal, data visualization, and editorial variants. Renderers read the active theme rather than hardcoding presentation values.
- Publisher manifests and layouts are stored in the shared App Group container. The extension reads them for the selected App Intent configuration and falls back to family-specific defaults when no saved layout is selected.
- The App Intents surface includes creating a layout from a prompt, reading count, list, status, metric, progress, and arbitrary slices, opening or refreshing a publisher app, and shortcut phrases for summaries and questions.

## Stack

- Swift 6 and Swift Package Manager
- SwiftUI and WidgetKit
- App Intents and App Shortcuts
- XcodeGen project definition
- XCTest and swift-snapshot-testing

## Running locally

Open `WidgetForge.xcodeproj` in Xcode, select the `WidgetForge` scheme, choose an iOS simulator, and run it. The project targets iOS 26.

The source includes a placeholder dependency URL for the optional ThemeKit visual module. Supply a compatible local or hosted module before resolving packages or building. Configure your own signing team and App Group capability before installing on a device. The app includes sample manifests for previews, so no external dataset or account is required to explore the composer.
