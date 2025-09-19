// Golf-themed color palette inspired by TopGolf design patterns
// Using legally safe golf colors instead of TopGolf's blue branding

export const golfColors = {
  // Primary golf colors (deep greens)
  evergreenPrimary: '#248A3D',     // Deep golf green
  evergreenSecondary: '#33B359',   // Fresh green
  evergreenTertiary: '#1F7A37',    // Darker evergreen
  
  // Golf accent colors
  golfAccent: '#D9A622',          // Golf flag yellow
  golfGold: '#F4D03F',            // Trophy gold
  
  // Semantic colors
  success: '#22C55E',             // Green success
  warning: '#F59E0B',             // Orange warning
  error: '#EF4444',               // Red error
  info: '#3B82F6',                // Blue info
  
  // Neutral palette
  background: '#FAFAFA',          // Light background
  surface: '#FFFFFF',             // Card surfaces
  muted: '#F3F4F6',               // Muted backgrounds
  border: '#E5E7EB',              // Border colors
  
  // Text colors
  textPrimary: '#111827',         // Primary text
  textSecondary: '#6B7280',       // Secondary text
  textMuted: '#9CA3AF',           // Muted text
  textOnPrimary: '#FFFFFF',       // Text on primary colors
  
  // Glass/overlay effects
  glass: 'rgba(255, 255, 255, 0.1)',
  overlay: 'rgba(0, 0, 0, 0.5)',
  
  // Gradients
  gradients: {
    primary: 'linear-gradient(135deg, #248A3D 0%, #33B359 100%)',
    accent: 'linear-gradient(135deg, #D9A622 0%, #F4D03F 100%)',
    hero: 'linear-gradient(135deg, #1F7A37 0%, #248A3D 50%, #33B359 100%)',
  }
} as const;

export type GolfColor = keyof typeof golfColors;