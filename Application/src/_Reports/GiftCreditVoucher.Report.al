report 6014522 "NPR Gift-Credit Voucher"
{
#IF NOT BC17
    Extensible = false;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Gift-Credit Voucher.rdlc';
    ApplicationArea = NPRRetail;
    Caption = 'Gift/Credit Vouchers';
    UsageCategory = ReportsAndAnalysis;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Integer; Integer)
        {
            MaxIteration = 1;
            DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
            column(CompanyInfoName; CompanyInfo.Name)
            {
            }
            column(GiftOpenVoucherAmount; GiftOpenVoucherAmount)
            {
            }
            column(CreditOpenVoucherAmount; CreditOpenVoucherAmount)
            {
            }
            column(TotalGiftVoucherCountPercent; TotalGiftVoucherCountPercent)
            {
            }
            column(TotalCreditVoucherCountPercent; TotalCreditVoucherCountPercent)
            {
            }
            column(TotalOpenVouchersPercent; TotalOpenVouchersPercent)
            {
            }
            column(GiftVoucherAccountBalance; GiftVoucherAccountBalance)
            {
            }
            column(CreditVoucherAccountBalance; CreditVoucherAccountBalance)
            {
            }
            column(GiftVoucherAccountNo; GiftVoucherAccountNo)
            {
            }
            column(CreditVoucherAccountNo; CreditVoucherAccountNo)
            {
            }
            column(RedeemedGiftVoucherAmountVchrEntry; RedeemedGiftVoucherAmountVchrEntry)
            {
            }
            column(RedeemedCreditVoucherAmountVchrEntry; RedeemedCreditVoucherAmountVchrEntry)
            {
            }
            column(RedeemedGiftVoucherAmountArchVchrEntry; RedeemedGiftVoucherAmountArchVchrEntry)
            {
            }
            column(RedeemedCreditVoucherAmountArchVchrEntry; RedeemedCreditVoucherAmountArchVchrEntry)
            {
            }
            column(GiftArchAmount; GiftArchAmount)
            {
            }
            column(CreditArchAmount; CreditArchAmount)
            {
            }
            column(DateFilter; DateFilter)
            {
            }
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field(Date_Filter; DateFilter)
                    {
                        Caption = 'Date Filter';
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Date Filter field.';
                        trigger OnValidate()
                        var
                            FilterTokens: Codeunit "Filter Tokens";
                        begin
                            FilterTokens.MakeDateFilter(DateFilter);
                        end;
                    }
                }
            }
        }
    }

    labels
    {
        ReportCaption = 'Gift Voucher / Credit Voucher';
        GiftVocherLbl = 'Gift Voucher';
        CreditVoucherLbl = 'Credit Voucher';
        BothCaptionLbl = 'Total Gift & Credit Voucher';
        AmountLbl = 'Amount';
        ArchivedLbl = 'Archived';
        RedeemedLbl = 'Redeemed';
        OpenLbl = 'Open';
        TotalLbl = 'Total';
        PercentLbl = '%';
        KeyFiguresLbl = 'Key Figures:';
        GLAccountsBalanceLbl = 'Balance on General Ledger Account';
        DateFilterLbl = 'Date Filter';
    }

    trigger OnPreReport()
    var
        TotalOpenVoucherCount: Integer;
    begin
        CompanyInfo.Get();

        if DateFilter <> '' then begin
            RetailVouchers.SetFilter("Issue Date", DateFilter);
            VoucherEntry.SetFilter("Posting Date", DateFilter);
            ArchivedVoucherEntry.SetFilter("Posting Date", DateFilter);
        end;

        TotalVoucherCount := RetailVouchers.Count();
        RetailVouchers.SetRange(Open, true);
        TotalOpenVoucherCount := RetailVouchers.Count();
        RetailVouchers.SetRange(Open);
        RetailVouchers.SetRange("Voucher Type", GiftVoucherLbl);
        TotalGiftVoucherCount := RetailVouchers.Count();
        RetailVouchers.SetRange("Voucher Type", CreditVoucherLbl);
        TotalCreditVoucherCount := RetailVouchers.Count();

        TotalOpenVouchersPercent := TotalOpenVoucherCount / TotalVoucherCount * 100;
        TotalGiftVoucherCountPercent := TotalGiftVoucherCount / TotalVoucherCount * 100;
        TotalCreditVoucherCountPercent := TotalCreditVoucherCount / TotalVoucherCount * 100;

        VoucherEntry.SetRange("Entry Type", VoucherEntry."Entry Type"::Payment);
        VoucherEntry.SetRange("Voucher Type", GiftVoucherLbl);
        VoucherEntry.CalcSums(Amount);
        RedeemedGiftVoucherAmountVchrEntry := Abs(VoucherEntry.Amount);
        VoucherEntry.SetRange("Entry Type");
        VoucherEntry.SetRange(Open, true);
        VoucherEntry.CalcSums("Remaining Amount");
        GiftOpenVoucherAmount := VoucherEntry."Remaining Amount";
        VoucherEntry.SetRange(Open);
        VoucherEntry.SetRange("Entry Type", VoucherEntry."Entry Type"::Payment);
        VoucherEntry.SetRange("Voucher Type", CreditVoucherLbl);
        VoucherEntry.CalcSums(Amount);
        RedeemedCreditVoucherAmountVchrEntry := Abs(VoucherEntry.Amount);
        VoucherEntry.SetRange("Entry Type");
        VoucherEntry.SetRange(Open, true);
        VoucherEntry.CalcSums("Remaining Amount");
        CreditOpenVoucherAmount := VoucherEntry."Remaining Amount";

        ArchivedVoucherEntry.SetRange("Entry Type", ArchivedVoucherEntry."Entry Type"::Payment);
        ArchivedVoucherEntry.SetRange("Voucher Type", GiftVoucherLbl);
        ArchivedVoucherEntry.CalcSums(Amount);
        RedeemedGiftVoucherAmountArchVchrEntry := Abs(ArchivedVoucherEntry.Amount);
        ArchivedVoucherEntry.SetRange("Voucher Type", CreditVoucherLbl);
        ArchivedVoucherEntry.CalcSums(Amount);
        RedeemedCreditVoucherAmountArchVchrEntry := Abs(ArchivedVoucherEntry.Amount);

        ArchivedVoucherEntry.SetFilter("Entry Type", '=%1|%2|%3|%4', ArchivedVoucherEntry."Entry Type"::"Issue Voucher", ArchivedVoucherEntry."Entry Type"::"Partner Issue Voucher", ArchivedVoucherEntry."Entry Type"::"Top-up", ArchivedVoucherEntry."Entry Type"::"Partner Top-up");
        ArchivedVoucherEntry.SetRange("Voucher Type", GiftVoucherLbl);
        ArchivedVoucherEntry.CalcSums(Amount);
        GiftArchAmount := ArchivedVoucherEntry.Amount;
        ArchivedVoucherEntry.SetRange("Voucher Type", CreditVoucherLbl);
        ArchivedVoucherEntry.CalcSums(Amount);
        CreditArchAmount := ArchivedVoucherEntry.Amount;

        GetAccountNoAndBalance(GiftVoucherLbl, GiftVoucherAccountNo, GiftVoucherAccountBalance);
        GetAccountNoAndBalance(CreditVoucherLbl, CreditVoucherAccountNo, CreditVoucherAccountBalance);
    end;

    var
        CompanyInfo: Record "Company Information";
        RetailVouchers: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        ArchivedVoucherEntry: Record "NPR NpRv Arch. Voucher Entry";
        GiftOpenVoucherAmount: Decimal;
        CreditOpenVoucherAmount: Decimal;
        GiftArchAmount: Decimal;
        CreditArchAmount: Decimal;
        TotalGiftVoucherCount: Decimal;
        TotalCreditVoucherCount: Decimal;
        TotalGiftVoucherCountPercent: Decimal;
        TotalCreditVoucherCountPercent: Decimal;
        TotalOpenVouchersPercent: Decimal;
        GiftVoucherAccountBalance: Decimal;
        CreditVoucherAccountBalance: Decimal;
        RedeemedGiftVoucherAmountVchrEntry: Decimal;
        RedeemedCreditVoucherAmountVchrEntry: Decimal;
        RedeemedGiftVoucherAmountArchVchrEntry: Decimal;
        RedeemedCreditVoucherAmountArchVchrEntry: Decimal;
        TotalVoucherCount: Integer;
        GiftVoucherAccountNo: Code[20];
        CreditVoucherAccountNo: Code[20];
        DateFilter: Text;
        GiftVoucherLbl: Label 'GIFTVOUCHER', Locked = true;
        CreditVoucherLbl: Label 'CREDITVOUCHER', Locked = true;

    local procedure GetAccountNoAndBalance(VoucherTypeCode: Code[20]; var VoucherTypeAccountNo: Code[20]; var VoucherTypeBalance: Decimal)
    var
        RetailVoucherType: Record "NPR NpRv Voucher Type";
        GLAccount: Record "G/L Account";
    begin
        if not (RetailVoucherType.Get(VoucherTypeCode) and (RetailVoucherType."Account No." <> '')) then
            exit;
        GLAccount.SetAutoCalcFields(Balance);
        if not GLAccount.Get(RetailVoucherType."Account No.") then
            exit;
        VoucherTypeAccountNo := GLAccount."No.";
        VoucherTypeBalance := GLAccount.Balance;
    end;
}
