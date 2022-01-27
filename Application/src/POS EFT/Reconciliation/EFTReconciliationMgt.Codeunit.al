codeunit 6014671 "NPR EFT Reconciliation Mgt."
{
    Access = Internal;

    trigger OnRun()
    begin
    end;

    var
        NoImportHandlerErr: label 'No Import Handlers enabled.';
        NoMatchHandlerErr: label 'No Matching Handlers enabled.';
        ImportNotHandledErr: label 'No Import Handler was able to import.';
        DeleteOldDataQst: label 'Data is already imported. Delete existing data?';
        CreateJnlPostedConfirmText: label '%1 is %2.\%3';
        CreateJournalQst: label 'Do you want to create Journal Lines for the Reconciliation?';
        PostReconciliationQst: label 'Do you want to post the Reconciliation?';
        CreatingJournalText: label 'Creating Journallines..\@1@@@@@@@@@@@@';
        PostingText: label 'Posting...\@1@@@@@@@@@@@@';
        PostingDescriptionTxt: label 'Recon. %1 %2 - %3';
        JournalCreatedTxt: label 'Lines are inserted in Journal %1 %2.';
        JournalPostedTxt: label 'Transactions are posted.';


    procedure ImportReconciliationFile(var EFTReconciliation: Record "NPR EFT Reconciliation")
    var
        EFTReconLine: Record "NPR EFT Recon. Line";
        EFTReconBankAmount: Record "NPR EFT Recon. Bank Amount";
        EFTReconSubscriber: Record "NPR EFT Recon. Subscriber";
        Handled: Boolean;
    begin
        EFTReconciliation.CheckUnpostedStatus();
        if EFTReconciliation."No." <> '' then begin
            EFTReconLine.SetRange("Reconciliation No.", EFTReconciliation."No.");
            EFTReconBankAmount.SetRange("Reconciliation No.", EFTReconciliation."No.");
            if not (EFTReconLine.IsEmpty and EFTReconBankAmount.IsEmpty) then
                if GuiAllowed and Confirm(DeleteOldDataQst) then begin
                    EFTReconciliation."Bank Amount" := 0;
                    EFTReconciliation."Bank Information" := '';
                    EFTReconciliation."Bank Transfer Date" := 0D;
                    EFTReconciliation."Transaction Amount" := 0;
                    EFTReconciliation."Transaction Fee Amount" := 0;
                    EFTReconLine.DeleteAll(true);
                    EFTReconBankAmount.DeleteAll(true);
                end else
                    Error('');
        end;
        EFTReconciliation.TestField("Provider Code");
        EFTReconSubscriber.SetRange("Provider Code", EFTReconciliation."Provider Code");
        EFTReconSubscriber.SetRange(Type, EFTReconSubscriber.Type::Import);
        EFTReconSubscriber.SetRange(Enabled);
        EFTReconSubscriber.SetCurrentkey("Provider Code", Type, "Subscriber Codeunit ID", "Subscriber Function", "Sequence No.");
        if EFTReconSubscriber.IsEmpty then
            Error(NoImportHandlerErr);
        EFTReconSubscriber.FindSet();
        repeat
            OnImportReconciliationFile(EFTReconciliation, EFTReconSubscriber, Handled);
        until EFTReconSubscriber.Next() = 0;
        if not Handled then
            Error(ImportNotHandledErr);
        EFTReconciliation.Status := EFTReconciliation.Status::Reconciling;
        EFTReconciliation.Modify(true);
    end;


    procedure MatchReconciliation(EFTReconciliation: Record "NPR EFT Reconciliation")
    var
        EFTReconSubscriber: Record "NPR EFT Recon. Subscriber";
    begin
        EFTReconciliation.TestField("Provider Code");
        EFTReconSubscriber.SetRange("Provider Code", EFTReconciliation."Provider Code");
        EFTReconSubscriber.SetRange(Type, EFTReconSubscriber.Type::Matching);
        EFTReconSubscriber.SetRange(Enabled);
        EFTReconSubscriber.SetCurrentkey("Provider Code", Type, "Subscriber Codeunit ID", "Subscriber Function", "Sequence No.");
        if EFTReconSubscriber.IsEmpty then
            Error(NoMatchHandlerErr);
        EFTReconSubscriber.FindSet();
        repeat
            OnMatchReconciliation(EFTReconciliation, EFTReconSubscriber);
        until EFTReconSubscriber.Next() = 0;
    end;


    procedure PostReconciliation(EFTReconciliation: Record "NPR EFT Reconciliation")
    var
        EFTReconProvider: Record "NPR EFT Recon. Provider";
        EFTReconBankAmount: Record "NPR EFT Recon. Bank Amount";
        TempEFTReconBankAmount: Record "NPR EFT Recon. Bank Amount" temporary;
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        DocumentNo: Code[20];
        NextLineNo: Integer;
        Handled: Boolean;
        NoOfLines: Integer;
        LineCounter: Integer;
        Window: Dialog;
    begin
        if not ConfirmPost(EFTReconciliation) then
            exit;
        OnBeforePost(EFTReconciliation);

        OnPost(EFTReconciliation, Handled);
        if Handled then
            exit;

        EFTReconProvider.Get(EFTReconciliation."Provider Code");
        EFTReconProvider.TestField("Bank Account");
        EFTReconProvider.TestField("Transaktion Account");
        EFTReconProvider.TestField("Fee Account");

        if EFTReconProvider.Posting = EFTReconProvider.Posting::"Through Journal" then begin
            EFTReconProvider.TestField("Journal Template Name");
            EFTReconProvider.TestField("Journal Batch Name");
            GenJnlTemplate.Get(EFTReconProvider."Journal Template Name");
            GenJnlBatch.Get(EFTReconProvider."Journal Template Name", EFTReconProvider."Journal Batch Name");
            GenJnlLine.SetRange("Journal Template Name", EFTReconProvider."Journal Template Name");
            GenJnlLine.SetRange("Journal Batch Name", EFTReconProvider."Journal Batch Name");
            if GenJnlLine.FindLast() then begin
                if EFTReconProvider."No. Series" = GenJnlBatch."No. Series" then
                    DocumentNo := IncStr(GenJnlLine."Document No.");
                NextLineNo := GenJnlLine."Line No." + 10000
            end else
                NextLineNo := 10000;
            if (DocumentNo = '') and (GenJnlBatch."No. Series" <> '') then begin
                Clear(NoSeriesMgt);
                DocumentNo := NoSeriesMgt.TryGetNextNo(GenJnlBatch."No. Series", EFTReconciliation."Bank Transfer Date");
            end;
            if (DocumentNo = '') and (EFTReconProvider."No. Series" <> '') then begin
                Clear(NoSeriesMgt);
                DocumentNo := NoSeriesMgt.GetNextNo(EFTReconProvider."No. Series", EFTReconciliation."Bank Transfer Date", true);
            end;
        end;
        if EFTReconProvider.Posting = EFTReconProvider.Posting::Direct then begin
            EFTReconProvider.TestField("No. Series");
            Clear(NoSeriesMgt);
            DocumentNo := NoSeriesMgt.GetNextNo(EFTReconProvider."No. Series", EFTReconciliation."Bank Transfer Date", true);
        end;

        EFTReconBankAmount.SetRange("Reconciliation No.", EFTReconciliation."No.");
        EFTReconBankAmount.SetRange("Exclude from Posting", false);
        if GuiAllowed then begin
            NoOfLines := EFTReconBankAmount.Count;
            if EFTReconProvider.Posting = EFTReconProvider.Posting::"Through Journal" then
                Window.Open(CreatingJournalText)
            else
                Window.Open(PostingText);
        end;
        if EFTReconBankAmount.FindSet() then
            repeat
                LineCounter += 1;
                if GuiAllowed then
                    Window.Update(1, ROUND(LineCounter / NoOfLines * 10000, 1));

                SplitBankTransfer(EFTReconBankAmount, TempEFTReconBankAmount);
                TempEFTReconBankAmount.FindSet();
                repeat
                    PostBankTransfer(EFTReconciliation, EFTReconProvider, TempEFTReconBankAmount, GenJnlTemplate,
                                     GenJnlBatch, DocumentNo, NextLineNo, GenJnlPostLine);
                until TempEFTReconBankAmount.Next() = 0;
            until EFTReconBankAmount.Next() = 0;

        if EFTReconProvider.Posting = EFTReconProvider.Posting::"Through Journal" then
            Message(JournalCreatedTxt, EFTReconProvider."Journal Template Name", EFTReconProvider."Journal Batch Name")
        else
            Message(JournalPostedTxt);
        EFTReconciliation.Status := EFTReconciliation.Status::Posted;
        EFTReconciliation.Modify();
    end;

    local procedure PostBankTransfer(EFTReconciliation: Record "NPR EFT Reconciliation"; EFTReconProvider: Record "NPR EFT Recon. Provider"; TempEFTReconBankAmount: Record "NPR EFT Recon. Bank Amount" temporary; GenJnlTemplate: Record "Gen. Journal Template"; GenJnlBatch: Record "Gen. Journal Batch"; var DocumentNo: Code[20]; var NextLineNo: Integer; GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        GenJnlLine: Record "Gen. Journal Line";
        Handled: Boolean;
    begin
        OnPostBankTransfer(EFTReconciliation, EFTReconProvider, TempEFTReconBankAmount, GenJnlTemplate, GenJnlBatch, DocumentNo, NextLineNo, Handled);
        if Handled then
            exit;
        if TempEFTReconBankAmount."Bank Amount" <> 0 then begin
            InitJournalLine(EFTReconciliation."Bank Transfer Date", DocumentNo, GenJnlTemplate."Source Code", GenJnlBatch."Reason Code", GenJnlBatch."Posting No. Series", GenJnlLine);
            GenJnlLine.Validate("Account Type", GenJnlLine."account type"::"Bank Account");
            GenJnlLine.Validate("Account No.", EFTReconProvider."Bank Account");
            GenJnlLine.Validate(Amount, TempEFTReconBankAmount."Bank Amount");
            GenJnlLine.Description := CopyStr(MakePostingDescription(EFTReconciliation, EFTReconProvider), 1, MaxStrLen(GenJnlLine.Description));
            SetJournalLineDimension(TempEFTReconBankAmount, GenJnlLine);
            if EFTReconProvider.Posting = EFTReconProvider.Posting::"Through Journal" then
                InsertJournalLine(EFTReconProvider, GenJnlLine, NextLineNo)
            else
                GenJnlPostLine.RunWithCheck(GenJnlLine);
        end;

        if TempEFTReconBankAmount."Transaction Amount" <> 0 then begin
            InitJournalLine(EFTReconciliation."Bank Transfer Date", DocumentNo, GenJnlTemplate."Source Code", GenJnlBatch."Reason Code", GenJnlBatch."Posting No. Series", GenJnlLine);
            GenJnlLine.Validate("Account Type", GenJnlLine."account type"::"G/L Account");
            GenJnlLine.Validate("Account No.", EFTReconProvider."Transaktion Account");
            GenJnlLine.Validate(Amount, -TempEFTReconBankAmount."Transaction Amount");
            GenJnlLine.Description := CopyStr(MakePostingDescription(EFTReconciliation, EFTReconProvider), 1, MaxStrLen(GenJnlLine.Description));
            SetJournalLineDimension(TempEFTReconBankAmount, GenJnlLine);
            if EFTReconProvider.Posting = EFTReconProvider.Posting::"Through Journal" then
                InsertJournalLine(EFTReconProvider, GenJnlLine, NextLineNo)
            else
                GenJnlPostLine.RunWithCheck(GenJnlLine);
        end;

        if TempEFTReconBankAmount."Transaction Fee Amount" <> 0 then begin
            InitJournalLine(EFTReconciliation."Bank Transfer Date", DocumentNo, GenJnlTemplate."Source Code", GenJnlBatch."Reason Code", GenJnlBatch."Posting No. Series", GenJnlLine);
            GenJnlLine.Validate("Account Type", GenJnlLine."account type"::"G/L Account");
            GenJnlLine.Validate("Account No.", EFTReconProvider."Fee Account");
            GenJnlLine.Validate(Amount, -TempEFTReconBankAmount."Transaction Fee Amount");
            GenJnlLine.Description := CopyStr(MakePostingDescription(EFTReconciliation, EFTReconProvider), 1, MaxStrLen(GenJnlLine.Description));
            SetJournalLineDimension(TempEFTReconBankAmount, GenJnlLine);
            if EFTReconProvider.Posting = EFTReconProvider.Posting::"Through Journal" then
                InsertJournalLine(EFTReconProvider, GenJnlLine, NextLineNo)
            else
                GenJnlPostLine.RunWithCheck(GenJnlLine);
        end;
        if TempEFTReconBankAmount."Subscription Amount" <> 0 then begin
            EFTReconProvider.TestField("Subscription Account");
            InitJournalLine(EFTReconciliation."Bank Transfer Date", DocumentNo, GenJnlTemplate."Source Code", GenJnlBatch."Reason Code", GenJnlBatch."Posting No. Series", GenJnlLine);
            GenJnlLine.Validate("Account Type", GenJnlLine."account type"::"G/L Account");
            GenJnlLine.Validate("Account No.", EFTReconProvider."Subscription Account");
            GenJnlLine.Validate(Amount, -TempEFTReconBankAmount."Subscription Amount");
            GenJnlLine.Description := CopyStr(MakePostingDescription(EFTReconciliation, EFTReconProvider), 1, MaxStrLen(GenJnlLine.Description));
            SetJournalLineDimension(TempEFTReconBankAmount, GenJnlLine);
            if EFTReconProvider.Posting = EFTReconProvider.Posting::"Through Journal" then
                InsertJournalLine(EFTReconProvider, GenJnlLine, NextLineNo)
            else
                GenJnlPostLine.RunWithCheck(GenJnlLine);
        end;

        if TempEFTReconBankAmount."Adjustment Amount" <> 0 then begin
            EFTReconProvider.TestField("Adjustment Account");
            InitJournalLine(EFTReconciliation."Bank Transfer Date", DocumentNo, GenJnlTemplate."Source Code", GenJnlBatch."Reason Code", GenJnlBatch."Posting No. Series", GenJnlLine);
            GenJnlLine.Validate("Account Type", GenJnlLine."account type"::"G/L Account");
            GenJnlLine.Validate("Account No.", EFTReconProvider."Adjustment Account");
            GenJnlLine.Validate(Amount, -TempEFTReconBankAmount."Adjustment Amount");
            GenJnlLine.Description := CopyStr(MakePostingDescription(EFTReconciliation, EFTReconProvider), 1, MaxStrLen(GenJnlLine.Description));
            SetJournalLineDimension(TempEFTReconBankAmount, GenJnlLine);
            if EFTReconProvider.Posting = EFTReconProvider.Posting::"Through Journal" then
                InsertJournalLine(EFTReconProvider, GenJnlLine, NextLineNo)
            else
                GenJnlPostLine.RunWithCheck(GenJnlLine);
        end;

        if TempEFTReconBankAmount."Chargeback Amount" <> 0 then begin
            EFTReconProvider.TestField("Chargeback Account");
            InitJournalLine(EFTReconciliation."Bank Transfer Date", DocumentNo, GenJnlTemplate."Source Code", GenJnlBatch."Reason Code", GenJnlBatch."Posting No. Series", GenJnlLine);
            GenJnlLine.Validate("Account Type", GenJnlLine."account type"::"G/L Account");
            GenJnlLine.Validate("Account No.", EFTReconProvider."Chargeback Account");
            GenJnlLine.Validate(Amount, -TempEFTReconBankAmount."Chargeback Amount");
            GenJnlLine.Description := CopyStr(MakePostingDescription(EFTReconciliation, EFTReconProvider), 1, MaxStrLen(GenJnlLine.Description));
            SetJournalLineDimension(TempEFTReconBankAmount, GenJnlLine);
            if EFTReconProvider.Posting = EFTReconProvider.Posting::"Through Journal" then
                InsertJournalLine(EFTReconProvider, GenJnlLine, NextLineNo)
            else
                GenJnlPostLine.RunWithCheck(GenJnlLine);
        end;
    end;

    local procedure InitJournalLine(PostingDate: Date; DocumentNo: Code[20]; SourceCode: Code[10]; ReasonCode: Code[10]; PostingNoSeries: Code[10]; var GenJnlLine: Record "Gen. Journal Line")
    begin
        GenJnlLine.Init();
        GenJnlLine."Source Code" := SourceCode;
        GenJnlLine."Reason Code" := ReasonCode;
        GenJnlLine."Posting No. Series" := PostingNoSeries;
        GenJnlLine.Validate("Document No.", DocumentNo);
        GenJnlLine."Document Type" := Enum::"Gen. Journal Document Type".FromInteger(0);
        GenJnlLine.Validate("Posting Date", PostingDate);
    end;

    local procedure SetJournalLineDimension(TempEFTReconBankAmount: Record "NPR EFT Recon. Bank Amount" temporary; var GenJnlLine: Record "Gen. Journal Line")
    begin
        GenJnlLine."Shortcut Dimension 1 Code" := TempEFTReconBankAmount."Global Dimension 1 Code";
        GenJnlLine."Shortcut Dimension 2 Code" := TempEFTReconBankAmount."Global Dimension 2 Code";
        GenJnlLine."Dimension Set ID" := TempEFTReconBankAmount."Dimension Set ID";
    end;

    local procedure InsertJournalLine(EFTReconProvider: Record "NPR EFT Recon. Provider"; var GenJnlLine: Record "Gen. Journal Line"; var NextLineNo: Integer)
    begin
        GenJnlLine.Validate("Journal Template Name", EFTReconProvider."Journal Template Name");
        GenJnlLine.Validate("Journal Batch Name", EFTReconProvider."Journal Batch Name");
        GenJnlLine."Line No." := NextLineNo;
        NextLineNo += 10000;
        GenJnlLine.Insert(true);
    end;

    local procedure ConfirmPost(EFTReconciliation: Record "NPR EFT Reconciliation"): Boolean
    var
        EFTReconProvider: Record "NPR EFT Recon. Provider";
    begin
        EFTReconProvider.Get(EFTReconciliation."Provider Code");

        case EFTReconProvider.Posting of
            EFTReconProvider.Posting::"Through Journal":
                begin
                    if EFTReconciliation.Status = EFTReconciliation.Status::Posted then begin
                        if not Confirm(StrSubstNo(CreateJnlPostedConfirmText,
                                        EFTReconciliation.TableCaption, EFTReconciliation.Status, CreateJournalQst)) then
                            exit(false);
                    end else begin
                        if not Confirm(CreateJournalQst) then
                            exit(false);
                    end;
                end;
            EFTReconProvider.Posting::Direct:
                begin
                    EFTReconciliation.CheckUnpostedStatus();
                    if not Confirm(PostReconciliationQst) then
                        exit(false);
                end;
        end;
        exit(true);
    end;

    local procedure SplitBankTransfer(EFTReconBankAmount: Record "NPR EFT Recon. Bank Amount"; var TempEFTReconBankAmount: Record "NPR EFT Recon. Bank Amount" temporary)
    var
        Handled: Boolean;
    begin
        TempEFTReconBankAmount.DeleteAll(false);
        OnSplitBankTransfer(EFTReconBankAmount, TempEFTReconBankAmount, Handled);
        if not Handled then begin
            TempEFTReconBankAmount := EFTReconBankAmount;
            TempEFTReconBankAmount.Insert(false);
        end;
    end;


    procedure GetPublisherFunction(Type: Option Import,Match): Text[80]
    begin
        case Type of
            Type::Import:
                exit('OnImportReconciliationFile');
            Type::Match:
                exit('OnMatchReconciliation');
        end;
    end;

    local procedure MakePostingDescription(EFTReconciliation: Record "NPR EFT Reconciliation"; EFTReconProvider: Record "NPR EFT Recon. Provider"): Text
    begin
        if EFTReconProvider."Posting Description" <> '' then
            exit(StrSubstNo(EFTReconProvider."Posting Description", EFTReconciliation."No.", EFTReconciliation."First Transaction Date", EFTReconciliation."Last Transaction Date"))
        else
            exit(StrSubstNo(PostingDescriptionTxt, EFTReconciliation."No.", EFTReconciliation."First Transaction Date", EFTReconciliation."Last Transaction Date"));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnImportReconciliationFile(var EFTReconciliation: Record "NPR EFT Reconciliation"; EFTReconSubscriber: Record "NPR EFT Recon. Subscriber"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnMatchReconciliation(var EFTReconciliation: Record "NPR EFT Reconciliation"; EFTReconSubscriber: Record "NPR EFT Recon. Subscriber")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePost(var EFTReconciliation: Record "NPR EFT Reconciliation")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPost(var EFTReconciliation: Record "NPR EFT Reconciliation"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSplitBankTransfer(var EFTReconBankAmount: Record "NPR EFT Recon. Bank Amount"; var TempEFTReconBankAmount: Record "NPR EFT Recon. Bank Amount" temporary; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostBankTransfer(EFTReconciliation: Record "NPR EFT Reconciliation"; EFTReconProvider: Record "NPR EFT Recon. Provider"; var TempEFTReconBankAmount: Record "NPR EFT Recon. Bank Amount" temporary; GenJnlTemplate: Record "Gen. Journal Template"; GenJnlBatch: Record "Gen. Journal Batch"; var DocumentNo: Code[20]; var NextLineNo: Integer; var Handled: Boolean)
    begin
    end;
}

