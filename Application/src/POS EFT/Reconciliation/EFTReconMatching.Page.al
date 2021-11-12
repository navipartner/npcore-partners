page 6059827 "NPR EFT Recon. Matching"
{
    PageType = Worksheet;
    SourceTable = "NPR EFT Recon. Line";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(Control6014412)
            {
                ShowCaption = false;
                grid(Control6014416)
                {
                    GridLayout = Columns;
                    group(Control6014418)
                    {
                        ShowCaption = false;
                        field(ScoreStatusText; ScoreStatusText)
                        {
                            ApplicationArea = NPRRetail;
                            Caption = 'Score status';
                            Editable = false;
                            ToolTip = 'Specifies the value of the ScoreStatusText field';
                        }
                    }
                }
            }
            group(Control6014414)
            {
                ShowCaption = false;
                field(ReconciliationNo; Rec."Reconciliation No.")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Reconciliation No. field';
                }
                field(TransactionDateFilter; TransactionDateFilter)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Transaction Date Filter';
                    ToolTip = 'Specifies the value of the Transaction Date Filter field';

                    trigger OnValidate()
                    begin
                        UpdateTransactionList();
                    end;
                }
                field(ShowMatched; ShowMatched)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Show Matched Lines';
                    ToolTip = 'Specifies the value of the Show Matched Lines field';

                    trigger OnValidate()
                    begin
                        SetShowMatchedFilter();
                        CurrPage.Update(false);
                    end;
                }
            }
            repeater(Group)
            {
                Editable = false;
                field(TransactionDate; Rec."Transaction Date")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Transaction Date field';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field(FeeAmount; Rec."Fee Amount")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Fee field';
                }
                field(ApplicationAccountID; Rec."Application Account ID")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Application Account ID field';
                }
                field(CardNumber; Rec."Card Number")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Card Number field';
                }
                field(ReferenceNumber; Rec."Reference Number")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Reference Number field';
                }
                field(HardwareID; Rec."Hardware ID")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Hardware ID field';
                }
                field(ShortcutDimension1Code; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = NPRRetail;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field';
                }
                field(ShortcutDimension2Code; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = NPRRetail;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field';
                }
                field(AppliedEntryNo; Rec."Applied Entry No.")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Applied Entry No. field';
                }
                field(AppliedAmount; Rec."Applied Amount")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Applied Amount field';
                }
                field(AppliedFeeAmount; Rec."Applied Fee Amount")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Applied Fee Amount field';
                }
            }
            part(TransactionRequest; "NPR EFT Recon. Trans. List")
            {
                ApplicationArea = NPRRetail;
                Editable = false;
                SubPageView = sorting("DCC Amount")
                              order(descending);
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Match)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Match';
                Image = Apply;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ShortCutKey = 'F9';
                ToolTip = 'Executes the Match action';

                trigger OnAction()
                var
                    EFTTransactionRequest: Record "NPR EFT Transaction Request";
                begin
                    CurrPage.TransactionRequest.Page.GetRecord(EFTTransactionRequest);
                    Rec.ApplyTransaction(EFTTransactionRequest);
                    CurrPage.Update(false);
                end;
            }
            action("Remove Match")
            {
                ApplicationArea = NPRRetail;
                Image = RemoveContacts;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ShortCutKey = 'Ctrl+F9';
                ToolTip = 'Executes the Remove Match action';

                trigger OnAction()
                begin
                    Rec.UnApply();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        if EFTReconciliation."No." <> Rec."Reconciliation No." then
            UpdateHeader();
        UpdateTransactionList();
    end;

    trigger OnOpenPage()
    begin
        if not ShowMatched then
            Rec.SetRange("Applied Entry No.", 0);
    end;

    var
        EFTReconciliation: Record "NPR EFT Reconciliation";
        TransactionDateFilter: Text;
        ShowMatched: Boolean;
        NoScoreSetup: Boolean;
        NoScoreSetupMsg: label 'No enabled Score Setup found for %1 %2';
        SetDateFilterErr: label 'Set a Transaction Date Filter';
        ScoreStatusText: Text;
        MaxScoreTxt: label 'Max. score is %1';

    local procedure UpdateHeader()
    var
        EFTReconMatchScore: Record "NPR EFT Recon. Match/Score";
        Date: Record Date;
        MaxScore: Decimal;
    begin
        EFTReconciliation.Get(Rec."Reconciliation No.");
        if (EFTReconciliation."First Transaction Date" <> 0D) and (EFTReconciliation."Last Transaction Date" <> 0D) then begin
            Date.SetRange("Period Start", EFTReconciliation."First Transaction Date", EFTReconciliation."Last Transaction Date");
            TransactionDateFilter := Date.GetFilter("Period Start");
        end;
        EFTReconMatchScore.SetRange(Type, EFTReconMatchScore.Type::Score);
        EFTReconMatchScore.SetRange("Provider Code", EFTReconciliation."Provider Code");
        EFTReconMatchScore.SetRange(Enabled, true);
        EFTReconMatchScore.SetAutocalcFields("Max. Additional Score");
        NoScoreSetup := not EFTReconMatchScore.FindSet();
        if NoScoreSetup then
            ScoreStatusText := StrSubstNo(NoScoreSetupMsg, EFTReconciliation.FieldCaption("Provider Code"), EFTReconciliation."Provider Code")
        else begin
            MaxScore := 0;
            repeat
                MaxScore += EFTReconMatchScore.Score + EFTReconMatchScore."Max. Additional Score";
            until EFTReconMatchScore.Next() = 0;
            ScoreStatusText := StrSubstNo(MaxScoreTxt, MaxScore);
        end;
    end;

    local procedure UpdateTransactionList()
    var
        TempEFTTransactionRequest: Record "NPR EFT Transaction Request" temporary;
    begin
        TempEFTTransactionRequest.DeleteAll();
        ReadTransactions(TempEFTTransactionRequest);
        TempEFTTransactionRequest.SetRange("Entry No.");
        CurrPage.TransactionRequest.Page.SetPageData(TempEFTTransactionRequest);
        TempEFTTransactionRequest.SetCurrentkey("DCC Amount");
        if TempEFTTransactionRequest.FindLast() then
            CurrPage.TransactionRequest.Page.SetRecord(TempEFTTransactionRequest);
    end;

    local procedure ReadTransactions(var TempEFTTransactionRequest: Record "NPR EFT Transaction Request" temporary)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTReconMatchScoreMgt: Codeunit "NPR EFT Rec. Match/Score Mgt.";
    begin
        if Rec."Line No." = 0 then
            exit;
        if Rec."Applied Entry No." <> 0 then begin
            if EFTTransactionRequest.Get(Rec."Applied Entry No.") then begin
                TempEFTTransactionRequest := EFTTransactionRequest;
                TempEFTTransactionRequest.Insert();
            end;
            exit;
        end;

        if not NoScoreSetup then begin
            EFTReconMatchScoreMgt.FindBestScore(EFTReconciliation, Rec, TransactionDateFilter, TempEFTTransactionRequest);
            exit;
        end;

        if TransactionDateFilter = '' then
            Error(SetDateFilterErr);
        EFTTransactionRequest.SetFilter("Transaction Date", TransactionDateFilter);
        if EFTTransactionRequest.FindSet() then
            repeat
                TempEFTTransactionRequest := EFTTransactionRequest;
                TempEFTTransactionRequest.Insert();
            until EFTTransactionRequest.Next() = 0;
    end;

    local procedure SetShowMatchedFilter()
    begin
        if ShowMatched then
            Rec.SetRange("Applied Entry No.")
        else
            Rec.SetRange("Applied Entry No.", 0);
    end;
}

