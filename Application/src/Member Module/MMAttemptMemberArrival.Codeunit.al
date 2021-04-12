codeunit 6014492 "NPR MM Attempt Member Arrival"
{
    trigger OnRun()
    begin

        if (_FunctionOption = _FunctionOption::AttemptArrival) then begin
            _ResponseCode := DoAttemptMemberArrival(_TicketItemNo, _AdmissionCode, _ScannerStationId, _Member, _ResponseMessage);
        end;

        if (_FunctionOption = _FunctionOption::AttemptArrivalBatch) then begin
            _ResponseCode := DoAttemptMemberArrival(_MemberInfoCapture, _AdmissionCode, _ScannerStationId, _ResponseMessage);
        end;

    end;

    var
        _FunctionOption: Option NotSet,AttemptArrival,IssueTicket,AttemptArrivalBatch;
        _TicketItemNo: Code[50];
        _AdmissionCode: Code[20];
        _ScannerStationId: Code[10];
        _Member: Record "NPR MM Member";
        _MemberInfoCapture: Record "NPR MM Member Info Capture";
        _ResponseMessage: Text;
        _ResponseCode: Integer;

    procedure AttemptMemberArrival(TicketItemNo: Code[50]; AdmissionCode: Code[20]; ScannerStationId: Code[10]; Member: Record "NPR MM Member")
    var
    begin
        _FunctionOption := _FunctionOption::AttemptArrival;
        _TicketItemNo := TicketItemNo;
        _AdmissionCode := AdmissionCode;
        _ScannerStationId := ScannerStationId;
        _Member.Copy(Member);
        _ResponseCode := -2; // When DoAttemptMemberArrival() throws error
        _ResponseMessage := 'Member Arrival Attempt failed with error.';
    end;

    procedure AttemptMemberArrival(var MemberInfoCapture: Record "NPR MM Member Info Capture"; AdmissionCode: Code[20]; ScannerStationId: Code[10])
    var
    begin
        _FunctionOption := _FunctionOption::AttemptArrivalBatch;
        _MemberInfoCapture.Copy(MemberInfoCapture);
        _AdmissionCode := AdmissionCode;
        _ScannerStationId := ScannerStationId;
    end;

    procedure GetAttemptMemberArrivalResponse(var ResponseMessage: Text) ResponseCode: Integer
    begin
        ResponseMessage := _ResponseMessage;

        if (_ResponseCode = -2) then
            ResponseMessage := GetLastErrorText();

        exit(_ResponseCode);
    end;

    local procedure DoAttemptMemberArrival(var MemberInfoCapture: Record "NPR MM Member Info Capture"; AdmissionCode: Code[20]; ScannerStationId: Code[10]; var ResponseMessage: Text) ResponseCode: Integer
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        Member: Record "NPR MM Member";
    begin

        if (not MemberInfoCapture.HasFilter()) then
            Error('No filter attached on MemberInfoCapture when attempting to AttemptArrivalBatch (Programming Error).');

        MemberInfoCapture.FindSet();
        repeat
            Clear(Member);
            if (Member.Get(MemberInfoCapture."Member Entry No")) then
                MemberInfoCapture."External Member No" := Member."External Member No.";

            MembershipSetup.Get(MemberInfoCapture."Membership Code");
            MembershipSetup.TestField("Ticket Item Barcode");

            ResponseCode := DoAttemptMemberArrival(MembershipSetup."Ticket Item Barcode", AdmissionCode, ScannerStationId, Member, ResponseMessage);
            if (ResponseCode <> 0) then
                Error(ResponseMessage);

        until (MemberInfoCapture.Next() = 0);

        exit(0); // Success

    end;

    local procedure DoAttemptMemberArrival(TicketItemNo: Code[50]; AdmissionCode: Code[20]; ScannerStationId: Code[10]; Member: Record "NPR MM Member"; var ResponseMessage: Text) ResponseCode: Integer
    var
        Ticket: Record "NPR TM Ticket";
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        TicketMgr: Codeunit "NPR TM Ticket Management";
        VariantCode: Code[10];
        ItemNo: Code[20];
        TicketNo: Code[20];
        ResolvingTable: Integer;
        NEW_MEMBER_TICKET: Label 'Ticket %1 for admission %2 was created for member %3.';
        MEMBER_TICKET: Label 'Ticket %1 for admission %2 was reused for member %3.';
        Token: Text[100];
    begin

        if (not (MemberRetailIntegration.TranslateBarcodeToItemVariant(TicketItemNo, ItemNo, VariantCode, ResolvingTable))) then begin
            ResponseMessage := StrSubstNo('%1 does not translate to an item. Check Item Cross-Reference or Item table.', TicketItemNo);
            exit(-1);
        end;

        Ticket.SetCurrentKey("External Member Card No.");
        Ticket.SetFilter("Item No.", '=%1', ItemNo);
        Ticket.SetFilter("Variant Code", '=%1', VariantCode);
        Ticket.SetFilter("Document Date", '=%', Today);

        Ticket.SetFilter("External Member Card No.", '=%1', Member."External Member No.");
        if (Ticket.FindLast()) then begin

            if (TicketMgr.AttemptValidateTicketForArrival(0, Ticket."No.", AdmissionCode, -1, ResponseMessage)) then begin

                if (AdmissionCode = '') then
                    AdmissionCode := '-default-';

                ResponseMessage := StrSubstNo(MEMBER_TICKET, Ticket."No.", AdmissionCode, Member."External Member No.");

                exit(0);
            end;
        end;

        if (not TicketMakeReservation(TicketItemNo, AdmissionCode, Member."External Member No.", ScannerStationId, Token, ResponseMessage)) then
            exit(-1);

        if (not (TicketConfirmReservation(Token, ScannerStationId, TicketNo, ResponseMessage))) then
            exit(-1);

        Ticket.Get(TicketNo);
        TicketMgr.ValidateTicketForArrival(0, TicketNo, AdmissionCode, -1);

        if (AdmissionCode = '') then
            AdmissionCode := '-default-';

        ResponseMessage := StrSubstNo(NEW_MEMBER_TICKET, TicketNo, AdmissionCode, Member."External Member No.");
        exit(ResponseCode);

    end;

    local procedure TicketMakeReservation(ExternalItemNumber: Code[50]; AdmissionCode: Code[20]; MemberReference: Code[20]; ScannerStation: Code[10]; var Token: Text[100]; var ResponseMessage: Text) ReservationStatus: Boolean
    var
        xmltext: Text;
        TmpBLOBbuffer: Record "NPR BLOB buffer" temporary;
        iStream: InStream;
        oStream: OutStream;
        TicketReservation: XMLport "NPR TM Ticket Reservation";
        TicketWebService: Codeunit "NPR TM Ticket WebService";
    begin

        xmltext :=
        '<?xml version="1.0" encoding="UTF-8" standalone="no"?>' +
        '<tickets xmlns="urn:microsoft-dynamics-nav/xmlports/x6060114">' +
        '   <reserve_tickets token="">' +
        StrSubstNo('       <ticket external_id="%1" line_no="1" qty="1" admission_schedule_entry="0" member_number="%2" admission_code="%3"/>', ExternalItemNumber, MemberReference, AdmissionCode) +
        '   </reserve_tickets>' +
        '</tickets>';

        TmpBLOBbuffer.Insert();
        TmpBLOBbuffer."Buffer 1".CreateOutStream(oStream);
        oStream.WriteText(xmltext);
        TmpBLOBbuffer.Modify();

        TmpBLOBbuffer."Buffer 1".CreateInStream(iStream);
        TicketReservation.SetSource(iStream);
        TicketReservation.Import();

        TicketWebService.MakeTicketReservation(TicketReservation, ScannerStation);

        ReservationStatus := TicketReservation.GetResult(Token, ResponseMessage);

        exit(ReservationStatus);

    end;

    local procedure TicketConfirmReservation(Token: Text[100]; ScannerStation: Code[10]; var TicketNumber: Code[20]; var ResponseMessage: Text) ConfirmationStatus: Boolean
    var
        xmltext: Text;
        TmpBLOBbuffer: Record "NPR BLOB buffer" temporary;
        iStream: InStream;
        oStream: OutStream;
        TicketWebService: Codeunit "NPR TM Ticket WebService";
        TicketConfirmation: XMLport "NPR TM Ticket Confirmation";
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
        Ticket: Record "NPR TM Ticket";
    begin

        xmltext :=
        '<?xml version="1.0" encoding="UTF-8" standalone="no"?>' +
        '<tickets xmlns="urn:microsoft-dynamics-nav/xmlports/x6060117">' +
        '  <ticket_tokens>' +
        StrSubstNo('      <ticket_token>%1</ticket_token>', Token) +
        '      <send_notification_to></send_notification_to>' +
        '      <external_order_no>prepaid</external_order_no>' +
        '  </ticket_tokens>' +
        '</tickets>';

        TmpBLOBbuffer.Insert();
        TmpBLOBbuffer."Buffer 1".CreateOutStream(oStream);
        oStream.WriteText(xmltext);
        TmpBLOBbuffer.Modify();

        TmpBLOBbuffer."Buffer 1".CreateInStream(iStream);
        TicketConfirmation.SetSource(iStream);
        TicketConfirmation.Import();

        ConfirmationStatus := TicketWebService.ConfirmTicketReservation(TicketConfirmation, ScannerStation);

        ResponseMessage := 'There was a problem with Confirm Ticket Reservation.';
        TicketReservationResponse.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationResponse.FindFirst()) then begin

            if (TicketReservationResponse.Confirmed) then begin
                Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationResponse."Request Entry No.");
                if (Ticket.FindFirst()) then
                    TicketNumber := Ticket."No.";
                ResponseMessage := '';
                ConfirmationStatus := true;
            end else begin
                ResponseMessage := TicketReservationResponse."Response Message";
                ConfirmationStatus := false;
            end;
        end;

        exit(ConfirmationStatus);

    end;

}