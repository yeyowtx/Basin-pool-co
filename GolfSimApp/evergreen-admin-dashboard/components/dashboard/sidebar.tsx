'use client'

import { cn } from '@/lib/utils'
import { Button } from '@/components/ui/button'
import { 
  LayoutDashboard, 
  Calendar, 
  Users, 
  UserCheck, 
  ShoppingBag,
  BarChart3,
  Settings,
  Trees
} from 'lucide-react'
import Link from 'next/link'
import { usePathname } from 'next/navigation'

const navigation = [
  { name: 'Dashboard', href: '/dashboard', icon: LayoutDashboard },
  { name: 'Bookings', href: '/dashboard/bookings', icon: Calendar },
  { name: 'Members', href: '/dashboard/members', icon: Users },
  { name: 'Staff', href: '/dashboard/staff', icon: UserCheck },
  { name: 'Shop & POS', href: '/dashboard/shop', icon: ShoppingBag },
  { name: 'Analytics', href: '/dashboard/analytics', icon: BarChart3 },
  { name: 'Settings', href: '/dashboard/settings', icon: Settings },
]

export function Sidebar() {
  const pathname = usePathname()

  return (
    <div className="desktop-sidebar bg-card border-r border-border">
      <div className="flex h-full flex-col">
        {/* Logo */}
        <div className="flex h-16 items-center px-6">
          <Trees className="h-8 w-8 text-evergreen-primary" />
          <span className="ml-3 text-lg font-bold text-evergreen-primary">
            Evergreen Admin
          </span>
        </div>

        {/* Navigation */}
        <nav className="flex-1 space-y-1 px-3 py-4">
          {navigation.map((item) => {
            const isActive = pathname === item.href
            return (
              <Button
                key={item.name}
                asChild
                variant={isActive ? 'evergreen' : 'ghost'}
                className={cn(
                  'w-full justify-start',
                  isActive && 'bg-evergreen-primary text-white'
                )}
              >
                <Link href={item.href as any}>
                  <item.icon className="mr-3 h-4 w-4" />
                  {item.name}
                </Link>
              </Button>
            )
          })}
        </nav>

        {/* Footer */}
        <div className="p-4 border-t border-border">
          <p className="text-xs text-muted-foreground text-center">
            Evergreen Golf Club
            <br />
            Admin Dashboard v1.0
          </p>
        </div>
      </div>
    </div>
  )
}