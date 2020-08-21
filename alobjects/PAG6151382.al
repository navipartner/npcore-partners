page 6151382 "CS Stock-Take Rfid List"
{
    // NPR5.50/JAKUBV/20190603  CASE 344466 Transport NPR5.50 - 3 June 2019

    Caption = 'CS Stock-Take Rfid List';
    CardPageID = "CS Stock-Take Rfid Card";
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "CS Stock-Take Handling Rfid";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Id; Id)
                {
                    ApplicationArea = All;
                }
                field("Batch Id"; "Batch Id")
                {
                    ApplicationArea = All;
                }
                field("Request Function"; "Request Function")
                {
                    ApplicationArea = All;
                }
                field("Batch No."; "Batch No.")
                {
                    ApplicationArea = All;
                }
                field("Device Id"; "Device Id")
                {
                    ApplicationArea = All;
                }
                field("Stock-Take Config Code"; "Stock-Take Config Code")
                {
                    ApplicationArea = All;
                }
                field("Worksheet Name"; "Worksheet Name")
                {
                    ApplicationArea = All;
                }
                field(Tags; Tags)
                {
                    ApplicationArea = All;
                }
                field(Handled; Handled)
                {
                    ApplicationArea = All;
                }
                field(Created; Created)
                {
                    ApplicationArea = All;
                }
                field("Created By"; "Created By")
                {
                    ApplicationArea = All;
                }
                field("Batch Posting"; "Batch Posting")
                {
                    ApplicationArea = All;
                }
                field("Posting Started"; "Posting Started")
                {
                    ApplicationArea = All;
                }
                field("Posting Ended"; "Posting Ended")
                {
                    ApplicationArea = All;
                }
                field("Posting Error"; "Posting Error")
                {
                    ApplicationArea = All;
                }
                field("Posting Error Detail"; "Posting Error Detail")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

