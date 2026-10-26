# Flutter Project Rules for AI Agents

These rules define the required conventions for implementing and
modifying this Flutter project. Follow them for every task unless the
user explicitly instructs otherwise.

## 1. General Working Rules

-   Inspect the existing project structure, `pubspec.yaml`, routing,
    theme, localization, dependency injection, and similar features
    before making changes.
-   Follow the project's existing conventions when they are consistent
    with these rules. Do not introduce a second pattern for something
    the project already handles.
-   Make the smallest complete change that solves the requested task.
    Avoid unrelated refactors and unnecessary new abstractions.
-   Do not invent API endpoints, request fields, response fields,
    business requirements, or design details. If essential information
    is missing, inspect the code and available project documentation
    first; ask a concise question if it still cannot be determined.
-   Preserve existing behavior unless the requested task requires
    changing it.
-   Do not add a package if an existing project dependency or a simple
    Dart/Flutter implementation already solves the problem. Explain the
    reason for any new dependency.
-   Never claim a task is complete or tests pass unless you actually
    performed the relevant checks.

## 2. Technology and Architecture

-   Use **Dart and Flutter** idiomatically and follow the official Dart
    style conventions.
-   Use **MVVM-inspired feature-first architecture**.
-   Use **Cubit (`flutter_bloc`) for feature-level state management**.
-   Use **GetIt (`get_it`) for dependency injection**.
-   Keep business logic out of widgets. Widgets should primarily render
    UI and forward user actions to Cubits.
-   Keep networking, persistence, and data mapping out of the UI layer.
-   Do not add extra architecture layers (such as UseCases) by default.
    Add one only when it solves a real complexity or reuse problem, or
    when the existing project already uses that layer consistently.

## 3. Required Folder Structure

Organize feature-specific code under `lib/features/<feature_name>/`.

``` text
lib/
├── core/
│   ├── di/
│   │   └── service_locator.dart
│   ├── errors/              # Shared exceptions/failures, if needed
│   ├── network/             # Shared API client and network handling, if used
│   ├── services/            # Shared technical services
│   ├── utils/               # Small, genuinely shared utilities
│   ├── widgets/             # Reusable app-wide widgets
│   └── theme/               # Shared theme, if used
├── features/
│   └── <feature_name>/
│       ├── data/
│       │   ├── models/
│       │   └── repositories/
│       └── presentation/
│           ├── cubit/
│           ├── views/
│           │   ├── <feature_name>_screen.dart
│           │   └── widgets/
│           └── widgets/      # Only if the project already separates these here
└── main.dart
```

### Structure rules

-   The canonical feature structure is:
    -   `data/models/`: parse, represent, and serialize data.
    -   `data/repositories/`: retrieve data from APIs, databases, or
        other data sources and expose feature-oriented operations.
    -   `presentation/cubit/`: feature state and presentation-related
        business logic.
    -   `presentation/views/`: screen-level widgets.
    -   `presentation/views/widgets/`: widgets used only by that screen
        or feature.
-   Prefer `presentation/views/widgets/` for feature-local widgets. Do
    not create both `presentation/widgets/` and
    `presentation/views/widgets/` without a clear reason; follow the
    established project convention if one already exists.
-   Keep shared, feature-independent components in `core/`. Keep
    feature-specific code inside its feature.
-   Do not move code into `core/` merely because it is used by two
    files. Promote it when it is genuinely reusable across features and
    has a stable, general-purpose responsibility.
-   Keep `core/` organized by responsibility. Reuse existing folders and
    files where appropriate instead of creating duplicate services, API
    clients, helpers, or widgets.
-   Use `snake_case` for file and directory names, for example
    `profile_screen.dart`, `profile_cubit.dart`, and
    `profile_state.dart`.
-   Keep each feature independent where practical. A feature should not
    import another feature's private implementation. If functionality
    must be shared, extract a well-defined shared abstraction into
    `core/`.

## 4. Dart Naming and Code Style

-   Files, directories, variables, parameters, and named arguments:
    `lower_snake_case`.
-   Types, classes, enums, typedefs, and extensions: `UpperCamelCase`.
-   Methods and functions: `lowerCamelCase`.
-   Constants: follow Dart conventions; use `lowerCamelCase` for
    constant identifiers unless an existing project convention or
    generated API requires otherwise.
-   Private members begin with `_`.
-   Use descriptive names that communicate intent. Avoid vague names
    such as `data`, `item`, `obj`, or `temp` when a more precise name is
    available.
-   Keep files, classes, methods, and functions small and focused on one
    responsibility. Extract a helper when it improves clarity, reuse, or
    testability---not merely to reduce line count.
-   Add comments only when intent, a non-obvious decision, a workaround,
    or a constraint cannot be understood from the code itself. Do not
    add comments that merely restate the code.
-   Prefer early returns and guard clauses over deeply nested
    conditionals.
-   Avoid magic values. Use named constants for values with meaning or
    values reused in multiple places.
-   Use `final` for local variables and fields that do not need
    reassignment. Use `const` when the value is a compile-time constant.
-   Prefer immutable data and state objects.
-   Avoid `dynamic` unless it is genuinely required, such as at an
    untyped external boundary. Convert external data to typed models as
    early as practical.
-   Avoid force-unwrapping nullable values with `!` unless
    non-nullability is guaranteed and the guarantee is clear.
-   Do not suppress analyzer warnings or lint rules simply to make the
    build pass. Fix the underlying issue or explain why a targeted
    exception is necessary.
-   Run `dart format` on changed Dart files and follow the project's
    `analysis_options.yaml`.

## 5. State Management: Cubit and `setState`

-   Use Cubit for feature-level state, asynchronous operations, API
    requests, validation that affects the feature flow, and business
    logic.
-   Use `setState` only for local, ephemeral UI state that does not
    belong to the feature's business state, such as a local animation
    flag, a simple visibility toggle, or a temporary expansion state.
-   Never use `setState` for API calls, business rules, feature data, or
    shared state.
-   Do not mix multiple state-management approaches for the same feature
    state without a clear, documented reason.
-   Keep Cubits focused on one feature or cohesive responsibility. Do
    not create a single global Cubit that manages unrelated features.
-   Keep widgets free of API calls and business rules. Widgets should
    call Cubit methods and render the emitted state.
-   Use `BlocBuilder` to render UI from state, `BlocListener` for
    one-off effects such as navigation, snackbars, or dialogs, and
    `BlocConsumer` only when both rendering and listening are required.
-   Use `buildWhen` or `listenWhen` only when they improve correctness
    or avoid meaningful unnecessary work; do not add them mechanically.
-   Avoid emitting duplicate or contradictory states without a reason.
-   Ensure asynchronous work handles errors and does not emit state
    after the Cubit has been closed.

## 6. State Design and UI States

For asynchronous screens and operations, explicitly handle the states
that are relevant to the use case:

-   **Initial:** the operation has not started yet, where applicable.
-   **Loading:** show a progress indicator or skeleton appropriate to
    the screen.
-   **Success with data:** render the data.
-   **Empty:** render a clear empty state when the request succeeds but
    there is no content.
-   **Error:** show a user-friendly error message and, where useful, a
    retry action.
-   **Null or missing values:** handle optional fields and absent data
    safely, with a sensible fallback when appropriate.

Rules:

-   Do not treat an API error as an empty result, or an empty result as
    an error.
-   Do not show a permanent spinner if a request fails.
-   Do not assume lists are non-empty or that API fields are always
    present unless the contract guarantees it.
-   Avoid displaying raw exception text, stack traces, internal URLs,
    tokens, or server diagnostics to users. Log useful diagnostic
    details safely where project logging supports it.
-   Make retry actions repeat the correct operation and preserve
    relevant context.
-   For forms, distinguish validation errors from network/server errors.
-   Avoid replacing existing content with a full-screen loader when a
    refresh indicator or localized loading state is more appropriate.
-   Use sealed classes, typed state classes, or a clear
    status/data/error structure according to the project's existing
    Cubit convention. Do not create an unnecessarily complex state
    hierarchy for a simple feature.
-   If stale data should remain visible during refresh, model and render
    that behavior intentionally.

## 7. Data Layer: Models and Repositories

### Models

-   Use typed models to represent external or persisted data.
-   Parse API responses defensively, especially nullable or optional
    fields.
-   Keep JSON parsing and serialization in models or the project's
    established serialization solution, not in widgets.
-   Follow existing model conventions, including `fromJson`, `toJson`,
    generated serialization, and naming.
-   Do not assume the API always returns the ideal response. Handle
    missing keys and expected type variations according to the actual
    API contract.
-   Do not silently fabricate required values when parsing fails. Use
    explicit defaults only when they are semantically valid.

### Repositories

-   Repositories are the boundary between a feature and its data
    sources.
-   Keep HTTP/database access in the repository or the project's
    established data-source abstraction---not in Cubits or views.
-   Reuse the shared network client, interceptors, authentication
    handling, and error mapping already in `core/`.
-   Keep repository methods focused and return typed results according
    to the project's existing convention.
-   Do not duplicate endpoint strings, request logic, or response
    parsing across multiple files when a shared, appropriately scoped
    implementation can be reused.
-   Do not swallow exceptions or convert every failure into an empty
    list.
-   Keep transport details out of the UI. Map errors to the project's
    established failure/result model or handle them consistently in the
    Cubit.

## 8. Dependency Injection with GetIt

-   Use the project's existing GetIt service locator and registration
    approach.
-   Keep registrations in the existing dependency injection file under
    `core/di/` (or the project's current equivalent).
-   Register shared services and clients once, then register
    repositories and Cubits with the appropriate lifetime.
-   Prefer lazy singletons for reusable shared services when
    appropriate; use factories for Cubits and other short-lived feature
    objects unless the existing architecture requires a different
    lifecycle.
-   Register dependencies in a clear order so prerequisites are
    available before dependent objects are created.
-   Do not instantiate repositories, API clients, or services manually
    inside views or Cubits when they should be injected.
-   Do not register the same type multiple times accidentally.
-   When adding a dependency, update GetIt registration and its
    initialization path, and verify the application initializes it
    before use.
-   Do not create a new service locator if the project already has one.
-   Avoid using the service locator from arbitrary UI code as a
    substitute for dependency injection. Follow the project's
    established Cubit/provider creation pattern.

## 9. `core/`, Shared Components, and Services

Before creating a helper, widget, client, or service, inspect `core/`
and existing features for an equivalent implementation.

-   Put app-wide technical infrastructure in `core/`, such as the shared
    API client, interceptors, error mapping, dependency injection,
    secure storage, and common utilities, when the project uses these
    facilities.
-   Put reusable app-wide UI components in `core/widgets/` and shared
    styling in the existing theme structure.
-   Put feature-specific widgets, models, Cubits, and repositories
    inside the feature.
-   Do not put feature-specific business rules in `core/`.
-   Do not create a generic abstraction for a single use case unless it
    clearly improves testability or separation of concerns.
-   Extend an existing service when appropriate instead of introducing a
    competing implementation.
-   Keep services cohesive; avoid a single large service that handles
    unrelated responsibilities.

## 10. Performance and Resource Management

-   Use `const` constructors and constant widget instances wherever
    possible.
-   Avoid unnecessary rebuilds. Keep `BlocBuilder` scopes as small as
    practical and do not rebuild large widget trees for unrelated state
    changes.
-   Use lazy list widgets such as `ListView.builder` for long or dynamic
    lists.
-   Avoid expensive computations, repeated parsing, or repeated object
    creation inside `build()` when they can be safely moved or cached.
-   Do not make network requests from `build()`.
-   Avoid unnecessary nested scroll views, shrink wrapping, and
    intrinsic layout calculations in large or frequently rebuilt lists.
-   Dispose of controllers, focus nodes, animation controllers, stream
    subscriptions, and other owned resources correctly.
-   Cancel timers and subscriptions when no longer needed.
-   Use pagination or incremental loading for large data sets when
    required by the product/API.
-   Do not optimize speculatively at the expense of readability. Make
    targeted, evidence-based improvements.

## 11. Async Operations and Error Handling

-   Use `async`/`await` with clear control flow.
-   Catch expected errors at the appropriate boundary and map them to
    actionable, user-safe states.
-   Do not use empty `catch` blocks.
-   Do not use broad catches to hide programming errors. If a broad
    catch is required at an application boundary, preserve diagnostic
    information and handle it deliberately.
-   Prevent duplicate submissions or overlapping requests when the use
    case requires it.
-   Handle cancellation, disposed objects, and stale responses when
    relevant to the feature.
-   Provide retry behavior when retrying is safe and useful.
-   Do not retry non-idempotent operations automatically unless the API
    and operation semantics make it safe.
-   Never log passwords, access tokens, refresh tokens, or other
    secrets.

## 12. Navigation, UI, and Accessibility

-   Reuse the project's existing routing solution and route conventions.
-   Do not introduce a second router or navigate by ad hoc mechanisms
    when the project already uses a router.
-   Keep navigation decisions and one-off navigation effects out of
    widget build methods.
-   Reuse the project's theme, spacing, typography, colors,
    localization, and design system.
-   Avoid hard-coded colors, dimensions, and user-facing strings when
    the project already has centralized theme or localization support.
-   Keep UI responsive across supported screen sizes.
-   Provide meaningful labels and semantic descriptions for interactive
    controls where needed.
-   Ensure buttons, text fields, and retry actions have clear behavior
    and appropriate enabled/disabled states.
-   Follow the existing localization strategy. Do not hard-code one
    language if the project supports localization.

## 13. Security and Configuration

-   Never hard-code secrets, private keys, passwords, or production
    access tokens in source code.
-   Use the project's established secure configuration and storage
    approach.
-   Validate and sanitize external input where appropriate.
-   Do not weaken authentication, authorization, certificate validation,
    or security checks to make a task work.
-   Avoid logging personally identifiable information or sensitive
    request/response bodies.
-   Keep environment-specific configuration in the established
    configuration mechanism.

## 14. Testing and Verification

-   Add or update unit tests for non-trivial Cubit behavior, repository
    mapping, parsing, and business rules when the project has a test
    setup.
-   Test relevant success, loading, empty, error, and nullable-data
    paths.
-   Use mocks or fakes according to the project's existing test
    conventions.
-   Do not write tests that merely duplicate implementation details;
    test observable behavior.
-   After changes, run the most relevant available checks, such as:
    -   `dart format <changed-files>`
    -   `flutter analyze`
    -   `flutter test` (or focused tests for the changed feature)
-   If a command cannot run, state that explicitly and identify what
    remains unverified.
-   Fix errors introduced by the change. Do not conceal unrelated
    pre-existing failures; report them separately.

## 15. Required Workflow for Every Task

1.  **Inspect:** Read the relevant feature, `pubspec.yaml`, routing, DI
    setup, shared `core/` utilities, and neighboring implementations.
2.  **Plan:** Identify the files that need to change and the intended
    data flow. Keep the plan proportional to the task.
3.  **Implement:** Follow the architecture and conventions in this
    document. Reuse existing code where appropriate.
4.  **Handle states:** Check loading, success, empty, error, nullable
    values, and retry behavior as applicable.
5.  **Verify:** Format changed files and run relevant analysis/tests
    when possible.
6.  **Review:** Check for duplicate logic, unused imports, accidental
    scope creep, missing DI registration, resource leaks, and
    unnecessary dependencies.
7.  **Report:** Summarize what changed, list important files, state
    checks actually performed, and disclose any remaining assumptions or
    failures.

## 16. Definition of Done

A task is complete only when all applicable conditions are met:

-   [ ] The implementation follows Dart/Flutter conventions and this
    project's architecture.
-   [ ] Business logic is not embedded in UI widgets.
-   [ ] Dependencies are reused or registered correctly through GetIt
    where applicable.
-   [ ] Relevant loading, empty, error, and nullable-data cases are
    handled.
-   [ ] No unnecessary duplicate files, services, dependencies, or
    abstractions were added.
-   [ ] Resources are disposed of correctly.
-   [ ] Changed Dart files are formatted.
-   [ ] Relevant analysis and tests were run, or the unverified checks
    are explicitly reported.
-   [ ] The final summary accurately describes the implementation and
    any limitations.

## 17. Conflict Resolution

-   The user's explicit task instructions take precedence over these
    general rules for that task, unless they conflict with security or
    platform constraints.
-   Existing project conventions should be preserved when they do not
    conflict with the user's explicit instructions or these rules.
-   If a requested change requires departing from these rules, make the
    smallest necessary exception and explain it in the final summary.
-   If a critical requirement is ambiguous and cannot be safely inferred
    from the project, ask before making a potentially destructive or
    architecture-changing decision.
