page 6151481 "NPR Magento Retail Activities"
{
    Caption = 'NaviConnect Activities';
    PageType = CardPart;
    UsageCategory = None;
    SourceTable = "NPR Magento Cue";

    layout
    {
        area(content)
        {
            cuegroup(Orders)
            {
                Caption = 'Orders';

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
                        Image = TileBrickNew;
                        ToolTip = 'Executes the New Sales Quote action';
                    }
                    action("New Sales Return Order")
                    {
                        Caption = 'New Sales Return Order';
                        RunObject = Page "Sales Return Order";
                        RunPageMode = Create;
                        ApplicationArea = All;
                        Image = TileBrickNearBy;
                        ToolTip = 'Executes the New Sales Return Order action';
                    }
                }
            }
            group(Control6150634)
            {
                ShowCaption = false;
                group(Control6150631)
                {
                    ShowCaption = false;
                    cuegroup(Control6150616)
                    {
                        ShowCaption = false;
                        field("Sales Orders"; Rec."Sales Orders")
                        {
                            ApplicationArea = All;
                            DrillDownPageID = "Sales Order List";
                            ToolTip = 'Specifies the value of the Sales Orders field';
                        }
                        field("Sales Quotes"; Rec."Sales Quotes")
                        {
                            ApplicationArea = All;
                            DrillDownPageID = "Sales Quotes";
                            Visible = false;
                            ToolTip = 'Specifies the value of the Sales Quotes field';
                        }
                        field("Sales Return Orders"; Rec."Sales Return Orders")
                        {
                            ApplicationArea = All;
                            DrillDownPageID = "Sales Return Order List";
                            ToolTip = 'Specifies the value of the Sales Return Orders field';
                        }
                    }
                }
            }
            group(Control6150635)
            {
                ShowCaption = false;
                group(Control6150632)
                {
                    ShowCaption = false;
                    cuegroup(Control6150622)
                    {
                        ShowCaption = false;
                        field("Magento Orders"; Rec."Magento Orders")
                        {
                            ApplicationArea = All;
                            DrillDownPageID = "Sales Order List";
                            Visible = false;
                            ToolTip = 'Specifies the value of the Magento Orders field';
                        }
                        field("Daily Sales Invoices"; Rec."Daily Sales Invoices")
                        {
                            ApplicationArea = All;
                            Caption = 'Daily Sales Invoices';
                            DrillDownPageID = "Posted Sales Invoices";
                            Visible = false;
                            ToolTip = 'Specifies the value of the Daily Sales Invoices field';
                        }
                    }
                }
            }
            group(Control6150636)
            {
                ShowCaption = false;
                group(Control6150633)
                {
                    ShowCaption = false;
                    cuegroup(Control6150620)
                    {
                        ShowCaption = false;
                        field("Import Pending"; Rec."Import Pending")
                        {
                            ApplicationArea = All;
                            DrillDownPageID = "NPR Nc Import List";
                            ToolTip = 'Specifies the value of the Import Unprocessed field';
                        }
                        field("Tasks Unprocessed"; Rec."Tasks Unprocessed")
                        {
                            ApplicationArea = All;
                            DrillDownPageID = "NPR Nc Task List";
                            Visible = false;
                            ToolTip = 'Specifies the value of the Tasks Unprocessed field';
                        }
                        field("Daily Sales Orders"; Rec."Daily Sales Orders")
                        {
                            ApplicationArea = All;
                            DrillDownPageID = "Sales Order List";
                            ToolTip = 'Specifies the value of the Daily Sales Orders field';
                        }
                    }
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