page 6150905 "HC Payment Types Posting Setup"
{
    // NPR5.37/BR  /20171027 CASE 267552 HQ Connector Created Object

    Caption = 'HC Payment Types Posting Setup';
    PageType = List;
    SourceTable = "HC Payment Type Posting Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("BC Payment Type POS No."; "BC Payment Type POS No.")
                {
                    ApplicationArea = All;
                }
                field("BC Register No."; "BC Register No.")
                {
                    ApplicationArea = All;
                }
                field("G/L Account No."; "G/L Account No.")
                {
                    ApplicationArea = All;
                }
                field("Bank Account No."; "Bank Account No.")
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

