page 6150904 "HC Payment Types"
{
    // NPR5.37/BR  /20171027 CASE 267552 HQ Connector Created Object
    // NPR5.38/BR  /20171128 CASE 297946 Added field 600 HQ Processing

    Caption = 'HC Payment Types';
    PageType = List;
    SourceTable = "HC Payment Type POS";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Account Type"; "Account Type")
                {
                    ApplicationArea = All;
                }
                field("G/L Account No."; "G/L Account No.")
                {
                    ApplicationArea = All;
                }
                field("Bank Acc. No."; "Bank Acc. No.")
                {
                    ApplicationArea = All;
                }
                field("HQ Processing"; "HQ Processing")
                {
                    ApplicationArea = All;
                }
                field("HQ Post Sales Document"; "HQ Post Sales Document")
                {
                    ApplicationArea = All;
                }
                field("HQ Post Payment"; "HQ Post Payment")
                {
                    ApplicationArea = All;
                }
                field("Payment Method Code"; "Payment Method Code")
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

