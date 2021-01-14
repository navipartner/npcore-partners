page 6151030 "NPR NpRv Arch. Sending Log"
{
    Caption = 'Archived Retail Voucher Sending Log';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR NpRv Arch. Sending Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Log Date"; "Log Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Log Date field';
                }
                field("Log Message"; "Log Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Log Message field';
                }
                field("Sending Type"; "Sending Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sending Type field';
                }
                field("Sent to"; "Sent to")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sent to field';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field("Error during Send"; "Error during Send")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Error during Send field';
                }
                field(ErrorMessage; GetErrorMessage())
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the GetErrorMessage() field';

                    trigger OnDrillDown()
                    begin
                        Message(GetErrorMessage());
                    end;
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Arch. Voucher No."; "Arch. Voucher No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Arch. Voucher No. field';
                }
                field("Original Entry No."; "Original Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Original Entry No. field';
                }
            }
        }
    }
}

