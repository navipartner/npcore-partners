page 6059840 "NPR EFT Recon. Bank Amounts"
{
    Extensible = False;
    Caption = 'EFT Recon. Bank Amounts';
    PageType = ListPart;
    SourceTable = "NPR EFT Recon. Bank Amount";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(ApplicationAccountID; Rec."Application Account ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Application Account ID field';
                }
                field(BankInformation; Rec."Bank Information")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Bank Information field';
                }
                field(BankTransferDate; Rec."Bank Transfer Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Bank Transfer Date field';
                }
                field(BankAmount; Rec."Bank Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Bank Amount field';
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
                field(ChargebackAmount; Rec."Chargeback Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Chargeback Amount field';
                }
                field(SubscriptionAmount; Rec."Subscription Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Subscription Amount field';
                }
                field(AdjustmentAmount; Rec."Adjustment Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Adjustment Amount field';
                }
                field(GlobalDimension1Code; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                }
                field(GlobalDimension2Code; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                }
                field(ExcludefromPosting; Rec."Exclude from Posting")
                {
                    ApplicationArea = NPRRetail;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Exclude from Posting field';
                }
                field(LineAmount; Rec."Line Amount")
                {
                    ApplicationArea = NPRRetail;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line Amount field';
                }
                field(LineFeeAmount; Rec."Line Fee Amount")
                {
                    ApplicationArea = NPRRetail;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line Fee Amount field';
                }
                field(AppliedAmount; Rec."Applied Amount")
                {
                    ApplicationArea = NPRRetail;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Applied Amount field';
                }
                field(AppliedFeeAmount; Rec."Applied Fee Amount")
                {
                    ApplicationArea = NPRRetail;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Applied Fee Amount field';
                }
                field(NoOfLines; Rec."No. Of Lines")
                {
                    ApplicationArea = NPRRetail;
                    Visible = false;
                    ToolTip = 'Specifies the value of the No. Of Lines field';
                }
                field(NoOfAppliedLines; Rec."No. Of Applied Lines")
                {
                    ApplicationArea = NPRRetail;
                    Visible = false;
                    ToolTip = 'Specifies the value of the No. Of Applied Lines field';
                }
            }
        }
    }

    actions
    {
    }
}

