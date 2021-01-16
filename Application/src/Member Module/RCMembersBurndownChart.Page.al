page 6060148 "NPR RC Members. Burndown Chart"
{

    Caption = 'Membership Burndown Chart';
    PageType = CardPart;
    UsageCategory = Administration;
    SourceTable = "Business Chart Buffer";

    layout
    {
        area(content)
        {
            field(StatusText; StatusText)
            {
                ApplicationArea = All;
                Caption = 'Status Text';
                ShowCaption = false;
                ToolTip = 'Specifies the value of the Status Text field';
            }
            usercontrol(BusinessChart; "Microsoft.Dynamics.Nav.Client.BusinessChart")
            {
                ApplicationArea = All;
                trigger AddInReady()
                begin
                    IsChartAddInReady := true;
                    MembershipBurndownMgt.OnPageOpen(MembershipBurndownSetup);
                    UpdateStatus;
                    if IsChartDataReady then
                        UpdateChart;
                end;
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
                action(TypeOfSales)
                {
                    Caption = 'Membership Sales Type';
                    Enabled = TypeOfSales;
                    ApplicationArea = All;
                    ToolTip = 'Filters by membership sales type';
                    Image = Filter; 

                    trigger OnAction()
                    begin
                        MembershipBurndownSetup.SetShowMemberships(MembershipBurndownSetup."Show Memberships"::SALES_TYPE);
                        UpdateStatus;
                    end;
                }
                action(OrdersUntilToday)
                {
                    Caption = 'Orders Until Today';
                    Enabled = OrdersUntilTodayEnabled;
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Orders Until Today action';
                    Image = Filter; 

                    trigger OnAction()
                    begin
                        MembershipBurndownSetup.SetShowMemberships(MembershipBurndownSetup."Show Memberships"::BY_COMMUNITY);
                        UpdateStatus;
                    end;
                }
                action(DelayedOrders)
                {
                    Caption = 'Delayed Orders';
                    Enabled = DelayedOrdersEnabled;
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Delayed Orders action';
                    Image = Filter; 

                    trigger OnAction()
                    begin
                        MembershipBurndownSetup.SetShowMemberships(MembershipBurndownSetup."Show Memberships"::BY_MEMBERSHIP);
                        UpdateStatus;
                    end;
                }
            }
            group(PeriodLength)
            {
                Caption = 'Period Length';
                Image = Period;
                action(Month)
                {
                    Caption = 'Month';
                    Enabled = MonthEnabled;
                    ApplicationArea = All;
                    ToolTip = 'Filters by month';
                    Image = Filter; 

                    trigger OnAction()
                    begin
                        MembershipBurndownSetup.SetPeriodLength(MembershipBurndownSetup."Period Length"::Month);
                        UpdateStatus;
                    end;
                }
                action(Quarter)
                {
                    Caption = 'Quarter';
                    Enabled = QuarterEnabled;
                    ApplicationArea = All;
                    ToolTip = 'Filters by quarter';
                    Image = Filter;

                    trigger OnAction()
                    begin
                        MembershipBurndownSetup.SetPeriodLength(MembershipBurndownSetup."Period Length"::Quarter);
                        UpdateStatus;
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
                        Enabled = MembershipValueEnabled;
                        ApplicationArea = All;
                        ToolTip = 'Filters by amount';
                        Image = Filter; 

                        trigger OnAction()
                        begin
                            MembershipBurndownSetup.SetValueToCalcuate(MembershipBurndownSetup."Value to Calculate"::MEMBERSHIP_VALUE);
                            UpdateStatus;
                        end;
                    }
                    action(NoofMemberships)
                    {
                        Caption = 'Membership Count';
                        Enabled = MembershipCountEnabled;
                        ApplicationArea = All;
                        ToolTip = 'Filters by membership count';
                        Image = Filter; 

                        trigger OnAction()
                        begin
                            MembershipBurndownSetup.SetValueToCalcuate(MembershipBurndownSetup."Value to Calculate"::MEMBERSHIP_COUNT);
                            UpdateStatus;
                        end;
                    }
                }
                group(PeriodTotal)
                {
                    Caption = 'Period Total';
                    Image = AmountByPeriod;
                    action(Accumulated)
                    {
                        Caption = 'Accumulate';
                        Enabled = AccumulatePeriodValue;
                        ApplicationArea = All;
                        ToolTip = 'Filters by accumulated value';
                        Image = Filter; 

                        trigger OnAction()
                        begin
                            MembershipBurndownSetup.SetPeriodType(MembershipBurndownSetup."Show Change As"::ACK);
                            UpdateStatus;
                        end;
                    }
                    action(NetChange)
                    {
                        Caption = 'Net Change';
                        Enabled = NetChangePeriodValue;
                        ApplicationArea = All;
                        ToolTip = 'Filters by net change';
                        Image = Filter; 

                        trigger OnAction()
                        begin
                            MembershipBurndownSetup.SetPeriodType(MembershipBurndownSetup."Show Change As"::NET);
                            UpdateStatus;
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
                        ApplicationArea = All;
                        ToolTip = 'Creates a stacked area chart';
                        Image = SelectChart;

                        trigger OnAction()
                        begin
                            MembershipBurndownSetup.SetChartType(MembershipBurndownSetup."Chart Type"::"Stacked Area");
                            UpdateStatus;
                        end;
                    }
                    action(StackedAreaPct)
                    {
                        Caption = 'Stacked Area (%)';
                        Enabled = StackedAreaPctEnabled;
                        ApplicationArea = All;
                        ToolTip = 'Creates a Stacked Area (%) chart';
                        Image = SelectChart;

                        trigger OnAction()
                        begin
                            MembershipBurndownSetup.SetChartType(MembershipBurndownSetup."Chart Type"::"Stacked Area (%)");
                            UpdateStatus;
                        end;
                    }
                    action(StackedColumn)
                    {
                        Caption = 'Stacked Column';
                        Enabled = StackedColumnEnabled;
                        ApplicationArea = All;
                        ToolTip = 'Creates a Stacked Column chart';
                        Image = SelectChart;

                        trigger OnAction()
                        begin
                            MembershipBurndownSetup.SetChartType(MembershipBurndownSetup."Chart Type"::"Stacked Column");
                            UpdateStatus;
                        end;
                    }
                    action(StackedColumnPct)
                    {
                        Caption = 'Stacked Column (%)';
                        Enabled = StackedColumnPctEnabled;
                        ApplicationArea = All;
                        ToolTip = 'Creates a Stacked Column (%) chart';
                        Image = SelectChart;

                        trigger OnAction()
                        begin
                            MembershipBurndownSetup.SetChartType(MembershipBurndownSetup."Chart Type"::"Stacked Column (%)");
                            UpdateStatus;
                        end;
                    }
                }
            }
            separator(Separator25)
            {
            }
            action(Refresh)
            {
                Caption = 'Refresh';
                Image = Refresh;
                ApplicationArea = All;
                ToolTip = 'Executes the Refresh action';

                trigger OnAction()
                begin
                    NeedsUpdate := true;
                    UpdateStatus;
                end;
            }
            separator(Separator27)
            {
            }
            action(Setup)
            {
                Caption = 'Setup';
                Image = Setup;
                ApplicationArea = All;
                ToolTip = 'Executes the Setup action';

                trigger OnAction()
                begin
                    RunSetup;
                end;
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        UpdateChart;
        IsChartDataReady := true;

        if not IsChartAddInReady then
            SetActionsEnabled;
    end;

    trigger OnOpenPage()
    begin
        SetActionsEnabled;
    end;

    var
        MembershipBurndownSetup: Record "NPR RC Members. Burndown Setup";
        OldMembershipBurndownSetup: Record "NPR RC Members. Burndown Setup";
        MembershipBurndownMgt: Codeunit "NPR RC MM Members.Burndown Mgt";
        StatusText: Text[250];
        NeedsUpdate: Boolean;
        [InDataSet]
        TypeOfSales: Boolean;
        [InDataSet]
        OrdersUntilTodayEnabled: Boolean;
        [InDataSet]
        DelayedOrdersEnabled: Boolean;
        [InDataSet]
        MonthEnabled: Boolean;
        [InDataSet]
        QuarterEnabled: Boolean;
        [InDataSet]
        MembershipValueEnabled: Boolean;
        [InDataSet]
        MembershipCountEnabled: Boolean;
        [InDataSet]
        StackedAreaEnabled: Boolean;
        [InDataSet]
        StackedAreaPctEnabled: Boolean;
        [InDataSet]
        StackedColumnEnabled: Boolean;
        [InDataSet]
        StackedColumnPctEnabled: Boolean;
        IsChartAddInReady: Boolean;
        IsChartDataReady: Boolean;
        AccumulatePeriodValue: Boolean;
        NetChangePeriodValue: Boolean;

    local procedure UpdateChart()
    begin
        if not NeedsUpdate then
            exit;
        if not IsChartAddInReady then
            exit;
        MembershipBurndownMgt.UpdateData(Rec);
        Update(CurrPage.BusinessChart);
        UpdateStatus;
        NeedsUpdate := false;
    end;

    procedure UpdateStatus()
    begin
        NeedsUpdate :=
          NeedsUpdate or
          (OldMembershipBurndownSetup."Period Length" <> MembershipBurndownSetup."Period Length") or
          (OldMembershipBurndownSetup."Show Memberships" <> MembershipBurndownSetup."Show Memberships") or
          (OldMembershipBurndownSetup."Use Work Date as Base" <> MembershipBurndownSetup."Use Work Date as Base") or
          (OldMembershipBurndownSetup."Value to Calculate" <> MembershipBurndownSetup."Value to Calculate") or
          (OldMembershipBurndownSetup."Chart Type" <> MembershipBurndownSetup."Chart Type") or
          (OldMembershipBurndownSetup."Show Change As" <> MembershipBurndownSetup."Show Change As");

        OldMembershipBurndownSetup := MembershipBurndownSetup;

        if NeedsUpdate then
            StatusText := MembershipBurndownSetup.GetCurrentSelectionText;

        SetActionsEnabled;
    end;

    procedure RunSetup()
    begin
        PAGE.RunModal(PAGE::"NPR RC Members. Burndown Setup", MembershipBurndownSetup);
        MembershipBurndownSetup.Get(UserId);
        UpdateStatus;
    end;

    procedure SetActionsEnabled()
    begin
        TypeOfSales := (MembershipBurndownSetup."Show Memberships" <> MembershipBurndownSetup."Show Memberships"::SALES_TYPE) and IsChartAddInReady;

        //OrdersUntilTodayEnabled :=
        //  (MembershipBurndownSetup."Show Orders" <> MembershipBurndownSetup."Show Orders"::"Orders Until Today") AND
        //  IsChartAddInReady;

        //DelayedOrdersEnabled := (MembershipBurndownSetup."Show Orders" <> MembershipBurndownSetup."Show Orders"::"Delayed Orders") AND
        //  IsChartAddInReady;

        AccumulatePeriodValue := (MembershipBurndownSetup."Show Change As" <> MembershipBurndownSetup."Show Change As"::ACK) and IsChartAddInReady;
        NetChangePeriodValue := (MembershipBurndownSetup."Show Change As" <> MembershipBurndownSetup."Show Change As"::NET) and IsChartAddInReady;

        MonthEnabled := (MembershipBurndownSetup."Period Length" <> MembershipBurndownSetup."Period Length"::Month) and IsChartAddInReady;
        QuarterEnabled := (MembershipBurndownSetup."Period Length" <> MembershipBurndownSetup."Period Length"::Quarter) and IsChartAddInReady;

        MembershipValueEnabled := (MembershipBurndownSetup."Value to Calculate" <> MembershipBurndownSetup."Value to Calculate"::MEMBERSHIP_VALUE) and IsChartAddInReady;
        MembershipCountEnabled := (MembershipBurndownSetup."Value to Calculate" <> MembershipBurndownSetup."Value to Calculate"::MEMBERSHIP_COUNT) and IsChartAddInReady;

        StackedAreaEnabled := (MembershipBurndownSetup."Chart Type" <> MembershipBurndownSetup."Chart Type"::"Stacked Area") and IsChartAddInReady;
        StackedAreaPctEnabled := (MembershipBurndownSetup."Chart Type" <> MembershipBurndownSetup."Chart Type"::"Stacked Area (%)") and IsChartAddInReady;
        StackedColumnEnabled := (MembershipBurndownSetup."Chart Type" <> MembershipBurndownSetup."Chart Type"::"Stacked Column") and IsChartAddInReady;
        StackedColumnPctEnabled := (MembershipBurndownSetup."Chart Type" <> MembershipBurndownSetup."Chart Type"::"Stacked Column (%)") and IsChartAddInReady;
    end;
}

