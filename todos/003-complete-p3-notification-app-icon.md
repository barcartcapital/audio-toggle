---
status: complete
priority: p3
issue_id: "003"
tags: [ui, branding, notification, enhancement]
dependencies: ["002"]
---

# Notification Missing App Icon

## Problem Statement
The notification that appears when switching audio has no icon. User wants to show the app icon in notifications for better branding and recognition.

## Findings
- Location: `Sources/AudioToggle/Services/AudioService.swift:127-144`
- Current behavior: Notification shows with generic/no icon
- User wants: Same icon as menu bar for consistency

## Proposed Solutions

### Option 1: Add AppIcon to Assets catalog
- **Pros**: Proper branding, notifications auto-use app icon
- **Cons**: Requires creating icon assets at multiple sizes
- **Effort**: Small-Medium (30 min)
- **Risk**: Low

### Option 2: Ensure app bundle is properly configured
- **Pros**: macOS should auto-associate app icon with notifications
- **Cons**: May already be configured, just missing the actual icon asset
- **Effort**: Small
- **Risk**: Low

## Recommended Action
Create an AppIcon asset set in Assets.xcassets using the headphones symbol or a custom design. macOS will automatically use this for notifications.

## Technical Details
- **Affected Files**: Assets.xcassets (new), possibly AudioService.swift
- **Related Components**: UNUserNotificationCenter, App bundle
- **Database Changes**: No

## Implementation Notes
1. Create Assets.xcassets folder if not exists
2. Add AppIcon.appiconset with required sizes (16, 32, 64, 128, 256, 512, 1024)
3. macOS should automatically use this for notifications

## Acceptance Criteria
- [ ] Notification displays app icon
- [ ] Icon matches menu bar icon theme
- [ ] Icon visible in Notification Center history

## Work Log

### 2026-01-15 - Approved for Work
**By:** Claude Triage System
**Actions:**
- Issue approved during triage session
- Status: ready
- Depends on #002 (should use same icon theme)

## Notes
Source: Triage session on 2026-01-15
User feedback: "The notification that pops up has no icon - I would like to show some kind of icon there"
