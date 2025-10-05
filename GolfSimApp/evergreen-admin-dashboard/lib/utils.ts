import { type ClassValue, clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

export function formatCurrency(amount: number | string): string {
  const num = typeof amount === 'string' ? parseFloat(amount) : amount
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
  }).format(num)
}

export function formatDate(date: Date | string): string {
  const d = typeof date === 'string' ? new Date(date) : date
  return new Intl.DateTimeFormat('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  }).format(d)
}

export function formatTime(date: Date | string): string {
  const d = typeof date === 'string' ? new Date(date) : date
  return new Intl.DateTimeFormat('en-US', {
    hour: 'numeric',
    minute: '2-digit',
    hour12: true,
  }).format(d)
}

export function formatDateTime(date: Date | string): string {
  const d = typeof date === 'string' ? new Date(date) : date
  return new Intl.DateTimeFormat('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
    hour12: true,
  }).format(d)
}

export function formatDuration(minutes: number): string {
  if (minutes < 60) {
    return `${minutes}m`
  }
  const hours = Math.floor(minutes / 60)
  const remainingMinutes = minutes % 60
  if (remainingMinutes === 0) {
    return `${hours}h`
  }
  return `${hours}h ${remainingMinutes}m`
}

export function formatPhoneNumber(phone: string): string {
  const cleaned = phone.replace(/\D/g, '')
  if (cleaned.length === 10) {
    const areaCode = cleaned.slice(0, 3)
    const exchange = cleaned.slice(3, 6)
    const number = cleaned.slice(6)
    return `(${areaCode}) ${exchange}-${number}`
  }
  return phone
}

export function getInitials(firstName: string, lastName: string): string {
  return `${firstName.charAt(0)}${lastName.charAt(0)}`.toUpperCase()
}

export function capitalizeFirst(str: string): string {
  return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase()
}

export function getStatusColor(status: string): string {
  const statusColors: Record<string, string> = {
    // Booking statuses
    PENDING: 'bg-yellow-100 text-yellow-800 border-yellow-200',
    CONFIRMED: 'bg-blue-100 text-blue-800 border-blue-200',
    CHECKED_IN: 'bg-green-100 text-green-800 border-green-200',
    IN_PROGRESS: 'bg-purple-100 text-purple-800 border-purple-200',
    COMPLETED: 'bg-gray-100 text-gray-800 border-gray-200',
    CANCELLED: 'bg-red-100 text-red-800 border-red-200',
    NO_SHOW: 'bg-red-100 text-red-800 border-red-200',
    
    // Resource statuses
    AVAILABLE: 'bg-green-100 text-green-800 border-green-200',
    OCCUPIED: 'bg-red-100 text-red-800 border-red-200',
    MAINTENANCE: 'bg-yellow-100 text-yellow-800 border-yellow-200',
    CLEANING: 'bg-purple-100 text-purple-800 border-purple-200',
    RESERVED: 'bg-blue-100 text-blue-800 border-blue-200',
    
    // Membership statuses
    ACTIVE: 'bg-green-100 text-green-800 border-green-200',
    INACTIVE: 'bg-gray-100 text-gray-800 border-gray-200',
    SUSPENDED: 'bg-yellow-100 text-yellow-800 border-yellow-200',
    EXPIRED: 'bg-red-100 text-red-800 border-red-200',
  }
  
  return statusColors[status.toUpperCase()] || 'bg-gray-100 text-gray-800 border-gray-200'
}

export function getMembershipTierColor(tier: string): string {
  const tierColors: Record<string, string> = {
    GUEST: 'bg-gray-100 text-gray-800 border-gray-200',
    CASCADE: 'bg-blue-100 text-blue-800 border-blue-200',
    PIKE: 'bg-orange-100 text-orange-800 border-orange-200',
    RAINIER: 'bg-purple-100 text-purple-800 border-purple-200',
    JUNIOR: 'bg-green-100 text-green-800 border-green-200',
  }
  
  return tierColors[tier.toUpperCase()] || 'bg-gray-100 text-gray-800 border-gray-200'
}

export function calculateUtilization(occupiedBays: number, totalBays: number): number {
  if (totalBays === 0) return 0
  return Math.round((occupiedBays / totalBays) * 100)
}

export function generateBookingNumber(facilityCode: string): string {
  const date = new Date()
  const dateStr = date.getFullYear().toString().slice(-2) + 
                 (date.getMonth() + 1).toString().padStart(2, '0') + 
                 date.getDate().toString().padStart(2, '0')
  const random = Math.floor(Math.random() * 9000) + 1000
  return `${facilityCode.toUpperCase()}-${dateStr}-${random}`
}

export function isValidEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  return emailRegex.test(email)
}

export function isValidPhone(phone: string): boolean {
  const phoneRegex = /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/
  return phoneRegex.test(phone)
}

export function debounce<T extends (...args: any[]) => any>(
  func: T,
  wait: number
): (...args: Parameters<T>) => void {
  let timeout: NodeJS.Timeout
  return (...args: Parameters<T>) => {
    clearTimeout(timeout)
    timeout = setTimeout(() => func(...args), wait)
  }
}

export function throttle<T extends (...args: any[]) => any>(
  func: T,
  limit: number
): (...args: Parameters<T>) => void {
  let inThrottle: boolean
  return (...args: Parameters<T>) => {
    if (!inThrottle) {
      func(...args)
      inThrottle = true
      setTimeout(() => (inThrottle = false), limit)
    }
  }
}