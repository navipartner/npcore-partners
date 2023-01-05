page 6059817 "NPR Retail Top 10 S.person"
{
    Extensible = False;
    Caption = 'Top 10 Sales Persons';
    CardPageID = "NPR Salesperson Card";
    Editable = true;
    PageType = ListPart;
    SourceTable = "Salesperson/Purchaser";
    SourceTableTemporary = true;
    UsageCategory = None;    
    SourceTableView = sorting("NPR Maximum Cash Returnsale") order (Descending);
                      
    layout
    {
        area(content)
        {
            group(Control6014404)
            {
                ShowCaption = false;
                field(StartDate; StartDate)
                {

                    Caption = 'Start Date';
                    ToolTip = 'The user can specify the Start Date from which wants to see the data';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        UpdateList();
                    end;
                }
                field(Enddate; Enddate)
                {

                    Caption = 'End date';
                    ToolTip = 'The user can specify the End date until which wants to see the data';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        UpdateList();
                    end;
                }
            }
            group(Control6014401)
            {
                ShowCaption = false;
                repeater(Group)
                {
                    field("Code"; Rec.Code)
                    {

                        ToolTip = 'Specifies the Code of the salesperson';
                        ApplicationArea = NPRRetail;

                        trigger OnDrillDown()
                        begin
                            SalesPerson.Get(Rec.Code);
                            PAGE.Run(PAGE::"NPR Salesperson Card", SalesPerson);
                        end;
                    }
                    field(Name; Rec.Name)
                    {

                        ToolTip = 'Specifies the Name of the salesperson';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sales (Qty.)"; Rec."NPR Maximum Cash Returnsale")
                    {

                        ToolTip = 'Specifies the value of the NPR Sales (Qty.) made within the date range';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sales (LCY)"; SalesLCY)
                    {

                        BlankZero = true;
                        Caption = 'Sales Amount (Actual)';
                        ToolTip = 'Specifies the value of the Sales Amount (Actual) made within the date range';
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
        PeriodType := PeriodType::Month;
        CurrDate := Today();
        UpdateList();
    end;


    trigger OnAfterGetRecord()
    begin
        Rec.NPRGetVESalesLCY(SalesLCY);
    end;

    var
        SalesPerson: Record "Salesperson/Purchaser";
        StartDate: Date;
        Enddate: Date;
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period;
        SalesLCY: Decimal;
        CurrDate: Date;

    local procedure UpdateList()
    var
        TempSalespersonPurchaser: Record "Salesperson/Purchaser" temporary;
        StartNo: Integer;
    begin
        TempSalespersonPurchaser.DeleteAll();
        Setdate();
        CalculateSalesPersonSalesQty(TempSalespersonPurchaser);
        TempSalespersonPurchaser.SetAscending("NPR Maximum Cash Returnsale", false);
        TempSalespersonPurchaser.SetFilter("NPR Maximum Cash Returnsale", '<>%1', 0);
        if TempSalespersonPurchaser.IsEmpty() then
            exit;
        TempSalespersonPurchaser.FindSet();
        StartNo := 0;
        repeat
            Rec.TransferFields(TempSalespersonPurchaser);
            if Rec.Insert() then;
            StartNo += 1;
        until (TempSalespersonPurchaser.Next() = 0) or (StartNo < 10);
    end;

    local procedure CalculateSalesPersonSalesQty(TempSalesPersonPurchaser: Record "Salesperson/Purchaser" temporary)
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        SalespersonPurchaser.SetFilter("Date Filter", '%1..%2', StartDate, Enddate);
        if not SalespersonPurchaser.FindSet() then
            exit;
        repeat
            TempSalesPersonPurchaser.TransferFields(SalespersonPurchaser);
            SalespersonPurchaser.NPRGetVESalesQty(TempSalesPersonPurchaser."NPR Maximum Cash Returnsale");
            if TempSalesPersonPurchaser.Insert() then;
        until SalespersonPurchaser.Next() = 0;
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

