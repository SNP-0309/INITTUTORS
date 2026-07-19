---
name: Academic Excellence System
colors:
  surface: '#f7f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#464555'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#777587'
  outline-variant: '#c7c4d8'
  surface-tint: '#4d44e3'
  primary: '#3525cd'
  on-primary: '#ffffff'
  primary-container: '#4f46e5'
  on-primary-container: '#dad7ff'
  inverse-primary: '#c3c0ff'
  secondary: '#505f76'
  on-secondary: '#ffffff'
  secondary-container: '#d0e1fb'
  on-secondary-container: '#54647a'
  tertiary: '#004d70'
  on-tertiary: '#ffffff'
  tertiary-container: '#006693'
  on-tertiary-container: '#b8e0ff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e2dfff'
  primary-fixed-dim: '#c3c0ff'
  on-primary-fixed: '#0f0069'
  on-primary-fixed-variant: '#3323cc'
  secondary-fixed: '#d3e4fe'
  secondary-fixed-dim: '#b7c8e1'
  on-secondary-fixed: '#0b1c30'
  on-secondary-fixed-variant: '#38485d'
  tertiary-fixed: '#c9e6ff'
  tertiary-fixed-dim: '#89ceff'
  on-tertiary-fixed: '#001e2f'
  on-tertiary-fixed-variant: '#004c6e'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 60px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  2xl: 48px
  3xl: 64px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 32px
---

## Brand & Style

The design system is engineered for the modern educational landscape, prioritizing clarity, efficiency, and a sense of calm authority. It serves administrators, educators, and students who require a tool that handles complex data without increasing cognitive load.

The style is **Corporate Modern** with a lean toward **High-Density Functionalism**. It leverages the structural logic of Material 3 but refines it with a custom aesthetic that feels more "Premium SaaS" and less "Generic OS." The interface evokes a sense of reliability and progress through a rhythmic use of whitespace, precise typography, and a deliberate lack of unnecessary ornamentation.

## Colors

The palette is anchored by a deep Indigo primary color, representing stability and intelligence. Surfaces utilize a tiered grayscale to create clear content grouping and separation.

- **Primary (#4F46E5):** Used for key actions, active states, and brand presence.
- **Surface Scale:** Use White (#FFFFFF) for the primary content cards and Slate-50 (#F8FAFC) for the background to create a subtle "lift" effect.
- **Semantic Logic:**
    - **Success (Emerald 500):** Exclusively for "Present" status and positive outcomes.
    - **Error (Red 500):** Reserved for "Absent" status and critical system alerts.
    - **Warning (Amber 500):** Used for "Late" status or pending actions.

## Typography

This system uses a dual-font strategy to balance character with utility. 

**Plus Jakarta Sans** is used for all headings. Its slightly wider stance and modern geometric curves provide a welcoming, contemporary feel to the dashboard. 

**Inter** is the workhorse for all body text, data tables, and input fields. It is chosen for its exceptional legibility in high-density environments. 

For data-heavy views, use `body-md` as the standard text size to maximize information density without sacrificing readability. Use `label-md` for table headers and section overlines to provide clear structural markers.

## Layout & Spacing

The layout follows a **Fluid Grid** model with a 12-column structure for desktop and a 4-column structure for mobile. 

- **Grid System:** On desktop, use a 24px gutter. For complex analytics dashboards, use a "Sidebar + Header + Content" layout where the content area is a flexible container.
- **Rhythm:** All spacing must be a multiple of 4px. Use `lg` (24px) for padding inside standard cards and `md` (16px) for tighter data-entry forms.
- **Mobile Reflow:** In mobile views, cards become full-width minus the 16px side margins. Data tables should transition to a "card-list" format to ensure data remains accessible on small screens.

## Elevation & Depth

Hierarchy is established through **Tonal Layering** and **Ambient Shadows**. 

- **Level 0 (Background):** Surface color #F8FAFC. No shadow.
- **Level 1 (Cards/Sidebar):** White surface. Subtle, diffused shadow: `0px 1px 3px rgba(0, 0, 0, 0.05), 0px 10px 15px -3px rgba(0, 0, 0, 0.03)`.
- **Level 2 (Dropdowns/Modals):** White surface. More pronounced shadow: `0px 4px 6px -1px rgba(0, 0, 0, 0.1), 0px 20px 25px -5px rgba(0, 0, 0, 0.05)`.
- **Interactive States:** Buttons and interactive cards should use a 2px Indigo outline on focus, rather than increasing shadow depth, to maintain the clean, modern look.

## Shapes

The design system utilizes a "Rounded" language to soften the density of the data. 

- **Small Elements (Inputs, Buttons):** 8px radius (`rounded-md`).
- **Medium Elements (Cards, Modals):** 12px radius (`rounded-lg`).
- **Pill Elements:** Used exclusively for status badges (Present, Absent, Late) and the active indicator in the bottom navigation bar.

## Components

### Buttons
Primary buttons use the Indigo seed color with white text. Secondary buttons use a Slate-100 background with Slate-900 text. All buttons have a height of 40px or 48px to ensure touch targets are accessible.

### Chips & Status Badges
Status indicators must be pill-shaped. Use low-saturation backgrounds with high-saturation text for readability:
- **Present:** Light Emerald background / Dark Emerald text.
- **Absent:** Light Red background / Dark Red text.
- **Late:** Light Amber background / Dark Amber text.

### Cards
Cards are the primary container. They must have a 12px border radius, a white background, and the Level 1 shadow. Header sections within cards should be separated by a 1px border (#F1F5F9) if the card contains multiple data types.

### Bottom Navigation (Mobile)
A fixed bottom bar with a height of 64px. Use the Primary Indigo for the active icon and label. Active icons should be housed within a subtle "pill" highlight container (Material 3 style).

### Input Fields
Inputs should have a 1px border (#E2E8F0) and an 8px radius. Label text should be `label-md`. On focus, the border transitions to Primary Indigo with a 1px thickness.

### Lists
Lists use `body-md` for primary text and `label-sm` for secondary metadata. Items are separated by 1px horizontal dividers with 16px of vertical padding.