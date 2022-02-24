page 6059836 "NPR EFT Recon. Provider Card"
{
    Extensible = False;
    Caption = 'EFT Recon. Provider Card';
    PageType = Card;
    SourceTable = "NPR EFT Recon. Provider";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
            group(PostingSetup)
            {
                Caption = 'Posting Setup';
                field(PostingDescription; Rec."Posting Description")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Posting Description field';
                }
                field(NoSeries; Rec."No. Series")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the No. Series field';
                }
                field(Posting; Rec.Posting)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Posting field';
                }
                field(JournalTemplateName; Rec."Journal Template Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Journal Template Name field';
                }
                field(JournalBatchName; Rec."Journal Batch Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Journal Batch Name field';
                }
                field(BankAccount; Rec."Bank Account")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Bank Account field';
                }
                field(TransaktionAccount; Rec."Transaktion Account")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Transaktion Account field';
                }
                field(FeeAccount; Rec."Fee Account")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Fee Account field';
                }
                field(ChargebackAccount; Rec."Chargeback Account")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Chargeback Account field';
                }
                field(SubscriptionAccount; Rec."Subscription Account")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Subscription Account field';
                }
                field(AdjustmentAccount; Rec."Adjustment Account")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Adjustment Account field';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Import)
            {
                Caption = 'Import';
                action(ImportHandlers)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Handlers';
                    Image = Import;
                    RunObject = Page "NPR EFT Recon. Subscribers";
                    RunPageLink = "Provider Code" = field(Code);
                    RunPageView = sorting("Provider Code", Type, "Subscriber Codeunit ID", "Subscriber Function")
                                  where(Type = const(Import));
                    ToolTip = 'Executes the Handlers action';
                }
            }
            group(Matching)
            {
                Caption = 'Matching';
                action(MatchingHandlers)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Handlers';
                    Image = Reconcile;
                    RunObject = Page "NPR EFT Recon. Subscribers";
                    RunPageLink = "Provider Code" = field(Code);
                    RunPageView = sorting("Provider Code", Type, "Subscriber Codeunit ID", "Subscriber Function")
                                  where(Type = const(Matching));
                    ToolTip = 'Executes the Handlers action';
                }
                action(MatchingSetup)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Setup';
                    Image = SuggestReconciliationLines;
                    RunObject = Page "NPR EFT Recon. Match List";
                    RunPageLink = "Provider Code" = field(Code);
                    RunPageView = sorting(Type, "Provider Code", ID)
                                  where(Type = const(Match));
                    ToolTip = 'Executes the Setup action';
                }
            }
            group(Score)
            {
                Caption = 'Score';
                action(ScoreSetup)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Setup';
                    Image = Setup;
                    RunObject = Page "NPR EFT Recon. Match List";
                    RunPageLink = "Provider Code" = field(Code);
                    RunPageView = sorting(Type, "Provider Code", ID)
                                  where(Type = const(Score));
                    ToolTip = 'Executes the Setup action';
                }
            }
        }
    }
}

