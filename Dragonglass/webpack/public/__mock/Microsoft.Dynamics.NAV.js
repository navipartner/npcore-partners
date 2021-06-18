const DEFAULT_NAV_LATENCY = 0;

const mockNavTemp = {
  lines: [],
};

const items = {
  10018: "Safari Test Ticket",
  31000: "          Tickets",
  31001: "Adult",
  31002: "Child",
  31003: "Senior",
  31004: "Child u/3 yr",
  31006: "Season Pass",
  31008: "Family",
  31009: "Events",
  31010: "Sponsor",
  320100: "Member Automated Test Framework",
  "320100-ADDMEMBER": "Member Automated Test Framework",
  "320100-CARD": "Member Automated Test Framework",
  "320100-RENEW": "Member Automated Test Framework",
  "320100-REPLACCRD": "Member Automated Test Framework",
  "320100-UPGRADE": "Member Automated Test Framework",
  320101: "Member Automated Test Framework",
  "320101-RENEW": "Member Automated Test Framework",
  "320101-UPGRADE": "Member Automated Test Framework",
  40000: "          Café Items",
  40001: "Soft Drink",
  40003: "Small Draft Beer",
  40004: "Large Draft Beer",
  40005: "Specialty Beer",
  40010: "White Wine Glass",
  40011: "White Wine Small Bottle",
  40012: "White Wine Regular Bottle",
  40013: "Red Wine Glass",
  40014: "Red Wine Small Bottle",
  40015: "Red Wine Regular Bottle",
  40016: "Rosé Wine Glass",
  40017: "Rosé Wine Small Bottle",
  40018: "Rosé Wine Regular Bottle",
  40019: "Apple Crumble Pie",
  40020: "Chocolate Eclair",
  40021: "Lemon Merinque Pie",
  40022: "Lemon & Raspeberry Eclair",
  70000: "          Watches",
  70001: "Skagen Ancher Men's Leather Watch",
  70003: "Skagen Ladies' Classic Watch",
  70004: "Skagen Black Label Ladies' Executive Diamond Watch",
  70005: "Festina Stainless Steel Chrono Watch Blue/Black",
  70006: "Festina Stainless Steel Chrono Watch Steel/Black",
  70007: "Certina DS Action Chronograph Men's Watch",
  70008: "Festina Men's Chronograph Watch Rose",
  70009: "Festina Multi Function Men's Watch",
  70010: "Certina DS-1 Men's Watch",
  70011: "Certina DS Action Diver Men's Watch",
  70012: "Ladies' Certina DS Dream Black Watch",
  70013: "Skagen Ladies' Black Mesh Strap Watch",
  70014: "Ladies' Certina DS Dream Watch",
  70015: "Men's Certina DS Sport Watch",
  70016: "Swiss Movement Sports Watch",
  73000: "          Jewelry",
  73001: "Skagen Jewellery Classic Bracelet",
  73002: "Skagen Swarovski Elements Ring",
  73003: "Change Silver Heart Necklace",
  73004: "Story Bracelet - Pink Lambskin",
  73005: "Story Gold Plated Ring w/ Oval Moonstone",
  73006: "Story Ring w/ Moonstone",
  73007: "Story Silver Ring w/Zirconia Stones",
  73008: "Marguerit Ring - Silver/Black",
  73009: "Skagen Rose Gold IP Ring",
  73010: "Skagen Black Mesh Ring",
  73011: "Skagen Swarovski Elements Ring",
  73012: "Skagen Swarovski White Ring",
  73013: "Skagen Swarovski Brown Ring",
  73014: "Skagen Rose Gold Ring w/ Clear Stone",
  73015: "Skagen Rose Gold Ring w/ Stone",
  73016: "Skagen Swarovski Elements Flower Ring",
  73017: "Skagen Swarovski Elements Heart Ring",
  73018: "Spinning Smilla Necklace w/ Logo",
  73019: "Spinning Cinderella Silver Ring - Extreme",
  73020: "Spinning Queen Silver Ring - Extreme",
  73021: "Spinning Sparkling Heart Silver Ring - Extreme",
  73022: "Spinning Brilliant Silver Ring - Max",
  73023: "Spinning Twinkle Silver Ring - Primo",
  73024: "Spinning Mini Blossom Black Silver Ring - Primo",
  73025: "Spinning Black Berry Oxidized Silver Pendant",
  73026: "Story Amazonite Bracelet",
  73027: "Gold Plated Silver Story Charm - Twisted Kugle",
  73029: "Story Bracelet - Black Lambskin",
  73030: "Story Bracelet - Blue Quartz",
  73031: "Story Bracelet - Green Peridot",
  73032: "Story Silver Ring w/ Green Stone",
  73033: "Ole Lynggaard Lace Pendant 18 kt Gold",
  73034: "Swing Time Earrings",
  73035: "Silver Desert Necklace",
  73036: "Pearl Stud Earrings",
  73037: "Blue Horizons Bracelets",
  80000: "          Clothing",
  80001: "Hummel Patrick Pants X13",
  80002: "Tommy Hilfiger Scanton 13",
  80004: "Tommy Hilfiger Sid Jeans AW13",
  80005: "Hummel Hamar Leggings",
  80006: "Hummel Alta T-shirt",
  80007: "Tommy Hilfiger Gingham Shirt",
  80008: "Tommy Hilfiger Shirt AW13",
  80009: "Hummel Abel Tee Green AW13",
  80010: "Tommy Hilfiger Allen Jacket",
  80011: "Napapijri Anorak AW13",
  80012: "Napapijri Terkel Fleece Jacket",
  80013: "Hummel Bredo Jacket AW13",
  80014: "Molo Parker Winter Jacket SS13",
  80015: "D-XEL Jacket 339",
  80016: "Hummel Emma Pants X13",
  80017: "Hummel Jane Pants X13",
  80018: "D-XEL Soft Pants 9837",
  80019: "D-XEL Emma Jeans Kroko",
  80020: "Molo Leopard Pants",
  80021: "Hummel Tula Cardigan X13",
  80022: "Tommy Hilfiger Colby 13",
  80023: "Tommy Hilfiger Knit AW13",
  80024: "Tommy Hilfiger Paula T-shirt",
  80025: "D-XEL Leggings 904 Copper AW13",
  80026: "Molo Person Ski Jacket",
  80027: "Hummel Rosina Pink Rain Wear",
  80028: "Hummel Abby T-shirt",
  80029: "Me Too Riborg Jacket",
  80030: "Hummel Cathrin Jacket AW13",
  80031: "Molo Peace Flower Jacket SS13",
  80032: "Hummel Hops Socks",
  80033: "Hummel Marco Pants",
  80034: "Hummel Jeremy Pants X13",
  80035: "Haglöfs Stem Jacket",
  80036: "Haglöfs Spitz II Jacket",
  80037: "Haglöfs Lizard Jacket",
  80038: "Haglöfs Rugged Mountain Pants",
  80039: "Haglöfs Mid Fjell Pants",
  80040: "Haglöfs Mid Trail Pants",
  80041: "Haglöfs B Tee",
  80042: "Haglöfs Zando Shirt",
  80043: "Haglöfs Lite Q Tour Skirt",
  80044: "Haglöfs Incus II Q Black",
  80045: "Haglöfs Lim Proof Q Jacket Imperial",
  80046: "Haglöfs Siljan Parka W Black",
  80047: "Haglöfs Hesse W Down Jacket",
  80048: "Haglöfs Lite Q Trek Pants Black",
  80049: "Haglöfs Fin II Q Vest",
  80050: "Haglöfs Lizard Q Jacket",
  80051: "Haglöfs Fjell Q Jacket",
  80052: "Haglöfs Velum II Q Jacket",
  80053: "Haglöfs Mid II Flex Q Pants",
  80054: "Haglöfs Lite Q Zip Off Pants",
  80055: "Haglöfs Rugged II Q Mountain Pants",
  80056: "Hummel Lana Leggings",
  80057: "Nolita Cami",
  80058: "Plaid Cotton Shirt",
  99: "Card Fee Surcharge",
  997: "",
  999: "Food",
  A2345: "Café",
  GL00000001: "GL00000001",
  GL00000003: "GL00000003",
  GL00000005: "GL00000005",
  GL00000007: "GL00000007",
  GL00000009: "GL00000009",
  GL00000011: "GL00000011",
  GL00000013: "GL00000013",
  GL00000015: "GL00000015",
  GL00000017: "GL00000017",
  GL00000018: "Food",
  SERIAL: "Serial",
  TESTTICKET: "test ticket",
};

class MockALImplementation {
  get interface() {
    return {
      OnFrameworkReady: [],
      OnAction: ["string", "string", "number", "number", "object"],
      OnInvokeMethod: ["string", "object"],
    };
  }

  OnFrameworkReady() {
    log(`OnFrameworkReady`);
  }

  OnAction(action, workflowStep, actionId, workflowId, context) {
    const response = {
      Stage: 0,
      WorkflowId: workflowId,
      ActionId: actionId,
      Success: true,
      ThrowError: false,
      ErrorMessage: null,
      Method: "WorkflowCallCompleted",
      RequiresResponse: false,
      Content: {
        _trace: {
          durationAll: 1851,
          durationAction: 1850,
          durationData: 0,
          durationOverhead: 1,
          debug_trace: "Method:OnAction20 at 10:42:44,211;",
        },
        context: {},
        workflowResponse: null,
        queuedWorkflows: [],
      },
    };

    try {
      switch (action) {
        case "ITEM":
          (() => {
            switch (workflowStep) {
              case "addSalesLine":
                mockNavTemp.saleLine = mockNavTemp.saleLine || {
                  lineNo: 10000,
                };
                mockNavTemp.saleLine.lineNo += 10000;

                const currentPos = `Cash Register No.=CONST(2),Sales Ticket No.=CONST(1002681),Date=CONST(27.09.19),Sale Type=CONST(Sale),Line No.=CONST(${mockNavTemp.saleLine.lineNo})`;
                mockNavTemp.lines.push(currentPos);
                const data = {
                  DataSets: {
                    BUILTIN_SALELINE: {
                      rows: [
                        {
                          position: currentPos,
                          negative: false,
                          class: null,
                          style: null,
                          deleted: false,
                          fields: {
                            5: 1,
                            6: context.parameters.itemNo,
                            10: items[context.parameters.itemNo] || "(non-existing item in mock-up database)",
                            11: "PCS",
                            12: 1,
                            15: 28,
                            19: 0,
                            20: 0,
                            31: 28,
                            6039: "",
                            "LineFormat.Color": "",
                            "LineFormat.Weight": "",
                            "LineFormat.Style": "",
                          },
                        },
                      ],
                      isDelta: true,
                      currentPosition: currentPos,
                      dataSource: "BUILTIN_SALELINE",
                      totals: {
                        AmountExclVAT: 89.6,
                        VATAmount: 22.4,
                        TotalAmount: 112,
                      },
                    },
                  },
                  Method: "RefreshData",
                  RequiresResponse: false,
                  Content: {
                    _trace: {
                      debug_trace: "",
                    },
                  },
                };
                javaScript("RefreshData", data);
                break;
            }
          })();
          break;

        case "ITEMCARD":
          alert("At this point, NAV would show the item card for this, but I myself can't do much about it.");
          break;

        case "QUANTITY":
          (() => {
            const data = {
              DataSets: {
                BUILTIN_SALELINE: {
                  rows: [
                    {
                      position: context.data.positions.BUILTIN_SALELINE,
                      fields: {
                        12: context.$PromptQuantity.numpad,
                        "LineFormat.Color": context.$PromptQuantity.numpad >= 0 ? "" : "red",
                        "LineFormat.Style": context.$PromptQuantity.numpad >= 0 ? "" : "italic",
                      },
                    },
                  ],
                  isDelta: true,
                  currentPosition: context.data.positions.BUILTIN_SALELINE,
                  dataSource: "BUILTIN_SALELINE",
                },
              },
              Method: "RefreshData",
              Content: {},
            };
            javaScript("RefreshData", data);
          })();
          break;
        case "DELETE_POS_LINE":
          (() => {
            const newLines = [];
            let deletedIndex;
            for (let i = 0; i < mockNavTemp.lines.length; i++)
              if (mockNavTemp.lines[i] === context.data.positions.BUILTIN_SALELINE) deletedIndex = i;
              else newLines.push(mockNavTemp.lines[i]);
            mockNavTemp.lines = newLines;
            const data = {
              DataSets: {
                BUILTIN_SALELINE: {
                  rows: [
                    {
                      position: context.data.positions.BUILTIN_SALELINE,
                      deleted: true,
                    },
                  ],
                  isDelta: true,
                  currentPosition: mockNavTemp.lines.length
                    ? mockNavTemp.lines.length > deletedIndex
                      ? mockNavTemp.lines[deletedIndex === 0 ? 0 : deletedIndex - 1]
                      : mockNavTemp.lines[mockNavTemp.lines.length - 1]
                    : null,
                  dataSource: "BUILTIN_SALELINE",
                  totals: { AmountExclVAT: 36, VATAmount: 9, TotalAmount: 45 },
                },
              },
              Method: "RefreshData",
            };
            javaScript("RefreshData", data);
          })();
          break;
        case "LOGIN":
          __mockLoginHandlePassword(javaScript, context);
          break;
        case "TEXT_ENTER":
          if (!items[context.value]) {
            throw new Error("Item No. " + context.value + " does not exist.");
          }
          mockNavTemp.saleLine = mockNavTemp.saleLine || { lineNo: 10000 };
          mockNavTemp.saleLine.lineNo += 10000;

          const currentPos = `Cash Register No.=CONST(2),Sales Ticket No.=CONST(1002681),Date=CONST(27.09.19),Sale Type=CONST(Sale),Line No.=CONST(${mockNavTemp.saleLine.lineNo})`;
          mockNavTemp.lines.push(currentPos);
          const data = {
            DataSets: {
              BUILTIN_SALELINE: {
                rows: [
                  {
                    position: currentPos,
                    negative: false,
                    class: null,
                    style: null,
                    deleted: false,
                    fields: {
                      5: 1,
                      6: context.value,
                      10: items[context.value] || "(non-existing item in mock-up database)",
                      11: "PCS",
                      12: 1,
                      15: 28,
                      19: 0,
                      20: 0,
                      31: 28,
                      6039: "",
                      "LineFormat.Color": "",
                      "LineFormat.Weight": "",
                      "LineFormat.Style": "",
                    },
                  },
                ],
                isDelta: true,
                currentPosition: currentPos,
                dataSource: "BUILTIN_SALELINE",
                totals: {
                  AmountExclVAT: 89.6,
                  VATAmount: 22.4,
                  TotalAmount: 112,
                },
              },
            },
            Method: "RefreshData",
            RequiresResponse: false,
            Content: {
              _trace: {
                debug_trace: "",
              },
            },
          };
          javaScript("RefreshData", data);
          break;
        case "PEPPER_TERMINAL":
          break;
        default:
          response.Success = false;
          response.ThrowError = true;
          response.ErrorMessage = `Action not implemented in AL: ${action}`;
          break;
      }
    } catch (e) {
      response.Success = false;
      response.ThrowError = true;
      response.ErrorMessage = e.message || String(e);
    }

    javaScript("WorkflowCallCompleted", response);
  }

  OnInvokeMethod(method, context) {
    if (method.startsWith("__mock")) return;

    log(`OnInvokeMethod(${method})`);
    var preHandler = preHandleMethod[method];
    if (preHandler) {
      log(`Pre-handled method: ${method}`);
      if (preHandler()) return;
    }

    var handler = methodHandlers[method];
    if (handler) {
      handler(context);
    } else {
      log(`Unknown method invoked: ${method}`);
    }
  }
}

const log = (msg) => console.log(`[Mock C/AL Backend] ${msg}`);

const preHandleMethod = {
  KeepAlive: () => true,
  InitializationComplete: () => __mockLoginInitialize(javaScript),
};

const action20Handlers = {
  SHOW_MODEL_TEST: () =>
    javaScript("ShowModel", {
      Method: "ShowModel",
      Content: {
        modelId: "{DA616DA0-6F25-489D-B8EB-A227F6827B2A}",
        html: '<div id="Panel1" class="adyen-dialog Panel"><span id="adyen-caption" class="adyen-dialog-item Label">Payment</span><span id="adyen-amount" class="adyen-dialog-item Label">0.50</span><div id="adyen-spinner" class="adyen-dialog-item Panel" style="font-size: 14px;"><div id="adyen-spinner-inner1" class="Panel" style="font-size: 14px;"></div><div id="adyen-spinner-inner2" class="Panel" style="font-size: 14px;"></div><div id="adyen-spinner-inner3" class="Panel" style="font-size: 14px;"></div><div id="adyen-spinner-inner4" class="Panel" style="font-size: 14px;"></div></div><span id="adyen-force-abort" class="adyen-dialog-item Label" style="display: none;">Force Abort</span><span id="adyen-abort" class="adyen-dialog-item Label">Abort</span><span id="adyen-timer" class="Label" style="font-size: 14px; display: none;"></span></div><script type="text/javascript">$("#adyen-force-abort").on("click", function() { n$.Framework.RaiseObjectModelEvent("adyen-force-abort", "click"); });$("#adyen-abort").on("click", function() { n$.Framework.RaiseObjectModelEvent("adyen-abort", "click"); });$("#adyen-timer").on("click", function() { n$.Framework.RaiseObjectModelEvent("adyen-timer", "click"); });;</script>',
        css: '<style type="text/css">.adyen-dialog {  max-width: 17.5em;  max-height: 20em;  width: 70vw;  height: 80vh;  background: linear-gradient(#f4f4f4, #dedede); -webkit-box-shadow: 0px 0px 12px 2px rgba(143,143,143,1); -moz-box-shadow: 0px 0px 12px 2px rgba(143,143,143,1);  box-shadow: 0px 0px 12px 2px rgba(143,143,143,1);  display: -webkit-box;  display: -moz-box;  display: -ms-flexbox;  display: -webkit-flex;  display: flex;  flex-flow: column wrap;  justify-content: space-around;  align-items: center;}.adyen-dialog-item {    margin: auto;    font-weight: bold;    font-family: Helvetica, Verdana, Arial, sans-serif;  text-align: center;}#adyen-caption {   margin-bottom: 0.2em;    font-size: 1em;  align-self: flex-start;}#adyen-amount {   margin-top: 0.2em;    margin-bottom: 1em;    font-size: 2em;  align-self: flex-start;}#adyen-status {   font-size: 1em;}#adyen-abort {   font-size: 1em;  background: grey;  border: none;  line-height: 2.5em;  cursor: pointer;  width: 80%;  align-self: flex-end;}#adyen-force-abort {   font-size: 1em;  background: grey;  border: none;  line-height: 2.5em;  cursor: pointer;  width: 80%;  align-self: flex-end;}#adyen-spinner {  display: inline-block;  position: relative;  width: 64px;  height: 64px;}#adyen-spinner div {  box-sizing: border-box;  display: block;  position: absolute;  width: 51px;  height: 51px;  margin: 6px;  border: 6px solid #000000;  border-radius: 50%;  animation: adyen-spinner 1.6s cubic-bezier(0.5, 0, 0.5, 1) infinite;  border-color: #000000 transparent transparent transparent;}#adyen-spinner div:nth-child(1) {  animation-delay: -0.45s;}#adyen-spinner div:nth-child(2) {  animation-delay: -0.3s;}#adyen-spinner div:nth-child(3) {  animation-delay: -0.15s;}@keyframes adyen-spinner {  0% {    transform: rotate(0deg);  }  100% {    transform: rotate(360deg);  }}</style>',
        script: '<script type="text/javascript">setInterval(function() { $("#adyen-timer").click(); }, 1000);</script>',
      },
    }),
  BALANCE_V1: () => javaScript("SetView", { View: { type: 4 } }),
  REST_VIEW: () => javaScript("SetView", { View: __mockViewRestaurant }),
  QUANTITY: (_workflowStep, context) => {
    const data = {
      DataSets: {
        BUILTIN_SALELINE: {
          rows: [
            {
              position: context.data.positions.BUILTIN_SALELINE,
              fields: {
                12: context.quantity,
              },
            },
          ],
          isDelta: true,
          currentPosition: context.data.positions.BUILTIN_SALELINE,
          dataSource: "BUILTIN_SALELINE",
        },
      },
      Method: "RefreshData",
      Content: {},
    };
    javaScript("RefreshData", data);
  },
  DELETE_POS_LINE: (_workflowStep, context) => {
    const newLines = [];
    let deletedIndex;
    for (let i = 0; i < mockNavTemp.lines.length; i++)
      if (mockNavTemp.lines[i] === context.data.positions.BUILTIN_SALELINE) deletedIndex = i;
      else newLines.push(mockNavTemp.lines[i]);
    mockNavTemp.lines = newLines;
    const data = {
      DataSets: {
        BUILTIN_SALELINE: {
          rows: [
            {
              position: context.data.positions.BUILTIN_SALELINE,
              deleted: true,
            },
          ],
          isDelta: true,
          currentPosition: mockNavTemp.lines.length
            ? mockNavTemp.lines.length > deletedIndex
              ? mockNavTemp.lines[deletedIndex === 0 ? 0 : deletedIndex - 1]
              : mockNavTemp.lines[mockNavTemp.lines.length - 1]
            : null,
          dataSource: "BUILTIN_SALELINE",
          totals: { AmountExclVAT: 36, VATAmount: 9, TotalAmount: 45 },
        },
      },
      Method: "RefreshData",
    };
    javaScript("RefreshData", data);
  },
  ITEM: (step, context) => {
    mockNavTemp.saleLine = mockNavTemp.saleLine || { lineNo: 10000 };
    mockNavTemp.saleLine.lineNo += 10000;

    const currentPos = `Cash Register No.=CONST(2),Sales Ticket No.=CONST(1002681),Date=CONST(27.09.19),Sale Type=CONST(Sale),Line No.=CONST(${mockNavTemp.saleLine.lineNo})`;
    mockNavTemp.lines.push(currentPos);
    const data = {
      DataSets: {
        BUILTIN_SALELINE: {
          rows: [
            {
              position: currentPos,
              negative: false,
              class: null,
              style: null,
              deleted: false,
              fields: {
                5: 1,
                6: context.parameters.itemNo,
                10: items[context.parameters.itemNo] || "(non-existing item in mock-up database)",
                11: "PCS",
                12: 1,
                15: 28,
                19: 0,
                20: 0,
                31: 28,
                6039: "",
                "LineFormat.Color": "",
                "LineFormat.Weight": "",
                "LineFormat.Style": "",
              },
            },
          ],
          isDelta: true,
          currentPosition: currentPos,
          dataSource: "BUILTIN_SALELINE",
          totals: {
            AmountExclVAT: 89.6,
            VATAmount: 22.4,
            TotalAmount: 112,
          },
        },
      },
      Method: "RefreshData",
      RequiresResponse: false,
      Content: {
        _trace: {
          debug_trace: "",
        },
      },
    };
    javaScript("RefreshData", data);
  },
  "LOGIN-BUTTON": (step, context) => {
    __mockLoginHandlePassword(javaScript, {
      type: "SalespersonCode",
      password: "1",
    });
  },
  "LOGIN.V2": (step, context) => {
    __mockLoginHandlePassword(javaScript, context);
  },
  "SEQ.POC.2": (step, context) => {
    if (window.confirm("Shall I not pass?")) throw new Error("You shall not pass!");
  },
  "POC20.2": (step, context) => "Done.",
  WF20DEMO: (step, context) => {
    /*
            CASE WorkflowStep OF 
            'math':
                IF CONFIRM('Result is: %1',FALSE,Context.GetInteger('exp',TRUE)) THEN;
            END;
        */
    switch (step) {
      case "math":
        if (window.confirm(`Result is: ${context.exp}`));
        break;
    }
  },
  WF20NEST2: (step, context) => {
    /*
            IF NOT CONFIRM('Gateway in AL') THEN BEGIN
                MESSAGE('An error is expected. Where is it?');
                ERROR('What? WAT?');
            END;

            FrontEnd.WorkflowResponse('Gateway response');
        */
    if (!window.confirm("Gateway in AL")) {
      alert("An error is expected. Where is it?");
      throw new Error("What? WAT?");
    }
    return "Gateway response";
  },
  WF20NEST1: (step, context) => {
    /*
            CASE WorkflowStep OF 
            'math':
                IF CONFIRM('Result is: %1',FALSE,Context.GetInteger('exp',TRUE)) THEN;
            END;
        */
    switch (step) {
      case "math":
        if (window.confirm(`Result is: ${context.exp}`));
        break;
    }
  },
  ACTIONINC: (step, context) => {
    (() => {
      const mock = (mockNavTemp.actionInc = mockNavTemp.actionInc || {});
      const position = context.data.positions.BUILTIN_SALELINE;
      const mockQty = (mock[position] = (mock[position] || 1) + context.increaseBy);

      const data = {
        DataSets: {
          BUILTIN_SALELINE: {
            rows: [
              {
                position: position,
                fields: {
                  12: mockQty,
                },
              },
            ],
            isDelta: true,
            currentPosition: position,
            dataSource: "BUILTIN_SALELINE",
          },
        },
        Method: "RefreshData",
        Content: {},
      };
      javaScript("RefreshData", data);
    })();
  },
  ACTIONDEL: (step, context) => {
    (() => {
      const newLines = [];
      let deletedIndex;
      for (let i = 0; i < mockNavTemp.lines.length; i++)
        if (mockNavTemp.lines[i] === context.data.positions.BUILTIN_SALELINE) deletedIndex = i;
        else newLines.push(mockNavTemp.lines[i]);
      mockNavTemp.lines = newLines;
      const data = {
        DataSets: {
          BUILTIN_SALELINE: {
            rows: [
              {
                position: context.data.positions.BUILTIN_SALELINE,
                deleted: true,
              },
            ],
            isDelta: true,
            currentPosition: mockNavTemp.lines.length
              ? mockNavTemp.lines.length > deletedIndex
                ? mockNavTemp.lines[deletedIndex === 0 ? 0 : deletedIndex - 1]
                : mockNavTemp.lines[mockNavTemp.lines.length - 1]
              : null,
            dataSource: "BUILTIN_SALELINE",
            totals: { AmountExclVAT: 36, VATAmount: 9, TotalAmount: 45 },
          },
        },
        Method: "RefreshData",
      };
      javaScript("RefreshData", data);
    })();
  },
};

const requireHandlers = {
  action: (context) => {
    switch (context.action) {
      case "LOGIN-BUTTON":
      case "ACTIONDEL":
      case "DELETE_POS_LINE":
      case "ACTIONINC":
        return {
          State: {},
          Workflow: {
            Name: context.action,
            RequestContext: false,
            Steps: [
              {
                Label: null,
                Code: "workflow.respond('');",
              },
            ],
            Content: {
              engineVersion: "2.0",
            },
          },
        };

      case "QUANTITY": {
        return {
          State: {},
          Workflow: {
            Name: context.action,
            RequestContext: false,
            Steps: [
              {
                Label: null,
                Code: "workflow.respond('', { quantity: await popup.numpad('How many?') });",
              },
            ],
            Content: {
              engineVersion: "2.0",
            },
          },
        };
      }

      case "NPRE-1":
        return {
          State: {},
          Workflow: {
            Name: context.action,
            RequestContext: false,
            Steps: [
              {
                Label: null,
                Code: "await popup.message(`${$parameters.caption} - ${$parameters.waiterPad}`);",
              },
            ],
            Content: {
              engineVersion: "2.0",
            },
          },
          Parameters: {
            caption: "Hello, World!",
            waiterPad: "1",
          },
        };

      case "TIMEOUT":
        return {
          State: {},
          Workflow: {
            Name: context.action,
            RequestContext: false,
            Steps: [
              {
                Label: null,
                Code: "window.top.location.reload();",
              },
            ],
            Content: {
              engineVersion: "2.0",
            },
          },
        };

      case "WF20NEST1":
        return {
          State: {},
          Workflow: {
            Name: "WF20NEST1",
            RequestContext: false,
            Steps: [
              {
                Label: null,
                // This workflow leaves "Uncaught in Promise" error in the console. That's because the error is not caught in the workflow, but is gobbled up.
                Code: 'workflow.queue("WF20QUEUE1", { parameters: { caption: "Hello, Mars!" } });workflow.queue("WF20QUEUE1", { parameters: { caption: "Hello, Jupiter!" } });workflow.run("WF20NEST2").then(result => {  workflow.respond("math", { exp: result } );   workflow.queue("WF20QUEUE1", { parameters: { caption: "Hello, Saturn!" } });  workflow.queue("WF20QUEUE1", { parameters: { caption: "Hello, Uranus!" } });}).then(() => {  workflow.queue("WF20QUEUE1", { parameters: { caption: "Hello, Neptune!" } });  workflow.queue("WF20QUEUE1", { parameters: { caption: "Hello, Pluto!" } });  workflow.complete(42);});workflow.keepAlive();',
              },
            ],
            Content: {
              engineVersion: "2.0",
            },
          },
          Parameters: {
            count: 1,
            _option_dialog: {
              message: 0,
              confirm: 1,
              error: 2,
            },
            dialog: 0,
            greeting: "Hello!",
            sendResponse: false,
          },
          Type: "Workflow",
          Content: {
            Description: "Proof of Concept: Workflows 2.0",
            param_option_dialogoriginalValue: "message",
          },
        };
      case "WF20NEST2":
        return {
          State: {},
          Workflow: {
            Name: "WF20NEST2",
            RequestContext: false,
            Steps: [
              {
                Label: null,
                Code: "js:WF20",
              },
            ],
            Content: {
              engineVersion: "2.0",
            },
          },
          Parameters: {},
          Type: "Workflow",
          Content: {
            Description: "Proof of Concept: Workflows 2.0 - nested",
          },
        };
      case "POC20.2":
        return {
          State: {},
          Workflow: {
            Name: "POC20.2",
            RequestContext: false,
            Steps: [
              {
                Label: null,
                Code: 'var result = await popup.numpad("An important question for " + $parameters.name, "Enter a number", $parameters.age);var cal = await workflow.respond("Step1", { value: result.ok ? result.value : 0, custom: "Hello?" });return cal;',
              },
            ],
            Content: {
              engineVersion: "2.0",
            },
          },
          Parameters: {
            age: 1,
            _option_color: {
              red: 0,
              green: 1,
              blue: 2,
            },
            color: 2,
            isGameOfThronesFan: false,
            name: "",
          },
          Type: "Workflow",
          Content: {
            Description: "Proof of Concept: Workflows 2.0",
            param_option_colororiginalValue: "blue",
          },
        };
      case "ITEM":
        return {
          State: {},
          Workflow: {
            Name: "ITEM",
            RequestContext: false,
            Steps: [
              {
                Label: null,
                Code: "workflow.respond();",
              },
            ],
            Content: {
              engineVersion: "2.0",
            },
          },
          Parameters: {
            caption: "Some caption",
            itemQuantity: 1,
          },
          Type: "Workflow",
          Content: {
            Description: "Proof of Concept: Workflows 2.0",
          },
        };
      case "WF20QUEUE1":
        return {
          State: {},
          Workflow: {
            Name: "WF20QUEUE1",
            RequestContext: false,
            Steps: [
              {
                Label: null,
                Code: "await popup.message($parameters.caption);",
              },
            ],
            Content: {
              engineVersion: "2.0",
            },
          },
          Parameters: {
            caption: "Some caption",
          },
          Type: "Workflow",
          Content: {
            Description: "Proof of Concept: Workflows 2.0",
          },
        };
      case "SEQ.POC.1":
        return {
          State: {},
          Workflow: {
            Name: "SEQ.POC.1",
            RequestContext: false,
            Steps: [
              {
                Label: null,
                Code: "await popup.message('First message');",
              },
            ],
            Content: {
              engineVersion: "2.0",
            },
          },
          Type: "Workflow",
          Content: {
            Description: "Proof of Concept: Workflows 2.0",
          },
        };
      case "SEQ.POC.2":
        return {
          State: {},
          Workflow: {
            Name: "SEQ.POC.2",
            RequestContext: false,
            Steps: [
              {
                Label: null,
                Code: "await popup.message('Second message'); workflow.respond();",
              },
            ],
            Content: {
              engineVersion: "2.0",
            },
          },
          Type: "Workflow",
          Content: {
            Description: "Proof of Concept: Workflows 2.0",
          },
        };
      case "SEQ.POC.3":
        return {
          State: {},
          Workflow: {
            Name: "SEQ.POC.3",
            RequestContext: false,
            Steps: [
              {
                Label: null,
                Code: "await popup.message('Third message');",
              },
            ],
            Content: {
              engineVersion: "2.0",
            },
          },
          Type: "Workflow",
          Content: {
            Description: "Proof of Concept: Workflows 2.0",
          },
        };
      case "SEQ.POC.4":
        return {
          State: {},
          Workflow: {
            Name: "SEQ.POC.4",
            RequestContext: false,
            Steps: [
              {
                Label: null,
                Code: "await popup.message('Fourth message');",
              },
            ],
            Content: {
              engineVersion: "2.0",
            },
          },
          Type: "Workflow",
          Content: {
            Description: "Proof of Concept: Workflows 2.0",
          },
        };
      default:
        throw new Error("Unknown action " + context.action);
    }
  },
  script: (context) => {
    switch (context.script) {
      case "WF20":
        return `await (async function (p) {
                        var msg = await workflow.respond(p);
                        await popup.message("Gateway completed: " + msg);
                    })();
                    return 11;`;
      default:
        throw new Error("Unknown script: " + context.script);
    }
  },
  image: (context) => {
    switch (context.image) {
      case "spinner":
        return "data:image/png;base64,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";
    }
  },
};

const _tempState = {};

const methodHandlers = {
  FrontEndId: (args) => {
    javaScript("HardwareInitializationCompleted");
  },
  Login: (args) => {
    __mockLoginHandlePassword(javaScript, args);
  },
  Require: (args) => {
    let result;
    try {
      result = requireHandlers[args.type](args.context);
      javaScript("RequireResponse", {
        Method: "RequireResponse",
        RequiresResponse: false,
        Content: {
          id: args.id,
          value: result,
          _trace: { debug_trace: "Method:Require at 14:49:48,307;" },
        },
      });
    } catch (e) {
      // Nothing to do here, a "require-not-resolved" kind of an event will be processed by the front end.
    }
  },

  BalancingGetState: (request) => {
    const { invocationId, method } = request._dragonglassResponseContext;
    javaScript("BackEndMethodInvocationResult", {
      Content: {
        id: invocationId,
        method,
        response: __mock_state_balancing,
      },
    });
  },

  BalancingSetState: (request) => {
    javaScript("SetView", { View: { type: 1 } });
  },

  LookupFromPOS: ({ _dragonglassResponseContext, type, generation, checkOnly, skip = 0, batchSize = 15 }) => {
    const { invocationId, method } = _dragonglassResponseContext;
    const state = (_tempState[type] = _tempState[type] || {});
    if (state.generation === undefined) {
      state.generation = -1;
    }
    if (!state._lastUpdated || Date.now() - state._lastUpdated > 5000) {
      state._lastUpdated = Date.now();
      state.generation += 1;
    }
    state.refreshIteration = (state.refreshIteration || 0) + 1;
    const fullRefresh = state.generation > generation;
    if (batchSize <= 0) {
      batchSize = 15;
    }
    if (fullRefresh) {
      if (!checkOnly) {
        batchSize += skip;
      }
      skip = 0;
    }

    const result = [];
    for (let i = 0; i < 830; i++) {
      result.push({
        id: `BIN-${i + 1}`,
        description: `Bin No. ${i + 1}, iteration ${state.refreshIteration}, skip: ${skip}`,
      });
    }

    javaScript("BackEndMethodInvocationResult", {
      Content: {
        id: invocationId,
        method,
        response: {
          type,
          fullRefresh,
          generation: state.generation,
          moreDataAvailable: skip + batchSize < result.length,
          data: result.slice(skip, skip + batchSize),
        },
      },
    });
  },

  BeforeWorkflow: (args) => {
    javaScript("WorkflowCallCompleted", {
      Stage: 0,
      WorkflowId: args.workflowId,
      ActionId: 0,
      Success: true,
      ThrowError: false,
      Method: "WorkflowCallCompleted",
      RequiresResponse: false,
      Content: {
        _trace: {
          durationAll: 3919,
          durationAction: 3919,
          durationData: 0,
          durationOverhead: 0,
          debug_trace: "Method:OnAction20 at 14:11:16,883;",
        },
        context: {},
        workflowResponse: {},
        queuedWorkflows: [],
      },
    });
  },

  OnAction20: (args) => {
    const { name, step, id, actionId, context } = args;

    const actionHandler = action20Handlers[name];
    let response = null,
      success = false,
      errorMessage = {};
    if (typeof actionHandler === "function") {
      try {
        response = actionHandler(step, context);
        success = true;
      } catch (e) {
        success = false;
        errorMessage = e.message;
      }
    } else {
      errorMessage = `Unknown action v2.0: ${name}`;
      log(errorMessage);
    }
    javaScript("WorkflowCallCompleted", {
      Stage: 0,
      WorkflowId: id,
      ActionId: actionId,
      Success: success,
      ThrowError: !success,
      ErrorMessage: errorMessage,
      Method: "WorkflowCallCompleted",
      RequiresResponse: false,
      Content: {
        _trace: {
          durationAll: 3919,
          durationAction: 3919,
          durationData: 0,
          durationOverhead: 0,
          debug_trace: "Method:OnAction20 at 14:11:16,883;",
        },
        workflowEngine: "2.0",
        context: {},
        workflowResponse: response,
        queuedWorkflows: [],
      },
    });
  },

  RequestWaiterPadData: (args) => {
    //"{"waiterPads":[{"id":"LP-PK00002","caption":"","status":"","statusCaption":""},{"id":"LP-PK00003","caption":"","status":"","statusCaption":""}],"waiterPadSeatingLinks":[{"restaurantId":"R2","locationId":"M1","seatingId":"S1","waiterPadId":"LP-PK00002"}]}"
    javaScript("UpdateWaiterPadData", {
      Method: "UpdateWaiterPadData",
      RequiresResponse: false,
      Content: __npre_waiterPadData,
    });
  },

  RequestRestaurantLayout: (args) => {
    javaScript("UpdateRestaurantLayout", {
      Method: "UpdateRestaurantLayout",
      RequiresResponse: false,
      Content: {
        restaurants: __npre_restaurants,
        locations: __npre_locations,
        statuses: __npre_statuses,
      },
    });

    setTimeout(() => {
      javaScript("UpdateRestaurantStatuses", {
        Method: "UpdateRestaurantStatuses",
        RequiresResponse: false,
        Content: __npre_updateStatuses,
      });
    }, 1500);
  },

  PreSearch: ({ search }) => {
    if (!search) {
      return;
    }
    let results = {};
    for (let key in items) {
      let item = items[key];
      let words = item.toLowerCase().split(" ");
      for (let word of words) {
        if (word.startsWith(search)) {
          if (!results[word]) {
            results[word] = 0;
          }
          results[word] += 1;
        }
      }
    }
    javaScript("UpdatePreSearch", {
      Method: "UpdatePreSearch",
      RequiresResponse: false,
      Content: { results },
    });
  },

  Search: ({ search, lastKey }) => {
    const descriptions = [
      "Lorem ipsum dolor sit amet.",
      "Adipiscing elit consectetur eliquan sed nobis trabitur.",
      "Consequentiar lamen tum pingus equitit nec volo nobem.",
      "Olim pulchra necquet alim potestatior loquuntur.",
      "Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
      "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
      "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.",
      "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
      "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium.",
      "Totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.",
      "Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit.",
      "Quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.",
      "Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit.",
      "Sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.",
      "Ut enim ad minima veniam, quis nostrum exercitationem ullam suscipit laboriosam, nisi ex ea commodi consequatur.",
      "Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur.",
      "Vel illum qui dolorem eum fugiat quo voluptas nulla pariatur.",
      "At quis risus sed vulputate odio ut enim blandit volutpat.",
      "Convallis a cras semper auctor neque. Nisl vel pretium lectus quam id leo in vitae turpis.",
      "Amet massa vitae tortor condimentum lacinia.",
      "Viverra vitae congue eu consequat.",
      "Vitae turpis massa sed elementum. Purus viverra accumsan in nisl nisi scelerisque eu.",
      "Posuere sollicitudin aliquam ultrices sagittis.",
      "Quis imperdiet massa tincidunt nunc pulvinar sapien et.",
      "Lacus sed turpis tincidunt id aliquet risus feugiat.",
      "Imperdiet dui accumsan sit amet nulla facilisi.",
      "Ultrices gravida dictum fusce ut placerat orci nulla pellentesque dignissim.",
      "Nisi vitae suscipit tellus mauris a. Amet nisl purus in mollis nunc sed id.",
      "Purus gravida quis blandit turpis cursus in hac. In fermentum et sollicitudin ac orci phasellus.",
      "Magna eget est lorem ipsum dolor sit amet consectetur.",
      "Lacus sed turpis tincidunt id aliquet risus feugiat in ante.",
      "Bibendum ut tristique et egestas quis ipsum suspendisse. Eget mi proin sed libero enim sed.",
      "Urna neque viverra justo nec ultrices dui sapien eget mi. Nunc consequat interdum varius sit amet mattis vulputate enim.",
      "Donec et odio pellentesque diam volutpat commodo sed. Molestie a iaculis at erat pellentesque adipiscing commodo.",
      "Quam vulputate dignissim suspendisse in est ante. Leo vel orci porta non pulvinar neque laoreet suspendisse interdum.",
      "Id venenatis a condimentum vitae sapien pellentesque habitant morbi tristique.",
      "Dignissim cras tincidunt lobortis feugiat vivamus.",
      "Posuere sollicitudin aliquam ultrices sagittis orci a scelerisque purus.",
      "At consectetur lorem donec massa sapien.",
    ];
    const results = [];
    let keys = Object.keys(items);
    let skip = keys.indexOf(lastKey) + 1;
    keys = keys.slice(skip);
    let hasMore = false;

    if (search !== "empty") {
      for (let key of keys) {
        results.push({
          no: key,
          name: items[key],
          description: descriptions
            .sort(() => Math.random() - 0.5)
            .slice(0, Math.ceil(Math.random() * 4) + 1)
            .reduce((previous, current) => `${previous}${Math.random() > 0.5 ? "\n" : " "}${current}`)
            .trim(),
          price: Math.round(Math.random() * 50) + 0.99,
          inventory: Math.round(Math.random() * 100) + 10,
        });
        if (results.length === 20) {
          hasMore = true;
          break;
        }
      }
    }

    setTimeout(
      () =>
        javaScript("UpdateSearch", {
          Method: "UpdateSearch",
          RequiresResponse: false,
          Content: { results, hasMore },
        }),
      Math.random() * 1500 + 1000
    );
  },
};

const javaScript = (method, request = {}) => {
  log(`[InvokeFrontEndAsync] ${method}: ${JSON.stringify(request)}`);
  request.Method = method;
  request.Content = request.Content || {};
  request.Content._trace = { debug_trace: "'mock trace'" };
  setTimeout(() => InvokeFrontEndAsync(request));
};

const navMethod =
  (action, types) =>
  (args = []) => {
    if (args.length !== types.length) throw new Error("The number of parameters must match");

    args.forEach((arg, i) => {
      const typeOfArg = typeof arg;
      if (types[i] !== typeOfArg)
        throw new Error(`Argument at ordinal ${i} must be of type ${types[i]}, but it was of type ${typeOfArg}.`);
    });

    try {
      action.apply(this, args);
    } catch (e) {
      alert("Runtime error in AL:\\" + e);
    }
  };

class MockNst {
  constructor(al) {
    this.___methods = {};
    const intf = al.interface;
    Object.keys(intf).forEach((key) => (this.___methods[key] = navMethod(al[key], intf[key])));
  }

  invoke(name, args) {
    if (name.startsWith("__mock")) return;

    const method = this.___methods[name];
    if (typeof method !== "function") throw new Error(`Unknown interface method: ${name}`);
    method(args);
  }
}

let taskId = 0;

class NstWorker {
  constructor(environment) {
    this.__environment = environment;
    this.__queue = [];
    this.__nst = new MockNst(new MockALImplementation());
    this.__latency = DEFAULT_NAV_LATENCY;
  }

  __enqueue(tracker) {
    this.__queue.push(Object.assign({}, tracker, { id: ++taskId }));
  }

  __delay(delay) {
    return new Promise((resolve) => setTimeout(resolve, delay));
  }

  __processNext(internal = false) {
    if ((!internal && this.__environment.Busy) || !this.__queue.length) return;

    const { name, args, fulfill, reject, timeout } = this.__queue.shift();

    this.__environment.__setBusy(true);
    (async () => {
      await (async () => {
        const delay = timeout / 2;
        await this.__delay(delay);
        try {
          this.__nst.invoke(name, args);
        } catch (e) {
          document.body.innerHTML =
            "<div style='padding-top: 0.5em; padding-bottom: 0.5em; font-weight: 100; font-size: 2.2em'>An error has occurred</div><div>" +
            e +
            "</div>";
          document.body.style.backgroundColor = "rgb(0, 114, 198)";
          document.body.style.color = "white";
          document.body.style.paddingLeft = "33%";
          document.body.style.paddingRight = "33%";
          reject(e);
        }
        await this.__delay(delay);
        fulfill();
      })();
      this.__processNext(true);
      this.__environment.__setBusy(false);
    })();
  }

  async work(name, args, timeout = this.__latency) {
    await new Promise((fulfill, reject) => {
      this.__enqueue({ name, args, fulfill, reject, task: ++taskId, timeout });
      this.__processNext();
    });
    this.__processNext();
  }
}

class Environment {
  constructor(deviceCategory, platform, userInteractionMode) {
    this.__deviceCategory = deviceCategory;
    this.__platform = platform;
    this.__userInteractionMode = userInteractionMode;
    this.__busy = false;
    this.__onBusyChanged = () => {};
  }

  get UserName() {
    return "MOCK_USER";
  }

  get CompanyName() {
    return "Dragonglass v.1.0";
  }

  get DeviceCategory() {
    return this.__deviceCategory;
  }

  get Platform() {
    return this.__platform;
  }

  get UserInteractionMode() {
    return this.__userInteractionMode;
  }

  get Busy() {
    return this.__busy;
  }

  get OnBusyChanged() {
    return this.__onBusyChanged;
  }

  set OnBusyChanged(value) {
    if (typeof value !== "function") return;

    this.__onBusyChanged = value;
  }

  __setBusy(next) {
    if (this.__busy === next) return;

    this.__busy = next;
    this.__onBusyChanged();
  }
}

class NavMock {
  constructor(deviceCategory = 0, platform = 1, userInteractionMode = 0) {
    this.__environment = new Environment(deviceCategory, platform, userInteractionMode);
    this.__nstWorker = new NstWorker(this.__environment);
  }

  InvokeExtensibilityMethod(name, args, skipIfBusy, callback) {
    if (skipIfBusy && this.__environment.Busy) return;

    (async () => {
      await this.__nstWorker.work(name, args);
      typeof callback === "function" && callback();
    })();
  }

  GetEnvironment() {
    return this.__environment;
  }

  GetImageResource(resource) {
    return `/.controlAddIn/${resource}`;
  }
}

window.Microsoft = {
  Dynamics: { NAV: new NavMock(), Framework: { Resource: {} } },
};
if (window.top !== window) window.top.Microsoft = window.Microsoft;
