<script>
  import { onMount } from 'svelte';

  let canvas;

  onMount(() => {
    if (typeof window === 'undefined') return;

    const ctx = canvas?.getContext('2d');
    let animationFrameId;

    if (ctx) {
      let width = (canvas.width = window.innerWidth);
      let height = (canvas.height = window.innerHeight);

      // Stars
      const stars = [];
      for (let i = 0; i < 300; i++) {
        stars.push({
          x: Math.random() * width,
          y: Math.random() * height,
          size: Math.random() * 1.2, // Crisp, distant stars
          opacity: Math.random(),
          twinkleSpeed: Math.random() * 0.005 + 0.001,
        });
      }

      // Cyber-Particles (Data motes)
      const particles = [];
      for (let i = 0; i < 40; i++) {
        particles.push({
          x: Math.random() * width,
          y: Math.random() * height,
          vx: (Math.random() - 0.5) * 0.15, // Slow, drift movement
          vy: (Math.random() - 0.5) * 0.15,
          size: Math.random() * 1.5 + 0.5,
          opacity: Math.random() * 0.4 + 0.1,
          color: Math.random() > 0.5 ? '#00d1b2' : '#38bdf8' // Cyan and Sky Blue
        });
      }

      const draw = () => {
        ctx.clearRect(0, 0, width, height);

        // Draw Stars
        stars.forEach(star => {
          star.opacity += star.twinkleSpeed;
          if (star.opacity > 1 || star.opacity < 0.1) {
            star.twinkleSpeed *= -1;
          }
          ctx.fillStyle = `rgba(255, 255, 255, ${Math.abs(star.opacity)})`;
          ctx.beginPath();
          ctx.arc(star.x, star.y, star.size, 0, Math.PI * 2);
          ctx.fill();
        });

        // Draw Particles with Glow
        particles.forEach(particle => {
          particle.x += particle.vx;
          particle.y += particle.vy;

          // Wrap around screen
          if (particle.x < 0) particle.x = width;
          if (particle.x > width) particle.x = 0;
          if (particle.y < 0) particle.y = height;
          if (particle.y > height) particle.y = 0;

          ctx.shadowBlur = 8;
          ctx.shadowColor = particle.color;
          ctx.fillStyle = particle.color;
          ctx.globalAlpha = particle.opacity;
          ctx.beginPath();
          ctx.arc(particle.x, particle.y, particle.size, 0, Math.PI * 2);
          ctx.fill();
          ctx.globalAlpha = 1;
          ctx.shadowBlur = 0;
        });

        animationFrameId = requestAnimationFrame(draw);
      };

      draw();

      const handleResize = () => {
        width = canvas.width = window.innerWidth;
        height = canvas.height = window.innerHeight;
      };
      window.addEventListener('resize', handleResize);
      
      return () => {
        window.removeEventListener('resize', handleResize);
        cancelAnimationFrame(animationFrameId);
      };
    }
  });
</script>

<div class="moonlight-container">
  <div class="deep-space-bg"></div>
  <div class="halo-moon-glow"></div>
  <div class="nebula-fog"></div>
  <canvas bind:this={canvas}></canvas>
</div>

<style>
  .moonlight-container {
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    z-index: -1;
    overflow: hidden;
    background-color: #050505;
  }

  .deep-space-bg {
    position: absolute;
    width: 100%;
    height: 100%;
    background: radial-gradient(circle at 50% 120%, #0f172a 0%, #020617 50%, #000000 100%);
    z-index: -4;
  }

  /* The "Moonlight" effect - a top-center cool glow */
  .halo-moon-glow {
    position: absolute;
    top: -20%;
    left: 50%;
    transform: translateX(-50%);
    width: 100vw;
    height: 100vw; /* Creates a large circle */
    background: radial-gradient(circle, 
      rgba(0, 209, 178, 0.08) 0%, 
      rgba(56, 189, 248, 0.03) 40%, 
      transparent 70%);
    border-radius: 50%;
    z-index: -3;
    pointer-events: none;
    filter: blur(60px);
  }

  /* Subtle moving fog for depth */
  .nebula-fog {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: 
      radial-gradient(circle at 15% 50%, rgba(30, 58, 138, 0.1) 0%, transparent 50%),
      radial-gradient(circle at 85% 30%, rgba(15, 118, 110, 0.05) 0%, transparent 50%);
    z-index: -2;
    filter: blur(80px);
    animation: breathe 20s ease-in-out infinite alternate;
  }

  canvas {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    z-index: -1;
  }

  @keyframes breathe {
    0% { opacity: 0.6; transform: scale(1); }
    100% { opacity: 0.9; transform: scale(1.05); }
  }
</style>
