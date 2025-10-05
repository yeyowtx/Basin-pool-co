import type { Config } from 'tailwindcss'

const config: Config = {
  darkMode: ['class'],
  content: [
    './pages/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
    './app/**/*.{ts,tsx}',
    './src/**/*.{ts,tsx}',
  ],
  prefix: '',
  theme: {
    container: {
      center: true,
      padding: '2rem',
      screens: {
        '2xl': '1400px',
      },
    },
    extend: {
      colors: {
        border: 'hsl(var(--border))',
        input: 'hsl(var(--input))',
        ring: 'hsl(var(--ring))',
        background: 'hsl(var(--background))',
        foreground: 'hsl(var(--foreground))',
        primary: {
          DEFAULT: 'hsl(var(--primary))',
          foreground: 'hsl(var(--primary-foreground))',
        },
        secondary: {
          DEFAULT: 'hsl(var(--secondary))',
          foreground: 'hsl(var(--secondary-foreground))',
        },
        destructive: {
          DEFAULT: 'hsl(var(--destructive))',
          foreground: 'hsl(var(--destructive-foreground))',
        },
        muted: {
          DEFAULT: 'hsl(var(--muted))',
          foreground: 'hsl(var(--muted-foreground))',
        },
        accent: {
          DEFAULT: 'hsl(var(--accent))',
          foreground: 'hsl(var(--accent-foreground))',
        },
        popover: {
          DEFAULT: 'hsl(var(--popover))',
          foreground: 'hsl(var(--popover-foreground))',
        },
        card: {
          DEFAULT: 'hsl(var(--card))',
          foreground: 'hsl(var(--card-foreground))',
        },
        // Evergreen Golf Club Branding Colors
        evergreen: {
          50: '#f0f9f4',
          100: '#dcf2e5',
          200: '#bce5cd',
          300: '#8dd2aa',
          400: '#52b788', // Light accent green
          500: '#248a3d', // Secondary green  
          600: '#1b4332', // Primary forest green
          700: '#164e29',
          800: '#113f22',
          900: '#0e341d',
          950: '#071d10',
        },
        // TopGolf Integration Colors
        topgolf: {
          blue: '#1E40AF',
          orange: '#EA580C',
          success: '#059669',
          warning: '#D97706',
        },
        // Status Colors
        status: {
          available: '#10B981',
          occupied: '#EF4444',
          maintenance: '#F59E0B',
          reserved: '#3B82F6',
          cleaning: '#8B5CF6',
        },
      },
      borderRadius: {
        lg: 'var(--radius)',
        md: 'calc(var(--radius) - 2px)',
        sm: 'calc(var(--radius) - 4px)',
      },
      keyframes: {
        'accordion-down': {
          from: { height: '0' },
          to: { height: 'var(--radix-accordion-content-height)' },
        },
        'accordion-up': {
          from: { height: 'var(--radix-accordion-content-height)' },
          to: { height: '0' },
        },
        'fade-in': {
          '0%': { opacity: '0', transform: 'translateY(10px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        'slide-in': {
          '0%': { transform: 'translateX(-100%)' },
          '100%': { transform: 'translateX(0)' },
        },
        'bounce-in': {
          '0%': { transform: 'scale(0.3)', opacity: '0' },
          '50%': { transform: 'scale(1.05)' },
          '70%': { transform: 'scale(0.9)' },
          '100%': { transform: 'scale(1)', opacity: '1' },
        },
        'pulse-green': {
          '0%, 100%': { backgroundColor: 'rgb(34 197 94)' },
          '50%': { backgroundColor: 'rgb(21 128 61)' },
        },
        'pulse-orange': {
          '0%, 100%': { backgroundColor: 'rgb(234 88 12)' },
          '50%': { backgroundColor: 'rgb(194 65 12)' },
        },
      },
      animation: {
        'accordion-down': 'accordion-down 0.2s ease-out',
        'accordion-up': 'accordion-up 0.2s ease-out',
        'fade-in': 'fade-in 0.5s ease-out',
        'slide-in': 'slide-in 0.3s ease-out',
        'bounce-in': 'bounce-in 0.6s ease-out',
        'pulse-green': 'pulse-green 2s infinite',
        'pulse-orange': 'pulse-orange 2s infinite',
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
      boxShadow: {
        'evergreen': '0 4px 6px -1px rgba(27, 67, 50, 0.1), 0 2px 4px -1px rgba(27, 67, 50, 0.06)',
        'evergreen-lg': '0 10px 15px -3px rgba(27, 67, 50, 0.1), 0 4px 6px -2px rgba(27, 67, 50, 0.05)',
      },
      gridTemplateColumns: {
        'auto-fit': 'repeat(auto-fit, minmax(0, 1fr))',
        'auto-fill': 'repeat(auto-fill, minmax(0, 1fr))',
      },
    },
  },
  plugins: [require('tailwindcss-animate')],
}

export default config