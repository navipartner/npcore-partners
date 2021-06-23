export const createRipple = (event, isLight = false) => {
  const button = event.currentTarget;
  const rect = button.getBoundingClientRect();

  const circle = document.createElement("span");
  const diameter = Math.max(button.clientWidth, button.clientHeight);
  const radius = diameter / 2;

  circle.style.width = circle.style.height = `${diameter}px`;
  circle.style.left = `${event.clientX - rect.left - radius}px`;
  circle.style.top = `${event.clientY - rect.top - radius}px`;

  circle.classList.add("ripple");

  if (isLight) {
    circle.classList.add("ripple--light");
  }

  const ripple = button.getElementsByClassName("ripple")[0];

  if (ripple) {
    ripple.remove();
  }

  button.appendChild(circle);
};
