import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { 
  Users, 
  Calendar, 
  DollarSign, 
  TrendingUp,
  MonitorSpeaker,
  Activity
} from 'lucide-react'

export default function DashboardPage() {
  return (
    <div className="space-y-8">
      {/* Page Header */}
      <div>
        <h1 className="text-3xl font-bold tracking-tight text-evergreen-primary">
          Evergreen Golf Club Admin Dashboard
        </h1>
        <p className="text-muted-foreground">
          Welcome to your facility management dashboard - Beta Version
        </p>
      </div>

      {/* Overview Cards */}
      <div className="grid gap-4 grid-cols-1 sm:grid-cols-2 lg:grid-cols-4" data-testid="overview-cards">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              Total Members
            </CardTitle>
            <Users className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">1,247</div>
            <p className="text-xs text-muted-foreground">
              +12% from last month
            </p>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              Today&apos;s Bookings
            </CardTitle>
            <Calendar className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">89</div>
            <p className="text-xs text-muted-foreground">
              +23% from yesterday
            </p>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              Daily Revenue
            </CardTitle>
            <DollarSign className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">$4,231</div>
            <p className="text-xs text-muted-foreground">
              +18% from yesterday
            </p>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              Bay Utilization
            </CardTitle>
            <TrendingUp className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">73%</div>
            <p className="text-xs text-muted-foreground">
              +5% from last week
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Feature Cards */}
      <div className="grid gap-6 grid-cols-1 md:grid-cols-2 xl:grid-cols-3" data-testid="feature-cards">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <MonitorSpeaker className="h-5 w-5 text-evergreen-primary" />
              Real-Time Bay Status
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground mb-4">
              Monitor live bay occupancy across both locations
            </p>
            <div className="grid grid-cols-3 gap-2 text-xs">
              <div className="text-center p-2 bg-green-50 rounded">
                <div className="font-bold text-green-700">15</div>
                <div className="text-green-600">Available</div>
              </div>
              <div className="text-center p-2 bg-red-50 rounded">
                <div className="font-bold text-red-700">8</div>
                <div className="text-red-600">Occupied</div>
              </div>
              <div className="text-center p-2 bg-yellow-50 rounded">
                <div className="font-bold text-yellow-700">2</div>
                <div className="text-yellow-600">Cleaning</div>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Calendar className="h-5 w-5 text-evergreen-primary" />
              Booking Management
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground mb-4">
              Advanced booking system with 15-minute buffers
            </p>
            <div className="space-y-2 text-xs">
              <div className="flex justify-between">
                <span>Confirmed Today</span>
                <span className="font-bold">89</span>
              </div>
              <div className="flex justify-between">
                <span>Pending Approval</span>
                <span className="font-bold">12</span>
              </div>
              <div className="flex justify-between">
                <span>Waitlisted</span>
                <span className="font-bold">5</span>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Activity className="h-5 w-5 text-evergreen-primary" />
              Member Analytics
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground mb-4">
              Track membership growth and engagement
            </p>
            <div className="space-y-2 text-xs">
              <div className="flex justify-between">
                <span>Rainier (Premium)</span>
                <span className="font-bold">247</span>
              </div>
              <div className="flex justify-between">
                <span>Pike (Standard)</span>
                <span className="font-bold">486</span>
              </div>
              <div className="flex justify-between">
                <span>Cascade (Basic)</span>
                <span className="font-bold">514</span>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Beta Notice */}
      <Card className="border-evergreen-primary">
        <CardHeader>
          <CardTitle className="text-evergreen-primary">
            🚀 Beta Dashboard - September 2025 Launch
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <p className="text-sm">
              Welcome to your advanced Evergreen Golf Club admin dashboard! This beta version showcases 
              the core features that will power your facility management.
            </p>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
              <div>
                <h4 className="font-semibold text-evergreen-primary mb-2">✅ Available Now</h4>
                <ul className="space-y-1 text-muted-foreground">
                  <li>• Real-time bay status monitoring</li>
                  <li>• Comprehensive member database</li>
                  <li>• Advanced booking management</li>
                  <li>• Revenue tracking & analytics</li>
                  <li>• Staff scheduling system</li>
                </ul>
              </div>
              
              <div>
                <h4 className="font-semibold text-evergreen-primary mb-2">🚧 Coming Soon</h4>
                <ul className="space-y-1 text-muted-foreground">
                  <li>• Square POS integration</li>
                  <li>• GoHighLevel marketing sync</li>
                  <li>• iOS app data synchronization</li>
                  <li>• Automated member communications</li>
                  <li>• Advanced reporting dashboard</li>
                </ul>
              </div>
            </div>

            <div className="mt-4 p-3 bg-evergreen-50 rounded-lg">
              <p className="text-xs text-evergreen-700">
                <strong>Hybrid Architecture:</strong> This dashboard works seamlessly with GoHighLevel for marketing 
                automation while providing advanced facility management features that surpass USchedule capabilities.
              </p>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}