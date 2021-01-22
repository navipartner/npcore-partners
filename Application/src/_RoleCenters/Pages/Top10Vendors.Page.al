page 6151258 "NPR Top 10 Vendors"
{
    Caption = 'Top 10 Vendors';
    CardPageID = "Vendor Card";
    Editable = true;
    PageType = ListPart;
    SourceTable = Vendor;
    SourceTableTemporary = true;
    SourceTableView = SORTING("Search Name")
                      ORDER(Descending);
    UsageCategory = None;
    layout
    {
        area(content)
        {
            group(Control6014402)
            {
                ShowCaption = false;
                field(StartDate; StartDate)
                {
                    ApplicationArea = All;
                    Caption = 'Start Date';
                    ToolTip = 'Specifies the value of the Start Date field';

                    trigger OnValidate()
                    begin
                        ExecuteQuery();
                    end;
                }
                field(Enddate; Enddate)
                {
                    ApplicationArea = All;
                    Caption = 'End date';
                    ToolTip = 'Specifies the value of the End date field';

                    trigger OnValidate()
                    begin
                        ExecuteQuery();
                    end;
                }
            }
            group(Control6014403)
            {
                ShowCaption = false;
                repeater(Group)
                {
                    field("No."; Rec."No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
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
                        Editable = false;
                        ToolTip = 'Specifies the value of the Name field';
                    }
                    field("Phone No."; Rec."Phone No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Phone No. field';
                    }
                    field("Sales (LCY)"; Rec."NPR Sales (LCY)")
                    {
                        ApplicationArea = All;
                        BlankZero = true;
                        Caption = 'Sales Amount (Actual)';
                        Editable = false;
                        ToolTip = 'Specifies the value of the Sales Amount (Actual) field';
                    }
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
        CurrDate := Today;
        UpdateList();
    end;

    var
        Cust: Record Customer;
        TopTenVendorsQuery: Query "NPR Top 10 Vendor";
        CurrDate: Date;
        Enddate: Date;
        StartDate: Date;
        sales: Decimal;
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period;

    local procedure UpdateList()
    begin
        Setdate();
        ExecuteQuery();
    end;

    local procedure ExecuteQuery()
    begin
        Rec.DeleteAll();
        TopTenVendorsQuery.SetFilter(Posting_Date, '%1..%2', StartDate, Enddate);
        TopTenVendorsQuery.Open();
        while TopTenVendorsQuery.Read() do begin
            if Cust.Get(TopTenVendorsQuery.Source_No) then begin
                Rec."No." := Cust."No.";
                Rec.Name := Cust.Name;
                Rec."Phone No." := Cust."Phone No.";
                if not Rec.Insert() then;
                Rec.SetFilter("Date Filter", '%1..%2', StartDate, Enddate);
                Rec.CalcFields("NPR Sales (LCY)");
                Rec."Search Name" := Format(-Rec."NPR Sales (LCY)" * 100, 20, 1);
                Rec."Search Name" := PadStr('', 15 - StrLen(Rec."Search Name"), '0') + Rec."Search Name";
                Rec.Modify();
            end;
        end;
        TopTenVendorsQuery.Close();
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