import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        // Golf-themed color system (TopGolf-inspired but legally distinct)
        golf: {
          primary: '#248A3D',      // Deep evergreen
          secondary: '#33B359',    // Fresh green
          tertiary: '#1F7A37',     // Darker evergreen
          accent: '#D9A622',       // Golf flag yellow
          gold: '#F4D03F',         // Trophy gold
        },
        // Semantic colors
        success: '#22C55E',
        warning: '#F59E0B',
        error: '#EF4444',
        info: '#3B82F6',
        // Custom surfaces
        surface: '#FFFFFF',
        muted: '#F3F4F6',
      },
      backgroundImage: {
        'golf-gradient': 'linear-gradient(135deg, #1F7A37 0%, #248A3D 50%, #33B359 100%)',
        'accent-gradient': 'linear-gradient(135deg, #D9A622 0%, #F4D03F 100%)',
        'hero-gradient': 'linear-gradient(135deg, #1F7A37 0%, #248A3D 50%, #33B359 100%)',
        'premium-mesh': 'radial-gradient(circle at 25% 25%, rgba(217, 166, 34, 0.1) 0%, transparent 50%), radial-gradient(circle at 75% 75%, rgba(51, 179, 89, 0.1) 0%, transparent 50%)',
      },
      animation: {
        'fade-in': 'fadeIn 0.8s ease-out',
        'slide-up': 'slideUp 0.8s ease-out',
        'scale-in': 'scaleIn 0.6s ease-out',
        'golf-pulse': 'golfPulse 3s ease-in-out infinite',
        'luxury-bounce': 'luxuryBounce 1s ease-out',
        'hero-reveal': 'heroReveal 1.2s ease-out',
        'stagger-fade': 'staggerFade 0.8s ease-out',
        'premium-glow': 'premiumGlow 2s ease-in-out infinite alternate',
        'floating': 'floating 6s ease-in-out infinite',
        'breathe': 'breathe 4s ease-in-out infinite',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0', transform: 'translateY(10px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        slideUp: {
          '0%': { opacity: '0', transform: 'translateY(30px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        scaleIn: {
          '0%': { opacity: '0', transform: 'scale(0.95)' },
          '100%': { opacity: '1', transform: 'scale(1)' },
        },
        golfPulse: {
          '0%, 100%': { opacity: '1', transform: 'scale(1)' },
          '50%': { opacity: '0.85', transform: 'scale(1.05)' },
        },
        luxuryBounce: {
          '0%': { transform: 'scale(0.95) translateY(10px)', opacity: '0' },
          '60%': { transform: 'scale(1.02) translateY(-5px)', opacity: '1' },
          '100%': { transform: 'scale(1) translateY(0)', opacity: '1' },
        },
        heroReveal: {
          '0%': { 
            opacity: '0', 
            transform: 'translateY(40px) scale(0.98)',
            filter: 'blur(4px)'
          },
          '100%': { 
            opacity: '1', 
            transform: 'translateY(0) scale(1)',
            filter: 'blur(0px)'
          },
        },
        staggerFade: {
          '0%': { opacity: '0', transform: 'translateX(-20px)' },
          '100%': { opacity: '1', transform: 'translateX(0)' },
        },
        premiumGlow: {
          '0%': { boxShadow: '0 0 20px rgba(217, 166, 34, 0.3)' },
          '100%': { boxShadow: '0 0 40px rgba(217, 166, 34, 0.6)' },
        },
        floating: {
          '0%, 100%': { transform: 'translateY(0px) rotate(0deg)' },
          '33%': { transform: 'translateY(-10px) rotate(1deg)' },
          '66%': { transform: 'translateY(-5px) rotate(-1deg)' },
        },
        breathe: {
          '0%, 100%': { transform: 'scale(1)' },
          '50%': { transform: 'scale(1.05)' },
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', '-apple-system', 'BlinkMacSystemFont', 'sans-serif'],
      },
      boxShadow: {
        'golf': '0 10px 40px rgba(36, 138, 61, 0.2)',
        'accent': '0 10px 40px rgba(217, 166, 34, 0.2)',
        'premium': '0 20px 60px rgba(0, 0, 0, 0.15)',
        'glass': '0 8px 32px rgba(31, 38, 135, 0.37)',
        'glow': '0 0 20px rgba(217, 166, 34, 0.4)',
      },
      backdropBlur: {
        xs: '2px',
      },
      fontSize: {
        '8xl': '6rem',
        '9xl': '8rem',
      },
      spacing: {
        '18': '4.5rem',
        '88': '22rem',
        '128': '32rem',
      },
      zIndex: {
        '60': '60',
        '70': '70',
        '80': '80',
        '90': '90',
        '100': '100',
      },
    },
  },
  plugins: [],
};

export default config;