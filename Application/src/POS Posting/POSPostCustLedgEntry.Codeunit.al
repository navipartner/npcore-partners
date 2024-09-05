codeunit 6184983 "NPR POS Post Cust. Ledg. Entry"
{
    Access = Internal;

#if not (BC17 or BC18 or BC19)
    internal procedure InsertGenJournalLinesForCustLedgEntryPosting(var GenJournalLine: Record "Gen. Journal Line"; var LineNumber: Integer; POSEntry: Record "NPR POS Entry")
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        Customer: Record Customer;
    begin
        if POSEntry."Customer No." = '' then
            exit;

        if not GetPOSPostingProfile(POSPostingProfile, POSEntry) then
            exit;

        if not POSPostingProfile."Enable POS Entry CLE Posting" then
            exit;

        Customer.Get(POSEntry."Customer No.");
        if (Customer."VAT Registration No." <> '') and (not POSPostingProfile."Enable Legal Ent. CLE Posting") then
            exit;

        ProcessPOSEntry(GenJournalLine, LineNumber, POSEntry, POSPostingProfile."General Journal Batch Name", POSPostingProfile."Journal Template Name");
    end;

    local procedure GetPOSPostingProfile(var POSPostingProfile: Record "NPR POS Posting Profile"; POSEntry: Record "NPR POS Entry"): Boolean
    var
        POSStore: Record "NPR POS Store";
    begin
        POSStore.Get(POSEntry."POS Store Code");
        if POSStore."POS Posting Profile" = '' then
            exit(false);
        exit(POSPostingProfile.Get(POSStore."POS Posting Profile"));
    end;

    local procedure ProcessPOSEntry(var GenJournalLine: Record "Gen. Journal Line"; var LineNumber: Integer; POSEntry: Record "NPR POS Entry"; BatchName: Code[10]; TemplateName: Code[10])
    begin
        POSEntry.CalcFields("Payment Amount");
        if POSEntry."Payment Amount" > 0 then
            ProcessPositivePOSSale(GenJournalLine, LineNumber, POSEntry, BatchName, TemplateName)
        else
            ProcessNegativePOSSale(GenJournalLine, LineNumber, POSEntry, BatchName, TemplateName);
    end;

    local procedure ProcessPositivePOSSale(var GenJournalLine: Record "Gen. Journal Line"; var LineNumber: Integer; POSEntry: Record "NPR POS Entry"; BatchName: Code[10]; TemplateName: Code[10])
    begin
        CreateGenJournalLine(GenJournalLine, LineNumber, POSEntry, GenJournalLine."Document Type"::Payment, BatchName, TemplateName);
        CreateGenJournalLine(GenJournalLine, LineNumber, POSEntry, GenJournalLine."Document Type"::Invoice, BatchName, TemplateName);
    end;

    local procedure ProcessNegativePOSSale(var GenJournalLine: Record "Gen. Journal Line"; var LineNumber: Integer; POSEntry: Record "NPR POS Entry"; BatchName: Code[10]; TemplateName: Code[10])
    begin
        CreateGenJournalLine(GenJournalLine, LineNumber, POSEntry, GenJournalLine."Document Type"::Refund, BatchName, TemplateName);
        CreateGenJournalLine(GenJournalLine, LineNumber, POSEntry, GenJournalLine."Document Type"::"Credit Memo", BatchName, TemplateName);
    end;

    local procedure CreateGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; var LineNumber: Integer; POSEntry: Record "NPR POS Entry"; GenJournalDocumentType: Enum "Gen. Journal Document Type";
                                            BatchName: Code[10]; TemplateName: Code[10])
    begin
        LineNumber += 10000;
        GenJournalLine.Init();
        GenJournalLine."Line No." := LineNumber;
        GenJournalLine."Journal Template Name" := TemplateName;
        GenJournalLine."Journal Batch Name" := BatchName;
        GenJournalLine."Document Type" := GenJournalDocumentType;
        GenJournalLine."Document No." := POSEntry."Document No.";
        GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
        GenJournalLine.Validate("Account No.", POSEntry."Customer No.");

        if GenJournalDocumentType in [GenJournalLine."Document Type"::Payment, GenJournalLine."Document Type"::Refund] then
            GenJournalLine.Validate("Credit Amount", POSEntry."Payment Amount")
        else
            GenJournalLine.Validate("Debit Amount", POSEntry."Amount Incl. Tax");

        GenJournalLine."Posting Date" := Today();
        GenJournalLine."VAT Reporting Date" := POSEntry."Posting Date";
        GenJournalLine.Description := POSEntry.Description;
        GenJournalLine.ValidateShortcutDimCode(1, GenJournalLine."Shortcut Dimension 1 Code");
        GenJournalLine.ValidateShortcutDimCode(2, GenJournalLine."Shortcut Dimension 2 Code");
        GenJournalLine.Insert();
    end;

    internal procedure CloseCustLedgerEntries(var POSEntry: Record "NPR POS Entry"; StopOnErrorVar: Boolean)
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        if not GetPOSPostingProfile(POSPostingProfile, POSEntry) then
            exit;

        if not POSPostingProfile."Enable POS Entry CLE Posting" then
            exit;

        POSEntry.FindSet();
        repeat
            if POSEntry."Customer No." <> '' then
                CloseEntries(POSEntry, POSPostingProfile."Enable Legal Ent. CLE Posting", StopOnErrorVar)
        until POSEntry.Next() = 0;
    end;

    local procedure CloseEntries(POSEntry: Record "NPR POS Entry"; LegalEntityPostingEnabled: Boolean; StopOnErrorVar: Boolean)
    var
        Customer: Record Customer;
    begin
        Customer.Get(POSEntry."Customer No.");
        if (Customer."VAT Registration No." <> '') and (not LegalEntityPostingEnabled) then
            exit;

        POSEntry.CalcFields("Payment Amount");
        if POSEntry."Payment Amount" > 0 then
            CloseEntriesForDocumentType(POSEntry, "Gen. Journal Document Type"::Payment, "Gen. Journal Document Type"::Invoice, StopOnErrorVar)
        else
            CloseEntriesForDocumentType(POSEntry, "Gen. Journal Document Type"::Refund, "Gen. Journal Document Type"::"Credit Memo", StopOnErrorVar);
    end;

    local procedure CloseEntriesForDocumentType(POSEntry: Record "NPR POS Entry"; GenJournalDocumentType: Enum "Gen. Journal Document Type"; ApplyToDocumentType: Enum "Gen. Journal Document Type"; StopOnErrorVar: Boolean)
    var
        TempApplyUnapplyParameters: Record "Apply Unapply Parameters" temporary;
        ApplyCustLedgerEntry: Record "Cust. Ledger Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GLSetup: Record "General Ledger Setup";
        CustEntrySetApplID: Codeunit "Cust. Entry-SetAppl.ID";
        CustEntryApplyPostedEntries: Codeunit "CustEntry-Apply Posted Entries";
    begin
        ClearAppliesToId();

        CustLedgerEntry.SetRange("Document Type", GenJournalDocumentType);
        CustLedgerEntry.SetRange("Document No.", POSEntry."Document No.");
        CustLedgerEntry.SetRange("Customer No.", POSEntry."Customer No.");
        CustLedgerEntry.SetRange(Open, true);
        if not CustLedgerEntry.FindFirst() then
            exit;

        CustLedgerEntry."Applying Entry" := true;
        if CustLedgerEntry."Applies-to ID" = '' then
            CustLedgerEntry."Applies-to ID" := AppliesToID;
        CustLedgerEntry.CalcFields("Remaining Amount");
        if CustLedgerEntry."Remaining Amount" = 0 then
            exit;
        CustLedgerEntry."Amount to Apply" := CustLedgerEntry."Remaining Amount";
        CustLedgerEntry.Modify();
        TempApplyUnapplyParameters.CopyFromCustLedgEntry(CustLedgerEntry);

        ApplyCustLedgerEntry.SetRange("Document Type", ApplyToDocumentType);
        ApplyCustLedgerEntry.SetRange("Document No.", POSEntry."Document No.");
        ApplyCustLedgerEntry.SetRange("Customer No.", POSEntry."Customer No.");
        ApplyCustLedgerEntry.SetRange(Open, true);
        if not ApplyCustLedgerEntry.IsEmpty() then begin
            CustEntrySetApplID.SetApplId(ApplyCustLedgerEntry, CustLedgerEntry, AppliesToID);
            GLSetup.Get();
            if GLSetup."Journal Templ. Name Mandatory" then begin
                TempApplyUnapplyParameters."Journal Template Name" := GLSetup."Apply Jnl. Template Name";
                TempApplyUnapplyParameters."Journal Batch Name" := GLSetup."Apply Jnl. Batch Name";
            end;
            if not CustEntryApplyPostedEntries.Apply(CustLedgerEntry, TempApplyUnapplyParameters) and StopOnErrorVar then
                Error(GetLastErrorText());
        end;

        ClearAppliesToId();
    end;

    local procedure ClearAppliesToId()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Applies-to ID", AppliesToID);
        if CustLedgerEntry.IsEmpty() then
            exit;
        CustLedgerEntry.ModifyAll("Applies-to ID", '');
    end;

    var
        AppliesToID: Label 'PREV', Locked = true;

#endif
}