'use client'

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'

export function RevenueMetrics() {
  return (
    <div className="grid gap-4 md:grid-cols-2">
      <Card>
        <CardHeader>
          <CardTitle>Revenue Overview</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="text-sm text-muted-foreground">
            Revenue charts will appear here...
          </div>
        </CardContent>
      </Card>
      
      <Card>
        <CardHeader>
          <CardTitle>Top Revenue Sources</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="text-sm text-muted-foreground">
            Revenue breakdown will appear here...
          </div>
        </CardContent>
      </Card>
    </div>
  )
}