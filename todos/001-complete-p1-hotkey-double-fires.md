---
status: complete
priority: p1
issue_id: "001"
tags: [bug, hotkey, critical]
dependencies: []
---

# Hotkey Double-Fires (Switches Forward Then Back)

## Problem Statement
When pressing the global hotkey, the audio switches to the next device but then immediately switches back to the original. The menu bar click works correctly, suggesting the hotkey handler is being triggered twice or there's a notification feedback loop.

## Findings
- Location: `Sources/AudioToggle/AudioToggleApp.swift:24-32` and `Sources/AudioToggle/Services/AudioService.swift:103-116`
- Menu bar clicking works correctly
- Hotkey triggers switch but reverts immediately
- User sees both notifications but ends up on original device

## Problem Scenario
1. User presses hotkey
2. `cycleToNextDevice()` fires → switches to Device B
3. `defaultOutputDeviceChanged` notification fires → `refreshDevices()` called
4. Something triggers another cycle → switches back to Device A
5. User sees both notifications but ends up on original device

## Proposed Solutions

### Option 1: Add debounce guard
- **Pros**: Simple fix, prevents rapid successive calls
- **Cons**: May mask underlying issue
- **Effort**: Small
- **Risk**: Low

### Option 2: Investigate duplicate handler registration
- **Pros**: Fixes root cause
- **Cons**: May require more investigation
- **Effort**: Small
- **Risk**: Low

## Recommended Action
Investigate if `onKeyUp` is being registered multiple times (e.g., on each menu bar open), and add a timestamp-based debounce to prevent rapid cycling.

## Technical Details
- **Affected Files**: AudioToggleApp.swift, AudioService.swift
- **Related Components**: KeyboardShortcuts integration, NotificationCenter observers
- **Database Changes**: No

## Acceptance Criteria
- [ ] Pressing hotkey cycles to next device and stays there
- [ ] No double-switching behavior
- [ ] Notifications show correct final device only

## Work Log

### 2026-01-15 - Approved for Work
**By:** Claude Triage System
**Actions:**
- Issue approved during triage session
- Status: ready
- Ready to be picked up and worked on

## Notes
Source: Triage session on 2026-01-15
User report: "when I click the recorded hotkey, it switches to the next input, and then back to the original"
