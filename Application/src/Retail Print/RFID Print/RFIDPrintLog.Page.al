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
    ApplicationArea = All;
    SourceTable = "NPR RFID Print Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("RFID Tag Value"; Rec."RFID Tag Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the RFID Tag Value field';
                }
                field(Barcode; Rec.Barcode)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Barcode field';
                }
                field("Batch ID"; Rec."Batch ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Batch ID field';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field("Printed At"; Rec."Printed At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Printed At field';
                }
            }
        }
    }

    actions
    {
    }
}

