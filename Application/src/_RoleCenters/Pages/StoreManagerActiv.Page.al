page 6059983 "NPR Store Manager Activ."
{
    // NPR5.41/TS  /20180105 CASE 300893 ControlContainers cannot have captions
    // NPR5.43/JDH /20180604 CASE 317971 Changed captions to ENU

    Caption = 'Order Processing';
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR Retail Order Cue";

    layout
    {
        area(content)
        {
            cuegroup("Open Documents")
            {
                field("Open Sales Orders"; "Open Sales Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Orders";
                }
                field("Open Purchase Orders"; "Open Purchase Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Purchase Orders";
                }

                actions
                {
                    action("New Salesorder")
                    {
                        Caption = 'New Salesorder';
                        RunObject = Page "Sales Order";
                        RunPageMode = Create;
                        ApplicationArea = All;
                    }
                    action("New Purchase Order")
                    {
                        Caption = 'New Purchase Order';
                        RunObject = Page "Purchase Order";
                        RunPageMode = Create;
                        ApplicationArea = All;
                    }
                }
            }
            cuegroup("Posted Documents")
            {
                field("Posted Sales Invoices"; "Posted Sales Invoices")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Posted Sales Invoices";
                }
                field("Posted Purchase Orders"; "Posted Purchase Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Posted Purchase Invoices";
                }
            }
        }
    }

    actions
    {
    }
}

