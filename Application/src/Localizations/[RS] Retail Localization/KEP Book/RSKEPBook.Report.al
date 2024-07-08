report 6014486 "NPR RS KEP Book"
{
#if not BC17
    Extensible = false;
#endif
    Caption = 'KEP Book';
    DefaultLayout = Word;
    WordLayout = './src/Localizations/[RS] Retail Localization/KEP Book/RSKEPBook.docx';
    UsageCategory = None;

    dataset
    {
        dataitem(HeaderInformation; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));

            column(CompanyInformation_Name; CompanyInformation.Name) { }
            column(KEPBookEntriesForYear_Lbl; StrSubstNo(KEPBookEntriesForYearLbl, YearFilter)) { }
            column(POSStore_Name; POSStore.Name) { }
            column(Location_Address; Location.Address) { }
        }

        dataitem(KEPBook; "NPR RS KEP Book")
        {
            DataItemTableView = sorting("Entry No.");

            column(Entry_No; "Entry No.") { }
            column(Posting_Date; Format("Posting Date", 0, '<Day>. <Month Text>')) { }
            column(Description; Description) { }
            column(Debit_Amout; "Debit Amount") { }
            column(Credit_Amount; "Credit Amount") { }
        }

        dataitem(Totals; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));
            
            column(Total_Debit_Amount; TotalDebitAmount) { }
            column(Total_Credit_Amount; TotalCreditAmount) { }
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group("KEP Book Filters")
                {
                    Caption = 'Filter: KEP Book';
                    field("Year Filter"; YearFilter)
                    {
                        ApplicationArea = NPRRSRLocal;
                        Caption = 'Year';
                        MaxValue = 9999;
                        MinValue = 1900;
                        ToolTip = 'Specifies the value of the Year field.';
                    }
                    field("POS Store Code Filter"; POSStoreCodeFilter)
                    {
                        ApplicationArea = NPRRSRLocal;
                        Caption = 'POS Store';
                        TableRelation = "NPR POS Store".Code;
                        ToolTip = 'Specifies the value of the POS Store field.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            POSStoreCodeFilter := POSStore.Code;
            YearFilter := Date2DMY(Today(), 3);
        end;
    }

    labels
    {
        ReportCaptionLbl = 'Образац  КЕП', Locked = true;
        ObligorCaptionLbl = 'OБВЕЗНИК', Locked = true;
        LocationCaptionLbl = 'MЕСТО', Locked = true;
        EntryNoCaptionLbl = 'Ред. број', Locked = true;
        PostingDateCaptionLbl = 'Датум књижења (дан и месец)', Locked = true;
        PostingDescriptionCaptionLbl = 'Oпис књижења(назив, број и датум документа)', Locked = true;
        DebitAmountCaptionLbl = 'задужење', Locked = true;
        CreditAmountCaptionLbl = 'раздужење', Locked = true;
        TotalAmountCaptionLbl = 'СВЕГА ЗА ПРЕНОС', Locked = true;
        POSStoreCaptionLbl = 'OБЈЕКАТ-ПРОДАЈНО МЕСТО', Locked = true;
        AmountLCYCaptionLbl = 'Износ динара', Locked = true;
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get();
        if POSStoreCodeFilter = '' then
            Error(POSStoreSelectionMandatoryLbl);

        if POSStore."Location Code" = '' then
            Error(LocationNotSetLbl);

        Location.Get(POSStore."Location Code");
        RSKEPBookMgt.CreateKEPBookDataset(KEPBook, Location.Code, YearFilter);

        KEPBook.CalcSums("Debit Amount", "Credit Amount");

        TotalDebitAmount := KEPBook."Debit Amount";
        TotalCreditAmount := KEPBook."Credit Amount";
    end;

    var
        CompanyInformation: Record "Company Information";
        Location: Record Location;
        POSStore: Record "NPR POS Store";
        RSKEPBookMgt: Codeunit "NPR RS KEP Book Mgt.";
        POSStoreCodeFilter: Code[10];
        TotalCreditAmount: Decimal;
        TotalDebitAmount: Decimal;
        YearFilter: Integer;
        KEPBookEntriesForYearLbl: Label 'КЊИГА ЕВИДЕНЦИЈЕ ПРОМЕТА ЗА %1 ГОДИНУ', Locked = true;
        LocationNotSetLbl: Label 'Location Code must be set for POS Store.';
        POSStoreSelectionMandatoryLbl: Label 'You must select POS Store in order to open the report.';

    internal procedure SetPOSStore(POSStoreCode: Code[10])
    begin
        POSStore.Get(POSStoreCode);
    end;
}