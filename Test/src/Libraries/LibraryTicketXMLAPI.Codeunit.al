codeunit 85012 "NPR Library - Ticket XML API"
{
    procedure MakeReservation(OrderCount: Integer; ItemNumber: Code[20]; Quantity: Integer; MemberReference: Code[20]; ScannerStation: Code[10]; var Token: Text[100]; var ResponseMessage: Text): Boolean
    var
        TmpBLOBbuffer: Record "NPR BLOB buffer" temporary;
        TicketAdmissionBOM: Record "NPR TM Ticket Admission BOM";
        TicketWebService: Codeunit "NPR TM Ticket WebService";
        MakeReservation: XMLport "NPR TM Ticket Reservation";
        IStream: InStream;
        OrderNumber: Integer;
        OStream: OutStream;
        NameSpace: Text;
        XmlAsText: Text;
        ReservationStatus: Boolean;
        XmlDec: XmlDeclaration;
        XmlDoc: XmlDocument;
        Reservation: XmlElement;
        TicketAdmission: XmlElement;
        Tickets: XmlElement;
        XMLNameSpace: XmlNamespaceManager;
    begin

        TicketAdmissionBOM.SetFilter("Item No.", '=%1', ItemNumber);

        NameSpace := 'urn:microsoft-dynamics-nav/xmlports/x6060114';

        XMLDoc := XmlDocument.Create();
        XMLDec := XmlDeclaration.Create('1.0', 'utf-8', 'yes');
        XMLDoc.SetDeclaration(XMLDec);

        Reservation := XmlElement.Create('reserve_tickets', NameSpace);
        Reservation.SetAttribute('token', '');

        for OrderNumber := 1 to OrderCount do begin
            TicketAdmissionBOM.FINDSET();
            repeat
                TicketAdmission := XmlElement.Create('ticket', NameSpace);
                TicketAdmission.SetAttribute('external_id', ItemNumber);
                TicketAdmission.SetAttribute('line_no', Format(OrderNumber));
                TicketAdmission.SetAttribute('qty', Format(Quantity));
                TicketAdmission.SetAttribute('admission_schedule_entry', Format(0));
                if (MemberReference <> '') then
                    TicketAdmission.SetAttribute('member_number', MemberReference);
                TicketAdmission.SetAttribute('admission_code', TicketAdmissionBOM."Admission Code");

                Reservation.Add(TicketAdmission);
            until (TicketAdmissionBOM.Next() = 0);

        end;
        Tickets := XmlElement.Create('tickets', NameSpace);
        Tickets.Add(Reservation);

        XmlDoc.Add(Tickets);
        XmlDoc.WriteTo(XmlAsText);

        TmpBLOBbuffer.Insert();
        TmpBLOBbuffer."Buffer 1".CreateOutStream(OStream);
        OStream.WriteText(XmlAsText);
        TmpBLOBbuffer.Modify();

        TmpBLOBbuffer."Buffer 1".CreateInStream(IStream);
        MakeReservation.SetSource(IStream);

        TicketWebService.MakeTicketReservation(MakeReservation, ScannerStation);

        ReservationStatus := MakeReservation.GetResult(Token, ResponseMessage);
        exit(ReservationStatus);

    end;

    procedure PreConfirmTicketReservation(Token: Text[100]; ScannerStation: Code[10]; var ResponseMessage: Text) PreConfirmationStatus: Boolean
    var
        TmpBLOBbuffer: Record "NPR BLOB buffer" temporary;
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
        Ticket: Record "NPR TM Ticket";
        TicketWebService: Codeunit "NPR TM Ticket WebService";
        PreConfirmReservation: XMLport "NPR TM Ticket PreConfirm";
        IStream: InStream;
        OrderNumber: Integer;
        OStream: OutStream;
        NameSpace: Text;
        XmlAsText: Text;
        ApiOk: Boolean;

        XmlDec: XmlDeclaration;
        XmlDoc: XmlDocument;
        TicketTokens: XmlElement;
        Tickets: XmlElement;
        XMLNameSpace: XmlNamespaceManager;
    begin

        if (Token = '') then begin
            ResponseMessage := 'Token must not be blank.';
            exit(false);
        end;

        NameSpace := 'urn:microsoft-dynamics-nav/xmlports/x6060115';

        XMLDoc := XmlDocument.Create();
        XMLDec := XmlDeclaration.Create('1.0', 'utf-8', 'yes');
        XMLDoc.SetDeclaration(XMLDec);

        TicketTokens := XmlElement.Create('ticket_tokens', NameSpace);
        TicketTokens.Add(AddElement('ticket_token', Token, NameSpace));

        Tickets := XmlElement.Create('tickets', NameSpace);
        Tickets.Add(TicketTokens);

        XmlDoc.Add(Tickets);
        XmlDoc.WriteTo(XmlAsText);

        TmpBLOBbuffer.Insert();
        TmpBLOBbuffer."Buffer 1".CreateOutStream(OStream);
        OStream.WriteText(XmlAsText);
        TmpBLOBbuffer.Modify();

        TmpBLOBbuffer."Buffer 1".CreateInStream(IStream);
        PreConfirmReservation.SetSource(IStream);

        TicketWebService.PreConfirmTicketReservation(PreConfirmReservation, ScannerStation);

        TicketReservationResponse.SetFilter("Session Token ID", '=%1', Token);
        ResponseMessage := 'There was a problem with Pre-Confirm Ticket Reservation.';
        ApiOk := TicketReservationResponse.FindFirst();
        if (ApiOK) then
            ApiOk := TicketReservationResponse.Status;

        exit(ApiOk);
    end;

    procedure ConfirmTicketReservation(Token: Text[100]; SendNotificationTo: Text; ExternalOrderNo: Text; ScannerStation: Code[20]; var TmpResultingTickets: Record "NPR TM Ticket" temporary; var ResponseMessage: Text) ConfirmationStatus: Boolean
    var
        TmpBLOBbuffer: Record "NPR BLOB buffer" temporary;
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
        Ticket: Record "NPR TM Ticket";
        TicketWebService: Codeunit "NPR TM Ticket WebService";
        ConfirmReservation: XMLport "NPR TM Ticket Confirmation";
        IStream: InStream;
        OrderNumber: Integer;
        OStream: OutStream;
        NameSpace: Text;
        XmlAsText: Text;
        ReservationStatus: Boolean;
        XmlDec: XmlDeclaration;
        XmlDoc: XmlDocument;
        TicketTokens: XmlElement;
        Tickets: XmlElement;
        XMLNameSpace: XmlNamespaceManager;
    begin

        if (Token = '') then begin
            ResponseMessage := 'Token must not be blank.';
            exit(false);
        end;

        NameSpace := 'urn:microsoft-dynamics-nav/xmlports/x6060117';

        XMLDoc := XmlDocument.Create();
        XMLDec := XmlDeclaration.Create('1.0', 'utf-8', 'yes');
        XMLDoc.SetDeclaration(XMLDec);

        TicketTokens := XmlElement.Create('ticket_tokens', NameSpace);
        TicketTokens.Add(AddElement('ticket_token', Token, NameSpace));

        if (SendNotificationTo <> '') then
            TicketTokens.Add(AddElement('send_notification_to', SendNotificationTo, NameSpace));
        if (ExternalOrderNo <> '') then
            TicketTokens.Add(AddElement('external_order_no', ExternalOrderNo, NameSpace));

        Tickets := XmlElement.Create('tickets', NameSpace);
        Tickets.Add(TicketTokens);

        XmlDoc.Add(Tickets);
        XmlDoc.WriteTo(XmlAsText);

        TmpBLOBbuffer.Insert();
        TmpBLOBbuffer."Buffer 1".CreateOutStream(OStream);
        OStream.WriteText(XmlAsText);
        TmpBLOBbuffer.Modify();

        TmpBLOBbuffer."Buffer 1".CreateInStream(IStream);
        ConfirmReservation.SetSource(IStream);

        TicketWebService.ConfirmTicketReservation(ConfirmReservation, ScannerStation);

        ResponseMessage := 'There was a problem with Confirm Ticket Reservation.';
        ConfirmationStatus := false;

        TicketReservationResponse.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationResponse.FindSet()) then begin
            repeat

                if (TicketReservationResponse.Confirmed) then begin
                    Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationResponse."Request Entry No.");
                    if (Ticket.FindSet()) then begin
                        repeat
                            TmpResultingTickets.TransferFields(Ticket, true);
                            TmpResultingTickets.Insert();
                        until (Ticket.Next() = 0);

                        ResponseMessage := '';
                        ConfirmationStatus := true;

                    end else
                        ResponseMessage := TicketReservationResponse."Response Message";

                end;
            until (TicketReservationResponse.Next() = 0);
        end;


        exit(ConfirmationStatus);

    end;


    procedure CancelTicketReservation(Token: Text[100]; ScannerStation: Code[20]; var ResponseMessage: Text) CancelStatus: Boolean
    var
        TmpBLOBbuffer: Record "NPR BLOB buffer" temporary;
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
        Ticket: Record "NPR TM Ticket";
        TicketWebService: Codeunit "NPR TM Ticket WebService";
        CancelReservation: XMLport "NPR TM Ticket Cancel";
        IStream: InStream;
        OrderNumber: Integer;
        OStream: OutStream;
        NameSpace: Text;
        XmlAsText: Text;
        ReservationStatus: Boolean;
        XmlDec: XmlDeclaration;
        XmlDoc: XmlDocument;

        TicketTokens: XmlElement;
        Tickets: XmlElement;
        XMLNameSpace: XmlNamespaceManager;
    begin

        if (Token = '') then begin
            ResponseMessage := 'Token must not be blank.';
            exit(false);
        end;

        NameSpace := 'urn:microsoft-dynamics-nav/xmlports/x6060116';

        XMLDoc := XmlDocument.Create();
        XMLDec := XmlDeclaration.Create('1.0', 'utf-8', 'yes');
        XMLDoc.SetDeclaration(XMLDec);

        TicketTokens := XmlElement.Create('ticket_tokens', NameSpace);
        TicketTokens.Add(AddElement('ticket_token', Token, NameSpace));

        Tickets := XmlElement.Create('tickets', NameSpace);
        Tickets.Add(TicketTokens);

        XmlDoc.Add(Tickets);
        XmlDoc.WriteTo(XmlAsText);

        TmpBLOBbuffer.Insert();
        TmpBLOBbuffer."Buffer 1".CreateOutStream(OStream);
        OStream.WriteText(XmlAsText);
        TmpBLOBbuffer.Modify();

        TmpBLOBbuffer."Buffer 1".CreateInStream(IStream);
        CancelReservation.SetSource(IStream);

        TicketWebService.CancelTicketReservation(CancelReservation, ScannerStation);

        TicketReservationResponse.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationResponse.SetFilter(Canceled, '=%1', false);
        CancelStatus := TicketReservationResponse.IsEmpty();

        if (not CancelStatus) then
            ResponseMessage := 'There was a problem with Cancel Ticket Reservation.';

        exit(CancelStatus);

    end;


    procedure GetTicketsPrintURL(var TmpTickets: Record "NPR TM Ticket" temporary; var ResponseMessage: Text): Boolean
    var
        TmpBLOBbuffer: Record "NPR BLOB buffer" temporary;
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
        TicketWebService: Codeunit "NPR TM Ticket WebService";
        GetTicketPrintURL: XMLport "NPR TM Ticket Get Print URL";
        IStream: InStream;
        OrderNumber: Integer;
        OStream: OutStream;
        NameSpace: Text;
        XmlAsText: Text;
        ReservationStatus: Boolean;
        XmlDec: XmlDeclaration;
        XmlDoc: XmlDocument;

        PrintRequest: XmlElement;
        Ticket: XmlElement;
        Tickets: XmlElement;
    begin

        TmpTickets.FindSet();

        NameSpace := 'urn:microsoft-dynamics-nav/xmlports/x6060122';

        XMLDoc := XmlDocument.Create();
        XMLDec := XmlDeclaration.Create('1.0', 'utf-8', 'yes');
        XMLDoc.SetDeclaration(XMLDec);

        PrintRequest := XmlElement.Create('print_request', NameSpace);
        repeat
            Ticket := XmlElement.Create('ticket', NameSpace);
            Ticket.SetAttribute('ticket_number', TmpTickets."External Ticket No.");
            PrintRequest.Add(Ticket)
        until (TmpTickets.Next() = 0);

        Tickets := XmlElement.Create('tickets', NameSpace);
        Tickets.Add(PrintRequest);

        XmlDoc.Add(Tickets);
        XmlDoc.WriteTo(XmlAsText);

        TmpBLOBbuffer.Insert();
        TmpBLOBbuffer."Buffer 1".CreateOutStream(OStream);
        OStream.WriteText(XmlAsText);
        TmpBLOBbuffer.Modify();

        TmpBLOBbuffer."Buffer 1".CreateInStream(IStream);
        GetTicketPrintURL.SetSource(IStream);

        TicketWebService.GetTicketPrintUrl(GetTicketPrintURL);
        exit(true);
    end;

    procedure OfflineTicketValidation(var TmpTickets: Record "NPR TM Ticket" temporary; ImportRefName: Text[20]; var ResponseMessage: Text): Boolean
    var
        TmpBLOBbuffer: Record "NPR BLOB buffer" temporary;
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
        TicketWebService: Codeunit "NPR TM Ticket WebService";
        OfflineTicketValidation: XMLport "NPR TM Offline Ticket Valid.";
        IStream: InStream;
        OrderNumber: Integer;
        OStream: OutStream;
        NameSpace: Text;
        XmlAsText: Text;
        ReservationStatus: Boolean;
        XmlDec: XmlDeclaration;
        XmlDoc: XmlDocument;

        ValidateOffline: XmlElement;
        Element: XmlElement;
        Tickets: XmlElement;
    begin

        TmpTickets.FindSet();

        NameSpace := 'urn:microsoft-dynamics-nav/xmlports/x6060109';

        XMLDoc := XmlDocument.Create();
        XMLDec := XmlDeclaration.Create('1.0', 'utf-8', 'yes');
        XMLDoc.SetDeclaration(XMLDec);

        Tickets := XmlElement.Create('tickets', NameSpace);

        TmpTickets.Reset();
        TmpTickets.FindSet();
        repeat
            ValidateOffline := XmlElement.Create('validate_offline', NameSpace);

            Element := AddElement('ticket_reference', TmpTickets."External Ticket No.", NameSpace);
            Element.SetAttribute('type', 'Ticket No.');
            ValidateOffline.Add(Element);

            Element := AddElement('member_reference', '', NameSpace);
            Element.SetAttribute('type', '');
            ValidateOffline.Add(Element);

            ValidateOffline.Add(AddElement('admission_code', '', NameSpace));

            Element := XmlElement.Create('admission_at', NameSpace);
            Element.SetAttribute('date', Format(Today(), 0, 9));
            Element.SetAttribute('time', Format(Time(), 0, 9));
            ValidateOffline.Add(Element);

            ValidateOffline.Add(AddElement('external_reference', ImportRefName, NameSpace));
            Tickets.Add(ValidateOffline);

        until (TmpTickets.Next() = 0);

        XmlDoc.Add(Tickets);
        XmlDoc.WriteTo(XmlAsText);

        TmpBLOBbuffer.Insert();
        TmpBLOBbuffer."Buffer 1".CreateOutStream(OStream);
        OStream.WriteText(XmlAsText);
        TmpBLOBbuffer.Modify();

        TmpBLOBbuffer."Buffer 1".CreateInStream(IStream);
        OfflineTicketValidation.SetSource(IStream);

        exit(TicketWebService.OfflineTicketValidation(OfflineTicketValidation));

    end;

    procedure ListTicketItems(var TmpTicketItems: Record "Item Variant" temporary): Boolean
    var
        TmpBLOBbuffer: Record "NPR BLOB buffer" temporary;
        TicketWebService: Codeunit "NPR TM Ticket WebService";
        IStream: InStream;
        OStream: OutStream;
        NameSpace: Text;
        XmlAsText: Text;
        ApiStatus: Boolean;
        XmlDec: XmlDeclaration;
        XmlDoc: XmlDocument;

        ListTicketItems: XMLport "NPR TM List Ticket Items";
        RequestElement: XmlElement;
    begin

        NameSpace := 'urn:microsoft-dynamics-nav/xmlports/x6060112';

        XMLDoc := XmlDocument.Create();
        XMLDec := XmlDeclaration.Create('1.0', 'utf-8', 'yes');
        XMLDoc.SetDeclaration(XMLDec);

        RequestElement := XmlElement.Create('ticket_items', NameSpace);
        XmlDoc.Add(RequestElement);
        XmlDoc.WriteTo(XmlAsText);

        TmpBLOBbuffer.Insert();
        TmpBLOBbuffer."Buffer 1".CreateOutStream(OStream);
        OStream.WriteText(XmlAsText);
        TmpBLOBbuffer.Modify();

        TmpBLOBbuffer."Buffer 1".CreateInStream(IStream);
        ListTicketItems.SetSource(IStream);

        TicketWebService.ListTicketItems(ListTicketItems);

        ListTicketItems.GetResponse(TmpTicketItems);
        exit(not TmpTicketItems.IsEmpty());

    end;



    procedure AdmissionCapacityCheck(AdmissionCode: Code[20]; ReferenceDate: Date; ReferenceItemNo: Code[20]; var TmpAdmScheduleEntryResponseOut: Record "NPR TM Admis. Schedule Entry" temporary): Boolean
    var
        TmpBLOBbuffer: Record "NPR BLOB buffer" temporary;
        TicketWebService: Codeunit "NPR TM Ticket WebService";
        IStream: InStream;
        OStream: OutStream;
        NameSpace: Text;
        XmlAsText: Text;
        ApiStatus: Boolean;
        XmlDec: XmlDeclaration;
        XmlDoc: XmlDocument;

        AdmissionCheckCapacity: XMLport "NPR TM Admis. Capacity Check";
        AdmissionElement: XmlElement;
        RequestElement: XmlElement;
        CapacityElement: XmlElement;
    begin

        NameSpace := 'urn:microsoft-dynamics-nav/xmlports/x6060113';

        XMLDoc := XmlDocument.Create();
        XMLDec := XmlDeclaration.Create('1.0', 'utf-8', 'yes');
        XMLDoc.SetDeclaration(XMLDec);

        AdmissionElement := XmlElement.Create('admission_schedule_entry', NameSpace);
        AdmissionElement.SetAttribute('admission_code', AdmissionCode);
        AdmissionElement.SetAttribute('reference_date', Format(ReferenceDate, 0, 9));
        AdmissionElement.SetAttribute('external_item_number', ReferenceItemNo);

        RequestElement := XmlElement.Create('request', NameSpace);
        RequestElement.Add(AdmissionElement);

        CapacityElement := XmlElement.Create('admission_capacity', NameSpace);
        CapacityElement.Add(RequestElement);

        XmlDoc.Add(CapacityElement);
        XmlDoc.WriteTo(XmlAsText);

        TmpBLOBbuffer.Insert();
        TmpBLOBbuffer."Buffer 1".CreateOutStream(OStream);
        OStream.WriteText(XmlAsText);
        TmpBLOBbuffer.Modify();

        TmpBLOBbuffer."Buffer 1".CreateInStream(IStream);
        AdmissionCheckCapacity.SetSource(IStream);

        TicketWebService.GetAdmissionCapacity(AdmissionCheckCapacity);

        ApiStatus := AdmissionCheckCapacity.GetResponse(TmpAdmScheduleEntryResponseOut);
        exit(ApiStatus);

    end;


    procedure ValidateTicketArrival(ExternalTicketNo: Code[20]; AdmissionCode: Code[20]; ScannerStation: Code[20]; var ResponseMessage: Text): Boolean
    var
        TicketWebService: Codeunit "NPR TM Ticket WebService";
    begin
        exit(TicketWebService.ValidateTicketArrival(AdmissionCode, ExternalTicketNo, ScannerStation, ResponseMessage));
    end;

    procedure ValidateTicketDeparture(ExternalTicketNo: Code[20]; AdmissionCode: Code[20]; ScannerStation: Code[20]; var ResponseMessage: Text): Boolean
    var
        TicketWebService: Codeunit "NPR TM Ticket WebService";
    begin
        exit(TicketWebService.ValidateTicketDeparture(AdmissionCode, ExternalTicketNo, ScannerStation, ResponseMessage));
    end;

    procedure ListDetails_Ticket(ExternalTicketNo: Code[20]; var TmpTicketsOut: Record "NPR TM Ticket" temporary): Boolean
    begin
        exit(ListDetails('TICKET', ExternalTicketNo, TmpTicketsOut));
    end;

    procedure ListDetails_Token(Token: Text[100]; var TmpTicketsOut: Record "NPR TM Ticket" temporary): Boolean
    begin
        exit(ListDetails('TOKEN', Token, TmpTicketsOut));
    end;

    local procedure ListDetails(FilterType: Code[20]; FilterValue: Text; var TmpTicketsOut: Record "NPR TM Ticket" temporary): Boolean
    var
        TmpBLOBbuffer: Record "NPR BLOB buffer" temporary;
        TicketWebService: Codeunit "NPR TM Ticket WebService";
        IStream: InStream;
        OStream: OutStream;
        NameSpace: Text;
        XmlAsText: Text;
        ApiStatus: Boolean;
        XmlDec: XmlDeclaration;
        XmlDoc: XmlDocument;

        TicketElement: XmlElement;
        RequestElement: XmlElement;
        DetailsElement: XmlElement;
        TicketDetails: XmlPort "NPR TM Ticket Details";
    begin

        NameSpace := 'urn:microsoft-dynamics-nav/xmlports/x6060120';

        XMLDoc := XmlDocument.Create();
        XMLDec := XmlDeclaration.Create('1.0', 'utf-8', 'yes');
        XMLDoc.SetDeclaration(XMLDec);

        TicketElement := XmlElement.Create('ticket', NameSpace);
        TicketElement.SetAttribute('filter_type', FilterType);
        TicketElement.SetAttribute('full_history', 'true');
        TicketElement.Add(AddElement('filter', FilterValue, NameSpace));

        RequestElement := XmlElement.Create('ticket_request', NameSpace);
        RequestElement.Add(TicketElement);

        DetailsElement := XmlElement.Create('ticketdetails', NameSpace);
        DetailsElement.Add(RequestElement);

        XmlDoc.Add(DetailsElement);
        XmlDoc.WriteTo(XmlAsText);

        TmpBLOBbuffer.Insert();
        TmpBLOBbuffer."Buffer 1".CreateOutStream(OStream);
        OStream.WriteText(XmlAsText);
        TmpBLOBbuffer.Modify();

        TmpBLOBbuffer."Buffer 1".CreateInStream(IStream);
        TicketDetails.SetSource(IStream);

        TicketWebService.ListTickets(TicketDetails);
        TicketDetails.GetResponse(TmpTicketsOut);

        exit(not TmpTicketsOut.IsEmpty());
    end;


    local procedure MyProcedure()
    begin

    end;

    procedure GetTicketChangeRequest(ExternalTicketNo: Code[20]; PinCode: Code[10]; var TokenOut: Text[100]; var TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary; var ResponseMessage: Text): Boolean
    var
        TmpBLOBbuffer: Record "NPR BLOB buffer" temporary;
        TicketWebService: Codeunit "NPR TM Ticket WebService";
        IStream: InStream;
        OStream: OutStream;
        NameSpace: Text;
        XmlAsText: Text;
        ApiStatus: Boolean;
        XmlDec: XmlDeclaration;
        XmlDoc: XmlDocument;

        RequestElement: XmlElement;
        ChangeElement: XmlElement;
        TicketsElement: XmlElement;
        ChangeTicketRequest: XmlPort "NPR TM Ticket Change Request";
    begin
        NameSpace := 'urn:microsoft-dynamics-nav/xmlports/x6060107';

        XMLDoc := XmlDocument.Create();
        XMLDec := XmlDeclaration.Create('1.0', 'utf-8', 'yes');
        XMLDoc.SetDeclaration(XMLDec);

        RequestElement := XmlElement.Create('Request', NameSpace);
        RequestElement.Add(AddElement('TicketNumber', ExternalTicketNo, NameSpace));
        RequestElement.Add(AddElement('PinCode', PinCode, NameSpace));

        ChangeElement := XmlElement.Create('ChangeReservation', NameSpace);
        ChangeElement.Add(RequestElement);

        TicketsElement := XmlElement.Create('Tickets', NameSpace);
        TicketsElement.Add(ChangeElement);

        XmlDoc.Add(TicketsElement);
        XmlDoc.WriteTo(XmlAsText);

        TmpBLOBbuffer.Insert();
        TmpBLOBbuffer."Buffer 1".CreateOutStream(OStream);
        OStream.WriteText(XmlAsText);
        TmpBLOBbuffer.Modify();

        TmpBLOBbuffer."Buffer 1".CreateInStream(IStream);
        ChangeTicketRequest.SetSource(IStream);
        TicketWebService.GetTicketChangeRequest(ChangeTicketRequest);

        ApiStatus := ChangeTicketRequest.GetChangeRequest(TmpTicketReservationRequest, ResponseMessage);
        if (ApiStatus) then begin
            TmpTicketReservationRequest.FindFirst();
            TokenOut := TmpTicketReservationRequest."Session Token ID";
        end;

        exit(ApiStatus);
    end;

    procedure ConfirmChangeTicketReservation(ChangeToken: Text[100]; var TmpCurrentRequest: Record "NPR TM Ticket Reservation Req." temporary; var TmpTargetRequest: Record "NPR TM Ticket Reservation Req." temporary; var TmpTicketReservationResponse: Record "NPR TM Ticket Reserv. Resp." temporary; var ResponseMessage: Text): Boolean
    var
        TmpBLOBbuffer: Record "NPR BLOB buffer" temporary;
        TicketWebService: Codeunit "NPR TM Ticket WebService";
        IStream: InStream;
        OStream: OutStream;
        NameSpace: Text;
        XmlAsText: Text;
        ApiStatus: Boolean;
        XmlDec: XmlDeclaration;
        XmlDoc: XmlDocument;

        RequestElement: XmlElement;
        AdmissionElement: XmlElement;
        Admissions: XmlElement;
        ConfirmElement: XmlElement;
        TicketsElement: XmlElement;
        ConfirmTicketRequest: XmlPort "NPR TM Ticket Conf. Change Req";
    begin

        TmpTargetRequest.Reset();

        NameSpace := 'urn:microsoft-dynamics-nav/xmlports/x6060108';

        XMLDoc := XmlDocument.Create();
        XMLDec := XmlDeclaration.Create('1.0', 'utf-8', 'yes');
        XMLDoc.SetDeclaration(XMLDec);

        Admissions := XmlElement.Create('Admissions', NameSpace);

        TmpTargetRequest.FindSet();
        repeat
            if (TmpCurrentRequest.Get(TmpTargetRequest."Entry No.")) then begin
                AdmissionElement := XmlElement.Create('Admission', NameSpace);
                AdmissionElement.SetAttribute('Code', TmpTargetRequest."Admission Code");
                AdmissionElement.SetAttribute('OldScheduleEntryNo', Format(TmpCurrentRequest."External Adm. Sch. Entry No.", 0, 9));
                AdmissionElement.SetAttribute('NewScheduleEntryNo', Format(TmpTargetRequest."External Adm. Sch. Entry No.", 0, 9));
                Admissions.Add(AdmissionElement);
            end;
        until (TmpTargetRequest.Next() = 0);

        RequestElement := XmlElement.Create('Request', NameSpace);
        RequestElement.Add(AddElement('ChangeRequestToken', ChangeToken, NameSpace));
        RequestElement.Add(Admissions);

        ConfirmElement := XmlElement.Create('ConfirmChangeReservation', NameSpace);
        ConfirmElement.Add(RequestElement);

        TicketsElement := XmlElement.Create('Tickets', NameSpace);
        TicketsElement.Add(ConfirmElement);

        XmlDoc.Add(TicketsElement);
        XmlDoc.WriteTo(XmlAsText);

        TmpBLOBbuffer.Insert();
        TmpBLOBbuffer."Buffer 1".CreateOutStream(OStream);
        OStream.WriteText(XmlAsText);
        TmpBLOBbuffer.Modify();

        TmpBLOBbuffer."Buffer 1".CreateInStream(IStream);
        ConfirmTicketRequest.SetSource(IStream);
        TicketWebService.ConfirmTicketChangeRequest(ConfirmTicketRequest);

        ApiStatus := ConfirmTicketRequest.GetConfirmResponse(TmpTicketReservationResponse, ResponseMessage);
        exit(ApiStatus);


    end;

    procedure SetTicketAttribute(Token: Text[100]; AdmissionCodeArray: array[10] of Code[20]; AttributeCodeArray: array[10] of Code[10]; ValueArray: array[10] of Text[100]; var ResponseMessage: Text): Boolean
    var
        TmpBLOBbuffer: Record "NPR BLOB buffer" temporary;
        TicketWebService: Codeunit "NPR TM Ticket WebService";
        IStream: InStream;
        OStream: OutStream;
        NameSpace: Text;
        XmlAsText: Text;
        ApiStatus: Boolean;
        XmlDec: XmlDeclaration;
        XmlDoc: XmlDocument;

        TicketsElement: XmlElement;
        SetAttributesElement: XmlElement;
        AttributesElement: XmlElement;
        Attribute: XmlElement;
        NAttributeCode: Integer;
        SetTicketAttribute: XmlPort "NPR TM Ticket Set Attr.";
    begin
        NameSpace := 'urn:microsoft-dynamics-nav/xmlports/x6060121';

        XMLDoc := XmlDocument.Create();
        XMLDec := XmlDeclaration.Create('1.0', 'utf-8', 'yes');
        XMLDoc.SetDeclaration(XMLDec);

        SetAttributesElement := XmlElement.Create('setattributes', NameSpace);
        SetAttributesElement.SetAttribute('token', Token);

        AttributesElement := XmlElement.Create('attributes', NameSpace);
        for NAttributeCode := 1 to System.ArrayLen(AttributeCodeArray) do begin
            if (AttributeCodeArray[NAttributeCode] <> '') then begin
                Attribute := XmlElement.Create('attribute', NameSpace);
                Attribute.SetAttribute('admission_code', AdmissionCodeArray[NAttributeCode]);
                Attribute.SetAttribute('attribute_code', AttributeCodeArray[NAttributeCode]);
                Attribute.SetAttribute('attribute_value', ValueArray[NAttributeCode]);
                AttributesElement.Add(Attribute);
            end;
        end;
        SetAttributesElement.Add(AttributesElement);

        TicketsElement := XmlElement.Create('tickets', NameSpace);
        TicketsElement.Add(SetAttributesElement);

        XmlDoc.Add(TicketsElement);
        XmlDoc.WriteTo(XmlAsText);

        TmpBLOBbuffer.Insert();
        TmpBLOBbuffer."Buffer 1".CreateOutStream(OStream);
        OStream.WriteText(XmlAsText);
        TmpBLOBbuffer.Modify();

        TmpBLOBbuffer."Buffer 1".CreateInStream(IStream);
        SetTicketAttribute.SetSource(IStream);
        ApiStatus := TicketWebService.SetReservationAttributes(SetTicketAttribute);
        if (not ApiStatus) then
            SetTicketAttribute.GetResponseMessage(ResponseMessage);

        exit(ApiStatus);
    end;


    procedure SendETicket(Token: Text[100]; var ResponseMessage: Text) Status: Boolean
    var
        TmpBLOBbuffer: Record "NPR BLOB buffer" temporary;
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
        Ticket: Record "NPR TM Ticket";
        TicketWebService: Codeunit "NPR TM Ticket WebService";
        SendETicket: XMLport "NPR TM Send eTicket";
        IStream: InStream;
        OrderNumber: Integer;
        OStream: OutStream;
        NameSpace: Text;
        XmlAsText: Text;
        ReservationStatus: Boolean;
        XmlDec: XmlDeclaration;
        XmlDoc: XmlDocument;

        TicketTokens: XmlElement;
        Tickets: XmlElement;
        XMLNameSpace: XmlNamespaceManager;
    begin

        if (Token = '') then begin
            ResponseMessage := 'Token must not be blank.';
            exit(false);
        end;

        NameSpace := 'urn:microsoft-dynamics-nav/xmlports/x6060124';

        XMLDoc := XmlDocument.Create();
        XMLDec := XmlDeclaration.Create('1.0', 'utf-8', 'yes');
        XMLDoc.SetDeclaration(XMLDec);

        TicketTokens := XmlElement.Create('ticket_tokens', NameSpace);
        TicketTokens.Add(AddElement('ticket_token', Token, NameSpace));

        Tickets := XmlElement.Create('tickets', NameSpace);
        Tickets.Add(TicketTokens);

        XmlDoc.Add(Tickets);
        XmlDoc.WriteTo(XmlAsText);

        TmpBLOBbuffer.Insert();
        TmpBLOBbuffer."Buffer 1".CreateOutStream(OStream);
        OStream.WriteText(XmlAsText);
        TmpBLOBbuffer.Modify();

        TmpBLOBbuffer."Buffer 1".CreateInStream(IStream);
        SendETicket.SetSource(IStream);

        TicketWebService.SendETicket(SendETicket);
        ReservationStatus := SendETicket.GetResponse(ResponseMessage)

    end;



    local procedure AddElement(Name: Text; ElementValue: Text; XmlNs: Text): XmlElement
    var
        Element: XmlElement;
    begin
        Element := XmlElement.Create(Name, XmlNs);
        Element.Add(ElementValue);
        exit(Element);
    end;

}
