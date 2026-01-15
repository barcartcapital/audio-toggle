---
status: deferred
priority: p3
issue_id: "005"
tags: [ui, branding, notification, future, deferred]
dependencies: []
---

# Notification Icon Not Showing (Future Improvement)

## Problem Statement
Notifications don't display the app icon. This is due to macOS restricting notification icons for unsigned/unnotarized apps. This is a known limitation that will be resolved when the app is properly signed for distribution.

## Findings
- Location: `Sources/AudioToggle/Services/AudioService.swift:127-187`
- Attempted UNNotificationAttachment approach - didn't work
- Root cause: unsigned app, macOS notification restrictions
- App icon assets exist and are correctly configured

## Current Behavior
- Notification shows with generic/blank icon
- Title and body text display correctly
- Attachment approach was attempted but macOS still blocks it

## Proposed Solutions

### Option 1: Code Sign with Apple Developer ID (Recommended)
- **Pros**: Proper fix, enables all macOS features
- **Cons**: Requires $99/year Apple Developer account
- **Effort**: Medium (account setup + signing configuration)
- **Risk**: Low

### Option 2: Ad-hoc signing with self-signed certificate
- **Pros**: Free, may partially work
- **Cons**: May not resolve notification icon issue
- **Effort**: Small
- **Risk**: Medium (uncertain results)

## Recommended Action
Defer until ready to distribute the app publicly. When setting up Homebrew Cask distribution, configure proper code signing and notarization at that time.

## Technical Details
- **Affected Files**: Build settings, export options
- **Related Components**: UNUserNotificationCenter, App bundle signing
- **Database Changes**: No

## Prerequisites for Resolution
- Apple Developer account ($99/year)
- Developer ID Application certificate
- Notarization through Apple's service

## Acceptance Criteria
- [ ] App is code-signed with Developer ID
- [ ] App is notarized by Apple
- [ ] Notification displays app icon
- [ ] Gatekeeper allows app to run without warnings

## Work Log

### 2026-01-15 - Approved for Work (Deferred)
**By:** Claude Triage System
**Actions:**
- Issue approved during triage session
- Status: ready (but deferred until distribution phase)
- Blocked by: Apple Developer account requirement

## Notes
Source: Triage session on 2026-01-15
User feedback: "it's not showing up... that's fine. We can mark this as a future improvement. Esp since it's not signed by macOS"
