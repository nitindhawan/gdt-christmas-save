# Screen Requirements - Save the Christmas

## Resolution & Display Settings
- **Base Resolution**: 1080×1920 pixels (9:16 portrait aspect ratio)
- **Viewport Mode**: canvas_items stretch with aspect expand
- **Orientation**: Portrait mode only (locked)
- **Safe Areas**: Account for 40px top/bottom margins for notches and navigation bars

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
  - H1 (Screen Titles): 72px
  - H2 (Section Headers): 48px
  - H3 (Level Numbers): 36px
  - Body (Buttons, Labels): 32px
  - Small (Captions): 24px

---

## Screen 1: Loading Screen

### Layout Specifications
```
┌─────────────────────────────┐
│         (Safe Area)         │ 40px
├─────────────────────────────┤
│                             │
│         [GAME LOGO]         │ 300×300px
│                             │ Centered vertically (top 40%)
│                             │
├─────────────────────────────┤
│                             │
│      ████████░░░░░░░        │ ProgressBar
│       Loading...            │ Width: 600px, Height: 40px
│                             │ Centered (bottom 20%)
│                             │
├─────────────────────────────┤
│         (Safe Area)         │ 40px
└─────────────────────────────┘
```

### Component Details
- **Background**: Christmas-themed gradient or static image
- **Game Logo**:
  - Size: 300×300px
  - Position: Centered horizontally, Y=480px from top
  - Asset: `res://assets/ui/logo.png`
- **ProgressBar**:
  - Size: 600×40px
  - Position: Centered horizontally, Y=1400px from top
  - Style: Rounded corners (20px radius), Christmas red fill
  - Progress range: 0-100%
- **Loading Text**:
  - Font Size: 32px
  - Position: Below ProgressBar (Y=1460px)
  - Color: White
  - Text: "Loading..."

### Behavior
- Display for minimum 1 second to show branding
- Load level data, audio assets, settings
- On complete:
  - If `current_level == 1` → Navigate to Gameplay Screen (Level 1 Easy)
  - If `current_level > 1` → Navigate to Level Selection

---

## Screen 2: Level Selection

### Layout Specifications
```
┌─────────────────────────────┐
│   Save the Christmas    ⚙️  │ Title + Settings button
├─────────────────────────────┤
│  ┌────┐  ┌────┐             │
│  │Lv1 │  │Lv2 │             │ 2-column grid
│  │⭐⭐⭐│  │⭐⭐░│             │ Scrollable
│  └────┘  └────┘             │
│  ┌────┐  ┌────┐             │
│  │Lv3 │  │Lv4 │             │
│  │░░░ │  │🔒  │             │
│  └────┘  └────┘             │
│    ...scrollable...         │
└─────────────────────────────┘
```

### Component Details

#### Title Bar (Top 100px)
- **Background**: Semi-transparent dark overlay
- **Title Text**: "Save the Christmas"
  - Font: Title font, 60px
  - Position: Centered horizontally, Y=30px from top
  - Color: Gold (#FFD700)
- **Settings Button**:
  - Size: 80×80px
  - Position: Top-right corner (X=960px, Y=30px)
  - Icon: Gear icon (white)
  - Touch area: 100×100px (larger than visual)

#### Level Grid (Scrollable)
- **Container**: ScrollContainer starting at Y=120px
- **Grid**: GridContainer with 2 columns
- **Column Gap**: 40px
- **Row Gap**: 40px
- **Margins**: 40px left/right

#### Level Cell (Per Item)
- **Size**: 460×560px per cell
- **Background**:
  - Unlocked: Full-color level thumbnail (preview of level image)
  - Locked: Greyed out thumbnail (desaturated)
- **Border**: 4px rounded rectangle
  - Unlocked unbeaten: Green border
  - Beaten: Gold border
  - Locked: Grey border
- **Level Number Label**:
  - Position: Top-left corner of cell (20px, 20px)
  - Background: Semi-transparent dark circle (60px diameter)
  - Text: "Level N", Font size 28px, Color: White
- **Star Display**:
  - Position: Bottom-center of cell
  - Size: 3 stars, each 50×50px
  - Spacing: 10px between stars
  - Filled stars: Gold color
  - Empty stars: Grey outline
- **Icon Overlay**:
  - Unlocked unbeaten: Play icon (▶) centered, 100×100px, semi-transparent white
  - Locked: Lock icon (🔒) centered, 100×100px, white
  - Beaten: No icon (stars visible)

### Interaction States
- **Hover/Touch**: Scale up to 1.05× with 0.2s tween
- **Click**:
  - Beaten level → Difficulty Selection screen
  - Unlocked unbeaten → Gameplay screen (Easy)
  - Locked → Show toast message "Complete previous level to unlock"

---

## Screen 3: Difficulty Selection

### Layout Specifications
```
┌─────────────────────────────┐
│ ✕                       ⤴   │ Close + Share buttons
├─────────────────────────────┤
│                             │
│      Level 4                │ Level number
│                             │
│    [PREVIEW IMAGE]          │ Full level preview
│                             │ 900×900px
│                             │
├─────────────────────────────┤
│   [Play Easy]      ⭐       │ Button + star indicator
│   [Play Normal]    ⭐⭐     │
│   [Play Hard]      ⭐⭐⭐   │
└─────────────────────────────┘
```

### Component Details

#### Top Bar (100px height)
- **Close Button (✕)**:
  - Size: 80×80px
  - Position: Top-left (X=30px, Y=30px)
  - Icon: X icon, white, 40×40px
  - Touch area: 100×100px
- **Share Button (⤴)**:
  - Size: 80×80px
  - Position: Top-right (X=970px, Y=30px)
  - Icon: Share icon, white, 40×40px
  - Touch area: 100×100px

#### Level Preview Section (Y=120px to Y=1120px)
- **Level Number Label**:
  - Position: Centered, Y=140px
  - Font: H3 (36px), Color: White
  - Text: "Level N"
- **Preview Image**:
  - Size: 900×900px
  - Position: Centered horizontally, Y=200px from top
  - Border: 4px gold rounded rectangle
  - Display: Full level image (not scrambled)

#### Difficulty Buttons Section (Y=1150px to Y=1850px)
- **Button Container**: VBoxContainer with 30px spacing
- **Button Dimensions**: 900×160px each

**Button 1: Play Easy**
- Position: Y=1160px
- Background: Green (#165B33) if unlocked, Grey (#757575) if locked
- Text: "Play Easy" + 1 star icon
  - Font: Body (32px), Color: White
  - Star: 50×50px, gold, aligned right
- State:
  - Unlocked: Full opacity, clickable
  - Locked: 50% opacity, lock icon left, non-clickable

**Button 2: Play Normal**
- Position: Y=1350px
- Background: Green if unlocked, Grey if locked
- Text: "Play Normal" + 2 star icons
- States: Same as Easy button

**Button 3: Play Hard**
- Position: Y=1540px
- Background: Green if unlocked, Grey if locked
- Text: "Play Hard" + 3 star icons
- States: Same as Easy button

### Interaction
- **Close Button**: Return to Level Selection
- **Share Button**: Open native share sheet with level preview image
- **Enabled Difficulty Button**: Navigate to Gameplay screen with selected difficulty
- **Disabled Difficulty Button**: No action (or show tooltip "Complete previous difficulty to unlock")

---

## Screen 4: Gameplay Screen

### Layout Specifications
```
┌─────────────────────────────┐
│ ◀  Level 5    ⤴  ⚙️         │ Top HUD
├─────────────────────────────┤
│                             │
│    ┌──┬──┬──┬──┐            │
│    │  │  │  │  │            │ Puzzle grid
│    ├──┼──┼──┼──┤            │ (size varies by difficulty)
│    │  │  │  │  │            │
│    ├──┼──┼──┼──┤            │
│    │  │  │  │  │            │
│    └──┴──┴──┴──┘            │
│                             │
├─────────────────────────────┤
│       [Hint Button]         │ Bottom HUD
└─────────────────────────────┘
```

### Component Details

#### Top HUD (120px height, Y=0px to Y=120px)
- **Background**: Semi-transparent dark overlay (rgba(0,0,0,0.4))
- **Back Button (◀)**:
  - Size: 80×80px
  - Position: X=30px, Y=20px
  - Icon: Left arrow, white
  - Touch area: 100×100px
- **Level Number Label**:
  - Position: Centered horizontally, Y=40px
  - Font: H3 (36px), Color: White
  - Text: "Level N"
- **Share Button (⤴)**:
  - Size: 80×80px
  - Position: X=820px, Y=20px
  - Icon: Share icon, white
- **Settings Button (⚙️)**:
  - Size: 80×80px
  - Position: X=940px, Y=20px
  - Icon: Gear icon, white

#### Puzzle Area (Y=140px to Y=1740px)
- **Container**: CenterContainer for puzzle grid
- **Grid Sizing** (varies by difficulty):

  **Easy (2×3):**
  - Total grid: 900×1350px
  - Tile size: 300×450px each

  **Normal (3×4):**
  - Total grid: 900×1200px
  - Tile size: 300×300px each

  **Hard (5×6):**
  - Total grid: 900×1500px
  - Tile size: 180×250px each

- **Tile Appearance**:
  - Border: 2px white border between tiles
  - Selected: 8px gold border, scale 1.05×
  - Unselected: Normal state
  - Texture: AtlasTexture displaying region of source image

#### Bottom HUD (180px height, Y=1740px to Y=1920px)
- **Background**: Semi-transparent dark overlay
- **Hint Button**:
  - Size: 600×120px
  - Position: Centered horizontally, Y=1770px
  - Background: Gold (#FFD700)
  - Text: "💡 Hint", Font: Body (32px), Color: Dark brown
  - Border radius: 20px
  - Touch area: Same as button size

### Interaction States
- **Tile Selection**:
  - First tap: Highlight tile with gold border, scale up
  - Second tap (different tile): Swap tiles with 0.3s tween animation
  - Second tap (same tile): Deselect tile, remove highlight
- **Hint Button**:
  - Click: Automatically swap one incorrect tile to correct position
  - Animation: Sparkle effect on swapping tiles
- **Back Button**:
  - Click: Show confirmation dialog (see below)
- **Share/Settings**:
  - Click: Open respective screens/popups

### Confirmation Dialog (Back Button)
```
┌─────────────────────────┐
│  Exit Level?            │
│                         │
│  Progress will not be   │
│  saved.                 │
│                         │
│  [Stay]     [Exit]      │
└─────────────────────────┘
```
- **Dialog Size**: 700×400px, centered
- **Background**: White with dark border
- **Text**: Body font (28px), centered
- **Buttons**: 300×100px each, 40px gap
  - Stay: Green background
  - Exit: Red background

---

## Screen 5: Level Complete

### Layout Specifications
```
┌─────────────────────────────┐
│                             │
│       Well Done!            │ Title
│  You have solved Level 5    │ Subtitle
│                             │
│      ⭐⭐⭐                  │ Stars earned
│                             │
│    [COMPLETED IMAGE]        │ 900×900px
│                             │
│     ⤴ Share Photo           │ Share button
│                             │
│      [Continue]             │ Continue button
└─────────────────────────────┘
```

### Component Details

#### Title Section (Y=100px to Y=400px)
- **"Well Done!" Text**:
  - Position: Centered, Y=120px
  - Font: Title font, 72px
  - Color: Gold (#FFD700)
  - Animation: Fade in + scale up (0.5s)
- **Subtitle Text**:
  - Position: Centered, Y=220px
  - Font: H3 (36px)
  - Color: White
  - Text: "You have solved Level N"
- **Stars Display**:
  - Position: Centered, Y=300px
  - Size: 3 stars, each 80×80px, 20px spacing
  - Filled: Based on difficulty (1, 2, or 3 stars in gold)
  - Animation: Pop in sequentially with 0.2s delay each

#### Completed Image Section (Y=420px to Y=1380px)
- **Image Display**:
  - Size: 900×900px
  - Position: Centered horizontally, Y=430px
  - Border: 8px gold rounded rectangle
  - Display: Solved level image (full, not tiled)
  - Corner badge: Small "✓" icon (60×60px) top-right

#### Button Section (Y=1400px to Y=1820px)
- **Share Button**:
  - Size: 800×100px
  - Position: Centered horizontally, Y=1420px
  - Background: Transparent with white border
  - Icon + Text: Share icon + "Share Photo"
  - Font: Body (32px), Color: White
- **Download Button** (optional, below Share):
  - Size: 800×100px
  - Position: Y=1540px
  - Background: Transparent with white border
  - Icon + Text: Download icon + "Download"
- **Continue Button**:
  - Size: 800×140px
  - Position: Centered horizontally, Y=1660px
  - Background: Green (#165B33)
  - Text: "Continue", Font: Body (36px), Color: White
  - Border radius: 20px

### Interaction
- **Share Button**: Open native share sheet with completed image
- **Download Button**: Save completed image to device gallery (requires permissions)
- **Continue Button**:
  - If next level exists → Navigate to next level Gameplay (Easy mode)
  - If last level → Navigate to Level Selection

---

## Screen 6: Settings Popup (Modal Overlay)

### Layout Specifications
```
┌─────────────────────────────┐
│                             │
│  ┌────────────────────┐     │
│  │  Settings       ✕  │     │ Modal header
│  ├────────────────────┤     │
│  │                    │     │
│  │  Sound      [  ]   │     │ Toggle switches
│  │  Music      [  ]   │     │
│  │  Vibrations [  ]   │     │
│  │                    │     │
│  │  [Send Feedback]   │     │ Buttons
│  │  [Remove Ads]      │     │
│  │                    │     │
│  │  Privacy | Terms   │     │ Links
│  └────────────────────┘     │
│                             │
└─────────────────────────────┘
```

### Component Details

#### Modal Background
- **Overlay**: Full screen rgba(0,0,0,0.6)
- **Modal Panel**:
  - Size: 900×1200px
  - Position: Centered
  - Background: White
  - Border radius: 30px

#### Header (100px height)
- **Title "Settings"**:
  - Position: X=60px, Y=40px
  - Font: H2 (48px), Color: Dark brown
- **Close Button (✕)**:
  - Position: Top-right (X=820px, Y=30px)
  - Size: 60×60px
  - Icon: X icon, dark brown

#### Toggle Section (Y=120px to Y=600px)
- **Toggle Items**: 3 rows, each 160px height, 30px gap
- **Toggle Item Layout**:
  - Label: X=80px, Font: Body (32px), Color: Dark brown
  - Switch: X=700px, Size: 120×60px
  - Switch colors: On=Green, Off=Grey

**Sound Toggle**: Y=140px
**Music Toggle**: Y=330px
**Vibrations Toggle**: Y=520px

#### Button Section (Y=640px to Y=960px)
- **Send Feedback Button**:
  - Size: 740×120px
  - Position: Centered, Y=660px
  - Background: Red (#C41E3A)
  - Text: "Send Feedback", Font: Body (32px), Color: White
  - Border radius: 15px
- **Remove Ads Button**:
  - Size: 740×120px
  - Position: Centered, Y=820px
  - Background: Green (#165B33)
  - Text: "Remove Ads", Font: Body (32px), Color: White
  - Border radius: 15px

#### Footer Links (Y=1000px to Y=1100px)
- **Container**: HBoxContainer, centered, 40px gap
- **Privacy Link**:
  - Text: "Privacy", Font: Body (28px), Color: Blue (#0066CC)
  - Underline on hover
- **Separator**: " | ", grey
- **Terms Link**:
  - Text: "Terms", Font: Body (28px), Color: Blue (#0066CC)
  - Underline on hover

### Interaction
- **Close Button**: Close popup, return to previous screen
- **Tap outside modal**: Close popup
- **Toggles**: Immediate effect, save to settings on close
- **Send Feedback**: Open email client or feedback form
- **Remove Ads**: Trigger IAP flow (if implemented)
- **Links**: Open browser with respective URLs

---

## Responsive Design Notes

### Safe Area Handling
- All important UI elements must respect safe areas
- Top margin: 40px minimum
- Bottom margin: 40px minimum (80px if device has home indicator)
- Test on devices: iPhone 14 Pro (Dynamic Island), Samsung Galaxy S23 (punch-hole)

### Touch Target Sizes
- Minimum touch target: 88×88px (44×44 points @2x)
- Buttons should have padding beyond visual bounds for easier tapping
- Maintain 20px spacing between adjacent interactive elements

### Landscape Support (Future)
- MVP: Portrait only, lock orientation
- Future: Adapt layouts for landscape mode

### Accessibility
- High contrast text (WCAG AA compliance)
- Scalable fonts (consider accessibility settings)
- Alternative text for images (screen reader support)

---

## Animation & Transitions

### Screen Transitions
- **Default**: 0.3s fade with slight slide (50px)
- **Modal Open**: 0.2s scale up from 0.8 to 1.0
- **Modal Close**: 0.2s scale down to 0.8 with fade out

### Button Interactions
- **Hover/Touch**: 0.1s scale to 1.05
- **Press**: 0.05s scale to 0.95
- **Release**: 0.1s return to 1.0

### Tile Swapping
- **Swap Animation**: 0.3s ease-in-out
- **Selection Highlight**: 0.1s border color fade

### Level Complete Animations
- **Title**: 0.5s fade in + scale (elastic easing)
- **Stars**: 0.3s each, sequential with 0.2s delay, pop effect
- **Image**: 0.4s fade in

## Performance Requirements
- Maintain 60 FPS on all screens
- Smooth scrolling in Level Selection (no frame drops)
- Tile swap animations must be 60 FPS
- Image loading: Show placeholder/spinner if load time > 0.5s
