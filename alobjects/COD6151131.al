codeunit 6151131 "TM Seating UI"
{
    // TM1.43/TSA /20190617 CASE 357359 Initial Version
    // 
    // ##### SINGLE INSTANCE #####

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        Model: DotNet npNetModel;
        ActiveModelID: Guid;
        Iteration: Integer;
        ReservationUpdateEntryNo: Integer;
        ShowExtAdmSchEntryNo: Integer;

    local procedure ConstructUI(ExtAdmScheduleEntryNo: Integer): Boolean
    var
        AdmissionScheduleEntry: Record "TM Admission Schedule Entry";
    begin

        AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', ExtAdmScheduleEntryNo);
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (not AdmissionScheduleEntry.FindFirst()) then
            exit(false);

        exit(ConstructUIWorker(AdmissionScheduleEntry."Admission Code", AdmissionScheduleEntry."Schedule Code", ExtAdmScheduleEntryNo));
    end;

    local procedure ConstructUIWorker(AdmissionCode: Code[20]; ScheduleCode: Code[20]; ExtAdmScheduleEntryNo: Integer): Boolean
    var
        Admission: Record "TM Admission";
        Schedule: Record "TM Admission Schedule";
        AdmissionSchedule: Record "TM Admission Schedule Lines";
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

    procedure ShowSelectSeatUI(POSFrontEnd: Codeunit "POS Front End Management"; Token: Text[100])
    var
        TmpSeatingReservationEntry: Record "TM Seating Reservation Entry" temporary;
        ShowUI: Boolean;
    begin

        // Asynchrounous
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindSet()) then
            repeat
                ShowUI := ShowUIAdmissionScheduleEntry(POSFrontEnd, TicketReservationRequest."External Adm. Sch. Entry No.");
            until (ShowUI or (TicketReservationRequest.Next() = 0));
    end;

    procedure ShowUIAdmissionScheduleEntry(POSFrontEnd: Codeunit "POS Front End Management"; ExtAdmScheduleEntryNo: Integer): Boolean
    var
        AdmissionScheduleEntry: Record "TM Admission Schedule Entry";
    begin

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
        AdmissionScheduleEntry: Record "TM Admission Schedule Entry";
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
        AdmissionScheduleEntry: Record "TM Admission Schedule Entry";
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
    local procedure OnUIResponse(POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; ModelID: Guid; Sender: Text; EventName: Text; var Handled: Boolean)
    var
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        ResponseMessage: Text;
        ResponseCode: Integer;
        seatNo: Integer;
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
                            ShowUI := ShowUIAdmissionScheduleEntry(FrontEnd, ShowExtAdmSchEntryNo);
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
        Admission: Record "TM Admission";
        AdmissionScheduleEntry: Record "TM Admission Schedule Entry";
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
            '.btnText {font: bold 20px sans-serif; fill: black;}' +
            '.isDisabled { opacity: 0.5; cursor: not-allowed; }' +
          '</style>' +

          '<polygon points="150,10 450,10 400,50 200,50" style="fill:#eeeeee;stroke:#999999;stroke-width:1"/>' +
          '<text x="300" y="30" fill=white text-anchor="middle" alignment-baseline="middle">screen</text>' +

          '<svg height="800">' +
          LoadSVGForAdmSchEntry(ExtAdmScheduleEntryNo) +
          '</svg>' +

          '<line x1="0" y1="0" x2="1200" y2="800" style="stroke:rgb(255,0,0);stroke-width:2" />' +
          '<line x1="0" y1="0" x2="0" y2="100%" style="stroke:rgb(255,0,0);stroke-width:2" />' +

          '<foreignObject x="0" y="520" width="200" height="150">' +
          '  <body xmlns="http://www.w3.org/1999/xhtml">' +
          '    <form class="btnText" >' +
          '     <input type="radio" name="assignment" id="assign_as_group" checked>Group<br>' +
          '   <input type="radio" name="assignment" id="assign_as_individual">Individuals' +
          '    </form>' +
          '  </body>' +
          '</foreignObject>' +

          '<a href="#" id="submitBtn">' +
          '  <rect x="400" y="900" rx="10" ry="10" height="60" width="140" fill="#00b2ff" stroke="black" />' +
          '  <text x="470" y="930" class="btnText" text-anchor="middle" alignment-baseline="middle">Reserve</text>' +
          '</a>' +

          '<a href="#" id="cancelBtn">' +
          '  <rect x="100" y="900" rx="10" ry="10" height="60" width="140" fill="#00b2ff" stroke="black" />' +
          '  <text x="170" y="930" class="btnText" text-anchor="middle" alignment-baseline="middle">Cancel</text>' +
          '</a>' +

          '<a href="#" id="prevBtn">' +
          '  <rect x="100" y="1000" rx="10" ry="10" height="30" width="140" fill="#00b2ff" stroke="black" />' +
          '  <text x="170" y="1017" class="btnText" text-anchor="middle" alignment-baseline="middle">Previous</text>' +
          '</a>' +

          '<a href="#" id="nextBtn">' +
          '  <rect x="400" y="1000" rx="10" ry="10" height="30" width="140" fill="#00b2ff" stroke="black" />' +
          '  <text x="470" y="1017" class="btnText" text-anchor="middle" alignment-baseline="middle">Next</text>' +
          '</a>' +

          StrSubstNo('<text x="300" y="1060" class="btnText" text-anchor="middle" alignment-baseline="middle">%1 - <%2> %3 - %4</text>',
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

            'setInterval (function() {updateSeatReservations();}, 3000);' +

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

            'function reserveSeats (csvStringOfElementIds) {' +
            '  var seatIds = csvStringOfElementIds.split('','');' +
            '  for (var i = 0; i < seatIds.length; i++) {' +
            '    reserveSeat(seatIds[i]);' +
            '  }' +

            '}' +

            'function setSeatsToReserve (seatCount) {' +
            '  maxSeatsToAllocate = seatCount;' +
            '}' +

            'function reserveSeat (elementId) {' +
            '  var element = document.getElementById (elementId);' +
            '  element.classList.remove ("free_seat");' +
            '  element.removeEventListener ("mouseover", eventMouseOverSeat);' +
            '  element.removeEventListener ("click", eventMouseClickSeat);' +
            '  element.classList.add ("taken_seat");' +
            '}' +

            CreateInitialSeatReservationList(ExtAdmScheduleEntryNo) +
            StrSubstNo('setSeatsToReserve (%1);', TicketReservationRequest.Quantity) +

          ']]></script>' +

        '</svg>' +
        '</div>';

        exit(SvGText);
    end;

    local procedure Javascript() JsText: Text
    begin

        //JsText := 'ticket-seating-main ()';
        //JsText += 'setInterval(function() { $("#npr-refresh-timer").click(); }, 250);';
    end;

    local procedure LoadSVGForAdmSchEntry(ExtAdmScheduleEntryNo: Integer) SVG: Text
    begin

        exit(CreateSeatingTest(50, 5));
    end;

    local procedure UpdateSeatReservationList(ExtAdmScheduleEntryNo: Integer) JavaScriptFunction: Text
    begin

        exit(GetSeatReservationList(ExtAdmScheduleEntryNo, ReservationUpdateEntryNo));
    end;

    local procedure CreateInitialSeatReservationList(ExtAdmScheduleEntryNo: Integer) JavaScriptFunction: Text
    begin

        exit(GetSeatReservationList(ExtAdmScheduleEntryNo, 0));
    end;

    local procedure GetSeatReservationList(ExtAdmScheduleEntryNo: Integer; ReservationUpdateEntryNo: Integer) JavaScriptFunction: Text
    var
        SeatingReservationEntry: Record "TM Seating Reservation Entry";
        CSV: Text;
    begin

        // 'reserveSeats ("1,2,3,4")
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

    local procedure SaveSeatReservation(TicketReservationRequest: Record "TM Ticket Reservation Request"; EventContents: Text)
    var
        AdmissionScheduleEntry: Record "TM Admission Schedule Entry";
        SeatingReservationEntry: Record "TM Seating Reservation Entry";
        JObject: DotNet npNetJObject;
        ElementId: Integer;
        SeatId: Text;
        SeatList: Text;
    begin

        if (EventContents = '') then
            exit;

        //Name {"seatlist": "xx,xy,..."}
        JObject := JObject.Parse(EventContents);
        SeatList := GetStringValueFromJson(JObject, 'seatlist');

        repeat
            SeatId := NextElement(SeatList);
            SeatingReservationEntry."Entry No." := 0;
            SeatingReservationEntry."External Schedule Entry No." := TicketReservationRequest."External Adm. Sch. Entry No.";
            Evaluate(SeatingReservationEntry.ElementId, SeatId);
            SeatingReservationEntry."Reservation Status" := SeatingReservationEntry."Reservation Status"::RESERVED;
            SeatingReservationEntry."Ticket Token" := TicketReservationRequest."Session Token ID";
            SeatingReservationEntry."Created At" := CurrentDateTime();
            SeatingReservationEntry.Insert();
        until (SeatList = '');
    end;

    local procedure OnSeatReservationCompleted(Token: Text[100])
    begin
    end;

    local procedure "---"()
    begin
    end;

    local procedure GetStringValueFromJson(JObject: DotNet npNetJObject; "Key": Text): Text
    var
        JToken: DotNet npNetJToken;
    begin

        JToken := JObject.GetValue(Key);
        if (IsNull(JToken)) then
            exit('');

        exit(JToken.ToString());
    end;

    local procedure NextElement(var VarLineOfText: Text) rField: Text
    begin

        exit(ForwardTokenizer(VarLineOfText, ',', '"'));
    end;

    local procedure ForwardTokenizer(var VarText: Text; PSeparator: Char; PQuote: Char) RField: Text[1024]
    var
        Separator: Char;
        Quote: Char;
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
        width: Integer;
        height: Integer;
        rx: Integer;
        ry: Integer;
        a: Integer;
        b: Integer;
        arcfactor: Decimal;
        v: Decimal;
        x: Decimal;
        y: Decimal;
    begin

        width := 25;
        height := 25;
        rx := 5;
        ry := 5;

        // small angle approximation of cos (x) is 1-x*x/2 (radians) in the range 0..1 (0..57 degrees)


        for a := 0 to rows - 1 do begin
            for b := 0 to cols - 1 do begin
                v := (b + 0.5 - cols / 2) / (cols / 2) / ((a + height) / height);
                arcfactor := (1 - v * v / 2) * height * 5;

                //x := 50 + b*width + b*10;
                x := b * width + b * 10;
                y := 50 + a * height + a * 10 + arcfactor;

                SeatText += StrSubstNo('<rect class="free_seat" id="%1" x="%2" y="%3" rx="%4" ry="%5" width="%6" height="%7" transform="%8" stroke="black"/>',
                  b + a * cols + 1,
                  Round(x, 1),
                  Round(y, 1),
                  rx,
                  ry,
                  width,
                  height,
                  StrSubstNo('rotate(%1 %2,%3)', Round(v / 2 / 3.14 * 360, 1) * -1, Round(x + width / 2, 1), Round(y + height / 2, 1)) // rad to deg
                )
            end;
        end;
    end;

}

