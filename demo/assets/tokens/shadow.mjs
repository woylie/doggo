export default {
  shadow: {
    $type: "shadow",
    elevation: {
      low: {
        $value: [
          {
            color: "#0000000D",
            offsetX: "0px",
            offsetY: "1px",
            blur: "2px",
            spread: "0px",
          },
        ],
      },
      medium: {
        $value: [
          {
            color: "#0000001A",
            offsetX: "0px",
            offsetY: "4px",
            blur: "6px",
            spread: "-1px",
          },
          {
            color: "#0000000F",
            offsetX: "0px",
            offsetY: "2px",
            blur: "4px",
            spread: "-1px",
          },
        ],
      },
      high: {
        $value: [
          {
            color: "#0000001A",
            offsetX: "0px",
            offsetY: "10px",
            blur: "15px",
            spread: "-3px",
          },
          {
            color: "#0000000D",
            offsetX: "0px",
            offsetY: "4px",
            blur: "6px",
            spread: "-2px",
          },
        ],
      },
    },
  },
};
