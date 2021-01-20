codeunit 6151242 "NPR Activities Mgt."
{

    trigger OnRun()
    begin
        RefreshActivitiesCueData;
    end;

    var
        DefaultWorkDate: Date;
        RefreshFrequencyErr: Label 'Refresh intervals of less than 10 minutes are not supported.';

    procedure CalcOverdueSalesInvoiceAmount(CalledFromWebService: Boolean) Amount: Decimal
    var
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
    begin
        SetFilterForCalcOverdueSalesInvoiceAmount(DetailedCustLedgEntry, CalledFromWebService);
        DetailedCustLedgEntry.CalcSums("Amount (LCY)");
        Amount := Abs(DetailedCustLedgEntry."Amount (LCY)");
    end;

    procedure SetFilterForCalcOverdueSalesInvoiceAmount(var DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry"; CalledFromWebService: Boolean)
    begin
        DetailedCustLedgEntry.SetRange("Initial Document Type", DetailedCustLedgEntry."Initial Document Type"::Invoice);
        if CalledFromWebService then
            DetailedCustLedgEntry.SetFilter("Initial Entry Due Date", '<%1', Today)
        else
            DetailedCustLedgEntry.SetFilter("Initial Entry Due Date", '<%1', GetDefaultWorkDate);
    end;

    procedure DrillDownCalcOverdueSalesInvoiceAmount()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.SetFilter("Due Date", '<%1', GetDefaultWorkDate);
        CustLedgerEntry.SetFilter("Remaining Amt. (LCY)", '<>0');
        CustLedgerEntry.SetCurrentKey("Remaining Amt. (LCY)");
        CustLedgerEntry.Ascending := false;

        PAGE.Run(PAGE::"Customer Ledger Entries", CustLedgerEntry);
    end;

    procedure CalcOverduePurchaseInvoiceAmount(CalledFromWebService: Boolean) Amount: Decimal
    var
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
    begin
        SetFilterForCalcOverduePurchaseInvoiceAmount(DetailedVendorLedgEntry, CalledFromWebService);
        DetailedVendorLedgEntry.CalcSums("Amount (LCY)");
        Amount := Abs(DetailedVendorLedgEntry."Amount (LCY)");
    end;

    procedure SetFilterForCalcOverduePurchaseInvoiceAmount(var DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry"; CalledFromWebService: Boolean)
    begin
        DetailedVendorLedgEntry.SetRange("Initial Document Type", DetailedVendorLedgEntry."Initial Document Type"::Invoice);
        if CalledFromWebService then
            DetailedVendorLedgEntry.SetFilter("Initial Entry Due Date", '<%1', Today)
        else
            DetailedVendorLedgEntry.SetFilter("Initial Entry Due Date", '<%1', GetDefaultWorkDate);
    end;

    procedure DrillDownOverduePurchaseInvoiceAmount()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Invoice);
        VendorLedgerEntry.SetFilter("Due Date", '<%1', WorkDate);
        VendorLedgerEntry.SetFilter("Remaining Amt. (LCY)", '<>0');
        VendorLedgerEntry.SetCurrentKey("Remaining Amt. (LCY)");
        VendorLedgerEntry.Ascending := true;

        PAGE.Run(PAGE::"Vendor Ledger Entries", VendorLedgerEntry);
    end;

    procedure CalcSalesThisMonthAmount(CalledFromWebService: Boolean) Amount: Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        SetFilterForCalcSalesThisMonthAmount(CustLedgerEntry, CalledFromWebService);
        CustLedgerEntry.CalcSums("Sales (LCY)");
        Amount := CustLedgerEntry."Sales (LCY)";
    end;

    procedure SetFilterForCalcSalesThisMonthAmount(var CustLedgerEntry: Record "Cust. Ledger Entry"; CalledFromWebService: Boolean)
    begin
        CustLedgerEntry.SetFilter("Document Type", '%1|%2',
          CustLedgerEntry."Document Type"::Invoice, CustLedgerEntry."Document Type"::"Credit Memo");
        if CalledFromWebService then
            CustLedgerEntry.SetRange("Posting Date", CalcDate('<-CM>', Today), Today)
        else
            CustLedgerEntry.SetRange("Posting Date", CalcDate('<-CM>', GetDefaultWorkDate), GetDefaultWorkDate);
    end;


    procedure NPCalcSalesThisMonthAmount(CalledFromWebService: Boolean) Amount: Decimal
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.Reset;
        ItemLedgerEntry.SetFilter("Entry Type", '%1', ItemLedgerEntry."Entry Type"::Sale);
        ItemLedgerEntry.SetRange("Posting Date", CalcDate('<-CM>', Today), Today);
        IF ItemLedgerEntry.FindSet THEN begin
            repeat
                ItemLedgerEntry.CalcFields("sales Amount (Actual)");
                Amount += ItemLedgerEntry."sales Amount (Actual)";
            until ItemLedgerEntry.Next = 0;
        end;
    end;

    procedure NPCalcSalesThisMonthAmountLastYear(CalledFromWebService: Boolean) Amount: Decimal
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.Reset;
        ItemLedgerEntry.SetFilter("Entry Type", '%1', ItemLedgerEntry."Entry Type"::Sale);
        ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', CALCDATE('<-CM-1Y>', TODAY), CALCDATE('<CM-1Y>', TODAY));
        IF ItemLedgerEntry.FindSet THEN begin
            repeat
                ItemLedgerEntry.CalcFields("sales Amount (Actual)");
                Amount += ItemLedgerEntry."sales Amount (Actual)";
            until ItemLedgerEntry.Next = 0;
        end;
    end;

    procedure DrillDownSalesThisMonth()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetFilter("Document Type", '%1|%2',
          ItemLedgerEntry."Document Type"::"Sales Invoice", ItemLedgerEntry."Document Type"::"Sales Credit Memo");
        ItemLedgerEntry.SetRange("Posting Date", CalcDate('<-CM>', GetDefaultWorkDate), GetDefaultWorkDate);
        PAGE.Run(PAGE::"Item Ledger Entries", ItemLedgerEntry);
    end;

    procedure DrillDownSalesThisMonthLastYear()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetFilter("Document Type", '%1|%2',
          ItemLedgerEntry."Document Type"::"Sales Invoice", ItemLedgerEntry."Document Type"::"Sales Credit Memo");
        ItemLedgerEntry.SetRange("Posting Date", CalcDate('<-CM-12M>', GetDefaultWorkDate), GetDefaultWorkDate);
        PAGE.Run(PAGE::"Item Ledger Entries", ItemLedgerEntry);
    end;






    local procedure GetPaidSalesInvoices(var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange(Open, false);
        CustLedgerEntry.SetRange("Posting Date", CalcDate('<CM-3M>', GetDefaultWorkDate), GetDefaultWorkDate);
        CustLedgerEntry.SetRange("Closed at Date", CalcDate('<CM-3M>', GetDefaultWorkDate), GetDefaultWorkDate);
    end;

    procedure CalcCashAccountsBalances() CashAccountBalance: Decimal
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.SetRange("Account Category", GLAccount."Account Category"::Assets);
        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
        GLAccount.SetRange("Account Subcategory Entry No.", 3);
        if GLAccount.FindSet then begin
            repeat
                GLAccount.CalcFields(Balance);
                CashAccountBalance += GLAccount.Balance;
            until GLAccount.Next = 0;
        end;
    end;

    procedure DrillDownCalcCashAccountsBalances()
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.SetRange("Account Category", GLAccount."Account Category"::Assets);
        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
        GLAccount.SetRange("Account Subcategory Entry No.", 3);
        PAGE.Run(PAGE::"Chart of Accounts", GLAccount);
    end;

    local procedure RefreshActivitiesCueData()
    var
        ActivitiesCue: Record "Activities Cue";
    begin
        ActivitiesCue.LockTable;

        ActivitiesCue.Get;
        ActivitiesCue."NPR Sales This Month Last Year" := NPCalcSalesThisMonthAmountLastYear(false);
        ActivitiesCue."NPR Sales This Month ILE" := NPCalcSalesThisMonthAmount(false);

        ActivitiesCue."Last Date/Time Modified" := CurrentDateTime;
        ActivitiesCue.Modify;
        Commit;
    end;

    procedure IsCueDataStale(): Boolean
    var
        ActivitiesCue: Record "Activities Cue";
    begin
        if not ActivitiesCue.Get then
            exit(false);

        exit(IsPassedCueDataStale(ActivitiesCue));
    end;

    local procedure IsPassedCueDataStale(ActivitiesCue: Record "Activities Cue"): Boolean
    begin
        if ActivitiesCue."Last Date/Time Modified" = 0DT then
            exit(true);

        exit(CurrentDateTime - ActivitiesCue."Last Date/Time Modified" >= GetActivitiesCueRefreshInterval)
    end;

    local procedure GetDefaultWorkDate(): Date
    var
        LogInManagement: Codeunit LogInManagement;
    begin
        if DefaultWorkDate = 0D then
            DefaultWorkDate := LogInManagement.GetDefaultWorkDate;
        exit(DefaultWorkDate);
    end;

    local procedure GetActivitiesCueRefreshInterval() Interval: Duration
    var
        MinInterval: Duration;
    begin
        MinInterval := 10 * 60 * 1000; // 10 minutes
        Interval := 60 * 60 * 1000; // 1 hr
        OnGetRefreshInterval(Interval);
        if Interval < MinInterval then
            Error(RefreshFrequencyErr);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetRefreshInterval(var Interval: Duration)
    begin
    end;
}

