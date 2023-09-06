codeunit 6151410 "NPR Prepayment Subs."
{
    Access = Internal;

#IF NOT (BC17 or BC18 or BC19)
    var
        PrepaymentMgt: Codeunit "NPR Prepayment Mgt.";
        RSLocalisationMgt: Codeunit "NPR RS Localisation Mgt.";

    #region Purchase Prepayment
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterGetVendorPayablesAccount', '', false, false)]
    local procedure OnAfterGetVendorPayablesAccount(GenJournalLine: Record "Gen. Journal Line"; VendorPostingGroup: Record "Vendor Posting Group"; var PayablesAccount: Code[20]);
    begin
        if not RSLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        PrepaymentMgt.SetPayablesAccount(GenJournalLine, VendorPostingGroup, PayablesAccount);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromPurchHeader', '', false, false)]
    local procedure OnAfterCopyGenJnlLineFromPurchHeader(PurchaseHeader: Record "Purchase Header"; var GenJournalLine: Record "Gen. Journal Line");
    var
        RSPurchaseHeader: Record "NPR RS Purchase Header";
    begin
        if not RSLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        RSPurchaseHeader.Read(PurchaseHeader.SystemId);
        GenJournalLine.Prepayment := RSPurchaseHeader."Prepayment";
    end;
    #endregion

    #region Sales Prepayment
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post Prepayments", 'OnAfterPostPrepayments', '', false, false)]
    local procedure OnAfterPostPrepayments(var SalesHeader: Record "Sales Header"; DocumentType: Option; CommitIsSuppressed: Boolean; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var CustLedgerEntry: Record "Cust. Ledger Entry");
    begin
        if not RSLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        PrepaymentMgt.SaveBankEntryNoOnPrepaymentPosting(SalesHeader, DocumentType, SalesInvoiceHeader);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterDeleteEvent(var Rec: Record "Sales Header")
    begin
        if Rec.IsTemporary() then
            exit;
        if not RSLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        PrepaymentMgt.DeleteSalesBankEntryRelation(Rec."No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post Prepayments", 'OnAfterApplyFilter', '', false, false)]
    local procedure OnAfterApplyFilter(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; DocumentType: Option);
    begin
        if not RSLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        PrepaymentMgt.SetAdditionalFiltersOnSalesLine(SalesLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post Prepayments", 'OnBeforeFillInvLineBuffer', '', false, false)]
    local procedure OnBeforeFillInvLineBuffer(var PrepaymentInvLineBuffer: Record "Prepayment Inv. Line Buffer"; SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line");
    begin
        if not RSLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        SalesHeader.TestField("Compress Prepayment", true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post Prepayments", 'OnBeforeCreateLinesFromBuffer', '', false, false)]
    local procedure OnBeforeCreateLinesFromBuffer(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var TempGlobalPrepmtInvLineBuf: Record "Prepayment Inv. Line Buffer" temporary; var LineCount: Integer; var SalesInvHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var PostedDocTabNo: Integer; DocumentType: Option; var LastLineNo: Integer; GenJnlLineDocNo: Code[20]; var IsHandled: Boolean);
    begin
        if not RSLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        PrepaymentMgt.RoundAmountsBeforePostingOfPrepaymentCrMemo(SalesHeader, TempGlobalPrepmtInvLineBuf);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeFinalizePosting', '', false, false)]
    local procedure OnBeforeFinalizePosting(var Sender: Codeunit "Sales-Post"; var SalesHeader: Record "Sales Header"; var TempSalesLineGlobal: Record "Sales Line" temporary; var EverythingInvoiced: Boolean; SuppressCommit: Boolean; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line");
    var
        RSSalesHeader: Record "NPR RS Sales Header";
    begin
        if not RSLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        RSSalesHeader.Read(SalesHeader.SystemId);
        if SalesHeader."Prepayment %" = 0 then begin
            Clear(RSSalesHeader."Applies-to Bank Entry");
            RSSalesHeader.Save();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post Prepayments", 'OnAfterPostCustomerEntry', '', false, false)]
    local procedure SalesPostPrepayments_OnAfterPostCustomerEntry(var GenJnlLine: Record "Gen. Journal Line"; TotalPrepmtInvLineBuffer: Record "Prepayment Inv. Line Buffer"; TotalPrepmtInvLineBufferLCY: Record "Prepayment Inv. Line Buffer"; CommitIsSuppressed: Boolean);
    begin
        if not RSLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        PrepaymentMgt.CloseEntriesForCrMemo(GenJnlLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostCustomerEntry', '', false, false)]
    local procedure OnAfterPostCustomerEntry(var GenJnlLine: Record "Gen. Journal Line"; var SalesHeader: Record "Sales Header"; var TotalSalesLine: Record "Sales Line"; var TotalSalesLineLCY: Record "Sales Line"; CommitIsSuppressed: Boolean; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line");
    begin
        if not RSLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        PrepaymentMgt.RebalancePostRefundAndPayment(GenJnlLine, SalesHeader, GenJnlPostLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Post Invoice Events", 'OnPostLedgerEntryOnAfterGenJnlPostLine', '', false, false)]
    local procedure OnPostLedgerEntryOnAfterGenJnlPostLine(var GenJnlLine: Record "Gen. Journal Line"; var SalesHeader: Record "Sales Header"; var TotalSalesLine: Record "Sales Line"; var TotalSalesLineLCY: Record "Sales Line"; PreviewMode: Boolean; SuppressCommit: Boolean; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line");
    begin
        if not RSLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        PrepaymentMgt.RebalancePostRefundAndPayment(GenJnlLine, SalesHeader, GenJnlPostLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterGetCustomerReceivablesAccount', '', false, false)]
    local procedure OnAfterGetCustomerReceivablesAccount(GenJournalLine: Record "Gen. Journal Line"; CustomerPostingGroup: Record "Customer Posting Group"; var ReceivablesAccount: Code[20]);
    begin
        if not RSLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        PrepaymentMgt.SetReceivablesAccount(GenJournalLine, CustomerPostingGroup, ReceivablesAccount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInitGLEntry', '', false, false)]
    local procedure OnBeforeInitGLEntry(var GenJournalLine: Record "Gen. Journal Line"; var GLAccNo: Code[20]; SystemCreatedEntry: Boolean; Amount: Decimal; AmountAddCurr: Decimal);
    begin
        if not RSLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        PrepaymentMgt.SetGLAccountForVATPosting(GenJournalLine, GLAccNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post Prepayments", 'OnBeforePostCustomerEntry', '', false, false)]
    local procedure OnBeforePostCustomerEntry(var GenJnlLine: Record "Gen. Journal Line"; TotalPrepmtInvLineBuffer: Record "Prepayment Inv. Line Buffer"; TotalPrepmtInvLineBufferLCY: Record "Prepayment Inv. Line Buffer"; CommitIsSuppressed: Boolean; SalesHeader: Record "Sales Header"; DocumentType: Option);
    begin
        if not RSLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        PrepaymentMgt.SetPostingAmountFromVATAmount(GenJnlLine, TotalPrepmtInvLineBuffer);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post Prepayments", 'OnBeforePostPrepayments', '', false, false)]
    local procedure OnBeforePostPrepayments(var SalesHeader: Record "Sales Header"; DocumentType: Option; CommitIsSuppressed: Boolean; PreviewMode: Boolean);
    var
        RSSalesHeader: Record "NPR RS Sales Header";
    begin
        if not RSLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        RSSalesHeader.Read(SalesHeader.SystemId);
        RSSalesHeader."Prepayment Posting Type" := DocumentType;
        RSSalesHeader.Save();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post Prepayments", 'OnBeforePostPrepmtInvLineBuffer', '', false, false)]
    local procedure OnBeforePostPrepmtInvLineBuffer(var GenJnlLine: Record "Gen. Journal Line"; PrepmtInvLineBuffer: Record "Prepayment Inv. Line Buffer"; CommitIsSuppressed: Boolean);
    begin
        if not RSLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        PrepaymentMgt.SetPostingAmountToZero(GenJnlLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure OnBeforePostSalesDoc(var Sender: Codeunit "Sales-Post"; var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; var HideProgressWindow: Boolean; var IsHandled: Boolean);
    begin
        if not RSLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        PrepaymentMgt.AutomaticallyPostCreditMemo(SalesHeader, PreviewMode);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeSalesLineByChangedFieldNo', '', false, false)]
    local procedure OnBeforeSalesLineByChangedFieldNo(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; ChangedFieldNo: Integer; var IsHandled: Boolean; xSalesHeader: Record "Sales Header");
    begin
        if not RSLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        PrepaymentMgt.SuspendStatusCheckOnSalesLine(SalesHeader, SalesLine, ChangedFieldNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post Prepayments", 'OnCodeOnAfterCalcShouldSetPendingPrepaymentStatus', '', false, false)]
    local procedure OnCodeOnAfterCalcShouldSetPendingPrepaymentStatus(var SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; DocumentType: Option; PreviewMode: Boolean; var ShouldSetPendingPrepaymentStatus: Boolean);
    begin
        if not RSLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        PrepaymentMgt.UpdatePrepaymentAmountsOnSalesLinesAfterPosting(SalesHeader, DocumentType);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostBankAccOnAfterBankAccLedgEntryInsert', '', false, false)]
    local procedure OnPostBankAccOnAfterBankAccLedgEntryInsert(var BankAccountLedgerEntry: Record "Bank Account Ledger Entry"; var GenJournalLine: Record "Gen. Journal Line");
    var
        RSBankAccLedgerEntry: Record "NPR RS Bank Acc. Ledger Entry";
    begin
        if not RSLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        RSBankAccLedgerEntry.Read(BankAccountLedgerEntry.SystemId);
        RSBankAccLedgerEntry."Document Type" := BankAccountLedgerEntry."Document Type";
        RSBankAccLedgerEntry."Bal. Account Type" := BankAccountLedgerEntry."Bal. Account Type";
        RSBankAccLedgerEntry."Bal. Account No." := BankAccountLedgerEntry."Bal. Account No.";
        RSBankAccLedgerEntry."Prepayment" := GenJournalLine.Prepayment;
        RSBankAccLedgerEntry.Save();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeValidateEvent', 'Prepayment %', false, false)]
    local procedure OnBeforeValidateEventPrepaymentPercentage(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if not RSLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        PrepaymentMgt.PreventChangingPrepaymentFieldsIfBankAccountIsSelected(Rec, CurrFieldNo);
        PrepaymentMgt.UpdatePaymentAmountOnSalesHeader(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post Prepayments", 'OnBeforeInvoice', '', false, false)]
    local procedure OnBeforeInvoice(var SalesHeader: Record "Sales Header"; var Handled: Boolean);
    begin
        if not RSLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        PrepaymentMgt.DisablePossibilityToPostDifferentVATRates(SalesHeader);
    end;
    #endregion
#ENDIF

}