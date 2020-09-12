page 6151481 "NPR Magento Retail Activities"
{
    // MAG1.17/MH/20150423  CASE 212263 Created NaviConnect Role Center
    // MAG1.17/BHR/20150428 CASE 212069 Added the following cues
    //                                               "Sales Orders"
    //                                               "Sales Quotes"
    //                                               "Sales Return Orders"
    //                                               "Internet orders"
    // MAG1.17/MH/20150514  CASE 213393 Removed custom caption of "Dailey Sales Orders"
    // MAG1.22/MHA/20160213 CASE 234030 Added wrapper groups around cuegroups in order to achieve three rows
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.01/MHA/20160907  CASE 242551 DrillDownPageID updated for "Import Pending" and "Tasks Unprocessed"

    Caption = 'NaviConnect Activities';
    PageType = CardPart;
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
                    }
                    action("New Sales Quote")
                    {
                        Caption = 'New Sales Quote';
                        RunObject = Page "Sales Quote";
                        RunPageMode = Create;
                        ApplicationArea = All;
                    }
                    action("New Sales Return Order")
                    {
                        Caption = 'New Sales Return Order';
                        RunObject = Page "Sales Return Order";
                        RunPageMode = Create;
                        ApplicationArea = All;
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
                        field("Sales Orders"; "Sales Orders")
                        {
                            ApplicationArea = All;
                            DrillDownPageID = "Sales Order List";
                        }
                        field("Sales Quotes"; "Sales Quotes")
                        {
                            ApplicationArea = All;
                            DrillDownPageID = "Sales Quotes";
                            Visible = false;
                        }
                        field("Sales Return Orders"; "Sales Return Orders")
                        {
                            ApplicationArea = All;
                            DrillDownPageID = "Sales Return Order List";
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
                        field("Magento Orders"; "Magento Orders")
                        {
                            ApplicationArea = All;
                            DrillDownPageID = "Sales Order List";
                            Visible = false;
                        }
                        field("Daily Sales Invoices"; "Daily Sales Invoices")
                        {
                            ApplicationArea = All;
                            Caption = 'Daily Sales Invoices';
                            DrillDownPageID = "Posted Sales Invoices";
                            Visible = false;
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
                        field("Import Pending"; "Import Pending")
                        {
                            ApplicationArea = All;
                            DrillDownPageID = "NPR Nc Import List";
                        }
                        field("Tasks Unprocessed"; "Tasks Unprocessed")
                        {
                            ApplicationArea = All;
                            DrillDownPageID = "NPR Nc Task List";
                            Visible = false;
                        }
                        field("Daily Sales Orders"; "Daily Sales Orders")
                        {
                            ApplicationArea = All;
                            DrillDownPageID = "Sales Order List";
                        }
                    }
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
                ApplicationArea = All;
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

