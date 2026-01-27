# Changelog

All notable changes to Rage Core and Rage Toolkit will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-01-27

### Fixed
- Health system: removed global identifier shadowing (preload constants renamed/removed)
- Health system: silenced unused parameter warnings

## [1.0.0] - 2025-01-27

### Added - Rage Core
- Layered architecture framework (core/game/platform/presentation)
- Mod system with versioning and dependency validation
- Content pack system for data-driven content
- Deterministic replay system with per-tick hash verification
- Event bus with priorities, interception, and cancellation
- Simulation pipeline with ordered system execution
- Game state management
- Game API for mods
- Godot platform integration
- Presentation layer bridges

### Added - Rage Toolkit
- Editor UI (Scaffold Dock) for no-code file generation
- CLI tool (\
age.py\) for scaffolding
- Metaprogramming tools:
  - \SystemGenerator\ - Generate system/event/command templates
  - \CodeGenerator\ - Full system generation with file writing
  - \HeadlessSimulator\ - Run simulations without UI
  - \SimulationRunner\ - High-level testing API
- Rapid development workflow support
- Project initialization tools
- Mod and pack generation tools

### Improved - Rage Core
- GameAPI now accepts custom events (\game.*\ and \mod.*\ prefixes)
- EventBus prevents duplicate handler subscriptions
- SimulationPipeline optimized to sort only when steps are registered

### Documentation
- Comprehensive README files for both addons
- Tutorial guides (including Spanish versions)
- API documentation
- Publishing guides for Asset Library
