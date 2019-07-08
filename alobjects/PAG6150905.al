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
                field("BC Payment Type POS No.";"BC Payment Type POS No.")
                {
                }
                field("BC Register No.";"BC Register No.")
                {
                }
                field("G/L Account No.";"G/L Account No.")
                {
                }
                field("Bank Account No.";"Bank Account No.")
                {
                }
            }
        }
    }

    actions
    {
    }
}

