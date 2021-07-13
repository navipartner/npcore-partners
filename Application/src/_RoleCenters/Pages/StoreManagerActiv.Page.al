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

                    DrillDownPageID = "Sales Orders";
                    ToolTip = 'Specifies the value of the Open Sales Orders field';
                    ApplicationArea = NPRRetail;
                }
                field("Open Purchase Orders"; Rec."Open Purchase Orders")
                {

                    DrillDownPageID = "Purchase Orders";
                    ToolTip = 'Specifies the value of the Open Purchase Orders field';
                    ApplicationArea = NPRRetail;
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

                        Image = TileNew;
                        ToolTip = 'Executes the New Salesorder action';
                        ApplicationArea = NPRRetail;
                    }
                    action("New Purchase Order")
                    {
                        Caption = 'New Purchase Order';
                        RunObject = Page "Purchase Order";
                        RunPageMode = Create;

                        Image = TileNew;
                        ToolTip = 'Executes the New Purchase Order action';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            cuegroup("Posted Documents")
            {
                field("Posted Sales Invoices"; Rec."Posted Sales Invoices")
                {

                    DrillDownPageID = "Posted Sales Invoices";
                    ToolTip = 'Specifies the value of the Posted Sales Invoices field';
                    ApplicationArea = NPRRetail;
                }
                field("Posted Purchase Orders"; Rec."Posted Purchase Orders")
                {

                    DrillDownPageID = "Posted Purchase Invoices";
                    ToolTip = 'Specifies the value of the Posted Purchase Orders field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

