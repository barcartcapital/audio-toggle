---
status: complete
priority: p3
issue_id: "002"
tags: [ui, branding, enhancement]
dependencies: []
---

# Custom Menu Bar Icon

## Problem Statement
The current menu bar uses the default SF Symbol `speaker.wave.2.fill`. User wants a unique icon to differentiate the app and make it more recognizable.

## Findings
- Location: `Sources/AudioToggle/AudioToggleApp.swift:14`
- Current code: `Label("AudioToggle", systemImage: "speaker.wave.2.fill")`
- User suggestions: record player or headphones icon

## Proposed Solutions

### Option 1: Use headphones SF Symbol (Recommended)
- **Pros**: Simple, already available in SF Symbols, fits audio theme
- **Cons**: Not entirely unique
- **Effort**: Small (5 minutes)
- **Risk**: Low

### Option 2: Custom record player asset
- **Pros**: Unique branding
- **Cons**: Requires creating/sourcing asset, more work
- **Effort**: Medium
- **Risk**: Low

## Recommended Action
Change to `headphones` SF Symbol for now. Can revisit custom branding later.

## Technical Details
- **Affected Files**: AudioToggleApp.swift
- **Related Components**: MenuBarExtra label
- **Database Changes**: No

## Implementation
```swift
// Change from:
Label("AudioToggle", systemImage: "speaker.wave.2.fill")

// To:
Label("AudioToggle", systemImage: "headphones")
```

## Acceptance Criteria
- [ ] Menu bar shows headphones icon instead of speaker
- [ ] Icon is visible in both light and dark mode

## Work Log

### 2026-01-15 - Approved for Work
**By:** Claude Triage System
**Actions:**
- Issue approved during triage session
- Status: ready
- Ready to be picked up and worked on

## Notes
Source: Triage session on 2026-01-15
User feedback: "I want to use a different icon other than the default 'sound' icon to showcase that it's unique"
