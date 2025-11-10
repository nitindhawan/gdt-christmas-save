# Save the Christmas - Game Design Document (MVP)

**Engine:** GODOT 2D  
**Platform:** Mobile (iOS/Android)  
**Genre:** Puzzle  
**Art Style:** Minimalistic Premium with Christmas Theme

---

## Core Concept

A relaxing puzzle game where players unscramble beautiful Christmas-themed images by rearranging jumbled rectangular tiles into their correct positions.

---

## MVP Features

### 1. Game Loading Screen

- Simple, elegant loading screen with Christmas branding
- Progress indicator
- If Level = 1, then loads to Gameplay screen.
- If Level > 1, then loads to Level Selection screen

### 2.  Level Selection

- **Grid Layout:** Display level thumbnails (2x3 grid scrollable)
- **Level States:**
    - Unlocked and beaten: Full color, Show 1-3 stars based on difficulty beaten
    - Unlocked but unbeaten: Full color, clickable with Play Icon
    - Locked: Greyed out with lock icon
- **Star Display:** Visible on each completed level thumbnail
- **Progression:** Linear unlock (complete Level N to unlock Level N+1)
- **Navigation:** Smooth scrolling for additional levels
- **UI Elements:**
    - Settings button (top-right, to open settings popup)
- **Level selection:**
	- You can select a previously beaten level or just unlocked level.
	- You cannot selected a locked level.
	- If you select a previously beaten level, you will be taken to difficulty selection screen. You select difficulty, and then the level will start in gameplay screen.
	- If you select an unlocked level, you will be taken directly to gameplay screen with easy mode difficulty.

### 3. Difficulty Selection screen
- Display full preview of the level image
- **Difficulty Selection:**
    - **Easy Mode:** Always available (Awards 1 star)
    - **Normal Mode:** Always available (Awards 2 stars)
    - **Hard Mode:** Unlocks only after beating Normal (Awards 3rd star)
- **UI Elements:**
    - "Play Easy" button (green)
    - "Play Normal" button (green if available)
    - "Play Hard" button (greyed out if locked, green if unlocked)
    - Cross button to go back

### 4. Gameplay Screen
Gameplay screen loads the level.
A level consists of a base image, puzzle type, and some constants which change based on easy, normal, hard difficulty. This is defined in levels.json. In MVP, we support only one puzzle type "rectangle jigsaw". Later we need to support spiral twist, and other hybrid puzzle types also.
#### Puzzle Type: Rectangle Jigsaw
- **Grid System:** Image divided into rectangular tiles (size varies by difficulty). Some part of the image is outside the tiles.
- **Mechanics:**
    - Tiles are scrambled at start
    - Player taps/drags tiles to swap positions
    - Clear visual feedback on tile selection
- **Difficulty Breakdown:** (number of rows, and columns)
    - Easy: 2x3 grid (6 tiles)
    - Normal: 3x4 grid (12 tiles)
    - Hard: 5x6 grid (30 tiles)
- **UI Elements:**
    - Back button
    - Share button (to share the photo on whatsapp/other apps)
    - Settings button (to open settings popup)
    - Hint button (This swaps one piece into its correct position.)
### 5. Level Complete Screen

- Show completed image (along with Download button, and share button)
- "Continue" button (continues to next level).

### 6. Settings Screen (Popup/Modal)

- **Display:** Modal overlay that can be opened from Level Selection or Gameplay screens
- **UI Elements:**
    - Close button (X)
    - **Toggles:**
        - Sound (on/off toggle)
        - Music (on/off toggle)
        - Vibrations (on/off toggle)
    - **Buttons:**
        - "Send Feedback" button
        - "Remove Ads" button (IAP)
    - **Links:**
        - Privacy policy link
        - Terms & conditions link
- **Behavior:** Settings are saved locally and persist across sessions

---

## Progression System

- **Star Collection:** Each level can earn up to 3 stars (one per difficulty)
- **Unlock Logic:**
    - When player completes EASY difficulty of Level N.
    - Level N+1 unlocks.
    - Level N's Normal Mode unlocks
    - Hard mode for any level unlocks after completing that level on Normal
- **Content:** 20 levels for MVP

---

## Visual Design

- **Premium Minimalistic UI:** Clean interfaces, generous whitespace, smooth animations
- **Christmas Palette:** Reds, greens, golds, whites with subtle sparkle effects
- **Image Content:** High-quality Christmas scenes (ornaments, snow scenes, Santa, reindeer, etc.)

---

## Audio

- Soft background Christmas music (can be toggled via Settings)
- Subtle tile click sounds (can be toggled via Settings)
- Haptic feedback/vibrations (can be toggled via Settings)
- Victory jingle on level complete

---

## Technical Notes

- **Save System:** Local storage for progress, stars, and unlocked levels
- **Performance:** Optimize for 60 FPS on mid-range devices
- **Orientation:** Portrait mode
- **Resolution:** Support for common mobile aspect ratios

---

## Future Features (Post-MVP)

- **Twist Mechanic:** Add tile rotation for increased difficulty
- **Spiral Puzzle Type:** Circular/spiral puzzle arrangement
- **Daily Puzzle:** New puzzle every day with special rewards
- **Monthly Awards:** Trophy system tracking monthly completions
- **Achievement System:** Badges for milestones (complete all Easy, get all stars, etc.)
- **Timed Mode:** Race against the clock
- **Undo Button:** Reverse recent moves
- **Gallery:** View completed images in full resolution
- **Multiple Theme Packs:** Halloween, Easter, Summer, etc.
- **Social Features:** Share completed puzzles, leaderboards
- **Ad Integration:** Banner ads, rewarded video for hints
- **In-App Purchases:** Unlock hint packs, buy level packs

---
