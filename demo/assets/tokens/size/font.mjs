// Modular font scale. This is the factor between two font sizes.
const modularScale = 1.2;

// The base size is `m` (1rem). Set the number of smaller sizes and
// and larger sizes relative to the base size here.
const smallerSizes = 2;
const largerSizes = 6;

const addSmallerSizes = (sizes, scale, smallerSizes) => {
  for (let i = smallerSizes; i >= 1; i--) {
    let rem = Math.pow(scale, -1 * i);
    let xCount = i - 1;
    let name = "x".repeat(xCount) + "s";
    sizes[name] = { $value: rem.toFixed(3) };
  }

  return sizes;
};

const addLargerSizes = (sizes, scale, largerSizes) => {
  for (let i = 1; i <= largerSizes; i++) {
    let rem = Math.pow(scale, 1 * i);
    let xCount = i - 1;
    let name = "x".repeat(xCount) + "l";
    sizes[name] = { $value: rem.toFixed(3) };
  }

  return sizes;
};

const addBaseSize = (sizes, scale) => {
  sizes["m"] = { $value: 1 };
  return sizes;
};

let sizes = {};
sizes = addSmallerSizes(sizes, modularScale, smallerSizes);
sizes = addBaseSize(sizes, modularScale);
sizes = addLargerSizes(sizes, modularScale, largerSizes);

export default {
  size: {
    $type: "dimension",
    font: sizes,
  },
};
