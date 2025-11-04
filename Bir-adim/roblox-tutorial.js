// Roblox Tutorial Interactive Features

document.addEventListener("DOMContentLoaded", () => {
  console.log("Roblox Tutorial sayfası yüklendi!");
  
  // Copy code functionality for code blocks
  const codeBlocks = document.querySelectorAll(".code-block");
  
  codeBlocks.forEach((block, index) => {
    // Create copy button
    const copyButton = document.createElement("button");
    copyButton.textContent = "📋 Kodu Kopyala";
    copyButton.className = "copy-button";
    copyButton.style.cssText = `
      position: absolute;
      top: 10px;
      right: 10px;
      background: #667eea;
      color: white;
      border: none;
      padding: 8px 15px;
      border-radius: 5px;
      cursor: pointer;
      font-size: 0.9em;
      transition: background 0.3s;
    `;
    
    // Make code block relative for button positioning
    block.style.position = "relative";
    block.appendChild(copyButton);
    
    // Copy functionality
    copyButton.addEventListener("click", () => {
      const codeText = block.querySelector("code").textContent;
      
      // Use clipboard API
      navigator.clipboard.writeText(codeText).then(() => {
        copyButton.textContent = "✅ Kopyalandı!";
        copyButton.style.background = "#28a745";
        
        setTimeout(() => {
          copyButton.textContent = "📋 Kodu Kopyala";
          copyButton.style.background = "#667eea";
        }, 2000);
      }).catch(() => {
        // Fallback for older browsers
        const textarea = document.createElement("textarea");
        textarea.value = codeText;
        document.body.appendChild(textarea);
        textarea.select();
        document.execCommand("copy");
        document.body.removeChild(textarea);
        
        copyButton.textContent = "✅ Kopyalandı!";
        copyButton.style.background = "#28a745";
        
        setTimeout(() => {
          copyButton.textContent = "📋 Kodu Kopyala";
          copyButton.style.background = "#667eea";
        }, 2000);
      });
    });
    
    // Hover effect
    copyButton.addEventListener("mouseenter", () => {
      if (copyButton.textContent === "📋 Kodu Kopyala") {
        copyButton.style.background = "#5568d3";
      }
    });
    
    copyButton.addEventListener("mouseleave", () => {
      if (copyButton.textContent === "📋 Kodu Kopyala") {
        copyButton.style.background = "#667eea";
      }
    });
  });
  
  // Smooth scroll for internal links
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener("click", function(e) {
      e.preventDefault();
      const target = document.querySelector(this.getAttribute("href"));
      if (target) {
        target.scrollIntoView({
          behavior: "smooth",
          block: "start"
        });
      }
    });
  });
  
  // Progress tracker for reading
  const sections = document.querySelectorAll(".tutorial-step");
  const totalSections = sections.length;
  let completedSections = 0;
  
  // Create progress indicator
  const progressBar = document.createElement("div");
  progressBar.style.cssText = `
    position: fixed;
    top: 0;
    left: 0;
    width: 0%;
    height: 4px;
    background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
    z-index: 9999;
    transition: width 0.3s ease;
  `;
  document.body.appendChild(progressBar);
  
  // Update progress on scroll
  window.addEventListener("scroll", () => {
    const windowHeight = window.innerHeight;
    const documentHeight = document.documentElement.scrollHeight - windowHeight;
    const scrolled = window.scrollY;
    const progress = (scrolled / documentHeight) * 100;
    
    progressBar.style.width = progress + "%";
  });
  
  // Add animation class to sections when they come into view
  const observerOptions = {
    threshold: 0.1,
    rootMargin: "0px 0px -100px 0px"
  };
  
  const sectionObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.style.opacity = "0";
        entry.target.style.transform = "translateY(20px)";
        entry.target.style.transition = "opacity 0.6s ease, transform 0.6s ease";
        
        setTimeout(() => {
          entry.target.style.opacity = "1";
          entry.target.style.transform = "translateY(0)";
        }, 100);
        
        sectionObserver.unobserve(entry.target);
      }
    });
  }, observerOptions);
  
  sections.forEach(section => {
    sectionObserver.observe(section);
  });
  
  // Add "Back to Top" button
  const backToTopButton = document.createElement("button");
  backToTopButton.textContent = "⬆️ Yukarı";
  backToTopButton.className = "back-to-top";
  backToTopButton.style.cssText = `
    position: fixed;
    bottom: 30px;
    right: 30px;
    background: #667eea;
    color: white;
    border: none;
    padding: 12px 20px;
    border-radius: 50px;
    cursor: pointer;
    font-size: 1em;
    font-weight: bold;
    box-shadow: 0 4px 8px rgba(0,0,0,0.3);
    opacity: 0;
    visibility: hidden;
    transition: opacity 0.3s, visibility 0.3s, background 0.3s;
    z-index: 1000;
  `;
  document.body.appendChild(backToTopButton);
  
  backToTopButton.addEventListener("click", () => {
    window.scrollTo({
      top: 0,
      behavior: "smooth"
    });
  });
  
  backToTopButton.addEventListener("mouseenter", () => {
    backToTopButton.style.background = "#5568d3";
  });
  
  backToTopButton.addEventListener("mouseleave", () => {
    backToTopButton.style.background = "#667eea";
  });
  
  // Show/hide back to top button
  window.addEventListener("scroll", () => {
    if (window.scrollY > 300) {
      backToTopButton.style.opacity = "1";
      backToTopButton.style.visibility = "visible";
    } else {
      backToTopButton.style.opacity = "0";
      backToTopButton.style.visibility = "hidden";
    }
  });
  
  // Add interactive checklist functionality
  const checklistItems = document.querySelectorAll(".test-checklist ul li");
  checklistItems.forEach(item => {
    item.style.cursor = "pointer";
    item.addEventListener("click", function() {
      this.style.textDecoration = this.style.textDecoration === "line-through" ? "none" : "line-through";
      this.style.opacity = this.style.textDecoration === "line-through" ? "0.6" : "1";
    });
  });
  
  console.log("Tüm interaktif özellikler yüklendi!");
});
