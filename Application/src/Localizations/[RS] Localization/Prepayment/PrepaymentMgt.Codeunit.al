codeunit 6151373 "NPR Prepayment Mgt."
{
    Access = Internal;
#if not (BC17 or BC18 or BC19)
    #region Purchase Prepayment
    internal procedure SetPayablesAccount(GenJournalLine: Record "Gen. Journal Line"; VendorPostingGroup: Record "Vendor Posting Group"; var PayablesAccount: Code[20])
    var
        RSVendorPostingGroup: Record "NPR RS Vendor Posting Group";
    begin
        if not GenJournalLine.Prepayment then
            exit;
        RSVendorPostingGroup.Read(VendorPostingGroup.SystemId);
        RSVendorPostingGroup.TestField("Prepayment Account");
        PayablesAccount := RSVendorPostingGroup."Prepayment Account";
    end;
    #endregion

    #region Sales Prepayment

    internal procedure AutomaticallyPostCreditMemo(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean)
    begin
        if PreviewMode then
            exit;
        if not SalesHeader.Invoice then
            exit;
        if not PostPrepaymentCreditMemo(SalesHeader, SalesHeader."Document Type"::"Credit Memo") then
            exit;
        SalesHeader.Find();
    end;

    internal procedure AutoPopulatePrepaymentPercentageOnSalesHeader(var RSSalesHeader: Record "NPR RS Sales Header")
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        SalesHeader: Record "Sales Header";
        ConfirmManagement: Codeunit "Confirm Management";
        Prepayment: Decimal;
        UpdatePrepaymentLbl: Label 'Do you want to add selected Bank Entry to existing order percentage? In total it will be %1, current prepayment %2', Comment = '%1 = Total Percentage,%2 = Currect Percentage';
        ZeroAmountLbl: Label 'Amount on order is 0';
    begin
        if RSSalesHeader."Applies-to Bank Entry" = 0 then
            exit;
        SalesHeader.GetBySystemId(RSSalesHeader."Table SystemId");
        BankAccountLedgerEntry.Get(RSSalesHeader."Applies-to Bank Entry");

        SalesHeader.CalcFields(Amount);
        if SalesHeader.Amount = 0 then
            Error(ZeroAmountLbl);

        RSSalesHeader."Prepmt. Amount Incl. VAT" += BankAccountLedgerEntry."Remaining Amount";
        Prepayment := RSSalesHeader."Prepmt. Amount Incl. VAT" / GetPrepaymentVATPercentage(SalesHeader) / SalesHeader.Amount * 100;

        if Prepayment > 100 then
            Prepayment := 100;
        if SalesHeader."Prepayment %" > 0 then
            if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(UpdatePrepaymentLbl, Round(Prepayment), Round(SalesHeader."Prepayment %")), true) then
                Error('');
        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.Validate("Prepayment %", Prepayment);
        SalesHeader.SetHideValidationDialog(false);
        SalesHeader.TestField("Prepayment %");
        SalesHeader.Modify();
        RSSalesHeader.Save();
    end;

    internal procedure CloseEntriesForCrMemo(GenJnlLine: Record "Gen. Journal Line")
    var
        ApplyCustLedgerEntry: Record "Cust. Ledger Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GLSetup: Record "General Ledger Setup";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempApplyUnapplyParameters: Record "Apply Unapply Parameters" temporary;
        CustEntryApplyPostedEntries: Codeunit "CustEntry-Apply Posted Entries";
        CustEntrySetApplID: Codeunit "Cust. Entry-SetAppl.ID";
    begin
        case GenJnlLine."Document Type" of
            "Gen. Journal Document Type"::"Credit Memo":
                begin
                    ClearAppliesToId();
                    if not SalesCrMemoHeader.Get(GenJnlLine."Document No.") then
                        exit;
                    CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
                    CustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
                    CustLedgerEntry.SetRange(Open, true);
                    if not CustLedgerEntry.FindFirst() then
                        exit;
                    TempApplyUnapplyParameters.CopyFromCustLedgEntry(CustLedgerEntry);

                    SalesInvoiceHeader.SetRange("Prepayment Order No.", SalesCrMemoHeader."Prepayment Order No.");
                    if SalesInvoiceHeader.IsEmpty() then
                        exit;
                    SalesInvoiceHeader.FindSet();
                    repeat
                        ApplyCustLedgerEntry.SetRange("Document Type", ApplyCustLedgerEntry."Document Type"::Invoice);
                        ApplyCustLedgerEntry.SetRange("Document No.", SalesInvoiceHeader."No.");
                        ApplyCustLedgerEntry.SetRange(Open, true);
                        if not ApplyCustLedgerEntry.IsEmpty() then begin
                            CustLedgerEntry."Applying Entry" := true;
                            if CustLedgerEntry."Applies-to ID" = '' then
                                CustLedgerEntry."Applies-to ID" := 'PREV';
                            CustLedgerEntry.CalcFields("Remaining Amount");
                            if CustLedgerEntry."Remaining Amount" = 0 then
                                exit;
                            CustLedgerEntry."Amount to Apply" := CustLedgerEntry."Remaining Amount";
                            CustLedgerEntry.Modify();

                            CustEntrySetApplID.SetApplId(ApplyCustLedgerEntry, CustLedgerEntry, 'PREV');
                            GLSetup.Get();
                            if GLSetup."Journal Templ. Name Mandatory" then begin
                                GLSetup.TestField("Apply Jnl. Template Name");
                                GLSetup.TestField("Apply Jnl. Batch Name");
                                TempApplyUnapplyParameters."Journal Template Name" := GLSetup."Apply Jnl. Template Name";
                                TempApplyUnapplyParameters."Journal Batch Name" := GLSetup."Apply Jnl. Batch Name";
                            end;
                            CustEntryApplyPostedEntries.Apply(CustLedgerEntry, TempApplyUnapplyParameters);
                            CustLedgerEntry.Get(CustLedgerEntry."Entry No.");
                            if not CustLedgerEntry.Open then
                                exit;
                        end;
                    until SalesInvoiceHeader.Next() = 0;
                end;
        end;
    end;

    internal procedure DisablePossibilityToPostDifferentVATRates(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        PrepaymentVAT: Decimal;
        DifferentVATPercentagesErr: Label 'Posting prepayment for different VAT Rates in the lines is not possible. You are trying to post line %1 with Prepayment VAT %2% and VAT %3%', Comment = '%1 = Line No, %2 = Prepayment VAT %, %3 = VAT %';
        DifferentVATPercentagesOnDifferentLinesErr: Label 'Posting prepayment for different VAT Rates in the lines is not possible. You are trying to post line %1 with Prepayment VAT %2% and on another line Prepayment VAT is %3%', Comment = '%1 = Line No, %2 = Prepayment VAT %, %3 = Prepayment VAT %';
    begin
        SalesLine.SetFilter("Prepayment VAT %", '<>0');
        SalesLine.SetFilter("VAT %", '<>0');
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.IsEmpty() then
            exit;
        SalesLine.FindSet();
        repeat
            if SalesLine."Prepayment VAT %" <> SalesLine."VAT %" then
                Error(DifferentVATPercentagesErr, SalesLine."Line No.", SalesLine."Prepayment VAT %", SalesLine."VAT %");
            if PrepaymentVAT = 0 then
                PrepaymentVAT := SalesLine."Prepayment VAT %";
            if PrepaymentVAT <> SalesLine."Prepayment VAT %" then
                Error(DifferentVATPercentagesOnDifferentLinesErr, SalesLine."Line No.", SalesLine."Prepayment VAT %", PrepaymentVAT);
        until SalesLine.Next() = 0;
    end;

    internal procedure PreventChangingPrepaymentFieldsIfBankAccountIsSelected(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    var
        RSSalesHeader: Record "NPR RS Sales Header";
        CannotBeChangedErr: Label 'Prepayment % and Amount cannot be changed manually when Applies to Bank Entry is selected';
    begin
        RSSalesHeader.Read(Rec.SystemId);
        if not (CurrFieldNo in [Rec.FieldNo("Prepayment %"), RSSalesHeader.FieldNo("Prepmt. Amount Incl. VAT")]) then
            exit;
        if RSSalesHeader."Applies-to Bank Entry" = 0 then
            exit;
        Error(CannotBeChangedErr);
    end;

    internal procedure RebalancePostRefundAndPayment(var GenJnlLine: Record "Gen. Journal Line"; var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
        NewGenJnlLine2: Record "Gen. Journal Line";
        NewGenJnlLine: Record "Gen. Journal Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        AmountRebalanced: Decimal;
        AmountToPost: Decimal;
        PostingAmountInclVAT: Decimal;
    begin
        SalesInvoiceHeader.SetRange("Prepayment Invoice", true);
        SalesInvoiceHeader.SetRange("Prepayment Order No.", SalesHeader."No.");
        if SalesInvoiceHeader.IsEmpty() then
            exit;

        SalesInvoiceHeader.SetAutoCalcFields("Amount Including VAT");
        if SalesInvoiceHeader.FindSet() then
            repeat
                AmountToPost += SalesInvoiceHeader."Amount Including VAT";
            until SalesInvoiceHeader.Next() = 0;

        AmountToPost -= GetTotalPrepaymentAmount(SalesHeader."Document Type", SalesHeader."No.", false);

        CustLedgerEntry.SetFilter("Document No.", GetCustomerLedgerEntriesDocumentNo(SalesHeader));
        CustLedgerEntry.SetRange("Customer No.", SalesHeader."Sell-to Customer No.");
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Payment);
        CustLedgerEntry.SetRange(Prepayment, false);
        CustLedgerEntry.SetAutoCalcFields(Amount);
        if CustLedgerEntry.FindSet() then
            repeat
                AmountRebalanced += CustLedgerEntry.Amount;
            until CustLedgerEntry.Next() = 0;

        AmountToPost := AmountToPost + AmountRebalanced;
        if AmountToPost <= 0 then
            exit;

        PostingAmountInclVAT := GetPostingAmount(SalesHeader);
        if PostingAmountInclVAT < AmountToPost then
            AmountToPost := PostingAmountInclVAT;

        if AmountToPost <= 0 then
            exit;
        AmountToPost := Round(AmountToPost, GetCurrencyAmountRoundingPrecision(SalesHeader."Currency Code"));

        Customer.Get(GenJnlLine."Account No.");
        CustomerPostingGroup.Get(Customer."Customer Posting Group");

        NewGenJnlLine.TransferFields(GenJnlLine);
        NewGenJnlLine.Validate("Document Type", NewGenJnlLine."Document Type"::Payment);
        NewGenJnlLine.Validate(Amount, -AmountToPost);
        NewGenJnlLine."Pmt. Discount Date" := 0D;
        NewGenJnlLine."Payment Discount %" := 0;
        GenJnlPostLine.RunWithCheck(NewGenJnlLine);

        NewGenJnlLine2.TransferFields(NewGenJnlLine);
        NewGenJnlLine2.Validate("Document Type", NewGenJnlLine2."Document Type"::Refund);
        NewGenJnlLine2.Validate(Amount, AmountToPost);
        NewGenJnlLine2."Pmt. Discount Date" := 0D;
        NewGenJnlLine2."Payment Discount %" := 0;
        NewGenJnlLine2.Prepayment := true;
        GenJnlPostLine.RunWithCheck(NewGenJnlLine2);

        CloseEntries(GenJnlLine, SalesHeader);
    end;

    internal procedure RoundAmountsBeforePostingOfPrepaymentCrMemo(var SalesHeader: Record "Sales Header"; var TempGlobalPrepmtInvLineBuf: Record "Prepayment Inv. Line Buffer" temporary)
    var
        Currency: Record Currency;
        RSSalesHeader: Record "NPR RS Sales Header";
        TotalSalesLine: Record "Sales Line";
        SalesPostPrepayments: Codeunit "Sales-Post Prepayments";
        AmountToPost: Decimal;
        AmountToPostInclVAT: Decimal;
        Coef: Decimal;
        TotalAmountToPost: Decimal;
        TotalVatAmountToPost: Decimal;
    begin
        RSSalesHeader.Read(SalesHeader.SystemId);
        if RSSalesHeader."Prepayment Posting Type" <> RSSalesHeader."Prepayment Posting Type"::"Credit Memo" then
            exit;
        if TempGlobalPrepmtInvLineBuf.IsEmpty() then
            exit;

        TempGlobalPrepmtInvLineBuf.FindSet();
        repeat
            SalesPostPrepayments.ApplyFilter(SalesHeader, RSSalesHeader."Prepayment Posting Type", TotalSalesLine);
            if TempGlobalPrepmtInvLineBuf."Line No." <> 0 then
                TotalSalesLine.SetRange("Line No.", TempGlobalPrepmtInvLineBuf."Line No.");
            if TotalSalesLine.FindSet() then
                repeat
                    TotalAmountToPost += TotalSalesLine.Amount * TotalSalesLine."Qty. to Ship" / TotalSalesLine.Quantity;
                until TotalSalesLine.Next() = 0;

            AmountToPost := TempGlobalPrepmtInvLineBuf.Amount;
            AmountToPostInclVAT := TempGlobalPrepmtInvLineBuf."Amount Incl. VAT";
            TotalVatAmountToPost := AmountToPostInclVAT - AmountToPost;
            if TotalVatAmountToPost <= 0 then
                exit;

            if AmountToPost > TotalAmountToPost then begin
                Coef := TotalAmountToPost / AmountToPost;
                AmountToPost *= Coef;
                AmountToPostInclVAT *= Coef;
                Currency.Initialize(SalesHeader."Currency Code");
                AmountToPost := Round(AmountToPost, Currency."Amount Rounding Precision");
                AmountToPostInclVAT := Round(AmountToPostInclVAT, Currency."Amount Rounding Precision");
            end;

            ApplyRoundingDifference(AmountToPost, AmountToPostInclVAT, SalesHeader);

            TempGlobalPrepmtInvLineBuf.SetAmounts(
                AmountToPost, AmountToPostInclVAT, AmountToPost,
                AmountToPost, AmountToPost, TempGlobalPrepmtInvLineBuf."VAT Difference");

            TempGlobalPrepmtInvLineBuf."VAT Amount" := AmountToPostInclVAT - AmountToPost;
            TempGlobalPrepmtInvLineBuf."VAT Amount (ACY)" := AmountToPostInclVAT - AmountToPost;
            TempGlobalPrepmtInvLineBuf."VAT Base Before Pmt. Disc." := -AmountToPost;
            TempGlobalPrepmtInvLineBuf.Modify();
        until TempGlobalPrepmtInvLineBuf.Next() = 0;
    end;

    internal procedure SetAdditionalFiltersOnSalesLine(var SalesLine: Record "Sales Line")
    begin
        SalesLine.SetFilter("Qty. to Ship", '>%1', 0);
    end;

    internal procedure SetGLAccountForVATPosting(var GenJournalLine: Record "Gen. Journal Line"; var GLAccNo: Code[20])
    var
        RSVATPostingSetup: Record "NPR RS VAT Posting Setup";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if not GenJournalLine.Prepayment then
            exit;
        if GenJournalLine."Gen. Posting Type" <> GenJournalLine."Gen. Posting Type"::Sale then
            exit;
        if not VATPostingSetup.Get(GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group") then
            exit;
        RSVATPostingSetup.Read(VATPostingSetup.SystemId);
        RSVATPostingSetup.TestField("Sales Prep. VAT Account");
        GLAccNo := RSVATPostingSetup."Sales Prep. VAT Account";
    end;

    internal procedure SetPostingAmountFromVATAmount(var GenJnlLine: Record "Gen. Journal Line"; var TotalPrepmtInvLineBuffer: Record "Prepayment Inv. Line Buffer")
    begin
        GenJnlLine.Amount := Abs(TotalPrepmtInvLineBuffer."VAT Amount");
        if GenJnlLine."Document Type" = GenJnlLine."Document Type"::"Credit Memo" then
            GenJnlLine.Amount := -GenJnlLine.Amount;
    end;

    internal procedure SetPostingAmountToZero(var GenJnlLine: Record "Gen. Journal Line")
    begin
        GenJnlLine.Amount := 0;
    end;

    internal procedure SetReceivablesAccount(var GenJournalLine: Record "Gen. Journal Line"; var CustomerPostingGroup: Record "Customer Posting Group"; var ReceivablesAccount: Code[20])
    var
        RSCustomerPostingGroup: Record "NPR RS Customer Posting Group";
    begin
        if not GenJournalLine.Prepayment then
            exit;
        RSCustomerPostingGroup.Read(CustomerPostingGroup.SystemId);
        RSCustomerPostingGroup.TestField("Prepayment Account");
        ReceivablesAccount := RSCustomerPostingGroup."Prepayment Account";
    end;

    internal procedure SuspendStatusCheckOnSalesLine(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; ChangedFieldNo: Integer)
    begin
        if ChangedFieldNo = SalesHeader.FieldNo("Prepayment %") then
            if SalesHeader.GetHideValidationDialog() then
                SalesLine.SuspendStatusCheck(true);
    end;

    internal procedure UpdatePaymentAmountOnSalesHeader(var SalesHeader: Record "Sales Header"; CurrFieldNo: Integer)
    var
        RSSalesHeader: Record "NPR RS Sales Header";
    begin
        if CurrFieldNo <> SalesHeader.FieldNo("Prepayment %") then
            exit;
        RSSalesHeader.Read(SalesHeader.SystemId);
        SalesHeader.CalcFields(Amount);
        RSSalesHeader."Prepmt. Amount Incl. VAT" := SalesHeader.Amount * GetPrepaymentVATPercentage(SalesHeader) * SalesHeader."Prepayment %" / 100;
        RSSalesHeader.Save();
    end;

    internal procedure UpdatePaymentPercentageOnSalesHeader(RSSalesHeader: Record "NPR RS Sales Header"; var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.CalcFields(Amount);
        SalesHeader.TestField(Amount);
        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.Validate("Prepayment %", RSSalesHeader."Prepmt. Amount Incl. VAT" / GetPrepaymentVATPercentage(SalesHeader) / SalesHeader.Amount * 100);
        SalesHeader.SetHideValidationDialog(false);
        SalesHeader.Modify();
    end;

    internal procedure UpdatePrepaymentAmountsOnSalesLinesAfterPosting(var SalesHeader: Record "Sales Header"; var DocumentType: Option)
    var
        OriginalSalesLine: Record "Sales Line";
        RSSalesHeader: Record "NPR RS Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CreditedAmount: Decimal;
        NewPercentage: Decimal;
        NewPrepaymentAmount: Decimal;
        PrepaymentAmount: Decimal;
        LocalDocumentType: Option Invoice,"Credit Memo";
    begin
        if DocumentType <> LocalDocumentType::"Credit Memo" then
            exit;

        SalesInvoiceHeader.SetRange("Prepayment Invoice", true);
        SalesInvoiceHeader.SetRange("Prepayment Order No.", SalesHeader."No.");
        SalesInvoiceHeader.SetAutoCalcFields(Amount);
        if SalesInvoiceHeader.FindSet() then
            repeat
                PrepaymentAmount += SalesInvoiceHeader.Amount;
            until SalesInvoiceHeader.Next() = 0;

        SalesCrMemoHeader.SetRange("Prepayment Credit Memo", true);
        SalesCrMemoHeader.SetRange("Prepayment Order No.", SalesHeader."No.");
        SalesCrMemoHeader.SetAutoCalcFields(Amount);
        if SalesCrMemoHeader.FindSet() then
            repeat
                CreditedAmount += SalesCrMemoHeader.Amount;
            until SalesCrMemoHeader.Next() = 0;

        if PrepaymentAmount <> CreditedAmount then begin
            NewPrepaymentAmount := PrepaymentAmount - CreditedAmount;
            SalesHeader.CalcFields(Amount);
            NewPercentage := NewPrepaymentAmount * 100 / SalesHeader.Amount;
        end;
        if PrepaymentAmount = CreditedAmount then
            NewPercentage := 0;
        if NewPercentage < 0 then
            NewPercentage := 0;

        SalesHeader."Prepayment %" := NewPercentage;
        SalesHeader.CalcFields(Amount);
        RSSalesHeader.Read(SalesHeader.SystemId);
        RSSalesHeader."Prepmt. Amount Incl. VAT" := SalesHeader.Amount * GetPrepaymentVATPercentage(SalesHeader) * SalesHeader."Prepayment %" / 100;
        SalesHeader.Modify();
        RSSalesHeader.Save();

        OriginalSalesLine.SetRange("Document Type", SalesHeader."Document Type");
        OriginalSalesLine.SetRange("Document No.", SalesHeader."No.");
        OriginalSalesLine.SetFilter(Type, '<>%1', OriginalSalesLine.Type::" ");
        if OriginalSalesLine.FindSet() then
            repeat
                OriginalSalesLine.SuspendStatusCheck(true);
                OriginalSalesLine.Validate("Prepayment %", NewPercentage);
                UpdatePrepaymentFieldsOnSalesLine(OriginalSalesLine, SalesHeader, OriginalSalesLine."Prepmt. Line Amount");
                OriginalSalesLine.Modify();
                OriginalSalesLine.SuspendStatusCheck(false);
            until OriginalSalesLine.Next() = 0;
    end;

    internal procedure SaveBankEntryNoOnPrepaymentPosting(var SalesHeader: Record "Sales Header"; DocumentType: Option Invoice,"Credit Memo"; var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        RSSalesBankRelation: Record "NPR RS Sales Bank Relation";
        RSSalesHeader: Record "NPR RS Sales Header";
    begin
        if DocumentType <> DocumentType::Invoice then
            exit;
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then
            exit;
        RSSalesHeader.Read(SalesHeader.SystemId);
        if RSSalesHeader."Applies-to Bank Entry" = 0 then
            exit;
        if not BankAccountLedgerEntry.Get(RSSalesHeader."Applies-to Bank Entry") then
            exit;
        RSSalesBankRelation.Init();
        RSSalesBankRelation."Sales Document No." := SalesHeader."No.";
        RSSalesBankRelation."Bank Document No." := BankAccountLedgerEntry."Document No.";
        RSSalesBankRelation."Bank Entry No." := BankAccountLedgerEntry."Entry No.";
        if RSSalesBankRelation.Insert() then;
    end;

    internal procedure DeleteSalesBankEntryRelation(No: Code[20])
    var
        RSSalesBankRelation: Record "NPR RS Sales Bank Relation";
    begin
        RSSalesBankRelation.SetRange("Sales Document No.", No);
        if RSSalesBankRelation.IsEmpty() then
            exit;
        RSSalesBankRelation.DeleteAll();
    end;

    local procedure ApplyRoundingDifference(var AmountToPost: Decimal; var AmountToPostInclVAT: Decimal; var SalesHeader: Record "Sales Header")
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PostedAmount: Decimal;
        PostedAmountInclVAT: Decimal;
    begin
        SalesInvoiceHeader.SetRange("Prepayment Invoice", true);
        SalesInvoiceHeader.SetRange("Prepayment Order No.", SalesHeader."No.");
        SalesInvoiceHeader.SetAutoCalcFields(Amount, "Amount Including VAT");
        if SalesInvoiceHeader.FindSet() then
            repeat
                PostedAmount += SalesInvoiceHeader.Amount;
                PostedAmountInclVAT += SalesInvoiceHeader."Amount Including VAT";
            until SalesInvoiceHeader.Next() = 0;

        SalesCrMemoHeader.SetRange("Prepayment Credit Memo", true);
        SalesCrMemoHeader.SetRange("Prepayment Order No.", SalesHeader."No.");
        SalesCrMemoHeader.SetAutoCalcFields(Amount, "Amount Including VAT");
        if SalesCrMemoHeader.FindSet() then
            repeat
                PostedAmount -= SalesCrMemoHeader.Amount;
                PostedAmountInclVAT -= SalesCrMemoHeader."Amount Including VAT";
            until SalesCrMemoHeader.Next() = 0;

        if PostedAmount < 0 then
            exit;
        if Abs(AmountToPost - PostedAmount) <= 0.05 then begin
            AmountToPost := PostedAmount;
            AmountToPostInclVAT := PostedAmountInclVAT;
        end;
    end;

    local procedure ClearAppliesToId()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Applies-to ID", 'PREV');
        if CustLedgerEntry.IsEmpty() then
            exit;
        CustLedgerEntry.ModifyAll("Applies-to ID", '');
    end;

    local procedure CloseEntries(var GenJnlLine: Record "Gen. Journal Line"; var SalesHeader: Record "Sales Header")
    begin
        //Payment
        CloseEntriesForPayment(GenJnlLine);

        //Refund
        CloseEntriesForRefund(GenJnlLine, SalesHeader);
    end;

    local procedure CloseEntriesForPayment(var GenJnlLine: Record "Gen. Journal Line")
    var
        ApplyCustLedgerEntry: Record "Cust. Ledger Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GLSetup: Record "General Ledger Setup";
        TempApplyUnapplyParameters: Record "Apply Unapply Parameters" temporary;
        CustEntryApplyPostedEntries: Codeunit "CustEntry-Apply Posted Entries";
        CustEntrySetApplID: Codeunit "Cust. Entry-SetAppl.ID";
    begin
        ClearAppliesToId();

        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Payment);
        CustLedgerEntry.SetRange("Document No.", GenJnlLine."Document No.");
        CustLedgerEntry.SetRange("Customer No.", GenJnlLine."Account No.");
        CustLedgerEntry.SetRange(Open, true);
        if not CustLedgerEntry.FindFirst() then
            exit;

        CustLedgerEntry."Applying Entry" := true;
        if CustLedgerEntry."Applies-to ID" = '' then
            CustLedgerEntry."Applies-to ID" := 'PREV';
        CustLedgerEntry.CalcFields("Remaining Amount");
        if CustLedgerEntry."Remaining Amount" = 0 then
            exit;
        CustLedgerEntry."Amount to Apply" := CustLedgerEntry."Remaining Amount";
        CustLedgerEntry.Modify();
        TempApplyUnapplyParameters.CopyFromCustLedgEntry(CustLedgerEntry);

        ApplyCustLedgerEntry.SetRange("Document Type", ApplyCustLedgerEntry."Document Type"::Invoice);
        ApplyCustLedgerEntry.SetRange("Document No.", GenJnlLine."Document No.");
        ApplyCustLedgerEntry.SetRange("Customer No.", GenJnlLine."Account No.");
        ApplyCustLedgerEntry.SetRange(Open, true);
        if ApplyCustLedgerEntry.IsEmpty() then
            exit;

        CustEntrySetApplID.SetApplId(ApplyCustLedgerEntry, CustLedgerEntry, 'PREV');
        GLSetup.Get();
        if GLSetup."Journal Templ. Name Mandatory" then begin
            GLSetup.TestField("Apply Jnl. Template Name");
            GLSetup.TestField("Apply Jnl. Batch Name");
            TempApplyUnapplyParameters."Journal Template Name" := GLSetup."Apply Jnl. Template Name";
            TempApplyUnapplyParameters."Journal Batch Name" := GLSetup."Apply Jnl. Batch Name";
        end;
        CustEntryApplyPostedEntries.Apply(CustLedgerEntry, TempApplyUnapplyParameters);
    end;

    local procedure CloseEntriesForRefund(var GenJnlLine: Record "Gen. Journal Line"; SalesHeader: Record "Sales Header")
    var
        ApplyCustLedgerEntry: Record "Cust. Ledger Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GLSetup: Record "General Ledger Setup";
        TempApplyUnapplyParameters: Record "Apply Unapply Parameters" temporary;
        CustEntryApplyPostedEntries: Codeunit "CustEntry-Apply Posted Entries";
        CustEntrySetApplID: Codeunit "Cust. Entry-SetAppl.ID";
    begin
        ClearAppliesToId();

        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Refund);
        CustLedgerEntry.SetRange("Document No.", GenJnlLine."Document No.");
        CustLedgerEntry.SetRange("Customer No.", GenJnlLine."Account No.");
        CustLedgerEntry.SetRange(Prepayment, true);
        CustLedgerEntry.SetRange(Open, true);
        if not CustLedgerEntry.FindFirst() then
            exit;

        CustLedgerEntry."Applying Entry" := true;
        if CustLedgerEntry."Applies-to ID" = '' then
            CustLedgerEntry."Applies-to ID" := 'PREV';
        CustLedgerEntry.CalcFields("Remaining Amount");
        if CustLedgerEntry."Remaining Amount" = 0 then
            exit;
        CustLedgerEntry."Amount to Apply" := CustLedgerEntry."Remaining Amount";
        CustLedgerEntry.Modify();
        TempApplyUnapplyParameters.CopyFromCustLedgEntry(CustLedgerEntry);

        ApplyCustLedgerEntry.SetRange("Document Type", ApplyCustLedgerEntry."Document Type"::Payment);
        ApplyCustLedgerEntry.SetRange("Customer No.", GenJnlLine."Account No.");
        ApplyCustLedgerEntry.SetRange(Prepayment, true);
        ApplyCustLedgerEntry.SetRange(Open, true);
        SetFilterForDocumentNo(ApplyCustLedgerEntry, SalesHeader."No.");

        if ApplyCustLedgerEntry.IsEmpty() then
            exit;

        CustEntrySetApplID.SetApplId(ApplyCustLedgerEntry, CustLedgerEntry, 'PREV');
        GLSetup.Get();
        if GLSetup."Journal Templ. Name Mandatory" then begin
            GLSetup.TestField("Apply Jnl. Template Name");
            GLSetup.TestField("Apply Jnl. Batch Name");
            TempApplyUnapplyParameters."Journal Template Name" := GLSetup."Apply Jnl. Template Name";
            TempApplyUnapplyParameters."Journal Batch Name" := GLSetup."Apply Jnl. Batch Name";
        end;
        CustEntryApplyPostedEntries.Apply(CustLedgerEntry, TempApplyUnapplyParameters);
        UpdateBankAccountLedgerEntries(GenJnlLine);
    end;

    local procedure GetCurrencyAmountRoundingPrecision(CurrencyCode: Code[10]): Decimal
    var
        Currency: Record Currency;
    begin
        Currency.Initialize(CurrencyCode);
        Currency.TestField("Amount Rounding Precision");
        exit(Currency."Amount Rounding Precision");
    end;

    local procedure GetCustomerLedgerEntriesDocumentNo(SalesHeader: Record "Sales Header") FilterValue: Text
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        SalesInvoiceHeader.SetRange("Order No.", SalesHeader."No.");
        if SalesInvoiceHeader.FindSet() then
            repeat
                FilterValue += SalesInvoiceHeader."No." + '|';
            until SalesInvoiceHeader.Next() = 0;
        if StrLen(FilterValue) > 0 then
            FilterValue := FilterValue.TrimEnd('|');
    end;

    local procedure GetPostingAmount(SalesHeader: Record "Sales Header") PostingAmountInclVAT: Decimal
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetFilter(Quantity, '>%1', 0);
        if SalesLine.FindSet() then
            repeat
                PostingAmountInclVAT += SalesLine."Amount Including VAT" * SalesLine."Qty. to Ship" / SalesLine.Quantity;
            until SalesLine.Next() = 0;
    end;

    local procedure GetTotalPrepaymentAmount(DocumentType: Enum "Sales Document Type"; DocumentNo: Code[20]; VATOnly: Boolean) ReturnValue: Decimal
    var
        TotalSalesLine: Record "Sales Line";
    begin
        TotalSalesLine.SetRange("Document Type", DocumentType);
        TotalSalesLine.SetRange("Document No.", DocumentNo);
        if TotalSalesLine.IsEmpty() then
            exit;
        if not VATOnly then begin
            TotalSalesLine.CalcSums("Prepmt. Line Amount");
            exit(TotalSalesLine."Prepmt. Line Amount");
        end;
        TotalSalesLine.FindSet();
        repeat
            if TotalSalesLine."Prepmt. Line Amount" > 0 then
                ReturnValue += TotalSalesLine."Prepmt. Line Amount" * TotalSalesLine."Prepayment VAT %" / 100;
        until TotalSalesLine.Next() = 0;
        exit(ReturnValue);
    end;

    local procedure PostPrepaymentCreditMemo(SalesHeader: Record "Sales Header"; PrepmtDocumentType: Enum "Sales Document Type"): Boolean
    var
        ErrorContextElement: Codeunit "Error Context Element";
        ErrorMessageHandler: Codeunit "Error Message Handler";
        ErrorMessageMgt: Codeunit "Error Message Management";
        SalesPostPrepayments: Codeunit "Sales-Post Prepayments";
    begin
        if not SalesPostPrepayments.CheckOpenPrepaymentLines(SalesHeader, PrepmtDocumentType.AsInteger()) then
            exit;
        ErrorMessageMgt.Activate(ErrorMessageHandler);
        ErrorMessageMgt.PushContext(ErrorContextElement, SalesHeader.RecordId, 0, '');
        SalesPostPrepayments.SetDocumentType(PrepmtDocumentType.AsInteger());
        SalesPostPrepayments.SetSuppressCommit(true);
        SalesPostPrepayments.CreditMemo(SalesHeader);
        exit(true);
    end;

    local procedure UpdateBankAccountLedgerEntries(GenJnlLine: Record "Gen. Journal Line")
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Payment);
        CustLedgerEntry.SetRange("Customer No.", GenJnlLine."Account No.");
        CustLedgerEntry.SetRange(Prepayment, true);
        CustLedgerEntry.SetAutoCalcFields("Remaining Amount");
        if CustLedgerEntry.FindSet() then
            repeat
                BankAccountLedgerEntry.SetRange("Posting Date", CustLedgerEntry."Posting Date");
                BankAccountLedgerEntry.SetRange("Document No.", CustLedgerEntry."Document No.");
                if BankAccountLedgerEntry.FindFirst() then
                    if BankAccountLedgerEntry."Remaining Amount" <> Abs(CustLedgerEntry."Remaining Amount") then begin
                        BankAccountLedgerEntry."Remaining Amount" := Abs(CustLedgerEntry."Remaining Amount");
                        BankAccountLedgerEntry.Modify();
                    end;
            until CustLedgerEntry.Next() = 0;
    end;

    local procedure UpdatePrepaymentFieldsOnSalesLine(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; AmountAfterCrMemo: Decimal)
    begin
        SalesLine."Prepmt. Amt. Inv." := AmountAfterCrMemo;
        if SalesHeader."Prices Including VAT" then
            SalesLine."Prepmt. Amount Inv. Incl. VAT" := SalesLine."Prepmt. Amt. Inv."
        else
            SalesLine."Prepmt. Amount Inv. Incl. VAT" := Round(SalesLine."Prepmt. Amt. Inv." * (100 + SalesLine."Prepayment VAT %") / 100, GetCurrencyAmountRoundingPrecision(SalesLine."Currency Code"));
        SalesLine."Prepmt. Amt. Incl. VAT" := SalesLine."Prepmt. Amount Inv. Incl. VAT";
        SalesLine."Prepayment Amount" := SalesLine."Prepmt. Amt. Inv.";
        SalesLine."Prepmt Amt to Deduct" := 0;
    end;

    local procedure GetPrepaymentVATPercentage(SalesHeader: Record "Sales Header"): Decimal
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter(Type, '<>%1', SalesLine.Type::" ");
        SalesLine.SetFilter("VAT %", '<>0');
        if SalesLine.IsEmpty() then
            exit(1);
        SalesLine.FindFirst();
        exit(1 + (SalesLine."VAT %" / 100)); //We took VAT % since Prepayment VAT % cannot be different than VAT %
    end;

    local procedure SetFilterForDocumentNo(var ApplyCustLedgerEntry: Record "Cust. Ledger Entry"; No: Code[20])
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        RSSalesBankRelation: Record "NPR RS Sales Bank Relation";
        DocumentNoFilter: TextBuilder;
    begin
        RSSalesBankRelation.SetRange("Sales Document No.", No);
        if RSSalesBankRelation.IsEmpty() then
            exit;
        RSSalesBankRelation.FindSet();
        repeat
            BankAccountLedgerEntry.Get(RSSalesBankRelation."Bank Entry No.");
            if BankAccountLedgerEntry."Remaining Amount" > 0 then
                DocumentNoFilter.Append('''' + BankAccountLedgerEntry."Document No." + '''' + '|');
        until RSSalesBankRelation.Next() = 0;
        if DocumentNoFilter.ToText() <> '' then
            ApplyCustLedgerEntry.SetFilter("Document No.", DocumentNoFilter.ToText().TrimEnd('|'));
    end;
    #endregion
#ENDIF
}