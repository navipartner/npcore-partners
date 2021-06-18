const __npre_restaurants = [
  {
    id: "R1",
    caption: "Titangade",
  },
  {
    id: "R2",
    caption: "Zagreb",
  },
  {
    id: "R3",
    caption: "Mauritius",
  },
];

const __npre_locations = [
  {
    restaurantId: "R2",
    id: "ZAG-1",
    caption: "Kitchen",
    components: [
      {
        type: "bar",
        id: "bar1",
        caption: "Bar",
        blob: '{ "x": "1000", "y": "40" }',
      },
      {
        type: "table",
        id: "table1",
        caption: "T-1",
        capacity: 8,
        blob: '{ "chairs": { "count": 8, "min": 4, "max": 12 }, "width": "3", "height": "1", "x": "400", "y": "100" }',
      },
    ],
  },
  {
    restaurantId: "R1",
    id: "R1-K",
    caption: "Køkkenet",
    components: [
      {
        type: "table",
        id: "R1-K-1",
        caption: "Long Table",
        capacity: 8,
        blob: '{ "chairs": { "count": 8, "min": 3, "max": 5 }, "width": "4", "height": "1", "x": "100", "y": "100" }',
        color: "red",
      },
      {
        type: "table",
        id: "R1-K-2",
        caption: "Big Table",
        capacity: 10,
        blob: '{ "chairs": { "count": 10, "min": 10, "max": 10 }, "width": "4", "height": "2", "x": "600", "y": "110" }',
        color: "green",
      },
      {
        type: "table",
        id: "R1-K-3",
        caption: "Small Table",
        capacity: 6,
        blob: '{ "chairs": { "count": 6, "min": 4, "max": 8 }, "width": "2", "height": "1", "x": "100", "y": "400" }',
      },
    ],
  },
  {
    restaurantId: "R1",
    id: "R1-S",
    caption: "Støberihallen",
    components: [
      {
        type: "table",
        id: "table1-2-1",
        caption: "Table 1",
        capacity: 4,
        blob: '{ "chairs": { "count": 4, "min": 4, "max": 12 }, "width": "1", "height": "1", "x": "400", "y": "200" }',
      },
      {
        type: "table",
        id: "table1-2-2",
        caption: "Table 2",
        capacity: 4,
        blob: '{ "chairs": { "count": 4, "min": 4, "max": 12 }, "width": "1", "height": "1", "x": "600", "y": "200" }',
      },
      {
        type: "table",
        id: "table1-2-3",
        caption: "Table 3",
        capacity: 4,
        blob: '{ "chairs": { "count": 4, "min": 4, "max": 12 }, "width": "1", "height": "1", "x": "400", "y": "400" }',
      },
      {
        type: "table",
        id: "table1-2-4",
        caption: "Table 4",
        capacity: 4,
        blob: '{ "chairs": { "count": 4, "min": 4, "max": 12 }, "width": "1", "height": "1", "x": "600", "y": "400" }',
      },
    ],
  },
  {
    restaurantId: "R1",
    id: "R1-U",
    caption: "Udenfor",
    components: [
      {
        type: "table",
        id: "table1-3",
        caption: "Seating 1",
        blob: '{ "chairs": { "count": 8, "min": 4, "max": 12 }, "width": "5", "height": "2", "x": "870", "y": "170" }',
      },
      {
        type: "table",
        id: "table2-4",
        caption: "Seating 2",
        capacity: 4,
        blob: '{ "chairs": { "count": 4, "min": 2, "max": 4 }, "width": "2", "height": "2", "x": "345", "y": "155" }',
      },
      {
        type: "table",
        id: "table3-4",
        caption: "Table 3",
        capacity: 0,
        blob: '{ "chairs": { "count": 0, "min": 2, "max": 5 }, "round": true, "width": "2", "height": "2", "x": "1220", "y": "190" }',
      },
    ],
  },
];

const __npre_waiterPadData = {
  waiterPads: [
    {
      restaurantId: "R1",
      id: "wp1",
      caption: "Waiter Pad 1",
    },
    {
      restaurantId: "R1",
      id: "wp2",
      caption: "Waiter Pad 2",
    },
    {
      restaurantId: "R1",
      id: "wp3",
      caption: "Waiter Pad 3",
    },
    {
      restaurantId: "R1",
      id: "wp4",
      caption: "Waiter Pad 4",
    },
    {
      restaurantId: "R1",
      id: "wp5",
      caption: "Waiter Pad 5",
    },
  ],
  waiterPadSeatingLinks: [
    {
      restaurantId: "R1",
      locationId: "",
      seatingId: "R1-K-1",
      waiterPadId: "wp1",
    },
    {
      restaurantId: "R1",
      locationId: "",
      seatingId: "R1-K-2",
      waiterPadId: "wp1",
    },
    {
      restaurantId: "R1",
      locationId: "",
      seatingId: "R1-K-2",
      waiterPadId: "wp2",
    },
    {
      restaurantId: "R1",
      locationId: "",
      seatingId: "R1-K-2",
      waiterPadId: "wp3",
    },
  ],
  activeWaiterPad: "wp1",
};

const __npre_statuses = {
  seating: [
    {
      id: "C1",
      caption: "Clean Please",
      color: "95B9C7",
      icon: "ion-ios-bell",
      ordinal: 4,
    },
    {
      id: "O1",
      caption: "Occupied",
      color: "7F5217",
      icon: "ion-ios-keypad",
      ordinal: 6,
    },
    {
      id: "R1",
      caption: "Reserved",
      color: "FFFFFF",
      icon: "ion-locked",
      ordinal: 2,
    },
    {
      id: "S1",
      caption: "Ready",
      color: "463E3F",
      icon: "ion-social-buffer",
      ordinal: 0,
    },
  ],
  waiterPad: [
    {
      id: "C2",
      caption: "New",
      color: "9F000F",
      icon: "im-hammer",
    },
    {
      id: "W1",
      caption: "Ready to pay",
      color: "4E9258",
      icon: "jw-bangle",
    },
  ],
};

const __npre_updateStatuses = {
  seating: {
    "R1-K-1": "S1",
    "R1-K-2": "C1",
    "R1-K-3": "O1",
    "table1-2-1": "R1",
  },
  waiterPad: {
    wp1: "C2",
    wp2: "W1",
  },
};
