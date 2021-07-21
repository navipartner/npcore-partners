report 6014545 "NPR Acc. Statement w FIK-Card"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Acc. Statement w FIK-Card.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Acc. Statement w FIK-Card';

    dataset
    {
        dataitem(Customer; Customer)
        {
            DataItemTableView = SORTING("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Search Name", "Print Statements", "Date Filter", "Currency Filter";
            column(Customer_No_; "No.")
            {
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                PrintOnlyIfDetail = true;
                column(STRSUBSTNO_Text000_FORMAT_CurrReport_PAGENO__; Text000)
                {
                }
                column(CustAddr_1_; CustAddr[1])
                {
                }
                column(CompanyAddr_1_; CompanyAddr[1])
                {
                }
                column(CustAddr_2_; CustAddr[2])
                {
                }
                column(CompanyAddr_2_; CompanyAddr[2])
                {
                }
                column(CustAddr_3_; CustAddr[3])
                {
                }
                column(CompanyAddr_3_; CompanyAddr[3])
                {
                }
                column(CustAddr_4_; CustAddr[4])
                {
                }
                column(CompanyAddr_4_; CompanyAddr[4])
                {
                }
                column(CustAddr_5_; CustAddr[5])
                {
                }
                column(CompanyInfo__Phone_No__; CompanyInfo."Phone No.")
                {
                }
                column(CustAddr_6_; CustAddr[6])
                {
                }
                column(CompanyInfo__Fax_No__; CompanyInfo."Fax No.")
                {
                }
                column(CompanyInfo__VAT_Registration_No__; CompanyInfo."VAT Registration No.")
                {
                }
                column(CompanyInfo__Giro_No__; CompanyInfo."Giro No.")
                {
                }
                column(CompanyInfo__Bank_Name_; CompanyInfo."Bank Name")
                {
                }
                column(CompanyInfo__Bank_Account_No__; CompanyInfo."Bank Account No.")
                {
                }
                column(CompanyInfo_BankBranchNo_; CompanyInfo."Bank Branch No.")
                {
                }
                column(Customer__No__; Customer."No.")
                {
                }
                column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
                {
                }
                column(StartDate; Format(StartDate))
                {
                }
                column(EndDate; Format(EndDate))
                {
                }
                column(Customer__Last_Statement_No__; Format(Customer."Last Statement No."))
                {
                }
                column(CustAddr_7_; CustAddr[7])
                {
                }
                column(CustAddr_8_; CustAddr[8])
                {
                }
                column(CompanyAddr_7_; CompanyAddr[7])
                {
                }
                column(CompanyAddr_8_; CompanyAddr[8])
                {
                }
                column(StatementCaption; StatementCaptionLbl)
                {
                }
                column(CompanyInfo__Phone_No__Caption; CompanyInfo__Phone_No__CaptionLbl)
                {
                }
                column(CompanyInfo__Fax_No__Caption; CompanyInfo__Fax_No__CaptionLbl)
                {
                }
                column(CompanyInfo__VAT_Registration_No__Caption; CompanyInfo__VAT_Registration_No__CaptionLbl)
                {
                }
                column(CompanyInfo__Giro_No__Caption; CompanyInfo__Giro_No__CaptionLbl)
                {
                }
                column(CompanyInfo__Bank_Name_Caption; CompanyInfo__Bank_Name_CaptionLbl)
                {
                }
                column(CompanyInfo__Bank_Account_No__Caption; CompanyInfo__Bank_Account_No__CaptionLbl)
                {
                }
                column(Customer__No__Caption; Customer__No__CaptionLbl)
                {
                }
                column(CompanyInfo_BankBranchNo_lbl; CompanyInfo.FieldCaption(CompanyInfo."Bank Branch No."))
                {
                }
                column(StartDateCaption; StartDateCaptionLbl)
                {
                }
                column(EndDateCaption; EndDateCaptionLbl)
                {
                }
                column(Customer__Last_Statement_No__Caption; Customer__Last_Statement_No__CaptionLbl)
                {
                }
                column(DtldCustLedgEntries__Posting_Date_Caption; DtldCustLedgEntries__Posting_Date_CaptionLbl)
                {
                }
                column(DtldCustLedgEntries__Document_No__Caption; DtldCustLedgEntries.FieldCaption("Document No."))
                {
                }
                column(CustLedgEntry2_DescriptionCaption; CustLedgEntry2.FieldCaption(Description))
                {
                }
                column(CustLedgEntry2__Due_Date_Caption; CustLedgEntry2__Due_Date_CaptionLbl)
                {
                }
                column(CustLedgEntry2__Remaining_Amount__Control61Caption; CustLedgEntry2.FieldCaption("Remaining Amount"))
                {
                }
                column(CustBalanceCaption; CustBalanceCaptionLbl)
                {
                }
                column(CustLedgEntry2__Original_Amount_Caption; CustLedgEntry2.FieldCaption("Original Amount"))
                {
                }
                column(CompanyInfo__IBAN__PM__Caption; CompanyInfo__IBAN__PM__CaptionLbl)
                {
                }
                column(Please_use_the_following_reference_upon_payment_Caption; Please_use_the_following_reference_upon_payment_CaptionLbl)
                {
                }
                column(Card_TypeCaption; Card_TypeCaptionLbl)
                {
                }
                column(Payment_IdentificationCaption; Payment_IdentificationCaptionLbl)
                {
                }
                column(Vendor_No_Caption; Vendor_No_CaptionLbl)
                {
                }
                column(Integer_Number; Number)
                {
                }
                column(Giro_No; Giro_No)
                {
                }
                column(Payment_ID; Payment_ID)
                {
                }
                column(IK_Card_Type; IK_Card_Type)
                {
                }
                dataitem(CurrencyLoop; "Integer")
                {
                    DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                    PrintOnlyIfDetail = true;
                    dataitem(CustLedgEntryHdr; "Integer")
                    {
                        DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                        column(STRSUBSTNO_Text001_Currency2_Code_; StrSubstNo(Text001, TempCurrency2.Code))
                        {
                        }
                        column(StartBalance; StartBalance)
                        {
                            AutoFormatExpression = TempCurrency2.Code;
                            AutoFormatType = 1;
                        }
                        column(PrintLine; PrintLine)
                        {
                        }
                        column(DtldCustLedgEntryType; Format(DtldCustLedgEntries."Entry Type", 0, 2))
                        {
                        }
                        column(CurrencyCode3; CurrencyCode3)
                        {
                        }
                        column(CustBalance_control; CustBalance)
                        {
                        }
                        column(EntriesExists; EntriesExists)
                        {
                        }
                        column(CustLedgEntryHdr_Number; Number)
                        {
                        }
                        dataitem(DtldCustLedgEntries; "Detailed Cust. Ledg. Entry")
                        {
                            DataItemTableView = SORTING("Customer No.", "Posting Date", "Entry Type", "Currency Code");
                            column(CustBalance___Amount; CustBalance - Amount)
                            {
                                AutoFormatExpression = "Currency Code";
                                AutoFormatType = 1;
                            }
                            column(DtldCustLedgEntries__Posting_Date_; Format("Posting Date"))
                            {
                            }
                            column(DtldCustLedgEntries__Document_No__; "Document No.")
                            {
                            }
                            column(Description; Description)
                            {
                            }
                            column(Due_Date_; Format("Due Date"))
                            {
                            }
                            column(DtldCustLedgEntries__Currency_Code_; "Currency Code")
                            {
                            }
                            column(DtldCustLedgEntries_Amount; Amount)
                            {
                                AutoFormatExpression = "Currency Code";
                                AutoFormatType = 1;
                            }
                            column(Remaining_Amount_; "Remaining Amount")
                            {
                                AutoFormatExpression = "Currency Code";
                                AutoFormatType = 1;
                            }
                            column(CustBalance; CustBalance)
                            {
                                AutoFormatExpression = "Currency Code";
                                AutoFormatType = 1;
                            }
                            column(Currency2Code; TempCurrency2.Code)
                            {
                            }
                            column(DtlEntries_CurrencyCode3; CurrencyCode3)
                            {
                            }
                            column(CustBalance___Amount_Control75; CustBalance - Amount)
                            {
                                AutoFormatExpression = "Currency Code";
                                AutoFormatType = 1;
                            }
                            column(CustBalance___AmountCaption; CustBalance___AmountCaptionLbl)
                            {
                            }
                            column(CustBalance___Amount_Control75Caption; CustBalance___Amount_Control75CaptionLbl)
                            {
                            }
                            column(DtldCustLedgEntries_Entry_No_; "Entry No.")
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                if SkipReversedUnapplied(DtldCustLedgEntries) then
                                    CurrReport.Skip();
                                "Remaining Amount" := 0;
                                PrintLine := true;
                                case "Entry Type" of
                                    "Entry Type"::"Initial Entry":
                                        begin
                                            "Cust. Ledger Entry".Get("Cust. Ledger Entry No.");
                                            Description := "Cust. Ledger Entry".Description;
                                            "Due Date" := "Cust. Ledger Entry"."Due Date";
                                            "Cust. Ledger Entry".SetRange("Date Filter", 0D, EndDate);
                                            "Cust. Ledger Entry".CalcFields("Remaining Amount");
                                            "Remaining Amount" := "Cust. Ledger Entry"."Remaining Amount";
                                            "Cust. Ledger Entry".SetRange("Date Filter");
                                        end;
                                    "Entry Type"::Application:
                                        begin
                                            DtldCustLedgEntries2.SetCurrentKey("Customer No.", "Posting Date", "Entry Type");
                                            DtldCustLedgEntries2.SetRange("Customer No.", "Customer No.");
                                            DtldCustLedgEntries2.SetRange("Posting Date", "Posting Date");
                                            DtldCustLedgEntries2.SetRange("Entry Type", "Entry Type"::Application);
                                            DtldCustLedgEntries2.SetRange("Transaction No.", "Transaction No.");
                                            DtldCustLedgEntries2.SetFilter("Currency Code", '<>%1', DtldCustLedgEntries."Currency Code");
                                            if DtldCustLedgEntries2.FindFirst() then begin
                                                Description := Text005;
                                                "Due Date" := 0D;
                                            end else
                                                PrintLine := false;
                                        end;
                                    "Entry Type"::"Payment Discount",
                                    "Entry Type"::"Payment Discount (VAT Excl.)",
                                    "Entry Type"::"Payment Discount (VAT Adjustment)",
                                    "Entry Type"::"Payment Discount Tolerance",
                                    "Entry Type"::"Payment Discount Tolerance (VAT Excl.)",
                                    "Entry Type"::"Payment Discount Tolerance (VAT Adjustment)":
                                        begin
                                            Description := Text006;
                                            "Due Date" := 0D;
                                        end;
                                    "Entry Type"::"Payment Tolerance",
                                    "Entry Type"::"Payment Tolerance (VAT Excl.)",
                                    "Entry Type"::"Payment Tolerance (VAT Adjustment)":
                                        begin
                                            Description := Text014;
                                            "Due Date" := 0D;
                                        end;
                                    "Entry Type"::"Appln. Rounding",
                                    "Entry Type"::"Correction of Remaining Amount":
                                        begin
                                            Description := Text007;
                                            "Due Date" := 0D;
                                        end;
                                end;

                                if PrintLine then
                                    CustBalance := CustBalance + Amount;
                            end;

                            trigger OnPreDataItem()
                            begin
                                SetRange("Customer No.", Customer."No.");
                                SetRange("Posting Date", StartDate, EndDate);
                                SetRange("Currency Code", TempCurrency2.Code);

                                if TempCurrency2.Code = '' then begin
                                    GLSetup.TestField("LCY Code");
                                    CurrencyCode3 := GLSetup."LCY Code";
                                end else
                                    CurrencyCode3 := TempCurrency2.Code;
                            end;
                        }
                    }
                    dataitem(CustLedgEntryFooter; "Integer")
                    {
                        DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                        column(CurrencyCode3_Control51; CurrencyCode3)
                        {
                        }
                        column(CustBalance_Control71; CustBalance)
                        {
                            AutoFormatExpression = TempCurrency2.Code;
                            AutoFormatType = 1;
                        }
                        column(EntriesExists_Control98; EntriesExists)
                        {
                        }
                        column(CustBalance_Control71Caption; CustBalance_Control71CaptionLbl)
                        {
                        }
                        column(CustLedgEntryFooter_Number; Number)
                        {
                        }
                    }
                    dataitem(CustLedgEntry2; "Cust. Ledger Entry")
                    {
                        DataItemLink = "Customer No." = FIELD("No.");
                        DataItemLinkReference = Customer;
                        DataItemTableView = SORTING("Customer No.", Open, Positive, "Due Date");
                        column(STRSUBSTNO_Text002_Currency2_Code_; StrSubstNo(Text002, TempCurrency2.Code))
                        {
                        }
                        column(CustLedgEntry2__Remaining_Amount_; "Remaining Amount")
                        {
                            AutoFormatExpression = "Currency Code";
                            AutoFormatType = 1;
                        }
                        column(CustLedgEntry2__Posting_Date_; Format("Posting Date"))
                        {
                        }
                        column(CustLedgEntry2__Document_No__; "Document No.")
                        {
                        }
                        column(CustLedgEntry2_Description; Description)
                        {
                        }
                        column(CustLedgEntry2__Due_Date_; Format("Due Date"))
                        {
                        }
                        column(CustLedgEntry2__Remaining_Amount__Control61; "Remaining Amount")
                        {
                            AutoFormatExpression = "Currency Code";
                            AutoFormatType = 1;
                        }
                        column(CustLedgEntry2__Original_Amount_; "Original Amount")
                        {
                            AutoFormatExpression = "Currency Code";
                        }
                        column(CustLedgEntry2__Currency_Code_; "Currency Code")
                        {
                        }
                        column(PrintEntriesDue; PrintEntriesDue)
                        {
                        }
                        column(Currency2Code_2nd; TempCurrency2.Code)
                        {
                        }
                        column(CustLedgEntry2__Remaining_Amount__Control64; "Remaining Amount")
                        {
                            AutoFormatExpression = "Currency Code";
                            AutoFormatType = 1;
                        }
                        column(CustLedgEntry2__Remaining_Amount__Control66; "Remaining Amount")
                        {
                            AutoFormatExpression = "Currency Code";
                            AutoFormatType = 1;
                        }
                        column(CurrencyCode3_Control73; CurrencyCode3)
                        {
                        }
                        column(CustLedgEntry2__Remaining_Amount_Caption; CustLedgEntry2__Remaining_Amount_CaptionLbl)
                        {
                        }
                        column(CustLedgEntry2__Remaining_Amount__Control64Caption; CustLedgEntry2__Remaining_Amount__Control64CaptionLbl)
                        {
                        }
                        column(CustLedgEntry2__Remaining_Amount__Control66Caption; CustLedgEntry2__Remaining_Amount__Control66CaptionLbl)
                        {
                        }
                        column(CustLedgEntry2_Entry_No_; "Entry No.")
                        {
                        }
                        column(CustLedgEntry2_Customer_No_; "Customer No.")
                        {
                        }

                        trigger OnAfterGetRecord()
                        var
                            CustLedgEntry: Record "Cust. Ledger Entry";
                        begin
                            if IncludeAgingBand then
                                if ("Posting Date" > EndDate) and ("Due Date" >= EndDate) then
                                    CurrReport.Skip();
                            CustLedgEntry := CustLedgEntry2;
                            CustLedgEntry.SetRange("Date Filter", 0D, EndDate);
                            CustLedgEntry.CalcFields("Remaining Amount");
                            "Remaining Amount" := CustLedgEntry."Remaining Amount";
                            if CustLedgEntry."Remaining Amount" = 0 then
                                CurrReport.Skip();

                            if IncludeAgingBand and ("Posting Date" <= EndDate) then
                                UpdateBuffer(TempCurrency2.Code, GetDate("Posting Date", "Due Date"), "Remaining Amount");
                            if ("Due Date" >= EndDate) or ("Remaining Amount" < 0) then
                                CurrReport.Skip();
                        end;

                        trigger OnPreDataItem()
                        begin
                            if not IncludeAgingBand then begin
                                SetRange("Due Date", 0D, EndDate - 1);
                                SetRange(Positive, true);
                            end;
                            SetRange("Currency Code", TempCurrency2.Code);
                            if (not PrintEntriesDue) and (not IncludeAgingBand) then
                                CurrReport.Break();
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if Number = 1 then
                            TempCurrency2.FindFirst()
                        else
                            if TempCurrency2.Next() = 0 then
                                CurrReport.Break();

                        Cust2 := Customer;
                        Cust2.SetRange("Date Filter", 0D, StartDate - 1);
                        Cust2.SetRange("Currency Filter", TempCurrency2.Code);
                        Cust2.CalcFields("Net Change");
                        StartBalance := Cust2."Net Change";
                        CustBalance := Cust2."Net Change";
                        "Cust. Ledger Entry".SetCurrentKey("Customer No.", "Posting Date", "Currency Code");
                        "Cust. Ledger Entry".SetRange("Customer No.", Customer."No.");
                        "Cust. Ledger Entry".SetRange("Posting Date", StartDate, EndDate);
                        "Cust. Ledger Entry".SetRange("Currency Code", TempCurrency2.Code);
                        EntriesExists := "Cust. Ledger Entry".FindFirst();
                    end;

                    trigger OnPreDataItem()
                    begin
                        Customer.CopyFilter("Currency Filter", TempCurrency2.Code);
                    end;
                }
                dataitem(AgingBandLoop; "Integer")
                {
                    DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                    column(AgingDate_1____1; Format(AgingDate[1] + 1))
                    {
                    }
                    column(AgingDate_2_; Format(AgingDate[2]))
                    {
                    }
                    column(AgingDate_2_____1; Format(AgingDate[2] + 1))
                    {
                    }
                    column(AgingDate_3_; Format(AgingDate[3]))
                    {
                    }
                    column(AgingDate_3____1; Format(AgingDate[3] + 1))
                    {
                    }
                    column(AgingDate_4_; Format(AgingDate[4]))
                    {
                    }
                    column(STRSUBSTNO_Text011_AgingBandEndingDate_PeriodLength_SELECTSTR_DateChoice___1_Text013__; StrSubstNo(Text011, AgingBandEndingDate, PeriodLength, SelectStr(DateChoice + 1, Text013)))
                    {
                    }
                    column(AgingDate_4____1; Format(AgingDate[4] + 1))
                    {
                    }
                    column(AgingDate_5_; Format(AgingDate[5]))
                    {
                    }
                    column(AgingBandBuf__Column_1_Amt__; TempAgingBandBuf."Column 1 Amt.")
                    {
                        AutoFormatExpression = TempAgingBandBuf."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(AgingBandBuf__Column_2_Amt__; TempAgingBandBuf."Column 2 Amt.")
                    {
                        AutoFormatExpression = TempAgingBandBuf."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(AgingBandBuf__Column_3_Amt__; TempAgingBandBuf."Column 3 Amt.")
                    {
                        AutoFormatExpression = TempAgingBandBuf."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(AgingBandBuf__Column_4_Amt__; TempAgingBandBuf."Column 4 Amt.")
                    {
                        AutoFormatExpression = TempAgingBandBuf."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(AgingBandBuf__Column_5_Amt__; TempAgingBandBuf."Column 5 Amt.")
                    {
                        AutoFormatExpression = TempAgingBandBuf."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(AgingBandCurrencyCode; AgingBandCurrencyCode)
                    {
                    }
                    column(beforeCaption; BeforeCaptionLbl)
                    {
                    }
                    column(AgingBandLoop_Number; Number)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if Number = 1 then begin
                            if not TempAgingBandBuf.FindFirst() then
                                CurrReport.Break();
                        end else
                            if TempAgingBandBuf.Next() = 0 then
                                CurrReport.Break();
                        AgingBandCurrencyCode := TempAgingBandBuf."Currency Code";
                        if AgingBandCurrencyCode = '' then
                            AgingBandCurrencyCode := GLSetup."LCY Code";
                    end;

                    trigger OnPreDataItem()
                    begin
                        if not IncludeAgingBand then
                            CurrReport.Break();
                    end;
                }
            }

            trigger OnAfterGetRecord()
            begin
                TempAgingBandBuf.DeleteAll();
                CurrReport.Language := Language.GetLanguageID("Language Code");
                PrintLine := false;
                Cust2 := Customer;
                CopyFilter("Currency Filter", TempCurrency2.Code);
                if PrintAllHavingBal then begin
                    if TempCurrency2.FindFirst() then
                        repeat
                            Cust2.SetRange("Date Filter", 0D, EndDate);
                            Cust2.SetRange("Currency Filter", TempCurrency2.Code);
                            Cust2.CalcFields("Net Change");
                            PrintLine := Cust2."Net Change" <> 0;
                        until (TempCurrency2.Next() = 0) or PrintLine;
                end;
                if (not PrintLine) and PrintAllHavingEntry then begin
                    "Cust. Ledger Entry".Reset();
                    "Cust. Ledger Entry".SetCurrentKey("Customer No.", "Posting Date");
                    "Cust. Ledger Entry".SetRange("Customer No.", Customer."No.");
                    "Cust. Ledger Entry".SetRange("Posting Date", StartDate, EndDate);
                    Customer.CopyFilter("Currency Filter", "Cust. Ledger Entry"."Currency Code");
                    PrintLine := "Cust. Ledger Entry".FindFirst();
                end;
                if not PrintLine then
                    CurrReport.Skip();

                FormatAddr.Customer(CustAddr, Customer);

                if not CurrReport.Preview() then begin
                    Customer.LockTable();
                    Customer.Find();
                    Customer."Last Statement No." := Customer."Last Statement No." + 1;
                    Customer.Modify();
                    Commit();
                end else
                    Customer."Last Statement No." := Customer."Last Statement No." + 1;

                if LogInteraction then
                    if not CurrReport.Preview() then
                        SegManagement.LogDocument(
                          7, Format(Customer."Last Statement No."), 0, 0, DATABASE::Customer, "No.", "Salesperson Code", '',
                          Text003 + Format(Customer."Last Statement No."), '');

                Clear(IK_Card_Type);
                Clear(Payment_ID);
                Clear(Giro_No);
                GenerateFIKCode(Customer);
            end;

            trigger OnPreDataItem()
            begin
                StartDate := GetRangeMin("Date Filter");
                EndDate := GetRangeMax("Date Filter");
                AgingBandEndingDate := EndDate;
                CalcAgingBandDates();

                CompanyInfo.Get();
                FormatAddr.Company(CompanyAddr, CompanyInfo);

                TempCurrency2.Code := '';
                TempCurrency2.Insert();
                CopyFilter("Currency Filter", Currency.Code);
                if Currency.FindFirst() then
                    repeat
                        TempCurrency2 := Currency;
                        TempCurrency2.Insert();
                    until Currency.Next() = 0;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field("Print Entries Due"; PrintEntriesDue)
                    {
                        Caption = 'Show Overdue Entries';

                        ToolTip = 'Specifies the value of the Show Overdue Entries field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Print All Having Entry"; PrintAllHavingEntry)
                    {
                        Caption = 'Include All Customers with Ledger Entries';
                        MultiLine = true;

                        ToolTip = 'Specifies the value of the Include All Customers with Ledger Entries field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            if not PrintAllHavingEntry then
                                PrintAllHavingBal := true;
                        end;
                    }
                    field("Print All Having Bal"; PrintAllHavingBal)
                    {
                        Caption = 'Include All Customers with a Balance';
                        MultiLine = true;

                        ToolTip = 'Specifies the value of the Include All Customers with a Balance field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            if not PrintAllHavingBal then
                                PrintAllHavingEntry := true;
                        end;
                    }
                    field("Print Reversed Entries"; PrintReversedEntries)
                    {
                        Caption = 'Include Reversed Entries';

                        ToolTip = 'Specifies the value of the Include Reversed Entries field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Print Unapplied Entries"; PrintUnappliedEntries)
                    {
                        Caption = 'Include Unapplied Entries';

                        ToolTip = 'Specifies the value of the Include Unapplied Entries field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Include Aging Band"; IncludeAgingBand)
                    {
                        Caption = 'Include Aging Band';

                        ToolTip = 'Specifies the value of the Include Aging Band field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Period Length"; PeriodLength)
                    {
                        Caption = 'Aging Band Period Length';

                        ToolTip = 'Specifies the value of the Aging Band Period Length field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Date Choice"; DateChoice)
                    {
                        Caption = 'Aging Band by';
                        OptionCaption = 'Due Date,Posting Date';

                        ToolTip = 'Specifies the value of the Aging Band by field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Log Interaction"; LogInteraction)
                    {
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;

                        ToolTip = 'Specifies the value of the Log Interaction field';
                        ApplicationArea = NPRRetail;
                    }
                    field("FIK No"; FIKNo)
                    {
                        Caption = 'FIK No.';

                        ToolTip = 'Specifies the value of the FIK No. field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group("Output Options")
                {
                    Caption = 'Output Options';
                    field(ReportOutput; SupportedOutputMethod)
                    {
                        Caption = 'Report Output';
                        OptionCaption = 'Print,Preview,PDF,Email,Excel,XML';

                        ToolTip = 'Specifies the value of the Report Output field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        var
                            CustomLayoutReporting: Codeunit "Custom Layout Reporting";
                        begin
                            ShowPrintRemaining := (SupportedOutputMethod = SupportedOutputMethod::Email);

                            case SupportedOutputMethod of
                                SupportedOutputMethod::Print:
                                    ChosenOutputMethod := CustomLayoutReporting.GetPrintOption();
                                SupportedOutputMethod::Preview:
                                    ChosenOutputMethod := CustomLayoutReporting.GetPreviewOption();
                                SupportedOutputMethod::PDF:
                                    ChosenOutputMethod := CustomLayoutReporting.GetPDFOption();
                                SupportedOutputMethod::Email:
                                    ChosenOutputMethod := CustomLayoutReporting.GetEmailOption();
                                SupportedOutputMethod::Excel:
                                    ChosenOutputMethod := CustomLayoutReporting.GetExcelOption();
                                SupportedOutputMethod::XML:
                                    ChosenOutputMethod := CustomLayoutReporting.GetXMLOption();
                            end;
                        end;
                    }
                    field(ChosenOutput; ChosenOutputMethod)
                    {
                        Caption = 'Chosen Output';
                        Visible = false;

                        ToolTip = 'Specifies the value of the Chosen Output field';
                        ApplicationArea = NPRRetail;
                    }
                    group(EmailOptions)
                    {
                        Caption = 'Email Options';
                        Visible = ShowPrintRemaining;
                        field(PrintMissingAddresses; PrintRemaining)
                        {
                            Caption = 'Print remaining statements';

                            ToolTip = 'Specifies the value of the Print remaining statements field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                }
            }
        }

        trigger OnInit()
        begin
            LogInteractionEnable := true;
        end;

        trigger OnOpenPage()
        begin
            if (not PrintAllHavingEntry) and (not PrintAllHavingBal) then
                PrintAllHavingBal := true;

            LogInteraction := SegManagement.FindInteractTmplCode(7) <> '';
            LogInteractionEnable := LogInteraction;

            if Format(PeriodLength) = '' then
                Evaluate(PeriodLength, '<1M+CM>');
        end;
    }


    trigger OnInitReport()
    begin
        GLSetup.Get();
    end;

    var
        TempAgingBandBuf: Record "Aging Band Buffer" temporary;
        CompanyInfo: Record "Company Information";
        Currency: Record Currency;
        TempCurrency2: Record Currency temporary;
        "Cust. Ledger Entry": Record "Cust. Ledger Entry";
        Cust2: Record Customer;
        DtldCustLedgEntries2: Record "Detailed Cust. Ledg. Entry";
        GLSetup: Record "General Ledger Setup";
        FormatAddr: Codeunit "Format Address";
        Language: Codeunit Language;
        SegManagement: Codeunit SegManagement;
        PeriodLength: DateFormula;
        PeriodLength2: DateFormula;
        EntriesExists: Boolean;
        IncludeAgingBand: Boolean;
        LogInteraction: Boolean;
        [InDataSet]
        LogInteractionEnable: Boolean;
        PrintAllHavingBal: Boolean;
        PrintAllHavingEntry: Boolean;
        PrintEntriesDue: Boolean;
        PrintLine: Boolean;
        PrintRemaining: Boolean;
        PrintReversedEntries: Boolean;
        PrintUnappliedEntries: Boolean;
        [InDataSet]
        ShowPrintRemaining: Boolean;
        AgingBandCurrencyCode: Code[20];
        CurrencyCode3: Code[10];
        FIKNo: Code[10];
        AgingBandEndingDate: Date;
        AgingDate: array[5] of Date;
        "Due Date": Date;
        EndDate: Date;
        StartDate: Date;
        CustBalance: Decimal;
        "Remaining Amount": Decimal;
        StartBalance: Decimal;
        ChosenOutputMethod: Integer;
        BeforeCaptionLbl: Label '..before';
        CompanyInfo__Bank_Account_No__CaptionLbl: Label 'Account No.';
        Text011: Label 'Aged Summary by %1 (%2 by %3)';
        Text014: Label 'Application Writeoffs';
        CustBalanceCaptionLbl: Label 'Balance';
        CompanyInfo__Bank_Name_CaptionLbl: Label 'Bank';
        Card_TypeCaptionLbl: Label 'Card Type';
        CustBalance___Amount_Control75CaptionLbl: Label 'Continued';
        CustBalance___AmountCaptionLbl: Label 'Continued';
        CustLedgEntry2__Remaining_Amount__Control64CaptionLbl: Label 'Continued';
        CustLedgEntry2__Remaining_Amount_CaptionLbl: Label 'Continued';
        Customer__No__CaptionLbl: Label 'Customer No.';
        CustLedgEntry2__Due_Date_CaptionLbl: Label 'Due Date';
        Text013: Label 'Due Date,Posting Date';
        EndDateCaptionLbl: Label 'Ending Date';
        Text001: Label 'Entries %1';
        CompanyInfo__Fax_No__CaptionLbl: Label 'Fax No.';
        CompanyInfo__Giro_No__CaptionLbl: Label 'Giro No.';
        CompanyInfo__IBAN__PM__CaptionLbl: Label 'IBAN';
        Text005: Label 'Multicurrency Application';
        Text002: Label 'Overdue Entries %1';
        Text000: Label 'Page';
        Text006: Label 'Payment Discount';
        Payment_IdentificationCaptionLbl: Label 'Payment Identification';
        Text012: Label 'Period Length is out of range.';
        CompanyInfo__Phone_No__CaptionLbl: Label 'Phone No.';
        Please_use_the_following_reference_upon_payment_CaptionLbl: Label 'Please use the following reference upon payment:';
        DtldCustLedgEntries__Posting_Date_CaptionLbl: Label 'Posting Date';
        Text007: Label 'Rounding';
        StartDateCaptionLbl: Label 'Starting Date';
        StatementCaptionLbl: Label 'Statement';
        Text003: Label 'Statement ';
        Customer__Last_Statement_No__CaptionLbl: Label 'Statement No.';
        CustBalance_Control71CaptionLbl: Label 'Total';
        CustLedgEntry2__Remaining_Amount__Control66CaptionLbl: Label 'Total';
        CompanyInfo__VAT_Registration_No__CaptionLbl: Label 'VAT Reg. No.';
        Vendor_No_CaptionLbl: Label 'Vendor No.';
        Text010: Label 'You must specify Aging Band Ending Date.';
        Text008: Label 'You must specify the Aging Band Period Length.';
        DateChoice: Option "Due Date","Posting Date";
        SupportedOutputMethod: Option Print,Preview,PDF,Email,Excel,XML;
        Giro_No: Text;
        IK_Card_Type: Text;
        Payment_ID: Text;
        CompanyAddr: array[8] of Text[100];
        CustAddr: array[8] of Text[100];
        Description: Text[100];

    local procedure GetDate(PostingDate: Date; DueDate: Date): Date
    begin
        if DateChoice = DateChoice::"Posting Date" then
            exit(PostingDate)
        else
            exit(DueDate);
    end;

    local procedure CalcAgingBandDates()
    begin
        if not IncludeAgingBand then
            exit;
        if AgingBandEndingDate = 0D then
            Error(Text010);
        if Format(PeriodLength) = '' then
            Error(Text008);
        Evaluate(PeriodLength2, '-' + Format(PeriodLength));
        AgingDate[5] := AgingBandEndingDate;
        AgingDate[4] := CalcDate(PeriodLength2, AgingDate[5]);
        AgingDate[3] := CalcDate(PeriodLength2, AgingDate[4]);
        AgingDate[2] := CalcDate(PeriodLength2, AgingDate[3]);
        AgingDate[1] := CalcDate(PeriodLength2, AgingDate[2]);
        if AgingDate[2] <= AgingDate[1] then
            Error(Text012);
    end;

    local procedure UpdateBuffer(CurrencyCode: Code[10]; Date: Date; Amount: Decimal)
    var
        GoOn: Boolean;
        I: Integer;
    begin
        TempAgingBandBuf.Init();
        TempAgingBandBuf."Currency Code" := CurrencyCode;
        if not TempAgingBandBuf.Find() then
            TempAgingBandBuf.Insert();
        I := 1;
        GoOn := true;
        while (I <= 5) and GoOn do begin
            if Date <= AgingDate[I] then
                if I = 1 then begin
                    TempAgingBandBuf."Column 1 Amt." := TempAgingBandBuf."Column 1 Amt." + Amount;
                    GoOn := false;
                end;
            if Date <= AgingDate[I] then
                if I = 2 then begin
                    TempAgingBandBuf."Column 2 Amt." := TempAgingBandBuf."Column 2 Amt." + Amount;
                    GoOn := false;
                end;
            if Date <= AgingDate[I] then
                if I = 3 then begin
                    TempAgingBandBuf."Column 3 Amt." := TempAgingBandBuf."Column 3 Amt." + Amount;
                    GoOn := false;
                end;
            if Date <= AgingDate[I] then
                if I = 4 then begin
                    TempAgingBandBuf."Column 4 Amt." := TempAgingBandBuf."Column 4 Amt." + Amount;
                    GoOn := false;
                end;
            if Date <= AgingDate[I] then
                if I = 5 then begin
                    TempAgingBandBuf."Column 5 Amt." := TempAgingBandBuf."Column 5 Amt." + Amount;
                    GoOn := false;
                end;
            I := I + 1;
        end;
        TempAgingBandBuf.Modify();
    end;

    procedure SkipReversedUnapplied(var DtldCustLedgEntries: Record "Detailed Cust. Ledg. Entry"): Boolean
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        if PrintReversedEntries and PrintUnappliedEntries then
            exit(false);
        if not PrintUnappliedEntries then
            if DtldCustLedgEntries.Unapplied then
                exit(true);
        if not PrintReversedEntries then begin
            CustLedgEntry.Get(DtldCustLedgEntries."Cust. Ledger Entry No.");
            if CustLedgEntry.Reversed then
                exit(true);
        end;
        exit(false);
    end;

    procedure Modulus10(TestNumber: Code[16]): Code[16]
    var
        Accumulator: Integer;
        Counter: Integer;
        WeightNo: Integer;
        SumStr: Text[30];
    begin
        WeightNo := 2;
        SumStr := '';
        for Counter := StrLen(TestNumber) downto 1 do begin
            Evaluate(Accumulator, CopyStr(TestNumber, Counter, 1));
            Accumulator := Accumulator * WeightNo;
            SumStr := SumStr + Format(Accumulator);
            if WeightNo = 1 then
                WeightNo := 2
            else
                WeightNo := 1;
        end;
        Accumulator := 0;
        for Counter := 1 to StrLen(SumStr) do begin
            Evaluate(WeightNo, CopyStr(SumStr, Counter, 1));
            Accumulator := Accumulator + WeightNo;
        end;
        Accumulator := 10 - (Accumulator mod 10);
        if Accumulator = 10 then
            exit('0')
        else
            exit(Format(Accumulator));
    end;

    local procedure GenerateFIKCode(Cust: Record Customer)
    var
        StringLen: Integer;
        NumbersLbl: Label '0123456789';
    begin
        StringLen := 15;

        if DelChr(Format(Cust."No."), '=', NumbersLbl) <> '' then
            exit;

        if FIKNo = '' then
            exit;

        IK_Card_Type := '71';
        Giro_No := FIKNo;

        Payment_ID := PadStr('', StringLen - 2 - StrLen(Cust."No."), '0') + Cust."No." + '1';
# pragma warning disable AA0139
        Payment_ID := Payment_ID + Modulus10(Payment_ID);
# pragma warning restore
    end;
}

