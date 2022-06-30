page 6184608 NPRPowerBIG_LAccount
{
    PageType = List;
    Caption = 'PowerBI G/L Account';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "G/L Account";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the name of the cash account.';
                    ApplicationArea = All;
                }
                field("Account Type"; Rec."Account Type")
                {
                    ToolTip = 'Specifies the purpose of the account. Total: Used to total a series of balances on accounts from many different account groupings. To use Total, leave this field blank. Begin-Total: A marker for the beginning of a series of accounts to be totaled that ends with an End-Total account. End-Total: A total of a series of accounts that starts with the preceding Begin-Total account. The total is defined in the Totaling field.';
                    ApplicationArea = All;
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies the status of the account.';
                    ApplicationArea = All;
                }
                field(Totaling; Rec.Totaling)
                {
                    ToolTip = 'Specifies an account interval or a list of account numbers. The entries of the account will be totaled to give a total balance. How entries are totaled depends on the value in the Account Type field.';
                    ApplicationArea = All;
                }
            }
        }
    }
}