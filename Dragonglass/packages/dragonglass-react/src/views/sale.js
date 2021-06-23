import { isMobile } from "../classes/functions";

const DEFAULT_VIEW = {
  MOBILE: {
    tag: "sale",
    renderer: "mobile",
    drawer: "DEV-MOBILE-DRAWER",
    pages: {
      sale: {
        content: [
          {
            type: "datagrid",
            dataSource: "BUILTIN_SALELINE",
          },
        ],
        toolbar: "search-item",
      },
      items: {
        content: [
          {
            type: "menu",
            source: "DEV-DESKTOP-LEFT",
          },
        ],
        toolbar: "menu-buttons",
      },
    },
    navigation: [
      {
        icon: "fa-user-lock",
        caption: "Lock",
        page: "lock",
      },
      {
        icon: "fa-cart-shopping",
        caption: "Sale",
        default: true,
        page: "sale",
        badge: {
          id: "sale-badge",
          dataSource: "BUILTIN_SALELINE",
        },
      },
      {
        icon: "fa-box-open",
        caption: "Items",
        page: "items",
      },
    ],
  },

  DESKTOP: {
    viewDesktop: {
      default: {
        button: {
          class: "multiline",
        },
      },
      tag: "sale",
      flow: "horizontal",
      content: [
        {
          alignment: "left",
          flow: "vertical",
          content: [
            {
              type: "grid",
              id: "salesLines",
              fontSize: "normal",
              dataSource: "BUILTIN_SALELINE",
              totals: [
                {
                  caption: "l$.Sale_SubTotal",
                  total: "TotalAmount",
                },
              ],
              control: "dataGrid",
            },
            {
              type: "menu",
              source: "SALE-LEFT",
              columns: 5,
              rows: 5,
              base: "55%",
              "margin-top": 0,
              dataSource: "BUILTIN_SALELINE",
            },
          ],
        },
        {
          flow: "vertical",
          base: "35%",
          content: [
            {
              type: "text",
              caption: "l$.Sale_EANHeader",
              id: "EanBoxText",
              showErase: false,
              base: "4em",
              control: "eanBox",
              bigCaption: true,
              inputFilter: true,
            },
            {
              type: "menu",
              source: "SALE-TOP",
              columns: 3,
              rows: 2,
              id: "buttongrid-functions-top",
              dataSource: "BUILTIN_SALELINE",
            },
            {
              type: "captionbox",
              fontSize: "medium",
              binding: {
                dataSource: "BUILTIN_SALELINE",
                captionSet: {
                  title: {
                    field: "10",
                  },
                  rows: [
                    {
                      field: "6039",
                    },
                    {
                      field: "6",
                    },
                    {
                      field: "15",
                    },
                  ],
                },
                fallback: {
                  dataSource: "BUILTIN_SALE",
                  captionSet: {
                    title: {
                      caption: "l$.Sale_LastSale",
                    },
                    rows: [
                      {
                        caption: "l$.LastSale_Total",
                        field: "LastSaleTotal",
                      },
                      {
                        caption: "l$.LastSale_Paid",
                        field: "LastSalePaid",
                      },
                      {
                        caption: "l$.LastSale_Change",
                        field: "LastSaleChange",
                      },
                    ],
                  },
                },
              },
            },
            {
              type: "menu",
              base: "44%",
              source: "SALE-BOTTOM",
              columns: 3,
              rows: [1, 1, 2],
              id: "buttongrid-functions-bottom",
              dataSource: "BUILTIN_SALELINE",
            },
          ],
        },
      ],
      statusBar: {
        dataSource: "BUILTIN_SALE",
        fontSize: "Medium",
        sections: [
          {
            field: "CompanyName",
            width: "20%",
            class: "strong",
          },
          {
            type: "group",
            width: "5%",
            sections: [
              {
                field: "4",
                width: "5%",
              },
              {
                field: "SalespersonName",
                class: "strong",
              },
            ],
          },
          {
            type: "group",
            width: "5%",
            sections: [
              {
                caption: "l$.Sale_RegisterNo",
                class: "strong",
              },
              {
                field: "1",
              },
            ],
          },
          {
            type: "group",
            width: "10%",
            sections: [
              {
                field: "7",
              },
              {
                field: "8",
              },
            ],
          },
          {
            type: "group",
            class: "group right",
            sections: [
              {
                caption: "l$.Sale_ReceiptNo",
                class: "strong",
              },
              {
                field: "2",
              },
            ],
          },
          {
            type: "group",
            class: "group right",
            sections: [
              {
                caption: "l$.Sale_LastSale",
                class: "strong",
              },
              {
                field: "LastSaleNo",
                class: "strong",
              },
            ],
          },
          {
            width: "5%",
            option: "nprVersion",
          },
        ],
      },
    },
    viewMobile: {
      default: {
        button: {
          class: "multiline",
        },
      },
      tag: "sale",
      flow: "vertical",
      content: [
        {
          flow: "vertical",
          content: [
            {
              type: "grid",
              id: "salesLines",
              fontSize: "normal",
              columns: [
                10,
                {
                  fieldId: 12,
                  width: 7,
                },
                {
                  fieldId: 15,
                  width: 15,
                },
                {
                  fieldId: 31,
                  width: 20,
                },
              ],
              dataSource: "BUILTIN_SALELINE",
              totals: [
                {
                  caption: "l$.Sale_SubTotal",
                  total: "TotalAmount",
                },
              ],
              control: "dataGrid",
            },
            {
              class: "togglable",
              flow: "vertical",
              content: [
                {
                  type: "text",
                  caption: "l$.Sale_EANHeader",
                  id: "EanBoxText",
                  showErase: false,
                  control: "eanBox",
                  bigCaption: true,
                },
                {
                  class: "top",
                  type: "menu",
                  source: "MSALE-TOP",
                  columns: 4,
                  rows: 1,
                  base: "5em",
                  id: "buttongrid-functions-top",
                  dataSource: "BUILTIN_SALELINE",
                  skipUndefined: true,
                },
              ],
            },
            {
              class: "more-menu",
              type: "menu",
              source: "MSALE-BOTTOM",
              columns: 3,
              rows: [1, 1, 2],
              id: "buttongrid-functions-more-menu",
              dataSource: "BUILTIN_SALELINE",
            },
            {
              class: "items-menu",
              type: "menu",
              source: "MSALE-LEFT",
              columns: 4,
              rows: 4,
              id: "buttongrid-functions-items-menu",
              dataSource: "BUILTIN_SALELINE",
            },
            {
              base: "4em",
              height: "4em",
              class: "bottom-menu",
              content: [
                {
                  type: "button",
                  caption: "l$.CaptionTablet_ButtonItems",
                  onclick: "toggleItems",
                },
                {
                  type: "button",
                  caption: "l$.CaptionTablet_ButtonMore",
                  onclick: "toggleMore",
                },
              ],
            },
          ],
        },
      ],
    },
  },
};

export const DEFAULT_VIEW_SALE = isMobile() ? DEFAULT_VIEW.MOBILE : DEFAULT_VIEW.DESKTOP;
