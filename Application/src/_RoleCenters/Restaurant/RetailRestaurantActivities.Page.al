page 6151335 "NPR Restaurant Activities"
{
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
                field("Waiter Pads - Open"; Rec."Waiter Pads - Open")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Waiter Pads - Open field';
                }
                field("Kitchen Requests - Open"; Rec."Kitchen Requests - Open")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Kitchen Requests - Open field';
                }
                field("Pending Reservations"; Rec."Pending Reservations")
                {
                    ApplicationArea = All;
                    Caption = 'Pending Reservations';
                    ToolTip = 'Specifies the value of the Pending Reservations field';
                    trigger OnDrillDown()
                    begin
                        DrillDownPendingReservations();
                    end;
                }
            }
            cuegroup(TableStatus)
            {
                Caption = 'Current Table Status';
                field("Seatings: Ready"; Rec."Seatings: Ready")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Available field';
                }
                field("Seatings: Occupied"; Rec."Seatings: Occupied")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Occupied field';
                }
                field("Seatings: Reserved"; Rec."Seatings: Reserved")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reserved field';
                }
                field("Seatings: Cleaning Required"; Rec."Seatings: Cleaning Required")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cleaning Required field';
                }
            }
            cuegroup(SeatStatus)
            {
                Caption = 'Seats';
                field("Available seats"; Rec."Available seats")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Available Seats field';
                }
                field("Inhouse Guests"; Rec."Inhouse Guests")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Inhouse Guests field';
                }
            }
            cuegroup("My User Tasks")
            {
                Caption = 'My User Tasks';
                field("UserTaskManagement.GetMyPendingUserTasksCount"; UserTaskManagement.GetMyPendingUserTasksCount())
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Pending User Tasks';
                    Image = Checklist;
                    ToolTip = 'Specifies the number of pending tasks that are assigned to you or to a group that you are a member of.';

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
                Caption = 'Today''s Summary';
                field("Turnover (LCY)"; Rec."Turnover (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Turnover field';

                    trigger OnDrillDown()
                    begin
                        DrillDownTurnover();
                    end;
                }
                field("No. of Sales"; Rec."No. of Sales")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. of Sales field';

                    trigger OnDrillDown()
                    begin
                        DrillDownTurnover();
                    end;
                }
                field("Total No. of Guests"; Rec."Total No. of Guests")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Total No. of Guests field';
                }
                field("Average per Sale (LCY)"; Rec."Average per Sale (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Average per Sale field';
                }
                field("Average per Guest (LCY)"; Rec."Average per Guest (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Average per Guest field';
                }
            }
            cuegroup(Reservations)
            {
                Caption = 'Reservations';
                field("Completed Reservations"; Rec."Completed Reservations")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Completed field';
                }
                field("No-Shows"; Rec."No-Shows")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No-Shows field';
                }
                field("Cancelled Reservations"; Rec."Cancelled Reservations")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cancelled field';
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
    var
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
    begin
        RoleCenterNotificationMgt.HideEvaluationNotificationAfterStartingTrial();
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
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;

        Rec.SetRange("Date Filter", WorkDate());
        Rec.SetRange("User ID Filter", UserId);

        if UserSetup.get(UserId) then
            if UserSetup."NPR Backoffice Restaurant Code" <> '' then
                Restaurant.SetRange(Code, UserSetup."NPR Backoffice Restaurant Code");
        SetRestaurantFilter(Restaurant);

        if not RestaurantSetup.get() then
            clear(RestaurantSetup);
        Rec.SetRange("Ready Seating Status Filter", RestaurantSetup."Seat.Status: Ready");
        Rec.SetRange("Occupied Seating Status Filter", RestaurantSetup."Seat.Status: Occupied");
        Rec.SetRange("Cleaning R. Seat.Status Filter", RestaurantSetup."Seat.Status: Cleaning Required");
        Rec.SetRange("Reserved Seating Status Filter", RestaurantSetup."Seat.Status: Reserved");

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

    local procedure RecalculateCues()
    var
        POSEntry: Record "NPR POS Entry";
        POSSalesLine: Record "NPR POS Entry Sales Line";
        POSEntryQry: Query "NPR POS Entry with Sales Lines";
        SeatingWPLinkQry: Query "NPR NPRE Seating - W/Pad Link";
    begin
        Rec."Turnover (LCY)" := 0;
        Rec."No. of Sales" := 0;
        Rec."Total No. of Guests" := 0;

        if Rec.GetFilter("Date Filter") <> '' then
            POSEntryQry.SetFilter(Posting_Date, Rec.GetFilter("Date Filter"));
        if Rec.GetFilter("POS Unit Filter") <> '' then
            POSEntryQry.SetFilter(POS_Unit_No, Rec.GetFilter("POS Unit Filter"));
        POSEntryQry.SetRange(Type, POSSalesLine.Type::Item);
        POSEntryQry.Open();
        while POSEntryQry.Read() do
            if POSSalesLine.Get(POSEntryQry.POS_Entry_No, POSEntryQry.Line_No) then begin
                Rec."Turnover (LCY)" += POSSalesLine."Amount Excl. VAT (LCY)";
                if POSEntry.Get(POSSalesLine."POS Entry No.") then
                    if not POSEntry.Mark() then begin
                        POSEntry.Mark(true);
                        Rec."No. of Sales" += 1;
                        Rec."Total No. of Guests" += POSEntry."NPRE Number of Guests";
                    end;
            end;
        POSEntryQry.Close();

        if Rec."Total No. of Guests" <> 0 then
            Rec."Average per Guest (LCY)" := Round(Rec."Turnover (LCY)" / Rec."Total No. of Guests")
        else
            Rec."Average per Guest (LCY)" := 0;
        if Rec."No. of Sales" <> 0 then
            Rec."Average per Sale (LCY)" := Round(Rec."Turnover (LCY)" / Rec."No. of Sales")
        else
            Rec."Average per Sale (LCY)" := 0;

        //Calc inhouse number of guests
        Rec."Inhouse Guests" := 0;
        if Rec.GetFilter("Seating Location Filter") <> '' then
            SeatingWPLinkQry.setfilter(SeatingLocation, Rec.GetFilter("Seating Location Filter"));
        SeatingWPLinkQry.SetRange(SeatingClosed, false);
        SeatingWPLinkQry.Open();
        while SeatingWPLinkQry.Read() do
            Rec."Inhouse Guests" += SeatingWPLinkQry.NumberOfGuests;
        SeatingWPLinkQry.Close();

        Rec.Modify();
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

    local procedure DrillDownPendingReservations()
    begin
        Error('Not supported yet');
    end;

    var
        CuesAndKpis: Codeunit "Cues And KPIs";
        UserTaskManagement: Codeunit "User Task Management";
}
