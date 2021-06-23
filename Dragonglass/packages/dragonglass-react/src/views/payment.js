import { isMobile } from "../classes/functions";

// TODO: Custom views should have a possibility that custom view definitions can provide only modifications of the default view rather than having to provide entire custom view definitions.
// For example, if a view wants only to change one single field in the statusbar, it doesn't have to provide the entire view definition, but only the "delta".

const DEFAULT_VIEW = {
    MOBILE: {
        tag: "payment",
        flow: "vertical",
        content:
            [
                {
                    flow: "vertical",
                    content: [
                        {
                            type: "grid",
                            id: "paymentLines",
                            fontSize: "normal",
                            dataSource: "BUILTIN_PAYMENTLINE",

                            totals: [
                                {
                                    caption: "l$.Sale_SubTotal",
                                    total: "Subtotal"
                                }
                            ],

                            control: "dataGrid"
                        },
                        {
                            "class": "togglable",
                            flow: "vertical",
                            content: [
                                {
                                    type: "text",
                                    caption: "l$.Sale_PaymentAmount",
                                    id: "TotalText",
                                    showErase: false,
                                    control: "totalBox",
                                    bigCaption: true
                                },
                                {
                                    "class": "top",
                                    type: "menu",
                                    source: "MPAYMENT-TOP",
                                    columns: 4,
                                    rows: 1,
                                    base: "5em",
                                    id: "buttongrid-functions-top",
                                    dataSource: "BUILTIN_PAYMENTLINE",
                                    skipUndefined: true
                                }
                            ]
                        },
                        {
                            "class": "more-menu",
                            type: "menu",
                            source: "MPAYMENT-BOTTOM",
                            columns: 3,
                            rows: 2,
                            id: "buttongrid-functions-more-menu",
                            dataSource: "BUILTIN_PAYMENTLINE"
                        },
                        {
                            "class": "items-menu",
                            type: "menu",
                            source: "MPAYMENT-LEFT",
                            columns: 4,
                            rows: 4,
                            id: "buttongrid-functions-items-menu",
                            dataSource: "BUILTIN_PAYMENTLINE"
                        },
                        {
                            base: "4em",
                            height: "4em",
                            "class": "bottom-menu",
                            content: [
                                {
                                    type: "button",
                                    caption: "l$.CaptionTablet_ButtonPaymentMethods",
                                    // onclick: toggleItems
                                },
                                {
                                    type: "button",
                                    caption: "l$.CaptionTablet_ButtonMore",
                                    // onclick: toggleMore
                                }
                            ]
                        }
                    ]
                }
            ]
    },

    DESKTOP: {
        "viewDesktop": {
            "default":
            {
                "button":
                {
                    "class": "multiline"
                }
            },
            tag: "payment",
            flow: "horizontal",
            content: [
                {
                    alignment: "left",
                    flow: "vertical",
                    content: [
                        {
                            type: "grid",
                            id: "paymentLines",
                            fontSize: "normal",
                            dataSource: "BUILTIN_PAYMENTLINE",
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
                    base: "35%",
                    content: [
                        {
                            type: "text",
                            caption: "l$.Sale_PaymentAmount",
                            id: "TotalText",
                            showErase: false,
                            base: "4em",
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
                            base: "25%",
                            dataSource: "BUILTIN_PAYMENTLINE"
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
                                        { caption: "l$.LastSale_Total", total: "SaleAmount" },
                                        { caption: "l$.LastSale_Paid", total: "PaidAmount" },
                                        { caption: "l$.LastSale_Change", total: "ReturnAmount" }
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
                fontSize: "Medium",
                sections: [
                    {
                        "field": "CompanyName",
                        "width": "20%",
                        "class": "strong"
                    },
                    {
                        "type": "group",
                        "width": "5%",
                        "sections": [
                            {
                                "field": "4",
                                "width": "5%"
                            },
                            {
                                "field": "SalespersonName",
                                "class": "strong"
                            }
                        ]
                    },
                    {
                        "type": "group",
                        "width": "5%",
                        "sections": [
                            {
                                "caption": "l$.Sale_RegisterNo",
                                "class": "strong"
                            },
                            {
                                "field": "1"
                            }
                        ]
                    },
                    {
                        "type": "group",
                        "width": "10%",
                        "sections": [
                            {
                                "field": "7"
                            },
                            {
                                "field": "8"
                            }
                        ]
                    },
                    {
                        "type": "group",
                        "class": "group right",
                        "sections": [
                            {
                                "caption": "l$.Sale_ReceiptNo",
                                "class": "strong"
                            },
                            {
                                "field": "2"
                            }
                        ]
                    },
                    {
                        "type": "group",
                        "class": "group right",
                        "sections": [
                            {
                                "caption": "l$.Sale_LastSale",
                                "class": "strong"
                            },
                            {
                                "field": "LastSaleNo",
                                "class": "strong"
                            }
                        ]
                    },
                    {
                        "width": "5%",
                        "option": "nprVersion"
                    }
                ]
            }
        },
        "viewMobile": {
            "default":
            {
                "button":
                {
                    "class": "multiline"
                }
            },
            tag: "payment",
            flow: "vertical",
            content:
                [
                    {
                        flow: "vertical",
                        content: [
                            {
                                type: "grid",
                                id: "paymentLines",
                                fontSize: "normal",
                                dataSource: "BUILTIN_PAYMENTLINE",

                                totals: [
                                    {
                                        caption: "l$.Sale_SubTotal",
                                        total: "Subtotal"
                                    }
                                ],

                                control: "dataGrid"
                            },
                            {
                                "class": "togglable",
                                flow: "vertical",
                                content: [
                                    {
                                        type: "text",
                                        caption: "l$.Sale_PaymentAmount",
                                        id: "TotalText",
                                        showErase: false,
                                        control: "totalBox",
                                        bigCaption: true
                                    },
                                    {
                                        "class": "top",
                                        type: "menu",
                                        source: "MPAYMENT-TOP",
                                        columns: 4,
                                        rows: 1,
                                        base: "5em",
                                        id: "buttongrid-functions-top",
                                        dataSource: "BUILTIN_PAYMENTLINE",
                                        skipUndefined: true
                                    }
                                ]
                            },
                            {
                                "class": "more-menu",
                                type: "menu",
                                source: "MPAYMENT-BOTTOM",
                                columns: 3,
                                rows: 2,
                                id: "buttongrid-functions-more-menu",
                                dataSource: "BUILTIN_PAYMENTLINE"
                            },
                            {
                                "class": "items-menu",
                                type: "menu",
                                source: "MPAYMENT-LEFT",
                                columns: 4,
                                rows: 4,
                                id: "buttongrid-functions-items-menu",
                                dataSource: "BUILTIN_PAYMENTLINE"
                            },
                            {
                                base: "4em",
                                height: "4em",
                                "class": "bottom-menu",
                                content: [
                                    {
                                        type: "button",
                                        caption: "l$.CaptionTablet_ButtonPaymentMethods",
                                        onclick: "toggleItems"
                                    },
                                    {
                                        type: "button",
                                        caption: "l$.CaptionTablet_ButtonMore",
                                        onclick: "toggleMore"
                                    }
                                ]
                            }
                        ]
                    }
                ]
        }
    }
};

export const DEFAULT_VIEW_PAYMENT =
    isMobile()
        ? DEFAULT_VIEW.MOBILE
        : DEFAULT_VIEW.DESKTOP;
