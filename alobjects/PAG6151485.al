page 6151485 "Magento Top 10 SalesPerson"
{
    // MAG1.20/BHR/20150928 CASE 223709 Object created
    // MAG1.22/JDH/20160202 CASE 233311 DK caption changed for page
    // MAG1.22/BHR/20160107 CASE 227440 format of "Search E-Mail" to enable proper sorting.
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration

    Caption = 'Top 10 Sales Persons';
    CardPageID = "Salesperson Card";
    Editable = false;
    PageType = ListPart;
    SourceTable = "Salesperson/Purchaser";
    SourceTableTemporary = true;
    SourceTableView = SORTING("Search E-Mail")
                      ORDER(Descending)
                      WHERE("Sales (Qty.)" = FILTER(<> 0));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        //-MAG1.22
                        //PAGE.RUN(6014428,REC);
                        SalesPerson.Get(Code);
                        PAGE.Run(PAGE::"Salesperson Card", SalesPerson);
                        //+MAG1.22
                    end;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field("Sales (LCY)"; "Sales (LCY)")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Sales Amount (Actual)';
                }
                field("Sales (Qty.)"; "Sales (Qty.)")
                {
                    ApplicationArea = All;
                }
                field("Search E-Mail"; "Search E-Mail")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("Period Length")
            {
                Caption = 'Period Length';
                Image = CostAccounting;
                Visible = true;
                action(Day)
                {
                    Caption = 'Day';

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Day;
                        UpdateList;
                    end;
                }
                action(Week)
                {
                    Caption = 'Week';

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Week;
                        UpdateList;
                    end;
                }
                action(Month)
                {
                    Caption = 'Month';

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Month;
                        UpdateList;
                    end;
                }
                action(Quarter)
                {
                    Caption = 'Quarter';

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Quarter;
                        UpdateList;
                    end;
                }
                action(Year)
                {
                    Caption = 'Year';

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Year;
                        UpdateList;
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        PeriodType := PeriodType::Year;
        CurrDate := Today;
        UpdateList;
    end;

    var
        Query1: Query "Retail Top 10 SalesPersons";
        SalesPerson: Record "Salesperson/Purchaser";
        StartDate: Date;
        Enddate: Date;
        Err000: Label 'End Date should be after Start Date';
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period;
        CurrDate: Date;

    local procedure UpdateList()
    begin
        DeleteAll;
        Setdate;
        Clear(Query1);
        Query1.SetFilter(Query1.Date_Filter, '%1..%2', StartDate, Enddate);
        Query1.Open;
        while Query1.Read do begin
            SalesPerson.Get(Query1.Code);
            TransferFields(SalesPerson);
            //-MAG1.22
            if Insert then;
            //+MAG1.22
            SetFilter("Date Filter", '%1..%2', StartDate, Enddate);
            CalcFields("Sales (Qty.)");

            //-MAG1.22
            //"Search E-Mail" := FORMAT(ROUND("Sales (Qty.)",0.01) * 100);
            "Search E-Mail" := Format(Round(-"Sales (Qty.)", 0.01) * 100, 20, 1);
            "Search E-Mail" := PadStr('', 15 - StrLen("Search E-Mail"), '0') + "Search E-Mail";
            Modify;
            //+MAG1.22
        end;
        Query1.Close;
    end;

    local procedure Setdate()
    var
        DatePeriod: Record Date;
    begin
        case PeriodType of
            PeriodType::Day:
                begin
                    StartDate := CurrDate;
                    Enddate := CurrDate;
                end;
            PeriodType::Week:
                begin
                    StartDate := CalcDate('<-CW>', CurrDate);
                    Enddate := CalcDate('<CW>', CurrDate);
                end;
            PeriodType::Month:
                begin
                    StartDate := CalcDate('<-CM>', CurrDate);
                    Enddate := CalcDate('<CM>', CurrDate);
                end;
            PeriodType::Quarter:
                begin
                    StartDate := CalcDate('<-CQ>', CurrDate);
                    Enddate := CalcDate('<CQ>', CurrDate);
                end;
            PeriodType::Year:
                begin
                    StartDate := CalcDate('<-CY>', CurrDate);
                    Enddate := CalcDate('<CY>', CurrDate);
                end;
        end;
    end;
}

