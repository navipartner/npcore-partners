page 6059815 "NPR Retail 10 Items by Qty."
{
    Extensible = false;
    Caption = 'Top 10 Items by Quantity';
    CardPageID = "Item Card";
    Editable = true;
    PageType = ListPart;
    RefreshOnActivate = true;
    SourceTable = Item;
    SourceTableTemporary = true;
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
                    ToolTip = 'Specifies the start date used to filter the sales data.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        ExecuteQueryBackground();
                    end;
                }
                field(Enddate; EndDate)
                {
                    Caption = 'End date';
                    ToolTip = 'Specifies the end date to filter the sales data.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        ExecuteQueryBackground();
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
                        ToolTip = 'Specifies the number of the item.';
                        ApplicationArea = NPRRetail;

                        trigger OnDrillDown()
                        var
                            Item: Record Item;
                        begin
                            Item.Get(Rec."No.");
                            Page.Run(Page::"Item Card", Item);
                        end;
                    }
                    field(Description; Rec.Description)
                    {
                        ToolTip = 'Specifies the description of the item.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sales (Qty.)"; Rec."Sales (Qty.)")
                    {
                        BlankZero = true;
                        Caption = 'Sales (Qty.)';
                        ToolTip = 'Specifies the quantity of items sold.';
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

                    ToolTip = 'Select this filter to visualize data by day.';

                    Image = Filter;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Day;
                        UpdateList();
                    end;
                }
                Action(Week)
                {
                    Caption = 'Week';

                    ToolTip = 'Select this filter to visualize data by week.';


                    Image = Filter;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Week;
                        UpdateList();
                    end;
                }
                Action(Month)
                {
                    Caption = 'Month';

                    ToolTip = 'Select this filter to visualize data by month.';

                    Image = Filter;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Month;
                        UpdateList();
                    end;
                }
                Action(Quarter)
                {
                    Caption = 'Quarter';

                    ToolTip = 'Select this filter to visualize data by quarter.';

                    Image = Filter;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        PeriodType := PeriodType::Quarter;
                        UpdateList();
                    end;
                }
                Action(Year)
                {
                    Caption = 'Year';

                    ToolTip = 'Select this filter to visualize data by year.';

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
        CurrDate: Date;
        EndDate: Date;
        StartDate: Date;
        BackgroundTaskId: Integer;
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period;

    local procedure UpdateList()
    begin
        Setdate();
        ExecuteQueryBackground();
    end;

    local procedure Setdate()
    begin
        case PeriodType of
            PeriodType::Day:
                begin
                    StartDate := CurrDate;
                    EndDate := CurrDate;
                end;
            PeriodType::Week:
                begin
                    StartDate := CalcDate('<-CW>', CurrDate);
                    EndDate := CalcDate('<CW>', CurrDate);
                end;
            PeriodType::Month:
                begin
                    StartDate := CalcDate('<-CM>', CurrDate);
                    EndDate := CalcDate('<CM>', CurrDate);
                end;
            PeriodType::Quarter:
                begin
                    StartDate := CalcDate('<-CQ>', CurrDate);
                    EndDate := CalcDate('<CQ>', CurrDate);
                end;
            PeriodType::Year:
                begin
                    StartDate := CalcDate('<-CY>', CurrDate);
                    EndDate := CalcDate('<CY>', CurrDate);
                end;
        end;
    end;

    local procedure ExecuteQueryBackground()
    var
        Parameters: Dictionary of [Text, Text];
    begin
        Parameters.Add('StartDate', Format(StartDate));
        Parameters.Add('EndDate', Format(EndDate));

        CurrPage.EnqueueBackgroundTask(BackgroundTaskId, Codeunit::"NPR Retail Top 10 Items BT", Parameters);
    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    var
        i: Integer;
        LowLevelCode: Integer;
        RecordCount: Integer;
    begin
        Rec.Reset();
        Rec.DeleteAll();
        if TaskId <> BackgroundTaskId then
            exit;
        if Results.Count() = 0 then
            exit;
        Evaluate(RecordCount, Results.Get('Count'));
        for i := 1 to RecordCount do begin
            Rec.Init();
            Rec."No." := CopyStr(Results.Get('No ' + Format(i)), 1, MaxStrLen(Rec."No."));
            Rec.Description := CopyStr(Results.Get('Description ' + Format(i)), 1, MaxStrLen(Rec.Description));
            Evaluate(LowLevelCode, Results.Get('LowLevelCode ' + Format(i)));
            Rec."Low-Level Code" := LowLevelCode;
            Rec.Insert();
            Rec.SetFilter("Date Filter", '%1..%2', StartDate, EndDate);
        end;
        Rec.SetCurrentKey("Low-Level Code");
        Rec.Ascending(false);
    end;

    trigger OnPageBackgroundTaskError(TaskId: Integer; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text; var IsHandled: Boolean)
    var
        BackgrndTaskMgt: Codeunit "NPR Page Background Task Mgt.";
    begin
        if TaskId = BackgroundTaskId then
            BackgrndTaskMgt.FailedTaskError(CurrPage.Caption(), ErrorCode, ErrorText);
    end;
}

