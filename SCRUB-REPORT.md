## Summary

WidgetForge is an iOS widget composer with a shared layout and rendering kit, a SwiftUI editor, and a WidgetKit extension. The scrub removed private planning material, local Xcode state, employer-specific publisher data, internal package endpoints, identifiers, and signing settings. The published tree uses neutral sample publishers and `com.example.widgetforge` identifiers.

## Files removed

- `.git/` - excluded while copying so no source history or metadata was retained.
- `.superpowers/` - removed because it contained private planning, review, and agent workflow material.
- `HANDOFF.md` - removed because it contained internal environment paths, app details, and build notes.
- `docs/superpowers/` - removed because it contained private plans and local paths.
- `WidgetForge.xcodeproj/xcuserdata/` - removed because it contained per-user Xcode state.
- `WidgetForgeKit/.swiftpm/xcode/xcuserdata/` - removed because it contained per-user Xcode state.
- AppleDouble `._*` files - removed because they are macOS metadata files and are excluded by the specification.
- `.env`, `.env.*`, `venv/`, `.venv/`, `node_modules/`, `dist/`, `build/`, `*.egg-info/`, `.pytest_cache/`, `__pycache__/`, `*.pyc`, `.DS_Store`, `*.log`, `*.zip`, `*.db`, `*.sqlite`, `*.sqlite3`, `.claude/`, `CLAUDE.md`, and `AGENTS.md` - already absent in the working copy or excluded during the filtered copy.

## Substitutions applied

- The former corporate app and App Group namespaces became `com.example.*`, including `com.example.widgetforge` and its widget extension identifier.
- Employer-specific publisher names, URL schemes, icon asset names, and sample bundle IDs became neutral Inbox, Pipeline, Review Queue, Wellness, Time Tracker, Milestones, and Time Off examples.
- Employer-branded intent, shortcut, context, display, and source-file names became `Widget` equivalents.
- The internal package host became the explicit placeholder `https://example.com/widgetforge-theme-kit.git`.
- The visual module references were renamed to neutral ThemeKit names.
- Team IDs, signing styles, signing identities, provisioning settings, and entitlement build settings were removed from the project definition and Xcode project.
- The app-icon script now writes `AppIcon-1024.png` to its current directory rather than a personal filesystem path.

## Verification

Exact denylist scan run from the repository root:

```text
rg -n -i -uuu --hidden -g '!goodWidgetDesigns/**' -g '!.git/**' -f /tmp/widgetforge-denylist-patterns .
```

Actual output: no matches.

Exact signing scan:

```text
rg -n -i -uuu -g '!SCRUB-REPORT.md' -g '!.git/**' -e 'DEVELOPMENT_TEAM|DevelopmentTeam|CODE_SIGN|PROVISIONING|ProvisioningStyle|LH8GY3DHHE' .
```

Actual output: no matches.

Exact excluded-file scan:

```text
find . -type f \( -name '.env' -o -name '.env.*' -o -name '*.pyc' -o -name '.DS_Store' -o -name '._*' -o -name '*.log' -o -name '*.zip' -o -name '*.db' -o -name '*.sqlite' -o -name '*.sqlite3' -o -name 'CLAUDE.md' -o -name 'AGENTS.md' \) -print
```

Actual output: no matches.

`git ls-files | wc -l`: 275

Commit hash: use `git rev-parse HEAD` after the initial commit. The repository has one `Initial commit` entry.

## Judgement calls

The original private visual dependency could not be published as-is. Its endpoint is now an obvious placeholder and its references use neutral names, while the project retains the full theme abstraction and all theme definitions. The real publisher roster was replaced with synthetic examples so the manifest, availability, rendering, and intent flows remain represented without exposing employer applications.

## Residual risk

The visual module is intentionally not bundled. A reviewer must supply a compatible ThemeKit implementation or replace those module references before resolving packages and building. Generated image assets are retained because they support the theme and gallery presentation, but their visual provenance has not been independently audited.
