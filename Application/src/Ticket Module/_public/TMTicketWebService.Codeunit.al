﻿codeunit 6060115 "NPR TM Ticket WebService"
{
    trigger OnRun()
    begin
    end;

    var
        TicketIdentifierType: Option INTERNAL_TICKET_NO,EXTERNAL_TICKET_NO,PRINTED_TICKET_NO;
        SETUP_MISSING: Label 'Setup is missing for %1';

    procedure ValidateTicketArrival(AdmissionCode: Code[20]; ExternalTicketNo: Text[50]; ScannerStationId: Code[10]; var MessageText: Text): Boolean
    var
        AttemptTicket: Codeunit "NPR Ticket Attempt Create";
    begin
        exit(AttemptTicket.AttemptValidateTicketForArrival(TicketIdentifierType::EXTERNAL_TICKET_NO, ExternalTicketNo, AdmissionCode, -1, '', ScannerStationId, MessageText));
    end;

    procedure ValidateTicketDeparture(AdmissionCode: Code[20]; ExternalTicketNo: Text[50]; ScannerStationId: Code[10]; MessageText: Text): Boolean
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
    begin
        TicketManagement.ValidateTicketForDeparture(TicketIdentifierType::EXTERNAL_TICKET_NO, ExternalTicketNo, AdmissionCode);
        exit(true);
    end;

    procedure MakeTicketReservation(var Reservation: XmlPort "NPR TM Ticket Reservation"; ScannerStationId: Code[10])
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        FileNameLbl: Label 'TicketReservation-%1-%2.xml', Locked = true;
    begin
        Reservation.Import();

        InsertImportEntry('MakeTicketReservation', ImportEntry);
        ImportEntry."Document ID" := Reservation.GetToken();
        if (ImportEntry."Document ID" = '') then
            ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, ImportEntry."Document ID", Reservation.GetSummary());
        ImportEntry."Sequence No." := GetDocumentSequence(ImportEntry."Document ID");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Reservation.SetDestination(OutStr);
        Reservation.Export();
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
        Reservation.Export();
        ImportEntry.Modify(true);
        Commit();
    end;

    procedure PreConfirmTicketReservation(var PreConfirm: XmlPort "NPR TM Ticket PreConfirm"; ScannerStationId: Code[10])
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        FileNameLbl: Label 'TicketPreConfirm-%1-%2.xml', Locked = true;
    begin

        PreConfirm.Import();

        InsertImportEntry('PreConfirmReservation', ImportEntry);
        ImportEntry."Document ID" := PreConfirm.GetToken();
        if (ImportEntry."Document ID" = '') then
            ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, ImportEntry."Document ID", PreConfirm.GetSummary());
        ImportEntry."Sequence No." := GetDocumentSequence(ImportEntry."Document ID");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        PreConfirm.SetDestination(OutStr);
        PreConfirm.Export();

        ImportEntry.Modify(true);

        Commit();
        NaviConnectSyncMgt.ProcessImportEntry(ImportEntry);

        ImportEntry.Get(ImportEntry."Entry No.");
        PreConfirm.SetReservationResult(ImportEntry."Document ID", ImportEntry.Imported);
    end;

    procedure CancelTicketReservation(var Cancelation: XmlPort "NPR TM Ticket Cancel"; ScannerStationId: Code[10])
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        FileNameLbl: Label 'TicketCancellation-%1-%2.xml', Locked = true;
    begin

        Cancelation.Import();

        InsertImportEntry('CancelReservation', ImportEntry);
        ImportEntry."Document ID" := Cancelation.GetToken();
        if (ImportEntry."Document ID" = '') then
            ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, ImportEntry."Document ID", Cancelation.GetSummary());
        ImportEntry."Sequence No." := GetDocumentSequence(ImportEntry."Document ID");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Cancelation.SetDestination(OutStr);
        Cancelation.Export();
        ImportEntry.Modify(true);
        Commit();

        NaviConnectSyncMgt.ProcessImportEntry(ImportEntry);
        ImportEntry.Get(ImportEntry."Entry No.");

        Cancelation.SetReservationResult(ImportEntry."Document ID", ImportEntry.Imported);

        ImportEntry.Imported := true;
        ImportEntry."Document Source".CreateOutStream(OutStr);
        Cancelation.SetDestination(OutStr);
        Cancelation.Export();

        ImportEntry.Modify(true);

    end;

    procedure ConfirmTicketReservation(var Confirmation: XmlPort "NPR TM Ticket Confirmation"; ScannerStationId: Code[10]) Success: Boolean
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        FileNameLbl: Label 'TicketConfirmation-%1-%2.xml', Locked = true;
    begin

        Confirmation.Import();

        InsertImportEntry('ConfirmReservation', ImportEntry);
        ImportEntry."Document ID" := Confirmation.GetToken();
        if (ImportEntry."Document ID" = '') then
            ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, ImportEntry."Document ID", Confirmation.GetSummary());
        ImportEntry."Sequence No." := GetDocumentSequence(ImportEntry."Document ID");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Confirmation.SetDestination(OutStr);
        Confirmation.Export();
        ImportEntry.Modify(true);
        Commit();

        NaviConnectSyncMgt.ProcessImportEntry(ImportEntry);
        ImportEntry.Get(ImportEntry."Entry No.");
        if (not ImportEntry.Imported) then
            Confirmation.SetErrorResult(ImportEntry."Document ID", ImportEntry."Error Message") else
            Confirmation.SetReservationResult(ImportEntry."Document ID");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Confirmation.SetDestination(OutStr);
        Confirmation.Export();
        ImportEntry.Modify(true);
        Commit();

        exit(ImportEntry.Imported);
    end;

    procedure GetTicketChangeRequest(var TicketChangeRequest: XmlPort "NPR TM Ticket Change Request");
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        FileNameLbl: Label 'GetTicketChangeRequest-%1.xml', Locked = true;
    begin

        TicketChangeRequest.Import();
        InsertImportEntry('GetTicketChangeRequest', ImportEntry);

        ImportEntry."Document ID" := CreateDocumentId();
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, ImportEntry."Document ID");
        ImportEntry."Sequence No." := GetDocumentSequence(ImportEntry."Document ID");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        TicketChangeRequest.SetDestination(OutStr);
        TicketChangeRequest.Export();
        ImportEntry.Modify(true);

        Commit();
        NaviConnectSyncMgt.ProcessImportEntry(ImportEntry);

        ImportEntry.Get(ImportEntry."Entry No.");
        if (ImportEntry.Imported) then begin
            TicketChangeRequest.SetChangeRequestId(ImportEntry."Document ID");
        end else begin
            ImportEntry.Imported := true;
            ImportEntry."Runtime Error" := true;
            TicketChangeRequest.SetError(ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        TicketChangeRequest.SetDestination(OutStr);
        TicketChangeRequest.Export();
        ImportEntry.Modify(true);
    end;

    procedure ConfirmTicketChangeRequest(var TicketConfChangeRequest: XmlPort "NPR TM Ticket Conf. Change Req");
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        FileNameLbl: Label 'ConfirmTicketChangeRequest-%1.xml', Locked = true;
    begin

        TicketConfChangeRequest.Import();
        InsertImportEntry('ConfirmTicketChangeRequest', ImportEntry);

        ImportEntry."Document ID" := TicketConfChangeRequest.GetToken();
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, ImportEntry."Document ID");
        ImportEntry."Sequence No." := GetDocumentSequence(ImportEntry."Document ID");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        TicketConfChangeRequest.SetDestination(OutStr);
        TicketConfChangeRequest.Export();
        ImportEntry.Modify(true);

        Commit();
        NaviConnectSyncMgt.ProcessImportEntry(ImportEntry);

        ImportEntry.Get(ImportEntry."Entry No.");
        if (ImportEntry.Imported) then begin
            TicketConfChangeRequest.SetChangeRequestId(ImportEntry."Document ID");
        end else begin
            ImportEntry.Imported := true;
            ImportEntry."Runtime Error" := true;
            TicketConfChangeRequest.SetError(ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        TicketConfChangeRequest.SetDestination(OutStr);
        TicketConfChangeRequest.Export();
        ImportEntry.Modify(true);

    end;

    procedure MakeTicketReservationConfirmAndValidateArrival(var Reservation: XmlPort "NPR TM Ticket Reserv.AndArrive"; ScannerStationId: Code[10])
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        FileNameLbl: Label 'ReserveConfirmArrive-%1-%2.xml', Locked = true;
    begin

        Reservation.Import();

        InsertImportEntry('ReserveConfirmArrive', ImportEntry);
        ImportEntry."Document ID" := Reservation.GetToken();
        if (ImportEntry."Document ID" = '') then
            ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, ImportEntry."Document ID", Reservation.GetSummary());
        ImportEntry."Sequence No." := GetDocumentSequence(ImportEntry."Document ID");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Reservation.SetDestination(OutStr);
        Reservation.Export();

        ImportEntry.Modify(true);

        Commit();
        NaviConnectSyncMgt.ProcessImportEntry(ImportEntry);

        ImportEntry.Get(ImportEntry."Entry No.");
        if (not ImportEntry.Imported) then
            Error(ImportEntry."Error Message");

        Reservation.SetReservationResult(ImportEntry."Document ID");
    end;

    [Obsolete('Pending removal, use RevokeTicketReservation(var TicketRevoke: XmlPort "NPR TM Ticket Revoke") instead.', 'NPR23.0')]
    procedure RevokeTicketReservation()
    begin

    end;

    procedure RevokeTicketReservation(var TicketRevoke: XmlPort "NPR TM Ticket Revoke")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        FileNameLbl: Label 'RevokeTicketRequest-%1-%2.xml', Locked = true;
    begin
        TicketRevoke.Import();

        InsertImportEntry('RevokeTicketRequest', ImportEntry);
        ImportEntry."Document ID" := TicketRevoke.GetToken();
        if (ImportEntry."Document ID" = '') then
            ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, ImportEntry."Document ID", TicketRevoke.GetSummary());
        ImportEntry."Sequence No." := GetDocumentSequence(ImportEntry."Document ID");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        TicketRevoke.SetDestination(OutStr);
        TicketRevoke.Export();

        ImportEntry.Modify(true);

        Commit();
        NaviConnectSyncMgt.ProcessImportEntry(ImportEntry);

        ImportEntry.Get(ImportEntry."Entry No.");
        if (not ImportEntry.Imported) then
            TicketRevoke.SetErrorResult(ImportEntry."Error Message") else
            TicketRevoke.SetReservationResult(ImportEntry."Document ID", true);

        ImportEntry."Document Source".CreateOutStream(OutStr);
        TicketRevoke.SetDestination(OutStr);
        TicketRevoke.Export();
        ImportEntry.Modify(true);
        Commit();
    end;

    procedure ConfirmRevokeRequest(var Confirmation: XMLport "NPR TM Ticket Confirmation"; ScannerStationId: Code[10]) Success: Boolean
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        FileNameLbl: Label 'RevokeConfirmation-%1-%2.xml', Locked = true;
    begin

        Confirmation.Import();

        InsertImportEntry('ConfirmRevokeRequest', ImportEntry);
        ImportEntry."Document ID" := Confirmation.GetToken();
        if (ImportEntry."Document ID" = '') then
            ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, ImportEntry."Document ID", Confirmation.GetSummary());
        ImportEntry."Sequence No." := GetDocumentSequence(ImportEntry."Document ID");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Confirmation.SetDestination(OutStr);
        Confirmation.Export();
        ImportEntry.Modify(true);
        Commit();

        NaviConnectSyncMgt.ProcessImportEntry(ImportEntry);
        ImportEntry.Get(ImportEntry."Entry No.");
        if (not ImportEntry.Imported) then
            Confirmation.SetErrorResult(ImportEntry."Document ID", ImportEntry."Error Message") else
            Confirmation.SetReservationResult(ImportEntry."Document ID");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Confirmation.SetDestination(OutStr);
        Confirmation.Export();
        ImportEntry.Modify(true);
        Commit();

        exit(ImportEntry.Imported);
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
#pragma warning disable AA0245 
    procedure OfflineTicketValidation(var OfflineTicketValidation: XmlPort "NPR TM Offline Ticket Valid.") Success: Boolean
    var
        ImportEntry: Record "NPR Nc Import Entry";
        OutStr: OutStream;
        FileNameLbl: Label 'OfflineTicketValidation-%1.xml', Locked = true;
    begin

        OfflineTicketValidation.Import();

        InsertImportEntry('OfflineTicketValidation', ImportEntry);
        ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, ImportEntry."Document ID");
        ImportEntry."Sequence No." := GetDocumentSequence(ImportEntry."Document ID");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        OfflineTicketValidation.SetDestination(OutStr);
        OfflineTicketValidation.Export();
        ImportEntry.Modify(true);
        Commit();

        OfflineTicketValidation.ProcessImportedRecords();

        Commit();
        exit(true);
    end;
#pragma warning restore

    procedure SetReservationAttributes(var Attributes: XmlPort "NPR TM Ticket Set Attr.") Success: Boolean
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        FileNameLbl: Label 'SetAttributes-%1.xml', Locked = true;
    begin

        Attributes.Import();

        InsertImportEntry('SetAttributes', ImportEntry);
        ImportEntry."Document ID" := Attributes.GetToken();
        if (ImportEntry."Document ID" = '') then
            ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, ImportEntry."Document ID");
        ImportEntry."Sequence No." := GetDocumentSequence(ImportEntry."Document ID");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Attributes.SetDestination(OutStr);
        Attributes.Export();
        ImportEntry.Modify(true);
        Commit();

        NaviConnectSyncMgt.ProcessImportEntry(ImportEntry);

        ImportEntry.Get(ImportEntry."Entry No.");
        Attributes.SetResult(ImportEntry.Imported, ImportEntry."Document ID", ImportEntry."Error Message");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Attributes.SetDestination(OutStr);
        Attributes.Export();
        ImportEntry.Modify(true);
        Commit();

        exit(not ImportEntry."Runtime Error");
    end;

    procedure GetAdmissionCapacity(var AdmissionCapacityCheck: XmlPort "NPR TM Admis. Capacity Check")
    begin
        AdmissionCapacityCheck.Import();
        AdmissionCapacityCheck.AddResponse();
    end;

    procedure GetAdmissionSchedules(var AdmissionSchedules: XmlPort "NPR TM Get Admission Schedules")
    begin
        AdmissionSchedules.Import();
        AdmissionSchedules.CreateResponse();
    end;

    procedure GetAdmissionCapacityPrice(var AdmissionCapacityPrice: XmlPort "NPR TM AdmissionCapacityPrice")
    begin
        AdmissionCapacityPrice.Import();
        AdmissionCapacityPrice.AddResponse();
    end;


    procedure GetTicketPrintUrl(var TicketGetTicketPrintURL: XmlPort "NPR TM Ticket Get Print URL")
    begin
        TicketGetTicketPrintURL.Import();
        TicketGetTicketPrintURL.CreateResponse();
    end;

    procedure ListTickets(var TicketDetails: XmlPort "NPR TM Ticket Details")
    begin

        TicketDetails.Import();
        TicketDetails.CreateResponse();

    end;

#pragma warning disable AA0245 
    procedure SendETicket(var SendETicket: XmlPort "NPR TM Send eTicket")
    begin

        SendETicket.Import();
        SendETicket.CreateResponse();

    end;
#pragma warning restore

#pragma warning disable AA0245 
    procedure ListTicketItems(var ListTicketItems: XmlPort "NPR TM List Ticket Items")
    begin
        ListTicketItems.Import();
        ListTicketItems.CreateResponse(ListTicketItems.GetRequestedStoreCode());
    end;
#pragma warning restore

    local procedure InsertImportEntry(WebServiceFunction: Text; var ImportEntry: Record "NPR Nc Import Entry")
    var
        FileNameLbl: Label '%1-%2.xml', Locked = true;
    begin
        ImportEntry.Init();
        ImportEntry."Entry No." := 0;
        ImportEntry."Import Type" := GetImportTypeCode(Codeunit::"NPR TM Ticket WebService", WebServiceFunction);
        if (ImportEntry."Import Type" = '') then begin
            TicketIntegrationSetup();
            ImportEntry."Import Type" := GetImportTypeCode(Codeunit::"NPR TM Ticket WebService", WebServiceFunction);
            if (ImportEntry."Import Type" = '') then
                Error(SETUP_MISSING, WebServiceFunction);
        end;

        ImportEntry.Date := CurrentDateTime;
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, ImportEntry."Import Type", Format(ImportEntry.Date, 0, 9));
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := false;
        ImportEntry.Insert(true);
    end;

    local procedure GetDocumentSequence(DocumentID: Text[100]): Integer
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

    local procedure TicketIntegrationSetup()
    var
        ImportType: Record "NPR Nc Import Type";
    begin

        ImportType.SetFilter("Webservice Codeunit ID", '=%1', Codeunit::"NPR TM Ticket WebService");
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
        CreateImportType('TICKET-10', 'Ticket reservation', 'RevokeTicketRequest');
        CreateImportType('TICKET-11', 'Ticket reservation', 'ConfirmRevokeRequest');
    end;

    local procedure CreateImportType("Code": Code[20]; Description: Text[30]; FunctionName: Text[30])
    var
        ImportType: Record "NPR Nc Import Type";
    begin

        ImportType.Code := Code;
        ImportType.Description := Description;
        ImportType."Webservice Function" := FunctionName;

        ImportType."Webservice Enabled" := true;
        ImportType."Import List Process Handler" := Enum::"NPR Nc IL Process Handler"::"TM Ticket WebService Mgr";
        ImportType."Webservice Codeunit ID" := Codeunit::"NPR TM Ticket WebService";
        ImportType."Import List Lookup Handler" := Enum::"NPR Nc IL Lookup Handler"::"TM View Ticket Requests";

        ImportType.Actionable := false;

        ImportType.Insert();
    end;

    local procedure GetImportTypeCode(WebServiceCodeunitID: Integer; WebserviceFunction: Text): Code[20]
    var
        ImportType: Record "NPR Nc Import Type";
    begin

        Clear(ImportType);
        ImportType.SetRange("Webservice Codeunit ID", WebServiceCodeunitID);
        ImportType.SetFilter("Webservice Function", '%1', CopyStr(WebserviceFunction, 1, MaxStrLen(ImportType."Webservice Function")));

        if (ImportType.FindFirst()) then
            exit(ImportType.Code);

        exit('');
    end;
#pragma warning disable AA0139
    local procedure CreateDocumentId(): Text[50]
    begin
        exit(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')));
    end;
#pragma warning restore
}


