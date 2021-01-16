report 6014545 "NPR Acc. Statement w FIK-Card"
{
    // NPR5.40/JLK /20180305  CASE 304195 Object created
    //                                    Added Report Option to select which custom layout to run the report
    // 
    // NPR5.42/ZESO/20180426  CASE 313027 Displayed Bank Branch No on report.
    // NPR5.49/BHR /20190111  CASE 341976 Comment Code as per OMA
    // NPR5.49/JAKUBV/20190402  CASE 341969 Transport NPR5.49 - 1 April 2019
    UsageCategory = None;
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Acc. Statement w FIK-Card.rdlc';

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
                        column(STRSUBSTNO_Text001_Currency2_Code_; StrSubstNo(Text001, Currency2.Code))
                        {
                        }
                        column(StartBalance; StartBalance)
                        {
                            AutoFormatExpression = Currency2.Code;
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
                            column(Currency2Code; Currency2.Code)
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
                                    CurrReport.Skip;
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
                                            if DtldCustLedgEntries2.FindFirst then begin
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
                                SetRange("Currency Code", Currency2.Code);

                                if Currency2.Code = '' then begin
                                    GLSetup.TestField("LCY Code");
                                    CurrencyCode3 := GLSetup."LCY Code";
                                end else
                                    CurrencyCode3 := Currency2.Code;
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
                            AutoFormatExpression = Currency2.Code;
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
                        column(STRSUBSTNO_Text002_Currency2_Code_; StrSubstNo(Text002, Currency2.Code))
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
                        column(Currency2Code_2nd; Currency2.Code)
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
                                    CurrReport.Skip;
                            CustLedgEntry := CustLedgEntry2;
                            CustLedgEntry.SetRange("Date Filter", 0D, EndDate);
                            CustLedgEntry.CalcFields("Remaining Amount");
                            "Remaining Amount" := CustLedgEntry."Remaining Amount";
                            if CustLedgEntry."Remaining Amount" = 0 then
                                CurrReport.Skip;

                            if IncludeAgingBand and ("Posting Date" <= EndDate) then
                                UpdateBuffer(Currency2.Code, GetDate("Posting Date", "Due Date"), "Remaining Amount");
                            if ("Due Date" >= EndDate) or ("Remaining Amount" < 0) then
                                CurrReport.Skip;
                        end;

                        trigger OnPreDataItem()
                        begin
                            if not IncludeAgingBand then begin
                                SetRange("Due Date", 0D, EndDate - 1);
                                SetRange(Positive, true);
                            end;
                            SetRange("Currency Code", Currency2.Code);
                            if (not PrintEntriesDue) and (not IncludeAgingBand) then
                                CurrReport.Break;
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if Number = 1 then
                            Currency2.FindFirst
                        else
                            if Currency2.Next = 0 then
                                CurrReport.Break;

                        Cust2 := Customer;
                        Cust2.SetRange("Date Filter", 0D, StartDate - 1);
                        Cust2.SetRange("Currency Filter", Currency2.Code);
                        Cust2.CalcFields("Net Change");
                        StartBalance := Cust2."Net Change";
                        CustBalance := Cust2."Net Change";
                        "Cust. Ledger Entry".SetCurrentKey("Customer No.", "Posting Date", "Currency Code");
                        "Cust. Ledger Entry".SetRange("Customer No.", Customer."No.");
                        "Cust. Ledger Entry".SetRange("Posting Date", StartDate, EndDate);
                        "Cust. Ledger Entry".SetRange("Currency Code", Currency2.Code);
                        EntriesExists := "Cust. Ledger Entry".FindFirst;
                    end;

                    trigger OnPreDataItem()
                    begin
                        Customer.CopyFilter("Currency Filter", Currency2.Code);
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
                    column(AgingBandBuf__Column_1_Amt__; AgingBandBuf."Column 1 Amt.")
                    {
                        AutoFormatExpression = AgingBandBuf."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(AgingBandBuf__Column_2_Amt__; AgingBandBuf."Column 2 Amt.")
                    {
                        AutoFormatExpression = AgingBandBuf."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(AgingBandBuf__Column_3_Amt__; AgingBandBuf."Column 3 Amt.")
                    {
                        AutoFormatExpression = AgingBandBuf."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(AgingBandBuf__Column_4_Amt__; AgingBandBuf."Column 4 Amt.")
                    {
                        AutoFormatExpression = AgingBandBuf."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(AgingBandBuf__Column_5_Amt__; AgingBandBuf."Column 5 Amt.")
                    {
                        AutoFormatExpression = AgingBandBuf."Currency Code";
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
                            if not AgingBandBuf.FindFirst then
                                CurrReport.Break;
                        end else
                            if AgingBandBuf.Next = 0 then
                                CurrReport.Break;
                        AgingBandCurrencyCode := AgingBandBuf."Currency Code";
                        if AgingBandCurrencyCode = '' then
                            AgingBandCurrencyCode := GLSetup."LCY Code";
                    end;

                    trigger OnPreDataItem()
                    begin
                        if not IncludeAgingBand then
                            CurrReport.Break;
                    end;
                }
            }

            trigger OnAfterGetRecord()
            var
                StringLen: Integer;
            begin
                AgingBandBuf.DeleteAll;
                CurrReport.Language := Language.GetLanguageID("Language Code");
                PrintLine := false;
                Cust2 := Customer;
                CopyFilter("Currency Filter", Currency2.Code);
                if PrintAllHavingBal then begin
                    if Currency2.FindFirst then
                        repeat
                            Cust2.SetRange("Date Filter", 0D, EndDate);
                            Cust2.SetRange("Currency Filter", Currency2.Code);
                            Cust2.CalcFields("Net Change");
                            PrintLine := Cust2."Net Change" <> 0;
                        until (Currency2.Next = 0) or PrintLine;
                end;
                if (not PrintLine) and PrintAllHavingEntry then begin
                    "Cust. Ledger Entry".Reset;
                    "Cust. Ledger Entry".SetCurrentKey("Customer No.", "Posting Date");
                    "Cust. Ledger Entry".SetRange("Customer No.", Customer."No.");
                    "Cust. Ledger Entry".SetRange("Posting Date", StartDate, EndDate);
                    Customer.CopyFilter("Currency Filter", "Cust. Ledger Entry"."Currency Code");
                    PrintLine := "Cust. Ledger Entry".FindFirst;
                end;
                if not PrintLine then
                    CurrReport.Skip;

                FormatAddr.Customer(CustAddr, Customer);

                if not CurrReport.Preview then begin
                    Customer.LockTable;
                    Customer.Find;
                    Customer."Last Statement No." := Customer."Last Statement No." + 1;
                    Customer.Modify;
                    Commit;
                end else
                    Customer."Last Statement No." := Customer."Last Statement No." + 1;

                if LogInteraction then
                    if not CurrReport.Preview then
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
                CalcAgingBandDates;

                CompanyInfo.Get;
                FormatAddr.Company(CompanyAddr, CompanyInfo);

                Currency2.Code := '';
                Currency2.Insert;
                CopyFilter("Currency Filter", Currency.Code);
                if Currency.FindFirst then
                    repeat
                        Currency2 := Currency;
                        Currency2.Insert;
                    until Currency.Next = 0;
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
                    field(PrintEntriesDue; PrintEntriesDue)
                    {
                        Caption = 'Show Overdue Entries';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Show Overdue Entries field';
                    }
                    field(PrintAllHavingEntry; PrintAllHavingEntry)
                    {
                        Caption = 'Include All Customers with Ledger Entries';
                        MultiLine = true;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Include All Customers with Ledger Entries field';

                        trigger OnValidate()
                        begin
                            if not PrintAllHavingEntry then
                                PrintAllHavingBal := true;
                        end;
                    }
                    field(PrintAllHavingBal; PrintAllHavingBal)
                    {
                        Caption = 'Include All Customers with a Balance';
                        MultiLine = true;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Include All Customers with a Balance field';

                        trigger OnValidate()
                        begin
                            if not PrintAllHavingBal then
                                PrintAllHavingEntry := true;
                        end;
                    }
                    field(PrintReversedEntries; PrintReversedEntries)
                    {
                        Caption = 'Include Reversed Entries';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Include Reversed Entries field';
                    }
                    field(PrintUnappliedEntries; PrintUnappliedEntries)
                    {
                        Caption = 'Include Unapplied Entries';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Include Unapplied Entries field';
                    }
                    field(IncludeAgingBand; IncludeAgingBand)
                    {
                        Caption = 'Include Aging Band';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Include Aging Band field';
                    }
                    field(PeriodLength; PeriodLength)
                    {
                        Caption = 'Aging Band Period Length';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Aging Band Period Length field';
                    }
                    field(DateChoice; DateChoice)
                    {
                        Caption = 'Aging Band by';
                        OptionCaption = 'Due Date,Posting Date';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Aging Band by field';
                    }
                    field(LogInteraction; LogInteraction)
                    {
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Log Interaction field';
                    }
                }
                group("Output Options")
                {
                    Caption = 'Output Options';
                    field(ReportOutput; SupportedOutputMethod)
                    {
                        Caption = 'Report Output';
                        OptionCaption = 'Print,Preview,PDF,Email,Excel,XML';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Report Output field';

                        trigger OnValidate()
                        var
                            CustomLayoutReporting: Codeunit "Custom Layout Reporting";
                        begin
                            ShowPrintRemaining := (SupportedOutputMethod = SupportedOutputMethod::Email);

                            case SupportedOutputMethod of
                                SupportedOutputMethod::Print:
                                    ChosenOutputMethod := CustomLayoutReporting.GetPrintOption;
                                SupportedOutputMethod::Preview:
                                    ChosenOutputMethod := CustomLayoutReporting.GetPreviewOption;
                                SupportedOutputMethod::PDF:
                                    ChosenOutputMethod := CustomLayoutReporting.GetPDFOption;
                                SupportedOutputMethod::Email:
                                    ChosenOutputMethod := CustomLayoutReporting.GetEmailOption;
                                SupportedOutputMethod::Excel:
                                    ChosenOutputMethod := CustomLayoutReporting.GetExcelOption;
                                SupportedOutputMethod::XML:
                                    ChosenOutputMethod := CustomLayoutReporting.GetXMLOption;
                            end;
                        end;
                    }
                    field(ChosenOutput; ChosenOutputMethod)
                    {
                        Caption = 'Chosen Output';
                        Visible = false;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Chosen Output field';
                    }
                    group(EmailOptions)
                    {
                        Caption = 'Email Options';
                        Visible = ShowPrintRemaining;
                        field(PrintMissingAddresses; PrintRemaining)
                        {
                            Caption = 'Print remaining statements';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Print remaining statements field';
                        }
                    }
                }
            }
        }

        actions
        {
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

    labels
    {
    }

    trigger OnInitReport()
    begin
        GLSetup.Get;
    end;

    var
        Text000: Label 'Page';
        Text001: Label 'Entries %1';
        Text002: Label 'Overdue Entries %1';
        Text003: Label 'Statement ';
        GLSetup: Record "General Ledger Setup";
        CompanyInfo: Record "Company Information";
        Cust2: Record Customer;
        Currency: Record Currency;
        Currency2: Record Currency temporary;
        Language: Codeunit Language;
        "Cust. Ledger Entry": Record "Cust. Ledger Entry";
        DtldCustLedgEntries2: Record "Detailed Cust. Ledg. Entry";
        AgingBandBuf: Record "Aging Band Buffer" temporary;
        PrintAllHavingEntry: Boolean;
        PrintAllHavingBal: Boolean;
        PrintEntriesDue: Boolean;
        PrintUnappliedEntries: Boolean;
        PrintReversedEntries: Boolean;
        PrintLine: Boolean;
        LogInteraction: Boolean;
        EntriesExists: Boolean;
        StartDate: Date;
        EndDate: Date;
        "Due Date": Date;
        CustAddr: array[8] of Text[50];
        CompanyAddr: array[8] of Text[50];
        Description: Text[50];
        StartBalance: Decimal;
        CustBalance: Decimal;
        "Remaining Amount": Decimal;
        FormatAddr: Codeunit "Format Address";
        SegManagement: Codeunit SegManagement;
        CurrencyCode3: Code[10];
        Text005: Label 'Multicurrency Application';
        Text006: Label 'Payment Discount';
        Text007: Label 'Rounding';
        PeriodLength: DateFormula;
        PeriodLength2: DateFormula;
        DateChoice: Option "Due Date","Posting Date";
        AgingDate: array[5] of Date;
        Text008: Label 'You must specify the Aging Band Period Length.';
        AgingBandEndingDate: Date;
        Text010: Label 'You must specify Aging Band Ending Date.';
        Text011: Label 'Aged Summary by %1 (%2 by %3)';
        IncludeAgingBand: Boolean;
        Text012: Label 'Period Length is out of range.';
        AgingBandCurrencyCode: Code[10];
        Text013: Label 'Due Date,Posting Date';
        Text014: Label 'Application Writeoffs';
        [InDataSet]
        LogInteractionEnable: Boolean;
        StatementCaptionLbl: Label 'Statement';
        CompanyInfo__Phone_No__CaptionLbl: Label 'Phone No.';
        CompanyInfo__Fax_No__CaptionLbl: Label 'Fax No.';
        CompanyInfo__VAT_Registration_No__CaptionLbl: Label 'VAT Reg. No.';
        CompanyInfo__Giro_No__CaptionLbl: Label 'Giro No.';
        CompanyInfo__Bank_Name_CaptionLbl: Label 'Bank';
        CompanyInfo__Bank_Account_No__CaptionLbl: Label 'Account No.';
        Customer__No__CaptionLbl: Label 'Customer No.';
        StartDateCaptionLbl: Label 'Starting Date';
        EndDateCaptionLbl: Label 'Ending Date';
        Customer__Last_Statement_No__CaptionLbl: Label 'Statement No.';
        DtldCustLedgEntries__Posting_Date_CaptionLbl: Label 'Posting Date';
        CustLedgEntry2__Due_Date_CaptionLbl: Label 'Due Date';
        CustBalanceCaptionLbl: Label 'Balance';
        CompanyInfo__IBAN__PM__CaptionLbl: Label 'IBAN';
        Please_use_the_following_reference_upon_payment_CaptionLbl: Label 'Please use the following reference upon payment:';
        Card_TypeCaptionLbl: Label 'Card Type';
        Payment_IdentificationCaptionLbl: Label 'Payment Identification';
        Vendor_No_CaptionLbl: Label 'Vendor No.';
        CustBalance___AmountCaptionLbl: Label 'Continued';
        CustBalance___Amount_Control75CaptionLbl: Label 'Continued';
        CustBalance_Control71CaptionLbl: Label 'Total';
        CustLedgEntry2__Remaining_Amount_CaptionLbl: Label 'Continued';
        CustLedgEntry2__Remaining_Amount__Control64CaptionLbl: Label 'Continued';
        CustLedgEntry2__Remaining_Amount__Control66CaptionLbl: Label 'Total';
        BeforeCaptionLbl: Label '..before';
        Payment_ID: Text;
        IK_Card_Type: Text;
        RetailSetup: Record "NPR Retail Setup";
        Giro_No: Text;
        SupportedOutputMethod: Option Print,Preview,PDF,Email,Excel,XML;
        ChosenOutputMethod: Integer;
        [InDataSet]
        ShowPrintRemaining: Boolean;
        PrintRemaining: Boolean;

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
        I: Integer;
        GoOn: Boolean;
    begin
        AgingBandBuf.Init;
        AgingBandBuf."Currency Code" := CurrencyCode;
        if not AgingBandBuf.Find then
            AgingBandBuf.Insert;
        I := 1;
        GoOn := true;
        while (I <= 5) and GoOn do begin
            if Date <= AgingDate[I] then
                if I = 1 then begin
                    AgingBandBuf."Column 1 Amt." := AgingBandBuf."Column 1 Amt." + Amount;
                    GoOn := false;
                end;
            if Date <= AgingDate[I] then
                if I = 2 then begin
                    AgingBandBuf."Column 2 Amt." := AgingBandBuf."Column 2 Amt." + Amount;
                    GoOn := false;
                end;
            if Date <= AgingDate[I] then
                if I = 3 then begin
                    AgingBandBuf."Column 3 Amt." := AgingBandBuf."Column 3 Amt." + Amount;
                    GoOn := false;
                end;
            if Date <= AgingDate[I] then
                if I = 4 then begin
                    AgingBandBuf."Column 4 Amt." := AgingBandBuf."Column 4 Amt." + Amount;
                    GoOn := false;
                end;
            if Date <= AgingDate[I] then
                if I = 5 then begin
                    AgingBandBuf."Column 5 Amt." := AgingBandBuf."Column 5 Amt." + Amount;
                    GoOn := false;
                end;
            I := I + 1;
        end;
        AgingBandBuf.Modify;
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
        Counter: Integer;
        Accumulator: Integer;
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
    begin
        StringLen := 15;

        if DelChr(Format(Cust."No."), '=', '0123456789') <> '' then
            exit;

        if not RetailSetup.Get then
            exit;

        IK_Card_Type := '71';
        Giro_No := RetailSetup."FIK No.";

        Payment_ID := PadStr('', StringLen - 2 - StrLen(Cust."No."), '0') + Cust."No." + '1';
        Payment_ID := Payment_ID + Modulus10(Payment_ID);
    end;
}

