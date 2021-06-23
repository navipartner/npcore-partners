export const DEFAULT_VIEW_RESTAURANT = {
    tag: "restaurant",
    flow: "vertical",
    content: [
        {
            type: "npre-locations",
            showRestaurant: true,
            allowRestaurantSelection: true
        },
        {
            type: "npre-restaurant-view",
            showTableWaiterPads: false,
            editable: true
        },
        {
            type: "npre-waiterpads",
            filter: {
                statuses: ["C2"]
            }
        },
        {
            class: "dragonglass__slide-in-right",
            width: "40vw",
            bindToState: "restaurant.activeTable",
            flow: "vertical",
            content: [
                {
                    type: "npre-table-info",
                    class: "dragonglass__no-padding-title"
                },
                {
                    flow: "vertical",
                    content: [
                        {
                            type: "npre-table-waiterpads",
                            flow: "horizontal"
                        },
                        {
                            type: "npre-statuses-waiterpad"
                        },
                        {
                            type: "menu",
                            source: "NPRE-WPAD",
                            columns: 4,
                            rows: 2,
                            plugins: ["npre-parameters", "npre-waiterpad-enabler"]
                        }
                    ]
                },
                {
                    flow: "vertical",
                    content: [
                        {
                            type: "npre-number-of-guests"
                        },
                        {
                            type: "npre-statuses-table"
                        },
                        {
                            type: "menu",
                            source: "NPRE-TBL",
                            columns: 4,
                            rows: 2,
                            plugins: ["npre-parameters"]
                        }
                    ]
                }
            ]
        }
    ]
};
