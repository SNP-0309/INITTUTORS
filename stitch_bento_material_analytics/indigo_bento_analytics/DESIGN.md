---
name: Indigo Bento Analytics
colors:
  surface: '#f8f9fa'
  surface-dim: '#d9dadb'
  surface-bright: '#f8f9fa'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f4f5'
  surface-container: '#edeeef'
  surface-container-high: '#e7e8e9'
  surface-container-highest: '#e1e3e4'
  on-surface: '#191c1d'
  on-surface-variant: '#454652'
  inverse-surface: '#2e3132'
  inverse-on-surface: '#f0f1f2'
  outline: '#757684'
  outline-variant: '#c5c5d4'
  surface-tint: '#4355b9'
  primary: '#24389c'
  on-primary: '#ffffff'
  primary-container: '#3f51b5'
  on-primary-container: '#cacfff'
  inverse-primary: '#bac3ff'
  secondary: '#4d5a9c'
  on-secondary: '#ffffff'
  secondary-container: '#abb7ff'
  on-secondary-container: '#394687'
  tertiary: '#004c44'
  on-tertiary: '#ffffff'
  tertiary-container: '#00665c'
  on-tertiary-container: '#74e5d5'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dee0ff'
  primary-fixed-dim: '#bac3ff'
  on-primary-fixed: '#00105c'
  on-primary-fixed-variant: '#293ca0'
  secondary-fixed: '#dee1ff'
  secondary-fixed-dim: '#b9c3ff'
  on-secondary-fixed: '#021355'
  on-secondary-fixed-variant: '#354282'
  tertiary-fixed: '#85f6e5'
  tertiary-fixed-dim: '#67d9c9'
  on-tertiary-fixed: '#00201c'
  on-tertiary-fixed-variant: '#005048'
  background: '#f8f9fa'
  on-background: '#191c1d'
  surface-variant: '#e1e3e4'
typography:
  display-lg:
    fontFamily: Hanken Grotesk
    fontSize: 44px
    fontWeight: '700'
    lineHeight: 52px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-md-mobile:
    fontFamily: Hanken Grotesk
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  title-sm:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
  body-md:
    fontFamily: Hanken Grotesk
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-numeric:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  margin-canvas: 16px
  gutter-bento: 12px
  padding-card: 20px
  radius-container: 24px
  radius-component: 12px
---

## Brand & Style
The design system is a high-density mobile interface optimized for data-rich environments. It blends the structured modularity of **Bento UI** with the systematic logic of **Material Design 3 (M3)**. The personality is "Analytical Intelligence"—calculated, precise, yet visually approachable.

The target audience consists of power users who require glanceable information. The UI should evoke a sense of order and reliability, using a "nested container" strategy where high-level metrics are encapsulated in distinct, varying-sized cards. The aesthetic leans into **Modernism** with a tactile twist: using subtle elevation and hairline borders to define space rather than heavy shadows.

## Colors
The palette follows M3 color logic to ensure accessibility and semantic clarity.
- **Primary Indigo:** Used for key actions, active states, and brand recognition.
- **Surface & On-Surface:** The background is a clean light grey (`#F8F9FA`). "On-surface" elements use a high-contrast dark slate to ensure legibility of complex data.
- **Functional Colors:** Strict semantic mapping for analytics (Profit/Loss, Status).
- **Chart Palette:** A sequence of distinct hues (Blues, Purples, Teals) designed to remain distinguishable when used in adjacent segments of a pie chart or multiple lines in a trend graph.

## Typography
This design system utilizes **Hanken Grotesk** for its clean, contemporary feel that bridges the gap between tech-centric and human-friendly. 

For data-specific labels and small-scale metrics, **JetBrains Mono** is employed to provide a "technical" flavor and ensure that numerical values align perfectly in tables and lists. Large display sizes use tight letter spacing for a modern Bento aesthetic, while body text maintains standard tracking for readability.

## Layout & Spacing
The layout is based on a **4-column mobile grid** using a Bento-box philosophy. 
- **Bento Logic:** Content is divided into cards that span either 2 or 4 columns. Height is variable (e.g., Square, Wide, or Tall cards) to create a visual "puzzle" effect.
- **The Gap:** A consistent 12px gutter exists between all Bento cards.
- **Internal Padding:** Cards use a generous 20px internal padding to ensure data visualizations do not feel cramped against the card boundaries.
- **Vertical Rhythm:** Components within cards follow an 8px spacing scale.

## Elevation & Depth
In alignment with M3 and Bento styles, the design system uses **Tonal Elevation** rather than deep shadows.
- **Level 0 (Canvas):** The base background (`#F8F9FA`).
- **Level 1 (Bento Cards):** Surface color with a 1px hairline border (`#000000 / 0.08 opacity`). This provides definition without visual weight.
- **Level 2 (Interaction):** When a card is tapped or active, it gains a subtle ambient shadow (4px blur, 2px Y-offset, 5% opacity) and the border color shifts to the Primary Indigo.
- **Backdrop Blurs:** Used exclusively for navigation bars and modal overlays to maintain a sense of context.

## Shapes
The shape language is characterized by **large, friendly radii**. 
- **Outer Containers:** All primary Bento cards must use a **24px corner radius** (`rounded-xl` logic).
- **Inner Elements:** Buttons, input fields, and tags use a halved radius of **12px** to create a nested visual harmony.
- **Selection Controls:** Checkboxes and progress bars use a fully rounded (pill) style to contrast against the architectural squareness of the grid.

## Components
- **Bento Cards:** The core component. Must include a `header` area for a title and optional icon, a `content` area for charts/metrics, and an optional `footer` for "View More" links.
- **Data Chips:** Small, pill-shaped indicators used for status (e.g., "+12.5%"). They use a low-opacity background of the functional color (Success/Error) with high-opacity text.
- **M3 Buttons:** Filled buttons use the Primary Indigo. Outlined buttons use the hairline border spec from the cards.
- **Input Fields:** Minimalist design with a 12px radius. The active state is indicated by a 2px Primary border.
- **Charts:** Line and bar charts should have no axes lines—only light horizontal grid markers. Data points should use the `chart_palette` tokens.
- **Segmented Control:** Used frequently for time-series toggles (1D, 1W, 1M). These should be styled as a single container with a sliding background highlight.