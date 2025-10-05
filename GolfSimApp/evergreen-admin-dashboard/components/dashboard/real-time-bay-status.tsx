'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { cn, formatTime, calculateUtilization } from '@/lib/utils'
import { 
  MonitorSpeaker, 
  Users, 
  Clock, 
  Wrench, 
  Sparkles,
  RefreshCw,
  MapPin
} from 'lucide-react'

// Types matching the iOS app data models
interface BayStatus {
  id: string
  resourceId: string
  resourceCode: string
  facilityId: string
  status: 'AVAILABLE' | 'OCCUPIED' | 'MAINTENANCE' | 'CLEANING' | 'RESERVED'
  occupancyStart?: Date
  occupancyEnd?: Date
  playerCount: number
  sessionMinutes: number
  lastActivity?: Date
  needsCleaning: boolean
  currentBookingId?: string
  currentBooking?: {
    id: string
    customerFirstName: string
    customerLastName: string
    totalParticipants: number
    endTime: Date
  }
}

interface Facility {
  id: string
  facilityCode: string
  name: string
  totalSimulators: number
}

const mockFacilities: Facility[] = [
  { id: 'tacoma', facilityCode: 'TAC', name: 'Tacoma Location', totalSimulators: 15 },
  { id: 'redmond', facilityCode: 'RED', name: 'Redmond Location', totalSimulators: 8 }
]

const generateMockBayStatus = (facility: Facility): BayStatus[] => {
  const statuses: BayStatus['status'][] = ['AVAILABLE', 'OCCUPIED', 'MAINTENANCE', 'CLEANING', 'RESERVED']
  
  return Array.from({ length: facility.totalSimulators }, (_, index) => {
    const bayNumber = index + 1
    const resourceCode = `${facility.facilityCode}-SIM-${bayNumber.toString().padStart(2, '0')}`
    const status = statuses[Math.floor(Math.random() * statuses.length)]
    const now = new Date()
    
    return {
      id: `${facility.id}-bay-${bayNumber}`,
      resourceId: `${facility.id}-resource-${bayNumber}`,
      resourceCode,
      facilityId: facility.id,
      status,
      occupancyStart: status === 'OCCUPIED' ? new Date(now.getTime() - Math.random() * 2 * 60 * 60 * 1000) : undefined,
      occupancyEnd: status === 'OCCUPIED' ? new Date(now.getTime() + Math.random() * 2 * 60 * 60 * 1000) : undefined,
      playerCount: status === 'OCCUPIED' ? Math.floor(Math.random() * 6) + 1 : 0,
      sessionMinutes: status === 'OCCUPIED' ? Math.floor(Math.random() * 120) + 30 : 0,
      lastActivity: status === 'OCCUPIED' ? new Date(now.getTime() - Math.random() * 30 * 60 * 1000) : undefined,
      needsCleaning: Math.random() > 0.8,
      currentBookingId: status === 'OCCUPIED' ? `booking-${bayNumber}` : undefined,
      currentBooking: status === 'OCCUPIED' ? {
        id: `booking-${bayNumber}`,
        customerFirstName: ['John', 'Sarah', 'Mike', 'Emma', 'David'][Math.floor(Math.random() * 5)],
        customerLastName: ['Smith', 'Johnson', 'Brown', 'Davis', 'Wilson'][Math.floor(Math.random() * 5)],
        totalParticipants: Math.floor(Math.random() * 6) + 1,
        endTime: new Date(now.getTime() + Math.random() * 2 * 60 * 60 * 1000)
      } : undefined
    }
  })
}

export function RealTimeBayStatus() {
  const [selectedFacility, setSelectedFacility] = useState<string>(mockFacilities[0].id)
  const [bayStatuses, setBayStatuses] = useState<BayStatus[]>([])
  const [lastUpdated, setLastUpdated] = useState<Date>(new Date())
  const [isRefreshing, setIsRefreshing] = useState(false)

  const currentFacility = mockFacilities.find(f => f.id === selectedFacility)!
  
  // Simulate real-time updates
  useEffect(() => {
    const updateBayStatuses = () => {
      setBayStatuses(generateMockBayStatus(currentFacility))
      setLastUpdated(new Date())
    }

    updateBayStatuses()
    
    // Update every 30 seconds (matches iOS app frequency)
    const interval = setInterval(updateBayStatuses, 30000)
    
    return () => clearInterval(interval)
  }, [selectedFacility, currentFacility])

  const handleRefresh = async () => {
    setIsRefreshing(true)
    // Simulate API call delay
    await new Promise(resolve => setTimeout(resolve, 1000))
    setBayStatuses(generateMockBayStatus(currentFacility))
    setLastUpdated(new Date())
    setIsRefreshing(false)
  }

  const getStatusIcon = (status: BayStatus['status']) => {
    switch (status) {
      case 'AVAILABLE': return <MonitorSpeaker className="w-4 h-4" />
      case 'OCCUPIED': return <Users className="w-4 h-4" />
      case 'MAINTENANCE': return <Wrench className="w-4 h-4" />
      case 'CLEANING': return <Sparkles className="w-4 h-4" />
      case 'RESERVED': return <Clock className="w-4 h-4" />
    }
  }

  const getStatusColor = (status: BayStatus['status']) => {
    switch (status) {
      case 'AVAILABLE': return 'bg-green-500'
      case 'OCCUPIED': return 'bg-red-500'
      case 'MAINTENANCE': return 'bg-yellow-500'
      case 'CLEANING': return 'bg-purple-500'
      case 'RESERVED': return 'bg-blue-500'
    }
  }

  const occupiedBays = bayStatuses.filter(bay => bay.status === 'OCCUPIED').length
  const utilization = calculateUtilization(occupiedBays, currentFacility.totalSimulators)

  return (
    <div className="space-y-6">
      {/* Facility Selector and Metrics */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div className="flex items-center gap-4">
          <div className="flex gap-2">
            {mockFacilities.map((facility) => (
              <Button
                key={facility.id}
                variant={selectedFacility === facility.id ? 'evergreen' : 'outline'}
                size="sm"
                onClick={() => setSelectedFacility(facility.id)}
                className="flex items-center gap-2"
              >
                <MapPin className="w-4 h-4" />
                {facility.name}
              </Button>
            ))}
          </div>
          
          <Button
            variant="outline"
            size="sm"
            onClick={handleRefresh}
            disabled={isRefreshing}
            className="flex items-center gap-2"
          >
            <RefreshCw className={cn("w-4 h-4", isRefreshing && "animate-spin")} />
            Refresh
          </Button>
        </div>

        <div className="flex items-center gap-4 text-sm text-muted-foreground">
          <span>Last updated: {formatTime(lastUpdated)}</span>
          <Badge variant="outline" className="bg-green-50">
            {utilization}% Utilization
          </Badge>
        </div>
      </div>

      {/* Status Summary */}
      <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
        {['AVAILABLE', 'OCCUPIED', 'MAINTENANCE', 'CLEANING', 'RESERVED'].map((status) => {
          const count = bayStatuses.filter(bay => bay.status === status).length
          return (
            <Card key={status}>
              <CardContent className="p-4">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <div className={cn("w-3 h-3 rounded-full", getStatusColor(status as BayStatus['status']))} />
                    <span className="text-sm font-medium capitalize">
                      {status.toLowerCase()}
                    </span>
                  </div>
                  <span className="text-2xl font-bold">{count}</span>
                </div>
              </CardContent>
            </Card>
          )
        })}
      </div>

      {/* Bay Status Grid */}
      <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4">
        {bayStatuses.map((bay) => (
          <Card 
            key={bay.id} 
            className={cn(
              "transition-all duration-200 hover:shadow-md cursor-pointer",
              bay.status === 'OCCUPIED' && "ring-2 ring-red-200",
              bay.needsCleaning && "ring-2 ring-yellow-200"
            )}
          >
            <CardHeader className="p-3">
              <div className="flex items-center justify-between">
                <CardTitle className="text-sm font-semibold">
                  {bay.resourceCode}
                </CardTitle>
                <div className="flex items-center gap-1">
                  {getStatusIcon(bay.status)}
                  <div className={cn("w-2 h-2 rounded-full", getStatusColor(bay.status))} />
                </div>
              </div>
            </CardHeader>
            
            <CardContent className="p-3 pt-0">
              <div className="space-y-2">
                <Badge variant="outline" className={cn(
                  "w-full justify-center text-xs",
                  bay.status === 'AVAILABLE' && "bg-green-50 text-green-700 border-green-200",
                  bay.status === 'OCCUPIED' && "bg-red-50 text-red-700 border-red-200",
                  bay.status === 'MAINTENANCE' && "bg-yellow-50 text-yellow-700 border-yellow-200",
                  bay.status === 'CLEANING' && "bg-purple-50 text-purple-700 border-purple-200",
                  bay.status === 'RESERVED' && "bg-blue-50 text-blue-700 border-blue-200"
                )}>
                  {bay.status.toLowerCase()}
                </Badge>

                {bay.status === 'OCCUPIED' && bay.currentBooking && (
                  <div className="space-y-1 text-xs">
                    <div className="font-medium">
                      {bay.currentBooking.customerFirstName} {bay.currentBooking.customerLastName}
                    </div>
                    <div className="text-muted-foreground flex items-center justify-between">
                      <span>{bay.playerCount} players</span>
                      <span>{Math.floor(bay.sessionMinutes / 60)}h {bay.sessionMinutes % 60}m</span>
                    </div>
                    {bay.currentBooking.endTime && (
                      <div className="text-muted-foreground">
                        Until {formatTime(bay.currentBooking.endTime)}
                      </div>
                    )}
                  </div>
                )}

                {bay.status === 'MAINTENANCE' && (
                  <div className="text-xs text-muted-foreground">
                    Scheduled maintenance
                  </div>
                )}

                {bay.status === 'CLEANING' && (
                  <div className="text-xs text-muted-foreground">
                    15-min buffer cleanup
                  </div>
                )}

                {bay.status === 'RESERVED' && (
                  <div className="text-xs text-muted-foreground">
                    Next booking holds
                  </div>
                )}

                {bay.needsCleaning && (
                  <Badge variant="outline" className="w-full justify-center text-xs bg-yellow-50 text-yellow-700 border-yellow-200">
                    Needs Cleaning
                  </Badge>
                )}
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Legend */}
      <Card>
        <CardHeader>
          <CardTitle className="text-sm">Status Legend</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 md:grid-cols-5 gap-4 text-xs">
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 rounded-full bg-green-500" />
              <span>Available for booking</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 rounded-full bg-red-500" />
              <span>Currently in use</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 rounded-full bg-yellow-500" />
              <span>Under maintenance</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 rounded-full bg-purple-500" />
              <span>15-min cleanup buffer</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 rounded-full bg-blue-500" />
              <span>Reserved/upcoming</span>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}