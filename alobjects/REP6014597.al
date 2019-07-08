report 6014597 "Sales Per Contact"
{
    // NPR70.00.00.00/LS/20141112  CASE 187453 : Convert Report to NAV 2013
    // 
    // NPR5.30/JLK /20170202  CASE 253099  Added Calcfields before turnover and modified rdlc layout to display contacts only once
    //                                     Removed harcoded text with text constant NoDateFilter
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    DefaultLayout = RDLC;
    RDLCLayout = './Sales Per Contact.rdlc';

    Caption = 'Sales Per. Contact';

    dataset
    {
        dataitem(Contact;Contact)
        {

            trigger OnAfterGetRecord()
            var
                ValueEntry: Record "Value Entry";
            begin
                m += 1;

                //-NPR5.30
                Clear(SumOfTurnover);
                Clear(SumOfTurnoverLY);
                //+NPR5.30

                TurnoverTmp.Init;
                Contact1.Get("No.");

                if Contact.GetFilter("Date Filter") <> '' then begin
                  //-NPR5.30
                  ValueEntry.Reset;
                  ValueEntry.SetRange("Source No.",Contact1."No.");
                  ValueEntry.SetRange("Item Ledger Entry Type",ValueEntry."Item Ledger Entry Type"::Sale);
                  ValueEntry.SetFilter("Posting Date",Contact1.GetFilter("Date Filter"));
                  ValueEntry.CalcSums("Sales Amount (Actual)");
                  SumOfTurnoverLY := ValueEntry."Sales Amount (Actual)";
                  //+NPR5.30
                end;

                //-NPR5.30
                ValueEntry.Reset;
                ValueEntry.SetRange("Source No.","No.");
                ValueEntry.SetRange("Item Ledger Entry Type",ValueEntry."Item Ledger Entry Type"::Sale);
                ValueEntry.SetFilter("Posting Date",GetFilter("Date Filter"));
                ValueEntry.CalcSums("Sales Amount (Actual)");
                SumOfTurnover := ValueEntry."Sales Amount (Actual)";

                //IF SumOfTurnover = 0 THEN
                if (SumOfTurnover = 0) and (SumOfTurnoverLY = 0) then
                  CurrReport.Skip;
                //+NPR5.30

                //-NPR5.30
                //CALCFIELDS(Turnover);
                //Contact1.CALCFIELDS(Turnover);

                //TurnoverTmp."Decimal 1" := Multiple * Turnover;
                //TurnoverTmp."Decimal 2" := Turnover;
                //TurnoverTmp."Decimal 3" := Contact1.Turnover;
                TurnoverTmp."Decimal 1" := Multiple * SumOfTurnover;
                TurnoverTmp."Decimal 2" := SumOfTurnover;
                TurnoverTmp."Decimal 3" := SumOfTurnoverLY;
                //+NPR5.30

                if SumOfTurnoverLY <> 0 then
                  TurnoverTmp."Decimal 4" := SumOfTurnover / SumOfTurnoverLY * 100
                else
                  TurnoverTmp."Decimal 4" := 0;
                TurnoverTmp."Short Code 1" := "No.";
                TurnoverTmp.Template := "No.";
                TurnoverTmp.Description := Name;
                TurnoverTmp."Description 2" := Address;
                TurnoverTmp.Insert;
            end;

            trigger OnPreDataItem()
            begin
                m := 0;

                if Contact.GetFilter("Date Filter") <> '' then begin
                  MinDate := Contact.GetRangeMin("Date Filter");
                  MaxDate := Contact.GetRangeMax("Date Filter");
                  MinDateLY := CalcDate('<-1Y>',MinDate);
                  MaxDateLY := CalcDate('<-1Y>',MaxDate);
                  Contact.SetFilter("Date Filter",'%1..%2', MinDate, MaxDate);
                  Contact1.SetFilter("Date Filter",'%1..%2', MinDateLY, MaxDateLY);
                end;
            end;
        }
        dataitem("Integer";"Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number=FILTER(1..));
            column(Number_Integer;Integer.Number)
            {
            }
            column(Decimal2_TurnoverTmp;TurnoverTmp."Decimal 2")
            {
            }
            column(Decimal4_TurnoverTmp;TurnoverTmp."Decimal 4")
            {
            }
            column(Decimal3_TurnoverTmp;TurnoverTmp."Decimal 3")
            {
            }
            column(COMPANYNAME;CompanyName)
            {
            }
            column(QuantityFilter;StrSubstNo(Text10600002,ShowQuantity))
            {
            }
            column(ContactDateFilter;StrSubstNo(Text10600003,ContactDateFilter))
            {
            }
            column(No_Contact;Contact."No.")
            {
            }
            column(Name_Contact;Contact.Name)
            {
            }
            column(Address_Contact;Contact.Address)
            {
            }
            column(PostCode_Contact;Contact."Post Code")
            {
            }
            column(City_Contact;Contact.City)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if Number = 1 then begin
                  if not TurnoverTmp.Find('-') then
                    CurrReport.Break;
                end else
                  if (TurnoverTmp.Next = 0) then
                    CurrReport.Break;

                if Number > ShowQuantity then
                 CurrReport.Break;

                if (Number/2) = Round((Number/2),1) then
                  Greyed := false
                else
                  Greyed := true;

                Contact.Get(TurnoverTmp."Short Code 1");
            end;

            trigger OnPreDataItem()
            begin
                TurnoverTmp.SetCurrentKey("Decimal 1", "Short Code 1");
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Control6150614)
                {
                    ShowCaption = false;
                    field(Sorting;Sorting)
                    {
                        Caption = 'Sort By';
                    }
                    field(ShowQuantity;ShowQuantity)
                    {
                        Caption = 'Quantity';
                    }
                }
            }
        }

        actions
        {
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

        //-NPR5.39
        // Object.SETRANGE(ID, 6014597);
        // Object.SETRANGE(Type, 3);
        // Object.FIND('-');
        //+NPR5.39
        ContactDateFilter := Contact.GetFilter("Date Filter");

        if ContactDateFilter = '' then
          ContactDateFilter := NoDateFilter;
        //-NPR5.30
        //  CASE CurrReport.LANGUAGE OF
        //    1030: // DAN
        //      ContactDateFilter := 'Intet dato filter';
        //  ELSE
        //    ContactDateFilter := 'No date filter';
        //  END;
        //+NPR5.30

        if Sorting = Sorting::Largest then
          Multiple := -1
        else
          Multiple := 1;
    end;

    var
        Sorting: Option Largest,Smallest;
        Multiple: Integer;
        Contact1: Record Contact;
        MinDate: Date;
        MaxDate: Date;
        MinDateLY: Date;
        MaxDateLY: Date;
        CompanyInformation: Record "Company Information";
        ContactDateFilter: Text[30];
        TurnoverTmp: Record "NPR - TEMP Buffer" temporary;
        ShowQuantity: Integer;
        d: Dialog;
        m: Integer;
        i: Integer;
        j: Integer;
        Greyed: Boolean;
        Text10600002: Label 'Top %1';
        Text10600003: Label 'Period: %1';
        NoDateFilter: Label 'No date filter entered';
        SumOfTurnover: Decimal;
        SumOfTurnoverLY: Decimal;
}

