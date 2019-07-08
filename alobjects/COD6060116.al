codeunit 6060116 "TM Ticket WebService Mgr"
{
    // TM1.04/TSA/20160118  CASE 231834 NaviPartner Ticket Management
    // TM1.05/TSA/20160119  CASE 232250 Added Field line_no to XML for external referencing of lines
    // TM1.08/TSA/20160212  CASE 234604 Admission Schedule not picked up from XML
    // TM1.08/TSA/20160222  CASE 235208 Added new Field Ext. Member No. for referencing a reservation made by members
    // TM1.08/TSA/20160222  CASE 235208 Added support for new ws MakeTicketReservationConfirmAndValidateArrival
    // TM1.09/TSA/20160305  CASE 235860 Restructured, moved request related functions to its own codeunit
    // TM1.08/TSA/20160323  CASE CreateTicketAndResponse return status
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.15.02/MHA/20160726  CASE 242557 Magento reference updated according to NC2.00
    // TM1.16/TSA/20160622  CASE 245004 Added field email and external order no.
    // TM1.18/TSA/20170120  CASE 264123 Undo all reservation when part of the order fails
    // TM1.19/TSA/20170130  CASE 264591 Added test for postitive quantity in MakeTicketReservation
    // TM1.20/TSA/20170321  CASE 270164 Renamed ImportTicketReservationConfirmArrive to CreateTicketReservation, removed tail exit functions
    // TM1.21/ANEN/20170412 CASE 271903 Fixing issue when making reservation with multiple items, looping reservation request in ImportTicketReservations.
    // TM1.22/BHR/20170609  CASE 280133 Set default value for ImportTypes
    // TM1.23/TSA /20170724 CASE 284752 Added SOAPAction for setting attributes on request, ImportTicketAttributes()
    // TM1.23/TSA /20170726 CASE 285079 Added a call to function LockResources() in OnRun() and CreateTicket()
    // TM1.24/NPKNAV/20170925  CASE 285079-01 Transport TM1.24 - 25 September 2017
    // TM1.26/TSA /20171101 CASE 294586 Problem with ImportTicketReservationConfirmArrive and multiple lines with same admission code and line no
    // TM1.27/TSA /20180112 CASE 302215 Duplicate admissions when recieving multiple lines in the ReserveConfirmArrive message
    // TM1.39/TSA /20190124 CASE 335889 Member Guest ticket with ticket reuse when reentry
    // TM1.40/TSA /20190327 CASE 350287 Signature Change on RevalidateRequestForTicketReuse
    // TM1.41/TSA /20190508 CASE 353736 Incorrect loop iterator

    TableNo = "Nc Import Entry";

    trigger OnRun()
    var
        XmlDoc: DotNet XmlDocument;
        ImportType: Record "Nc Import Type";
        FunctionName: Text[100];
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
    begin

        Commit;
        TicketRequestManager.LockResources ();

        if LoadXmlDoc (XmlDoc) then begin
          FunctionName := GetWebserviceFunction ("Import Type");
          case FunctionName of
            'MakeTicketReservation' : ImportTicketReservations (XmlDoc,  "Entry No.", "Document ID");
            'ReserveConfirmArrive' :  ImportTicketReservationConfirmArriveDoc (XmlDoc,  "Entry No.", "Document ID");
            'PreConfirmReservation' : ImportTicketPreConfirmation (XmlDoc,  "Entry No.", "Document ID");
            'CancelReservation' :     ImportTicketCancelation (XmlDoc,  "Entry No.", "Document ID");
            'ConfirmReservation' :    ImportTicketConfirmation (XmlDoc,  "Entry No.", "Document ID");

            'SetAttributes' :         ImportTicketAttributes (XmlDoc, "Entry No.", "Document ID");
            else
              Error (MISSING_CASE, "Import Type", FunctionName);
          end;
        end;

        Commit;
    end;

    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        Initialized: Boolean;
        ITEM_NOT_FOUND: Label 'The sales item specified in external_id %1, was not found.';
        CHANGE_NOT_ALLOWED: Label 'Confirmed tickets can''t be changed.';
        TOKEN_NOT_FOUND: Label 'The token %1 was not found, or has incorrect state.';
        TOKEN_EXPIRED: Label 'The token %1 has expired. Use PreConfirm to re-reserve tickets.';
        TOKEN_INCORRECT_STATE: Label 'The token %1 can''t be changed when in the %1 state.';
        MISSING_CASE: Label 'No handler for %1 [%2].';
        XML_NODE: Label '%1 not found (this is a programming error.)';
        MUST_BE_POSITIVE: Label 'Quantity must be positive.';

    local procedure ImportTicketReservations(XmlDoc: DotNet XmlDocument;RequestEntryNo: Integer;DocumentID: Text[100])
    var
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        TicketReservationResponse: Record "TM Ticket Reservation Response";
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        XmlElement: DotNet XmlElement;
        XmlTokenElement: DotNet XmlElement;
        XmlNodeList: DotNet XmlNodeList;
        XmlTokenNodeList: DotNet XmlNodeList;
        i: Integer;
        Token_i: Integer;
        Token: Text[50];
        TicketCreated: Boolean;
    begin

        TicketRequestManager.ExpireReservationRequests ();

        if IsNull(XmlDoc) then
          exit;
        XmlElement := XmlDoc.DocumentElement;
        if IsNull(XmlElement) then
          exit;

        if not NpXmlDomMgt.FindNodes(XmlElement,'reserve_tickets',XmlTokenNodeList) then
          exit;

        for Token_i := 0 to XmlTokenNodeList.Count - 1 do begin
          XmlTokenElement := XmlTokenNodeList.ItemOf (Token_i);
          Token := CopyStr (NpXmlDomMgt.GetXmlAttributeText (XmlTokenElement, 'token', false), 1, MaxStrLen (Token));
          if (Token = '') then
            Token := DocumentID;

          if TicketRequestManager.TokenRequestExists (Token) then
            TicketRequestManager.DeleteReservationRequest (Token, true);

          if not NpXmlDomMgt.FindNodes (XmlTokenElement, 'ticket', XmlNodeList) then
            exit;

          for i := 0 to XmlNodeList.Count - 1 do begin
            XmlElement := XmlNodeList.ItemOf(i);
            ImportTicketReservation (XmlElement, Token, DocumentID);
          end;
        end;

        TicketReservationRequest.SetCurrentKey ("Session Token ID");
        TicketReservationRequest.SetFilter ("Session Token ID", '=%1', Token);
        //-TM1.21
        if (TicketReservationRequest.FindSet (true,false)) then begin
          TicketCreated := true;
          repeat
            CreateResponse (TicketReservationRequest, TicketReservationResponse);

            if (ValidTicketRequest (TicketReservationRequest, TicketReservationResponse)) then begin
              TicketCreated := TicketCreated and CreateTicket (TicketReservationRequest, TicketReservationResponse);

            end else begin
              TicketCreated := false;
            end;

          until ((TicketReservationRequest.Next () = 0));
        end;
        //+TM1.21

        if (not TicketCreated) then
          TicketRequestManager.DeleteReservationRequest (Token, false);
    end;

    local procedure ImportTicketReservation(XmlElement: DotNet XmlElement;Token: Text[100];DocumentID: Text[100]) Imported: Boolean
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        TicketReservationResponse: Record "TM Ticket Reservation Response";
    begin

        if IsNull(XmlElement) then
          exit(false);

        TicketReservationRequest.Init ();
        InsertTicketReservation (XmlElement, Token, TicketReservationRequest);

        exit(true);
    end;

    local procedure ImportTicketPreConfirmation(XmlDoc: DotNet XmlDocument;RequestEntryNo: Integer;DocumentID: Text[100])
    var
        XmlElement: DotNet XmlElement;
        XmlNodeList: DotNet XmlNodeList;
        i: Integer;
        Token: Text[100];
        TicketReservationResponse: Record "TM Ticket Reservation Response";
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        TicketCreated: Boolean;
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
    begin

        if IsNull(XmlDoc) then
          exit;
        XmlElement := XmlDoc.DocumentElement;
        if IsNull(XmlElement) then
          exit;

        if not NpXmlDomMgt.FindNodes(XmlElement,'ticket_tokens',XmlNodeList) then
          exit;

        Token := CopyStr (NpXmlDomMgt.GetXmlAttributeText(XmlElement,'ticket_token',false), 1, MaxStrLen (Token));
        if (Token = '') then
          Token := DocumentID;

        TicketReservationRequest.Reset ();
        TicketReservationRequest.SetFilter ("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter ("Request Status", '=%1', TicketReservationRequest."Request Status"::REGISTERED);
        if (TicketReservationRequest.FindSet (true,false)) then begin
          TicketReservationRequest.ModifyAll ("Expires Date Time", CurrentDateTime + 1500 * 1000);
          exit;

        end;

        TicketReservationRequest.Reset ();
        TicketReservationRequest.SetFilter ("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter ("Request Status", '=%1', TicketReservationRequest."Request Status"::EXPIRED);
        if (TicketReservationRequest.FindSet ()) then begin
          TicketCreated := true;
          repeat
            CreateResponse (TicketReservationRequest, TicketReservationResponse);

            if (ValidTicketRequest (TicketReservationRequest, TicketReservationResponse)) then begin
              TicketCreated := TicketCreated and CreateTicket (TicketReservationRequest, TicketReservationResponse);

            end else begin
              TicketCreated := false;
            end;
          until (TicketReservationRequest.Next () = 0);

          if (not TicketCreated) then
            TicketRequestManager.DeleteReservationRequest (Token, false);

          exit;
        end;

        TicketReservationRequest.Reset ();
        TicketReservationRequest.SetFilter ("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindSet ()) then begin
          CreateResponse (TicketReservationRequest, TicketReservationResponse);
          TicketReservationResponse."Response Message" := StrSubstNo (TOKEN_INCORRECT_STATE, Token, TicketReservationRequest."Request Status");
          TicketReservationResponse.Status := false;
          TicketReservationResponse.Modify ();
        end;
    end;

    local procedure ImportTicketConfirmation(XmlDoc: DotNet XmlDocument;RequestEntryNo: Integer;DocumentID: Text[100])
    var
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        XmlElement: DotNet XmlElement;
        XmlNodeList: DotNet XmlNodeList;
        i: Integer;
        Token: Text[100];
        ResponseMessage: Text;
    begin

        if IsNull(XmlDoc) then
          exit;
        XmlElement := XmlDoc.DocumentElement;
        if IsNull(XmlElement) then
          exit;

        if not NpXmlDomMgt.FindNodes(XmlElement,'ticket_tokens',XmlNodeList) then
          exit;

        for i := 0 to XmlNodeList.Count - 1 do begin
          XmlElement := XmlNodeList.ItemOf(i);

          Token := NpXmlDomMgt.GetXmlText(XmlElement,'ticket_token', MaxStrLen (Token), false);

          TicketRequestManager.SetReservationRequestExtraInfo (Token,
            NpXmlDomMgt.GetXmlText (XmlElement,'send_notification_to', 80, false),
            NpXmlDomMgt.GetXmlText (XmlElement,'external_order_no', 80, false));

          // Response is updated with a soft fail message if confirm fails.
          TicketRequestManager.ConfirmReservationRequest (Token, ResponseMessage);

        end;
    end;

    local procedure ImportTicketCancelation(XmlDoc: DotNet XmlDocument;RequestEntryNo: Integer;DocumentID: Text[100])
    var
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        XmlElement: DotNet XmlElement;
        XmlNodeList: DotNet XmlNodeList;
        i: Integer;
        Token: Text[100];
        TicketReservationResponse: Record "TM Ticket Reservation Response";
    begin

        if IsNull(XmlDoc) then
          exit;
        XmlElement := XmlDoc.DocumentElement;
        if IsNull(XmlElement) then
          exit;

        if not NpXmlDomMgt.FindNodes(XmlElement,'ticket_tokens',XmlNodeList) then
          exit;

        Token := CopyStr (NpXmlDomMgt.GetXmlAttributeText(XmlElement,'ticket_token',false), 1, MaxStrLen (Token));
        if (Token = '') then
          Token := DocumentID;

        TicketRequestManager.DeleteReservationTokenRequest (Token);

        //XCOMMIT;
    end;

    local procedure ImportTicketReservationConfirmArriveDoc(XmlDoc: DotNet XmlDocument;RequestEntryNo: Integer;DocumentID: Text[100])
    var
        XmlElement: DotNet XmlElement;
        XmlNodeList: DotNet XmlNodeList;
        i: Integer;
        Token: Text[50];
        MemberTicketManager: Codeunit "MM Member Ticket Manager";
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        TmpTicketReservationRequest: Record "TM Ticket Reservation Request" temporary;
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        TicketReservationResponse: Record "TM Ticket Reservation Response";
        TicketReservationResponse2: Record "TM Ticket Reservation Response";
        TicketCreated: Boolean;
        ReusedToken: Text;
        ResponseMessage: Text;
    begin
        //-TM1.08
        TicketRequestManager.ExpireReservationRequests ();

        if IsNull(XmlDoc) then
          exit;
        XmlElement := XmlDoc.DocumentElement;
        if IsNull(XmlElement) then
          exit;

        if not NpXmlDomMgt.FindNodes(XmlElement,'ticket_tokens',XmlNodeList) then
          exit;

        Token := CopyStr (NpXmlDomMgt.GetXmlAttributeText(XmlElement,'ticket_token',false), 1, MaxStrLen (Token));
        if (Token = '') then
          Token := DocumentID;

        if TicketRequestManager.TokenRequestExists (Token) then
          TicketRequestManager.DeleteReservationRequest (Token, true);

        if not NpXmlDomMgt.FindNodes(XmlElement,'ticket',XmlNodeList) then
          exit;

        //-#335889 [335889] refactoring ***
        for i := 0 to XmlNodeList.Count - 1 do begin
          XmlElement := XmlNodeList.ItemOf(i);
          InsertTemporaryTicketReservation (XmlElement, Token, TmpTicketReservationRequest);
        end;

        TmpTicketReservationRequest.Reset ();
        if (TmpTicketReservationRequest.IsEmpty()) then
          Error ('Houston, we have a problem! 6060116.CreateTicketRequest() said ok, but token %1 was NOT found.', Token);

        // precheck member guest
        MemberTicketManager.PreValidateMemberGuestTicketRequest (TmpTicketReservationRequest, true);

        //-TM1.40 [350287]
        if (TicketRequestManager.RevalidateRequestForTicketReuse (TmpTicketReservationRequest, ReusedToken, ResponseMessage)) then begin
          // duplicate the previous response so SOAP Service gets a valid response
          TicketReservationResponse.SetFilter ("Session Token ID", '=%1', ReusedToken);
          if (TicketReservationResponse.FindSet ()) then begin
            repeat
              TicketReservationResponse2.TransferFields (TicketReservationResponse, false);
              TicketReservationResponse2."Entry No." := 0;
              TicketReservationResponse2."Session Token ID" := Token;
              TicketReservationResponse2.Insert ();
            //-TM1.41 [353736]
            //UNTIL (TicketReservationRequest.NEXT () = 0);
            until (TicketReservationResponse.Next () = 0);
            //-TM1.41 [353736]
          end;
          exit;
        end;
        //+TM1.40 [350287]


        TmpTicketReservationRequest.Reset ();
        TmpTicketReservationRequest.FindSet ();
        repeat
          TicketReservationRequest.TransferFields (TmpTicketReservationRequest, false);
          TicketReservationRequest."Entry No." := 0;
          TicketReservationRequest.Insert ();
        until (TmpTicketReservationRequest.Next () = 0);
        //+#335889 [335889]


        TicketReservationRequest.SetCurrentKey ("Session Token ID");
        TicketReservationRequest.SetFilter ("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindSet (true,false)) then begin
          TicketCreated := true;
          repeat
            CreateResponse (TicketReservationRequest, TicketReservationResponse);

            if (ValidTicketRequest (TicketReservationRequest, TicketReservationResponse)) then begin
              TicketCreated := TicketCreated and CreateTicket (TicketReservationRequest, TicketReservationResponse);

            end else begin
              TicketCreated := false;
            end;

          until ((TicketReservationRequest.Next () = 0));
        end;

        //-#335889 [335889]
        // MemberTicketManager.ValidateMemberAssignedTickets (Token, TRUE);
        //+#335889 [335889]

        TicketRequestManager.ConfirmReservationRequestWithValidate (Token);
        TicketRequestManager.RegisterArrivalRequest (Token);
    end;

    local procedure ImportTicketAttributes(XmlDoc: DotNet XmlDocument;RequestEntryNo: Integer;DocumentID: Text[100])
    var
        Token: Text[50];
        AdmissionCode: Code[20];
        AttributeCode: Code[20];
        AttributeValue: Text[250];
        XmlElement: DotNet XmlElement;
        XmlNodeList: DotNet XmlNodeList;
        i: Integer;
    begin
        //-TM1.23 [284752]

        if IsNull(XmlDoc) then
          exit;

        XmlElement := XmlDoc.DocumentElement;
        if IsNull(XmlElement) then
          exit;

        if not NpXmlDomMgt.FindNodes(XmlElement,'set_attributes',XmlNodeList) then
          exit;

        Token := CopyStr (NpXmlDomMgt.GetXmlAttributeText(XmlElement,'token',false), 1, MaxStrLen (Token));
        if (Token = '') then
          Token := DocumentID;

        if not NpXmlDomMgt.FindNodes (XmlElement, 'attribute', XmlNodeList) then
          exit;

        // Pass one - blank Admission Code
        for i := 0 to XmlNodeList.Count - 1 do begin
          XmlElement := XmlNodeList.ItemOf(i);

          AdmissionCode := 'not_blank';
          AdmissionCode := CopyStr (NpXmlDomMgt.GetXmlAttributeText (XmlElement, 'admission_code', false), 1, MaxStrLen (AdmissionCode));
          AttributeCode := CopyStr (NpXmlDomMgt.GetXmlAttributeText (XmlElement, 'attribute_code', true), 1, MaxStrLen (AttributeCode));
          AttributeValue := CopyStr (NpXmlDomMgt.GetXmlAttributeText (XmlElement, 'attribute_value', true), 1, MaxStrLen (AttributeValue));

          if (AdmissionCode = '') then
            ApplyAttributes (Token, '', AttributeCode, AttributeValue);

        end;

        if not NpXmlDomMgt.FindNodes (XmlElement, 'attribute', XmlNodeList) then
          exit;
        // Pass two - specific Admission Code
        for i := 0 to XmlNodeList.Count - 1 do begin
          XmlElement := XmlNodeList.ItemOf(i);

          AdmissionCode := '';
          AdmissionCode := CopyStr (NpXmlDomMgt.GetXmlAttributeText (XmlElement, 'admission_code', false), 1, MaxStrLen (AdmissionCode));
          AttributeCode := CopyStr (NpXmlDomMgt.GetXmlAttributeText (XmlElement, 'attribute_code', true), 1, MaxStrLen (AttributeCode));
          AttributeValue := CopyStr (NpXmlDomMgt.GetXmlAttributeText (XmlElement, 'attribute_value', true), 1, MaxStrLen (AttributeValue));

         if (AdmissionCode <> '') then
           ApplyAttributes (Token, AdmissionCode, AttributeCode, AttributeValue);

        end;
        //+TM1.23 [284752]
    end;

    local procedure "---Database"()
    begin
    end;

    local procedure CreateResponse(var TicketReservationRequest: Record "TM Ticket Reservation Request";var TicketReservationResponse: Record "TM Ticket Reservation Response"): Boolean
    var
        TicketReservationRequest2: Record "TM Ticket Reservation Request";
    begin

        // One response per external line ref
        TicketReservationRequest2.SetCurrentKey ("Session Token ID", "Ext. Line Reference No.");
        TicketReservationRequest2.SetFilter ("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
        TicketReservationRequest2.SetFilter ("Ext. Line Reference No.", '=%1', TicketReservationRequest."Ext. Line Reference No.");
        if (not TicketReservationRequest2.FindFirst ()) then
          exit (false);

        TicketReservationResponse.Reset ();
        TicketReservationResponse.SetCurrentKey ("Request Entry No.");
        TicketReservationResponse.SetFilter ("Request Entry No.", '=%1', TicketReservationRequest2."Entry No.");
        if (not TicketReservationResponse.FindFirst ()) then begin
          TicketReservationResponse.Init ();
          TicketReservationResponse."Entry No." := 0;
          TicketReservationResponse."Request Entry No." := TicketReservationRequest2."Entry No.";
          TicketReservationResponse."Session Token ID" := TicketReservationRequest."Session Token ID";
          TicketReservationResponse."Exires (Seconds)" := 1500;
          TicketReservationResponse.Status := true;
          TicketReservationResponse.Confirmed := false;
          TicketReservationResponse.Insert ();

        end;

        exit (true);
    end;

    local procedure CreateTicket(var TicketReservationRequest: Record "TM Ticket Reservation Request";var TicketReservationResponse: Record "TM Ticket Reservation Response"): Boolean
    var
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        ResponseMessage: Text;
        ResponseCode: Integer;
    begin

        TicketReservationRequest."Expires Date Time" := CurrentDateTime + TicketReservationResponse."Exires (Seconds)" * 1000;
        TicketReservationRequest."Request Status" := TicketReservationRequest."Request Status"::REGISTERED;
        TicketReservationRequest.Modify ();

        // commit is required when/if IssueTicket throws an error, or the reservation and response will be rolled back as well
        Commit ();
        TicketRequestManager.LockResources ();

        ResponseCode := TicketRequestManager.IssueTicketFromReservation (TicketReservationRequest, false, ResponseMessage);

        if (ResponseCode <> 0) then begin
          TicketReservationResponse."Response Message" := CopyStr (ResponseMessage, 1, MaxStrLen (TicketReservationResponse."Response Message"));
          TicketRequestManager.DeleteReservationRequest (TicketReservationRequest."Session Token ID", false);
          TicketReservationResponse.Status := false;
        end else begin
          TicketReservationResponse.Status := true;
        end;

        TicketReservationResponse.Modify ();
        exit (TicketReservationResponse.Status);
    end;

    local procedure ValidTicketRequest(var TicketReservationRequest: Record "TM Ticket Reservation Request";var TicketReservationResponse: Record "TM Ticket Reservation Response"): Boolean
    var
        TicketReservationRequest2: Record "TM Ticket Reservation Request";
        Admission: Record "TM Admission";
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        ItemNo: Code[20];
        VariantCode: Code[10];
        ExternalItemType: Integer;
    begin

        if (TicketReservationRequest.Quantity <= 0) then begin
          TicketReservationResponse."Response Message" := StrSubstNo (MUST_BE_POSITIVE);
          TicketReservationResponse.Status := false;
        end;

        if (TicketReservationRequest."Admission Code" <> '') then begin
          if (not Admission.Get (TicketReservationRequest."Admission Code")) then begin
            TicketReservationResponse."Response Message" := StrSubstNo ('Admission Code [%1] is not a valid admission code.', TicketReservationRequest."Admission Code");
            TicketReservationResponse.Status := false;
          end;
        end;

        if (not TicketRequestManager.TranslateBarcodeToItemVariant (TicketReservationRequest."External Item Code", ItemNo, VariantCode, ExternalItemType)) then begin
          TicketReservationResponse."Response Message" := StrSubstNo ('External Item [%1] does not resolve to an internal item.', TicketReservationRequest."External Item Code");
          TicketReservationResponse.Status := false;
        end;

        TicketReservationRequest2.SetFilter ("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
        TicketReservationRequest2.SetFilter ("Entry No.", '<>%1', TicketReservationRequest."Entry No.");
        TicketReservationRequest2.SetFilter ("External Item Code", '=%1', TicketReservationRequest."External Item Code");
        TicketReservationRequest2.SetFilter ("Ext. Line Reference No.", '=%1', TicketReservationRequest."Ext. Line Reference No.");
        TicketReservationRequest2.SetFilter ("Admission Code", '=%1|=%2', '', TicketReservationRequest."Admission Code");

        if (not TicketReservationRequest2.IsEmpty ()) then begin
          TicketReservationResponse."Response Message" := StrSubstNo ('Ambigous ticket request, multiple references for %1 line %2',
            TicketReservationRequest."External Item Code", TicketReservationRequest."Ext. Line Reference No.");
          TicketReservationResponse.Status := false;
        end;

        TicketReservationResponse.Modify ();
        exit (TicketReservationResponse.Status);
    end;

    local procedure InsertTicketReservation(XmlElement: DotNet XmlElement;Token: Text[100];var TicketReservationRequest: Record "TM Ticket Reservation Request")
    begin

        Initialize;

        Clear (TicketReservationRequest);
        TicketReservationRequest."Session Token ID" := Token;
        TicketReservationRequest."Request Status" := TicketReservationRequest."Request Status"::WIP;
        TicketReservationRequest."Created Date Time" := CurrentDateTime ();

        TicketReservationRequest."External Item Code" := CopyStr (NpXmlDomMgt.GetXmlAttributeText (XmlElement, 'external_id', true), 1, MaxStrLen (TicketReservationRequest."External Item Code"));
        Evaluate (TicketReservationRequest.Quantity, NpXmlDomMgt.GetXmlAttributeText (XmlElement, 'qty', true));
        Evaluate (TicketReservationRequest."Ext. Line Reference No.", NpXmlDomMgt.GetXmlAttributeText (XmlElement, 'line_no', true));
        TicketReservationRequest."External Member No." := CopyStr (NpXmlDomMgt.GetXmlAttributeText (XmlElement, 'member_number', false), 1, MaxStrLen (TicketReservationRequest."External Member No."));
        TicketReservationRequest."Admission Code" := CopyStr (NpXmlDomMgt.GetXmlAttributeText (XmlElement, 'admission_code', false), 1, MaxStrLen (TicketReservationRequest."Admission Code"));

        Evaluate (TicketReservationRequest."External Adm. Sch. Entry No.", NpXmlDomMgt.GetXmlAttributeText (XmlElement, 'admission_schedule_entry', false));

        TicketReservationRequest.Insert ();
    end;

    local procedure InsertTemporaryTicketReservation(XmlElement: DotNet XmlElement;Token: Text[100];var TmpTicketReservationRequest: Record "TM Ticket Reservation Request" temporary)
    begin

        //-#335889 [335889]
        Initialize;

        with TmpTicketReservationRequest do begin
          Init;
          TmpTicketReservationRequest."Entry No." := TmpTicketReservationRequest.Count () +1;
          "Session Token ID" := Token;
          "Request Status" := "Request Status"::WIP;
          "Created Date Time" := CurrentDateTime ();

          "External Item Code" := CopyStr (NpXmlDomMgt.GetXmlAttributeText (XmlElement, 'external_id', true), 1, MaxStrLen ("External Item Code"));
          Evaluate (Quantity, NpXmlDomMgt.GetXmlAttributeText (XmlElement, 'qty', true));
          Evaluate ("Ext. Line Reference No.", NpXmlDomMgt.GetXmlAttributeText (XmlElement, 'line_no', true));
          "External Member No." := CopyStr (NpXmlDomMgt.GetXmlAttributeText (XmlElement, 'member_number', false), 1, MaxStrLen ("External Member No."));
          "Admission Code" := CopyStr (NpXmlDomMgt.GetXmlAttributeText (XmlElement, 'admission_code', false), 1, MaxStrLen ("Admission Code"));

          Evaluate ("External Adm. Sch. Entry No.", NpXmlDomMgt.GetXmlAttributeText (XmlElement, 'admission_schedule_entry', false));

          Insert ();
        end;
        //+#335889 [335889]
    end;

    local procedure ApplyAttributes(Token: Text[50];AdmissionCode: Code[20];AttributeCode: Code[20];AttributeValue: Text)
    var
        NPRAttribute: Record "NPR Attribute";
        NPRAttributeID: Record "NPR Attribute ID";
        Admission: Record "TM Admission";
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        TicketReservationResponse: Record "TM Ticket Reservation Response";
        TableId: Integer;
        NPRAttributeManagement: Codeunit "NPR Attribute Management";
    begin

        TableId := DATABASE::"TM Ticket Reservation Request";

        if (not NPRAttribute.Get (AttributeCode)) then
          Error ('Attribute %1 is not valid.', AttributeCode);

        if (not NPRAttributeID.Get (TableId, AttributeCode)) then
          Error ('Attribute %1 is not defined for table with id %2.', AttributeCode, TableId);

        if (AdmissionCode <> '') then
          if (not Admission.Get (AdmissionCode)) then
            Error ('The admission code %1 is not valid.', AdmissionCode);

        // update the request
        TicketReservationRequest.Reset ();
        TicketReservationRequest.SetFilter ("Session Token ID", '=%1', Token);
        if (AdmissionCode <> '') then
          TicketReservationRequest.SetFilter ("Admission Code", '=%1', AdmissionCode);

        if (TicketReservationRequest.IsEmpty ()) then
          Error ('No reservation request found using filter %1.', TicketReservationRequest.GetFilters ());

        TicketReservationRequest.FindSet (false, false);
        repeat
          NPRAttributeManagement.SetEntryAttributeValue (TableId, NPRAttributeID."Shortcut Attribute ID", TicketReservationRequest."Entry No.", AttributeValue);
        until (TicketReservationRequest.Next() = 0);
    end;

    local procedure "--Utils"()
    begin
    end;

    procedure Initialize()
    begin

        if not Initialized then begin
          Initialized := true;
        end;
    end;

    local procedure GetWebserviceFunction(ImportTypeCode: Code[20]) FunctionName: Text[100]
    var
        ImportType: Record "Nc Import Type";
    begin

        Clear (ImportType);
        ImportType.SetFilter (Code, '=%1', ImportTypeCode);
        if (ImportType.FindFirst ()) then ;

        exit (ImportType."Webservice Function");
    end;
}

