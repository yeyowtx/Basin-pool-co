import './globals.css'
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import { Providers } from './providers'
import { Toaster } from '@/components/ui/toaster'
import { cn } from '@/lib/utils'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: {
    default: 'Evergreen Golf Club - Admin Dashboard',
    template: '%s | Evergreen Admin'
  },
  description: 'Advanced facility management dashboard for Evergreen Golf Club',
  keywords: ['golf simulator', 'facility management', 'booking system', 'golf club'],
  authors: [{ name: 'Evergreen Golf Club' }],
  creator: 'Evergreen Golf Club',
  publisher: 'Evergreen Golf Club',
  metadataBase: new URL(process.env.NEXTAUTH_URL || 'http://localhost:3000'),
  openGraph: {
    type: 'website',
    locale: 'en_US',
    url: '/',
    title: 'Evergreen Golf Club - Admin Dashboard',
    description: 'Advanced facility management dashboard for Evergreen Golf Club',
    siteName: 'Evergreen Admin Dashboard',
    images: [
      {
        url: '/og-image.png',
        width: 1200,
        height: 630,
        alt: 'Evergreen Golf Club Admin Dashboard'
      }
    ]
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Evergreen Golf Club - Admin Dashboard',
    description: 'Advanced facility management dashboard for Evergreen Golf Club',
    images: ['/og-image.png']
  },
  robots: {
    index: false, // Admin dashboard should not be indexed
    follow: false,
    noarchive: true,
    nosnippet: true,
    noimageindex: true
  },
  icons: {
    icon: '/favicon.ico',
    shortcut: '/favicon-16x16.png',
    apple: '/apple-touch-icon.png'
  },
  manifest: '/site.webmanifest'
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={cn(
        inter.className,
        'min-h-screen bg-background font-sans antialiased'
      )}>
        <Providers>
          {children}
          <Toaster />
        </Providers>
      </body>
    </html>
  )
}