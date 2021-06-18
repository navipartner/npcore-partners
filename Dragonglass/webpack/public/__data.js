let addIndex = 0;

let lastRandom = 0;
function getNextRandom() {
    let newRandom = lastRandom;
    while (newRandom === lastRandom) {
        newRandom = Math.ceil(Math.random() * 15 + 2);;
    }
    return lastRandom = newRandom;
}

const __data = {
    init: {
        "BUILTIN_SALE": {
            "rows": [
                {
                    "position": "Cash Register No.=CONST(2),Sales Ticket No.=CONST()",
                    "negative": false,
                    "class": null,
                    "style": null,
                    "deleted": false,
                    "fields": {
                        "1": "2",
                        "2": "",
                        "4": "",
                        "5": "0001-01-01T00:00:00",
                        "7": "",
                        "8": "",
                        "15": "",
                        "LastSaleNo": "1006317",
                        "LastSaleTotal": 35,
                        "LastSalePaid": 35,
                        "LastSaleChange": 0,
                        "LastSaleDate": "24-06-19 | 16:31:38",
                        "CompanyName": "337539 Global",
                        "SalespersonName": "Unknown",
                        "RegisterName": "",
                        "CustomerName": "",
                        "ContactName": "",
                        "FC.EURO": "0",
                        "FC.GBP": "0",
                        "FC.NOR": "0",
                        "FC.SEK": "0",
                        "FC.USD": "0",
                        "CollectInStore.UnprocessedOrdersExists": true,
                        "CollectInStore.UnprocessedOrdersQty": 3
                    }
                }
            ],
            "isDelta": true,
            "currentPosition": "Cash Register No.=CONST(2),Sales Ticket No.=CONST()",
            "dataSource": "BUILTIN_SALE",
            "totals": {}
        }
    },
    sale: {
        "BUILTIN_SALELINE": {
            "rows": [
                // {
                //     "position": "Cash Register No.=CONST(2),Sales Ticket No.=CONST(1006319),Date=CONST(24-06-19),Sale Type=CONST(Sale),Line No.=CONST(20000)",
                //     "negative": false,
                //     "class": null,
                //     "style": null,
                //     "deleted": false,
                //     "fields": {
                //         "5": 1,
                //         "6": "40005",
                //         "10": "Specialty Beer",
                //         "11": "PCS",
                //         "12": 1,
                //         "15": 35,
                //         "19": 0,
                //         "20": 0,
                //         "31": 35,
                //         "6039": "",
                //         "LineFormat.Color": "",
                //         "LineFormat.Weight": "",
                //         "LineFormat.Style": ""
                //     }
                // },
                // {
                //     "position": "Cash Register No.=CONST(2),Sales Ticket No.=CONST(1006319),Date=CONST(24-06-19),Sale Type=CONST(Sale),Line No.=CONST(30000)",
                //     "negative": false,
                //     "class": null,
                //     "style": null,
                //     "deleted": false,
                //     "fields": {
                //         "5": 1,
                //         "6": "40004",
                //         "10": "Large Draft Beer",
                //         "11": "PCS",
                //         "12": 1,
                //         "15": 35,
                //         "19": 0,
                //         "20": 0,
                //         "31": 35,
                //         "6039": "",
                //         "LineFormat.Color": "",
                //         "LineFormat.Weight": "",
                //         "LineFormat.Style": ""
                //     }
                // },
                // {
                //     "position": "Cash Register No.=CONST(2),Sales Ticket No.=CONST(1006319),Date=CONST(24-06-19),Sale Type=CONST(Sale),Line No.=CONST(40000)",
                //     "negative": false,
                //     "class": null,
                //     "style": null,
                //     "deleted": false,
                //     "fields": {
                //         "5": 1,
                //         "6": "40003",
                //         "10": "Small Draft Beer",
                //         "11": "PCS",
                //         "12": 1,
                //         "15": 43.75,
                //         "19": 0,
                //         "20": 0,
                //         "31": 43.75,
                //         "6039": "",
                //         "LineFormat.Color": "",
                //         "LineFormat.Weight": "",
                //         "LineFormat.Style": ""
                //     }
                // }
            ],
            "isDelta": true,
            "currentPosition": "Cash Register No.=CONST(2),Sales Ticket No.=CONST(1006319),Date=CONST(24-06-19),Sale Type=CONST(Sale),Line No.=CONST(20000)",
            "dataSource": "BUILTIN_SALELINE",
            "totals": {
                "AmountExclVAT": 91,
                "VATAmount": 22.75,
                "TotalAmount": 113.75
            }
        },
        "BUILTIN_SALE": {
            "rows": [
                {
                    "position": "Cash Register No.=CONST(2),Sales Ticket No.=CONST(1006319)",
                    "negative": false,
                    "class": null,
                    "style": null,
                    "deleted": false,
                    "fields": {
                        "1": "2",
                        "2": "1006319",
                        "4": "1",
                        "5": "2019-06-24T00:00:00+02:00",
                        "7": "",
                        "8": "",
                        "15": "",
                        "LastSaleNo": "1006317",
                        "LastSaleTotal": 35,
                        "LastSalePaid": 35,
                        "LastSaleChange": 0,
                        "LastSaleDate": "24-06-19 | 16:31:38",
                        "CompanyName": "337539 Global",
                        "SalespersonName": "Salym",
                        "RegisterName": "Register 2 (NPR Testing)",
                        "CustomerName": "",
                        "ContactName": "",
                        "FC.EURO": "16",
                        "FC.GBP": "14",
                        "FC.NOR": "141",
                        "FC.SEK": "143",
                        "FC.USD": "17",
                        "DIMENSION.DEPARTMENT": "MRU",
                        "DIMENSION.1": "MRU",
                        "DIMENSION.PROJECT": "P2",
                        "DIMENSION.2": "P2",
                        "CollectInStore.UnprocessedOrdersExists": true,
                        "CollectInStore.UnprocessedOrdersQty": 3
                    }
                }
            ],
            "isDelta": true,
            "currentPosition": "Cash Register No.=CONST(2),Sales Ticket No.=CONST(1006319)",
            "dataSource": "BUILTIN_SALE",
            "totals": {}
        }
    },
    addLine: () => ({
        "BUILTIN_SALELINE": {
            "rows": [
                {
                    "position": "line_" + (++addIndex),
                    "negative": false,
                    "class": null,
                    "style": null,
                    "deleted": false,
                    "fields": {
                        "5": 1,
                        "6": "40013",
                        "10": "Red Wine Glass",
                        "11": "PCS",
                        "12": 1,
                        "15": 45,
                        "19": 0,
                        "20": 0,
                        "31": 45,
                        "6039": "",
                        "LineFormat.Color": "",
                        "LineFormat.Weight": "",
                        "LineFormat.Style": ""
                    }
                }
            ],
            "isDelta": true,
            "currentPosition": "line_" + addIndex,
            "dataSource": "BUILTIN_SALELINE",
            "totals": {
                "AmountExclVAT": 127,
                "VATAmount": 31.75,
                "TotalAmount": 158.75
            }
        },
        "BUILTIN_SALE": {
            "rows": [
                {
                    "position": "Cash Register No.=CONST(2),Sales Ticket No.=CONST(1006319)",
                    "negative": false,
                    "class": null,
                    "style": null,
                    "deleted": false,
                    "fields": {
                        "1": "2",
                        "2": "1006319",
                        "4": "1",
                        "5": "2019-06-24T00:00:00+02:00",
                        "7": "",
                        "8": "",
                        "15": "",
                        "LastSaleNo": "1006317",
                        "LastSaleTotal": 35,
                        "LastSalePaid": 35,
                        "LastSaleChange": 0,
                        "LastSaleDate": "24-06-19 | 16:31:38",
                        "CompanyName": "337539 Global",
                        "SalespersonName": "Salym",
                        "RegisterName": "Register 2 (NPR Testing)",
                        "CustomerName": "",
                        "ContactName": "",
                        "FC.EURO": "22",
                        "FC.GBP": "19",
                        "FC.NOR": "196",
                        "FC.SEK": "199",
                        "FC.USD": "24",
                        "DIMENSION.DEPARTMENT": "MRU",
                        "DIMENSION.1": "MRU",
                        "DIMENSION.PROJECT": "P2",
                        "DIMENSION.2": "P2",
                        "CollectInStore.UnprocessedOrdersExists": true,
                        "CollectInStore.UnprocessedOrdersQty": 3
                    }
                }
            ],
            "isDelta": true,
            "currentPosition": "Cash Register No.=CONST(2),Sales Ticket No.=CONST(1006319)",
            "dataSource": "BUILTIN_SALE",
            "totals": {}
        }
    }),
    changeLine: () => ({
        "BUILTIN_SALELINE": {
            "rows": [
                {
                    "position": "line_" + addIndex,
                    "negative": false,
                    "class": null,
                    "style": null,
                    "deleted": false,
                    "fields": {
                        "5": 1,
                        "6": "40013",
                        "10": "Red Wine Glass",
                        "11": "PCS",
                        "12": getNextRandom(),
                        "15": 45,
                        "19": 0,
                        "20": 0,
                        "31": lastRandom * 45,
                        "6039": "",
                        "LineFormat.Color": "",
                        "LineFormat.Weight": "",
                        "LineFormat.Style": ""
                    }
                }
            ],
            "isDelta": true,
            "currentPosition": "line_" + addIndex,
            "dataSource": "BUILTIN_SALELINE",
            "totals": {
                "AmountExclVAT": 271,
                "VATAmount": 67.75,
                "TotalAmount": 338.75
            }
        }
    }),
    deleteLine: () => ({
        "BUILTIN_SALELINE": {
            "rows": [
                {
                    "position": "line_" + addIndex,
                    "negative": false,
                    "class": null,
                    "style": null,
                    "deleted": true,
                    "fields": {}
                }
            ],
            "isDelta": true,
            "currentPosition": "Cash Register No.=CONST(2),Sales Ticket No.=CONST(1006319),Date=CONST(24-06-19),Sale Type=CONST(Sale),Line No.=CONST(10000)",
            "dataSource": "BUILTIN_SALELINE",
            "totals": {
                "AmountExclVAT": 91,
                "VATAmount": 22.75,
                "TotalAmount": 113.75
            }
        },
        "BUILTIN_SALE": {
            "rows": [
                {
                    "position": "Cash Register No.=CONST(2),Sales Ticket No.=CONST(1006319)",
                    "negative": false,
                    "class": null,
                    "style": null,
                    "deleted": false,
                    "fields": {
                        "1": "2",
                        "2": "1006319",
                        "4": "1",
                        "5": "2019-06-24T00:00:00+02:00",
                        "7": "",
                        "8": "",
                        "15": "",
                        "LastSaleNo": "1006317",
                        "LastSaleTotal": 35,
                        "LastSalePaid": 35,
                        "LastSaleChange": 0,
                        "LastSaleDate": "24-06-19 | 16:31:38",
                        "CompanyName": "337539 Global",
                        "SalespersonName": "Salym",
                        "RegisterName": "Register 2 (NPR Testing)",
                        "CustomerName": "",
                        "ContactName": "",
                        "FC.EURO": "16",
                        "FC.GBP": "14",
                        "FC.NOR": "141",
                        "FC.SEK": "143",
                        "FC.USD": "17",
                        "DIMENSION.DEPARTMENT": "MRU",
                        "DIMENSION.1": "MRU",
                        "DIMENSION.PROJECT": "P2",
                        "DIMENSION.2": "P2",
                        "CollectInStore.UnprocessedOrdersExists": true,
                        "CollectInStore.UnprocessedOrdersQty": 3
                    }
                }
            ],
            "isDelta": true,
            "currentPosition": "Cash Register No.=CONST(2),Sales Ticket No.=CONST(1006319)",
            "dataSource": "BUILTIN_SALE",
            "totals": {}
        }
    })
};

const __dataSources = {
    "BUILTIN_SALELINE": {
        "id": "BUILTIN_SALELINE",
        "tableNo": 6014406,
        "columns": [
            {
                "fieldId": "6",
                "dataType": 5,
                "format": null,
                "ordinal": 1,
                "caption": "No.",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 13,
                "isCheckbox": false
            },
            {
                "fieldId": "5",
                "dataType": 5,
                "format": null,
                "ordinal": 2,
                "caption": "Type",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 10,
                "isCheckbox": false
            },
            {
                "fieldId": "10",
                "dataType": 5,
                "format": null,
                "ordinal": 3,
                "caption": "Description",
                "visible": true,
                "formula": null,
                "isSubtotal": false,
                "width": 20,
                "isCheckbox": false
            },
            {
                "fieldId": "6039",
                "dataType": 5,
                "format": null,
                "ordinal": 4,
                "caption": "Description 2",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 20,
                "isCheckbox": false
            },
            {
                "fieldId": "12",
                "dataType": 4,
                "format": null,
                "ordinal": 5,
                "caption": "Quantity",
                "visible": true,
                "formula": null,
                "isSubtotal": false,
                "width": 5,
                "isCheckbox": false
            },
            {
                "fieldId": "11",
                "dataType": 5,
                "format": null,
                "ordinal": 6,
                "caption": "Unit of Measure Code",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 10,
                "isCheckbox": false
            },
            {
                "fieldId": "15",
                "dataType": 4,
                "format": null,
                "ordinal": 7,
                "caption": "Unit Price",
                "visible": true,
                "formula": null,
                "isSubtotal": false,
                "width": 5,
                "isCheckbox": false
            },
            {
                "fieldId": "19",
                "dataType": 4,
                "format": null,
                "ordinal": 8,
                "caption": "Discount %",
                "visible": true,
                "formula": null,
                "isSubtotal": false,
                "width": 5,
                "isCheckbox": false
            },
            {
                "fieldId": "20",
                "dataType": 4,
                "format": null,
                "ordinal": 9,
                "caption": "Discount",
                "visible": true,
                "formula": null,
                "isSubtotal": false,
                "width": 5,
                "isCheckbox": false
            },
            {
                "fieldId": "31",
                "dataType": 4,
                "format": null,
                "ordinal": 10,
                "caption": "Amount Including VAT",
                "visible": true,
                "formula": null,
                "isSubtotal": false,
                "width": 5,
                "isCheckbox": false
            },
            {
                "fieldId": "LineFormat.Color",
                "dataType": 5,
                "format": null,
                "ordinal": 11,
                "caption": "Text color",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 0,
                "isCheckbox": false
            },
            {
                "fieldId": "LineFormat.Weight",
                "dataType": 5,
                "format": null,
                "ordinal": 12,
                "caption": "Font weight",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 0,
                "isCheckbox": false
            },
            {
                "fieldId": "LineFormat.Style",
                "dataType": 5,
                "format": null,
                "ordinal": 13,
                "caption": "Font style",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 0,
                "isCheckbox": false
            }
        ],
        "totals": [
            "AmountExclVAT",
            "VATAmount",
            "TotalAmount"
        ]
    },
    "BUILTIN_SALE": {
        "id": "BUILTIN_SALE",
        "tableNo": 6014405,
        "columns": [
            {
                "fieldId": "1",
                "dataType": 5,
                "format": null,
                "ordinal": 1,
                "caption": "Cash Register No.",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 10,
                "isCheckbox": false
            },
            {
                "fieldId": "2",
                "dataType": 5,
                "format": null,
                "ordinal": 2,
                "caption": "Sales Ticket No.",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 13,
                "isCheckbox": false
            },
            {
                "fieldId": "4",
                "dataType": 5,
                "format": null,
                "ordinal": 3,
                "caption": "Salesperson Code",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 10,
                "isCheckbox": false
            },
            {
                "fieldId": "7",
                "dataType": 5,
                "format": null,
                "ordinal": 4,
                "caption": "Customer No.",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 13,
                "isCheckbox": false
            },
            {
                "fieldId": "8",
                "dataType": 5,
                "format": null,
                "ordinal": 5,
                "caption": "Name",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 20,
                "isCheckbox": false
            },
            {
                "fieldId": "5",
                "dataType": 3,
                "format": null,
                "ordinal": 6,
                "caption": "Date",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 4,
                "isCheckbox": false
            },
            {
                "fieldId": "15",
                "dataType": 5,
                "format": null,
                "ordinal": 7,
                "caption": "Contact",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 16,
                "isCheckbox": false
            },
            {
                "fieldId": "RegisterName",
                "dataType": 5,
                "format": null,
                "ordinal": 8,
                "caption": "Register Name",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 0,
                "isCheckbox": false
            },
            {
                "fieldId": "CustomerName",
                "dataType": 5,
                "format": null,
                "ordinal": 9,
                "caption": "Customer Name",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 0,
                "isCheckbox": false
            },
            {
                "fieldId": "ContactName",
                "dataType": 5,
                "format": null,
                "ordinal": 10,
                "caption": "Contact Name",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 0,
                "isCheckbox": false
            },
            {
                "fieldId": "LastSaleNo",
                "dataType": 5,
                "format": null,
                "ordinal": 11,
                "caption": "",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 0,
                "isCheckbox": false
            },
            {
                "fieldId": "LastSaleTotal",
                "dataType": 4,
                "format": null,
                "ordinal": 12,
                "caption": "",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 0,
                "isCheckbox": false
            },
            {
                "fieldId": "LastSalePaid",
                "dataType": 4,
                "format": null,
                "ordinal": 13,
                "caption": "",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 0,
                "isCheckbox": false
            },
            {
                "fieldId": "LastSaleChange",
                "dataType": 4,
                "format": null,
                "ordinal": 14,
                "caption": "",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 0,
                "isCheckbox": false
            },
            {
                "fieldId": "LastSaleDate",
                "dataType": 5,
                "format": null,
                "ordinal": 15,
                "caption": "",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 0,
                "isCheckbox": false
            },
            {
                "fieldId": "CompanyName",
                "dataType": 5,
                "format": null,
                "ordinal": 16,
                "caption": "Company Name",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 0,
                "isCheckbox": false
            },
            {
                "fieldId": "SalespersonName",
                "dataType": 5,
                "format": null,
                "ordinal": 17,
                "caption": "",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 0,
                "isCheckbox": false
            },
            {
                "fieldId": "LOYALTY.RemainingPoints",
                "dataType": 5,
                "format": null,
                "ordinal": 18,
                "caption": "Remaining Points",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 0,
                "isCheckbox": false
            },
            {
                "fieldId": "LOYALTY.RemainingValue",
                "dataType": 5,
                "format": null,
                "ordinal": 19,
                "caption": "Remaining Points",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 0,
                "isCheckbox": false
            },
            {
                "fieldId": "FC.EURO",
                "dataType": 5,
                "format": null,
                "ordinal": 20,
                "caption": "EURO",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 0,
                "isCheckbox": false
            },
            {
                "fieldId": "FC.GBP",
                "dataType": 5,
                "format": null,
                "ordinal": 21,
                "caption": "GBP",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 0,
                "isCheckbox": false
            },
            {
                "fieldId": "FC.NOR",
                "dataType": 5,
                "format": null,
                "ordinal": 22,
                "caption": "Norwegian Kroner",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 0,
                "isCheckbox": false
            },
            {
                "fieldId": "FC.SEK",
                "dataType": 5,
                "format": null,
                "ordinal": 23,
                "caption": "Swedish Kroner",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 0,
                "isCheckbox": false
            },
            {
                "fieldId": "FC.USD",
                "dataType": 5,
                "format": null,
                "ordinal": 24,
                "caption": "US $",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 0,
                "isCheckbox": false
            },
            {
                "fieldId": "DIMENSION.DEPARTMENT",
                "dataType": 5,
                "format": null,
                "ordinal": 25,
                "caption": "",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 0,
                "isCheckbox": false
            },
            {
                "fieldId": "DIMENSION.1",
                "dataType": 5,
                "format": null,
                "ordinal": 26,
                "caption": "",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 0,
                "isCheckbox": false
            },
            {
                "fieldId": "DIMENSION.POS",
                "dataType": 5,
                "format": null,
                "ordinal": 27,
                "caption": "",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 0,
                "isCheckbox": false
            },
            {
                "fieldId": "DIMENSION.2",
                "dataType": 5,
                "format": null,
                "ordinal": 28,
                "caption": "",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 0,
                "isCheckbox": false
            },
            {
                "fieldId": "DIMENSION.POSTNR",
                "dataType": 5,
                "format": null,
                "ordinal": 29,
                "caption": "",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 0,
                "isCheckbox": false
            },
            {
                "fieldId": "DIMENSION.3",
                "dataType": 5,
                "format": null,
                "ordinal": 30,
                "caption": "",
                "visible": false,
                "formula": null,
                "isSubtotal": false,
                "width": 0,
                "isCheckbox": false
            }
        ],
        "totals": []
    }
}