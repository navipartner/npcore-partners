page 6151335 "NPR Restaurant Activities"
{
    Caption = 'Activities';
    PageType = CardPart;
    UsageCategory = Administration;
    RefreshOnActivate = true;
    SourceTable = "NPR Restaurant Cue";

    layout
    {
        area(content)
        {
            cuegroup(Outstanding)
            {
                Caption = 'Outstanding';
                CuegroupLayout = Wide;
                field("Waiter Pads - Open"; "Waiter Pads - Open")
                {
                    ApplicationArea = All;
                }
                field("Kitchen Requests - Open"; "Kitchen Requests - Open")
                {
                    ApplicationArea = All;
                }
                field("Pending Reservations"; "Pending Reservations")
                {
                    ApplicationArea = All;
                    Caption = 'Pending Reservations';
                    trigger OnDrillDown()
                    begin
                        DrillDownPendingReservations();
                    end;
                }
            }
            cuegroup(TableStatus)
            {
                Caption = 'Current Table Status';
                field("Seatings: Ready"; "Seatings: Ready")
                {
                    ApplicationArea = All;
                }
                field("Seatings: Occupied"; "Seatings: Occupied")
                {
                    ApplicationArea = All;
                }
                field("Seatings: Reserved"; "Seatings: Reserved")
                {
                    ApplicationArea = All;
                }
                field("Seatings: Cleaning Required"; "Seatings: Cleaning Required")
                {
                    ApplicationArea = All;
                }
            }
            cuegroup(SeatStatus)
            {
                Caption = 'Seats';
                field("Available seats"; "Available seats")
                {
                    ApplicationArea = All;
                }
                field("Inhouse Guests"; "Inhouse Guests")
                {
                    ApplicationArea = All;
                }
            }
            cuegroup("My User Tasks")
            {
                Caption = 'My User Tasks';
                field("UserTaskManagement.GetMyPendingUserTasksCount"; UserTaskManagement.GetMyPendingUserTasksCount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Pending User Tasks';
                    Image = Checklist;
                    ToolTip = 'Specifies the number of pending tasks that are assigned to you or to a group that you are a member of.';

                    trigger OnDrillDown()
                    var
                        UserTaskList: Page "User Task List";
                    begin
                        UserTaskList.SetPageToShowMyPendingUserTasks;
                        UserTaskList.Run;
                    end;
                }
            }
            cuegroup(TodaySummary)
            {
                Caption = 'Today''s Summary';
                field("Turnover (LCY)"; "Turnover (LCY)")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        DrillDownTurnover();
                    end;
                }
                field("No. of Sales"; "No. of Sales")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        DrillDownTurnover();
                    end;
                }
                field("Total No. of Guests"; "Total No. of Guests")
                {
                    ApplicationArea = All;
                }
                field("Average per Sale (LCY)"; "Average per Sale (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Average per Guest (LCY)"; "Average per Guest (LCY)")
                {
                    ApplicationArea = All;
                }
            }
            cuegroup(Reservations)
            {
                Caption = 'Reservations';
                field("Completed Reservations"; "Completed Reservations")
                {
                    ApplicationArea = All;
                }
                field("No-Shows"; "No-Shows")
                {
                    ApplicationArea = All;
                }
                field("Cancelled Reservations"; "Cancelled Reservations")
                {
                    ApplicationArea = All;
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
                ApplicationArea = Basic, Suite;
                Caption = 'Set Up Cues';
                Image = Setup;
                ToolTip = 'Set up the cues (status tiles) related to the role.';

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
                ApplicationArea = Basic, Suite;
                Caption = 'Select Restaurant';
                Image = NewBranch;
                ToolTip = 'Select active restaurant for the cue calculations.';

                trigger OnAction()
                var
                    Restaurant: Record "NPR NPRE Restaurant";
                    FilterPage: FilterPageBuilder;
                begin
                    FilterPage.AddRecord(Restaurant.TableCaption, Restaurant);
                    FilterPage.AddField(Restaurant.TableCaption, Restaurant.Code, GetFilter("Restaurant Filter"));
                    if not FilterPage.RunModal() then
                        exit;
                    Restaurant.SetView(FilterPage.GetView(Restaurant.TableCaption));
                    SetRestaurantFilter(Restaurant);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
    begin
        RoleCenterNotificationMgt.HideEvaluationNotificationAfterStartingTrial;
        RecalculateCues();
    end;

    trigger OnOpenPage()
    var
        Restaurant: Record "NPR NPRE Restaurant";
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        UserSetup: Record "User Setup";
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
    begin
        Reset;
        if not Get then begin
            Init;
            Insert;
        end;

        SetRange("Date Filter", WorkDate());
        SetRange("User ID Filter", UserId);

        if UserSetup.get(UserId) then
            if UserSetup."NPR Backoffice Restaurant Code" <> '' then
                Restaurant.SetRange(Code, UserSetup."NPR Backoffice Restaurant Code");
        SetRestaurantFilter(Restaurant);

        if not RestaurantSetup.get() then
            clear(RestaurantSetup);
        SetRange("Ready Seating Status Filter", RestaurantSetup."Seat.Status: Ready");
        SetRange("Occupied Seating Status Filter", RestaurantSetup."Seat.Status: Occupied");
        SetRange("Cleaning R. Seat.Status Filter", RestaurantSetup."Seat.Status: Cleaning Required");
        SetRange("Reserved Seating Status Filter", RestaurantSetup."Seat.Status: Reserved");

        RoleCenterNotificationMgt.ShowNotifications;
        ConfPersonalizationMgt.RaiseOnOpenRoleCenterEvent;
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
            SetRange("Restaurant Filter");
            SetRange("Seating Location Filter");
        end else begin
            RecRef.GetTable(Restaurant);
            SetFilter("Restaurant Filter", SelectionFilterMgt.GetSelectionFilter(RecRef, Restaurant.FieldNo(Code)));

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
            SetFilter("Seating Location Filter", SelectionFilterMgt.GetSelectionFilter(RecRef, SeatingLocation.FieldNo(Code)));
        end;

        POSUnit.reset;
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
        TotalNoOfPOSUnits: Integer;
    begin
        if POSUnit.Count = POSUnit2.Count then begin
            SetRange("POS Unit Filter");
            exit;
        end;
        RecRef.GetTable(POSUnit);
        SetFilter("POS Unit Filter", SelectionFilterMgt.GetSelectionFilter(RecRef, POSUnit.FieldNo("No.")));
    end;

    local procedure RecalculateCues()
    var
        POSEntry: Record "NPR POS Entry";
        POSSalesLine: Record "NPR POS Sales Line";
        POSEntryQry: Query "NPR POS Entry with Sales Lines";
        SeatingWPLinkQry: Query "NPR NPRE Seating - W/Pad Link";
    begin
        "Turnover (LCY)" := 0;
        "No. of Sales" := 0;
        "Total No. of Guests" := 0;

        if GetFilter("Date Filter") <> '' then
            POSEntryQry.SetFilter(Posting_Date, GetFilter("Date Filter"));
        if GetFilter("POS Unit Filter") <> '' then
            POSEntryQry.SetFilter(POS_Unit_No, GetFilter("POS Unit Filter"));
        POSEntryQry.SetRange(Type, POSSalesLine.Type::Item);
        POSEntryQry.Open();
        while POSEntryQry.Read() do
            if POSSalesLine.Get(POSEntryQry.POS_Entry_No, POSEntryQry.Line_No) then begin
                "Turnover (LCY)" += POSSalesLine."Amount Excl. VAT (LCY)";
                if POSEntry.Get(POSSalesLine."POS Entry No.") then
                    if not POSEntry.Mark then begin
                        POSEntry.Mark(true);
                        "No. of Sales" += 1;
                        "Total No. of Guests" += POSEntry."NPRE Number of Guests";
                    end;
            end;
        POSEntryQry.Close();

        if "Total No. of Guests" <> 0 then
            "Average per Guest (LCY)" := Round("Turnover (LCY)" / "Total No. of Guests")
        else
            "Average per Guest (LCY)" := 0;
        if "No. of Sales" <> 0 then
            "Average per Sale (LCY)" := Round("Turnover (LCY)" / "No. of Sales")
        else
            "Average per Sale (LCY)" := 0;

        //Calc inhouse number of guests
        "Inhouse Guests" := 0;
        if GetFilter("Seating Location Filter") <> '' then
            SeatingWPLinkQry.setfilter(SeatingLocation, GetFilter("Seating Location Filter"));
        SeatingWPLinkQry.SetRange(SeatingClosed, false);
        SeatingWPLinkQry.Open();
        while SeatingWPLinkQry.Read() do
            "Inhouse Guests" += SeatingWPLinkQry.NumberOfGuests;
        SeatingWPLinkQry.Close();

        Modify();
    end;

    local procedure DrillDownTurnover()
    var
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.SetRange("Entry Date", WorkDate());
        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Direct Sale");  //?
        CopyFilter("POS Unit Filter", POSEntry."POS Unit No.");
        Page.run(Page::"NPR POS Entries", POSEntry);
    end;

    local procedure DrillDownPendingReservations()
    begin
        Error('Not supported yet');
    end;

    var
        CuesAndKpis: Codeunit "Cues And KPIs";
        UserTaskManagement: Codeunit "User Task Management";
}