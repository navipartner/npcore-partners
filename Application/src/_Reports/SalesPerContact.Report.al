report 6014597 "NPR Sales Per Contact"
{
    #IF NOT BC17 
    Extensible = False; 
    #ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Sales Per Contact.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Sales Per. Contact';
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Contact; Contact)
        {

            trigger OnAfterGetRecord()
            var
                ValueEntry: Record "Value Entry";
            begin

                Clear(SumOfTurnover);
                Clear(SumOfTurnoverLY);
                TempTurnover.Init();
                Contact1.Get("No.");

                if Contact.GetFilter("Date Filter") <> '' then begin
                    ValueEntry.Reset();
                    ValueEntry.SetRange("Source No.", Contact1."No.");
                    ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
                    ValueEntry.SetFilter("Posting Date", Contact1.GetFilter("Date Filter"));
                    ValueEntry.CalcSums("Sales Amount (Actual)");
                    SumOfTurnoverLY := ValueEntry."Sales Amount (Actual)";
                end;

                ValueEntry.Reset();
                ValueEntry.SetRange("Source No.", "No.");
                ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
                ValueEntry.SetFilter("Posting Date", GetFilter("Date Filter"));
                ValueEntry.CalcSums("Sales Amount (Actual)");
                SumOfTurnover := ValueEntry."Sales Amount (Actual)";

                if (SumOfTurnover = 0) and (SumOfTurnoverLY = 0) then
                    CurrReport.Skip();
                TempTurnover."Decimal 1" := Multiple * SumOfTurnover;
                TempTurnover."Decimal 2" := SumOfTurnover;
                TempTurnover."Decimal 3" := SumOfTurnoverLY;

                if SumOfTurnoverLY <> 0 then
                    TempTurnover."Decimal 4" := SumOfTurnover / SumOfTurnoverLY * 100
                else
                    TempTurnover."Decimal 4" := 0;
                TempTurnover."Short Code 1" := "No.";
                TempTurnover.Template := "No.";
                TempTurnover.Description := Name;
                TempTurnover."Description 2" := Address;
                TempTurnover.Insert();
            end;

            trigger OnPreDataItem()
            begin

                if Contact.GetFilter("Date Filter") <> '' then begin
                    MinDate := Contact.GetRangeMin("Date Filter");
                    MaxDate := Contact.GetRangeMax("Date Filter");
                    MinDateLY := CalcDate('<-1Y>', MinDate);
                    MaxDateLY := CalcDate('<-1Y>', MaxDate);
                    Contact.SetFilter("Date Filter", '%1..%2', MinDate, MaxDate);
                    Contact1.SetFilter("Date Filter", '%1..%2', MinDateLY, MaxDateLY);
                end;
            end;
        }
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
            column(Number_Integer; Integer.Number)
            {
            }
            column(Decimal2_TurnoverTmp; TempTurnover."Decimal 2")
            {
            }
            column(Decimal4_TurnoverTmp; TempTurnover."Decimal 4")
            {
            }
            column(Decimal3_TurnoverTmp; TempTurnover."Decimal 3")
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column(QuantityFilter; StrSubstNo(TopLbl, ShowQuantity))
            {
            }
            column(ContactDateFilter; StrSubstNo(PeriodLbl, ContactDateFilter))
            {
            }
            column(No_Contact; Contact."No.")
            {
            }
            column(Name_Contact; Contact.Name)
            {
            }
            column(Address_Contact; Contact.Address)
            {
            }
            column(PostCode_Contact; Contact."Post Code")
            {
            }
            column(City_Contact; Contact.City)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if Number = 1 then begin
                    if not TempTurnover.Find('-') then
                        CurrReport.Break();
                end else
                    if (TempTurnover.Next() = 0) then
                        CurrReport.Break();

                if Number > ShowQuantity then
                    CurrReport.Break();



                Contact.Get(TempTurnover."Short Code 1");
            end;

            trigger OnPreDataItem()
            begin
                TempTurnover.SetCurrentKey("Decimal 1", "Short Code 1");
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
                group(Control6150614)
                {
                    ShowCaption = false;
                    field("Sorting"; SortOrder)
                    {

                        Caption = 'Sort By';
                        OptionCaption = 'Largest,Smallest';
                        ToolTip = 'Specifies the value of the Sort By field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Show Quantity"; ShowQuantity)
                    {

                        Caption = 'Quantity';
                        ToolTip = 'Specifies the value of the Quantity field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            if ShowQuantity = 0 then
                ShowQuantity := 10;
        end;
    }

    labels
    {
        Report_Caption = 'Contact analysis';
        Rank_Caption = 'Rank';
        No_Caption = 'No.';
        Name_Caption = 'Name';
        Address_Caption = 'Address';
        PostCode_Caption = 'Post Code';
        City_Caption = 'City';
        Turnover_Caption = 'Turnover';
        Index_Caption = 'Index';
        Turnover_LY_Caption = 'Turnover last year';
        Total_Caption = 'Total';
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);
        ContactDateFilter := Contact.GetFilter("Date Filter");

        if ContactDateFilter = '' then
            ContactDateFilter := NoDateFilterLbl;

        if SortOrder = SortOrder::Largest then
            Multiple := -1
        else
            Multiple := 1;
    end;

    var
        CompanyInformation: Record "Company Information";
        Contact1: Record Contact;
        TempTurnover: Record "NPR TEMP Buffer" temporary;
        MaxDate: Date;
        MaxDateLY: Date;
        MinDate: Date;
        MinDateLY: Date;
        SumOfTurnover: Decimal;
        SumOfTurnoverLY: Decimal;
        Multiple: Integer;
        ShowQuantity: Integer;
        NoDateFilterLbl: Label 'No date filter entered';
        PeriodLbl: Label 'Period: %1', Comment = '%1 = Contact Date Filter';
        TopLbl: Label 'Top %1', Comment = '%1 = Quantity';
        SortOrder: Option Largest,Smallest;
        ContactDateFilter: Text;
}

