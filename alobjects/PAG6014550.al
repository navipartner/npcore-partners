page 6014550 "RFID Print Log"
{
    // NPR5.55/MMV /20200713 CASE 407265 Created object

    Caption = 'RFID Print Log';
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "RFID Print Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No.";"Item No.")
                {
                }
                field("Variant Code";"Variant Code")
                {
                }
                field(Description;Description)
                {
                }
                field("RFID Tag Value";"RFID Tag Value")
                {
                }
                field(Barcode;Barcode)
                {
                }
                field("Batch ID";"Batch ID")
                {
                }
                field("User ID";"User ID")
                {
                }
                field("Printed At";"Printed At")
                {
                }
            }
        }
    }

    actions
    {
    }
}

