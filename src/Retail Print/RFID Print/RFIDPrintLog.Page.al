page 6014550 "NPR RFID Print Log"
{
    // NPR5.55/MMV /20200713 CASE 407265 Created object

    Caption = 'RFID Print Log';
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR RFID Print Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("RFID Tag Value"; "RFID Tag Value")
                {
                    ApplicationArea = All;
                }
                field(Barcode; Barcode)
                {
                    ApplicationArea = All;
                }
                field("Batch ID"; "Batch ID")
                {
                    ApplicationArea = All;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                }
                field("Printed At"; "Printed At")
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

