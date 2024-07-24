// in rem
const baseLineHeight = 1.5;

// multiples of the base line height
const factors = [0.25, 0.5, 0.75, 1, 1.5, 2];

var lines = factors.reduce(
  (a, v) => ({ ...a, [v]: { $value: baseLineHeight * v } }),
  {},
);

export default {
  size: {
    $type: "number",
    line: lines,
  },
};
