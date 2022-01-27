page 6151576 "NPR Event Resource Overview"
{
    Extensible = False;
    Caption = 'Event Resource Overview';
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;

    SourceTable = Resource;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(Control6014417)
            {
                ShowCaption = false;
                field(StartingDate; StartingDate)
                {

                    Caption = 'Starting Date';
                    ToolTip = 'Specifies the value of the Starting Date field';
                    ApplicationArea = NPRRetail;
                }
                field(EndingDate; EndingDate)
                {

                    Caption = 'Ending Date';
                    ToolTip = 'Specifies the value of the Ending Date field';
                    ApplicationArea = NPRRetail;
                }
            }
            repeater(Group)
            {
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("E-Mail"; Rec."NPR E-Mail")
                {

                    ToolTip = 'Specifies the value of the NPR E-Mail field';
                    ApplicationArea = NPRRetail;
                }
                field(Capacity; Rec.Capacity)
                {

                    ToolTip = 'Specifies the value of the Capacity field';
                    ApplicationArea = NPRRetail;
                }
                field(QtyOnEvent; QtyOnEvent)
                {

                    Caption = 'Qty. on Event';
                    ToolTip = 'Specifies the value of the Qty. on Event field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        EventPlanningLineList: Page "NPR Event Planning Line List";
                        JobPlanningLine: Record "Job Planning Line";
                    begin
                        SetPlanningLineFilter(JobPlanningLine);
                        EventPlanningLineList.SetTableView(JobPlanningLine);
                        EventPlanningLineList.Run();
                    end;
                }
                field(Available; Available)
                {

                    Caption = 'Available';
                    ToolTip = 'Specifies the value of the Available field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the View action';
                ApplicationArea = NPRRetail;
            }
            group("Period Length")
            {
                Caption = 'Period Length';
                Image = CostAccounting;
                action(Day)
                {
                    Caption = 'Day';

                    ToolTip = 'Filters by day';
                    Image = Filter;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        PeriodType := 0;
                        PrepareDates(PeriodType, 0D, StartingDate, EndingDate);
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
                        PeriodType := 1;
                        PrepareDates(PeriodType, 0D, StartingDate, EndingDate);
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
                        PeriodType := 2;
                        PrepareDates(PeriodType, 0D, StartingDate, EndingDate);
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
                        PeriodType := 3;
                        PrepareDates(PeriodType, 0D, StartingDate, EndingDate);
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
                        PeriodType := 4;
                        PrepareDates(PeriodType, 0D, StartingDate, EndingDate);
                    end;
                }
            }
            action(Previous)
            {
                Caption = 'Previous';
                Image = PreviousRecord;

                ToolTip = 'Executes the Previous action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    PrepareDates(PeriodType, CalcDate('<-1D>', StartingDate), StartingDate, EndingDate);
                end;
            }
            action("Next")
            {
                Caption = 'Next';
                Image = NextRecord;

                ToolTip = 'Executes the Next action';
                ApplicationArea = NPRRetail;

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
        Rec.SetFilter("Date Filter", '%1..%2', StartingDate, EndingDate);
        Rec.CalcFields(Capacity);
        Available := Rec.Capacity - QtyOnEvent;
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
        if JobPlanningLine.FindSet() then
            repeat
                Job.Get(JobPlanningLine."Job No.");
                if Job."NPR Event" then
                    TotalQty += JobPlanningLine."Quantity (Base)";
            until JobPlanningLine.Next() = 0;
        exit(TotalQty);
    end;

    local procedure PrepareDates(DateType: Option Day,Week,Month,Quarter,Year; ReferalDate: Date; var FromDate: Date; var ToDate: Date)
    var
        BusinessChartBuffer: Record "Business Chart Buffer";
    begin
        BusinessChartBuffer."Period Length" := DateType;
        if ReferalDate = 0D then begin
            ReferalDate := WorkDate();
            Clear(FromDate);
            Clear(ToDate);
        end;
        FromDate := BusinessChartBuffer.CalcFromDate(ReferalDate);
        ToDate := BusinessChartBuffer.CalcToDate(ReferalDate);
        CurrPage.Update(false);
    end;
}

