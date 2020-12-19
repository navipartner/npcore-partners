codeunit 6060115 "NPR TM Ticket WebService"
{

    trigger OnRun()
    begin
    end;

    var
        TicketIdentifierType: Option INTERNAL_TICKET_NO,EXTERNAL_TICKET_NO,PRINTED_TICKET_NO;
        SETUP_MISSING: Label 'Setup is missing for %1';

    procedure ValidateTicketArrival(AdmissionCode: Code[20]; ExternalTicketNo: Text[50]; ScannerStationId: Code[10]; var MessageText: Text): Boolean
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
    begin
        exit(TicketManagement.AttemptValidateTicketForArrival(TicketIdentifierType::EXTERNAL_TICKET_NO, ExternalTicketNo, AdmissionCode, -1, MessageText));
    end;

    procedure ValidateTicketDeparture(AdmissionCode: Code[20]; ExternalTicketNo: Text[50]; ScannerStationId: Code[10]; var MessageText: Text): Boolean
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
    begin
        TicketManagement.ValidateTicketForDeparture(TicketIdentifierType::EXTERNAL_TICKET_NO, ExternalTicketNo, AdmissionCode);
        exit(true);
    end;

    procedure MakeTicketReservation(var Reservation: XMLport "NPR TM Ticket Reservation"; ScannerStationId: Code[10])
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
    begin

        Reservation.Import;

        InsertImportEntry('MakeTicketReservation', ImportEntry);
        ImportEntry."Document ID" := Reservation.GetToken();
        if (ImportEntry."Document ID" = '') then
            ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

        ImportEntry."Document Name" := StrSubstNo('TicketReservation-%1-%2.xml', ImportEntry."Document ID", Reservation.GetSummary());
        ImportEntry."Sequence No." := GetDocumentSequence(ImportEntry."Document ID");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Reservation.SetDestination(OutStr);
        Reservation.Export;
        ImportEntry.Modify(true);
        Commit();

        NaviConnectSyncMgt.ProcessImportEntry(ImportEntry);

        ImportEntry.Get(ImportEntry."Entry No.");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        if (not ImportEntry.Imported) then begin
            Reservation.SetErrorResult(ImportEntry."Document ID", ImportEntry."Error Message");
        end else begin
            Reservation.SetReservationResult(ImportEntry."Document ID");
        end;

        Reservation.SetDestination(OutStr);
        Reservation.Export;
        ImportEntry.Modify(true);
        Commit;

    end;

    procedure PreConfirmTicketReservation(var PreConfirm: XMLport "NPR TM Ticket PreConfirm"; ScannerStationId: Code[10])
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
    begin

        PreConfirm.Import;

        InsertImportEntry('PreConfirmReservation', ImportEntry);
        ImportEntry."Document ID" := PreConfirm.GetToken();
        if (ImportEntry."Document ID" = '') then
            ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

        ImportEntry."Document Name" := StrSubstNo('TicketPreConfirm-%1-%2.xml', ImportEntry."Document ID", PreConfirm.GetSummary());
        ImportEntry."Sequence No." := GetDocumentSequence(ImportEntry."Document ID");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        PreConfirm.SetDestination(OutStr);
        PreConfirm.Export;

        ImportEntry.Modify(true);

        Commit();
        NaviConnectSyncMgt.ProcessImportEntry(ImportEntry);

        ImportEntry.Get(ImportEntry."Entry No.");
        PreConfirm.SetReservationResult(ImportEntry."Document ID", ImportEntry.Imported);
    end;

    procedure CancelTicketReservation(var Cancelation: XMLport "NPR TM Ticket Cancel"; ScannerStationId: Code[10])
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
    begin

        Cancelation.Import;

        InsertImportEntry('CancelReservation', ImportEntry);
        ImportEntry."Document ID" := Cancelation.GetToken();
        if (ImportEntry."Document ID" = '') then
            ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

        ImportEntry."Document Name" := StrSubstNo('TicketCancelation-%1-%2.xml', ImportEntry."Document ID", Cancelation.GetSummary());
        ImportEntry."Sequence No." := GetDocumentSequence(ImportEntry."Document ID");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Cancelation.SetDestination(OutStr);
        Cancelation.Export;
        ImportEntry.Modify(true);
        Commit();


        NaviConnectSyncMgt.ProcessImportEntry(ImportEntry);
        ImportEntry.Get(ImportEntry."Entry No.");

        Cancelation.SetReservationResult(ImportEntry."Document ID", ImportEntry.Imported);

        //-TM1.48 [414413]
        ImportEntry.Imported := true;
        ImportEntry."Document Source".CreateOutStream(OutStr);
        Cancelation.SetDestination(OutStr);
        Cancelation.Export;

        ImportEntry.Modify(true);
        //-TM1.48 [414413]
    end;

    procedure ConfirmTicketReservation(var Confirmation: XMLport "NPR TM Ticket Confirmation"; ScannerStationId: Code[10]) Success: Boolean
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
    begin

        Confirmation.Import;

        InsertImportEntry('ConfirmReservation', ImportEntry);
        ImportEntry."Document ID" := Confirmation.GetToken();
        if (ImportEntry."Document ID" = '') then
            ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

        ImportEntry."Document Name" := StrSubstNo('TicketConfirmation-%1-%2.xml', ImportEntry."Document ID", Confirmation.GetSummary());
        ImportEntry."Sequence No." := GetDocumentSequence(ImportEntry."Document ID");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Confirmation.SetDestination(OutStr);
        Confirmation.Export;
        ImportEntry.Modify(true);
        Commit();

        NaviConnectSyncMgt.ProcessImportEntry(ImportEntry);
        ImportEntry.Get(ImportEntry."Entry No.");
        if (not ImportEntry.Imported) then
            Error(ImportEntry."Error Message");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Confirmation.SetReservationResult(ImportEntry."Document ID");
        Confirmation.SetDestination(OutStr);
        Confirmation.Export;
        ImportEntry.Modify(true);
        Commit;

        exit(true);
    end;

    procedure GetTicketChangeRequest(VAR TicketChangeRequest: XMLport "NPR TM Ticket Change Request");
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
    begin

        TicketChangeRequest.IMPORT();
        InsertImportEntry('GetTicketChangeRequest', ImportEntry);

        ImportEntry."Document ID" := UPPERCASE(DELCHR(FORMAT(CREATEGUID), '=', '{}-'));
        ImportEntry."Document Name" := STRSUBSTNO('GetTicketChangeRequest-%1.xml', ImportEntry."Document ID");
        ImportEntry."Sequence No." := GetDocumentSequence(ImportEntry."Document ID");

        ImportEntry."Document Source".CREATEOUTSTREAM(OutStr);
        TicketChangeRequest.SETDESTINATION(OutStr);
        TicketChangeRequest.EXPORT;
        ImportEntry.MODIFY(TRUE);

        COMMIT();
        NaviConnectSyncMgt.ProcessImportEntry(ImportEntry);

        ImportEntry.GET(ImportEntry."Entry No.");
        if (ImportEntry.Imported) then begin
            TicketChangeRequest.SetChangeRequestId(ImportEntry."Document ID");
        end else begin
            ImportEntry.Imported := TRUE;
            ImportEntry."Runtime Error" := TRUE;
            TicketChangeRequest.SetError(ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CREATEOUTSTREAM(OutStr);
        TicketChangeRequest.SETDESTINATION(OutStr);
        TicketChangeRequest.EXPORT;
        ImportEntry.MODIFY(TRUE);
    end;

    procedure ConfirmTicketChangeRequest(VAR TicketConfChangeRequest: XMLport "NPR TM Ticket Conf. Change Req");
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
    begin

        TicketConfChangeRequest.IMPORT();
        InsertImportEntry('ConfirmTicketChangeRequest', ImportEntry);

        ImportEntry."Document ID" := TicketConfChangeRequest.GetToken();
        ImportEntry."Document Name" := STRSUBSTNO('ConfirmTicketChangeRequest-%1.xml', ImportEntry."Document ID");
        ImportEntry."Sequence No." := GetDocumentSequence(ImportEntry."Document ID");

        ImportEntry."Document Source".CREATEOUTSTREAM(OutStr);
        TicketConfChangeRequest.SETDESTINATION(OutStr);
        TicketConfChangeRequest.EXPORT;
        ImportEntry.MODIFY(TRUE);

        COMMIT();
        NaviConnectSyncMgt.ProcessImportEntry(ImportEntry);

        ImportEntry.GET(ImportEntry."Entry No.");
        if (ImportEntry.Imported) then begin
            TicketConfChangeRequest.SetChangeRequestId(ImportEntry."Document ID");
        end else begin
            ImportEntry.Imported := TRUE;
            ImportEntry."Runtime Error" := TRUE;
            TicketConfChangeRequest.SetError(ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CREATEOUTSTREAM(OutStr);
        TicketConfChangeRequest.SETDESTINATION(OutStr);
        TicketConfChangeRequest.EXPORT;
        ImportEntry.MODIFY(TRUE);

    end;

    procedure MakeTicketReservationConfirmAndValidateArrival(var Reservation: XMLport "NPR TM Ticket Reserv.AndArrive"; ScannerStationId: Code[10])
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
    begin

        Reservation.Import;

        InsertImportEntry('ReserveConfirmArrive', ImportEntry);
        ImportEntry."Document ID" := Reservation.GetToken();
        if (ImportEntry."Document ID" = '') then
            ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

        ImportEntry."Document Name" := StrSubstNo('ReserveConfirmArrive-%1-%2.xml', ImportEntry."Document ID", Reservation.GetSummary());
        ImportEntry."Sequence No." := GetDocumentSequence(ImportEntry."Document ID");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Reservation.SetDestination(OutStr);
        Reservation.Export;

        ImportEntry.Modify(true);

        Commit();
        NaviConnectSyncMgt.ProcessImportEntry(ImportEntry);

        ImportEntry.Get(ImportEntry."Entry No.");
        if (not ImportEntry.Imported) then
            Error(ImportEntry."Error Message");

        Reservation.SetReservationResult(ImportEntry."Document ID");
    end;

    procedure RevokeTicketReservation()
    begin
    end;

    procedure GetComplementaryMembershipItemNo(ExternalTicketNo: Code[20]; var ComplementaryItemNo: Code[20]) Success: Integer
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
        Ticket: Record "NPR TM Ticket";
        TicketType: Record "NPR TM Ticket Type";
        ReasonText: Text;
    begin

        Ticket.SetFilter("External Ticket No.", '=%1', ExternalTicketNo);
        if (not Ticket.FindFirst()) then
            exit(-10);

        if (Ticket.Blocked) then
            exit(-13);

        if (not TicketType.Get(Ticket."Ticket Type Code")) then
            exit(-11);

        if (ComplementaryItemNo = '') then begin

            if (TicketType."Membership Sales Item No." = '') then
                exit(-12);

            ComplementaryItemNo := TicketType."Membership Sales Item No.";
        end;

        if (not TicketManagement.CheckIfCanBeConsumed(Ticket."No.", '', ComplementaryItemNo, ReasonText)) then begin
            ComplementaryItemNo := '';
            exit(-20);
        end;
        exit(1);

    end;

    procedure ConsumeComplementaryItem(ExternalTicketNo: Code[20]; var ComplementaryItemNo: Code[20]) Success: Integer
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
        Ticket: Record "NPR TM Ticket";
        TicketType: Record "NPR TM Ticket Type";
        ReasonText: Text;
    begin

        Ticket.SetFilter("External Ticket No.", '=%1', ExternalTicketNo);
        if (not Ticket.FindFirst()) then
            exit(-10);

        if (Ticket.Blocked) then
            exit(-13);

        if (not TicketType.Get(Ticket."Ticket Type Code")) then
            exit(-11);

        if (ComplementaryItemNo = '') then begin
            if (TicketType."Membership Sales Item No." = '') then
                exit(-12);

            ComplementaryItemNo := TicketType."Membership Sales Item No.";

        end;

        TicketManagement.CheckAndConsumeItem(Ticket."No.", '', ComplementaryItemNo, ReasonText);
        exit(1);

    end;

    procedure OfflineTicketValidation(var OfflineTicketValidation: XMLport "NPR TM Offline Ticket Valid.") Success: Boolean
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
    begin

        OfflineTicketValidation.Import;

        InsertImportEntry('OfflineTicketValidation', ImportEntry);
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

        ImportEntry."Document Name" := StrSubstNo('OfflineTicketValidation-%1.xml', ImportEntry."Document ID");
        ImportEntry."Sequence No." := GetDocumentSequence(ImportEntry."Document ID");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        OfflineTicketValidation.SetDestination(OutStr);
        OfflineTicketValidation.Export;
        ImportEntry.Modify(true);
        Commit();

        OfflineTicketValidation.ProcessImportedRecords();

        Commit;
        exit(true);
    end;

    procedure SetReservationAttributes(var Attributes: XMLport "NPR TM Ticket Set Attr.") Success: Boolean
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
    begin

        Attributes.Import;

        InsertImportEntry('SetAttributes', ImportEntry);
        ImportEntry."Document ID" := Attributes.GetToken();
        if (ImportEntry."Document ID" = '') then
            ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

        ImportEntry."Document Name" := StrSubstNo('SetAttributes-%1.xml', ImportEntry."Document ID");
        ImportEntry."Sequence No." := GetDocumentSequence(ImportEntry."Document ID");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Attributes.SetDestination(OutStr);
        Attributes.Export;
        ImportEntry.Modify(true);
        Commit();

        NaviConnectSyncMgt.ProcessImportEntry(ImportEntry);

        ImportEntry.Get(ImportEntry."Entry No.");
        Attributes.SetResult(ImportEntry.Imported, ImportEntry."Document ID", ImportEntry."Error Message");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Attributes.SetDestination(OutStr);
        Attributes.Export;
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := false;
        ImportEntry.Modify(true);
        Commit();

        exit(true);
    end;

    procedure GetAdmissionCapacity(var AdmissionCapacityCheck: XMLport "NPR TM Admis. Capacity Check")
    begin

        AdmissionCapacityCheck.Import;
        AdmissionCapacityCheck.AddResponse();

    end;

    procedure GetTicketPrintUrl(var TicketGetTicketPrintURL: XMLport "NPR TM Ticket Get Print URL")
    begin

        TicketGetTicketPrintURL.Import();
        TicketGetTicketPrintURL.CreateResponse();
    end;

    procedure ListTickets(var TicketDetails: XMLport "NPR TM Ticket Details")
    begin

        TicketDetails.Import;
        TicketDetails.CreatResponse();

    end;

    procedure SendETicket(var SendETicket: XMLport "NPR TM Send eTicket")
    begin

        SendETicket.Import();
        SendETicket.CreateResponse();

    end;

    procedure ListTicketItems(var ListTicketItems: XMLport "NPR TM List Ticket Items")
    begin

        ListTicketItems.CreateResponse();

    end;

    local procedure InsertImportEntry(WebserviceFunction: Text; var ImportEntry: Record "NPR Nc Import Entry")
    var
        NaviConnectSetupMgt: Codeunit "NPR Nc Setup Mgt.";
    begin

        ImportEntry.Init;
        ImportEntry."Entry No." := 0;
        ImportEntry."Import Type" := GetImportTypeCode(CODEUNIT::"NPR TM Ticket WebService", WebserviceFunction);
        if (ImportEntry."Import Type" = '') then begin
            TicketIntegrationSetup();
            ImportEntry."Import Type" := GetImportTypeCode(CODEUNIT::"NPR TM Ticket WebService", WebserviceFunction);
            if (ImportEntry."Import Type" = '') then
                Error(SETUP_MISSING, WebserviceFunction);
        end;

        ImportEntry.Date := CurrentDateTime;
        ImportEntry."Document Name" := StrSubstNo('%1-%2.xml', ImportEntry."Import Type", Format(ImportEntry.Date, 0, 9));
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := false;
        ImportEntry.Insert(true);
    end;

    local procedure GetDocumentSequence(DocumentID: Text[100]) SequenceNo: Integer
    var
        ImportEntry: Record "NPR Nc Import Entry";
    begin

        if (DocumentID = '') then
            exit(1);

        ImportEntry.SetCurrentKey("Document ID");
        ImportEntry.SetFilter("Document ID", '=%1', DocumentID);
        if (not ImportEntry.FindLast()) then
            exit(1);

        exit(ImportEntry."Sequence No." + 1);
    end;

    local procedure InitSetup(): Text
    begin
    end;

    local procedure TicketIntegrationSetup()
    var
        ImportType: Record "NPR Nc Import Type";
    begin

        ImportType.SetFilter("Webservice Codeunit ID", '=%1', CODEUNIT::"NPR TM Ticket WebService");
        if (not ImportType.IsEmpty()) then
            ImportType.DeleteAll();

        CreateImportType('TICKET-01', 'Ticket reservation', 'MakeTicketReservation');
        CreateImportType('TICKET-02', 'Ticket reservation', 'PreConfirmReservation');
        CreateImportType('TICKET-03', 'Ticket reservation', 'CancelReservation');
        CreateImportType('TICKET-04', 'Ticket reservation', 'ConfirmReservation');
        CreateImportType('TICKET-05', 'Ticket reservation', 'ReserveConfirmArrive');
        CreateImportType('TICKET-06', 'Ticket reservation', 'OfflineTicketValidation');
        CreateImportType('TICKET-07', 'Ticket reservation', 'SetAttributes');
        CreateImportType('TICKET-08', 'Ticket reservation', 'GetTicketChangeRequest');
        CreateImportType('TICKET-09', 'Ticket reservation', 'ConfirmTicketChangeRequest');
    end;

    local procedure CreateImportType("Code": Code[20]; Description: Text[30]; FunctionName: Text[30])
    var
        ImportType: Record "NPR Nc Import Type";
    begin

        ImportType.Code := Code;
        ImportType.Description := Description;
        ImportType."Webservice Function" := FunctionName;

        ImportType."Webservice Enabled" := true;
        ImportType."Import Codeunit ID" := CODEUNIT::"NPR TM Ticket WebService Mgr";
        ImportType."Webservice Codeunit ID" := CODEUNIT::"NPR TM Ticket WebService";
        ImportType."Lookup Codeunit ID" := CODEUNIT::"NPR TM View Ticket Requests";

        ImportType.Insert();
    end;

    local procedure GetImportTypeCode(WebServiceCodeunitID: Integer; WebserviceFunction: Text): Code[10]
    var
        ImportType: Record "NPR Nc Import Type";
    begin

        Clear(ImportType);
        ImportType.SetRange("Webservice Codeunit ID", WebServiceCodeunitID);
        ImportType.SetFilter("Webservice Function", '%1', CopyStr(WebserviceFunction, 1, MaxStrLen(ImportType."Webservice Function")));

        if ImportType.FindFirst then
            exit(ImportType.Code);

        exit('');
    end;
}

