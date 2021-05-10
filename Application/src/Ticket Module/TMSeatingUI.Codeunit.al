codeunit 6151131 "NPR TM Seating UI"
{
    // TM1.43/TSA /20190617 CASE 357359 Initial Version
    // TM1.45/TSA /20191113 CASE 322432 Alot of small changes
    // 
    // ##### SINGLE INSTANCE #####

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Model: DotNet NPRNetModel;
        ActiveModelID: Guid;
        ReservationUpdateEntryNo: Integer;
        ShowExtAdmSchEntryNo: Integer;
        EditReservation: Boolean;

    local procedure ConstructUI(ExtAdmScheduleEntryNo: Integer): Boolean
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin

        AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', ExtAdmScheduleEntryNo);
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (not AdmissionScheduleEntry.FindFirst()) then
            exit(false);

        exit(ConstructUIWorker(AdmissionScheduleEntry."Admission Code", AdmissionScheduleEntry."Schedule Code", ExtAdmScheduleEntryNo));
    end;

    local procedure ConstructUIWorker(AdmissionCode: Code[20]; ScheduleCode: Code[20]; ExtAdmScheduleEntryNo: Integer): Boolean
    var
        Admission: Record "NPR TM Admission";
        Schedule: Record "NPR TM Admis. Schedule";
        AdmissionSchedule: Record "NPR TM Admis. Schedule Lines";
    begin

        Admission.Get(AdmissionCode);
        Schedule.Get(ScheduleCode);
        AdmissionSchedule.Get(AdmissionCode, ScheduleCode);

        case Admission."Capacity Limits By" of
            Admission."Capacity Limits By"::ADMISSION:
                if (Admission."Capacity Control" <> Admission."Capacity Control"::SEATING) then
                    exit(false);

            Admission."Capacity Limits By"::SCHEDULE:
                if (Schedule."Capacity Control" <> Schedule."Capacity Control"::SEATING) then
                    exit(false);

            else
                if (AdmissionSchedule."Capacity Control" <> AdmissionSchedule."Capacity Control"::SEATING) then
                    exit(false);
        end;

        Model := Model.Model();
        Model.AddHtml(RenderSeatSelection(AdmissionCode, ScheduleCode, ExtAdmScheduleEntryNo));
        Model.AddStyle(CSS());
        Model.AddScript(Javascript());

        exit(true);
    end;

    procedure ShowSelectSeatUI(POSFrontEnd: Codeunit "NPR POS Front End Management"; Token: Text[100]; EditCurrentReservation: Boolean)
    var
        ShowUI: Boolean;
    begin

        // Asynchrounous
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindSet()) then
            repeat
                ShowUI := ShowUIAdmissionScheduleEntry(POSFrontEnd, TicketReservationRequest."External Adm. Sch. Entry No.", EditCurrentReservation);
            until (ShowUI or (TicketReservationRequest.Next() = 0));
    end;

    procedure ShowUIAdmissionScheduleEntry(POSFrontEnd: Codeunit "NPR POS Front End Management"; ExtAdmScheduleEntryNo: Integer; EditCurrentReservation: Boolean): Boolean
    begin

        EditReservation := EditCurrentReservation;

        if (ExtAdmScheduleEntryNo <= 0) then
            exit(false);

        if (not (ConstructUI(ExtAdmScheduleEntryNo))) then
            exit(false);

        ShowExtAdmSchEntryNo := ExtAdmScheduleEntryNo;


        // Asynchrounous
        ActiveModelID := POSFrontEnd.ShowModel(Model);

        exit(true);
    end;

    local procedure FindNextSchedule(): Boolean
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin

        AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', ShowExtAdmSchEntryNo);
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (not AdmissionScheduleEntry.FindFirst()) then
            exit(false);

        AdmissionScheduleEntry.Reset();
        AdmissionScheduleEntry.SetCurrentKey("Admission Start Date", "Admission Start Time");
        AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionScheduleEntry."Admission Code");
        AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', AdmissionScheduleEntry."Admission Start Date");
        AdmissionScheduleEntry.SetFilter("Admission Start Time", '>%1', AdmissionScheduleEntry."Admission Start Time");
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);

        if (not AdmissionScheduleEntry.FindFirst()) then begin
            AdmissionScheduleEntry.Reset();
            AdmissionScheduleEntry.SetCurrentKey("Admission Start Date", "Admission Start Time");
            AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionScheduleEntry."Admission Code");
            AdmissionScheduleEntry.SetFilter("Admission Start Date", '>%1', AdmissionScheduleEntry."Admission Start Date");
            AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        end;

        if (not AdmissionScheduleEntry.FindFirst()) then
            exit(false);

        ShowExtAdmSchEntryNo := AdmissionScheduleEntry."External Schedule Entry No.";
        exit(true);
    end;

    local procedure FindPrevSchedule(): Boolean
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin

        AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', ShowExtAdmSchEntryNo);
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (not AdmissionScheduleEntry.FindFirst()) then
            exit(false);

        AdmissionScheduleEntry.Reset();
        AdmissionScheduleEntry.SetCurrentKey("Admission Start Date", "Admission Start Time");
        AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionScheduleEntry."Admission Code");
        AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', AdmissionScheduleEntry."Admission Start Date");
        AdmissionScheduleEntry.SetFilter("Admission Start Time", '<%1', AdmissionScheduleEntry."Admission Start Time");
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);

        if (not AdmissionScheduleEntry.FindLast()) then begin
            AdmissionScheduleEntry.Reset();
            AdmissionScheduleEntry.SetCurrentKey("Admission Start Date", "Admission Start Time");
            AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionScheduleEntry."Admission Code");
            AdmissionScheduleEntry.SetFilter("Admission Start Date", '<%1', AdmissionScheduleEntry."Admission Start Date");
            AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        end;

        if (not AdmissionScheduleEntry.FindLast()) then
            exit(false);

        if (AdmissionScheduleEntry."Admission Start Date" < Today) then
            exit(false);

        if (AdmissionScheduleEntry."Admission Start Date" = Today) and (AdmissionScheduleEntry."Admission End Time" < Time) then
            exit(false);

        ShowExtAdmSchEntryNo := AdmissionScheduleEntry."External Schedule Entry No.";
        exit(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnProtocolUIResponse', '', true, true)]
    local procedure OnUIResponse(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; ModelID: Guid; Sender: Text; EventName: Text; var Handled: Boolean)
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ResponseMessage: Text;
        ResponseCode: Integer;
        ShowUI: Boolean;
    begin

        if ModelID <> ActiveModelID then
            exit;

        Handled := true;

        case Sender of
            'ticketing-refresh-timer':
                begin
                    Model.AddScript(UpdateSeatReservationList(ShowExtAdmSchEntryNo));
                    FrontEnd.UpdateModel(Model, ActiveModelID);
                end;

            'ticketing-make-reservation':
                begin
                    if (TicketReservationRequest."External Adm. Sch. Entry No." <> ShowExtAdmSchEntryNo) then begin
                        TicketRequestManager.DeleteReservationRequest(TicketReservationRequest."Session Token ID", false);

                        TicketReservationRequest.Get(TicketReservationRequest."Entry No.");
                        TicketReservationRequest."External Adm. Sch. Entry No." := ShowExtAdmSchEntryNo;
                        TicketReservationRequest.Modify();

                        ResponseCode := TicketRequestManager.IssueTicketFromReservationToken(TicketReservationRequest."Session Token ID", false, ResponseMessage);
                        if (ResponseCode <> 0) then begin
                            FrontEnd.CloseModel(ActiveModelID);
                            Error(ResponseMessage);
                        end;

                    end;
                    SaveSeatReservation(TicketReservationRequest, EventName);

                    FrontEnd.UpdateModel(Model, ActiveModelID);
                    FrontEnd.CloseModel(ActiveModelID);

                    // Goto next ticket in BOM
                    if (TicketReservationRequest.Next() <> 0) then begin
                        repeat
                            ShowUI := ShowUIAdmissionScheduleEntry(FrontEnd, ShowExtAdmSchEntryNo, EditReservation);
                        until (ShowUI or (TicketReservationRequest.Next() = 0));
                    end;

                    if (not ShowUI) then
                        OnSeatReservationCompleted(TicketReservationRequest."Session Token ID");

                end;

            'ticketing-nextSchedule':
                begin
                    if (FindNextSchedule()) then begin
                        if (ConstructUI(ShowExtAdmSchEntryNo)) then begin
                            FrontEnd.CloseModel(ActiveModelID);
                            ActiveModelID := FrontEnd.ShowModel(Model);
                        end;
                    end;
                end;

            'ticketing-prevSchedule':
                begin
                    if (FindPrevSchedule()) then begin
                        if (ConstructUI(ShowExtAdmSchEntryNo)) then begin
                            FrontEnd.CloseModel(ActiveModelID);
                            ActiveModelID := FrontEnd.ShowModel(Model);
                        end;
                    end;
                end;

            'ticketing-abort':
                begin
                    FrontEnd.UpdateModel(Model, ActiveModelID);
                    FrontEnd.CloseModel(ActiveModelID);
                end;

            else
                Message('Unhandled event from UI: %1', Sender);

        end;
    end;

    local procedure RenderSeatSelection(AdmissionCode: Code[20]; ScheduleCode: Code[20]; ExtAdmScheduleEntryNo: Integer): Text
    begin

        exit(SVG_Example(AdmissionCode, ScheduleCode, ExtAdmScheduleEntryNo));
    end;

    local procedure CSS(): Text
    begin

        exit(
        '.seating-dialog {' +
         '  max-width: 100em;' +
         '  max-height: 100em;' +
         '  width: 50vw;' +
         '  height: 80vh;' +
         '  background: linear-gradient(#f4f4f4, #dedede);' +
         '  -webkit-box-shadow: 0px 0px 12px 2px rgba(143,143,143,1);' +
         '  -moz-box-shadow: 0px 0px 12px 2px rgba(143,143,143,1);' +
         '  box-shadow: 0px 0px 12px 2px rgba(143,143,143,1);' +

        // '  display: -webkit-box;'+
        // '  display: -moz-box;'+
        // '  display: -ms-flexbox;'+
        // '  display: -webkit-flex;'+
        // '  display: flex;'+
        //'  flex-flow: column wrap;'+
        //'  justify-content: space-around;'+
        //'  align-items: center;' +
        '}'
        );
    end;

    local procedure SVG_Example(AdmissionCode: Code[20]; ScheduleCode: Code[20]; ExtAdmScheduleEntryNo: Integer) SvGText: Text
    var
        Admission: Record "NPR TM Admission";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin

        Admission.Get(AdmissionCode);
        AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', ExtAdmScheduleEntryNo);
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        AdmissionScheduleEntry.FindFirst();

        SvGText :=
        '<div class="seating-dialog">' +
        '<svg width="100%" height="100%" viewBox="0 0 1200 1200" preserveAspectRatio="none"> ' +

          '<style>' +
            'a:hover rect { fill: #007eff; }' +
            '.free_seat {fill: #bcbcbc; opacity: 1; cursor: pointer;}' +
            '.taken_seat {fill: #ec0000; opacity: 1; cursor: not-allowed;}' +
            '.seat-highlight {fill: #00ec00; opacity: 1;}' +
            '.seat-selected {fill: #1d1d1d; opacity: 1;}' +
            '.btnText32 {font: bold 32px sans-serif; fill: black;}' +
            '.btnText24 {font: bold 24px sans-serif; fill: black;}' +
            '.btnText12 {font: bold 12px sans-serif;}' +
            '.isDisabled { opacity: 0.5; cursor: not-allowed; }' +
            '.hidden_seat { opacity: 0.0; }' +
          '</style>' +

          '<svg x="200" width="800" height="800" preserveaspectratio="none">' +
          LoadSVGForAdmSchEntry(ExtAdmScheduleEntryNo) +
          '</svg>' +

          '<foreignObject x="500" y="900" width="200" height="150">' +
          '  <body xmlns="http://www.w3.org/1999/xhtml">' +
          '    <div valign=center><form class="btnText32" >' +
          '     <input type="radio" name="assignment" id="assign_as_group" checked>Group<br>' +
          '     <input type="radio" name="assignment" id="assign_as_individual">Individuals' +
          '    </form></div>' +
          '  </body>' +
          '</foreignObject>' +

          '<a href="#" id="submitBtn">' +
          '  <rect x="860" y="900" rx="10" ry="10" height="60" width="140" fill="#00b2ff" stroke="black" />' +
          '  <text x="930" y="933" class="btnText32" text-anchor="middle" alignment-baseline="middle">Reserve</text>' +
          '</a>' +

          '<a href="#" id="cancelBtn">' +
          '  <rect x="200" y="900" rx="10" ry="10" height="60" width="140" fill="#00b2ff" stroke="black" />' +
          '  <text x="270" y="933" class="btnText32" text-anchor="middle" alignment-baseline="middle">Cancel</text>' +
          '</a>' +

          '<a href="#" id="prevBtn">' +
          '  <rect x="200" y="1000" rx="10" ry="10" height="30" width="140" fill="#00b2ff" stroke="black" />' +
          '  <text x="270" y="1017" class="btnText24" text-anchor="middle" alignment-baseline="middle">Previous</text>' +
          '</a>' +

          '<a href="#" id="nextBtn">' +
          '  <rect x="860" y="1000" rx="10" ry="10" height="30" width="140" fill="#00b2ff" stroke="black" />' +
          '  <text x="930" y="1017" class="btnText24" text-anchor="middle" alignment-baseline="middle">Next</text>' +
          '</a>' +

          StrSubstNo('<text x="600" y="1060" class="btnText32" text-anchor="middle" alignment-baseline="middle">%1 - <%2> %3 - %4</text>',
            Admission.Description,
            AdmissionScheduleEntry."Admission Start Date",
            AdmissionScheduleEntry."Admission Start Time",
            AdmissionScheduleEntry."Admission End Time") +

          '<script><![CDATA[' +

            'var maxSeatsToAllocate = 1;' +
            'var numberOfSeatsToAllocate = 1;' +
            'var seatAllocationIndex = 0;' +
            'var seatsSelected = [];' +

            'var freeseats = document.getElementsByClassName ("free_seat");' +
            'for (var i = 0; i < freeseats.length; i++) {' +
            '  freeseats[i].addEventListener ("mouseover", eventMouseOverSeat);' +
            '  freeseats[i].addEventListener ("mouseout", eventMouseOutSeat);' +
            '  freeseats[i].addEventListener ("click", eventMouseClickSeat);' +
            '}' +

            'document.getElementById("submitBtn").classList.add ("isDisabled");' +
            'document.getElementById("submitBtn").addEventListener ("click", () => {' +
            '  var selectedseats = document.getElementsByClassName ("seat-selected");' +
            '  var seatlist = "";' +
            '  for (var i = 0; i < selectedseats.length -1; i++) {' +
            '    seatlist += selectedseats[i].id +",";' +
            '  }' +
            '  seatlist += selectedseats[selectedseats.length -1].id;' +
            '  n$.respondExplicit("ticketing-make-reservation",{seatlist});' +
            '});' +

            'document.getElementById("cancelBtn").addEventListener ("click", () => {' +
            '  n$.respondExplicit("ticketing-abort",{});' +
            '});' +

            'document.getElementById("nextBtn").addEventListener ("click", () => {' +
            '  n$.respondExplicit("ticketing-nextSchedule",{});' +
            '});' +

            'document.getElementById("prevBtn").addEventListener ("click", () => {' +
            '  n$.respondExplicit("ticketing-prevSchedule",{});' +
            '});' +

            // 'setInterval (function() {updateSeatReservations();}, 3000);'+

            // ************************************** //
            'function updateSeatReservations() {' +
            '  n$.respondExplicit("ticketing-refresh-timer",{});' +
            '}' +

            'function eventMouseOverSeat() {' +
            '  numberOfSeatsToAllocate = 1;' +
            '  if (document.getElementById("assign_as_group").checked) numberOfSeatsToAllocate = maxSeatsToAllocate;' +

            '  var element = this;' +
            '  var available = 0;' +
            '  for (var i = 1; i <= numberOfSeatsToAllocate; i++) {' +
            '    available += (element.classList.contains ("free_seat")) ? 1 : 0;' +
            '    element = element.nextElementSibling;' +
            '    if (!element) if (i < maxSeatsToAllocate) return;' +
            '  }' +

            '  if (available != numberOfSeatsToAllocate) return;' +

            '  var element = this;' +
            '  for (var i = 0; i < numberOfSeatsToAllocate; i++) {' +
            '    element.classList.add ("seat-highlight");' +
            '    element = element.nextElementSibling;' +
            '  }' +
            '}' +

            'function eventMouseOutSeat() {' +
            '  numberOfSeatsToAllocate = 1;' +
            '  if (document.getElementById("assign_as_group").checked) numberOfSeatsToAllocate = maxSeatsToAllocate;' +
            '  var element = this;' +
            '   for (var i = 0; i < numberOfSeatsToAllocate; i++) {' +
            '    element.classList.remove ("seat-highlight");' +
            '     element = element.nextElementSibling;' +
            '     if (!element) return;' +
            ' }' +
            '}' +

            'function eventMouseClickSeat() {' +

             // Clear current selection
             '  var selectedseats = Array.from (document.getElementsByClassName("seat-selected"));' +
             '  for (var i = 0; i < selectedseats.length; i++) {' +
             '   selectedseats[i].classList.remove ("seat-selected");' +
             '  }' +

             // Assign all seats in grupp selection
             '  if (document.getElementById("assign_as_group").checked) {' +
             '    seatAllocationIndex = 0;' +
             '    var highlightedseats = Array.from (document.getElementsByClassName("seat-highlight"));' +
             '    for (var i = 0; i < highlightedseats.length; i++) {' +
             '      highlightedseats[i].classList.add ("seat-selected");' +
             '      seatsSelected[i] = highlightedseats[i];' +
             '    }' +
             '  }' +

             // Assign seat by seat
             '  if (document.getElementById("assign_as_individual").checked) {' +
             '   var firstSeat = (seatAllocationIndex + maxSeatsToAllocate -1) % maxSeatsToAllocate;' +
             '   if (seatsSelected[firstSeat]) ' +
             '       seatsSelected[firstSeat].classList.remove ("seat-selected");' +
             '   seatsSelected[seatAllocationIndex % maxSeatsToAllocate] = this;' +
             '       seatAllocationIndex++;' +
             '  for (var i = 0; i < maxSeatsToAllocate; i++) ' +
             '        if (seatsSelected[i]) ' +
             '          seatsSelected[i].classList.add ("seat-selected");' +
             '  }' +

             '  if (document.getElementsByClassName("seat-selected").length == maxSeatsToAllocate)' +
             '   document.getElementById("submitBtn").classList.remove ("isDisabled");' +
            '}' +

            // Set quantity of seats to reserve
            'function setSeatsToReserve (seatCount) {' +
            '  maxSeatsToAllocate = seatCount;' +
            '}' +


            // Mark seats already reserved
            'function reserveSeats (csvStringOfElementIds) {' +
            '  var seatIds = csvStringOfElementIds.split('','');' +
            '  for (var i = 0; i < seatIds.length; i++) {' +
            '    reserveSeat(seatIds[i]);' +
            '  }' +
            '}' +

            'function reserveSeat (elementId) {' +
            '  var element = document.getElementById (elementId);' +
            '  element.classList.remove ("free_seat");' +
            '  element.removeEventListener ("mouseover", eventMouseOverSeat);' +
            '  element.removeEventListener ("click", eventMouseClickSeat);' +
            '  element.classList.add ("taken_seat");' +
            '}' +

            // Mark seats as disabled
            'function disableSeats (csvStringOfElementIds) {' +
            '  var seatIds = csvStringOfElementIds.split('','');' +
            '  for (var i = 0; i < seatIds.length; i++) {' +
            '    disableSeat(seatIds[i]);' +
            '  }' +
            '}' +

            'function disableSeat (elementId) {' +
            '  var element = document.getElementById (elementId);' +
            '  element.classList.remove ("free_seat");' +
            '  element.removeEventListener ("mouseover", eventMouseOverSeat);' +
            '  element.removeEventListener ("click", eventMouseClickSeat);' +
            '  element.classList.add ("isDisabled");' +
            '}' +

            // Edit already reserved seats
            'function editReservedSeats (csvStringOfElementIds) {' +
            '  seatAllocationIndex = 0;' +
            '  var seatIds = csvStringOfElementIds.split('','');' +
            '  for (var i = 0; i < seatIds.length; i++) {' +
            '    editReservedSeat (seatIds[i]);' +
            '    seatsSelected[i] = seatIds[i];' +
            '  }' +
            '}' +

            'function editReservedSeat (elementId) {' +
            '  var element = document.getElementById (elementId);' +
            '  element.classList.remove ("taken_seat");' +
            '  element.addEventListener ("mouseover", eventMouseOverSeat);' +
            '  element.addEventListener ("click", eventMouseClickSeat);' +
            '  element.classList.add ("free_seat");' +
            '  element.classList.add ("seat-selected");' +
            '}' +

            CreateInitialSeatReservationList(ExtAdmScheduleEntryNo) +
            GetSeatDisabledList(ExtAdmScheduleEntryNo) +
            GetSeatReservationEditList(EditReservation) +
            StrSubstNo('setSeatsToReserve (%1);', TicketReservationRequest.Quantity) +

          ']]></script>' +

        '</svg>' +
        '</div>';

        exit(SvGText);
    end;

    local procedure Javascript(): Text
    begin
    end;

    local procedure LoadSVGForAdmSchEntry(ExtAdmScheduleEntryNo: Integer) SVG: Text
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        WebClientDependency: Record "NPR Web Client Dependency";
        SeatingSetup: Record "NPR TM Seating Setup";
        SvgCode: Code[10];
        OutStr: OutStream;
    begin

        AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', ExtAdmScheduleEntryNo);
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        AdmissionScheduleEntry.FindFirst();

        SeatingSetup.Get(AdmissionScheduleEntry."Admission Code");
        case SeatingSetup."Template Cache" of
            SeatingSetup."Template Cache"::NO_CACHE:
                SvgCode := '';
            SeatingSetup."Template Cache"::ADMIN:
                SvgCode := CopyStr(AdmissionScheduleEntry."Admission Code", 1, 10);
            SeatingSetup."Template Cache"::SCHEDULE:
                SvgCode := StrSubstNo('%1%2', CopyStr(AdmissionScheduleEntry."Admission Code", 1, 10), CopyStr(AdmissionScheduleEntry."Schedule Code", 1, 5));
            SeatingSetup."Template Cache"::ENTRY:
                SvgCode := StrSubstNo('AS-%1', Format(ExtAdmScheduleEntryNo, 0, 9));
        end;

        if (SvgCode <> '') then
            if (WebClientDependency.Get(WebClientDependency.Type::SVG, SvgCode)) then
                exit(WebClientDependency.GetSvg(SvgCode));

        SVG := CreateSeatingTemplate(ExtAdmScheduleEntryNo);

        if (SvgCode <> '') then begin
            WebClientDependency.Init();
            WebClientDependency.Type := WebClientDependency.Type::SVG;

            WebClientDependency.Code := SvgCode;
            WebClientDependency.Description := StrSubstNo('Entry created at %1', CurrentDateTime());
            WebClientDependency.Insert();

            Clear(WebClientDependency.BLOB);
            WebClientDependency.BLOB.CreateOutStream(OutStr);
            OutStr.WriteText(SVG);
            WebClientDependency.Modify(true);
        end;

        exit(SVG);
    end;

    local procedure UpdateSeatReservationList(ExtAdmScheduleEntryNo: Integer): Text
    begin

        exit(GetSeatReservationList(ExtAdmScheduleEntryNo, ReservationUpdateEntryNo));
    end;

    local procedure CreateInitialSeatReservationList(ExtAdmScheduleEntryNo: Integer): Text
    begin

        exit(GetSeatReservationList(ExtAdmScheduleEntryNo, 0));
    end;

    local procedure GetSeatReservationList(ExtAdmScheduleEntryNo: Integer; ReservationUpdateEntryNo: Integer): Text
    var
        SeatingReservationEntry: Record "NPR TM Seating Reserv. Entry";
        CSV: Text;
    begin

        // 'reservedSeats ("1,2,3,4")
        if (SeatingReservationEntry.SetCurrentKey("External Schedule Entry No.")) then;
        SeatingReservationEntry.SetFilter("External Schedule Entry No.", '=%1', ExtAdmScheduleEntryNo);
        SeatingReservationEntry.SetFilter("Entry No.", '>%1', ReservationUpdateEntryNo);

        if (not SeatingReservationEntry.FindSet()) then
            exit('');

        CSV := StrSubstNo('%1', SeatingReservationEntry.ElementId);

        if (SeatingReservationEntry.Next() <> 0) then
            repeat
                CSV += StrSubstNo(',%1', SeatingReservationEntry.ElementId);
            until (SeatingReservationEntry.Next() = 0);

        ReservationUpdateEntryNo := SeatingReservationEntry."Entry No.";

        exit(StrSubstNo('reserveSeats ("%1");', CSV));
    end;

    local procedure GetSeatReservationEditList(EditMode: Boolean): Text
    var
        SeatingReservationEntry: Record "NPR TM Seating Reserv. Entry";
        CSV: Text;
    begin

        // 'editReservedSeats ("1,2,3,4")
        if (not EditMode) then
            exit('');

        SeatingReservationEntry.SetFilter("Ticket Token", '=%1', TicketReservationRequest."Session Token ID");
        if (not SeatingReservationEntry.FindSet()) then
            exit('');

        CSV := StrSubstNo('%1', SeatingReservationEntry.ElementId);

        if (SeatingReservationEntry.Next() <> 0) then
            repeat
                CSV += StrSubstNo(',%1', SeatingReservationEntry.ElementId);
            until (SeatingReservationEntry.Next() = 0);

        exit(StrSubstNo('editReservedSeats ("%1");', CSV));
    end;

    local procedure GetSeatDisabledList(ExtAdmScheduleEntryNo: Integer): Text
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        SeatingTemplate: Record "NPR TM Seating Template";
        CSV: Text;
    begin

        // 'disabledSeats ("1,2,3,4")

        AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', ExtAdmScheduleEntryNo);
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        AdmissionScheduleEntry.FindFirst();

        SeatingTemplate.SetFilter("Admission Code", '=%1', AdmissionScheduleEntry."Admission Code");
        SeatingTemplate.SetFilter("Entry Type", '=%1', SeatingTemplate."Entry Type"::LEAF);
        SeatingTemplate.SetFilter("Reservation Category", '=%1', SeatingTemplate."Reservation Category"::BLOCKED);
        if (not SeatingTemplate.FindSet()) then
            exit('');

        CSV := StrSubstNo('%1', SeatingTemplate.ElementId);

        if (SeatingTemplate.Next() <> 0) then
            repeat
                CSV += StrSubstNo(',%1', SeatingTemplate.ElementId);
            until (SeatingTemplate.Next() = 0);

        exit(StrSubstNo('disableSeats ("%1");', CSV));
    end;

    local procedure SaveSeatReservation(TicketReservationRequest: Record "NPR TM Ticket Reservation Req."; EventContents: Text)
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        SeatingReservationEntry: Record "NPR TM Seating Reserv. Entry";
        JObject: DotNet NPRNetJObject;
        SeatId: Text;
        SeatList: Text;
    begin

        if (EventContents = '') then
            exit;

        //Name {"seatlist": "xx,xy,..."}
        JObject := JObject.Parse(EventContents);
        SeatList := GetStringValueFromJson(JObject, 'seatlist');

        SeatingReservationEntry.SetCurrentKey("Ticket Token");
        SeatingReservationEntry.SetFilter("Ticket Token", '=%1', TicketReservationRequest."Session Token ID");
        SeatingReservationEntry.DeleteAll();

        repeat
            SeatId := NextElement(SeatList);
            SeatingReservationEntry."Entry No." := 0;
            SeatingReservationEntry."External Schedule Entry No." := TicketReservationRequest."External Adm. Sch. Entry No.";
            Evaluate(SeatingReservationEntry.ElementId, SeatId);
            SeatingReservationEntry."Reservation Status" := SeatingReservationEntry."Reservation Status"::RESERVED;
            SeatingReservationEntry."Ticket Token" := TicketReservationRequest."Session Token ID";
            SeatingReservationEntry."Created At" := CurrentDateTime();

            AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', TicketReservationRequest."External Adm. Sch. Entry No.");
            AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
            AdmissionScheduleEntry.FindFirst();
            SeatingReservationEntry."Admission Code" := AdmissionScheduleEntry."Admission Code";
            SeatingReservationEntry."Schedule Code" := AdmissionScheduleEntry."Schedule Code";

            SeatingReservationEntry.Insert();
        until (SeatList = '');
    end;

    local procedure OnSeatReservationCompleted(Token: Text[100])
    begin
    end;

    local procedure "---"()
    begin
    end;

    local procedure GetStringValueFromJson(JObject: DotNet NPRNetJObject; "Key": Text): Text
    var
        JToken: DotNet NPRNetJToken;
    begin

        JToken := JObject.GetValue(Key);
        if (IsNull(JToken)) then
            exit('');

        exit(JToken.ToString());
    end;

    local procedure NextElement(var VarLineOfText: Text): Text
    begin

        exit(ForwardTokenizer(VarLineOfText, ',', '"'));
    end;

    local procedure ForwardTokenizer(var VarText: Text; PSeparator: Char; PQuote: Char) RField: Text[1024]
    var
        IsQuoted: Boolean;
        InputText: Text[1024];
        NextFieldPos: Integer;
        IsNextField: Boolean;
        NextByte: Text[1];
    begin

        //  This function splits the textline into 2 parts at first occurence of separator
        //  Quotecharacter enables separator to occur inside datablock

        //  example:
        //  23;some text;"some text with a ;";xxxx

        //  result:
        //  1) 23
        //  2) some text
        //  3) some text with a ;
        //  4) xxxx

        //  Quoted text, variable length text tokenizer:
        //  forward searching tokenizer splitting string at separator.
        //  separator is protected by quoting string
        //  the separator is omitted from the resulting strings

        if ((VarText[1] = PQuote) and (StrLen(VarText) = 1)) then begin
            VarText := '';
            RField := '';
            exit(RField);
        end;

        IsQuoted := false;
        NextFieldPos := 1;
        IsNextField := false;

        InputText := VarText;

        if (PQuote = InputText[NextFieldPos]) then IsQuoted := true;
        while ((NextFieldPos <= StrLen(InputText)) and (not IsNextField)) do begin
            if (PSeparator = InputText[NextFieldPos]) then IsNextField := true;
            if (IsQuoted and IsNextField) then IsNextField := (InputText[NextFieldPos - 1] = PQuote);

            NextByte[1] := InputText[NextFieldPos];
            if (not IsNextField) then RField += NextByte;
            NextFieldPos += 1;
        end;
        if (IsQuoted) then RField := CopyStr(RField, 2, StrLen(RField) - 2);

        VarText := CopyStr(InputText, NextFieldPos);
        exit(RField);
    end;

    local procedure "--"()
    begin
    end;

    local procedure CreateSeatingTest(rows: Integer; cols: Integer) SeatText: Text
    var
        a: Integer;
        b: Integer;
        ViewPort: Decimal;
    begin

        ViewPort := cols * 50;
        if (rows > cols) then
            ViewPort := rows * 50;


        // small angle approximation of cos (x) is 1-x*x/2 (radians) in the range 0..1 (0..57 degrees)

        SeatText := StrSubstNo('<svg viewbox="0 0 %1 %1" preserveaspectratio="none">', Format(ViewPort, 0, 9));

        for a := 0 to rows - 1 do begin
            for b := 0 to cols - 1 do begin
                SeatText += CreateSeatWithPreset((b + a * cols + 1), 'free_seat', a, b, cols, rows);
            end;
        end;

        SeatText += '</svg>';
    end;

    local procedure CreateSeatingTemplate(ExtAdmScheduleEntryNo: Integer) SeatText: Text
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        SeatingTemplate: Record "NPR TM Seating Template";
        Row: Integer;
        Col: Integer;
        MaxRows: Integer;
        MaxCols: Integer;
        ViewPort: Decimal;
        ElementId: Integer;
        Middle: Integer;
        HalfScreenTop: Integer;
        HalfScreenBottom: Integer;
        CssClassName: Text;
        SeatSize: Integer;
        ScreenIllustrationHeight: Integer;
    begin

        AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', ExtAdmScheduleEntryNo);
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        AdmissionScheduleEntry.FindFirst();

        SeatingTemplate.SetFilter("Admission Code", '=%1', AdmissionScheduleEntry."Admission Code");
        SeatingTemplate.SetFilter("Entry Type", '=%1', SeatingTemplate."Entry Type"::NODE);
        MaxRows := SeatingTemplate.Count() - 1; // Exclude root node

        SeatingTemplate.SetFilter("Entry Type", '=%1', SeatingTemplate."Entry Type"::LEAF);
        MaxCols := Round(SeatingTemplate.Count() / MaxRows, 1, '>');

        // some magic numbers to create the seats
        SeatSize := 35;

        ViewPort := (MaxCols + 1) * SeatSize;
        if (MaxRows > MaxCols) then
            ViewPort := (MaxRows + 1) * SeatSize;
        // end magic numbers

        SeatText := StrSubstNo('<svg x="%2" viewbox="0 0 %1 %1" preserveaspectratio="none">', Format(ViewPort + 70, 0, 9), Round((800 / (MaxCols * SeatSize) * 35), 1));
        Middle := Round(MaxCols * SeatSize / 2, 1);
        HalfScreenTop := Round(0.75 * Middle, 1);
        HalfScreenBottom := Round(HalfScreenTop * 0.25, 1);
        ScreenIllustrationHeight := Round(ViewPort * 0.05, 1);

        SeatText += StrSubstNo('%1%3%2%3',
          StrSubstNo('<polygon points="%1,%5 %2,%5 %3,%6 %4,%6" style="fill:#000000;stroke:#000000;stroke-width:1"/>',
            Middle - HalfScreenTop + 5,
            Middle + HalfScreenTop + 5,
            Middle + HalfScreenTop - HalfScreenBottom + 5,
            Middle - HalfScreenTop + HalfScreenBottom + 5,
            10, 10 + ScreenIllustrationHeight),

          StrSubstNo('<text x="%1" y="%2" class="btnText12" fill="white" text-anchor="middle" alignment-baseline="middle" >screen</text>',
            Middle + 5,
            Round(10 + (ScreenIllustrationHeight / 2), 1)),

          CRLF());

        SeatingTemplate.SetCurrentKey("Parent Entry No.", Ordinal);
        SeatingTemplate.FindSet();
        Row := 0;
        Col := 0;
        repeat
            ElementId += 1;
            if (SeatingTemplate.ElementId = 0) then begin
                SeatingTemplate.ElementId := ElementId;
                SeatingTemplate.Modify();
            end;
            CssClassName := 'free_seat';
            if (SeatingTemplate."Reservation Category" = SeatingTemplate."Reservation Category"::HIDDEN) then
                CssClassName := 'hidden_seat';

            SeatText += CreateSeatWithPreset(SeatingTemplate.ElementId, CssClassName, Row, Col, MaxCols, MaxRows);

            Col += 1;
            if (Col >= MaxCols) then begin
                Row += 1;
                Col := 0;
            end;

        until (SeatingTemplate.Next() = 0);

        SeatText += '</svg>';
    end;

    local procedure CreateSeatWithPreset(elementId: Integer; cssClassName: Text; a: Integer; b: Integer; cols: Integer; rows: Integer): Text
    var
        width: Integer;
        height: Integer;
        rx: Integer;
        ry: Integer;
    begin

        // some magic numbers to describe the seats
        width := 25;
        height := 25;
        rx := 5;
        ry := 5;

        exit(CreateSeat(elementId, cssClassName, a, b, cols, rows, width, height, rx, ry));
    end;

    local procedure CreateSeat(elementId: Integer; cssClassName: Text; a: Integer; b: Integer; cols: Integer; rows: Integer; width: Integer; height: Integer; rx: Integer; ry: Integer) SeatText: Text
    var
        arcfactor: Decimal;
        v: Decimal;
        x: Decimal;
        y: Decimal;
    begin

        // small angle approximation of cos (x) is 1-x*x/2 (radians) in the range 0..1 (0..57 degrees)
        v := (b + 0.5 - cols / 2) / (cols / 2) / ((a + height) / height);
        arcfactor := (1 - v * v / 2) * height * 3;

        // calculate (x,y) position for seat. (offset + seat size + spacing)
        x := 5 + b * width + b * 10;
        y := 25 + a * height + a * 10 + arcfactor;

        SeatText += StrSubstNo('<rect %1 %2 %3 %4 %5 %6 stroke="black"/>%7',
          StrSubstNo('class="%1"', cssClassName),
          StrSubstNo('id="%1"', Format(elementId, 0, 9)),
          StrSubstNo('x="%1" y="%2"', Format(Round(x, 1), 0, 9), Format(Round(y, 1), 0, 9)),
          StrSubstNo('rx="%1" ry="%2"', rx, ry),
          StrSubstNo('width="%1" height="%2"', width, height),
          StrSubstNo('transform="rotate(%1 %2,%3)"', Format(Round(v / 2 / 3.14 * 360, 1) * -1, 0, 9), Format(Round(x + width / 2, 1), 0, 9), Format(Round(y + height / 2, 1), 0, 9)), // rad to deg
          CRLF());
    end;

    local procedure CRLF() CRLF: Text[2]
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
    end;

}

