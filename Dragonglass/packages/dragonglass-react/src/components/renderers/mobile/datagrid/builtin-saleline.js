// TODO: this file should go somewhere else, it's not just mobile, it will eventually have desktop version too

const setup = {
  mobile: {
    buttons: {
      left: [
        {
          icon: "fa-trash-can",
          caption: "Delete",
          action: "DELETE_POS_LINE",
        },
      ],
      right: [
        {
          icon: "fa-percent",
          caption: "Discount",
          action: "DISCOUNT",
        },
        {
          icon: "fa-circle-plus",
          caption: "Quantity",
          action: "QUANTITY",
        },
      ],
    },
    layout: [
      {
        controls: [
          {
            fieldNo: 10,
          },
          {
            fieldNo: 12,
          },
        ],
      },
      {
        controls: [
          {
            caption: "price",
            fieldNo: 15,
          },
          {
            caption: "total",
            fieldNo: 31,
          },
        ],
      },
    ],
  },
};

export default setup;
