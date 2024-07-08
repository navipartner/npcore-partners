var viewSale = {
    tag: "sale",
    flow: "horizontal",
    content: [
        {
            alignment: "left",
            base: "60%",
            grow: 0,
            shrink: 1,
            width: "60%",
            flow: "vertical",
            content: [
                {
                    type: "grid",
                    id: "salesLines",
                    fontSize: "normal",
                    dataSource: "BUILTIN_SALELINE",
                    base: "45%",

                    totals: [
                        {
                            caption: "l$.Sale_SubTotal",
                            total: "TotalAmount"
                        }
                    ],

                    control: "dataGrid"
                },
                {
                    type: "menu",
                    source: "SALE-LEFT",
                    columns: 5,
                    rows: 5,
                    base: "55%",
                    "margin-top": 0,
                    dataSource: "BUILTIN_SALELINE"
                }
            ]
        },
        {
            flow: "vertical",
            base: "40%",
            grow: 0,
            shrink: 0,
            width: "calc(40% - 1.5em)",
            content: [
                {
                    type: "text",
                    caption: "l$.Sale_EANHeader",
                    id: "EanBoxText",
                    showErase: false,
                    base: "4em",
                    grow: "0",
                    control: "eanBox",
                    bigCaption: true,
                    inputFilter: true
                },
                {
                    type: "menu",
                    source: "SALE-TOP",
                    columns: 3,
                    rows: 2,
                    id: "buttongrid-functions-top",
                    dataSource: "BUILTIN_SALELINE",
                    base: "25%"
                },
                {
                    type: "captionbox",
                    fontSize: "medium",
                    base: "25%",
                    binding: {
                        dataSource: "BUILTIN_SALELINE",
                        captionSet: {
                            title: { field: "10" },
                            rows: [
                                { field: "6" },
                                { field: "15" }
                            ]
                        },

                        fallback: {
                            dataSource: "BUILTIN_SALE",
                            captionSet: {
                                title: { caption: "l$.Sale_LastSale" },
                                rows: [
                                    { caption: "l$.LastSale_Total", field: "LastSaleTotal" },
                                    { caption: "l$.LastSale_Paid", field: "LastSalePaid" },
                                    { caption: "l$.LastSale_Change", field: "LastSaleChange" }
                                ]
                            }
                        }
                    }
                },
                {
                    type: "menu",
                    base: "44%",
                    source: "SALE-BOTTOM",
                    columns: 3,
                    rows: [1, 1, 2],
                    id: "buttongrid-functions-bottom",
                    dataSource: "BUILTIN_SALELINE"
                }
            ]
        }
    ],
    statusBar: {
        dataSource: "BUILTIN_SALE",

        sections: [
            { field: "CompanyName", width: "20%" },
            { field: "4", width: "15%" },
            {
                type: "group",
                width: "5%",
                sections: [
                    { caption: "l$.Sale_RegisterNo", "class": "strong" },
                    { field: "1" }
                ]
            },
            { field: "7", width: "10%" },
            {
                type: "group",
                "class": "group right",
                sections: [
                    { caption: "l$.Sale_ReceiptNo", "class": "strong" },
                    { field: "2" }
                ]
            },
            {
                type: "group",
                "class": "group right",
                sections: [
                    { caption: "l$.Sale_LastSale", "class": "strong" },
                    { field: "LastSaleNo" }
                ]
            },
            {
                width: "5%",
                option: "nprVersion"
            },
            { id: "walkthrough" }
        ]
    }
};
