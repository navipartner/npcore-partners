page 6059812 "NPR Retail Activities"
{
    Caption = 'Retail Activities';
    PageType = CardPart;
    UsageCategory = Administration;
    SourceTable = "NPR Retail Sales Cue";

    layout
    {
        area(content)
        {
            cuegroup(Control6150623)
            {
                ShowCaption = false;
                field("Sales Orders"; "Sales Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Order List";
                    Image = "Document";
                    ToolTip = 'Specifies the value of the Sales Orders field';
                }
                field("Daily Sales Orders"; "Daily Sales Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Order List";
                    Image = "Document";
                    ToolTip = 'Specifies the value of the Daily Sales Orders field';
                }
                field("Import Pending"; "Import Pending")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR Nc Import List";
                    Image = "Document";
                    ToolTip = 'Specifies the value of the Import Unprocessed field';
                }

                actions
                {
                    action("New Sales Order")
                    {
                        Caption = 'New Sales Order';
                        RunObject = Page "Sales Order";
                        RunPageMode = Create;
                        ApplicationArea = All;
                        ToolTip = 'Executes the New Sales Order action';
                    }
                    action("New Sales Quote")
                    {
                        Caption = 'New Sales Quote';
                        RunObject = Page "Sales Quote";
                        RunPageMode = Create;
                        ApplicationArea = All;
                        ToolTip = 'Executes the New Sales Quote action';
                    }
                }
            }
            cuegroup(Control6150622)
            {
                ShowCaption = false;
                field("Pending Inc. Documents"; "Pending Inc. Documents")
                {
                    ApplicationArea = All;
                    Image = "Document";
                    ToolTip = 'Specifies the value of the Pending Inc. Documents field';
                }
                field("Processed Error Tasks"; "Processed Error Tasks")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR Nc Task List";
                    Image = "Document";
                    ToolTip = 'Specifies the value of the Processed Error Tasks field';
                }
                field("Failed Webshop Payments"; "Failed Webshop Payments")
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
                field("Sales Quotes"; "Sales Quotes")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Quotes";
                    Image = "Document";
                    Visible = false;
                    ToolTip = 'Specifies the value of the Sales Quotes field';
                }
                field("Sales Return Orders"; "Sales Return Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Return Order List";
                    Image = "Document";
                    Visible = false;
                    ToolTip = 'Specifies the value of the Sales Return Orders field';
                }
                field("Magento Orders"; "Magento Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Order List";
                    Image = "Document";
                    Visible = false;
                    ToolTip = 'Specifies the value of the Magento Orders field';
                }
                field("Daily Sales Invoices"; "Daily Sales Invoices")
                {
                    ApplicationArea = All;
                    Caption = 'Daily Sales Invoices';
                    DrillDownPageID = "Posted Sales Invoices";
                    Image = "Document";
                    Visible = false;
                    ToolTip = 'Specifies the value of the Daily Sales Invoices field';
                }
                field("Tasks Unprocessed"; "Tasks Unprocessed")
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

    actions
    {
        area(processing)
        {
            action("Action Items")
            {
                Caption = 'Action Items';
                ApplicationArea = All;
                ToolTip = 'Executes the Action Items action';
            }
        }
    }

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
            Init;
            Insert;
        end;
        SetFilter("Date Filter", '=%1', WorkDate);
    end;
}