var viewPayment = {
    tag: "payment",
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
                    id: "paymentLines",
                    fontSize: "normal",
                    dataSource: "BUILTIN_PAYMENTLINE",
                    base: "45%",

                    totals: [
                        {
                            caption: "l$.Sale_SubTotal",
                            total: "Subtotal"
                        }
                    ],

                    control: "dataGrid"
                },
                {
                    type: "menu",
                    source: "PAYMENT-LEFT",
                    columns: 5,
                    rows: 5,
                    base: "55%",
                    "margin-top": 0,
                    dataSource: "BUILTIN_PAYMENTLINE"
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
                    caption: "l$.Sale_PaymentAmount",
                    id: "TotalText",
                    showErase: false,
                    base: "4em",
                    grow: "0",
                    control: "totalBox",
                    bigCaption: true,
                    inputFilter: true
                },
                {
                    type: "menu",
                    source: "PAYMENT-TOP",
                    columns: 3,
                    rows: 2,
                    id: "buttongrid-functions-top",
                    dataSource: "BUILTIN_PAYMENTLINE",
                    base: "25%"
                },
                {
                    type: "captionbox",
                    fontSize: "medium",
                    base: "25%",
                    binding: {
                        dataSource: "BUILTIN_PAYMENTLINE",
                        captionSet: {
                            title: { caption: "l$.Payment_PaymentInfo" },
                            rows: [
                                { caption: "l$.Payment_SaleLCY", total: "SaleAmount" },
                                { caption: "l$.Payment_Paid", total: "PaidAmount" },
                                { caption: "l$.Payment_Balance", total: "ReturnAmount" }
                            ]
                        }
                    }
                },
                {
                    type: "menu",
                    base: "44%",
                    source: "PAYMENT-BOTTOM",
                    columns: 3,
                    rows: [1, 1, 2],
                    id: "buttongrid-functions-bottom",
                    dataSource: "BUILTIN_PAYMENTLINE"
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
