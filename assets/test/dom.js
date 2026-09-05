export function render(html) {
  document.body.innerHTML = html;
  return document.body.firstElementChild;
}

export function press(el, key) {
  el.dispatchEvent(
    new window.KeyboardEvent("keydown", {
      key,
      bubbles: true,
      cancelable: true,
    }),
  );
}
