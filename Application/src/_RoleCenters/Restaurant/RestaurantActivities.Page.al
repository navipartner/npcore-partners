page 6151335 "NPR Restaurant Activities"
{
    Extensible = False;
    Caption = 'Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "NPR Restaurant Cue";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            cuegroup(Outstanding)
            {
                Caption = 'Outstanding';
                CuegroupLayout = Wide;
                field("Waiter Pads - Open"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Waiter Pads - Open"))))
                {
                    ToolTip = 'Specifies the number of currently opened waiter pads.';
                    ApplicationArea = NPRRetail;
                    Caption = 'Waiter Pads - Open';

                    trigger OnDrillDown()
                    begin
                        DrillDownWaiterPads();
                    end;
                }
                field("Kitchen Orders - Open"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Kitchen Orders - Open"))))
                {
                    ToolTip = 'Specifies the number of currently active kitchen orders (the orders having active kitchen requests).';
                    ApplicationArea = NPRRetail;
                    Caption = 'Kitchen Orders - Open';

                    trigger OnDrillDown()
                    var
                        KitchenOrder: Record "NPR NPRE Kitchen Order";
                    begin
                        Rec.CopyFilter("Restaurant Filter", KitchenOrder."Restaurant Code");
                        KitchenOrder.SetRange("Order Status", KitchenOrder."Order Status"::"Ready for Serving", KitchenOrder."Order Status"::Planned);
                        Page.Run(0, KitchenOrder);
                    end;
                }
                field("Kitchen Requests - Open"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Kitchen Requests - Open"))))
                {
                    ToolTip = 'Specifies the number of currently active expedite kitchen requests (the requests that haven’t been completed or cancelled yet).';
                    ApplicationArea = NPRRetail;
                    Caption = 'Kitchen Requests (Expedite) - Open';

                    trigger OnDrillDown()
                    var
                        KitchenRequest: Record "NPR NPRE Kitchen Request";
                    begin
                        Rec.CopyFilter("Restaurant Filter", KitchenRequest."Restaurant Code");
                        Page.Run(Page::"NPR NPRE Kitchen Req.", KitchenRequest);
                    end;
                }
                field("Kitch. Station Requests - Open"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Kitch. Station Requests - Open"))))
                {
                    ToolTip = 'Specifies the number of currently active production requests to kitchen stations (requests for which production hasn’t been completed or cancelled).';
                    ApplicationArea = NPRRetail;
                    Caption = 'Kitchen Station Requests - Open';

                    trigger OnDrillDown()
                    begin
                        ShowKitchenRequests();
                    end;
                }
                field("Pending Reservations"; Rec."Pending Reservations")
                {
                    Caption = 'Pending Reservations';
                    ToolTip = 'Specifies the number of upcoming reservations.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
            }
            cuegroup(TableStatus)
            {
                Caption = 'Current Table Status';
                field("Seatings: Ready"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Seatings: Ready"))))
                {
                    ToolTip = 'Specifies the number of tables that are currently ready for next guests.';
                    ApplicationArea = NPRRetail;
                    Caption = 'Ready';

                    trigger OnDrillDown()
                    begin
                        DrillDownSeatingList(0);
                    end;
                }
                field("Seatings: Occupied"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Seatings: Occupied"))))
                {
                    ToolTip = 'Specifies the number of occupied tables.';
                    ApplicationArea = NPRRetail;
                    Caption = 'Occupied';

                    trigger OnDrillDown()
                    begin
                        DrillDownSeatingList(1);
                    end;
                }
                field("Seatings: Reserved"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Seatings: Reserved"))))
                {
                    ToolTip = 'Specifies the number of reserved tables.';
                    ApplicationArea = NPRRetail;
                    Caption = 'Reserved';

                    trigger OnDrillDown()
                    begin
                        DrillDownSeatingList(2);
                    end;
                }
                field("Seatings: Cleaning Required"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Seatings: Cleaning Required"))))
                {
                    ToolTip = 'Specifies the number of tables requiring cleaning.';
                    ApplicationArea = NPRRetail;
                    Caption = 'Cleaning Required';

                    trigger OnDrillDown()
                    begin
                        DrillDownSeatingList(3);
                    end;
                }
            }
            cuegroup(SeatStatus)
            {
                Caption = 'Seats';
                field("Available seats"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Available Seats"))))
                {
                    ToolTip = 'Specifies the number of currently available seats.';
                    ApplicationArea = NPRRetail;
                    Caption = 'Available Seats';
                }
                field("Inhouse Guests"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Inhouse Guests"))))
                {
                    ToolTip = 'Specifies current number of inhouse guests.';
                    ApplicationArea = NPRRetail;
                    Caption = 'Inhouse Guests';
                }
            }
            cuegroup("My User Tasks")
            {
                Caption = 'My User Tasks';
                field("Pending User Tasks"; UserTaskManagement.GetMyPendingUserTasksCount())
                {
                    Caption = 'Pending User Tasks';
                    Image = Checklist;
                    ToolTip = 'Specifies the number of pending tasks that are assigned to you or to a group that you are a member of.';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        UserTaskList: Page "User Task List";
                    begin
                        UserTaskList.SetPageToShowMyPendingUserTasks();
                        UserTaskList.Run();
                    end;
                }
            }
            cuegroup(TodaySummary)
            {
                Caption = 'Today’s Summary';
                field("Turnover (LCY)"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Turnover (LCY)"))))
                {
                    ToolTip = 'Specifies today’s turnover amount posted so far.';
                    ApplicationArea = NPRRetail;
                    Caption = 'Turnover (LCY)';
                    trigger OnDrillDown()
                    begin
                        DrillDownTurnover();
                    end;
                }
                field("No. of Sales"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("No. of Sales"))))
                {
                    ToolTip = 'Specifies today’s number of POS sales posted so far.';
                    ApplicationArea = NPRRetail;
                    Caption = 'No. of Sales';
                    trigger OnDrillDown()
                    begin
                        DrillDownTurnover();
                    end;
                }
                field("Total No. of Guests"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Total No. of Guests"))))
                {
                    ToolTip = 'Specifies today’s total of number of guests registered on posted POS sales so far.';
                    ApplicationArea = NPRRetail;
                    Caption = 'Total No. of Guests';
                }
                field("Average per Sale (LCY)"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Average per Sale (LCY)"))))
                {
                    ToolTip = 'Specifies today’s average amount per sale.';
                    ApplicationArea = NPRRetail;
                    Caption = 'Average per Sale (LCY)';
                }
                field("Average per Guest (LCY)"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Average per Guest (LCY)"))))
                {
                    ToolTip = 'Specifies today’s average amount per guest.';
                    ApplicationArea = NPRRetail;
                    Caption = 'Average per Guest (LCY)';
                }
            }
            cuegroup(Reservations)
            {
                Caption = 'Reservations';
                Visible = false;
                field("Completed Reservations"; Rec."Completed Reservations")
                {
                    ToolTip = 'Specifies today’s number of completed reservations.';
                    ApplicationArea = NPRRetail;
                    Caption = 'Completed';
                }
                field("No-Shows"; Rec."No-Shows")
                {
                    ToolTip = 'Specifies today’s number of reservation no-shows.';
                    ApplicationArea = NPRRetail;
                    Caption = 'No-Shows';
                }
                field("Cancelled Reservations"; Rec."Cancelled Reservations")
                {
                    ToolTip = 'Specifies today’s number of cancelled reservations.';
                    ApplicationArea = NPRRetail;
                    Caption = 'Cancelled';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Set Up Cues")
            {
                Caption = 'Set Up Cues';
                Image = Setup;
                ToolTip = 'Set up the cues (status tiles) related to the role.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    CueRecordRef: RecordRef;
                begin
                    CueRecordRef.GetTable(Rec);
                    CuesAndKpis.OpenCustomizePageForCurrentUser(CueRecordRef.Number);
                end;
            }
            action("Select Restaurant")
            {
                Caption = 'Select Restaurant';
                Image = NewBranch;
                ToolTip = 'Select active restaurant for cue calculations.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    Restaurant: Record "NPR NPRE Restaurant";
                    FilterPage: FilterPageBuilder;
                begin
                    FilterPage.AddRecord(Restaurant.TableCaption, Restaurant);
                    FilterPage.AddField(Restaurant.TableCaption, Restaurant.Code, Rec.GetFilter("Restaurant Filter"));
                    if not FilterPage.RunModal() then
                        exit;
                    Restaurant.SetView(FilterPage.GetView(Restaurant.TableCaption));
                    SetRestaurantFilter(Restaurant);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
#if BC17 or BC18 or BC19 or BC20    
    var
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
#endif        
    begin
#if BC17 or BC18 or BC19 or BC20
        RoleCenterNotificationMgt.HideEvaluationNotificationAfterStartingTrial();
#endif
        CalculateFieldValues();
    end;

    local procedure CalculateFieldValues()
    var
        Parameters: Dictionary of [Text, Text];
    begin
        if (BackgroundTaskId <> 0) then
            CurrPage.CancelBackgroundTask(BackgroundTaskId);

        Parameters.Add(Rec.FieldCaption("Restaurant Filter"), Rec.GetFilter("Restaurant Filter"));
        Parameters.Add(Rec.FieldCaption("Seating Location Filter"), Rec.GetFilter("Seating Location Filter"));
        Parameters.Add(Rec.FieldCaption("POS Unit Filter"), Rec.GetFilter("POS Unit Filter"));

        CurrPage.EnqueueBackgroundTask(BackgroundTaskId, Codeunit::"NPR RE Activity Backgrd Task", Parameters);
    end;

    trigger OnOpenPage()
    var
        Restaurant: Record "NPR NPRE Restaurant";
        UserSetup: Record "User Setup";
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;

        if UserSetup.get(UserId) then
            if UserSetup."NPR Backoffice Restaurant Code" <> '' then
                Restaurant.SetRange(Code, UserSetup."NPR Backoffice Restaurant Code");
        SetRestaurantFilter(Restaurant);

        RoleCenterNotificationMgt.ShowNotifications();
        ConfPersonalizationMgt.RaiseOnOpenRoleCenterEvent();
    end;

    local procedure SetRestaurantFilter(var Restaurant: Record "NPR NPRE Restaurant")
    var
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        POSUnit: Record "NPR POS Unit";
        SeatingLocation: Record "NPR NPRE Seating Location";
        SeatingMgt: Codeunit "NPR NPRE Seating Mgt.";
        SelectionFilterMgt: Codeunit SelectionFilterManagement;
        RecRef: RecordRef;
    begin
        if Restaurant.GetFilters() = '' then begin
            Rec.SetRange("Restaurant Filter");
            Rec.SetRange("Seating Location Filter");
        end else begin
            RecRef.GetTable(Restaurant);
            Rec.SetFilter("Restaurant Filter", SelectionFilterMgt.GetSelectionFilter(RecRef, Restaurant.FieldNo(Code)));

            SeatingLocation.Reset();
            if Restaurant.FindSet() then
                repeat
                    SeatingLocation.SetFilter(Code, SeatingMgt.RestaurantSeatingLocationFilter(Restaurant.Code));
                    if SeatingLocation.FindSet() then
                        repeat
                            SeatingLocation.Mark(true);
                        until SeatingLocation.Next() = 0;
                until Restaurant.Next() = 0;

            SeatingLocation.SetRange(Code);
            SeatingLocation.MarkedOnly(true);
            RecRef.GetTable(SeatingLocation);
            Rec.SetFilter("Seating Location Filter", SelectionFilterMgt.GetSelectionFilter(RecRef, SeatingLocation.FieldNo(Code)));
        end;

        POSUnit.Reset();
        if Restaurant.FindSet() then
            repeat
                POSRestProfile.SetRange("Restaurant Code", Restaurant.Code);
                RecRef.GetTable(POSRestProfile);
                POSUnit.SetFilter("POS Restaurant Profile", SelectionFilterMgt.GetSelectionFilter(RecRef, POSRestProfile.FieldNo(Code)));
                if POSUnit.FindSet() then
                    repeat
                        POSUnit.Mark(true);
                    until POSUnit.Next() = 0;
            until Restaurant.Next() = 0;

        POSUnit.SetRange("POS Restaurant Profile");
        POSUnit.MarkedOnly(true);
        SetPOSUnitFilter(POSUnit);
    end;

    local procedure SetPOSUnitFilter(var POSUnit: Record "NPR POS Unit")
    var
        POSUnit2: Record "NPR POS Unit";
        SelectionFilterMgt: Codeunit SelectionFilterManagement;
        RecRef: RecordRef;
    begin
        if POSUnit.Count() = POSUnit2.Count() then begin
            Rec.SetRange("POS Unit Filter");
            exit;
        end;
        RecRef.GetTable(POSUnit);
        Rec.SetFilter("POS Unit Filter", SelectionFilterMgt.GetSelectionFilter(RecRef, POSUnit.FieldNo("No.")));
    end;

    local procedure DrillDownTurnover()
    var
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.SetRange("Entry Date", WorkDate());
        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Direct Sale");  //?
        Rec.CopyFilter("POS Unit Filter", POSEntry."POS Unit No.");
        Page.run(Page::"NPR POS Entries", POSEntry);
    end;

    local procedure DrillDownWaiterPads()
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        SeatingWPLinkQry: Query "NPR NPRE Seating - W/Pad Link";
        Window: Dialog;
        CalculatingLbl: Label 'Working on it...';
    begin
        Window.Open(CalculatingLbl);
        if Rec.GetFilter("Seating Location Filter") <> '' then
            SeatingWPLinkQry.SetFilter(SeatingLocation, Rec.GetFilter("Seating Location Filter"));
        SeatingWPLinkQry.SetRange(SeatingClosed, false);
        SeatingWPLinkQry.Open();
        while SeatingWPLinkQry.Read() do begin
            WaiterPad."No." := SeatingWPLinkQry.WaiterPadNo;
            if not WaiterPad.Mark() then
                WaiterPad.Mark(true);
        end;
        SeatingWPLinkQry.Close();
        Window.Close();
        WaiterPad.MarkedOnly(true);
        Page.Run(0, WaiterPad);
    end;

    local procedure DrillDownSeatingList(SeatingStatus: Option Ready,Occupied,Reserved,Cleaning)
    var
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        Seating: Record "NPR NPRE Seating";
    begin
        RestaurantSetup.Get();
        case SeatingStatus of
            SeatingStatus::Ready:
                begin
                    RestaurantSetup.TestField("Seat.Status: Ready");
                    Seating.SetRange(Status, RestaurantSetup."Seat.Status: Ready");
                end;
            SeatingStatus::Occupied:
                begin
                    RestaurantSetup.TestField("Seat.Status: Occupied");
                    Seating.SetRange(Status, RestaurantSetup."Seat.Status: Occupied");
                end;
            SeatingStatus::Reserved:
                begin
                    RestaurantSetup.TestField("Seat.Status: Reserved");
                    Seating.SetRange(Status, RestaurantSetup."Seat.Status: Reserved");
                end;
            SeatingStatus::Cleaning:
                begin
                    RestaurantSetup.TestField("Seat.Status: Cleaning Required");
                    Seating.SetRange(Status, RestaurantSetup."Seat.Status: Cleaning Required");
                end;
        end;
        Rec.CopyFilter("Seating Location Filter", Seating."Seating Location");
        Page.Run(0, Seating);
    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    var
        BackgrndTaskMgt: Codeunit "NPR Page Background Task Mgt.";
    begin
        BackgrndTaskMgt.CopyTaskResults(Results, BackgroundTaskResults);
    end;

    trigger OnPageBackgroundTaskError(TaskId: Integer; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text; var IsHandled: Boolean)
    var
        BackgrndTaskMgt: Codeunit "NPR Page Background Task Mgt.";
    begin
        if (TaskId = BackgroundTaskId) then
            BackgrndTaskMgt.FailedTaskError(CurrPage.Caption(), ErrorCode, ErrorText);
    end;

    local procedure GetFieldValueFromBackgroundTaskResultSet(FieldNo: Text) Result: Integer
    begin
        if not BackgroundTaskResults.ContainsKey(FieldNo) then
            exit(0);
        if not Evaluate(Result, BackgroundTaskResults.Get(FieldNo), 9) then
            Result := 0;
    end;

    local procedure ShowKitchenRequests()
    var
        KitchenStation: Record "NPR NPRE Kitchen Station";
        PageAction: Action;
    begin
        KitchenStation.FilterGroup(2);
        Rec.CopyFilter("Restaurant Filter", KitchenStation."Restaurant Code");
        KitchenStation.FilterGroup(0);
        if KitchenStation.Count() = 1 then
            KitchenStation.FindFirst()
        else
            PageAction := Page.RunModal(Page::"NPR NPRE Kitchen Stations", KitchenStation);
        KitchenStation.ShowKitchenRequests();
    end;

    var
        CuesAndKpis: Codeunit "Cues And KPIs";
        UserTaskManagement: Codeunit "User Task Management";
        BackgroundTaskResults: Dictionary of [Text, Text];
        BackgroundTaskId: Integer;
}
