pageextension 6014407 "NPR Payment Journal" extends "Payment Journal"
{
    layout
    {
        addafter("Account No.")
        {
            field("NPR Account Name"; AccountName)
            {
                Caption = 'Account Name';
                ApplicationArea = NPRRetail;
                Visible = false;
                ToolTip = 'Specifies the name of the account.';
            }
        }
        modify("Account Type")
        {
            trigger OnAfterValidate()
            begin
                GenJnlManagement.GetAccounts(Rec, AccountName, BalancingAccountName);
            end;
        }
        modify("Account No.")
        {
            trigger OnAfterValidate()
            begin
                GenJnlManagement.GetAccounts(Rec, AccountName, BalancingAccountName);
            end;
        }
        modify("Bal. Account No.")
        {
            trigger OnAfterValidate()
            begin
                GenJnlManagement.GetAccounts(Rec, AccountName, BalancingAccountName);
            end;
        }
    }
    var
        GenJnlManagement: Codeunit GenJnlManagement;
        AccountName: Text;
        BalancingAccountName: Text;

    trigger OnAfterGetRecord()
    begin
        GenJnlManagement.GetAccounts(Rec, AccountName, BalancingAccountName);

    end;
}