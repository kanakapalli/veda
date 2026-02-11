




# DeskBubby Design Guidelines

## Design Philosophy

DeskBubby follows a **Neo-Minimalist Line Art** aesthetic inspired by architectural blueprints, Swiss design principles, and Bauhaus typography. This design system prioritizes clarity, focus, and intentionality through the strategic use of negative space, ultra-thin strokes, and a strict grid system.

---

## Core Design Principles

### 1. Minimalist Line Art / Wireframe Aesthetic
- **Ultra-thin strokes**: Use 0.5pt–1pt stroke widths for all line elements
- **No solid fills**: Prefer outlines and borders over filled shapes (except for small accent elements)
- **Geometric precision**: All elements follow mathematical proportions and grid alignment
- **Blueprint feel**: Design should evoke technical drawings and architectural sketches

### 2. Swiss Design Grid System
- **4-column vertical grid**: Screen divided into 4 equal columns with 0.5pt dividers
- **48px baseline grid**: Horizontal rhythm based on 48px increments
- **Strict alignment**: All elements snap to grid intersections
- **Hierarchical spacing**: Use multiples of 12px (12, 24, 48, 72, 96, 120)

### 3. Neo-Minimalism
- **Negative space is functional**: Empty areas guide user focus, not just decoration
- **Breathing room**: Generous padding (minimum 48px on screen edges)
- **One primary action per screen**: Reduce cognitive load through simplicity
- **Progressive disclosure**: Show only what's essential for the current task

### 4. Monochromatic Color Palette
- **Primary**: Pure black (`#000000`) or pure white (`#FFFFFF`) depending on theme
- **Secondary**: Grey scale only (`grey[500]`, `grey[700]`, `grey[800]`, `grey[900]`)
- **Accent**: Single blue accent (`#4A90E2`) used sparingly for:
  - Interactive indicators
  - Loading states
  - Key focal points (dots, icons)
- **Rule**: Never use more than 2 colors on a single screen

---

## Dark Mode Specification

### Color Values

```dart
// Background
backgroundColor: #000000 (Pure Black - AMOLED optimized)

// Grid Lines
gridLines: Colors.grey[900] (0.5pt stroke)

// Primary Text
primaryText: #FFFFFF (Pure White)

// Secondary Text
secondaryText: Colors.grey[500]

// Tertiary Text (Legal, footnotes)
tertiaryText: Colors.grey[700]

// Borders
defaultBorder: Colors.grey[800]
hoverBorder: #FFFFFF
accentBorder: #4A90E2

// Interactive Elements
primaryAccent: #4A90E2 (Blue)
hoverBackground: Colors.grey[900]
```

### Contrast Requirements
- **Primary text on black**: White (#FFFFFF) - 21:1 contrast ratio
- **Secondary text on black**: Grey[500] - minimum 7:1 contrast ratio
- **Interactive elements**: Must pass WCAG AAA standards (7:1+)

---

## Typography System

### Font Weights
- **Ultra Light (w300)**: Headings, display text
- **Regular (w400)**: Body text, labels
- **Never use bold** in minimalist contexts (exception: data emphasis)

### Type Scale

```dart
// Display (Titles)
displayLarge: {
  fontSize: 52pt,
  fontWeight: w300,
  letterSpacing: -1.2pt,
  height: 1.0,
  color: white
}

// Headings
headingMedium: {
  fontSize: 28pt,
  fontWeight: w300,
  letterSpacing: -0.5pt,
  color: white
}

// Body
bodyLarge: {
  fontSize: 16pt,
  fontWeight: w400,
  letterSpacing: 0.5pt,
  color: grey[500]
}

bodyMedium: {
  fontSize: 15pt,
  fontWeight: w400,
  letterSpacing: 0.3pt,
  color: white
}

// Small / Legal
caption: {
  fontSize: 11pt,
  fontWeight: w400,
  letterSpacing: 0.2pt,
  height: 1.6,
  color: grey[700]
}
```

### Typography Rules
1. **Left-align all text** (never center unless it's a numeric display)
2. **Maximum 60-80 characters per line** for readability
3. **Use letter-spacing judiciously**: Negative for large text, positive for small
4. **Line height**: 1.0 for display, 1.6 for body text
5. **Never use ALL CAPS** except for 8pt+ tracking acronyms

---

## Component Specifications

### 1. Buttons

#### Primary Action Button (Minimalist)
```dart
Container(
  height: 56,
  decoration: BoxDecoration(
    color: transparent → grey[900] (on hover),
    border: Border.all(
      color: grey[800] → white (on hover),
      width: 1,
    ),
  ),
)
```

**States:**
- **Default**: 1pt grey[800] border, transparent background
- **Hover**: 1pt white border, grey[900] background
- **Active**: Same as hover with subtle ink splash (grey[900])
- **Disabled**: 1pt grey[900] border, 50% opacity

**Layout:**
- Height: 56px (fixed)
- Padding: 24px horizontal
- Icon-text spacing: 16px
- Arrow indicator: 18px, right-aligned

#### Loading Indicator
```dart
CircularProgressIndicator(
  strokeWidth: 1,
  valueColor: AlwaysStoppedAnimation(primaryLight),
)
```

### 2. Logo / Iconography

#### Line Art Logo Specifications
- **Size**: 80×80px
- **Stroke weight**: 1pt for main shapes, 0.5pt for architectural crosses
- **Outer circle**: 35% of canvas radius
- **Accent dot**: 2.5px radius, filled with `primaryLight`
- **Geometric shapes**: Chat bubble with 60% inner width
- **Alignment marks**: Top-left corner, 10% offset from edge

**Icon Style:**
- Always outline style (never filled)
- 1pt stroke weight
- 24px standard size, 18px for secondary icons
- Rounded caps and joins (`StrokeCap.round`, `StrokeJoin.round`)

### 3. Grid System

#### Implementation
```dart
CustomPainter(
  painter: GridPainter(
    verticalColumns: 4,
    horizontalBaseline: 48.0,
    strokeWidth: 0.5,
    color: grey[900],
  ),
)
```

**Grid Rules:**
- Always paint grid **behind** content (lowest z-index)
- Grid is decorative, not interactive
- Use `shouldRepaint: false` for performance
- Grid visible in design mode only (optional)

### 4. Spacing System

Use **multiples of 12px** for all spacing:

```dart
// Micro spacing (within components)
4px, 8px, 12px

// Component spacing
16px, 24px, 32px

// Section spacing
48px, 72px, 96px

// Page spacing
120px, 144px
```

**Vertical Rhythm Example:**
```
Logo: 80px
↓ 72px
Title: 52px
↓ 12px
Subtitle: 16px
↓ 96px
Button: 56px
↓ 120px
Footer: 11px
```

---

## Layout Patterns

### Screen Structure

```
┌─────────────────────────────────┐
│  48px padding                   │
│  ┌─────────────────────────┐   │
│  │  Max width: 440px        │   │
│  │                          │   │
│  │  Logo (80×80)            │   │
│  │                          │   │
│  │  ↓ 72px                  │   │
│  │                          │   │
│  │  Title (52pt)            │   │
│  │  Subtitle (16pt)         │   │
│  │                          │   │
│  │  ↓ 96px                  │   │
│  │                          │   │
│  │  [Action Button]         │   │
│  │                          │   │
│  │  ↓ 120px                 │   │
│  │                          │   │
│  │  Legal (11pt)            │   │
│  └─────────────────────────┘   │
│                                 │
└─────────────────────────────────┘
```

### Constraints
- **Max content width**: 440px (centered)
- **Min screen width**: 320px (mobile)
- **Screen padding**: 48px all sides (desktop), 24px (mobile)
- **ScrollView**: Always wrapped in `SingleChildScrollView` for overflow

---

## Animation Guidelines

### Timing Functions
- **Entrance**: `Curves.easeOut` (200-300ms)
- **Exit**: `Curves.easeIn` (150-200ms)
- **Interaction**: `Curves.easeInOut` (200ms)
- **Never use bounces or elastic curves** in minimalist design

### Animation Types

#### Fade Transition
```dart
FadeTransition(
  opacity: Tween(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(
      parent: controller,
      curve: Interval(0.0, 0.6, curve: Curves.easeOut),
    ),
  ),
)
```

#### Slide Transition
```dart
SlideTransition(
  position: Tween(
    begin: Offset(0, 0.3),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: controller,
      curve: Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ),
  ),
)
```

#### Hover States
```dart
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  curve: Curves.easeOut,
  // Property changes
)
```

### Animation Rules
1. **Duration**: 150-300ms for UI transitions
2. **Stagger**: 100-150ms between sequential animations
3. **Loading indicators**: Infinite, 1-2s loop
4. **Micro-interactions**: 100-150ms (hover, tap)
5. **No parallax, no 3D transforms** - keep it flat

---

## Accessibility Standards

### WCAG Compliance
- **Level**: AAA (7:1 contrast for normal text, 4.5:1 for large text)
- **Touch targets**: Minimum 56px height for interactive elements
- **Focus indicators**: 2pt outline, primary accent color
- **Semantic HTML/widgets**: Proper use of `Semantics` widget in Flutter

### Screen Reader Support
```dart
Semantics(
  label: 'Continue with Google',
  button: true,
  enabled: true,
  child: _MinimalistSignInButton(...),
)
```

### Keyboard Navigation
- Tab order follows visual hierarchy (top-to-bottom, left-to-right)
- Focus visible with 2pt blue outline
- Enter/Space activates buttons
- Escape dismisses overlays

---

## Implementation Examples

### Sign-In Screen (Dark Mode)

```dart
Scaffold(
  backgroundColor: AppColors.black, // #000000
  body: SafeArea(
    child: CustomPaint(
      painter: _GridPainter(), // 0.5pt grey[900] grid
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: EdgeInsets.all(48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LineArtLogo(), // 80×80, 1pt white stroke
                SizedBox(height: 72),

                Text(
                  'DeskBubby',
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    letterSpacing: -1.2,
                  ),
                ),
                SizedBox(height: 12),

                Text(
                  'AI Companion',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[500],
                  ),
                ),
                SizedBox(height: 96),

                _MinimalistSignInButton(...),
                SizedBox(height: 120),

                Text(
                  'By continuing, you agree to our Terms',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
)
```

---

## Do's and Don'ts

### ✅ Do
- Use generous white (negative) space
- Keep stroke weights at 0.5pt or 1pt
- Align everything to the grid
- Use monochromatic colors (black, white, greys)
- Apply blue accent sparingly (< 5% of screen)
- Use ultra-light font weights for headings
- Left-align all text
- Make touch targets 56px minimum
- Animate with subtle easing (200ms)

### ❌ Don't
- Fill shapes with solid colors (except tiny accents)
- Use gradients, shadows, or blur effects
- Center-align body text
- Use bold fonts for headings
- Add decorative elements
- Use more than 2 colors per screen
- Create rounded corners > 4px
- Add drop shadows
- Use bright, saturated colors
- Clutter the interface with multiple actions

---

## File Locations

### Design Implementation
- **Sign-in screen**: `deskbubbytest_flutter/lib/screens/sign_in_screen.dart`
- **Color palette**: `deskbubbytest_flutter/lib/config/app_theme.dart`
- **Typography**: `deskbubbytest_flutter/lib/config/app_theme.dart` (AppTextStyles)

### Custom Painters
- **Grid painter**: `_GridPainter` class in sign_in_screen.dart
- **Logo painter**: `_LogoPainter` class in sign_in_screen.dart

---

## Design Tools & Resources

### Inspiration
- **Swiss Design**: Josef Müller-Brockmann, Massimo Vignelli
- **Bauhaus**: László Moholy-Nagy, Herbert Bayer
- **Contemporary**: Stripe, Linear, Vercel design systems

### Figma Grid Setup
```
Columns: 4
Gutter: 0px
Margin: 48px
Row height: 48px (baseline grid)
```

### Color Palette (Figma/Hex)
```
Background: #000000
White: #FFFFFF
Grey 500: #9E9E9E
Grey 700: #616161
Grey 800: #424242
Grey 900: #212121
Primary Blue: #4A90E2
```

---

## Version History

- **v1.0.0** (2026-01-26): Initial dark mode minimalist design system
  - Neo-minimalist line art aesthetic
  - Swiss grid system (4 columns, 48px baseline)
  - Monochromatic dark mode palette
  - Ultra-light typography (w300)
  - 1pt stroke-based components

---

## Contributing to the Design System

When adding new screens or components:

1. **Follow the grid**: Align all elements to the 4-column, 48px baseline grid
2. **Maintain stroke weights**: Use only 0.5pt or 1pt for outlines
3. **Limit colors**: Stick to black/white/grey + blue accent
4. **Use spacing system**: Multiples of 12px only
5. **Test contrast**: Ensure 7:1+ contrast ratio (WCAG AAA)
6. **Animate subtly**: 200ms ease-out transitions
7. **Update this doc**: Document any new patterns or components

---

**Design System maintained by**: DeskBubby Team
**Last updated**: January 26, 2026
**Status**: Active Development