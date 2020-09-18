page 6059814 "NPR Retail Top 10 Customers"
{
    // NC1.17/BHR/20150406 CASE 212983  TOP 10 CUSTOMERS
    // NC1.17/MH/20150619  CASE 216793 Changed pagename
    // NC1.17/BHR/20150619 CASE 216856 Sort the top 10 cust
    // NC1.19/BHR/20150720 CASE 218963 Change caption of Actions and property of Sales(LCY)
    // NC1.20/BHR/20150805 CASE 218620 Applied datefilter
    // NC1.22/JLK/20151215 CASE 229520 Phone No. moved 1 field up
    // NC1.22/BHR/20160107 CASE 227440 format "search name" to enable prober sorting of code.
    // NPR5.23.03/MHA/20160726  CASE 242557 Object renamed and re-versioned from NC1.22 to NPR5.23.03
    // NPR5.29/BHR /20170116 CASE 262956 code to Filter on Specific date

    Caption = 'Top 10 Customers';
    CardPageID = "Customer Card";
    Editable = true;
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = Customer;
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
                    ApplicationArea = All;
                    Caption = 'Start Date';

                    trigger OnValidate()
                    begin
                        //-NPR5.29 [262956]
                        ExecuteQuery;
                        //+NPR5.29 [262956]
                    end;
                }
                field(Enddate; Enddate)
                {
                    ApplicationArea = All;
                    Caption = 'End date';

                    trigger OnValidate()
                    begin
                        //-NPR5.29 [262956]
                        ExecuteQuery;
                        //+NPR5.29 [262956]
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
                        ApplicationArea = All;
                        Editable = false;

                        trigger OnDrillDown()
                        begin
                            //-NC1.22
                            Cust.Get("No.");
                            PAGE.Run(PAGE::"Customer Card", Cust);
                            //+NC1.22
                        end;
                    }
                    field(Name; Name)
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("Phone No."; "Phone No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("Sales (LCY)"; "Sales (LCY)")
                    {
                        ApplicationArea = All;
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
                    ApplicationArea = All;

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
        Query1: Query "NPR Retail Top 10 Cust. Sales";
        Cust: Record Customer;
        StartDate: Date;
        Enddate: Date;
        Err000: Label 'End Date should be after Start Date';
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period;
        CurrDate: Date;
        sales: Decimal;

    local procedure UpdateList()
    begin
        //-NPR5.29 [262956]
        //DELETEALL;
        //+NPR5.29 [262956]
        Setdate;
        //-NPR5.29 [262956]
        ExecuteQuery;
        //+NPR5.29 [262956]
    end;

    local procedure ExecuteQuery()
    begin
        //-NPR5.29 [262956]
        DeleteAll;
        Query1.SetFilter(Posting_Date, '%1..%2', StartDate, Enddate);
        Query1.Open;
        while Query1.Read do begin
            if Cust.Get(Query1.Source_No) then begin
                TransferFields(Cust);
                if not Insert then;
                //-NC1.20
                SetFilter("Date Filter", '%1..%2', StartDate, Enddate);
                //+NC1.20
                //-NC1.17
                //-NC1.20
                //  Cust.CALCFIELDS("Sales (LCY)");
                //  "Search Name" := FORMAT(Cust."Sales (LCY)");
                //  "Search Name" := PADSTR('',15 - STRLEN("Search Name"),'0') + "Search Name";

                CalcFields("Sales (LCY)");
                //-NC1.22
                //"Search Name" := FORMAT("Sales (LCY)");
                "Search Name" := Format(-"Sales (LCY)" * 100, 20, 1);
                //+NC1.22
                //  "Search Name" := FORMAT("Sales (LCY)");
                "Search Name" := PadStr('', 15 - StrLen("Search Name"), '0') + "Search Name";
                Modify;
                //+NC1.20
                //+NC1.17

            end;
        end;
        Query1.Close;
        //-NPR5.29 [262956]
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

