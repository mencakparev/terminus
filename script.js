// Subtle, smooth parallax drift on the wordmark, following the pointer.
(function () {
  const wordmark = document.getElementById("wordmark");
  if (!wordmark) return;

  const prefersReducedMotion = window.matchMedia(
    "(prefers-reduced-motion: reduce)"
  ).matches;
  if (prefersReducedMotion || window.matchMedia("(hover: none)").matches) {
    return;
  }

  let targetX = 0;
  let targetY = 0;
  let currentX = 0;
  let currentY = 0;
  const maxOffset = 10;

  window.addEventListener("mousemove", (e) => {
    const nx = e.clientX / window.innerWidth - 0.5;
    const ny = e.clientY / window.innerHeight - 0.5;
    targetX = nx * maxOffset;
    targetY = ny * (maxOffset * 0.5);
  });

  function animate() {
    currentX += (targetX - currentX) * 0.06;
    currentY += (targetY - currentY) * 0.06;
    wordmark.style.transform = `translate3d(${currentX.toFixed(
      2
    )}px, ${currentY.toFixed(2)}px, 0)`;
    requestAnimationFrame(animate);
  }

  requestAnimationFrame(animate);
})();
