codeunit 6060115 "TM Ticket WebService"
{
    // TM1.04/TSA/20160114 CASE 231834 Added the Confirm Reservation WS
    // TM1.08/TSA/20160222 CASE 235208 Addded WS to combine reservation, confirmation and arrival in go
    // TM1.09/TSA/20160305  CASE 235860 Restructured, moved request related functions to its own codeunit
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.15/TSA/20160603  CASE 240864 Transport TM1.15 - 1 June 2016
    // TM1.15.02/MHA/20160726  CASE 242557 Magento reference updated according to NC2.00
    // TM1.18/TSA/20161220  CASE 261405 Added service GetComplementaryMembershipItemNo that returns Ticket Type.Membership Sales Item No.
    // TM1.19/TSA/20170130  CASE 264591 ConfirmTicketReservation had boolean response that was not set correctly on exit.
    // TM1.21/TSA/20170419  CASE 272421 ResolveIdentifiers SOAP Action
    // TM1.22/TSA/20170601  CASE 274464 Added OfflineTicketValidation
    // TM1.22/BHR/20170609  CASE 280133 Set default value for ImportTypes
    // TM1.23/TSA /20170724 CASE 284752 New SOAPAction SetReservationAttributes
    // TM1.24/TSA /20170824 CASE 287582 Added SOAPAction GetAdmissionCapacity
    // TM1.24/TSA /20170911 CASE 276842 Added SOAPAction ListTickets
    // TM1.26/TSA /20171102 CASE 285601 Added SOAPAction GetTicketPrintUrl
    // TM1.26/TSA /20171109 CASE 295981 Change the error path of MakeTicketReservation
    // TM1.29/TSA /20180322 CASE 308975 Adding ConsumeComplementaryItem, and changing GetComplementaryMembershipItemNo to check if consumed
    // TM1.36/TSA /20180830 CASE 326733 Removed ResolveIdentifiers()
    // TM1.38/TSA /20181025 CASE 332109 SendETicket()
    // TM1.45/TSA /20200114 CASE 384490 Ticket blocked checked for complementary item
    // TM90.1.46/TSA /20200128 CASE 387877 Added ListTicketItems() service


    trigger OnRun()
    begin
    end;

    var
        TicketIdentifierType: Option INTERNAL_TICKET_NO,EXTERNAL_TICKET_NO,PRINTED_TICKET_NO;
        SETUP_MISSING: Label 'Setup is missing for %1';

    [Scope('Personalization')]
    procedure ValidateTicketArrival(AdmissionCode: Code[20];ExternalTicketNo: Text[50];ScannerStationId: Code[10];var MessageText: Text): Boolean
    var
        TicketManagement: Codeunit "TM Ticket Management";
        MessageId: Integer;
    begin

        MessageId := TicketManagement.ValidateTicketForArrival (TicketIdentifierType::EXTERNAL_TICKET_NO, ExternalTicketNo, AdmissionCode, -1, false, MessageText);
        exit (MessageId = 0);
    end;

    [Scope('Personalization')]
    procedure ValidateTicketDeparture(AdmissionCode: Code[20];ExternalTicketNo: Text[50];ScannerStationId: Code[10];var MessageText: Text): Boolean
    var
        TicketManagement: Codeunit "TM Ticket Management";
        MessageId: Integer;
    begin

        MessageId := TicketManagement.ValidateTicketForDeparture (TicketIdentifierType::EXTERNAL_TICKET_NO, ExternalTicketNo, AdmissionCode, false, MessageText);
        exit (MessageId = 0);
    end;

    [Scope('Personalization')]
    procedure MakeTicketReservation(var Reservation: XMLport "TM Ticket Reservation";ScannerStationId: Code[10])
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
    begin

        Reservation.Import;

        InsertImportEntry ('MakeTicketReservation',ImportEntry);
        ImportEntry."Document ID" := Reservation.GetToken();
        if (ImportEntry."Document ID" = '') then
          ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));

        ImportEntry."Document Name" := StrSubstNo ('TicketReservation-%1-%2.xml', ImportEntry."Document ID", Reservation.GetSummary());
        ImportEntry."Sequence No." := GetDocumentSequence (ImportEntry."Document ID");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Reservation.SetDestination(OutStr);
        Reservation.Export;
        ImportEntry.Modify(true);
        Commit ();

        NaviConnectSyncMgt.ProcessImportEntry (ImportEntry);

        ImportEntry.Get (ImportEntry."Entry No.");
        //-TM1.26 [295981]
        // IF (NOT ImportEntry.Imported) THEN
        //  ERROR (ImportEntry."Error Message");
        //
        // ImportEntry."Document Source".CREATEOUTSTREAM(OutStr);
        // Reservation.SetReservationResult (ImportEntry."Document ID");
        // Reservation.SETDESTINATION(OutStr);
        // Reservation.EXPORT;
        // ImportEntry.MODIFY(TRUE);
        // COMMIT;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        if (not ImportEntry.Imported) then begin
          Reservation.SetErrorResult (ImportEntry."Document ID", ImportEntry."Error Message");
        end else begin
          Reservation.SetReservationResult (ImportEntry."Document ID");
        end;

        Reservation.SetDestination(OutStr);
        Reservation.Export;
        ImportEntry.Modify(true);
        Commit;
        //+TM1.26 [295981]
    end;

    [Scope('Personalization')]
    procedure PreConfirmTicketReservation(var PreConfirm: XMLport "TM Ticket PreConfirm";ScannerStationId: Code[10])
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
    begin

        PreConfirm.Import;

        InsertImportEntry ('PreConfirmReservation',ImportEntry);
        ImportEntry."Document ID" := PreConfirm.GetToken();
        if (ImportEntry."Document ID" = '') then
          ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));

        ImportEntry."Document Name" := StrSubstNo ('TicketPreConfirm-%1-%2.xml', ImportEntry."Document ID", PreConfirm.GetSummary());
        ImportEntry."Sequence No." := GetDocumentSequence (ImportEntry."Document ID");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        PreConfirm.SetDestination(OutStr);
        PreConfirm.Export;

        ImportEntry.Modify(true);

        Commit ();
        NaviConnectSyncMgt.ProcessImportEntry (ImportEntry);

        ImportEntry.Get (ImportEntry."Entry No.");
        PreConfirm.SetReservationResult (ImportEntry."Document ID", ImportEntry.Imported);
    end;

    [Scope('Personalization')]
    procedure CancelTicketReservation(var Cancelation: XMLport "TM Ticket Cancel";ScannerStationId: Code[10])
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
    begin

        Cancelation.Import;

        InsertImportEntry ('CancelReservation',ImportEntry);
        ImportEntry."Document ID" := Cancelation.GetToken();
        if (ImportEntry."Document ID" = '') then
          ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));

        ImportEntry."Document Name" := StrSubstNo ('TicketCancelation-%1-%2.xml', ImportEntry."Document ID", Cancelation.GetSummary());
        ImportEntry."Sequence No." := GetDocumentSequence (ImportEntry."Document ID");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Cancelation.SetDestination(OutStr);
        Cancelation.Export;

        ImportEntry.Modify(true);

        Commit ();
        NaviConnectSyncMgt.ProcessImportEntry (ImportEntry);

        ImportEntry.Get (ImportEntry."Entry No.");
        Cancelation.SetReservationResult (ImportEntry."Document ID", ImportEntry.Imported);
    end;

    [Scope('Personalization')]
    procedure ConfirmTicketReservation(var Confirmation: XMLport "TM Ticket Confirmation";ScannerStationId: Code[10]) Success: Boolean
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
    begin

        Confirmation.Import;

        InsertImportEntry ('ConfirmReservation',ImportEntry);
        ImportEntry."Document ID" := Confirmation.GetToken();
        if (ImportEntry."Document ID" = '') then
          ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));

        ImportEntry."Document Name" := StrSubstNo ('TicketConfirmation-%1-%2.xml', ImportEntry."Document ID", Confirmation.GetSummary());
        ImportEntry."Sequence No." := GetDocumentSequence (ImportEntry."Document ID");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Confirmation.SetDestination(OutStr);
        Confirmation.Export;
        ImportEntry.Modify(true);
        Commit ();

        NaviConnectSyncMgt.ProcessImportEntry (ImportEntry);
        ImportEntry.Get (ImportEntry."Entry No.");
        if (not ImportEntry.Imported) then
          Error (ImportEntry."Error Message");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Confirmation.SetReservationResult (ImportEntry."Document ID");
        Confirmation.SetDestination(OutStr);
        Confirmation.Export;
        ImportEntry.Modify(true);
        Commit;

        exit (true);
    end;

    [Scope('Personalization')]
    procedure MakeTicketReservationConfirmAndValidateArrival(var Reservation: XMLport "TM Ticket ReservationAndArrive";ScannerStationId: Code[10])
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
    begin

        Reservation.Import;

        InsertImportEntry ('ReserveConfirmArrive',ImportEntry);
        ImportEntry."Document ID" := Reservation.GetToken();
        if (ImportEntry."Document ID" = '') then
          ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));

        ImportEntry."Document Name" := StrSubstNo ('ReserveConfirmArrive-%1-%2.xml', ImportEntry."Document ID", Reservation.GetSummary());
        ImportEntry."Sequence No." := GetDocumentSequence (ImportEntry."Document ID");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Reservation.SetDestination(OutStr);
        Reservation.Export;

        ImportEntry.Modify(true);

        Commit ();
        NaviConnectSyncMgt.ProcessImportEntry (ImportEntry);

        ImportEntry.Get (ImportEntry."Entry No.");
        if (not ImportEntry.Imported) then
          Error (ImportEntry."Error Message");

        Reservation.SetReservationResult (ImportEntry."Document ID");
    end;

    [Scope('Personalization')]
    procedure RevokeTicketReservation()
    begin
    end;

    [Scope('Personalization')]
    procedure GetComplementaryMembershipItemNo(ExternalTicketNo: Code[20];var ComplementaryItemNo: Code[20]) Success: Integer
    var
        TicketManagement: Codeunit "TM Ticket Management";
        Ticket: Record "TM Ticket";
        TicketType: Record "TM Ticket Type";
        ReasonText: Text;
    begin

        //-TM1.18 [261405]
        Ticket.SetFilter ("External Ticket No.", '=%1', ExternalTicketNo);
        if (not Ticket.FindFirst ()) then
          exit (-10);

        //-TM1.45 [384490]
        if (Ticket.Blocked) then
          exit (-13);
        //+TM1.45 [384490]


        if (not TicketType.Get (Ticket."Ticket Type Code")) then
          exit (-11);

        if (ComplementaryItemNo = '') then begin

          if (TicketType."Membership Sales Item No." = '') then
            exit (-12);

          ComplementaryItemNo := TicketType."Membership Sales Item No.";
        end;

        //-#308975 [308975]
        if (TicketManagement.CheckIfConsumed (false, Ticket."No.", '', ComplementaryItemNo, ReasonText)) then begin
          ComplementaryItemNo := '';
          exit (-20);
        end;
        //+#308975 [308975]

        exit (1);

        //+TM1.18 [261405]
    end;

    [Scope('Personalization')]
    procedure ConsumeComplementaryItem(ExternalTicketNo: Code[20];var ComplementaryItemNo: Code[20]) Success: Integer
    var
        TicketManagement: Codeunit "TM Ticket Management";
        Ticket: Record "TM Ticket";
        TicketType: Record "TM Ticket Type";
        ReasonText: Text;
    begin

        //-#308975 [308975]

        Ticket.SetFilter ("External Ticket No.", '=%1', ExternalTicketNo);
        if (not Ticket.FindFirst ()) then
          exit (-10);

        //-TM1.45 [384490]
        if (Ticket.Blocked) then
          exit (-13);
        //+TM1.45 [384490]

        if (not TicketType.Get (Ticket."Ticket Type Code")) then
          exit (-11);

        if (ComplementaryItemNo = '') then begin
          if (TicketType."Membership Sales Item No." = '') then
            exit (-12);

          ComplementaryItemNo := TicketType."Membership Sales Item No.";

        end;

        TicketManagement.ConsumeItem (false, Ticket."No.", '', ComplementaryItemNo, ReasonText);
        exit (1);
        //+#308975 [308975]
    end;

    [Scope('Personalization')]
    procedure OfflineTicketValidation(var OfflineTicketValidation: XMLport "TM Offline Ticket Validation") Success: Boolean
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
    begin

        OfflineTicketValidation.Import;

        InsertImportEntry ('OfflineTicketValidation',ImportEntry);
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));

        ImportEntry."Document Name" := StrSubstNo ('OfflineTicketValidation-%1.xml', ImportEntry."Document ID");
        ImportEntry."Sequence No." := GetDocumentSequence (ImportEntry."Document ID");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        OfflineTicketValidation.SetDestination(OutStr);
        OfflineTicketValidation.Export;
        ImportEntry.Modify(true);
        Commit ();

        OfflineTicketValidation.ProcessImportedRecords ();

        Commit;
        exit (true);
    end;

    [Scope('Personalization')]
    procedure SetReservationAttributes(var Attributes: XMLport "TM Ticket Set Attributes") Success: Boolean
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
    begin
        //-TM1.23 [284752]

        Attributes.Import;

        InsertImportEntry ('SetAttributes', ImportEntry);
        ImportEntry."Document ID" := Attributes.GetToken();
        if (ImportEntry."Document ID" = '') then
          ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));

        ImportEntry."Document Name" := StrSubstNo ('SetAttributes-%1.xml', ImportEntry."Document ID");
        ImportEntry."Sequence No." := GetDocumentSequence (ImportEntry."Document ID");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Attributes.SetDestination(OutStr);
        Attributes.Export;
        ImportEntry.Modify(true);
        Commit ();

        NaviConnectSyncMgt.ProcessImportEntry (ImportEntry);

        ImportEntry.Get (ImportEntry."Entry No.");
        Attributes.SetResult(ImportEntry.Imported, ImportEntry."Document ID", ImportEntry."Error Message");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Attributes.SetDestination(OutStr);
        Attributes.Export;
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := false;
        ImportEntry.Modify (true);
        Commit ();

        exit (true);
        //+TM1.23 [284752]
    end;

    [Scope('Personalization')]
    procedure GetAdmissionCapacity(var AdmissionCapacityCheck: XMLport "TM Admission Capacity Check")
    begin

        //-TM1.24 [287582]
        AdmissionCapacityCheck.Import;
        AdmissionCapacityCheck.AddResponse ();
        //+TM1.24 [287582]
    end;

    [Scope('Personalization')]
    procedure GetTicketPrintUrl(var TicketGetTicketPrintURL: XMLport "TM Ticket Get Ticket Print URL")
    begin

        TicketGetTicketPrintURL.Import ();
        TicketGetTicketPrintURL.CreateResponse ();
    end;

    [Scope('Personalization')]
    procedure ListTickets(var TicketDetails: XMLport "TM Ticket Details")
    begin

        //-#276842 [276842]
        TicketDetails.Import;
        TicketDetails.CreatResponse ();
        //+#276842 [276842]
    end;

    [Scope('Personalization')]
    procedure SendETicket(var SendETicket: XMLport "TM Send eTicket")
    begin

        //-TM1.38 [332109]
        SendETicket.Import ();
        SendETicket.CreateResponse ();
        //+TM1.38 [332109]
    end;

    [Scope('Personalization')]
    procedure ListTicketItems(var ListTicketItems: XMLport "TM List Ticket Items")
    begin

        //-TM90.1.46 [387877]
        // implicit export
        ListTicketItems.CreateResponse ();
        //+TM90.1.46 [387877]
    end;

    local procedure "--"()
    begin
    end;

    local procedure "--Internal"()
    begin
    end;

    local procedure InsertImportEntry(WebserviceFunction: Text;var ImportEntry: Record "Nc Import Entry")
    var
        NaviConnectSetupMgt: Codeunit "Nc Setup Mgt.";
    begin

        ImportEntry.Init;
        ImportEntry."Entry No." := 0;
        ImportEntry."Import Type" := GetImportTypeCode(CODEUNIT::"TM Ticket WebService", WebserviceFunction);
        if (ImportEntry."Import Type" = '') then begin
          TicketIntegrationSetup ();
          ImportEntry."Import Type" := GetImportTypeCode(CODEUNIT::"TM Ticket WebService", WebserviceFunction);
          if (ImportEntry."Import Type" = '') then
            Error (SETUP_MISSING, WebserviceFunction);
        end;

        ImportEntry.Date := CurrentDateTime;
        ImportEntry."Document Name" := StrSubstNo('%1-%2.xml', ImportEntry."Import Type", Format(ImportEntry.Date,0,9));
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := false;
        ImportEntry.Insert(true);
    end;

    local procedure GetDocumentSequence(DocumentID: Text[100]) SequenceNo: Integer
    var
        ImportEntry: Record "Nc Import Entry";
    begin

        if (DocumentID = '') then
          exit (1);

        ImportEntry.SetCurrentKey ("Document ID");
        ImportEntry.SetFilter ("Document ID", '=%1', DocumentID);
        if (not ImportEntry.FindLast ()) then
          exit (1);

        exit (ImportEntry."Sequence No."+1);
    end;

    local procedure InitSetup(): Text
    begin
    end;

    local procedure TicketIntegrationSetup()
    var
        ImportType: Record "Nc Import Type";
    begin

        ImportType.SetFilter ("Webservice Codeunit ID", '=%1', CODEUNIT::"TM Ticket WebService");
        if (not ImportType.IsEmpty ()) then
          ImportType.DeleteAll ();

        CreateImportType ('TICKET-01', 'Ticket reservation', 'MakeTicketReservation');
        CreateImportType ('TICKET-02', 'Ticket reservation', 'PreConfirmReservation');
        CreateImportType ('TICKET-03', 'Ticket reservation', 'CancelReservation');
        CreateImportType ('TICKET-04', 'Ticket reservation', 'ConfirmReservation');
        CreateImportType ('TICKET-05', 'Ticket reservation', 'ReserveConfirmArrive');
        CreateImportType ('TICKET-06', 'Ticket reservation', 'OfflineTicketValidation');
        CreateImportType ('TICKET-07', 'Ticket reservation', 'SetAttributes');
    end;

    local procedure CreateImportType("Code": Code[20];Description: Text[30];FunctionName: Text[30])
    var
        ImportType: Record "Nc Import Type";
    begin

        ImportType.Code := Code;
        ImportType.Description := Description;
        ImportType."Webservice Function" := FunctionName;

        ImportType."Webservice Enabled" := true;
        ImportType."Import Codeunit ID" := CODEUNIT::"TM Ticket WebService Mgr";
        ImportType."Webservice Codeunit ID" := CODEUNIT::"TM Ticket WebService";
        //-TM1.22 [280133]
        ImportType."Lookup Codeunit ID" := CODEUNIT::"TM View Ticket Requests";
        //+TM1.22 [280133]
        ImportType.Insert ();
    end;

    local procedure GetImportTypeCode(WebServiceCodeunitID: Integer;WebserviceFunction: Text): Code[10]
    var
        ImportType: Record "Nc Import Type";
    begin

        Clear(ImportType);
        ImportType.SetRange("Webservice Codeunit ID",WebServiceCodeunitID);
        ImportType.SetFilter("Webservice Function",'%1',CopyStr(WebserviceFunction,1,MaxStrLen(ImportType."Webservice Function")));

        if ImportType.FindFirst then
          exit(ImportType.Code);

        exit('');
    end;
}

