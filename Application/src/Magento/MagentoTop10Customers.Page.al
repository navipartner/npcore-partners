page 6151483 "NPR Magento Top 10 Customers"
{
    Caption = 'Top 10 Customers';
    CardPageID = "Customer Card";
    Editable = false;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = Customer;
    SourceTableTemporary = true;
    SourceTableView = SORTING("Search Name")
                      ORDER(Descending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';

                    trigger OnDrillDown()
                    begin
                        Cust.Get(Rec."No.");
                        PAGE.Run(PAGE::"Customer Card", Cust);
                    end;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Phone No. field';
                }
                field("Sales (LCY)"; Rec."Sales (LCY)")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Sales Amount (Actual)';
                    ToolTip = 'Specifies the value of the Sales Amount (Actual) field';
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
                    ApplicationArea = All;
                    ToolTip = 'Filters by day';
                    Image = Filter;

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Day;
                        UpdateList();
                    end;
                }
                action(Week)
                {
                    Caption = 'Week';
                    ApplicationArea = All;
                    ToolTip = 'Filters by week';
                    Image = Filter;

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Week;
                        UpdateList();
                    end;
                }
                action(Month)
                {
                    Caption = 'Month';
                    ApplicationArea = All;
                    ToolTip = 'Filters by month';
                    Image = Filter;

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Month;
                        UpdateList();
                    end;
                }
                action(Quarter)
                {
                    Caption = 'Quarter';
                    ApplicationArea = All;
                    ToolTip = 'Filters by quarter';
                    Image = Filter;

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Quarter;
                        UpdateList();
                    end;
                }
                action(Year)
                {
                    Caption = 'Year';
                    ApplicationArea = All;
                    ToolTip = 'Filters by year';
                    Image = Filter;

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
        Query1: Query "NPR Top 10 Cust. Sales";
        Cust: Record Customer;
        StartDate: Date;
        Enddate: Date;
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period;
        CurrDate: Date;

    local procedure UpdateList()
    begin
        Rec.DeleteAll();
        Setdate;
        Query1.SetFilter(Posting_Date, '%1..%2', StartDate, Enddate);
        Query1.Open();
        while Query1.Read() do begin
            Cust.Get(Query1.Source_No);
            Rec.TransferFields(Cust);
            if not Rec.Insert() then;
            Rec.SetFilter("Date Filter", '%1..%2', StartDate, Enddate);

            Rec.CalcFields("Sales (LCY)");
            Rec."Search Name" := Format(-Rec."Sales (LCY)" * 100, 20, 1);
            Rec."Search Name" := PadStr('', 15 - StrLen(Rec."Search Name"), '0') + Rec."Search Name";
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