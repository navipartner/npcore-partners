page 6151258 "NPR Top 10 Vendors"
{
    Extensible = False;
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

                    Caption = 'Start Date';
                    ToolTip = 'Specify the Start Date from which wants to see the data';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        ExecuteQuery();
                    end;
                }
                field(Enddate; Enddate)
                {

                    Caption = 'End date';
                    ToolTip = 'Specify the End date until which wants to see the data';
                    ApplicationArea = NPRRetail;

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

                        Editable = false;
                        ToolTip = 'Specifies the No. of the vendor';
                        ApplicationArea = NPRRetail;

                        trigger OnDrillDown()
                        begin
                            Cust.Get(Rec."No.");
                            PAGE.Run(PAGE::"Customer Card", Cust);
                        end;
                    }
                    field(Name; Rec.Name)
                    {

                        Editable = false;
                        ToolTip = 'Specifies the Name of the vendor';
                        ApplicationArea = NPRRetail;
                    }
                    field("Phone No."; Rec."Phone No.")
                    {

                        Editable = false;
                        ToolTip = 'Specifies the Phone No. of the vendor';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sales (LCY)"; SalesLCY)
                    {
                        BlankZero = true;
                        Caption = 'Sales Amount (Actual)';
                        Editable = false;
                        ToolTip = 'Speficies the Sales Amount (Actual) that the vendor has made within the date range';
                        ApplicationArea = NPRRetail;
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

    trigger OnAfterGetRecord()
    begin
        Rec.NPRGetVESalesLCYSalesQtyCOGSLCY(SalesLCY, SalesQty, COGSLCY);
    end;

    var
        Cust: Record Customer;
        TopTenVendorsQuery: Query "NPR Top 10 Vendor";
        CurrDate: Date;
        Enddate: Date;
        StartDate: Date;
        SalesLCY: Decimal;
        SalesQty: Decimal;
        COGSLCY: Decimal;
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
                Rec.NPRGetVESalesLCYSalesQtyCOGSLCY(SalesLCY, SalesQty, COGSLCY);
                Rec."Search Name" := Format(-SalesLCY * 100, 20, 1);
                Rec."Search Name" := PadStr('', 15 - StrLen(Rec."Search Name"), '0') + Rec."Search Name";
                Rec.Modify();
            end;
        end;
        TopTenVendorsQuery.Close();
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
