# Request Management UI Guide

## Visual Overview

This guide provides a visual description of the request management UI components.

---

## 1. Request Card (Pending State)

```
┌─────────────────────────────────────────────────────────┐
│  ┌────┐                                      ┌────────┐ │
│  │ 🎵 │  Song Title                          │PENDING │ │
│  │    │  Artist Name                         └────────┘ │
│  └────┐                                                  │
│                                                          │
│  👤 John Doe    💰 KSh 50.00           🕐 2:30 PM       │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │ "Please play this for my birthday! 🎂"            │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌──────────┐  ┌─────────────────────────────────────┐ │
│  │  Reject  │  │         Accept                      │ │
│  └──────────┘  └─────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

**Features:**
- Album artwork placeholder (60x60)
- Song title and artist (truncated if long)
- Status badge (orange for pending)
- Requester name with person icon
- Tip amount in green with money icon
- Timestamp
- Optional message (truncated to 2 lines)
- Quick action buttons:
  - Red "Reject" button (outlined)
  - Green "Accept" button (filled, 2x width)

---

## 2. Request Card (Approved State)

```
┌─────────────────────────────────────────────────────────┐
│  ┌────┐                                      ┌────────┐ │
│  │ 🎵 │  Song Title                          │APPROVED│ │
│  │    │  Artist Name                         └────────┘ │
│  └────┐                                                  │
│                                                          │
│  👤 John Doe    💰 KSh 50.00           🕐 2:30 PM       │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │ "Please play this for my birthday! 🎂"            │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │         ✓  Mark as Played                          │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

**Features:**
- Status badge changes to green "APPROVED"
- Single action button:
  - Blue "Mark as Played" button (outlined, full width)

---

## 3. Glassmorphism Modal (Pending Request)

```
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║  Song Request                                      [X]    ║
║                                                           ║
║  ┌─────────────────────────────────────────────────────┐ ║
║  │  ┌────────┐                                         │ ║
║  │  │        │  Song Title                             │ ║
║  │  │   🎵   │  Artist Name                            │ ║
║  │  │        │  Album Name                             │ ║
║  │  └────────┘                                         │ ║
║  └─────────────────────────────────────────────────────┘ ║
║                                                           ║
║  ┌─────────────────────────────────────────────────────┐ ║
║  │  👤 Requested by              John Doe              │ ║
║  │  💰 Tip Amount                KSh 50.00             │ ║
║  │  🕐 Requested at              Oct 8, 2:30 PM        │ ║
║  └─────────────────────────────────────────────────────┘ ║
║                                                           ║
║  ┌─────────────────────────────────────────────────────┐ ║
║  │              ⏳ PENDING                              │ ║
║  └─────────────────────────────────────────────────────┘ ║
║                                                           ║
║  ┌─────────────────────────────────────────────────────┐ ║
║  │  💬 Message                                          │ ║
║  │  "Please play this for my birthday! It's my         │ ║
║  │  favorite song and would mean a lot. Thank you!"    │ ║
║  └─────────────────────────────────────────────────────┘ ║
║                                                           ║
║  ┌──────────┐  ┌───────────────────────────────────────┐║
║  │  Reject  │  │  ✓  Accept & Add to Queue            │║
║  └──────────┘  └───────────────────────────────────────┘║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```

**Features:**
- Glassmorphism effect (blurred background)
- Semi-transparent white/surface color
- Subtle border and shadow
- Close button (X) in top-right
- Large album artwork (80x80)
- Comprehensive song details
- Requester information section
- Status badge (centered, full width)
- Full message display (no truncation)
- Action buttons at bottom

---

## 4. Glassmorphism Modal (Approved Request)

```
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║  Song Request                                      [X]    ║
║                                                           ║
║  [Song Info Section - Same as above]                     ║
║                                                           ║
║  [Requester Info Section - Same as above]                ║
║                                                           ║
║  ┌─────────────────────────────────────────────────────┐ ║
║  │              ✓ APPROVED                              │ ║
║  └─────────────────────────────────────────────────────┘ ║
║                                                           ║
║  [Message Section - If present]                          ║
║                                                           ║
║  ┌─────────────────────────────────────────────────────┐ ║
║  │         ✓  Mark as Played                           │ ║
║  └─────────────────────────────────────────────────────┘ ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```

**Features:**
- Status badge changes to green "APPROVED"
- Single action button:
  - Blue "Mark as Played" button (full width)

---

## 5. Loading State (Modal)

```
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║                                                           ║
║                                                           ║
║                      ⟳ Loading...                        ║
║                                                           ║
║                    Processing...                         ║
║                                                           ║
║                                                           ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```

**Features:**
- Circular progress indicator
- "Processing..." text
- Prevents user interaction during API call

---

## 6. Confirmation Dialog (Reject)

```
┌─────────────────────────────────────────┐
│  Reject Request?                        │
│                                         │
│  Reject "Song Title"? The tip will be  │
│  refunded.                              │
│                                         │
│              [Cancel]  [Reject]         │
└─────────────────────────────────────────┘
```

**Features:**
- Standard Material dialog
- Song title in quotes
- Clear explanation of consequences
- Cancel button (default)
- Reject button (red, destructive)

---

## 7. Notifications

### Success (Accept)
```
┌─────────────────────────────────────────────┐
│ ✓ Request accepted! Song added to queue.   │
└─────────────────────────────────────────────┘
```
- Green background
- Floating snackbar
- Auto-dismisses after 3 seconds

### Success (Reject)
```
┌─────────────────────────────────────────────┐
│ ⚠ Request rejected. Tip refunded.           │
└─────────────────────────────────────────────┘
```
- Orange background
- Floating snackbar
- Auto-dismisses after 3 seconds

### Success (Mark as Played)
```
┌─────────────────────────────────────────────┐
│ ✓ Request marked as played!                 │
└─────────────────────────────────────────────┘
```
- Blue background
- Floating snackbar
- Auto-dismisses after 3 seconds

### Error
```
┌─────────────────────────────────────────────┐
│ ✗ Failed to accept request: Network error   │
└─────────────────────────────────────────────┘
```
- Red background
- Floating snackbar
- Auto-dismisses after 4 seconds

---

## 8. Filter and Search Section

```
┌─────────────────────────────────────────────────────────┐
│  ┌─────────────────────────────────────────────────────┐│
│  │ 🔍 Search by song, artist, or requester...         ││
│  └─────────────────────────────────────────────────────┘│
│                                                          │
│  [All] [Pending] [Approved] [Rejected]    [Sort: ▼]    │
└─────────────────────────────────────────────────────────┘
```

**Features:**
- Search bar with icon
- Filter chips (selected chip highlighted)
- Sort dropdown (By Time, By Tip, By Status)
- Horizontal scrollable if needed

---

## 9. Empty State

```
┌─────────────────────────────────────────────────────────┐
│                                                          │
│                                                          │
│                        🎵                                │
│                                                          │
│                  No requests found                       │
│                                                          │
│        Requests will appear here when listeners         │
│                    make them                             │
│                                                          │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

**Features:**
- Large music note icon (faded)
- Centered text
- Helpful message
- Clean, minimal design

---

## Color Scheme

### Status Colors
- **Pending**: Orange (#FF9800)
- **Approved**: Green (#4CAF50)
- **Rejected**: Red (#F44336)
- **Played**: Blue (#2196F3)

### Action Colors
- **Accept Button**: Green background, white text
- **Reject Button**: Red border, red text
- **Mark as Played**: Blue border, blue text

### UI Elements
- **Tip Amount**: Green (#4CAF50)
- **Icons**: Theme-based with opacity
- **Borders**: Theme outline with 0.1-0.2 opacity
- **Shadows**: Theme shadow with varying opacity

---

## Animations

### Modal Entry
```
Duration: 300ms
Scale: 0.8 → 1.0 (easeOutBack)
Opacity: 0.0 → 1.0 (easeOut)
```

### Modal Exit
```
Duration: 300ms
Scale: 1.0 → 0.8 (reverse)
Opacity: 1.0 → 0.0 (reverse)
```

### Button Press
```
Duration: 100ms
Scale: 1.0 → 0.95 → 1.0
```

---

## Responsive Design

### Mobile (< 600px)
- Full-width cards
- Stacked buttons on small screens
- Modal takes 90% of screen width

### Tablet (600px - 900px)
- Cards with max-width
- Side-by-side buttons
- Modal max-width: 500px

### Desktop (> 900px)
- Centered layout
- Hover effects on cards
- Modal max-width: 500px

---

## Accessibility

### Screen Reader Labels
- "Accept request from [Requester Name]"
- "Reject request for [Song Title]"
- "Mark [Song Title] as played"
- "Request status: [Status]"
- "Tip amount: [Amount] Kenyan Shillings"

### Focus Indicators
- Visible focus ring on all interactive elements
- Logical tab order
- Skip to content option

### Color Contrast
- All text meets WCAG AA standards
- Status badges have sufficient contrast
- Icons paired with text labels

---

## Dark Mode Support

All components automatically adapt to dark theme:
- Glassmorphism uses dark surface colors
- Borders and shadows adjust opacity
- Text colors invert appropriately
- Status colors remain consistent for recognition

---

**UI Version:** 1.0.0  
**Last Updated:** 2025-10-08  
**Design System:** SpinWish Design System v1.0

