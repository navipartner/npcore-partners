page 6150904 "NPR HC Payment Types"
{
    // NPR5.37/BR  /20171027 CASE 267552 HQ Connector Created Object
    // NPR5.38/BR  /20171128 CASE 297946 Added field 600 HQ Processing

    Caption = 'HC Payment Types';
    PageType = List;
    SourceTable = "NPR HC Payment Type POS";
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
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Account Type"; "Account Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Account Type field';
                }
                field("G/L Account No."; "G/L Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the G/L Account field';
                }
                field("Bank Acc. No."; "Bank Acc. No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bank field';
                }
                field("HQ Processing"; "HQ Processing")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the HQ Processing field';
                }
                field("HQ Post Sales Document"; "HQ Post Sales Document")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the HQ Post Sales Document field';
                }
                field("HQ Post Payment"; "HQ Post Payment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the HQ Post Payment field';
                }
                field("Payment Method Code"; "Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Method Code field';
                }
            }
        }
    }

    actions
    {
    }
}

