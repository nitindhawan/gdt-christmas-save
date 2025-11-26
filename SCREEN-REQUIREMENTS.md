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
  - Close button (✕): Top-left corner, ~80×80px, 72px font **[Updated]**, white X icon
  - Share button (⤴): Top-right corner, ~80×80px, 56px font **[Updated]**, white share icon

- **Level Preview Section** (center ~900×900px area):
  - Level Number: Centered above image, 64px font **[Updated: increased from 36px]**
  - Preview Image: 850-900px square **[CRITICAL]**, centered
  - Border: 4px gold rounded rectangle

- **Difficulty Buttons Section** (lower ~700px):
  - Container: VBoxContainer with 30px spacing **[Updated]**
  - Button Size: 850px width, 150px height each **[Updated]**
  - Button Font: 56px **[Updated: increased from 32px]**

**Button States**:
- **Play Easy**: Green (#165B33) if unlocked, Grey (#757575) if locked
  - Text: "Play Easy ⭐" (56px font) **[Updated]**
- **Play Normal**: Same color logic + "Play Normal ⭐⭐" (56px font) **[Updated]**
- **Play Hard**: Same color logic + "Play Hard ⭐⭐⭐" (56px font) **[Updated]**
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

  **Arrow Puzzle Layout (Alternative to Rectangle Grid):**
  - **Puzzle Area** (900×900px, centered):
    - Background: Full level image (TextureRect, stretched to fit)
    - Arrows Container: Control overlay with grid of arrow nodes
    - Arrow Size: Calculated based on grid size (max 120px, with 10px spacing)
    - Grid centered in puzzle area
  - **Arrow Node Appearance**:
    - Size: 100×100px Control
    - Shadow: Dark background panel with 4px offset
    - Background: White glow panel with 3px inset
    - Arrow Texture: Rotated arrow image (0°/90°/180°/270° based on direction)
    - Semi-transparent to show level image beneath

- **Bottom HUD** (150-180px height):
  - Background: Semi-transparent dark overlay
  - Reserved for future features (hint system removed)

### Interaction States

**Rectangle Jigsaw**:
- **Tile Selection**:
  - First tap: Highlight with gold border, scale up
  - Second tap (different): Swap with animation (0.2-0.4s tween) **[Target]**
  - Second tap (same): Deselect, remove highlight

**Arrow Puzzle**:
- **Arrow Tap**: Attempt movement in arrow's direction
  - Success: Arrow exits and disappears (0.15s fade)
  - Blocked: Arrow bounces back (0.2s animation) + error sound

**Common**:
- **Back Button**: Show confirmation dialog (see below)

### Confirmation Dialog (Back Button) **[Updated]**
- **Dialog Size**: 850px width, 700px height, centered **[Updated: custom scene]**
- **Background Panel**: Dark brown Color(0.15, 0.12, 0.12, 1) **[Updated: matches settings popup]**
  - Corner radius: 20px **[Updated]**
  - Padding: 60px all around **[Updated]**
- **Title**: "Exit Level?", 80px font **[Updated: larger]**, light beige Color(0.866, 0.745, 0.722, 1) **[Updated: matches settings]**
- **Text**: "Exit level? Progress will not be saved.", 56px font **[Updated: larger]**, light beige color **[Updated: matches settings]**
- **Buttons**: 320×120px each **[Updated: even larger for mobile]**, 40px gap **[Updated]**
  - **Exit Button**: Red background Color(0.77, 0.12, 0.23, 1.0) (#C41E3A) **[Updated: styled]**
    - Font: 60px, White text **[Updated: larger]**
    - Corner radius: 20px **[Updated]**
    - Pressed state: Darker red Color(0.65, 0.1, 0.2, 1.0) **[Updated]**
  - **Stay Button**: Green background Color(0.09, 0.36, 0.2, 1.0) (#165B33) **[Updated: styled]**
    - Font: 60px, White text **[Updated: larger]**
    - Corner radius: 20px **[Updated]**
    - Pressed state: Darker green Color(0.07, 0.3, 0.17, 1.0) **[Updated]**
- **Implementation**: Custom scene (exit_confirmation_dialog.tscn) with signal-based communication **[Updated]**

---

## Screen 5: Level Complete

### Layout
- **Title Section** (top ~400px):
  - "Well Done!" text:
    - Position: Centered, upper area
    - Font: Title font, 72px **[Updated]**, Gold color
    - Animation: Fade in + scale up (0.4-0.6s) **[Target]**
  - Subtitle: "You have solved Level N" (centered, 56px **[Updated: increased from 36px]**, White)
  - Stars Display:
    - Position: Centered below subtitle
    - Size: 3 stars, each 80px **[Updated]**, spacing 20px **[Updated]**
    - Animation: Pop in sequentially with 0.1-0.2s delay **[Target]**

- **Completed Image Section** (center ~900×900px area):
  - Image: 850px square **[Updated]**, centered
  - Border: 6px gold rounded rectangle **[Updated]**
  - Corner badge: Small "✓" icon (50-60px) top-right

- **Button Section** (lower ~400px):
  - **Share Button**: 750px width, 100px height **[Updated]**
    - Background: Transparent with white border
    - Icon + Text: "⤴ Share Photo" (56px font) **[Updated: increased from 32px]**
  - **Download Button**: 750px width, 100px height **[Updated]**
    - Icon + Text: "💾 Download" (56px font) **[Updated: increased from 32px]**
  - **Continue Button**: 750px width, 130px height **[Updated]**
    - Background: Green (#165B33)
    - Text: "Continue", 60px font **[Updated: increased from 36px]**, White
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
- **Modal Background**: Full screen rgba(0, 0, 0, 0.85) **[CRITICAL - Updated: darker overlay for better contrast]**
- **Modal Panel**:
  - Size: 850px width, 1200px height **[CRITICAL]**
  - Position: Centered
  - Background: Dark brown Color(0.15, 0.12, 0.12, 1) or rgba(38, 31, 31, 1) **[Updated: solid background]**
  - Border radius: 20px **[Updated: consistent rounding]**
  - Padding/Margins: 50px all around **[Updated: increased breathing room]**

- **Header** (~100px):
  - Title "Settings": Left side, 96px font **[Updated]**, Color(0.866, 0.745, 0.722, 1) beige/tan **[Updated]**
  - Close button (✕): Right side, 60×60px, same beige color

- **Toggle Section** (middle ~480px) **[Updated: more compact]**:
  - 3 toggle items, each 120px height **[Updated]**, 60px gap between rows **[Updated: better spacing]**
  - Section separation: 50px **[Updated]**
  - Layout per item (HBoxContainer with alignment=1 for vertical centering):
    - Label: Left side, 64px font **[Updated]**, beige color, expands to fill (size_flags_horizontal=3)
    - Horizontal gap between label and button: 30px **[Updated]**
    - Toggle Button: Right side, **240×100px** **[CRITICAL - Updated: custom buttons instead of switches]**
      - Font size: 56px **[Updated]**
      - Text: "ON" or "OFF" **[Updated: explicit state text]**
      - Corner radius: 16px **[Updated]**
      - Colors **[Updated: clear visual states]**:
        - ON state: Green Color(0.2, 0.7, 0.3, 1.0), White text
        - OFF state: Gray Color(0.4, 0.4, 0.4, 1.0), White text
  - Items: Sound, Music, Vibrations

- **Button Section** (~300px):
  - Section spacing from toggles: 50px **[Updated]**
  - **Send Feedback**: 720px width, 110px height **[Updated: specific sizes]**
    - Background: Default button style
    - Text: 64px font **[Updated]**, White
  - **Remove Ads**: Same sizing
    - Background: Default button style
  - Button spacing: 20px **[Updated]**

- **Footer Links** (~100px):
  - Container: HBoxContainer, centered, 40px gap **[Updated]**
  - "Privacy" link: 56px font **[Updated]**, Blue Color(0, 0.4, 0.8, 1) **[Updated]**
  - Separator: " | ", grey, 28px font
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
