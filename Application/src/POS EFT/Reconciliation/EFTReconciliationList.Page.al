page 6059818 "NPR EFT Reconciliation List"
{
    Caption = 'EFT Reconciliation List';
    CardPageID = "NPR EFT Reconciliation";
    Editable = false;
    PageType = List;
    SourceTable = "NPR EFT Reconciliation";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(No; Rec."No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(ProviderCode; Rec."Provider Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Provider field';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field(AccountID; Rec."Account ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Account ID field';
                }
                field(AdvisID; Rec."Advis ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Advis ID field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(BankTransferDate; Rec."Bank Transfer Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Bank Transfer Date field';
                }
                field(TransactionAmount; Rec."Transaction Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Transaction Amount field';
                }
                field(TransactionFeeAmount; Rec."Transaction Fee Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Transaction Fee Amount field';
                }
            }
        }
    }

    actions
    {
    }
}

