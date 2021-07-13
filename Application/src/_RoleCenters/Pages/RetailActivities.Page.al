page 6059812 "NPR Retail Activities"
{
    Caption = 'Retail Activities';
    PageType = CardPart;
    SourceTable = "NPR Retail Sales Cue";
    UsageCategory = None;
    layout
    {
        area(content)
        {
            cuegroup(Control6150623)
            {
                ShowCaption = false;
                field("Sales Orders"; Rec."Sales Orders")
                {

                    DrillDownPageID = "Sales Order List";
                    Image = "Document";
                    ToolTip = 'Specifies the value of the Sales Orders field';
                    ApplicationArea = NPRRetail;
                }
                field("Daily Sales Orders"; Rec."Daily Sales Orders")
                {

                    DrillDownPageID = "Sales Order List";
                    Image = "Document";
                    ToolTip = 'Specifies the value of the Daily Sales Orders field';
                    ApplicationArea = NPRRetail;
                }
                field("Import Pending"; Rec."Import Pending")
                {

                    DrillDownPageID = "NPR Nc Import List";
                    Image = "Document";
                    ToolTip = 'Specifies the value of the Import Unprocessed field';
                    ApplicationArea = NPRRetail;
                }
            }
            cuegroup(Control1)
            {
                Caption = 'Actions';
                actions
                {
                    action("New Sales Order")
                    {
                        Caption = 'New Sales Order';
                        RunObject = Page "Sales Order";
                        RunPageMode = Create;

                        Image = TileNew;
                        ToolTip = 'Executes the New Sales Order action';
                        ApplicationArea = NPRRetail;
                    }
                    action("New Sales Quote")
                    {
                        Caption = 'New Sales Quote';
                        RunObject = Page "Sales Quote";
                        RunPageMode = Create;

                        Image = TileNew;
                        ToolTip = 'Executes the New Sales Quote action';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            cuegroup(Control6150622)
            {
                ShowCaption = false;
                field("Pending Inc. Documents"; Rec."Pending Inc. Documents")
                {

                    Image = "Document";
                    ToolTip = 'Specifies the value of the Pending Inc. Documents field';
                    ApplicationArea = NPRRetail;
                }
                field("Processed Error Tasks"; Rec."Processed Error Tasks")
                {

                    DrillDownPageID = "NPR Nc Task List";
                    Image = "Document";
                    ToolTip = 'Specifies the value of the Processed Error Tasks field';
                    ApplicationArea = NPRRetail;
                }
                field("Failed Webshop Payments"; Rec."Failed Webshop Payments")
                {

                    DrillDownPageID = "NPR Magento Payment Line List";
                    Image = "Document";
                    ToolTip = 'Specifies the value of the Failed Webshop Payments field';
                    ApplicationArea = NPRRetail;
                }
            }
            cuegroup(Depreciated)
            {
                Caption = 'Depreciated';
                Visible = false;
                field("Sales Quotes"; Rec."Sales Quotes")
                {

                    DrillDownPageID = "Sales Quotes";
                    Image = "Document";
                    Visible = false;
                    ToolTip = 'Specifies the value of the Sales Quotes field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Return Orders"; Rec."Sales Return Orders")
                {

                    DrillDownPageID = "Sales Return Order List";
                    Image = "Document";
                    Visible = false;
                    ToolTip = 'Specifies the value of the Sales Return Orders field';
                    ApplicationArea = NPRRetail;
                }
                field("Magento Orders"; Rec."Magento Orders")
                {

                    DrillDownPageID = "Sales Order List";
                    Image = "Document";
                    Visible = false;
                    ToolTip = 'Specifies the value of the Magento Orders field';
                    ApplicationArea = NPRRetail;
                }
                field("Daily Sales Invoices"; Rec."Daily Sales Invoices")
                {

                    Caption = 'Daily Sales Invoices';
                    DrillDownPageID = "Posted Sales Invoices";
                    Image = "Document";
                    Visible = false;
                    ToolTip = 'Specifies the value of the Daily Sales Invoices field';
                    ApplicationArea = NPRRetail;
                }
                field("Tasks Unprocessed"; Rec."Tasks Unprocessed")
                {

                    DrillDownPageID = "NPR Nc Task List";
                    Image = "Document";
                    Visible = false;
                    ToolTip = 'Specifies the value of the Tasks Unprocessed field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
        Rec.SetFilter("Date Filter", '=%1', WorkDate());
    end;
}
