document.addEventListener('DOMContentLoaded', () => {

  const aiButton = document.getElementById('ai-toggle-btn');
  const appLayout = document.querySelector('.app-layout'); // changes the display layout
  const aiPanel = document.querySelector(".right-panel"); // toggles the AI chat box

  if (aiButton && appLayout) {
    aiButton.addEventListener('click', () => {
      appLayout.classList.toggle('ai-open');
      aiPanel.classList.toggle("open");
      aiButton.textContent =
        appLayout.classList.contains('ai-open')
          ? 'Close Portal AI'
          : 'Ask Portal AI';
    });
  }

  // Follow toggle — support elements using either class or id and normalize initial text
  const followEls = document.querySelectorAll('.follow-state, #follow-state');
  followEls.forEach(el => {
    el.style.cursor = 'pointer';
    // If the element contains both options (e.g. "★ Following / ☆ Follow"), normalize to a single state
    if (el.textContent.includes('/')) {
      const hasFollowing = el.textContent.includes('★ Following');
      el.textContent = hasFollowing ? '★ Following' : '☆ Follow';
    }

    el.addEventListener('click', () => {
      const isFollowing = el.textContent.includes('★');
      el.textContent = isFollowing ? '☆ Follow' : '★ Following';
    });
  });

  // Animate stability bar
  document.querySelectorAll('.stability-bar-fill').forEach(bar => {
    const width = bar.style.width;
    bar.style.width = '0';
    setTimeout(() => bar.style.width = width, 200);
  });

  document.querySelectorAll(".toggle").forEach(toggle => {
    toggle.addEventListener("click", () => {
        toggle.classList.toggle("on");
    });
  });

});
