page 6151481 "NPR Magento Retail Activities"
{
    Extensible = False;
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

                        Image = TileNew;
                        ToolTip = 'Executes the New Sales Order action';
                        ApplicationArea = NPRMagento;
                    }
                    action("New Sales Quote")
                    {
                        Caption = 'New Sales Quote';
                        RunObject = Page "Sales Quote";
                        RunPageMode = Create;

                        Image = TileBrickNew;
                        ToolTip = 'Executes the New Sales Quote action';
                        ApplicationArea = NPRMagento;
                    }
                    action("New Sales Return Order")
                    {
                        Caption = 'New Sales Return Order';
                        RunObject = Page "Sales Return Order";
                        RunPageMode = Create;

                        Image = TileBrickNearBy;
                        ToolTip = 'Executes the New Sales Return Order action';
                        ApplicationArea = NPRMagento;
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

                            DrillDownPageID = "Sales Order List";
                            ToolTip = 'Specifies the value of the Sales Orders field';
                            ApplicationArea = NPRMagento;
                        }
                        field("Sales Quotes"; Rec."Sales Quotes")
                        {

                            DrillDownPageID = "Sales Quotes";
                            Visible = false;
                            ToolTip = 'Specifies the value of the Sales Quotes field';
                            ApplicationArea = NPRMagento;
                        }
                        field("Sales Return Orders"; Rec."Sales Return Orders")
                        {

                            DrillDownPageID = "Sales Return Order List";
                            ToolTip = 'Specifies the value of the Sales Return Orders field';
                            ApplicationArea = NPRMagento;
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

                            DrillDownPageID = "Sales Order List";
                            Visible = false;
                            ToolTip = 'Specifies the value of the Magento Orders field';
                            ApplicationArea = NPRMagento;
                        }
                        field("Daily Sales Invoices"; Rec."Daily Sales Invoices")
                        {

                            Caption = 'Daily Sales Invoices';
                            DrillDownPageID = "Posted Sales Invoices";
                            Visible = false;
                            ToolTip = 'Specifies the value of the Daily Sales Invoices field';
                            ApplicationArea = NPRMagento;
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

                            DrillDownPageID = "NPR Nc Import List";
                            ToolTip = 'Specifies the value of the Import Unprocessed field';
                            ApplicationArea = NPRMagento;
                        }
                        field("Tasks Unprocessed"; Rec."Tasks Unprocessed")
                        {

                            DrillDownPageID = "NPR Nc Task List";
                            Visible = false;
                            ToolTip = 'Specifies the value of the Tasks Unprocessed field';
                            ApplicationArea = NPRMagento;
                        }
                        field("Daily Sales Orders"; Rec."Daily Sales Orders")
                        {

                            DrillDownPageID = "Sales Order List";
                            ToolTip = 'Specifies the value of the Daily Sales Orders field';
                            ApplicationArea = NPRMagento;
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
