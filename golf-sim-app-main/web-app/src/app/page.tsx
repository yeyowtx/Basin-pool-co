'use client';

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-green-800 via-green-600 to-green-500 flex flex-col justify-center items-center text-white p-6">
      <div className="text-center space-y-8 max-w-md">
        <div className="space-y-4">
          <div className="text-6xl">⛳</div>
          <h1 className="text-5xl font-black">GOLF SIM PLUS</h1>
          <p className="text-xl opacity-90">Premium Golf Simulation</p>
        </div>
        
        <div className="space-y-6">
          <button 
            onClick={() => alert('Booking system coming soon!')}
            className="w-full bg-white text-green-800 font-bold py-4 px-8 rounded-xl text-xl hover:bg-gray-100 active:bg-gray-200 transition-colors"
          >
            START YOUR SESSION
          </button>
          
          <div className="grid grid-cols-3 gap-4 text-center">
            <div>
              <div className="text-2xl font-bold">4.9★</div>
              <div className="text-sm opacity-80">Rating</div>
            </div>
            <div>
              <div className="text-2xl font-bold">8s</div>
              <div className="text-sm opacity-80">Booking</div>
            </div>
            <div>
              <div className="text-2xl font-bold">10x</div>
              <div className="text-sm opacity-80">Faster</div>
            </div>
          </div>
        </div>
        
        <p className="text-sm opacity-75">
          Experience the fastest golf simulation booking system
        </p>
      </div>
    </div>
  );
}