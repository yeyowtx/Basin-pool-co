import { Sidebar } from '@/components/dashboard/sidebar'
import { Header } from '@/components/dashboard/header'
import { MobileNav } from '@/components/dashboard/mobile-nav'
export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  // Auth disabled for beta deployment
  // const session = await getServerSession(authOptions)
  // if (!session) {
  //   redirect('/auth/signin')
  // }

  return (
    <div className="h-screen flex overflow-hidden bg-background">
      {/* Desktop Sidebar */}
      <Sidebar />
      
      {/* Main Content */}
      <div className="flex flex-col flex-1 overflow-hidden">
        <Header />
        
        <main className="flex-1 overflow-y-auto focus:outline-none">
          <div className="py-6">
            <div className="container-fluid w-full px-4 sm:px-6 md:px-8 2xl:px-12">
              {children}
            </div>
          </div>
        </main>
      </div>
      
      {/* Mobile Navigation */}
      <MobileNav />
    </div>
  )
}