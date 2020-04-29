page 6151576 "Event Resource Overview"
{
    // NPR5.31/NPKNAV/20170502  CASE 269162 Transport NPR5.31 - 2 May 2017
    // NPR5.32/TJ  /20170523 CASE 277397 Added View action

    Caption = 'Event Resource Overview';
    Editable = false;
    PageType = ListPart;
    SourceTable = Resource;

    layout
    {
        area(content)
        {
            group(Control6014417)
            {
                ShowCaption = false;
                field(StartingDate;StartingDate)
                {
                    Caption = 'Starting Date';
                }
                field(EndingDate;EndingDate)
                {
                    Caption = 'Ending Date';
                }
            }
            repeater(Group)
            {
                field("No.";"No.")
                {
                }
                field(Name;Name)
                {
                }
                field("E-Mail";"E-Mail")
                {
                }
                field(Capacity;Capacity)
                {
                }
                field(QtyOnEvent;QtyOnEvent)
                {
                    Caption = 'Qty. on Event';

                    trigger OnDrillDown()
                    var
                        EventPlanningLineList: Page "Event Planning Line List";
                        JobPlanningLine: Record "Job Planning Line";
                    begin
                        SetPlanningLineFilter(JobPlanningLine);
                        EventPlanningLineList.SetTableView(JobPlanningLine);
                        EventPlanningLineList.Run;
                    end;
                }
                field(Available;Available)
                {
                    Caption = 'Available';
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
                RunPageLink = "No."=FIELD("No.");
                RunPageMode = View;
            }
            group("Period Length")
            {
                Caption = 'Period Length';
                Image = CostAccounting;
                action(Day)
                {
                    Caption = 'Day';

                    trigger OnAction()
                    begin
                        PeriodType := 0;
                        PrepareDates(PeriodType,0D,StartingDate,EndingDate);
                    end;
                }
                action(Week)
                {
                    Caption = 'Week';

                    trigger OnAction()
                    begin
                        PeriodType := 1;
                        PrepareDates(PeriodType,0D,StartingDate,EndingDate);
                    end;
                }
                action(Month)
                {
                    Caption = 'Month';

                    trigger OnAction()
                    begin
                        PeriodType := 2;
                        PrepareDates(PeriodType,0D,StartingDate,EndingDate);
                    end;
                }
                action(Quarter)
                {
                    Caption = 'Quarter';

                    trigger OnAction()
                    begin
                        PeriodType := 3;
                        PrepareDates(PeriodType,0D,StartingDate,EndingDate);
                    end;
                }
                action(Year)
                {
                    Caption = 'Year';

                    trigger OnAction()
                    begin
                        PeriodType := 4;
                        PrepareDates(PeriodType,0D,StartingDate,EndingDate);
                    end;
                }
            }
            action(Previous)
            {
                Caption = 'Previous';
                Image = PreviousRecord;

                trigger OnAction()
                begin
                    PrepareDates(PeriodType,CalcDate('<-1D>',StartingDate),StartingDate,EndingDate);
                end;
            }
            action(Next)
            {
                Caption = 'Next';
                Image = NextRecord;

                trigger OnAction()
                begin
                    PrepareDates(PeriodType,CalcDate('<1D>',EndingDate),StartingDate,EndingDate);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        QtyOnEvent := CalcQtyOnEvent();
        SetFilter("Date Filter",'%1..%2',StartingDate,EndingDate);
        CalcFields(Capacity);
        Available := Capacity - QtyOnEvent;
    end;

    trigger OnOpenPage()
    begin
        PeriodType := 2;
        PrepareDates(PeriodType,0D,StartingDate,EndingDate);
    end;

    var
        QtyOnEvent: Decimal;
        Available: Decimal;
        StartingDate: Date;
        EndingDate: Date;
        PeriodType: Option;

    local procedure SetPlanningLineFilter(var JobPlanningLine: Record "Job Planning Line")
    begin
        JobPlanningLine.SetFilter("Event Status",'<%1',JobPlanningLine."Event Status"::Completed);
        JobPlanningLine.SetRange(Type,JobPlanningLine.Type::Resource);
        JobPlanningLine.SetRange("No.",Rec."No.");
        JobPlanningLine.SetRange("Planning Date",StartingDate,EndingDate);
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
            if Job."Event" then
              TotalQty += JobPlanningLine."Quantity (Base)";
          until JobPlanningLine.Next = 0;
        exit(TotalQty);
    end;

    local procedure PrepareDates(DateType: Option Day,Week,Month,Quarter,Year;ReferalDate: Date;var FromDate: Date;var ToDate: Date)
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

