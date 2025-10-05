'use client'

import { cn } from '@/lib/utils'
import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { 
  LayoutDashboard, 
  Calendar, 
  Users, 
  MoreHorizontal
} from 'lucide-react'

const navigation = [
  { name: 'Dashboard', href: '/dashboard', icon: LayoutDashboard },
  { name: 'Bookings', href: '/dashboard/bookings', icon: Calendar },
  { name: 'Members', href: '/dashboard/members', icon: Users },
  { name: 'More', href: '/dashboard/settings', icon: MoreHorizontal },
]

export function MobileNav() {
  const pathname = usePathname()
  
  return (
    <div className="mobile-nav lg:hidden">
      <div className="grid grid-cols-4 h-16">
        {navigation.map((item) => {
          const isActive = pathname === item.href
          return (
            <Link 
              key={item.name} 
              href={item.href}
              className="flex flex-col items-center justify-center space-y-1 p-2"
            >
              <item.icon className={cn(
                "h-5 w-5",
                isActive ? "text-evergreen-primary" : "text-muted-foreground"
              )} />
              <span className={cn(
                "text-xs",
                isActive ? "text-evergreen-primary font-medium" : "text-muted-foreground"
              )}>{item.name}</span>
            </Link>
          )
        })}
      </div>
    </div>
  )
}