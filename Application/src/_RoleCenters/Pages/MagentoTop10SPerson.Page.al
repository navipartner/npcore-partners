page 6151485 "NPR Magento Top 10 S.Person"
{
    Extensible = False;
    Caption = 'Top 10 Sales Persons';
    CardPageID = "NPR Salesperson Card";
    Editable = false;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "Salesperson/Purchaser";
    SourceTableTemporary = true;
    SourceTableView = SORTING("Search E-Mail")
                      ORDER(Descending)
                      WHERE("NPR Sales (Qty.)" = FILTER(<> 0));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        SalesPerson.Get(Rec.Code);
                        PAGE.Run(PAGE::"NPR Salesperson Card", SalesPerson);
                    end;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales (LCY)"; Rec."NPR Sales (LCY)")
                {

                    BlankZero = true;
                    Caption = 'Sales Amount (Actual)';
                    ToolTip = 'Specifies the value of the Sales Amount (Actual) field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales (Qty.)"; Rec."NPR Sales (Qty.)")
                {

                    ToolTip = 'Specifies the value of the NPR Sales (Qty.) field';
                    ApplicationArea = NPRRetail;
                }
                field("Search E-Mail"; Rec."Search E-Mail")
                {

                    ToolTip = 'Specifies the value of the Search E-Mail field';
                    ApplicationArea = NPRRetail;
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

                    ToolTip = 'Filters by day';
                    Image = Filter;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Day;
                        UpdateList();
                    end;
                }
                action(Week)
                {
                    Caption = 'Week';

                    ToolTip = 'Filters by week';
                    Image = Filter;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Week;
                        UpdateList();
                    end;
                }
                action(Month)
                {
                    Caption = 'Month';

                    ToolTip = 'Filters by month';
                    Image = Filter;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Month;
                        UpdateList();
                    end;
                }
                action(Quarter)
                {
                    Caption = 'Quarter';

                    ToolTip = 'Filters by quarter';
                    Image = Filter;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Quarter;
                        UpdateList();
                    end;
                }
                action(Year)
                {
                    Caption = 'Year';

                    ToolTip = 'Filters by year';
                    Image = Filter;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Year;
                        UpdateList();
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        PeriodType := PeriodType::Year;
        CurrDate := Today();
        UpdateList();
    end;

    var
        Query1: Query "NPR Retail Top 10 S.Persons";
        SalesPerson: Record "Salesperson/Purchaser";
        StartDate: Date;
        Enddate: Date;
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period;
        CurrDate: Date;

    local procedure UpdateList()
    begin
        Rec.DeleteAll();
        Setdate();
        Clear(Query1);
        Query1.SetFilter(Query1.Date_Filter, '%1..%2', StartDate, Enddate);
        Query1.Open();
        while Query1.Read() do begin
            SalesPerson.Get(Query1.Code);
            Rec.TransferFields(SalesPerson);
            if Rec.Insert() then;
            Rec.SetFilter("Date Filter", '%1..%2', StartDate, Enddate);
            Rec.CalcFields("NPR Sales (Qty.)");

            Rec."Search E-Mail" := Format(Round(-Rec."NPR Sales (Qty.)", 0.01) * 100, 20, 1);
            Rec."Search E-Mail" := PadStr('', 15 - StrLen(Rec."Search E-Mail"), '0') + Rec."Search E-Mail";
            Rec.Modify();
        end;
        Query1.Close();
    end;

    local procedure Setdate()
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
