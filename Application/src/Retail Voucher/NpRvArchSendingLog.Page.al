page 6151030 "NPR NpRv Arch. Sending Log"
{
    Caption = 'Archived Retail Voucher Sending Log';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR NpRv Arch. Sending Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Log Date"; Rec."Log Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Log Date field';
                }
                field("Log Message"; Rec."Log Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Log Message field';
                }
                field("Sending Type"; Rec."Sending Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sending Type field';
                }
                field("Sent to"; Rec."Sent to")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sent to field';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field("Error during Send"; Rec."Error during Send")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Error during Send field';
                }
                field(ErrorMessage; Rec.GetErrorMessage())
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the GetErrorMessage() field';

                    trigger OnDrillDown()
                    begin
                        Message(Rec.GetErrorMessage());
                    end;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Arch. Voucher No."; Rec."Arch. Voucher No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Arch. Voucher No. field';
                }
                field("Original Entry No."; Rec."Original Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Original Entry No. field';
                }
            }
        }
    }
}

