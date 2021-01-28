report 6014415 "NPR Gift/Credit Voucher"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Gift VoucherCredit Voucher.rdlc';
    Caption = 'Gift Voucher/Credit Voucher';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number) ORDER(Ascending);
            MaxIteration = 1;
            column(PageNoCaptionLbl; PageNoCaptionLbl)
            {
            }
            column(Report_Caption; Report_Caption_Lbl)
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column(Gift_Voucher_Caption; Gift_Voucher_Caption_Lbl)
            {
            }
            column(No_Caption; No_Caption_Lbl)
            {
            }
            column(Sales_Ticket_No_Caption; Sales_Ticket_No_Caption_Lbl)
            {
            }
            column(Issue_Date_Caption; Issue_Date_Caption_Lbl)
            {
            }
            column(Cashed_Date_Caption; Cashed_Date_Caption_Lbl)
            {
            }
            column(Status_Caption; Status_Caption_Lbl)
            {
            }
            column(Amount_Caption; Amount_Caption_Lbl)
            {
            }
            column(Gift_Voucher_Total_Caption; Gift_Voucher_Total_Caption_Lbl)
            {
            }
            column(Credit_Voucher_Caption; Credit_Voucher_Caption_Lbl)
            {
            }
            column(Credit_Voucher_Total_Caption; Credit_Voucher_Total_Caption_Lbl)
            {
            }
            column(Total_Caption; Total_Caption_Lbl)
            {
            }
            column(Pct_Caption; Pct_Caption_Lbl)
            {
            }
            column(Cashed_Caption; Cashed_Caption_Lbl)
            {
            }
            column(Open_Caption; Open_Caption_Lbl)
            {
            }
            column(Cancelled_Caption; Cancelled_Caption_Lbl)
            {
            }
            column(Key_Figures_Caption; Key_Figures_Caption_Lbl)
            {
            }
            column(Total_GL_Accounts_Caption; Total_GL_Accounts_Caption_Lbl)
            {
            }
            column(Gift_Vouchers_Caption; Gift_Vouchers_Caption_Lbl)
            {
            }
            column(Credit_Vouchers_Caption; Credit_Vouchers_Caption_Lbl)
            {
            }
            column(Gift_Credit_Total_Caption; Gift_Credit_Total_Caption_Lbl)
            {
            }
            column(ShowGiftOnly; ShowGiftOnly)
            {
            }
            column(ShowCreditOnly; ShowCreditOnly)
            {
            }
            column(ShowPosting; ShowPosting)
            {
            }
            column(Number_Integer; Integer.Number)
            {
            }
            column(GV_Filters; GV_Filters)
            {
            }
            column(AddFilters; AddFilters)
            {
            }
        }
        dataitem("Gift Voucher"; "NPR Gift Voucher")
        {
            DataItemTableView = SORTING(Status, "Issue Date", "Cashed Date", "External Gift Voucher") WHERE("External Gift Voucher" = FILTER(= false));
            RequestFilterFields = "Issue Date", Status, "Cashed Date", "Shortcut Dimension 1 Code", "Location Code";
            RequestFilterHeading = 'Gift Voucher/Credit Voucher';
            column(No_Gift_Voucher; "Gift Voucher"."No.")
            {
            }
            column(Sales_Ticket_No_Gift_Voucher; "Gift Voucher"."Sales Ticket No.")
            {
            }
            column(Issue_Date_Gift_Voucher; "Gift Voucher"."Issue Date")
            {
            }
            column(Cashed_Date_Gift_Voucher; "Gift Voucher"."Cashed Date")
            {
            }
            column(Status_Gift_Voucher; "Gift Voucher".Status)
            {
            }
            column(Amount_Gift_Voucher; "Gift Voucher".Amount)
            {
            }
            column(Gift_Voucher_Filters; Format("Gift Voucher".GetFilters))
            {
            }

            trigger OnPreDataItem()
            begin
                Filter := Format("Gift Voucher".GetFilters);
                GiftVoucherCashed.CopyFilters("Gift Voucher");

                Location := GetFilter("Location Code");

                if Location <> '' then
                    SetFilter("Location Code", '%1', Location);

                if "Gift Voucher".GetFilter("Cashed Date") = '' then
                    CurrReport.Break();

                if ShowCreditOnly and not ShowGiftOnly then
                    CurrReport.Break();
            end;
        }
        dataitem("Credit Voucher"; "NPR Credit Voucher")
        {
            DataItemTableView = SORTING(Status, "Issue Date", "Cashed Date", "External Credit Voucher", "Location Code") WHERE("External Credit Voucher" = FILTER(= false));
            column(No_Credit_Voucher; "Credit Voucher"."No.")
            {
            }
            column(Sales_Ticket_No_Credit_Voucher; "Credit Voucher"."Sales Ticket No.")
            {
            }
            column(Issue_Date_Credit_Voucher; "Credit Voucher"."Issue Date")
            {
            }
            column(Cashed_Date_Credit_Voucher; "Credit Voucher"."Cashed Date")
            {
            }
            column(Status_Credit_Voucher; "Credit Voucher".Status)
            {
            }
            column(Amount_Credit_Voucher; "Credit Voucher".Amount)
            {
            }
            column(Credit_Voucher_FILTERS; Format("Credit Voucher".GetFilters))
            {
            }

            trigger OnPreDataItem()
            begin
                "Gift Voucher".CopyFilter("Issue Date", "Credit Voucher"."Issue Date");
                "Gift Voucher".CopyFilter("Cashed Date", "Credit Voucher"."Cashed Date");

                if Location <> '' then
                    SetFilter("Location Code", '%1', Location);

                "Gift Voucher".CopyFilter("External Gift Voucher", "Credit Voucher"."External Credit Voucher");

                if ShowGiftOnly and not ShowCreditOnly then
                    CurrReport.Break();

                if "Gift Voucher".GetFilter("Cashed Date") = '' then
                    CurrReport.Break();
            end;
        }
        dataitem(GiftVoucherCashed; "NPR Gift Voucher")
        {
            DataItemTableView = SORTING(Status, "Issue Date", "Cashed Date", "External Gift Voucher") WHERE("External Gift Voucher" = FILTER(= false));
            column(No_GiftVoucherCashed; GiftVoucherCashed."No.")
            {
            }
            column(Sales_Ticket_No_GiftVoucherCashed; GiftVoucherCashed."Sales Ticket No.")
            {
            }
            column(Issue_Date_GiftVoucherCashed; GiftVoucherCashed."Issue Date")
            {
            }
            column(Cashed_Date_GiftVoucherCashed; GiftVoucherCashed."Cashed Date")
            {
            }
            column(Status_GiftVoucherCashed; GiftVoucherCashed.Status)
            {
            }
            column(Amount_GiftVoucherCashed; GiftVoucherCashed.Amount)
            {
            }
            column(GiftVoucherCashed_FILTERS; Format(GiftVoucherCashed.GetFilters))
            {
            }

            trigger OnPreDataItem()
            begin
                if ShowCreditOnly and not ShowGiftOnly then
                    CurrReport.Break();

                GiftVoucherCashed.CopyFilters("Gift Voucher");

                if "Gift Voucher".GetFilter("Cashed Date") <> '' then
                    CurrReport.Break();
            end;
        }
        dataitem(Integer_GiftVoucher; "Integer")
        {
            DataItemTableView = SORTING(Number) ORDER(Ascending);
            MaxIteration = 1;
            column(Number_Integer_GiftVoucher; Integer_GiftVoucher.Number)
            {
            }
            column(TestVar; TestVar)
            {
            }
            column(TotalAmtGV; TotalAmtGV)
            {
            }
            column(TotalCancelledGV; TotalCancelledGV)
            {
            }
            column(TotalRedeemedGV; TotalRedeemedGV)
            {
            }
            column(TotalOpenGV; TotalOpenGV)
            {
            }
            column(PercentGV; PercentGV)
            {
            }
            column(PercentGVDiff; PercentGVDiff)
            {
            }

            trigger OnAfterGetRecord()
            begin
                GiftVoucher2.SetCurrentKey(Status, "Issue Date", "Cashed Date", "External Gift Voucher", "Location Code");
                if "Gift Voucher".GetFilter("Issue Date") <> '' then
                    "Gift Voucher".CopyFilter("Issue Date", GiftVoucher2."Issue Date");
                GiftVoucher2.SetRange(Status, GiftVoucher2.Status::Cashed);
                GiftVoucher2.SetFilter("External Gift Voucher", '=%1', false);
                if Location <> '' then
                    GiftVoucher2.SetRange("Location Code", Location);
                GiftVoucher2.CalcSums(Amount);
                TotalRedeemedGV := GiftVoucher2.Amount;

                GiftVoucher2.SetRange(Status, GiftVoucher2.Status::Cancelled);
                GiftVoucher2.SetFilter("External Gift Voucher", '=%1', false);
                if Location <> '' then
                    GiftVoucher2.SetRange("Location Code", Location);
                GiftVoucher2.CalcSums(Amount);
                TotalCancelledGV := GiftVoucher2.Amount;

                GiftVoucher2.SetRange(Status, GiftVoucher2.Status::Open);
                GiftVoucher2.SetFilter("External Gift Voucher", '=%1', false);
                if Location <> '' then
                    GiftVoucher2.SetRange("Location Code", Location);
                GiftVoucher2.CalcSums(Amount);
                TotalOpenGV := GiftVoucher2.Amount;

                GiftVoucher2.SetRange(Status);
                if Location <> '' then
                    GiftVoucher2.SetRange("Location Code", Location);
                GiftVoucher2.CalcSums(Amount);
                TotalAmtGV := GiftVoucher2.Amount;

                if TotalAmtGV <> 0 then
                    PercentGV := 100 * (TotalRedeemedGV / TotalAmtGV);

                if TotalAmtGV <> 0 then
                    PercentGVDiff := 100 - (100 * (TotalRedeemedGV / TotalAmtGV));
            end;

            trigger OnPreDataItem()
            begin
                if ShowCreditOnly and not ShowGiftOnly then
                    CurrReport.Break();

                if "Gift Voucher".GetFilter("Cashed Date") <> '' then
                    CurrReport.Break();
            end;
        }
        dataitem(CreditVoucherCashed; "NPR Credit Voucher")
        {
            DataItemTableView = SORTING(Status, "Issue Date", "Cashed Date", "External Credit Voucher") WHERE("External Credit Voucher" = FILTER(= false));
            column(No_CreditVoucherCashed; CreditVoucherCashed."No.")
            {
            }
            column(Sales_Ticket_No_CreditVoucherCashed; CreditVoucherCashed."Sales Ticket No.")
            {
            }
            column(Issue_Date_CreditVoucherCashed; CreditVoucherCashed."Issue Date")
            {
            }
            column(Cashed_Date_CreditVoucherCashed; CreditVoucherCashed."Cashed Date")
            {
            }
            column(Status_Credit_CreditVoucherCashed; CreditVoucherCashed.Status)
            {
            }
            column(Amount_Credit_CreditVoucherCashed; CreditVoucherCashed.Amount)
            {
            }
            column(CreditVoucherCashed_FILTERS; Format(CreditVoucherCashed.GetFilters))
            {
            }

            trigger OnPreDataItem()
            begin
                if ShowGiftOnly and not ShowCreditOnly then
                    CurrReport.Break();

                if "Gift Voucher".GetFilter("Cashed Date") <> '' then
                    CurrReport.Break();

                "Gift Voucher".CopyFilter("Issue Date", CreditVoucherCashed."Issue Date");
                "Gift Voucher".CopyFilter("Cashed Date", CreditVoucherCashed."Cashed Date");
                "Gift Voucher".CopyFilter(Status, CreditVoucherCashed.Status);
                "Gift Voucher".CopyFilter("External Gift Voucher", CreditVoucherCashed."External Credit Voucher");

                if Location <> '' then
                    SetFilter("Location Code", '%1', Location);
            end;
        }
        dataitem(Integer_CreditVoucher; "Integer")
        {
            DataItemTableView = SORTING(Number) ORDER(Ascending);
            MaxIteration = 1;
            column(Number_Integer_CreditVoucher; Integer_CreditVoucher.Number)
            {
            }
            column(TotalAmtCV; TotalAmtCV)
            {
            }
            column(TotalCancelledCV; TotalCancelledCV)
            {
            }
            column(TotalRedeemedCV; TotalRedeemedCV)
            {
            }
            column(TotalOpenCV; TotalOpenCV)
            {
            }
            column(PercentCV; PercentCV)
            {
            }
            column(PercentCVDiff; PercentCVDiff)
            {
            }

            trigger OnAfterGetRecord()
            begin
                CreditVoucher2.SetCurrentKey(Status, "Issue Date", "Cashed Date", "External Credit Voucher", "Location Code");
                if "Gift Voucher".GetFilter("Issue Date") <> '' then
                    "Gift Voucher".CopyFilter("Issue Date", CreditVoucher2."Issue Date");

                CreditVoucher2.SetRange(Status, CreditVoucher2.Status::Cashed);
                if Location <> '' then
                    CreditVoucher2.SetRange("Location Code", Location);
                CreditVoucher2.SetFilter("External Credit Voucher", '=%1', false);
                CreditVoucher2.CalcSums(Amount);
                TotalRedeemedCV := CreditVoucher2.Amount;

                CreditVoucher2.SetRange(Status, CreditVoucher2.Status::Cancelled);
                if Location <> '' then
                    CreditVoucher2.SetRange("Location Code", Location);
                CreditVoucher2.SetFilter("External Credit Voucher", '=%1', false);
                CreditVoucher2.CalcSums(Amount);
                TotalCancelledCV := CreditVoucher2.Amount;

                CreditVoucher2.SetRange(Status, CreditVoucher2.Status::Open);
                if Location <> '' then
                    CreditVoucher2.SetRange("Location Code", Location);
                CreditVoucher2.SetFilter("External Credit Voucher", '=%1', false);
                CreditVoucher2.CalcSums(Amount);
                TotalOpenCV := CreditVoucher2.Amount;

                CreditVoucher2.SetRange(Status);
                if Location <> '' then
                    CreditVoucher2.SetRange("Location Code", Location);
                CreditVoucher2.CalcSums(Amount);
                TotalAmtCV := CreditVoucher2.Amount;

                if TotalAmtCV <> 0 then
                    PercentCV := 100 * (TotalRedeemedCV / TotalAmtCV);

                if TotalAmtCV <> 0 then
                    PercentCVDiff := 100 - (100 * (TotalRedeemedCV / TotalAmtCV));
            end;

            trigger OnPreDataItem()
            begin
                if ShowGiftOnly and not ShowCreditOnly then
                    CurrReport.Break();

                if "Gift Voucher".GetFilter("Cashed Date") <> '' then
                    CurrReport.Break();
            end;
        }
        dataitem(Integer2_CreditVoucher; "Integer")
        {
            DataItemTableView = SORTING(Number) ORDER(Ascending);
            MaxIteration = 1;
            column(Number_Integer2_CreditVoucher; Integer2_CreditVoucher.Number)
            {
            }
            column(TotalAmount; TotalAmount)
            {
            }
            column(TotalCancelled; TotalCancelled)
            {
            }
            column(TotalRedeemedAmt; TotalRedeemedAmt)
            {
            }
            column(TotalOpenAmt; TotalOpenAmt)
            {
            }
            column(PercentRedeemed; PercentRedeemed)
            {
            }
            column(PercentOpen; PercentOpen)
            {
            }
            column(TotalRedeemedPctGV; TotalRedeemedPctGV)
            {
            }
            column(TotalRedeemedPctCV; TotalRedeemedPctCV)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if "Gift Voucher".GetFilter("Cashed Date") <> '' then
                    CurrReport.Break();

                if ShowCreditOnly and not ShowGiftOnly then
                    CurrReport.Break();

                if ShowGiftOnly and not ShowCreditOnly then
                    CurrReport.Break();

                TotalOpenAmt := TotalOpenGV + TotalOpenCV;
                TotalRedeemedAmt := TotalRedeemedGV + TotalRedeemedCV;
                TotalAmount := TotalAmtGV + TotalAmtCV;
                TotalCancelled := TotalCancelledGV + TotalCancelledCV;

                if TotalAmount <> 0 then
                    PercentRedeemed := 100 * (TotalRedeemedAmt / TotalAmount);

                if TotalAmount <> 0 then
                    PercentOpen := 100 * (TotalOpenAmt / TotalAmount);

                if TotalAmount <> 0 then
                    TotalRedeemedPctGV := 100 * (TotalAmtGV / TotalAmount);

                if TotalAmount <> 0 then
                    TotalRedeemedPctCV := 100 * (TotalAmtCV / TotalAmount);
            end;
        }
        dataitem("G/L Account"; "G/L Account")
        {
            DataItemTableView = SORTING("No.") ORDER(Ascending);
            column(No_G_L_Account; "G/L Account"."No.")
            {
            }
            column(G_L_Account_FILTERS; Format("G/L Account".GetFilters))
            {
            }
            column(SalesGV; SalesGV)
            {
            }
            column(SalesCV; SalesCV)
            {
            }
            column(GVAccountNo; GVAccountNo)
            {
            }
            column(CVAccountNo; CVAccountNo)
            {
            }

            trigger OnPreDataItem()
            begin
                Register.FindFirst;
                "Credit Voucher".CopyFilter("Issue Date", "Date Filter");
                if Get(Register."Gift Voucher Account") then
                    GVAccountNo := '(' + Register."Gift Voucher Account" + ')';
                CalcFields("Net Change");
                SalesGV := "Net Change";
                if Get(Register."Credit Voucher Account") then
                    CVAccountNo := '(' + Register."Credit Voucher Account" + ')';
                CalcFields("Net Change");
                SalesCV := "Net Change";
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(ShowGiftOnly; ShowGiftOnly)
                    {
                        Caption = 'Gift Voucher';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Gift Voucher field';
                    }
                    field(ShowCreditOnly; ShowCreditOnly)
                    {
                        Caption = 'Credit Voucher';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Credit Voucher field';
                    }
                    field(ShowPosting; ShowPosting)
                    {
                        Caption = 'Show Ledger Entries';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Show Ledger Entries field';
                    }
                }
            }
        }
    }

    labels
    {
        Page_Caption = 'Page';
    }

    trigger OnPreReport()
    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);

        GV_Filters := Format("Gift Voucher".GetFilters);
        AddFilters := '';
        if ShowGiftOnly then
            AddFilters += ' ' + TextShowGV + '  ';

        if ShowCreditOnly then
            AddFilters += ' ' + TextShowCV + '  ';

        if ShowPosting then
            AddFilters += ' ' + TextShowPosting;
    end;

    var
        CompanyInfo: Record "Company Information";
        CreditVoucher2: Record "NPR Credit Voucher";
        GiftVoucher2: Record "NPR Gift Voucher";
        Register: Record "NPR Register";
        ShowCreditOnly: Boolean;
        ShowGiftOnly: Boolean;
        ShowPosting: Boolean;
        Location: Code[10];
        CVAccountNo: Code[20];
        GVAccountNo: Code[20];
        PercentCV: Decimal;
        PercentCVDiff: Decimal;
        PercentGV: Decimal;
        PercentGVDiff: Decimal;
        PercentOpen: Decimal;
        PercentRedeemed: Decimal;
        SalesCV: Decimal;
        SalesGV: Decimal;
        TestVar: Decimal;
        TotalAmount: Decimal;
        TotalAmtCV: Decimal;
        TotalAmtGV: Decimal;
        TotalCancelled: Decimal;
        TotalCancelledCV: Decimal;
        TotalCancelledGV: Decimal;
        TotalOpenAmt: Decimal;
        TotalOpenCV: Decimal;
        TotalOpenGV: Decimal;
        TotalRedeemedAmt: Decimal;
        TotalRedeemedCV: Decimal;
        TotalRedeemedGV: Decimal;
        TotalRedeemedPctCV: Decimal;
        TotalRedeemedPctGV: Decimal;
        Counter: Integer;
        Counter2: Integer;
        Counter3: Integer;
        Pct_Caption_Lbl: Label '%';
        Amount_Caption_Lbl: Label 'Amount';
        Cancelled_Caption_Lbl: Label 'Cancelled';
        Cashed_Caption_Lbl: Label 'Cashed';
        Cashed_Date_Caption_Lbl: Label 'Cashed Date';
        Credit_Voucher_Caption_Lbl: Label 'Credit Voucher';
        Credit_Vouchers_Caption_Lbl: Label 'Credit Vouchers';
        Credit_Voucher_Total_Caption_Lbl: Label 'Credit Voucher total';
        Gift_Voucher_Caption_Lbl: Label 'Gift Voucher';
        Report_Caption_Lbl: Label 'Gift Voucher/Credit Voucher';
        Gift_Vouchers_Caption_Lbl: Label 'Gift Vouchers';
        Gift_Voucher_Total_Caption_Lbl: Label 'Gift Voucher total';
        Issue_Date_Caption_Lbl: Label 'Issue Date';
        Key_Figures_Caption_Lbl: Label 'Key Figures';
        No_Caption_Lbl: Label 'No.';
        Open_Caption_Lbl: Label 'Open';
        PageNoCaptionLbl: Label 'Page';
        Sales_Ticket_No_Caption_Lbl: Label 'Sales Ticket No.';
        TextShowCV: Label 'Show Credit Voucher';
        TextShowGV: Label 'Show Gift Voucher';
        TextShowPosting: Label 'Show Ledger Entries';
        Status_Caption_Lbl: Label 'Status';
        Total_Caption_Lbl: Label 'Total';
        Gift_Credit_Total_Caption_Lbl: Label 'Total Gift Vouchers & Credit Vouchers';
        Total_GL_Accounts_Caption_Lbl: Label 'Total Posted to G/L';
        AddFilters: Text;
        "Filter": Text[100];
        ObjectDetails: Text[100];
        GV_Filters: Text[300];
}

