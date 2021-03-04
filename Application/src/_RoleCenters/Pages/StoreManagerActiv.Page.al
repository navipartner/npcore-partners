page 6059983 "NPR Store Manager Activ."
{

    Caption = 'Order Processing';
    PageType = ListPart;
    SourceTable = "NPR Retail Order Cue";
    UsageCategory = None;
    layout
    {
        area(content)
        {
            cuegroup("Open Documents")
            {
                field("Open Sales Orders"; Rec."Open Sales Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Orders";
                    ToolTip = 'Specifies the value of the Open Sales Orders field';
                }
                field("Open Purchase Orders"; Rec."Open Purchase Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Purchase Orders";
                    ToolTip = 'Specifies the value of the Open Purchase Orders field';
                }
            }
            cuegroup(Control6014404)
            {
                Caption = 'Actions';
                actions
                {
                    action("New Salesorder")
                    {
                        Caption = 'New Salesorder';
                        RunObject = Page "Sales Order";
                        RunPageMode = Create;
                        ApplicationArea = All;
                        Image = TileNew;
                        ToolTip = 'Executes the New Salesorder action';
                    }
                    action("New Purchase Order")
                    {
                        Caption = 'New Purchase Order';
                        RunObject = Page "Purchase Order";
                        RunPageMode = Create;
                        ApplicationArea = All;
                        Image = TileNew;
                        ToolTip = 'Executes the New Purchase Order action';
                    }
                }
            }
            cuegroup("Posted Documents")
            {
                field("Posted Sales Invoices"; Rec."Posted Sales Invoices")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Posted Sales Invoices";
                    ToolTip = 'Specifies the value of the Posted Sales Invoices field';
                }
                field("Posted Purchase Orders"; Rec."Posted Purchase Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Posted Purchase Invoices";
                    ToolTip = 'Specifies the value of the Posted Purchase Orders field';
                }
            }
        }
    }
}

