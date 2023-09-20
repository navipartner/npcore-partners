page 6059818 "NPR EFT Reconciliation List"
{
    Extensible = False;
    Caption = 'EFT Reconciliation List';
    ContextSensitiveHelpPage = 'docs/retail/eft/how-to/reconciliation/';
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
                    ToolTip = 'Specifies the number of the EFT reconciliation';
                }
                field(ProviderCode; Rec."Provider Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the provider of the EFT reconciliation';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the status of the EFT Reconciliation';
                }
                field(AccountID; Rec."Account ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the account id of the EFT reconciliation';
                }
                field(AdvisID; Rec."Advis ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Advis ID used for EFT reconciliation.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the description of the EFT reconciliation';
                }
                field(BankTransferDate; Rec."Bank Transfer Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the bank transfer date of the EFT reconciliation';
                }
                field(TransactionAmount; Rec."Transaction Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the transaction amount of the EFT reconciliation';
                }
                field(TransactionFeeAmount; Rec."Transaction Fee Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the transaction fee amount of the EFT reconciliation';
                }
            }
        }
    }

    actions
    {
    }
}

