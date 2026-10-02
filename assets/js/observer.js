const watchers = new Map();

// The elements a mutation may have changed, and whether their descendants
// count too: a text change concerns the element around it, an added subtree
// or a changed attribute everything below.
function touched(mutation) {
  if (mutation.type === "attributes") return [[mutation.target, true]];

  if (mutation.type === "childList") {
    return [
      [mutation.target, false],
      ...[...mutation.addedNodes]
        .filter((node) => node.nodeType === 1)
        .map((node) => [node, true]),
    ];
  }

  return mutation.target.parentElement
    ? [[mutation.target.parentElement, false]]
    : [];
}

function run(watcher, el, deep) {
  const { selector, update, written } = watcher;

  if (deep) {
    if (el.matches?.(selector)) update(el);
    el.querySelectorAll?.(selector).forEach(update);
    return;
  }

  // An element whose text is still the one the client wrote needs nothing;
  // this skips the mutation that the write itself causes.
  const target = el.closest?.(selector);
  if (target && target.textContent.trim() !== written.get(target)) {
    update(target);
  }
}

// Formats the matching elements below `root` and keeps them formatted. One
// observer per root serves every watcher: it needs no id on the elements, and
// it corrects a patch that restores the server text in the same microtask,
// before the browser paints.
export function watch(root, watcher) {
  run(watcher, root, true);

  if (watchers.has(root)) {
    watchers.get(root).add(watcher);
    return;
  }

  const registered = new Set([watcher]);
  watchers.set(root, registered);

  new MutationObserver((mutations) => {
    const changes = mutations.flatMap(touched);
    for (const each of registered) {
      for (const [el, deep] of changes) run(each, el, deep);
    }
  }).observe(root, {
    subtree: true,
    childList: true,
    characterData: true,
    attributes: true,
    attributeFilter: [
      "datetime",
      "data-localize",
      "data-relative-sync",
      "lang",
    ],
  });
}
