'use client';

import React, { useState, useEffect, useRef } from 'react';
import { golfColors } from '@/lib/colors';

interface PremiumWelcomeScreenProps {
  facilityName?: string;
  onGetStarted?: () => void;
  onMemberLogin?: () => void;
}

export default function PremiumWelcomeScreen({ 
  facilityName = "Golf Sim Plus",
  onGetStarted,
  onMemberLogin 
}: PremiumWelcomeScreenProps) {
  // Premium animation states
  const [isLoaded, setIsLoaded] = useState(false);
  const [heroAnimationTrigger, setHeroAnimationTrigger] = useState(false);
  const [breathingEffect, setBreathingEffect] = useState(false);
  const [parallaxOffset, setParallaxOffset] = useState(0);
  const [statusGlow, setStatusGlow] = useState(false);
  const [mousePosition, setMousePosition] = useState({ x: 0, y: 0 });
  
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    // Trigger animation sequence
    const timer1 = setTimeout(() => setIsLoaded(true), 100);
    const timer2 = setTimeout(() => setBreathingEffect(true), 300);
    const timer3 = setTimeout(() => setHeroAnimationTrigger(true), 500);
    const timer4 = setTimeout(() => setStatusGlow(true), 2000);

    return () => {
      clearTimeout(timer1);
      clearTimeout(timer2);
      clearTimeout(timer3);
      clearTimeout(timer4);
    };
  }, []);

  // Mouse parallax effect
  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      if (containerRef.current) {
        const rect = containerRef.current.getBoundingClientRect();
        const x = (e.clientX - rect.left - rect.width / 2) / rect.width;
        const y = (e.clientY - rect.top - rect.height / 2) / rect.height;
        setMousePosition({ x: x * 20, y: y * 20 });
      }
    };

    window.addEventListener('mousemove', handleMouseMove);
    return () => window.removeEventListener('mousemove', handleMouseMove);
  }, []);

  // Scroll parallax effect
  useEffect(() => {
    const handleScroll = () => {
      setParallaxOffset(window.scrollY);
    };

    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <div 
      ref={containerRef}
      className="min-h-screen relative overflow-hidden bg-gradient-to-br from-golf-tertiary via-golf-primary to-golf-secondary"
    >
      {/* Premium Animated Background */}
      <div className="absolute inset-0">
        {/* Floating premium orbs with parallax */}
        {[0, 1, 2, 3].map((index) => (
          <div
            key={index}
            className={`absolute w-60 h-60 rounded-full blur-3xl opacity-20 ${
              breathingEffect ? 'animate-golf-pulse' : ''
            }`}
            style={{
              background: `radial-gradient(circle, ${golfColors.evergreenSecondary}20 0%, ${golfColors.evergreenPrimary}10 50%, transparent 100%)`,
              left: index % 2 === 0 ? '-100px' : 'calc(100% + 100px)',
              top: `${index * 180 - 100 + parallaxOffset * (index + 1) * 0.1}px`,
              transform: `translate(${mousePosition.x * (index + 1) * 0.2}px, ${mousePosition.y * (index + 1) * 0.2}px)`,
              animationDelay: `${index * 1000}ms`,
              animationDuration: `${5000 + index * 1000}ms`,
            }}
          />
        ))}

        {/* Premium mesh gradient overlay */}
        <div 
          className={`absolute inset-0 bg-gradient-to-tr from-transparent via-golf-primary/5 to-transparent ${
            breathingEffect ? 'animate-pulse' : ''
          }`}
          style={{
            transform: `scale(${breathingEffect ? 1.1 : 0.9})`,
            transition: 'transform 8s ease-in-out infinite alternate',
          }}
        />

        {/* Sophisticated grid pattern */}
        <div className="absolute inset-0 opacity-5">
          <div className="w-full h-full" style={{
            backgroundImage: `
              radial-gradient(circle at 25% 25%, ${golfColors.golfAccent} 2px, transparent 2px),
              radial-gradient(circle at 75% 75%, ${golfColors.evergreenSecondary} 1px, transparent 1px)
            `,
            backgroundSize: '100px 100px, 60px 60px',
            transform: `translate(${mousePosition.x * 0.5}px, ${mousePosition.y * 0.5}px)`,
          }} />
        </div>
      </div>

      {/* Main Content */}
      <div className="relative z-10 flex flex-col min-h-screen">
        
        {/* Premium Header */}
        <header className={`pt-safe-top px-6 py-8 transition-all duration-1000 ${
          isLoaded ? 'opacity-100 translate-y-0' : 'opacity-0 -translate-y-4'
        }`}>
          <div className="flex items-center justify-between">
            
            {/* Premium brand identity */}
            <div className="flex items-center space-x-4">
              {/* Sophisticated avatar with breathing effect */}
              <div className="relative">
                <div className={`w-16 h-16 rounded-full bg-gradient-to-br from-golf-accent to-golf-gold flex items-center justify-center shadow-golf transition-all duration-1000 ${
                  breathingEffect ? 'scale-105' : 'scale-100'
                }`}>
                  <div className="text-white text-xl font-bold">⛳</div>
                </div>
                
                {/* Premium status indicator */}
                <div className={`absolute -bottom-1 -right-1 w-5 h-5 bg-gradient-to-r from-green-400 to-green-500 rounded-full border-2 border-white shadow-lg transition-all duration-1000 ${
                  statusGlow ? 'animate-pulse scale-110' : ''
                }`} />
                
                {/* Outer glow ring */}
                <div className={`absolute inset-0 w-16 h-16 rounded-full border-2 border-white/30 transition-all duration-3000 ${
                  breathingEffect ? 'scale-110 opacity-70' : 'scale-100 opacity-100'
                }`} />
              </div>
              
              <div>
                <h1 className="text-white text-xl font-bold tracking-tight">{facilityName}</h1>
                <p className="text-white/80 text-sm font-medium">Premium Golf Simulation</p>
              </div>
            </div>
            
            {/* Member access */}
            <button 
              onClick={onMemberLogin}
              className="text-white/90 text-sm font-semibold hover:text-white transition-all duration-200 hover:scale-105 active:scale-95"
            >
              Member Access
            </button>
          </div>
        </header>

        {/* Premium Hero Section */}
        <main className="flex-1 flex flex-col justify-center px-6 pb-20">
          <div className="text-center space-y-12 max-w-4xl mx-auto">
            
            {/* Hero messaging with sophisticated animations */}
            <div className={`space-y-6 transition-all duration-1000 delay-300 ${
              heroAnimationTrigger ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'
            }`}>
              <div className="space-y-4">
                <h2 className="text-5xl md:text-7xl lg:text-8xl font-black text-white leading-none tracking-tight">
                  <span className="block">ELEVATE</span>
                  <span className="block bg-gradient-to-r from-golf-accent to-golf-gold bg-clip-text text-transparent">
                    YOUR GAME
                  </span>
                </h2>
                <p className="text-white/90 text-xl md:text-2xl font-medium max-w-2xl mx-auto leading-relaxed">
                  Experience professional-grade golf simulation with 
                  <span className="text-golf-accent font-semibold"> lightning-fast booking</span> 
                  — 10x faster than any competitor
                </p>
              </div>
            </div>

            {/* Premium feature showcase */}
            <div className={`grid grid-cols-1 md:grid-cols-3 gap-6 max-w-5xl mx-auto transition-all duration-1000 delay-500 ${
              isLoaded ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'
            }`}>
              <PremiumFeatureCard 
                icon="⚡"
                title="8-Second Booking"
                subtitle="Lightning Speed"
                description="Reserve your bay instantly with our revolutionary booking system"
                delay={0}
              />
              <PremiumFeatureCard 
                icon="🎯"
                title="Premium Simulation"
                subtitle="Pro Technology"
                description="Experience the most advanced golf simulation technology available"
                delay={200}
              />
              <PremiumFeatureCard 
                icon="💳"
                title="Universal Tab"
                subtitle="One Payment"
                description="Simulator, food, drinks — everything on one seamless tab"
                delay={400}
              />
            </div>

            {/* Premium CTA section */}
            <div className={`space-y-8 transition-all duration-1000 delay-700 ${
              isLoaded ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'
            }`}>
              
              {/* Main CTA with sophisticated hover effects */}
              <div className="space-y-4">
                <button
                  onClick={onGetStarted}
                  className="group relative w-full max-w-md mx-auto bg-gradient-to-r from-white to-gray-50 text-golf-primary font-bold py-6 px-12 rounded-2xl 
                           shadow-2xl hover:shadow-accent transform hover:scale-105 active:scale-98 transition-all duration-300
                           overflow-hidden"
                >
                  <div className="absolute inset-0 bg-gradient-to-r from-golf-accent to-golf-gold opacity-0 group-hover:opacity-10 transition-opacity duration-300" />
                  <span className="relative z-10 text-xl tracking-wide">
                    START YOUR SESSION
                  </span>
                  <div className="absolute bottom-0 left-0 right-0 h-1 bg-gradient-to-r from-golf-accent to-golf-gold transform scale-x-0 group-hover:scale-x-100 transition-transform duration-300" />
                </button>
                
                <p className="text-white/70 text-base font-medium">
                  Book instantly • Premium experience • Way better than USchedule
                </p>
              </div>

              {/* Social proof indicators */}
              <div className="flex items-center justify-center space-x-8 text-white/60">
                <div className="text-center">
                  <div className="text-2xl font-bold text-white">4.9★</div>
                  <div className="text-sm">Customer Rating</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-white">8s</div>
                  <div className="text-sm">Avg Booking Time</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-white">10x</div>
                  <div className="text-sm">Faster Than Others</div>
                </div>
              </div>
            </div>
          </div>
        </main>

        {/* Premium bottom navigation hint */}
        <div className={`px-6 pb-8 transition-all duration-1000 delay-900 ${
          isLoaded ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'
        }`}>
          <div className="flex justify-center">
            <div className="glass-effect rounded-full px-8 py-4 backdrop-blur-sm">
              <p className="text-white/90 text-sm text-center font-medium">
                👆 Tap &ldquo;Start Your Session&rdquo; to experience the future of golf booking
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

// Premium Feature Card Component
interface PremiumFeatureCardProps {
  icon: string;
  title: string;
  subtitle: string;
  description: string;
  delay: number;
}

function PremiumFeatureCard({ icon, title, subtitle, description, delay }: PremiumFeatureCardProps) {
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    const timer = setTimeout(() => setIsVisible(true), delay);
    return () => clearTimeout(timer);
  }, [delay]);

  return (
    <div className={`group relative transition-all duration-700 ${
      isVisible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'
    }`}>
      <div className="glass-effect rounded-3xl p-8 text-center hover:bg-white/15 transition-all duration-300 
                      transform hover:scale-105 hover:shadow-2xl overflow-hidden relative">
        
        {/* Premium background effect */}
        <div className="absolute inset-0 bg-gradient-to-br from-white/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
        
        {/* Content */}
        <div className="relative z-10">
          <div className="text-4xl mb-4 transform group-hover:scale-110 transition-transform duration-300">
            {icon}
          </div>
          <div className="text-golf-accent text-sm font-bold uppercase tracking-wider mb-2">
            {subtitle}
          </div>
          <h3 className="text-white font-bold text-xl mb-3">
            {title}
          </h3>
          <p className="text-white/80 text-sm leading-relaxed">
            {description}
          </p>
        </div>

        {/* Premium accent line */}
        <div className="absolute bottom-0 left-0 right-0 h-1 bg-gradient-to-r from-golf-accent to-golf-gold transform scale-x-0 group-hover:scale-x-100 transition-transform duration-500" />
      </div>
    </div>
  );
}