page 6151484 "NPR Magento Top10 Items by Qty"
{
    Caption = 'Top 10 Items by Quantity';
    CardPageID = "Item Card";
    Editable = false;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = Item;
    SourceTableTemporary = true;
    SourceTableView = SORTING("Low-Level Code")
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
                        Item.Get(Rec."No.");
                        PAGE.Run(PAGE::"Item Card", Item);
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Sales (Qty.)"; Rec."Sales (Qty.)")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Sales (Qty.)';
                    ToolTip = 'Specifies the value of the Sales (Qty.) field';
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
                        UpdateList;
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
                        UpdateList;
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
                        UpdateList;
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
                        UpdateList;
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
        Query1: Query "NPR Top 10 Items by Quantity";
        Item: Record Item;
        StartDate: Date;
        Enddate: Date;
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period;
        CurrDate: Date;

    local procedure UpdateList()
    begin
        Rec.DeleteAll;
        Setdate;
        Query1.SetFilter(Posting_Date, '%1..%2', StartDate, Enddate);
        Query1.SetFilter(Item_Ledger_Entry_Type, 'Sale');
        Query1.Open;
        while Query1.Read do begin
            if Item.Get(Query1.Item_No) then begin
                Rec.TransferFields(Item);
                if Rec.Insert then
                    Rec.SetFilter("Date Filter", '%1..%2', StartDate, Enddate);

                Rec.CalcFields("Sales (Qty.)");
                Rec."Low-Level Code" := Round(Rec."Sales (Qty.)", 0.01) * 100;
                Rec.Modify;
            end;

        end;
        Query1.Close;
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