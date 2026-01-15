---
status: complete
priority: p1
issue_id: "004"
tags: [bug, hotkey, ux, critical]
dependencies: []
---

# Hotkey Not Active Until Menu Bar Clicked

## Problem Statement
The global hotkey only becomes active after the user clicks on the menu bar icon at least once. This breaks the expected UX where hotkeys should work immediately after app launch.

## Findings
- Location: `Sources/AudioToggle/AudioToggleApp.swift:15-18`
- `setupHotkeyOnce()` is called inside `.onAppear` on MenuBarView
- `.onAppear` only fires when the popover is opened for the first time
- Users must click menu bar icon before hotkey works

## Problem Scenario
1. User launches AudioToggle
2. User presses hotkey → nothing happens
3. User clicks menu bar icon (popover appears)
4. User closes popover
5. User presses hotkey → now it works
6. User confused why it didn't work initially

## Proposed Solutions

### Option 1: Use NSApplicationDelegateAdaptor (Recommended)
- **Pros**: Runs at app launch, standard pattern for setup tasks
- **Cons**: Adds AppDelegate boilerplate
- **Effort**: Small
- **Risk**: Low

### Option 2: Use task modifier on MenuBarExtra
- **Pros**: SwiftUI native approach
- **Cons**: May still have timing issues
- **Effort**: Small
- **Risk**: Low

## Recommended Action
Add an AppDelegate using `@NSApplicationDelegateAdaptor` and register the hotkey in `applicationDidFinishLaunching`.

## Technical Details
- **Affected Files**: AudioToggleApp.swift
- **Related Components**: KeyboardShortcuts, App lifecycle
- **Database Changes**: No

## Acceptance Criteria
- [ ] Hotkey works immediately after app launch (no menu bar click needed)
- [ ] Hotkey still respects the user's configured shortcut
- [ ] No regression in existing functionality

## Work Log

### 2026-01-15 - Approved for Work
**By:** Claude Triage System
**Actions:**
- Issue approved during triage session
- Status: ready
- Ready to be picked up and worked on

## Notes
Source: Triage session on 2026-01-15
User report: "I need to actually click into the menu bar once before the hot key will take effect"
