page 6014555 "NPR Touch Screen - Cust Loc."
{
    // NPR5.22/MMV/20160408 CASE 232067 Created page
    // NPR5.31/MMV /20170316 CASE 264109 Added field 4.

    Caption = 'Touch Screen - Customer Locations';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = StandardDialog;
    SourceTable = "NPR POS Customer Location";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Total Amount"; "Total Amount")
                {
                    ApplicationArea = All;
                }
            }
            group(Control6150617)
            {
                ShowCaption = false;
                part(Control6150618; "NPR Sale POS: Saved Sale Line")
                {
                    SubPageLink = "Customer Location No." = FIELD("No.");
                    SubPageView = SORTING("Register No.", "Sales Ticket No.", "Line No.");
                }
            }
        }
    }

    actions
    {
    }
}

