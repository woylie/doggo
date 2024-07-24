export default {
  size: {
    $type: "dimension",
    gutter: { $value: "1.5rem" },
    measure: { $value: "65ch", comment: "The maximum paragraph width." },
    spacer: {
      $value: "0.25rem",
      comment:
        "Base value for paddings and margins. All paddings and margins should be a multiple of this value.",
    },
  },
  internal: {
    size: {
      $type: "number",
      spacer: {
        factors: {
          $value: [1, 2, 3, 4, 5, 6, 7, 8],
          comment:
            "The factors are multiplied with the spacer base. These values are the basis for the utility classes. You can still use other factors in the scss files.",
        },
      },
    },
  },
};
