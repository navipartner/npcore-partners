page 6151483 "NPR Magento Top 10 Customers"
{
    // MAG1.17/BHR/20150406 CASE 212983  TOP 10 CUSTOMERS
    // MAG1.17/MH/20150619  CASE 216793 Changed pagename
    // MAG1.17/BHR/20150619 CASE 216856 Sort the top 10 cust
    // MAG1.19/BHR/20150720 CASE 218963 Change caption of Actions and property of Sales(LCY)
    // MAG1.20/BHR/20150805 CASE 218620 Applied datefilter
    // MAG1.22/JLK/20151215 CASE 229520 Phone No. moved 1 field up
    // MAG1.22/BHR/20160107 CASE 227440 format "search name" to enable prober sorting of code.
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration

    Caption = 'Top 10 Customers';
    CardPageID = "Customer Card";
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';

                    trigger OnDrillDown()
                    begin
                        //-MAG1.22
                        Cust.Get("No.");
                        PAGE.Run(PAGE::"Customer Card", Cust);
                        //+MAG1.22
                    end;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Phone No. field';
                }
                field("Sales (LCY)"; "Sales (LCY)")
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
                    ToolTip = 'Executes the Day action';

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Day;
                        UpdateList;
                    end;
                }
                action(Week)
                {
                    Caption = 'Week';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Week action';

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Week;
                        UpdateList;
                    end;
                }
                action(Month)
                {
                    Caption = 'Month';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Month action';

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Month;
                        UpdateList;
                    end;
                }
                action(Quarter)
                {
                    Caption = 'Quarter';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Quarter action';

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Quarter;
                        UpdateList;
                    end;
                }
                action(Year)
                {
                    Caption = 'Year';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Year action';

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
        Query1: Query "NPR Top 10 Cust. Sales";
        Cust: Record Customer;
        StartDate: Date;
        Enddate: Date;
        Err000: Label 'End Date should be after Start Date';
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period;
        CurrDate: Date;
        sales: Decimal;

    local procedure UpdateList()
    begin
        DeleteAll;
        Setdate;
        Query1.SetFilter(Posting_Date, '%1..%2', StartDate, Enddate);
        Query1.Open;
        while Query1.Read do begin
            Cust.Get(Query1.Source_No);
            TransferFields(Cust);
            if not Insert then;
            //-MAG1.20
            SetFilter("Date Filter", '%1..%2', StartDate, Enddate);
            //+MAG1.20
            //-MAG1.17
            //-MAG1.20
            //  Cust.CALCFIELDS("Sales (LCY)");
            //  "Search Name" := FORMAT(Cust."Sales (LCY)");
            //  "Search Name" := PADSTR('',15 - STRLEN("Search Name"),'0') + "Search Name";

            CalcFields("Sales (LCY)");
            //-MAG1.22
            //"Search Name" := FORMAT("Sales (LCY)");
            "Search Name" := Format(-"Sales (LCY)" * 100, 20, 1);
            //+MAG1.22
            //  "Search Name" := FORMAT("Sales (LCY)");
            "Search Name" := PadStr('', 15 - StrLen("Search Name"), '0') + "Search Name";
            Modify;
            //+MAG1.20
            //+MAG1.17



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

