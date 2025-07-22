codeunit 6014410 "NPR POS Apply Customer Entries"
{
    Access = Internal;
    Permissions = TableData "Cust. Ledger Entry" = rimd;
    TableNo = "NPR POS Sale Line";

    var
        _CustLedgEntryView: Text;
        CONFIRM_BALANCE: Label 'Do you wish to apply %1 %2 for customer %3?';
        BALANCING_OF: Label 'Balancing of %1 %2';

    procedure DeleteExistingLines(SalePOS: Record "NPR POS Sale")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        FilterPosSaleLines(SalePOS, SaleLinePOS);
        if not SaleLinePOS.IsEmpty() then
            SaleLinePOS.DeleteAll();
    end;

    local procedure FilterPosSaleLines(SalePOS: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line")
    begin
        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetFilter("Buffer Document No.", '<>%1', '');
    end;

    procedure SetCustLedgEntryView(TableView: Text)
    begin
        _CustLedgEntryView := TableView;
    end;

    procedure SelectCustomerEntries(var POSSession: Codeunit "NPR POS Session"; CustLedgEntryView: Text; CopyDesc: Boolean)
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        CustLedgEntry: Record "Cust. Ledger Entry";
        AppliesToID: Code[50];
        Confirmed: Boolean;
        AppliesToIDLbl: Label '%1-%2', Locked = true;
    begin
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);

        SalePOS.TestField("Customer No.");
        AppliesToID := StrSubstNo(AppliesToIDLbl, SalePOS."Register No.", SalePOS."Sales Ticket No.");
        RestoreAppliesToIDMarks(SalePOS, AppliesToID);

        if CustLedgEntryView <> '' then
            CustLedgEntry.SetView(CustLedgEntryView)
        else
            CustLedgEntry.SetCurrentKey("Customer No.", Open);
        CustLedgEntry.SetRange("Customer No.", SalePOS."Customer No.");
        CustLedgEntry.SetRange(Open, true);
        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS."Buffer ID" := AppliesToID;

        Confirmed := SelectCustLedgerEntry(SalePOS, SaleLinePOS, SaleLinePOS.FieldNo("Buffer ID"), CustLedgEntry);

        SalePOS.CheckPostingDatePermitted(CustLedgEntry."Posting Date");

        CustLedgEntry.Reset();
        CustLedgEntry.SetCurrentKey("Customer No.", "Applies-to ID", Open);
        CustLedgEntry.SetAutoCalcFields("Remaining Amount");
        CustLedgEntry.SetRange("Customer No.", SalePOS."Customer No.");
        CustLedgEntry.SetRange("Applies-to ID", AppliesToID);
        CustLedgEntry.SetRange(Open, true);
        if not CustLedgEntry.FindSet() then
            exit;
        if not Confirmed then begin
            ClearAppliesToID(CustLedgEntry);
            exit;
        end;
        DeleteExistingLines(SalePOS);
        POSSaleLine.RefreshCurrent();

        ClearAcceptedPmtTolerance(CustLedgEntry);
        repeat
            CreateApplyingPOSSaleLine(POSSaleLine, CustLedgEntry, CopyDesc);
        until CustLedgEntry.Next() = 0;
    end;

    procedure BalanceDocument(var POSSession: Codeunit "NPR POS Session"; DocumentType: Enum "Gen. Journal Document Type"; DocumentNo: Code[20];
                                                  Silent: Boolean;
                                                  CopyDesc: Boolean)
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
    begin
        if DocumentNo = '' then
            exit;

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);

        CustLedgEntry.SetAutoCalcFields("Remaining Amount");
        CustLedgEntry.SetRange("Document Type", DocumentType);
        CustLedgEntry.SetRange("Document No.", DocumentNo);
        if SalePOS."Customer No." <> '' then
            CustLedgEntry.SetRange("Customer No.", SalePOS."Customer No.");
        CustLedgEntry.FindFirst();
        CustLedgEntry.TestField(Open);

        if DocumentType = DocumentType::Invoice then
            SalePOS.CheckPostingDatePermitted(CustLedgEntry."Posting Date");

        if not Silent then
            if not Confirm(StrSubstNo(CONFIRM_BALANCE, CustLedgEntry."Document Type", CustLedgEntry."Document No.", CustLedgEntry."Customer No."), true) then
                Error('');

        if SalePOS."Customer No." = '' then begin
            SalePOS.Validate("Customer No.", CustLedgEntry."Customer No.");
            SalePOS.Modify();
            POSSale.RefreshCurrent();
        end else
            SalePOS.TestField("Customer No.", CustLedgEntry."Customer No.");

        CreateApplyingPOSSaleLine(POSSaleLine, CustLedgEntry, CopyDesc);
    end;

    local procedure CreateApplyingPOSSaleLine(var POSSaleLine: Codeunit "NPR POS Sale Line"; CustLedgEntry: Record "Cust. Ledger Entry"; CopyDesc: Boolean)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        GenJnlApply: Codeunit "Gen. Jnl.-Apply";
        ApplnAmountToApply: Decimal;
        LineAmount: Decimal;
    begin
        POSSaleLine.GetNewSaleLine(SaleLinePOS);

        GenJnlApply.CheckAgainstApplnCurrency(SaleLinePOS."Currency Code", CustLedgEntry."Currency Code", "Gen. Journal Account Type"::Customer, true);
        if (CustLedgEntry."Document Type" = CustLedgEntry."Document Type"::Invoice) and
           (SaleLinePOS.Date <= CustLedgEntry."Pmt. Discount Date")
        then
            LineAmount := (CustLedgEntry."Remaining Amount" - CustLedgEntry."Original Pmt. Disc. Possible")
        else
            LineAmount := CustLedgEntry."Remaining Amount";

        if CustLedgEntry."Currency Code" = SaleLinePOS."Currency Code" then
            ApplnAmountToApply := CustLedgEntry."Amount to Apply"
        else begin
            ApplnAmountToApply := ConvertFromCurrency(SaleLinePOS.Date, CustLedgEntry."Currency Code", SaleLinePOS."Currency Code", CustLedgEntry."Amount to Apply");
            LineAmount := ConvertFromCurrency(SaleLinePOS.Date, CustLedgEntry."Currency Code", SaleLinePOS."Currency Code", LineAmount);
        end;
        if (Abs(ApplnAmountToApply) < Abs(LineAmount)) and (ApplnAmountToApply <> 0) then
            LineAmount := ApplnAmountToApply;

        SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::"Customer Deposit";
        SaleLinePOS.Validate("No.", CustLedgEntry."Customer No.");
        SaleLinePOS."Buffer Document Type" := CustLedgEntry."Document Type";
        SaleLinePOS."Buffer Document No." := CustLedgEntry."Document No.";
        SaleLinePOS."Buffer ID" := CustLedgEntry."Applies-to ID";

        case CustLedgEntry."Document Type" of
            CustLedgEntry."Document Type"::Invoice:
                SaleLinePOS."Posted Sales Document Type" := SaleLinePOS."Posted Sales Document Type"::INVOICE;
            CustLedgEntry."Document Type"::"Credit Memo":
                SaleLinePOS."Posted Sales Document Type" := SaleLinePOS."Posted Sales Document Type"::CREDIT_MEMO;
        end;
        SaleLinePOS."Posted Sales Document No." := CustLedgEntry."Document No.";

        SaleLinePOS.Validate(Quantity, 1);
        SaleLinePOS.Validate("Unit Price", LineAmount);
        SaleLinePOS.Description := StrSubstNo(BALANCING_OF, FORMAT(CustLedgEntry."Document Type"), CustLedgEntry."Document No.");
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        SaleLinePOS."Copy Description" := CopyDesc;

        POSSaleLine.InsertLineRaw(SaleLinePOS, false);

        CustLedgEntry.SetRecFilter();
        ClearAppliesToID(CustLedgEntry);
    end;

    local procedure ClearAppliesToID(var CustLedgEntry: Record "Cust. Ledger Entry")
    var
        ApplyingCustLedgEntry: Record "Cust. Ledger Entry";
        CustEntrySetApplID: Codeunit "Cust. Entry-SetAppl.ID";
    begin
        CustEntrySetApplID.SetApplId(CustLedgEntry, ApplyingCustLedgEntry, '');
    end;

    local procedure ConvertFromCurrency(Date: Date; FromCurrencyCode: Code[10]; ToCurrencyCode: Code[10]; Amount: Decimal): Decimal
    var
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        ValidExchRate: Boolean;
    begin
        ValidExchRate := true;
        if ToCurrencyCode <> '' then
            Currency.Get(ToCurrencyCode)
        else
            Currency.InitRoundingPrecision();
        exit(Round(CurrExchRate.ApplnExchangeAmtFCYToFCY(Date, FromCurrencyCode, ToCurrencyCode, Amount, ValidExchRate), Currency."Amount Rounding Precision"));
    end;

    local procedure ClearAcceptedPmtTolerance(CustLedgEntry: Record "Cust. Ledger Entry")
    var
        AppliedCustLedgEntry: Record "Cust. Ledger Entry";
    begin
        if CustLedgEntry."Applies-to ID" = '' then
            exit;
        AppliedCustLedgEntry.SetCurrentKey("Customer No.", "Applies-to ID", Open);
        AppliedCustLedgEntry.SetRange("Customer No.", CustledgEntry."Customer No.");
        AppliedCustLedgEntry.SetRange(Open, true);
        AppliedCustLedgEntry.SetRange("Applies-to ID", CustLedgEntry."Applies-to ID");
        if AppliedCustLedgEntry.FindSet(true) then
            repeat
                AppliedCustLedgEntry."Accepted Payment Tolerance" := 0;
                AppliedCustLedgEntry."Accepted Pmt. Disc. Tolerance" := false;
                AppliedCustLedgEntry.Modify();
            until AppliedCustLedgEntry.Next() = 0;
    end;

    local procedure RestoreAppliesToIDMarks(SalePOS: Record "NPR POS Sale"; AppliesToID: Code[50])
    var
        ApplyingCustLedgEntry: Record "Cust. Ledger Entry";
        CustLedgEntry: Record "Cust. Ledger Entry";
        CustLedgEntry2: Record "Cust. Ledger Entry";
        SaleLinePOS: Record "NPR POS Sale Line";
        CustEntrySetApplID: Codeunit "Cust. Entry-SetAppl.ID";
        ApplnAmountToApply: Decimal;
    begin
        FilterPosSaleLines(SalePOS, SaleLinePOS);
        if not SaleLinePOS.FindSet() then
            exit;
        CustLedgEntry.SetCurrentKey("Document No.");
        CustLedgEntry.SetRange("Customer No.", SalePOS."Customer No.");
        CustLedgEntry.SetRange(Open, true);
        repeat
            CustLedgEntry.SetRange("Document No.", SaleLinePOS."Buffer Document No.");
            CustLedgEntry.SetRange("Document Type", SaleLinePOS."Buffer Document Type");
            if CustLedgEntry.FindFirst() then begin
                CustLedgEntry2 := CustLedgEntry;
                CustLedgEntry2.SetRecFilter();
                CustEntrySetApplID.SetApplId(CustLedgEntry2, ApplyingCustLedgEntry, AppliesToID);
                CustLedgEntry2.Find();
                if CustLedgEntry."Currency Code" = SaleLinePOS."Currency Code" then
                    ApplnAmountToApply := SaleLinePOS."Amount Including VAT"
                else
                    ApplnAmountToApply := ConvertFromCurrency(SaleLinePOS.Date, SaleLinePOS."Currency Code", CustLedgEntry."Currency Code", SalePOS."Amount Including VAT");
                if (Abs(CustLedgEntry2."Amount to Apply") > Abs(ApplnAmountToApply)) and (CustLedgEntry2."Amount to Apply" * ApplnAmountToApply > 0) then begin
                    CustLedgEntry2.Validate("Amount to Apply", ApplnAmountToApply);
                    CustLedgEntry2.Modify();
                end;
            end;
        until SaleLinePOS.Next() = 0;
        Commit();
    end;

    local procedure SelectCustLedgerEntry(SalePOSIn: Record "NPR POS Sale"; NewSaleLinePOS: Record "NPR POS Sale Line"; ApplnTypeSelect: Integer; var CustLedgEntry: Record "Cust. Ledger Entry"): Boolean
    var
        POSApplyCustomerEntries: Page "NPR POS Apply Cust. Entries";
        MPOSApplyCustEntries: Page "NPR MPOS Apply Cust. Entries";
    begin
        if CurrentClientType = ClientType::Phone then begin
            MPOSApplyCustEntries.SetPOSSaleLine(SalePOSIn, NewSaleLinePOS, ApplnTypeSelect);
            MPOSApplyCustEntries.SetRecord(CustLedgEntry);
            MPOSApplyCustEntries.SetTableView(CustLedgEntry);
            MPOSApplyCustEntries.LookupMode(true);
            exit(MPOSApplyCustEntries.RunModal() = ACTION::LookupOK);
        end else begin
            POSApplyCustomerEntries.SetPOSSaleLine(SalePOSIn, NewSaleLinePOS, ApplnTypeSelect);
            POSApplyCustomerEntries.SetRecord(CustLedgEntry);
            POSApplyCustomerEntries.SetTableView(CustLedgEntry);
            POSApplyCustomerEntries.LookupMode(true);
            exit(POSApplyCustomerEntries.RunModal() = ACTION::LookupOK);
        end;
    end;
}