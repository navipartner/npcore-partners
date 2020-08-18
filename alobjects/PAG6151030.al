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
                field("Log Date";"Log Date")
                {
                }
                field("Log Message";"Log Message")
                {
                }
                field("Sending Type";"Sending Type")
                {
                }
                field("Sent to";"Sent to")
                {
                }
                field(Amount;Amount)
                {
                }
                field("User ID";"User ID")
                {
                }
                field("Error during Send";"Error during Send")
                {
                }
                field(ErrorMessage;GetErrorMessage())
                {

                    trigger OnDrillDown()
                    begin
                        Message(GetErrorMessage());
                    end;
                }
                field("Entry No.";"Entry No.")
                {
                }
                field("Arch. Voucher No.";"Arch. Voucher No.")
                {
                }
                field("Original Entry No.";"Original Entry No.")
                {
                }
            }
        }
    }

    actions
    {
    }
}

