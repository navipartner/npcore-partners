page 6151576 "NPR Event Resource Overview"
{

    Caption = 'Event Resource Overview';
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = Resource;

    layout
    {
        area(content)
        {
            group(Control6014417)
            {
                ShowCaption = false;
                field(StartingDate; StartingDate)
                {
                    ApplicationArea = All;
                    Caption = 'Starting Date';
                    ToolTip = 'Specifies the value of the Starting Date field';
                }
                field(EndingDate; EndingDate)
                {
                    ApplicationArea = All;
                    Caption = 'Ending Date';
                    ToolTip = 'Specifies the value of the Ending Date field';
                }
            }
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("E-Mail"; "NPR E-Mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR E-Mail field';
                }
                field(Capacity; Capacity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Capacity field';
                }
                field(QtyOnEvent; QtyOnEvent)
                {
                    ApplicationArea = All;
                    Caption = 'Qty. on Event';
                    ToolTip = 'Specifies the value of the Qty. on Event field';

                    trigger OnDrillDown()
                    var
                        EventPlanningLineList: Page "NPR Event Planning Line List";
                        JobPlanningLine: Record "Job Planning Line";
                    begin
                        SetPlanningLineFilter(JobPlanningLine);
                        EventPlanningLineList.SetTableView(JobPlanningLine);
                        EventPlanningLineList.Run;
                    end;
                }
                field(Available; Available)
                {
                    ApplicationArea = All;
                    Caption = 'Available';
                    ToolTip = 'Specifies the value of the Available field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(View)
            {
                Caption = 'View';
                Image = View;
                RunObject = Page "Resource Card";
                RunPageLink = "No." = FIELD("No.");
                RunPageMode = View;
                ApplicationArea = All;
                ToolTip = 'Executes the View action';
            }
            group("Period Length")
            {
                Caption = 'Period Length';
                Image = CostAccounting;
                action(Day)
                {
                    Caption = 'Day';
                    ApplicationArea = All;
                    ToolTip = 'Filters by day';
                    Image = Filter; 

                    trigger OnAction()
                    begin
                        PeriodType := 0;
                        PrepareDates(PeriodType, 0D, StartingDate, EndingDate);
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
                        PeriodType := 1;
                        PrepareDates(PeriodType, 0D, StartingDate, EndingDate);
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
                        PeriodType := 2;
                        PrepareDates(PeriodType, 0D, StartingDate, EndingDate);
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
                        PeriodType := 3;
                        PrepareDates(PeriodType, 0D, StartingDate, EndingDate);
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
                        PeriodType := 4;
                        PrepareDates(PeriodType, 0D, StartingDate, EndingDate);
                    end;
                }
            }
            action(Previous)
            {
                Caption = 'Previous';
                Image = PreviousRecord;
                ApplicationArea = All;
                ToolTip = 'Executes the Previous action';

                trigger OnAction()
                begin
                    PrepareDates(PeriodType, CalcDate('<-1D>', StartingDate), StartingDate, EndingDate);
                end;
            }
            action("Next")
            {
                Caption = 'Next';
                Image = NextRecord;
                ApplicationArea = All;
                ToolTip = 'Executes the Next action';

                trigger OnAction()
                begin
                    PrepareDates(PeriodType, CalcDate('<1D>', EndingDate), StartingDate, EndingDate);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        QtyOnEvent := CalcQtyOnEvent();
        SetFilter("Date Filter", '%1..%2', StartingDate, EndingDate);
        CalcFields(Capacity);
        Available := Capacity - QtyOnEvent;
    end;

    trigger OnOpenPage()
    begin
        PeriodType := 2;
        PrepareDates(PeriodType, 0D, StartingDate, EndingDate);
    end;

    var
        QtyOnEvent: Decimal;
        Available: Decimal;
        StartingDate: Date;
        EndingDate: Date;
        PeriodType: Option;

    local procedure SetPlanningLineFilter(var JobPlanningLine: Record "Job Planning Line")
    begin
        JobPlanningLine.SetFilter("NPR Event Status", '<%1', JobPlanningLine."NPR Event Status"::Completed);
        JobPlanningLine.SetRange(Type, JobPlanningLine.Type::Resource);
        JobPlanningLine.SetRange("No.", Rec."No.");
        JobPlanningLine.SetRange("Planning Date", StartingDate, EndingDate);
    end;

    local procedure CalcQtyOnEvent() TotalQty: Decimal
    var
        Job: Record Job;
        JobPlanningLine: Record "Job Planning Line";
    begin
        SetPlanningLineFilter(JobPlanningLine);
        if JobPlanningLine.FindSet then
            repeat
                Job.Get(JobPlanningLine."Job No.");
                if Job."NPR Event" then
                    TotalQty += JobPlanningLine."Quantity (Base)";
            until JobPlanningLine.Next = 0;
        exit(TotalQty);
    end;

    local procedure PrepareDates(DateType: Option Day,Week,Month,Quarter,Year; ReferalDate: Date; var FromDate: Date; var ToDate: Date)
    var
        BusinessChartBuffer: Record "Business Chart Buffer";
    begin
        BusinessChartBuffer."Period Length" := DateType;
        if ReferalDate = 0D then begin
            ReferalDate := WorkDate;
            Clear(FromDate);
            Clear(ToDate);
        end;
        FromDate := BusinessChartBuffer.CalcFromDate(ReferalDate);
        ToDate := BusinessChartBuffer.CalcToDate(ReferalDate);
        CurrPage.Update(false);
    end;
}

