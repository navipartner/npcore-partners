page 6151030 "NPR NpRv Arch. Sending Log"
{
    Extensible = False;
    Caption = 'Archived Retail Voucher Sending Log';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR NpRv Arch. Sending Log";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Log Date"; Rec."Log Date")
                {

                    ToolTip = 'Specifies the value of the Log Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Log Message"; Rec."Log Message")
                {

                    ToolTip = 'Specifies the value of the Log Message field';
                    ApplicationArea = NPRRetail;
                }
                field("Sending Type"; Rec."Sending Type")
                {

                    ToolTip = 'Specifies the value of the Sending Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Sent to"; Rec."Sent to")
                {

                    ToolTip = 'Specifies the value of the Sent to field';
                    ApplicationArea = NPRRetail;
                }
                field(Amount; Rec.Amount)
                {

                    ToolTip = 'Specifies the value of the Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("User ID"; Rec."User ID")
                {

                    ToolTip = 'Specifies the value of the User ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Error during Send"; Rec."Error during Send")
                {

                    ToolTip = 'Specifies the value of the Error during Send field';
                    ApplicationArea = NPRRetail;
                }
                field(ErrorMessage; Rec.GetErrorMessage())
                {

                    Caption = 'Error Message';
                    ToolTip = 'Specifies the value of the GetErrorMessage() field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        Message(Rec.GetErrorMessage());
                    end;
                }
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Arch. Voucher No."; Rec."Arch. Voucher No.")
                {

                    ToolTip = 'Specifies the value of the Arch. Voucher No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Original Entry No."; Rec."Original Entry No.")
                {

                    ToolTip = 'Specifies the value of the Original Entry No. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

