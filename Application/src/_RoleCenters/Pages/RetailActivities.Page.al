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
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Order List";
                    Image = "Document";
                    ToolTip = 'Specifies the value of the Sales Orders field';
                }
                field("Daily Sales Orders"; Rec."Daily Sales Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Order List";
                    Image = "Document";
                    ToolTip = 'Specifies the value of the Daily Sales Orders field';
                }
                field("Import Pending"; Rec."Import Pending")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR Nc Import List";
                    Image = "Document";
                    ToolTip = 'Specifies the value of the Import Unprocessed field';
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
                        ApplicationArea = All;
                        Image = TileNew;
                        ToolTip = 'Executes the New Sales Order action';
                    }
                    action("New Sales Quote")
                    {
                        Caption = 'New Sales Quote';
                        RunObject = Page "Sales Quote";
                        RunPageMode = Create;
                        ApplicationArea = All;
                        Image = TileNew;
                        ToolTip = 'Executes the New Sales Quote action';
                    }
                }
            }
            cuegroup(Control6150622)
            {
                ShowCaption = false;
                field("Pending Inc. Documents"; Rec."Pending Inc. Documents")
                {
                    ApplicationArea = All;
                    Image = "Document";
                    ToolTip = 'Specifies the value of the Pending Inc. Documents field';
                }
                field("Processed Error Tasks"; Rec."Processed Error Tasks")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR Nc Task List";
                    Image = "Document";
                    ToolTip = 'Specifies the value of the Processed Error Tasks field';
                }
                field("Failed Webshop Payments"; Rec."Failed Webshop Payments")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR Magento Payment Line List";
                    Image = "Document";
                    ToolTip = 'Specifies the value of the Failed Webshop Payments field';
                }
            }
            cuegroup(Depreciated)
            {
                Caption = 'Depreciated';
                Visible = false;
                field("Sales Quotes"; Rec."Sales Quotes")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Quotes";
                    Image = "Document";
                    Visible = false;
                    ToolTip = 'Specifies the value of the Sales Quotes field';
                }
                field("Sales Return Orders"; Rec."Sales Return Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Return Order List";
                    Image = "Document";
                    Visible = false;
                    ToolTip = 'Specifies the value of the Sales Return Orders field';
                }
                field("Magento Orders"; Rec."Magento Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Order List";
                    Image = "Document";
                    Visible = false;
                    ToolTip = 'Specifies the value of the Magento Orders field';
                }
                field("Daily Sales Invoices"; Rec."Daily Sales Invoices")
                {
                    ApplicationArea = All;
                    Caption = 'Daily Sales Invoices';
                    DrillDownPageID = "Posted Sales Invoices";
                    Image = "Document";
                    Visible = false;
                    ToolTip = 'Specifies the value of the Daily Sales Invoices field';
                }
                field("Tasks Unprocessed"; Rec."Tasks Unprocessed")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR Nc Task List";
                    Image = "Document";
                    Visible = false;
                    ToolTip = 'Specifies the value of the Tasks Unprocessed field';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset;
        if not Rec.Get then begin
            Rec.Init;
            Rec.Insert;
        end;
        Rec.SetFilter("Date Filter", '=%1', WorkDate);
    end;
}
