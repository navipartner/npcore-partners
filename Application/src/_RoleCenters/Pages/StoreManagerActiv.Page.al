page 6059983 "NPR Store Manager Activ."
{
    Extensible = False;

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
                    ToolTip = 'Specifies the number of the Open Sales Orders. By clicking you can view the list of Open Sales Orders';
                    ApplicationArea = NPRRetail;
                }
                field("Open Purchase Orders"; Rec."Open Purchase Orders")
                {

                    DrillDownPageID = "Purchase Orders";
                    ToolTip = 'Specifies the number of the Open Purchase Orders. By clicking you can view the list of Open Purchase Orders';
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
                        ToolTip = 'Create new Purchase Order';
                        ApplicationArea = NPRRetail;
                    }
                    action("New Purchase Order")
                    {
                        Caption = 'New Purchase Order';
                        RunObject = Page "Purchase Order";
                        RunPageMode = Create;

                        Image = TileNew;
                        ToolTip = 'Create new Purchase Order';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            cuegroup("Posted Documents")
            {
                Caption = 'Posted Documents';
                ShowCaption = true;

                field("Posted Sales Invoices"; Rec."Posted Sales Invoices")
                {

                    DrillDownPageID = "Posted Sales Invoices";
                    ToolTip = 'Specifies the number of the Posted Sales Invoices. By clicking you can view the list of Posted Sales Invoices.';
                    ApplicationArea = NPRRetail;
                }
                field("Posted Purchase Orders"; Rec."Posted Purchase Orders")
                {

                    DrillDownPageID = "Posted Purchase Invoices";
                    ToolTip = 'Specifies the number of the Posted Purchase Orders field. By clicking you can view the list of Posted Purchase Invoices.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

