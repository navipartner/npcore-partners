page 6151258 "NP Retail Top 10 Vendors"
{
    // #369128/YAHA/20191113 CASE 369128 Created page Top 10 Vendors

    Caption = 'Top 10 Vendors';
    CardPageID = "Vendor Card";
    Editable = true;
    PageType = ListPart;
    SourceTable = Vendor;
    SourceTableTemporary = true;
    SourceTableView = SORTING("Search Name")
                      ORDER(Descending);

    layout
    {
        area(content)
        {
            group(Control6014402)
            {
                ShowCaption = false;
                field(StartDate; StartDate)
                {
                    Caption = 'Start Date';

                    trigger OnValidate()
                    begin
                        ExecuteQuery;
                    end;
                }
                field(Enddate; Enddate)
                {
                    Caption = 'End date';

                    trigger OnValidate()
                    begin
                        ExecuteQuery;
                    end;
                }
            }
            group(Control6014403)
            {
                ShowCaption = false;
                repeater(Group)
                {
                    field("No."; "No.")
                    {
                        Editable = false;

                        trigger OnDrillDown()
                        begin
                            Cust.Get("No.");
                            PAGE.Run(PAGE::"Customer Card", Cust);
                        end;
                    }
                    field(Name; Name)
                    {
                        Editable = false;
                    }
                    field("Phone No."; "Phone No.")
                    {
                        Editable = false;
                    }
                    field("Sales (LCY)"; "Sales (LCY)")
                    {
                        BlankZero = true;
                        Caption = 'Sales Amount (Actual)';
                        Editable = false;
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
        Query1: Query "NP Retail Top 10 Vendor";
        Cust: Record Customer;
        StartDate: Date;
        Enddate: Date;
        Err000: Label 'End Date should be after Start Date';
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period;
        CurrDate: Date;
        sales: Decimal;

    local procedure UpdateList()
    begin
        Setdate;
        ExecuteQuery;
    end;

    local procedure ExecuteQuery()
    begin
        DeleteAll;
        Query1.SetFilter(Posting_Date, '%1..%2', StartDate, Enddate);
        Query1.Open;
        while Query1.Read do begin
            if Cust.Get(Query1.Source_No) then begin
                TransferFields(Cust);
                if not Insert then;
                SetFilter("Date Filter", '%1..%2', StartDate, Enddate);
                CalcFields("Sales (LCY)");
                "Search Name" := Format(-"Sales (LCY)" * 100, 20, 1);
                "Search Name" := PadStr('', 15 - StrLen("Search Name"), '0') + "Search Name";
                Modify;


            end;
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

