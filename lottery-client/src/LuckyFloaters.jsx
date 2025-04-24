import React from "react";
import "./assets/LuckyFloaters.css"; // Import CSS for animations

const emojis = ["🎉", "🍀", "🎲", "💰", "🎰", "🧨"];

function LuckyFloaters() {
  return (
    <div className="absolute inset-0 overflow-hidden pointer-events-none z-0">
      {Array.from({ length: 100 }).map((_, i) => {
        const emoji = emojis[i % emojis.length];
        const left = Math.random() * 100;
        const top = Math.random() * 100;
        const size = 12 + Math.random() * 20; // nhỏ hơn
        const duration = 8 + Math.random() * 12;
        const delay = Math.random() * 10;

        return (
          <span
            key={i}
            style={{
              left: `${left}%`,
              top: `${top}%`,
              fontSize: `${size}px`,
              animationDuration: `${duration}s`,
              animationDelay: `${delay}s`,
            }}
            className="absolute animate-float text-white opacity-20"
          >
            {emoji}
          </span>
        );
      })}
    </div>
  );
}

export default LuckyFloaters
