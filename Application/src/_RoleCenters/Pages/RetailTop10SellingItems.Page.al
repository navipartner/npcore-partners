page 6151256 "NPR Retail Top10 Selling Items"
{
    Extensible = False;

    Caption = 'Top 10 Items by Quantity';
    CardPageID = "Item Card";
    Editable = true;
    PageType = ListPart;
    SourceTable = Item;
    SourceTableTemporary = true;
    SourceTableView = SORTING("Low-Level Code")
                      ORDER(Descending);
    UsageCategory = None;
    layout
    {
        area(content)
        {
            group(Control6014403)
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
            group(Control6014400)
            {
                ShowCaption = false;
                repeater(Group)
                {
                    field("No."; Rec."No.")
                    {

                        ToolTip = 'Specifies the No. of the item';
                        ApplicationArea = NPRRetail;

                        trigger OnDrillDown()
                        begin
                            Item.Get(Rec."No.");
                            PAGE.Run(PAGE::"Item Card", Item);
                        end;
                    }
                    field(Description; Rec.Description)
                    {

                        ToolTip = 'Specifies the Description of the item';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sales (Qty.)"; Rec."Sales (Qty.)")
                    {
                        BlankZero = true;
                        Caption = 'Sales (Qty.)';

                        ToolTip = 'Specifies the Sales (Qty.) that this item is sold within the date range';
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
        Query1: Query "NPR Retail Top 10 ItemsByQty.";
        Item: Record Item;
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
        Query1.SetFilter(Item_Ledger_Entry_Type, 'Sale');
        Query1.Open();
        while Query1.Read() do begin
            if Item.Get(Query1.Item_No) then begin
                Rec.TransferFields(Item);
                if Rec.Insert() then
                    Rec.SetFilter("Date Filter", '%1..%2', StartDate, Enddate);
                Rec.CalcFields("Sales (Qty.)");
                Rec."Low-Level Code" := Round(Rec."Sales (Qty.)", 0.01) * 100;
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

