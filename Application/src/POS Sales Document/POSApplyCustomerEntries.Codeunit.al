codeunit 6014410 "NPR POS Apply Customer Entries"
{
    Permissions = TableData "Cust. Ledger Entry" = rimd;
    TableNo = "NPR POS Sale Line";

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        Txt001: Label 'Application cancelled.';
        Txt002: Label '%1 in %2 will be change from %3 to %4.\Continue?';
        Txt003: Label 'Balancing of %1.';
        CustLedgerEntryView: Text;
        ERROR_DOUBLE_ENTRY: Label 'Error. Document %1 %2 is already selected for balancing.';
        CONFIRM_BALANCE: Label 'Do you wish to apply %1 %2 for customer %3?';
        BALANCING_OF: Label 'Balancing of %1';

    procedure DeleteExistingLines(var SaleLinePOS: Record "NPR POS Sale Line")
    begin
        SaleLinePOS.SetRange("Register No.", SaleLinePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        SaleLinePOS.SetFilter("Buffer Document No.", '<>%1', '');
        SaleLinePOS.DeleteAll;
    end;

    procedure GetLineNo(var SaleLinePOS: Record "NPR POS Sale Line") LineNo: Integer
    begin
        SaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", "Line No.");
        SaleLinePOS.SetRange("Register No.", SaleLinePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        SaleLinePOS.SetFilter("Buffer Document No.", '<>%1', '');
        if SaleLinePOS.Find('+') then
            LineNo := SaleLinePOS."Line No."
        else
            LineNo := 10000;
    end;

    procedure CheckCurrency(ApplicationCurrencyCode: Code[10]; CompareToCurrencyCode: Code[10]; AccountType: Option "G/L",Customer,Vendor,Bank,"Fixed Asset"; ShowError: Boolean): Boolean
    var
        Currency: Record Currency;
        Currency2: Record Currency;
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        CurrencyApplication: Option "None",EMU,All;
        Txt001: Label 'All Ledger Entries must be the same currency';
        Txt002: Label 'All Ledger Entries must be the same currency,or in one or more of the EMU-Currencies';
        Txt003: Label 'All Ledger Entries on a Vendor must be the same currency';
    begin
        if (ApplicationCurrencyCode = CompareToCurrencyCode) then
            exit(true);

        case AccountType of
            AccountType::Customer:
                begin
                    SalesReceivablesSetup.Get;
                    CurrencyApplication := SalesReceivablesSetup."Appln. between Currencies";
                    case CurrencyApplication of
                        CurrencyApplication::None:
                            begin
                                if ApplicationCurrencyCode <> CompareToCurrencyCode then
                                    if ShowError then
                                        Error(Txt001)
                                    else
                                        exit(false);
                            end;
                        CurrencyApplication::EMU:
                            begin
                                GeneralLedgerSetup.Get;
                                if not Currency.Get(ApplicationCurrencyCode) then
                                    Currency."EMU Currency" := GeneralLedgerSetup."EMU Currency";
                                if not Currency2.Get(CompareToCurrencyCode) then
                                    Currency2."EMU Currency" := GeneralLedgerSetup."EMU Currency";
                                if not Currency."EMU Currency" or not Currency2."EMU Currency" then
                                    if ShowError then
                                        Error(Txt002)
                                    else
                                        exit(false);
                            end;
                    end;
                end;
            AccountType::Vendor:
                begin
                    PurchasesPayablesSetup.Get;
                    CurrencyApplication := PurchasesPayablesSetup."Appln. between Currencies";
                    case CurrencyApplication of
                        CurrencyApplication::None:
                            begin
                                if ApplicationCurrencyCode <> CompareToCurrencyCode then
                                    if ShowError then
                                        Error(Txt003)
                                    else
                                        exit(false);
                            end;
                        CurrencyApplication::EMU:
                            begin
                                GeneralLedgerSetup.Get;
                                if not Currency.Get(ApplicationCurrencyCode) then
                                    Currency."EMU Currency" := GeneralLedgerSetup."EMU Currency";
                                if not Currency2.Get(CompareToCurrencyCode) then
                                    Currency2."EMU Currency" := GeneralLedgerSetup."EMU Currency";
                                if not Currency."EMU Currency" or not Currency2."EMU Currency" then
                                    if ShowError then
                                        Error(Txt002)
                                    else
                                        exit(false);
                            end;
                    end;
                end;
        end;

        exit(true);
    end;

    procedure SetCustLedgerEntryView(TableView: Text)
    begin
        CustLedgerEntryView := TableView;
    end;

    procedure SelectCustomerEntries(var POSSession: Codeunit "NPR POS Session"; CustLedgerEntryView: Text)
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        CustLedgEntry: Record "Cust. Ledger Entry";
        POSApplyCustomerEntries: Page "NPR POS Apply Cust. Entries";
    begin
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);

        SalePOS.TestField("Customer No.");
        SalePOS.TestField("Customer Type", SalePOS."Customer Type"::Ord);
        if CustLedgerEntryView <> '' then
            CustLedgEntry.SetView(CustLedgerEntryView);
        CustLedgEntry.SetRange("Customer No.", SalePOS."Customer No.");
        CustLedgEntry.SetRange(Open, true);
        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS."Buffer ID" := StrSubstNo('%1-%2', SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.");
        POSApplyCustomerEntries.SetSalesLine(SaleLinePOS, SaleLinePOS.FieldNo("Buffer ID"));
        POSApplyCustomerEntries.SetRecord(CustLedgEntry);
        POSApplyCustomerEntries.SetTableView(CustLedgEntry);
        POSApplyCustomerEntries.LookupMode(true);
        if POSApplyCustomerEntries.RunModal <> ACTION::LookupOK then
            exit;
        DeleteExistingLines(SaleLinePOS);
        POSSaleLine.RefreshCurrent();

        CustLedgEntry.Reset;
        CustLedgEntry.SetAutoCalcFields("Remaining Amount");
        CustLedgEntry.SetRange("Customer No.", SalePOS."Customer No.");
        CustLedgEntry.SetRange(Open, true);
        CustLedgEntry.SetRange("Applies-to ID", UserId);

        if not CustLedgEntry.FindSet then
            exit;

        repeat
            CreateApplyingPOSSaleLine(POSSaleLine, CustLedgEntry);
        until CustLedgEntry.Next = 0;
    end;

    procedure BalanceDocument(var POSSession: Codeunit "NPR POS Session"; DocumentType: Enum "Gen. Journal Document Type"; DocumentNo: Code[20]; Silent: Boolean)
    var
        Customer: Record Customer;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SaleLinePOSCheck: Record "NPR POS Sale Line";
        LineAmount: Decimal;
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
    begin
        if DocumentNo = '' then
            exit;

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);

        CustLedgerEntry.SetAutoCalcFields("Remaining Amount");
        CustLedgerEntry.SetRange("Document Type", DocumentType);
        CustLedgerEntry.SetRange("Document No.", DocumentNo);
        if SalePOS."Customer Type" = SalePOS."Customer Type"::Ord then
            if SalePOS."Customer No." <> '' then
                CustLedgerEntry.SetRange("Customer No.", SalePOS."Customer No.");
        CustLedgerEntry.FindFirst;
        CustLedgerEntry.TestField(Open);

        if not Silent then
            if not Confirm(StrSubstNo(CONFIRM_BALANCE, CustLedgerEntry."Document Type", CustLedgerEntry."Document No.", CustLedgerEntry."Customer No."), true) then
                Error('');

        if SalePOS."Customer No." = '' then begin
            SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
            SalePOS.Validate("Customer No.", CustLedgerEntry."Customer No.");
            SalePOS.Modify;
            POSSale.RefreshCurrent();
        end else begin
            SalePOS.TestField("Customer Type", SalePOS."Customer Type"::Ord);
            SalePOS.TestField("Customer No.", CustLedgerEntry."Customer No.");
        end;

        CreateApplyingPOSSaleLine(POSSaleLine, CustLedgerEntry);
    end;

    local procedure CreateApplyingPOSSaleLine(var POSSaleLine: Codeunit "NPR POS Sale Line"; CustLedgerEntry: Record "Cust. Ledger Entry")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        LineAmount: Decimal;
    begin
        POSSaleLine.GetNewSaleLine(SaleLinePOS);

        with SaleLinePOS do begin
            if (Type = Type::Customer) and
               ("Sale Type" = "Sale Type"::Deposit) and
                 (CustLedgerEntry."Document Type" = CustLedgerEntry."Document Type"::Invoice) and
                   (Date <= CustLedgerEntry."Pmt. Discount Date") then
                LineAmount := (CustLedgerEntry."Remaining Amount" - CustLedgerEntry."Original Pmt. Disc. Possible")
            else
                LineAmount := CustLedgerEntry."Remaining Amount";

            "Sale Type" := "Sale Type"::Deposit;
            Type := SaleLinePOS.Type::Customer;
            Validate("No.", CustLedgerEntry."Customer No.");
            "Buffer Document Type" := CustLedgerEntry."Document Type";
            "Buffer Document No." := CustLedgerEntry."Document No.";
            "Buffer ID" := "Register No." + '-' + "Sales Ticket No.";

            case CustLedgerEntry."Document Type" of
                CustLedgerEntry."Document Type"::Invoice:
                    begin
                        "Posted Sales Document Type" := "Posted Sales Document Type"::INVOICE;
                        "Posted Sales Document No." := CustLedgerEntry."Document No.";
                    end;
                CustLedgerEntry."Document Type"::"Credit Memo":
                    begin
                        "Posted Sales Document Type" := "Posted Sales Document Type"::CREDIT_MEMO;
                        "Posted Sales Document No." := CustLedgerEntry."Document No.";
                    end;
            end;

            Validate(Quantity, 1);
            Validate("Unit Price", LineAmount);
            Description := StrSubstNo(BALANCING_OF, CustLedgerEntry.Description);

            CheckCurrency(SaleLinePOS."Currency Code", CustLedgerEntry."Currency Code", 1, true);
            UpdateAmounts(SaleLinePOS);
        end;

        POSSaleLine.InsertLineRaw(SaleLinePOS, false);
    end;
}

