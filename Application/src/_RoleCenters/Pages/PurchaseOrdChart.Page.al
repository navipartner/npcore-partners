﻿page 6151261 "NPR Purchase Ord Chart"
{
    Extensible = False;
    Caption = 'Trailing Purchase Orders';
    PageType = CardPart;
    SourceTable = "Business Chart Buffer";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            field(StatusText; StatusText)
            {

                Caption = 'Status Text';
                Editable = false;
                ShowCaption = false;
                ToolTip = 'Specifies the status of the chart.';
                ApplicationArea = NPRRetail;
            }
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
            usercontrol(BusinessChart; BusinessChart)
#ELSE
            usercontrol(BusinessChart; "Microsoft.Dynamics.Nav.Client.BusinessChart")
#ENDIF
            {
                ApplicationArea = NPRRetail;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Show)
            {
                Caption = 'Show';
                Image = View;
                action(AllOrders)
                {

                    Caption = 'All Orders';
                    Enabled = AllOrdersEnabled;
                    ToolTip = 'View all not fully posted sales orders, including sales orders with document dates in the future because of long delivery times, delays, or other reasons.';
                    Image = Filter;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        TrailingSalesOrdersSetup.SetShowOrders(TrailingSalesOrdersSetup."Show Orders"::"All Orders");
                        UpdateStatus();
                    end;
                }
                action(OrdersUntilToday)
                {

                    Caption = 'Orders Until Today';
                    Enabled = OrdersUntilTodayEnabled;
                    ToolTip = 'View not fully posted sales orders with document dates up until today''s date.';
                    Image = Filter;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        TrailingSalesOrdersSetup.SetShowOrders(TrailingSalesOrdersSetup."Show Orders"::"Orders Until Today");
                        UpdateStatus();
                    end;
                }
                action(DelayedOrders)
                {

                    Caption = 'Delayed Orders';
                    Enabled = DelayedOrdersEnabled;
                    ToolTip = 'View not fully posted sales orders with shipment dates that are before today''s date.';
                    Image = Filter;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        TrailingSalesOrdersSetup.SetShowOrders(TrailingSalesOrdersSetup."Show Orders"::"Delayed Orders");
                        UpdateStatus();
                    end;
                }
            }
            group(PeriodLength)
            {
                Caption = 'Period Length';
                Image = Period;
                action(Day)
                {

                    Caption = 'Day';
                    Enabled = DayEnabled;
                    ToolTip = 'Each stack covers one day.';
                    Image = Filter;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        TrailingSalesOrdersSetup.SetPeriodLength(TrailingSalesOrdersSetup."Period Length"::Day);
                        UpdateStatus();
                    end;
                }
                action(Week)
                {

                    Caption = 'Week';
                    Enabled = WeekEnabled;
                    ToolTip = 'Each stack except for the last stack covers one week. The last stack contains data from the start of the week until the date that is defined by the Show option.';
                    Image = Filter;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        TrailingSalesOrdersSetup.SetPeriodLength(TrailingSalesOrdersSetup."Period Length"::Week);
                        UpdateStatus();
                    end;
                }
                action(Month)
                {

                    Caption = 'Month';
                    Enabled = MonthEnabled;
                    ToolTip = 'Each stack except for the last stack covers one month. The last stack contains data from the start of the month until the date that is defined by the Show option.';
                    Image = Filter;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        TrailingSalesOrdersSetup.SetPeriodLength(TrailingSalesOrdersSetup."Period Length"::Month);
                        UpdateStatus();
                    end;
                }
                action(Quarter)
                {

                    Caption = 'Quarter';
                    Enabled = QuarterEnabled;
                    ToolTip = 'Each stack except for the last stack covers one quarter. The last stack contains data from the start of the quarter until the date that is defined by the Show option.';
                    Image = Filter;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        TrailingSalesOrdersSetup.SetPeriodLength(TrailingSalesOrdersSetup."Period Length"::Quarter);
                        UpdateStatus();
                    end;
                }
                action(Year)
                {

                    Caption = 'Year';
                    Enabled = YearEnabled;
                    ToolTip = 'Each stack except for the last stack covers one year. The last stack contains data from the start of the year until the date that is defined by the Show option.';
                    Image = Filter;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        TrailingSalesOrdersSetup.SetPeriodLength(TrailingSalesOrdersSetup."Period Length"::Year);
                        UpdateStatus();
                    end;
                }
            }
            group(Options)
            {
                Caption = 'Options';
                Image = SelectChart;
                group(ValueToCalculate)
                {
                    Caption = 'Value to Calculate';
                    Image = Calculate;
                    action(Amount)
                    {

                        Caption = 'Amount';
                        Enabled = AmountEnabled;
                        ToolTip = 'The Y-axis shows the totaled LCY amount of the orders.';
                        Image = Filter;
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        begin
                            TrailingSalesOrdersSetup.SetValueToCalcuate(TrailingSalesOrdersSetup."Value to Calculate"::"Amount Excl. VAT");
                            UpdateStatus();
                        end;
                    }
                    action(NoofOrders)
                    {

                        Caption = 'No. of Orders';
                        Enabled = NoOfOrdersEnabled;
                        ToolTip = 'The Y-axis shows the number of orders.';
                        Image = Filter;
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        begin
                            TrailingSalesOrdersSetup.SetValueToCalcuate(TrailingSalesOrdersSetup."Value to Calculate"::"No. of Orders");
                            UpdateStatus();
                        end;
                    }
                }
                group("Chart Type")
                {
                    Caption = 'Chart Type';
                    Image = BarChart;
                    action(StackedArea)
                    {

                        Caption = 'Stacked Area';
                        Enabled = StackedAreaEnabled;
                        ToolTip = 'View the data in area layout.';
                        Image = SelectChart;
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        begin
                            TrailingSalesOrdersSetup.SetChartType(TrailingSalesOrdersSetup."Chart Type"::"Stacked Area");
                            UpdateStatus();
                        end;
                    }
                    action(StackedAreaPct)
                    {

                        Caption = 'Stacked Area (%)';
                        Enabled = StackedAreaPctEnabled;
                        ToolTip = 'view the percentage distribution of the four order statuses in area layout.';
                        Image = SelectChart;
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        begin
                            TrailingSalesOrdersSetup.SetChartType(TrailingSalesOrdersSetup."Chart Type"::"Stacked Area (%)");
                            UpdateStatus();
                        end;
                    }
                    action(StackedColumn)
                    {

                        Caption = 'Stacked Column';
                        Enabled = StackedColumnEnabled;
                        ToolTip = 'view the data in column layout.';
                        Image = SelectChart;
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        begin
                            TrailingSalesOrdersSetup.SetChartType(TrailingSalesOrdersSetup."Chart Type"::"Stacked Column");
                            UpdateStatus();
                        end;
                    }
                    action(StackedColumnPct)
                    {

                        Caption = 'Stacked Column (%)';
                        Enabled = StackedColumnPctEnabled;
                        ToolTip = 'view the percentage distribution of the four order statuses in column layout.';
                        Image = SelectChart;
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        begin
                            TrailingSalesOrdersSetup.SetChartType(TrailingSalesOrdersSetup."Chart Type"::"Stacked Column (%)");
                            UpdateStatus();
                        end;
                    }
                }
            }
            separator(Separator25)
            {
            }
            action(Setup)
            {

                Caption = 'Setup';
                Image = Setup;
                ToolTip = 'Specify if the chart will be based on a work date other than today''s date. This is mainly relevant in demonstration databases with fictitious sales orders.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    RunSetup();
                end;
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        UpdateChart();

        if not IsChartAddInReady then
            SetActionsEnabled();
    end;

    trigger OnOpenPage()
    begin
        SetActionsEnabled();
    end;

    var
        TrailingSalesOrdersSetup: Record "NPR Trail. Purch. Orders Setup";
        OldTrailingSalesOrdersSetup: Record "NPR Trail. Purch. Orders Setup";
        TrailingSalesOrdersMgt: Codeunit "Trailing Sales Orders Mgt.";
        StatusText: Text[250];
        NeedsUpdate: Boolean;
        AllOrdersEnabled: Boolean;
        OrdersUntilTodayEnabled: Boolean;
        DelayedOrdersEnabled: Boolean;
        DayEnabled: Boolean;
        WeekEnabled: Boolean;
        MonthEnabled: Boolean;
        QuarterEnabled: Boolean;
        YearEnabled: Boolean;
        AmountEnabled: Boolean;
        NoOfOrdersEnabled: Boolean;
        StackedAreaEnabled: Boolean;
        StackedAreaPctEnabled: Boolean;
        StackedColumnEnabled: Boolean;
        StackedColumnPctEnabled: Boolean;
        IsChartAddInReady: Boolean;

    local procedure UpdateChart()
    begin
        if not NeedsUpdate then
            exit;
        if not IsChartAddInReady then
            exit;
        TrailingSalesOrdersMgt.UpdateData(Rec);
        UpdateStatus();
        NeedsUpdate := false;
    end;

    local procedure UpdateStatus()
    begin
        NeedsUpdate :=
          NeedsUpdate or
          (OldTrailingSalesOrdersSetup."Period Length" <> TrailingSalesOrdersSetup."Period Length") or
          (OldTrailingSalesOrdersSetup."Show Orders" <> TrailingSalesOrdersSetup."Show Orders") or
          (OldTrailingSalesOrdersSetup."Use Work Date as Base" <> TrailingSalesOrdersSetup."Use Work Date as Base") or
          (OldTrailingSalesOrdersSetup."Value to Calculate" <> TrailingSalesOrdersSetup."Value to Calculate") or
          (OldTrailingSalesOrdersSetup."Chart Type" <> TrailingSalesOrdersSetup."Chart Type");

        OldTrailingSalesOrdersSetup := TrailingSalesOrdersSetup;

        if NeedsUpdate then
            StatusText := TrailingSalesOrdersSetup.GetCurrentSelectionText();

        SetActionsEnabled();
    end;

    local procedure RunSetup()
    begin
        PAGE.RunModal(PAGE::"Trailing Sales Orders Setup", TrailingSalesOrdersSetup);
        TrailingSalesOrdersSetup.Get(UserId);
        UpdateStatus();
    end;

    internal procedure SetActionsEnabled()
    begin
        AllOrdersEnabled := (TrailingSalesOrdersSetup."Show Orders" <> TrailingSalesOrdersSetup."Show Orders"::"All Orders") and
          IsChartAddInReady;
        OrdersUntilTodayEnabled :=
          (TrailingSalesOrdersSetup."Show Orders" <> TrailingSalesOrdersSetup."Show Orders"::"Orders Until Today") and
          IsChartAddInReady;
        DelayedOrdersEnabled := (TrailingSalesOrdersSetup."Show Orders" <> TrailingSalesOrdersSetup."Show Orders"::"Delayed Orders") and
          IsChartAddInReady;
        DayEnabled := (TrailingSalesOrdersSetup."Period Length" <> TrailingSalesOrdersSetup."Period Length"::Day) and
          IsChartAddInReady;
        WeekEnabled := (TrailingSalesOrdersSetup."Period Length" <> TrailingSalesOrdersSetup."Period Length"::Week) and
          IsChartAddInReady;
        MonthEnabled := (TrailingSalesOrdersSetup."Period Length" <> TrailingSalesOrdersSetup."Period Length"::Month) and
          IsChartAddInReady;
        QuarterEnabled := (TrailingSalesOrdersSetup."Period Length" <> TrailingSalesOrdersSetup."Period Length"::Quarter) and
          IsChartAddInReady;
        YearEnabled := (TrailingSalesOrdersSetup."Period Length" <> TrailingSalesOrdersSetup."Period Length"::Year) and
          IsChartAddInReady;
        AmountEnabled :=
          (TrailingSalesOrdersSetup."Value to Calculate" <> TrailingSalesOrdersSetup."Value to Calculate"::"Amount Excl. VAT") and
          IsChartAddInReady;
        NoOfOrdersEnabled :=
          (TrailingSalesOrdersSetup."Value to Calculate" <> TrailingSalesOrdersSetup."Value to Calculate"::"No. of Orders") and
          IsChartAddInReady;
        StackedAreaEnabled := (TrailingSalesOrdersSetup."Chart Type" <> TrailingSalesOrdersSetup."Chart Type"::"Stacked Area") and
          IsChartAddInReady;
        StackedAreaPctEnabled := (TrailingSalesOrdersSetup."Chart Type" <> TrailingSalesOrdersSetup."Chart Type"::"Stacked Area (%)") and
          IsChartAddInReady;
        StackedColumnEnabled := (TrailingSalesOrdersSetup."Chart Type" <> TrailingSalesOrdersSetup."Chart Type"::"Stacked Column") and
          IsChartAddInReady;
        StackedColumnPctEnabled :=
          (TrailingSalesOrdersSetup."Chart Type" <> TrailingSalesOrdersSetup."Chart Type"::"Stacked Column (%)") and
          IsChartAddInReady;
    end;
}

