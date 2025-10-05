import { redirect } from 'next/navigation'

export default async function HomePage() {
  // Auth disabled for beta deployment
  // const session = await getServerSession(authOptions)
  // if (!session) {
  //   redirect('/auth/signin')
  // }
  
  // Redirect to dashboard
  redirect('/dashboard')
}