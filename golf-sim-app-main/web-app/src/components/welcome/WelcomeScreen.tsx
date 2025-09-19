'use client';

import React, { useState, useEffect } from 'react';
// import { golfColors } from '@/lib/colors';

interface WelcomeScreenProps {
  facilityName?: string;
  onGetStarted?: () => void;
  onMemberLogin?: () => void;
}

export default function WelcomeScreen({ 
  facilityName = "Golf Sim Plus",
  onGetStarted,
  onMemberLogin 
}: WelcomeScreenProps) {
  const [isLoaded, setIsLoaded] = useState(false);

  useEffect(() => {
    setIsLoaded(true);
  }, []);

  return (
    <div className="min-h-screen bg-golf-gradient relative overflow-hidden">
      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-10">
        <div className="absolute top-20 left-10 w-32 h-32 border-2 border-white rounded-full"></div>
        <div className="absolute top-40 right-20 w-24 h-24 border border-white rounded-full"></div>
        <div className="absolute bottom-32 left-20 w-16 h-16 border border-white rounded-full"></div>
        <div className="absolute bottom-20 right-16 w-20 h-20 border-2 border-white rounded-full"></div>
      </div>

      {/* Main Content */}
      <div className={`relative z-10 flex flex-col min-h-screen transition-all duration-1000 ${
        isLoaded ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'
      }`}>
        
        {/* Header */}
        <header className="pt-safe-top px-6 py-8">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-white/20 backdrop-blur-sm rounded-full flex items-center justify-center">
                <div className="w-6 h-6 bg-golf-accent rounded-full"></div>
              </div>
              <h1 className="text-white text-xl font-bold">{facilityName}</h1>
            </div>
            <button 
              onClick={onMemberLogin}
              className="text-white/80 text-sm font-medium hover:text-white transition-colors"
            >
              Member Login
            </button>
          </div>
        </header>

        {/* Hero Section */}
        <main className="flex-1 flex flex-col justify-center px-6 pb-20">
          <div className="text-center space-y-8">
            
            {/* Welcome Message */}
            <div className={`space-y-4 transition-all duration-700 delay-300 ${
              isLoaded ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'
            }`}>
              <h2 className="text-4xl md:text-5xl lg:text-6xl font-bold text-white leading-tight">
                Welcome to
                <br />
                <span className="text-golf-accent">Golf Excellence</span>
              </h2>
              <p className="text-white/80 text-lg md:text-xl max-w-md mx-auto leading-relaxed">
                Experience premium golf simulation technology in a world-class facility
              </p>
            </div>

            {/* Feature Cards */}
            <div className={`grid grid-cols-1 md:grid-cols-3 gap-4 max-w-4xl mx-auto transition-all duration-700 delay-500 ${
              isLoaded ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'
            }`}>
              <FeatureCard 
                icon="🏌️‍♂️"
                title="Book Instantly"
                description="Reserve your bay in seconds"
              />
              <FeatureCard 
                icon="⚡"
                title="Lightning Fast"
                description="10x faster than other systems"
              />
              <FeatureCard 
                icon="🎯"
                title="Premium Experience"
                description="Professional golf simulation"
              />
            </div>

            {/* CTA Buttons */}
            <div className={`space-y-4 transition-all duration-700 delay-700 ${
              isLoaded ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'
            }`}>
              <button
                onClick={onGetStarted}
                className="w-full max-w-sm mx-auto bg-white text-golf-primary font-semibold py-4 px-8 rounded-2xl 
                         shadow-xl hover:shadow-2xl transform hover:scale-105 transition-all duration-200
                         active:scale-95 text-lg"
              >
                Get Started
              </button>
              
              <p className="text-white/60 text-sm">
                Book your first session and experience the difference
              </p>
            </div>
          </div>
        </main>

        {/* Bottom Navigation Hint */}
        <div className={`px-6 pb-8 transition-all duration-700 delay-900 ${
          isLoaded ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'
        }`}>
          <div className="flex justify-center">
            <div className="bg-white/10 backdrop-blur-sm rounded-full px-6 py-3">
              <p className="text-white/80 text-sm text-center">
                Swipe up or tap Get Started to begin
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

// Feature Card Component
interface FeatureCardProps {
  icon: string;
  title: string;
  description: string;
}

function FeatureCard({ icon, title, description }: FeatureCardProps) {
  return (
    <div className="bg-white/10 backdrop-blur-sm rounded-2xl p-6 text-center hover:bg-white/15 transition-all duration-200">
      <div className="text-3xl mb-3">{icon}</div>
      <h3 className="text-white font-semibold text-lg mb-2">{title}</h3>
      <p className="text-white/70 text-sm">{description}</p>
    </div>
  );
}