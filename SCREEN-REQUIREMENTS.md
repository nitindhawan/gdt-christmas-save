# Screen Requirements - Save the Christmas

**Related Documentation**:
- **GAME-RULES.md** - Gameplay mechanics and user flows
- **ARCHITECTURE-MASTER.md** - System overview and scene flow
- **DATA-SCHEMA.md** - Data structures

---

## Resolution & Display Settings
- **Base Resolution**: 1080×1920 pixels (9:16 portrait aspect ratio) **[CRITICAL]**
- **Viewport Mode**: canvas_items stretch with aspect expand **[CRITICAL]**
- **Orientation**: Portrait mode only (locked) **[CRITICAL]**
- **Safe Areas**: 40px top/bottom margins for notches and navigation bars **[CRITICAL]**

## Color Palette (Christmas Theme)
- **Primary Red**: #C41E3A (Buttons, accents)
- **Primary Green**: #165B33 (Secondary buttons, success states)
- **Gold**: #FFD700 (Stars, highlights)
- **White**: #FFFFFF (Text, backgrounds)
- **Dark Brown**: #3E2723 (Text, UI borders)
- **Background Gradient**: #8B0000 to #4A0000 (Deep red gradient)
- **Overlay**: rgba(0, 0, 0, 0.6) (Modal backgrounds)

## Typography
- **Primary Font**: "Roboto" or "Open Sans" (sans-serif, premium feel)
- **Title Font**: "Mountains of Christmas" or similar decorative Christmas font
- **Sizes**:
  - H1 (Screen Titles): 60-72px
  - H2 (Section Headers): 40-48px
  - H3 (Level Numbers): 32-36px
  - Body (Buttons, Labels): 28-32px
  - Small (Captions): 20-24px

---

## Screen 1: Loading Screen

### Layout
- **Background**: Christmas-themed gradient or static image (full screen)
- **Game Logo**:
  - Size: ~300×300px
  - Position: Centered horizontally, upper-center area (~25% from top)
- **ProgressBar**:
  - Size: 500-600px width, 30-40px height
  - Position: Centered, lower area (~70-75% from top)
  - Style: Rounded corners, Christmas red fill
  - Progress range: 0-100%
- **Loading Text**:
  - Font Size: 28-32px
  - Position: Below ProgressBar
  - Color: White
  - Text: "Loading..."

### Behavior
- Display for minimum 1 second to show branding
- Load level data, audio assets, settings
- Navigate based on current_level:
  - If level == 1 → Gameplay Screen (Level 1 Easy)
  - If level > 1 → Level Selection

---

## Screen 2: Level Selection

### Layout
- **Title Bar** (top ~100px):
  - Title: "Save the Christmas" (centered, Title font, 60px, Gold color)
  - Settings button (top-right corner, ~80×80px, gear icon)

- **Level Grid** (scrollable):
  - Container: ScrollContainer, 2-column GridContainer
  - Column/Row gap: 30-40px
  - Side margins: 30-40px

### Level Cell
- **Size**: ~460×560px per cell **[CRITICAL for grid layout]**
- **Background**: Level thumbnail (full-color if unlocked, desaturated if locked)
- **Border**: 3-4px rounded rectangle
  - Unlocked unbeaten: Green border
  - Beaten: Gold border
  - Locked: Grey border
- **Level Number Label**:
  - Position: Top-left corner (inset 15-20px)
  - Background: Semi-transparent dark circle (50-60px diameter)
  - Text: "Level N", Font size 24-28px, Color: White
- **Star Display**:
  - Position: Bottom-center of cell
  - Size: 3 stars, each 40-50px
  - Spacing: 8-10px between stars
  - Filled stars: Gold, Empty stars: Grey outline
- **Icon Overlay** (centered):
  - Unlocked unbeaten: Play icon (▶) 80-100px, semi-transparent white
  - Locked: Lock icon (🔒) 80-100px, white
  - Beaten: No icon (stars visible)

### Interaction States
- **Touch feedback**: Scale up to 1.05× with 0.1-0.2s animation **[Target]**
- **Click**:
  - Beaten level → Difficulty Selection screen
  - Unlocked unbeaten → Gameplay screen (Easy)
  - Locked → Toast message "Complete previous level to unlock"

---

## Screen 3: Difficulty Selection

### Layout
- **Top Bar** (~100px):
  - Close button (✕): Top-left corner, ~80×80px, white X icon
  - Share button (⤴): Top-right corner, ~80×80px, white share icon

- **Level Preview Section** (center ~900×900px area):
  - Level Number: Centered above image, 32-36px font
  - Preview Image: 850-900px square **[CRITICAL]**, centered
  - Border: 4px gold rounded rectangle

- **Difficulty Buttons Section** (lower ~700px):
  - Container: VBoxContainer with 20-30px spacing
  - Button Size: 850-900px width, 140-160px height each

**Button States**:
- **Play Easy**: Green (#165B33) if unlocked, Grey (#757575) if locked
  - Text: "Play Easy" + 1 star icon (40-50px, gold)
- **Play Normal**: Same color logic + 2 star icons
- **Play Hard**: Same color logic + 3 star icons
- **Locked state**: 50% opacity, lock icon (left side)

### Interaction
- Close → Return to Level Selection
- Share → Native share sheet with level preview
- Enabled button → Navigate to Gameplay
- Disabled button → No action or tooltip

---

## Screen 4: Gameplay Screen

### Layout
- **Top HUD** (100-120px height): **[CRITICAL]**
  - Background: Semi-transparent dark overlay
  - Back button (◀): Left side, ~80×80px
  - Level Number: Centered, 32-36px font, White
  - Share button (⤴): Right side, offset left, ~80×80px
  - Settings button (⚙️): Right side, ~80×80px

- **Puzzle Area** (centered, main area):
  **Grid Sizing [CRITICAL - varies by difficulty]:**

  - **Easy (2×3)**:
    - Total grid: ~900×1350px
    - Tile size: ~300×450px each

  - **Normal (3×4)**:
    - Total grid: ~900×1200px
    - Tile size: ~300×300px each

  - **Hard (5×6)**:
    - Total grid: ~900×1500px
    - Tile size: ~180×250px each

  - **Tile Appearance**:
    - Border: 2px white between tiles **[CRITICAL]**
    - Selected: 6-8px gold border, scale 1.03-1.05× **[Target]**
    - Texture: AtlasTexture displaying region of source image

- **Bottom HUD** (150-180px height):
  - Background: Semi-transparent dark overlay
  - Hint Button:
    - Size: 500-600px width, 100-120px height
    - Position: Centered
    - Background: Gold (#FFD700)
    - Text: "💡 Hint", Font: 28-32px, Color: Dark brown
    - Border radius: 15-20px

### Interaction States
- **Tile Selection**:
  - First tap: Highlight with gold border, scale up
  - Second tap (different): Swap with animation (0.2-0.4s tween) **[Target]**
  - Second tap (same): Deselect, remove highlight
- **Hint Button**: Auto-swap one incorrect tile with sparkle effect
- **Back Button**: Show confirmation dialog (see below)

### Confirmation Dialog (Back Button)
- **Dialog Size**: 600-700px width, 350-400px height, centered
- **Background**: White with dark border
- **Text**: "Exit Level? Progress will not be saved." (centered, 24-28px)
- **Buttons**: 250-300px width, 80-100px height each, 30-40px gap
  - Stay: Green background
  - Exit: Red background

---

## Screen 5: Level Complete

### Layout
- **Title Section** (top ~400px):
  - "Well Done!" text:
    - Position: Centered, upper area
    - Font: Title font, 60-72px, Gold color
    - Animation: Fade in + scale up (0.4-0.6s) **[Target]**
  - Subtitle: "You have solved Level N" (centered, 32-36px, White)
  - Stars Display:
    - Position: Centered below subtitle
    - Size: 3 stars, each 70-80px, spacing 15-20px
    - Animation: Pop in sequentially with 0.1-0.2s delay **[Target]**

- **Completed Image Section** (center ~900×900px area):
  - Image: 850-900px square, centered
  - Border: 6-8px gold rounded rectangle
  - Corner badge: Small "✓" icon (50-60px) top-right

- **Button Section** (lower ~400px):
  - **Share Button**: 700-800px width, 80-100px height
    - Background: Transparent with white border
    - Icon + Text: "Share Photo"
  - **Download Button** (optional): Same sizing as Share
  - **Continue Button**: 700-800px width, 120-140px height
    - Background: Green (#165B33)
    - Text: "Continue", 32-36px font, White
    - Border radius: 15-20px

### Interaction
- Share → Native share sheet
- Download → Save to gallery (requires permissions)
- Continue:
  - Next level exists → Navigate to next level Gameplay (Easy)
  - Last level → Navigate to Level Selection

---

## Screen 6: Settings Popup (Modal)

### Layout
- **Modal Background**: Full screen rgba(0, 0, 0, 0.6) **[CRITICAL]**
- **Modal Panel**:
  - Size: 850-900px width, 1100-1200px height
  - Position: Centered
  - Background: White
  - Border radius: 25-30px

- **Header** (~100px):
  - Title "Settings": Left side, 40-48px font, Dark brown
  - Close button (✕): Right side, ~60×60px, dark brown X

- **Toggle Section** (middle ~400px):
  - 3 toggle items, each ~150px height, 20-30px gap
  - Layout per item:
    - Label: Left side, 28-32px font, Dark brown
    - Switch: Right side, 100-120px width, 50-60px height
    - Colors: On=Green, Off=Grey
  - Items: Sound, Music, Vibrations

- **Button Section** (~300px):
  - **Send Feedback**: 700-740px width, 100-120px height
    - Background: Red (#C41E3A)
    - Text: 28-32px, White
  - **Remove Ads**: Same sizing
    - Background: Green (#165B33)

- **Footer Links** (~100px):
  - Container: HBoxContainer, centered, 30-40px gap
  - "Privacy" link: 24-28px, Blue (#0066CC), underline on touch
  - Separator: " | ", grey
  - "Terms" link: Same as Privacy

### Interaction
- Close/Outside tap → Close popup
- Toggles → Immediate effect, save on close
- Buttons → Open respective flows
- Links → Open browser

---

## Animation & Transitions **[Target Values]**

### Screen Transitions
- Default: 0.2-0.4s fade with slight slide
- Modal Open: 0.15-0.25s scale up from 0.8 to 1.0
- Modal Close: 0.15-0.25s scale down with fade

### Button Interactions
- Touch: 0.08-0.12s scale to 1.03-1.05
- Press: 0.04-0.06s scale to 0.92-0.95
- Release: 0.08-0.12s return to 1.0

### Tile Swapping
- Swap Animation: 0.2-0.4s ease-in-out
- Selection Highlight: 0.08-0.12s border color fade

### Level Complete Animations
- Title: 0.4-0.6s fade in + scale (elastic easing)
- Stars: 0.2-0.3s each, sequential with 0.1-0.2s delay, pop effect
- Image: 0.3-0.5s fade in

---

## Responsive Design & Touch

### Safe Area Handling **[CRITICAL]**
- Top margin: 40px minimum
- Bottom margin: 40px minimum (80px if device has home indicator)
- Test on: iPhone 14 Pro (Dynamic Island), Samsung Galaxy S23

### Touch Target Sizes **[CRITICAL]**
- Minimum touch target: 88×88px (44×44 points @2x)
- Buttons: Padding beyond visual bounds for easier tapping
- Spacing: Minimum 20px between adjacent interactive elements

### Accessibility
- High contrast text (WCAG AA compliance)
- Scalable fonts (consider accessibility settings)
- Alternative text for images (screen reader support)

---

## Performance Requirements

- Maintain **60 FPS** on all screens **[CRITICAL]**
- Smooth scrolling in Level Selection (no frame drops)
- Tile swap animations must be 60 FPS
- Image loading: Show placeholder/spinner if load time > 0.5s

---

This document provides UI specifications for "Save the Christmas". Critical measurements marked **[CRITICAL]**, target values marked **[Target]**.
