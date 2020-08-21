page 6151029 "NpRv Sending Log"
{
    // NPR5.55/MHA /20200702  CASE 407070 Object created

    Caption = 'Retail Voucher Sending Log';
    Editable = false;
    PageType = List;
    SourceTable = "NpRv Sending Log";

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
                field("Voucher No."; "Voucher No.")
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

