var viewLogin = {
    tag: "login",
    flow: "vertical",
    margin: "10% 15%",
    content: [
        {
            "class": "top",
            base: "75%",
            flow: "horizontal",
            content: [
                {
                    "class": "left",
                    flow: "vertical",
                    base: "60%",
                    content: [
                        {
                            width: "100%",
                            type: "logo"
                        },
                        {
                            type: "captionbox",
                            "class": "lastsale",
                            fontSize: "medium",
                            selfAlign: "center",
                            binding: {
                                dataSource: "BUILTIN_SALE",
                                captionSet: {
                                    title: { caption: "l$.Sale_LastSale", field: "LastSaleDate" },
                                    rows: [
                                        { caption: "l$.Sale_PaymentAmount", field: "LastSalePaid" },
                                        { caption: "l$.Sale_PaymentTotal", field: "LastSaleTotal" },
                                        { caption: "l$.Sale_ReturnAmount", field: "LastSaleChange" },
                                        {
                                            "class": "lastline",
                                            left: {
                                                caption: "l$.Sale_ReceiptNo",
                                                field: "LastSaleNo"
                                            },
                                            right: {
                                                caption: "l$.Sale_RegisterNo",
                                                field: "1"
                                            }
                                        }
                                    ]
                                }
                            }
                        }
                    ]
                },
                {
                    "class": "right",
                    width: "40%",
                    content: { type: "loginpad", control: "loginpad" }
                }
            ]
        },
        {
            "class": "bottom",
            content: { type: "menu", source: "LOGIN", columns: 2, rows: 1, width: "350px", height: "80px" }
        }
    ]
};
