page 6059817 "NPR Retail Top 10 S.person"
{
    Extensible = false;
    Caption = 'Top 10 Salespersons';
    CardPageID = "Salesperson/Purchaser Card";
    Editable = true;
    PageType = ListPart;
    RefreshOnActivate = true;
    SourceTable = "Salesperson/Purchaser";
    SourceTableTemporary = true;
    UsageCategory = None;

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
                        UpdateList(false);
                    end;
                }
                field(Enddate; Enddate)
                {

                    Caption = 'End date';
                    ToolTip = 'The user can specify the End date until which wants to see the data';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        UpdateList(false);
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
                            Page.Run(Page::"Salesperson/Purchaser Card", SalesPerson);
                        end;
                    }
                    field(Name; Rec.Name)
                    {
                        ToolTip = 'Specifies the Name of the salesperson';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sales (Qty.)"; Rec."NPR Maximum Cash Returnsale")
                    {
                        Caption = 'Sales (Qty.)';
                        ToolTip = 'Specifies the value of the NPR Sales (Qty.) made within the date range';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sales (LCY)"; Rec."NPR Sales (LCY)")
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
                Action(Day)
                {
                    Caption = 'Day';

                    ToolTip = 'Select this filter to visualize data by day';
                    Image = Filter;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Day;
                        UpdateList(true);
                    end;
                }
                Action(Week)
                {
                    Caption = 'Week';

                    ToolTip = 'Select this filter to visualize data by week';
                    Image = Filter;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Week;
                        UpdateList(true);
                    end;
                }
                Action(Month)
                {
                    Caption = 'Month';

                    ToolTip = 'Select this filter to visualize data by month';
                    Image = Filter;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Month;
                        UpdateList(true);
                    end;
                }
                Action(Quarter)
                {
                    Caption = 'Quarter';

                    ToolTip = 'Select this filter to visualize data by quarter';
                    Image = Filter;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Quarter;
                        UpdateList(true);
                    end;
                }
                Action(Year)
                {
                    Caption = 'Year';

                    ToolTip = 'Select this filter to visualize data by year';
                    Image = Filter;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Year;
                        UpdateList(true);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        PeriodType := PeriodType::Year;
        CurrDate := Today();
        UpdateList(true);
    end;

    var
        SalesPerson: Record "Salesperson/Purchaser";
        CurrDate: Date;
        Enddate: Date;
        StartDate: Date;
        BackgroundTaskId: Integer;
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period;

    local procedure UpdateList(UpdateDate: Boolean)
    var
        Parameters: Dictionary of [Text, Text];
    begin
        if UpdateDate then
            Setdate();
        Parameters.Add('StartDate', Format(StartDate));
        Parameters.Add('EndDate', Format(EndDate));

        CurrPage.EnqueueBackgroundTask(BackgroundTaskId, Codeunit::"NPR Top 10 Salespersons BT", Parameters);
    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    var
        DecimalAmount: Decimal;
        i: Integer;
        RecordCount: Integer;
    begin
        if TaskId <> BackgroundTaskId then
            exit;
        Rec.Reset();
        Rec.DeleteAll();
        if Results.Count() = 0 then
            exit;
        Evaluate(RecordCount, Results.Get('Count'));
        for i := 1 to RecordCount do begin
            Rec.Init();
            Rec.Code := CopyStr(Results.Get('Code ' + Format(i)), 1, MaxStrLen(Rec.Code));
            Rec.Name := CopyStr(Results.Get('Name ' + Format(i)), 1, MaxStrLen(Rec.Name));
            Evaluate(DecimalAmount, Results.Get('MaximumCashReturnsale ' + Format(i)));
            Rec."NPR Maximum Cash Returnsale" := DecimalAmount;
            Evaluate(DecimalAmount, Results.Get('SalesLCY ' + Format(i)));
            Rec."NPR Sales (LCY)" := DecimalAmount;
            Rec.Insert();
        end;
        Rec.SetCurrentKey("NPR Sales (LCY)");
        Rec.Ascending(false);
    end;

    trigger OnPageBackgroundTaskError(TaskId: Integer; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text; var IsHandled: Boolean)
    var
        BackgrndTaskMgt: Codeunit "NPR Page Background Task Mgt.";
    begin
        if TaskId = BackgroundTaskId then
            BackgrndTaskMgt.FailedTaskError(CurrPage.Caption(), ErrorCode, ErrorText);
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

