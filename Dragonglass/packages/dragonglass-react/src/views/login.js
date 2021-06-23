import { isMobile } from "../classes/functions";

const DEFAULT_VIEW = {
  MOBILE: {
    tag: "login",
    renderer: "mobile",
    drawer: "DEV-MOBILE-DRAWER",
    pages: {
      login: {
        content: [
          {
            type: "loginpad",
          },
        ],
      },
      info: {
        content: [
          {
            type: "infobox",
            dataSource: "BUILTIN_SALE",
            header: {
              caption: "l$.Sale_LastSale",
              field: "LastSaleDate",
            },
            rows: [
              {
                caption: "l$.Sale_PaymentAmount",
                field: "LastSalePaid",
              },
              {
                caption: "l$.Sale_PaymentTotal",
                field: "LastSaleTotal",
              },
              {
                caption: "l$.Sale_ReturnAmount",
                field: "LastSaleChange",
              },
              [
                {
                  caption: "l$.Sale_ReceiptNo",
                  field: "LastSaleNo",
                  align: "left",
                  width: "33%",
                },
                {
                  caption: "l$.Sale_RegisterNo",
                  field: "1",
                  align: "right",
                  width: "33%",
                },
              ],
            ],
            footer: {
              caption: "Hello, World!",
              align: "center",
            },
          },
        ],
      },
      settings: {
        content: [
          {
            type: "menu",
            source: "LOGIN",
          },
        ],
      },
    },
    navigation: [
      {
        icon: "fa-user-unlock",
        caption: "Login",
        page: "login",
      },
      {
        icon: "fa-circle-info",
        caption: "Info",
        page: "info",
      },
      {
        icon: "fa-gear",
        caption: "Settings",
        page: "settings",
      },
      {
        icon: "fa-scale-balanced",
        caption: "Balance",
        disabled: true,
      },
    ],
  },

  DESKTOP: {
    viewDesktop: {
      tag: "login",
      flow: "vertical",
      margin: "10% 15%",
      content: [
        {
          class: "top",
          base: "75%",
          flow: "horizontal",
          content: [
            {
              class: "left",
              flow: "vertical",
              base: "60%",
              content: [
                {
                  width: "100%",
                  type: "logo",
                },
                {
                  type: "captionbox",
                  class: "lastsale",
                  fontSize: "medium",
                  selfAlign: "center",
                  binding: {
                    dataSource: "BUILTIN_SALE",
                    captionSet: {
                      title: {
                        caption: "l$.Sale_LastSale",
                        field: "LastSaleDate",
                      },
                      rows: [
                        {
                          caption: "l$.Sale_PaymentAmount",
                          field: "LastSalePaid",
                        },
                        {
                          caption: "l$.Sale_PaymentTotal",
                          field: "LastSaleTotal",
                        },
                        {
                          caption: "l$.Sale_ReturnAmount",
                          field: "LastSaleChange",
                        },
                        {
                          class: "lastline",
                          left: {
                            caption: "l$.Sale_ReceiptNo",
                            field: "LastSaleNo",
                          },
                          right: {
                            caption: "l$.Sale_RegisterNo",
                            field: "1",
                          },
                        },
                      ],
                    },
                  },
                },
              ],
            },
            {
              class: "right",
              width: "40%",
              content: {
                type: "loginpad",
                control: "loginpad",
              },
            },
          ],
        },
        {
          class: "bottom",
          content: {
            type: "menu",
            source: "LOGIN",
            columns: 2,
            rows: 1,
            width: "350px",
            height: "80px",
          },
        },
      ],
    },
    viewMobile: {
      tag: "login",
      flow: "vertical",
      content: [
        {
          type: "logo",
          class: "logo",
        },
        {
          type: "loginpad",
          class: "loginpad",
          control: "loginpad",
        },
        {
          class: "menu",
          content: {
            type: "menu",
            source: "MLOGIN",
            columns: 2,
            rows: 1,
          },
        },
        {
          type: "captionbox",
          class: "info",
          binding: {
            dataSource: "BUILTIN_SALE",
            captionSet: {
              rows: [
                {
                  caption: "l$.Sale_RegisterNo",
                  field: "1",
                },
              ],
            },
          },
        },
      ],
    },
  },
};

export const DEFAULT_VIEW_LOGIN = isMobile()
  ? DEFAULT_VIEW.MOBILE
  : DEFAULT_VIEW.DESKTOP;
