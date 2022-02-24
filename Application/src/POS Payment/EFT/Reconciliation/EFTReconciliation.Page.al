page 6059809 "NPR EFT Reconciliation"
{
    Extensible = False;
    Caption = 'EFT Reconciliation';
    PageType = Card;
    SourceTable = "NPR EFT Reconciliation";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                Editable = AllowEdit;
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
                field(AccountID; Rec."Account ID")
                {
                    ApplicationArea = NPRRetail;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Account ID field';
                }
                field(AdvisID; Rec."Advis ID")
                {
                    ApplicationArea = NPRRetail;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Advis ID field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field(BankInformation; Rec."Bank Information")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Bank Information field';
                }
                field(BankAmount; Rec."Bank Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Bank Amount field';
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
                field(FirstTransactionDate; Rec."First Transaction Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the First Transaction Date field';
                }
                field(LastTransactionDate; Rec."Last Transaction Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Last Transaction Date field';
                }
                group(Control6014420)
                {
                    ShowCaption = false;
                    grid(Control6014421)
                    {
                        group(Control6014422)
                        {
                            Caption = ' ';
                            label(Amount)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = 'Amount';
                                Editable = false;
                                ShowCaption = false;
                            }
                            label(Fee)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = 'Fee';
                                ShowCaption = false;
                            }
                            label(NoofLinesLbl)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = 'No. of Lines';
                                ShowCaption = false;
                            }
                        }
                        group(Total)
                        {
                            Caption = 'Total';
                            field(LineAmount; Rec."Line Amount")
                            {
                                ApplicationArea = NPRRetail;
                                Caption = 'Amount';
                                ShowCaption = false;
                                ToolTip = 'Specifies the value of the Amount field';
                            }
                            field(FeeAmount; Rec."Line Fee Amount")
                            {
                                ApplicationArea = NPRRetail;
                                Caption = 'Fee Amount';
                                ShowCaption = false;
                                ToolTip = 'Specifies the value of the Fee Amount field';
                            }
                            field(NoOfLines; Rec."No. Of Lines")
                            {
                                ApplicationArea = NPRRetail;
                                ShowCaption = false;
                                ToolTip = 'Specifies the value of the No. Of Lines field';
                            }
                        }
                        group(Applied)
                        {
                            Caption = 'Applied';
                            field(AppliedAmount; Rec."Applied Amount")
                            {
                                ApplicationArea = NPRRetail;
                                ShowCaption = false;
                                ToolTip = 'Specifies the value of the Applied Amount field';
                            }
                            field(AppliedFeeAmount; Rec."Applied Fee Amount")
                            {
                                ApplicationArea = NPRRetail;
                                ShowCaption = false;
                                ToolTip = 'Specifies the value of the Applied Fee Amount field';
                            }
                            field(NoOfAppliedLines; Rec."No. Of Applied Lines")
                            {
                                ApplicationArea = NPRRetail;
                                ShowCaption = false;
                                ToolTip = 'Specifies the value of the No. Of Applied Lines field';
                            }
                        }
                    }
                }
            }
            part(ReconLines; "NPR EFT Recon. Lines")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Lines';
                Editable = AllowEdit;
                SubPageLink = "Reconciliation No." = field("No.");
            }
            part(BankAmounts; "NPR EFT Recon. Bank Amounts")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Bank Amounts';
                Editable = AllowEdit;
                SubPageLink = "Reconciliation No." = field("No.");
                SubPageView = sorting("Reconciliation No.", "Application Account ID");
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(ImportActionGroup)
            {
                Caption = 'Import';
                action(ImportFile)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Import File';
                    Image = ImportDatabase;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Executes the Import File action';

                    trigger OnAction()
                    var
                        EFTReconciliationMgt: Codeunit "NPR EFT Reconciliation Mgt.";
                    begin
                        EFTReconciliationMgt.ImportReconciliationFile(Rec);
                    end;
                }
            }
            group(MatchActionGroup)
            {
                Caption = 'Matching';
                action(MatchAutomatically)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Match Automatically';
                    Image = MapAccounts;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Executes the Match Automatically action';

                    trigger OnAction()
                    var
                        EFTReconciliationMgt: Codeunit "NPR EFT Reconciliation Mgt.";
                    begin
                        EFTReconciliationMgt.MatchReconciliation(Rec);
                    end;
                }
                action(MatchManually)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Match Manually';
                    Image = CheckRulesSyntax;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    RunObject = Page "NPR EFT Recon. Matching";
                    RunPageLink = "Reconciliation No." = field("No.");
                    RunPageView = sorting("Reconciliation No.", "Line No.");
                    ToolTip = 'Executes the Match Manually action';
                }
            }
            group(PostActionGroup)
            {
                action(Post)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Post';
                    Image = PostOrder;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Executes the Post action';

                    trigger OnAction()
                    var
                        EFTReconciliationMgt: Codeunit "NPR EFT Reconciliation Mgt.";
                    begin
                        EFTReconciliationMgt.PostReconciliation(Rec);
                    end;
                }
            }
        }
        area(navigation)
        {
            group(Handlers)
            {
                Caption = 'Handlers';
                action(ImportHandlers)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Import Handlers';
                    Image = Import;
                    RunObject = Page "NPR EFT Recon. Subscribers";
                    RunPageLink = "Provider Code" = field("Provider Code");
                    RunPageView = sorting("Provider Code", Type, "Subscriber Codeunit ID", "Subscriber Function")
                                  where(Type = const(Import));
                    ToolTip = 'Executes the Import Handlers action';
                }
                action(MatchingHandlers)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Matching Handlers';
                    Image = Reconcile;
                    RunObject = Page "NPR EFT Recon. Subscribers";
                    RunPageLink = "Provider Code" = field("Provider Code");
                    RunPageView = sorting("Provider Code", Type, "Subscriber Codeunit ID", "Subscriber Function")
                                  where(Type = const(Matching));
                    ToolTip = 'Executes the Matching Handlers action';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        AllowEdit := Rec.Status <> Rec.Status::Posted;
    end;

    trigger OnOpenPage()
    begin
        AllowEdit := true;
    end;

    var
        AllowEdit: Boolean;
}

