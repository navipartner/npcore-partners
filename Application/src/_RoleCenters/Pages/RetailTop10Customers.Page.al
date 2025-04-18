﻿page 6059814 "NPR Retail Top 10 Customers"
{
    Extensible = False;

    Caption = 'Top 10 Customers';
    CardPageID = "Customer Card";
    Editable = true;
    PageType = ListPart;
    SourceTable = Customer;
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
                    ToolTip = 'The user can specify the Start Date from which wants to see the data';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        ExecuteQuery();
                    end;
                }
                field(Enddate; Enddate)
                {

                    Caption = 'End date';
                    ToolTip = 'The user can specify the End date until which wants to see the data';
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
                        ToolTip = 'Specifies the No. of the customer';
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
                        ToolTip = 'Specifies the Name of the customer';
                        ApplicationArea = NPRRetail;
                    }
                    field("Phone No."; Rec."Phone No.")
                    {

                        Editable = false;
                        ToolTip = 'Specifies the Phone No. of the customer';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sales (LCY)"; Rec."Sales (LCY)")
                    {

                        BlankZero = true;
                        Caption = 'Sales Amount (Actual)';
                        Editable = false;
                        ToolTip = 'Speficies the Sales Amount (Actual) that the customer has made within the date range';
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

                    ToolTip = 'Select this filter to visualize data by day';
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

                    ToolTip = 'Select this filter to visualize data by week';
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

                    ToolTip = 'Select this filter to visualize data by month';
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

                    ToolTip = 'Select this filter to visualize data by quarter';
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

                    ToolTip = 'Select this filter to visualize data by year';
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
        Query1: Query "NPR Retail Top 10 Cust. Sales";
        Cust: Record Customer;
        StartDate: Date;
        Enddate: Date;
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period;
        CurrDate: Date;

    local procedure UpdateList()
    begin
        Setdate();
        ExecuteQuery();
    end;

    local procedure ExecuteQuery()
    begin
        Rec.DeleteAll();
        Query1.SetFilter(Posting_Date, '%1..%2', StartDate, Enddate);
        Query1.Open();
        while Query1.Read() do begin
            if Cust.Get(Query1.Source_No) then begin
                Rec.TransferFields(Cust);
                if not Rec.Insert() then;
                Rec.SetFilter("Date Filter", '%1..%2', StartDate, Enddate);
                Rec.CalcFields("Sales (LCY)");
                Rec."Search Name" := Format(-Rec."Sales (LCY)" * 100, 20, 1);
                Rec."Search Name" := PadStr('', 15 - StrLen(Rec."Search Name"), '0') + Rec."Search Name";
                Rec.Modify();
            end;
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
