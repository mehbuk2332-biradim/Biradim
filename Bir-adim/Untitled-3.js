document.addEventListener("DOMContentLoaded", () => {
  const heroSection = document.querySelector(".hero");
  
  const infoButton = document.createElement("button");
  infoButton.textContent = "Detaylı Bilgi";
  infoButton.style.padding = "10px 20px";
  infoButton.onclick = () => {
    alert("Kurslarımız hakkında detaylı bilgi için 'Kurslar' sekmesini ziyaret edin!");
  };

  heroSection.appendChild(infoButton);
});