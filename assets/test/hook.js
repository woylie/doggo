// Minimal stand-in for LiveView's ViewHook
export function mount(hook, el) {
  const instance = Object.create(hook);
  instance.el = el;
  instance.mounted();
  return instance;
}

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
