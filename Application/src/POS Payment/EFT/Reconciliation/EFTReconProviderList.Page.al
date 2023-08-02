page 6059837 "NPR EFT Recon. Provider List"
{
    Extensible = false;
    Caption = 'EFT Recon. Provider List';
    ContextSensitiveHelpPage = 'docs/retail/eft/how-to/reconciliation/';
    CardPageId = "NPR EFT Recon. Provider Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR EFT Recon. Provider";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
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
        }
    }

    actions
    {
        area(Navigation)
        {
            action(ReconciliationList)
            {
                Caption = 'Reconciliations';
                ApplicationArea = NPRRetail;
                Image = Reconcile;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = page "NPR EFT Reconciliation List";
                RunPageLink = "Provider Code" = field(Code);
                ToolTip = 'View or create Reconciliations for this Provider';
            }
            group(Handlers)
            {
                Caption = 'Handlers';
                action(ImportHandlers)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Import Handlers';
                    Image = Import;
                    RunObject = page "NPR EFT Recon. Subscribers";
                    RunPageLink = "Provider Code" = field(Code);
                    RunPageView = sorting("Provider Code", Type, "Subscriber Codeunit ID", "Subscriber Function")
                                  where(Type = const(Import));
                    ToolTip = 'Executes the Import Handlers action';
                }
                action(MatchingHandlers)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Matching Handlers';
                    Image = Reconcile;
                    RunObject = page "NPR EFT Recon. Subscribers";
                    RunPageLink = "Provider Code" = field(Code);
                    RunPageView = sorting("Provider Code", Type, "Subscriber Codeunit ID", "Subscriber Function")
                                  where(Type = const(Matching));
                    ToolTip = 'Executes the Matching Handlers action';
                }
            }
            group(Setup)
            {
                Caption = 'Match and Score Setup';
                action(MatchingSetup)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Match';
                    Image = SuggestReconciliationLines;
                    RunObject = page "NPR EFT Recon. Match List";
                    RunPageLink = "Provider Code" = field(Code);
                    RunPageView = sorting(Type, "Provider Code", ID)
                                  where(Type = const(Match));
                    ToolTip = 'Shows the list of matching entries';
                }
                action(ScoreSetup)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Score';
                    Image = Setup;
                    RunObject = page "NPR EFT Recon. Match List";
                    RunPageLink = "Provider Code" = field(Code);
                    RunPageView = sorting(Type, "Provider Code", ID)
                                  where(Type = const(Score));
                    ToolTip = 'Shows the list of score entries';
                }

            }
        }
    }
}

