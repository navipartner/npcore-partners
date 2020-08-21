page 6151030 "NpRv Arch. Sending Log"
{
    // NPR5.55/MHA /20200702  CASE 407070 Object created

    Caption = 'Archived Retail Voucher Sending Log';
    Editable = false;
    PageType = List;
    SourceTable = "NpRv Arch. Sending Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Log Date"; "Log Date")
                {
                    ApplicationArea = All;
                }
                field("Log Message"; "Log Message")
                {
                    ApplicationArea = All;
                }
                field("Sending Type"; "Sending Type")
                {
                    ApplicationArea = All;
                }
                field("Sent to"; "Sent to")
                {
                    ApplicationArea = All;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                }
                field("Error during Send"; "Error during Send")
                {
                    ApplicationArea = All;
                }
                field(ErrorMessage; GetErrorMessage())
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        Message(GetErrorMessage());
                    end;
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Arch. Voucher No."; "Arch. Voucher No.")
                {
                    ApplicationArea = All;
                }
                field("Original Entry No."; "Original Entry No.")
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

