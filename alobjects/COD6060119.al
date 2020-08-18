codeunit 6060119 "TM Ticket Request Manager"
{
    // TM1.09/TSA/20160301  CASE 235860 Sell event tickets in POS
    // TM1.09.02/TSA/20160317  CASE 237208 Changed timeframe from 15 seconds to 1500 seconds from registered to expired
    // TM1.11/BR /20160331  CASE 237850 fix determining Valid From Date
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.15/TSA/20160513  CASE 240864 Cancel Ticket
    // TM1.16/TSA/20160622  CASE 245004 function SetReservationRequestExtraInfo
    // TM1.17/TSA/20160913  CASE 251883 Added SMS as Notification Method
    // TM1.17/TSA/20161024  CASE 256133 Added check for not allowing revoke of a used ticket, cancelled
    // TM1.18/TSA/20161213  CASE 260816 Removed marshaller error to use regular error instead.
    // TM1.18/TSA/20170103  CASE 262095 Implemented Revoke Policy
    // TM1.19/TSA/20170215  CASE 266372 Refactored POS_CreateReservationRequest, splitting function into 2
    // TM1.20/TSA/20170321  CASE 270164 Function needs refactoring
    // TM1.20/TSA/20170320  CASE 269171 Support for changing a confirm tickets qty (down)
    // TM1.20/TSA/20170330  CASE 271142 Assigning a closed admission schedule entry must force the schedule entry picker dialog
    // TM1.21/TSA/20170508  CASE 272432 Added harder errors on items that are note configured to be tickets.
    // TM1.21/TSA/20170523  CASE 276898 Made a wrapper on ConfirmReservationRequest
    // TM1.21/TSA/20170525  CASE 278049 Fixing issues report by OMA
    // TM1.22/TSA/20170526  CASE 278142 Added a progress bar when more than 50 tickets are created in one ticket request,
    // TM1.22/TSA/20170526  CASE 278142 Changed function to TicketManagement.CreatePaymentEntryType
    // TM1.22/TSA/20170526  CASE 278142 PREPAID,POSTPAID tickets refund from POS, refund must be handled by issuer handled by us. POS_CreateRevokeRequest
    // NPR5.32.10/TSA/20170616  CASE 250631 Changed Signature of POS_CreateRevokeRequest
    // TM1.23/TSA /20170717 CASE 284248 When the external docno is set, the payment option is set to prepaid.
    // TM1.23/TSA /20170717 CASE 284248 Added function to check if a token has status reservation
    // TM1.23/TSA /20170718 CASE 284248 Payment Option::unpaid does not generate payment entry
    // TM1.23/TSA /20170718 CASE 284248 Added Field "Primary Request Line" in IssueTicket()
    // TM1.23/TSA /20170726 CASE 285079 Added function LockResources()
    // TM1.24/TSA /20170824 CASE 285601 Populated Ticket."Customer No." from Reservation Request
    // TM1.24/NPKNAV/20170925  CASE 285079-01 Transport TM1.24 - 25 September 2017
    // TM1.26/TSA /20171102 CASE 295263 Added a fatal error on missing Ticket BOM
    // TM1.27/TSA /20180112 CASE 302215 Duplicate admissions when recieving multiple lines in the ReserveConfirmArrive message
    // TM1.29/TSA /20180326 CASE 307113 Renamed GetReceiptForToken to GetTokenFromReceipt
    // TM1.29/TSA /20180326 CASE 307113 Added GetReceiptFromToken
    // TM1.30/TSA /20180424 CASE 310947 Reworked the POS_CreateRevokeRequest() function
    // TM1.31/TSA /20180503 CASE 313742 Change precision in rounding in revoke
    // TM1.31/TSA /20180508 CASE 307230 POS_AppendToReservationRequest2 as overload function
    // TM1.31/TSA /20180524 CASE 316500 Added SetCurrentKey to increase the concurrency on multiadmission tickets; TicketReservationRequest.SETCURRENTKEY ("Session Token ID");
    // TM1.31/TSA /20180524 CASE 316500 Added key "Request Status", "Expires Date Time", IsEmpty dropped from 650 reads to 4 according to profiler
    // TM1.31/TSA /20180515 CASE 306040 Handling of negative change of qty on return tickets
    // TM1.36/TSA /20180802 CASE 323737 Reintroduced LockResource for high intensity concurrent web-service interactions
    // TM1.36/TSA /20180820 CASE 325345 Changed Request Status to "Registered" so it is include by the expire function
    // TM1.38/TSA /20181014 CASE 332109 Added eTicket functionality
    // TM1.38/TSA /20181105 CASE 333705 Missing filter on variant code on ticket bom
    // TM1.38/TSA /20181109 CASE 335653 Signature Change on POS_CreateRevokeRequest
    // TM1.38/TSA /20181119 CASE 335653 Refactored GetExternalNo() to exclude alternative number
    // TM1.39/TSA /20190107 CASE 310057 Allowing external source to notify eTicket recipent
    // TM1.39/TSA /20190124 CASE 343585 Revoke for tickets with policy always did not consider multiple admissons codes
    // TM1.43/TSA /20190124 CASE 335889 Refactored ticket request re-validation RevalidateRequestForTicketReuse();
    // TM1.40/TSA /20190327 CASE 350287 Changed signature and filter in RevalidateRequestForTicketReuse()
    // TM1.41/TSA /20190501 CASE 352873 External Item number is same as item number unless variant code is defined
    // TM1.42/TSA /20190826 CASE 364739 Selection of notification address, Signature change on POS_AppendToReservationRequest2
    // TM1.43/TSA /20190904 CASE 357359 Deleting a ticket token must also delete the seating reservation entry
    // TM1.43/TSA /20190910 CASE 368043 Refactored usage of External Item Code
    // TM1.45/TSA /20191113 CASE 322432 Row Seat Section field populated for seating arrangments
    // TM1.45/TSA /20191121 CASE 378212 Added Sales cut-off dates in IssueTicket();
    // TM1.45/TSA /20191202 CASE 374620 Fixed eTicket Status due to Stakeholder notification
    // TM1.45/TSA /20191204 CASE 380754 Waiting List adoption
    // TM1.45/TSA /20191216 CASE 382535 Added assignment of Admission Inclusion when request is created
    // TM1.45/TSA /20200121 CASE 382535 Had to refactor IssueTicket() function break it down in smaller reusable units
    // TM1.47/TSA/20200611  CASE 382535-01 Transport TM1.47 - 11 June 2020


    trigger OnRun()
    begin
    end;

    var
        ITEM_NOT_FOUND: Label 'The sales item specified in external_id %1, was not found.';
        CHANGE_NOT_ALLOWED: Label 'Confirmed tickets can''t be changed.';
        TOKEN_NOT_FOUND: Label 'The ticket-token %1 was not found, or has incorrect state.';
        TOKEN_EXPIRED: Label 'The ticket-token %1 has expired. Use PreConfirm to re-reserve tickets.';
        TOKEN_INCORRECT_STATE: Label 'The ticket-token %1 can''t be changed when in the %1 state.';
        MISSING_CASE: Label 'No handler for %1 [%2].';
        MISSING_SCHEDULE_ENTRY: Label 'Admission Code %1 requires a valid schedule entry.';
        "XREF-NOT-FOUND": Label 'The Item and Variant %1 %2 requires a valid cross reference or alternative no.';
        EXTERNAL_ITEM_CHANGE: Label 'Changing the sales item when there is an active ticket reservation, is not supported. Please delete the POS line and start over.';
        REVOKE_UNUSED_ERROR: Label 'Ticket %1 has been used for entry to %2 at %3 and can''t be revoked due to the revoke policy set on item %4 for admission %5.';
        TICKET_CANCELLED: Label 'Ticket %1 has already been revoked at %2 and can''t be revoked again.';
        REVOKE_NEVER_ERROR: Label 'The revoke policy for ticket %1 set on item %2 for admission %3, does not allow revoke.';
        NOT_TICKET_ITEM: Label 'The item %1 is not configured to be used as a ticket item. Verify that the item has a valid value in field "%2", current value is %3.';
        WRONG_SCH_ENTRY: Label 'Specified admission schedule entry %1 is not for admission %2';
        INVALID_SCH_ENTRY: Label 'Admission schedule entry %1 is not valid.';
        INVALID_POLICY: Label 'Revoke Policy %1 not implemented.';
        showProgressBar: Boolean;
        PREPAID_REFUND: Label 'The ticket admission %1 is prepaid by a different issuer (ref: %2). Do you allow a monetary refund for this admission?';
        POSTPAID_REFUND: Label 'The ticket admission %1 is postpaid by a different issuer (ref: %2). Do you allow a monetary refund for this admission?';
        NO_TICKET_BOM: Label 'The ticket contents has not been defined yet. There are no admissions in the %1 table for %2.';
        MAX_TO_REVOKE: Label 'Maximum number of tickets to revoke is %1.';
        MISSING_RECIPIENT: Label '%1 is blank.';
        NOT_ETICKET: Label '%1 has no %2 marked for %3 in %4.';
        SALES_NOT_STARTED_1200: Label 'Ticket sales does not start until %1 for %2 using ticket item %3 %4.';
        SALES_STOPPED_1201: Label 'Ticket sales ended at %1 for %2 using ticket item %3 %4.';
        WAITINGLIST_REQUIRED_1202: Label 'Waitinglist reference code is required to book a ticket for this time schedule.';
        WAITINGLIST_FAULT_1203: Label 'A problem redeeming the waiting list reference code.';

    procedure LockResources()
    var
        TMTicketReservationRequest: Record "TM Ticket Reservation Request";
        TMTicket: Record "TM Ticket";
        TMTicketAccessEntry: Record "TM Ticket Access Entry";
        TMDetTicketAccessEntry: Record "TM Det. Ticket Access Entry";
        TMTicketReservationResponse: Record "TM Ticket Reservation Response";
    begin

        //-TM1.36 [323737]
        TMTicket.LockTable(true);
        if (TMTicket.FindFirst()) then;
        exit;

        //+TM1.36 [323737]

        //-TM1.23 [285079]
        // LOCKTIMEOUT (FALSE);
        //
        // TMTicketReservationRequest.LOCKTABLE (TRUE);
        // TMTicketReservationResponse.LOCKTABLE (TRUE);
        // TMDetTicketAccessEntry.LOCKTABLE (TRUE);
        // TMTicketAccessEntry.LOCKTABLE (TRUE);
        // TMTicket.LOCKTABLE (TRUE);
        //+TM1.23 [285079]
    end;

    procedure GetNewToken() Token: Code[40]
    begin

        exit(UpperCase(DelChr(Format(CreateGuid), '=', '{}-')));
    end;

    procedure TokenRequestExists(Token: Text[50]): Boolean
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
    begin

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        exit(TicketReservationRequest.FindFirst());
    end;

    procedure DeleteReservationRequest(Token: Text[50]; RemoveRequest: Boolean)
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        TicketReservationResponse: Record "TM Ticket Reservation Response";
        Ticket: Record "TM Ticket";
        TicketAccessEntry: Record "TM Ticket Access Entry";
        DetailedTicketAccessEntry: Record "TM Det. Ticket Access Entry";
        SeatingReservationEntry: Record "TM Seating Reservation Entry";
    begin

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);

        //-TM1.45 [380754]
        // TicketReservationRequest.SETFILTER ("Request Status", '<>%1', TicketReservationRequest."Request Status"::RESERVED);
        TicketReservationRequest.SetFilter ("Request Status", '<>%1 & <>%2', TicketReservationRequest."Request Status"::RESERVED, TicketReservationRequest."Request Status"::WAITINGLIST);
        //+TM1.45 [380754]

        if (TicketReservationRequest.FindSet(true, false)) then begin

            if (TicketReservationRequest."Request Status" = TicketReservationRequest."Request Status"::CONFIRMED) then
                Error(CHANGE_NOT_ALLOWED);

            repeat
                Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");

                if (Ticket.FindSet(true, true)) then begin
                    repeat
                        Ticket.Delete();
                        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
                        if (not TicketAccessEntry.IsEmpty()) then
                            TicketAccessEntry.DeleteAll();
                        DetailedTicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
                        if (not DetailedTicketAccessEntry.IsEmpty()) then
                            DetailedTicketAccessEntry.DeleteAll();

                    until (Ticket.Next = 0);
                end;

            //-TM1.43 [357359]
            SeatingReservationEntry.SetCurrentKey ("Ticket Token");
            SeatingReservationEntry.SetFilter ("Ticket Token", '=%1', Token);
            if (not SeatingReservationEntry.IsEmpty ()) then
              SeatingReservationEntry.DeleteAll ();
            //+TM1.43 [357359]

                if (not RemoveRequest) then begin
                    TicketReservationRequest."Admission Created" := false;
                    TicketReservationRequest."Request Status" := TicketReservationRequest."Request Status"::EXPIRED;
                    TicketReservationRequest."Expires Date Time" := CurrentDateTime + 1500 * 1000;
                    TicketReservationRequest.Modify();
                end;

                if (RemoveRequest) then begin
                    TicketReservationResponse.SetFilter("Session Token ID", '=%1', Token);
                    TicketReservationResponse.DeleteAll();
                    TicketReservationRequest.Delete;
                end;

            until (TicketReservationRequest.Next = 0);

        end;
    end;

    procedure IssueTicketFromReservationToken(Token: Text[100]; FailWithError: Boolean; var ResponseMessage: Text) ResponseCode: Integer
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
    begin

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.FindSet();
        repeat
            ResponseCode := IssueTicketFromReservation(TicketReservationRequest, FailWithError, ResponseMessage);
            if (ResponseCode <> 0) then
                exit(ResponseCode);

        until (TicketReservationRequest.Next() = 0);
    end;

    procedure IssueTicketFromReservation(TicketReservationRequest: Record "TM Ticket Reservation Request"; FailWithError: Boolean; var ResponseMessage: Text) ResponseCode: Integer
    var
        Ticket: Record "TM Ticket";
        TicketBOM: Record "TM Ticket Admission BOM";
        AdmissionUnitPrice: Decimal;
        AdmissionCount: Decimal;
    begin

        TicketReservationRequest.Get(TicketReservationRequest."Entry No.");
        if (TicketReservationRequest."Admission Created") then
            exit(0);

        //-TM1.45 [382535] refactored
        // WITH TicketReservationRequest DO BEGIN
        //  //-TM1.43 [368043]
        //  // IF (NOT TranslateBarcodeToItemVariant ("External Item Code", ItemNo, VariantCode, ResolvingTable)) THEN
        //  //   ERROR (ITEM_NOT_FOUND, "External Item Code");
        //
        //  // ResponseCode := IssueTicket (ItemNo, VariantCode, Quantity, "Entry No.", FailWithError, ResponseMessage);
        //
        //  ResponseCode := IssueTicketOriginal ("Item No.", "Variant Code", Quantity, "Entry No.", FailWithError, ResponseMessage);
        //  //+TM1.43 [368043]
        // END;

        with TicketReservationRequest do begin

          //-TM1.47 [382535]
          //ResponseCode := IssueTicketOriginal ("Item No.","Variant Code", Quantity, "Entry No.", FailWithError, ResponseMessage);
          if (TicketReservationRequest."Request Status" <> TicketReservationRequest."Request Status"::CONFIRMED) then
            // IssueTicketOriginal ("Item No.","Variant Code", Quantity, "Entry No.", FailWithError, ResponseMessage);
            ResponseCode := _IssueNewTickets("Item No.","Variant Code", Quantity, "Entry No.", FailWithError, AdmissionUnitPrice, ResponseMessage);

          if ((TicketReservationRequest."Request Status" = TicketReservationRequest."Request Status"::CONFIRMED) and
              (not TicketReservationRequest."Admission Created")) then begin

            Ticket.SetFilter ("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
            if (Ticket.FindSet ()) then begin
              AdmissionCount := 0;
              repeat
                AdmissionCount += 1;
                ResponseCode := _IssueOneAdmission (FailWithError, TicketReservationRequest, Ticket, TicketReservationRequest."Admission Code", 1, true, AdmissionUnitPrice, ResponseMessage);
                if (ResponseCode <> 0) then
                  exit (ResponseCode);

              until (Ticket.Next () = 0);

              if (AdmissionUnitPrice > 0) then begin

              end;

            end;

          end;
          //+TM1.47 [382535]

        end;
        //+TM1.45 [382535]
    end;

    local procedure IssueTicketOriginal(ItemNo: Code[20];VariantCode: Code[10];Quantity: Integer;RequestEntryNo: Integer;FailWithError: Boolean;var ResponseMessage: Text) ResponseCode: Integer
    var
        Item: Record Item;
        TicketType: Record "TM Ticket Type";
        Ticket: Record "TM Ticket";
        AdmissionSchEntry: Record "TM Admission Schedule Entry";
        ReservationRequest: Record "TM Ticket Reservation Request";
        ReservationRequest2: Record "TM Ticket Reservation Request";
        TicketBom: Record "TM Ticket Admission BOM";
        TicketBom2: Record "TM Ticket Admission BOM";
        Admission: Record "TM Admission";
        TicketAccessEntry: Record "TM Ticket Access Entry";
        TicketManagement: Codeunit "TM Ticket Management";
        NumberOfTickets: Integer;
        TicketQuantity: Integer;
        i: Integer;
        TicketValidDate: Date;
        LowDate: Date;
        HighDate: Date;
        UserSetup: Record "User Setup";
        Window: Dialog;
        WaitingListReferenceCode: Code[10];
        CreateAdmission: Boolean;
    begin

        Item.Get(ItemNo);
        if (not TicketType.Get(Item."Ticket Type")) then begin
            ResponseMessage := StrSubstNo(NOT_TICKET_ITEM, ItemNo, Item.FieldCaption("Ticket Type"), Item."Ticket Type");
            Error(ResponseMessage);
        end;

        if ((not TicketType."Is Ticket") or (TicketType.Code = '')) then begin
            ResponseMessage := StrSubstNo(NOT_TICKET_ITEM, ItemNo, Item.FieldCaption("Ticket Type"), Item."Ticket Type");
            Error(ResponseMessage);
        end;

        //-TM1.26 [295263]
        TicketBom.SetFilter("Item No.", '=%1', ItemNo);
        TicketBom.SetFilter("Variant Code", '=%1', VariantCode);
        if (TicketBom.IsEmpty()) then begin
            ResponseMessage := StrSubstNo(NO_TICKET_BOM, TicketBom.TableCaption, TicketBom.GetFilters);
            Error(ResponseMessage);
        end;
        TicketBom.Reset();
        //+TM1.26 [295263]

        TicketQuantity := Quantity;
        NumberOfTickets := Quantity;

        if (TicketType."Admission Registration" = TicketType."Admission Registration"::GROUP) then
            NumberOfTickets := 1;

        if (TicketType."Admission Registration" = TicketType."Admission Registration"::INDIVIDUAL) then
            TicketQuantity := 1;

        ReservationRequest.Get(RequestEntryNo);
        if (ReservationRequest."Revoke Ticket Request") then
            exit;

        if (GetShowProgressBar()) then
            Window.Open('Creating tickets... @1@@@@@@@@@@@@@');

        for i := 1 to Abs(NumberOfTickets) do begin
            TicketValidDate := Today;
            Ticket.Init;
            Ticket."No." := '';
            Ticket."No. Series" := TicketType."No. Series";
            Ticket."Ticket Type Code" := TicketType.Code;
            Ticket."Item No." := ItemNo;
            Ticket."Variant Code" := VariantCode;
            Ticket."Customer No." := ReservationRequest."Customer No.";
            Ticket."Ticket Reservation Entry No." := RequestEntryNo;
            Ticket."External Member Card No." := ReservationRequest."External Member No.";
            Ticket."Sales Receipt No." := ReservationRequest."Receipt No.";
            Ticket."Line No." := ReservationRequest."Line No.";

            if (UserSetup.Get(CopyStr(UserId, 1, MaxStrLen(UserSetup."User ID")))) then
                Ticket."Salesperson Code" := UserSetup."Salespers./Purch. Code";

            if (Ticket."Salesperson Code" = '') then
                Ticket."Salesperson Code" := CopyStr(UserId, 1, MaxStrLen(Ticket."Salesperson Code"));

            TicketManagement.SetTicketProperties(Ticket, TicketValidDate);
            Ticket.Insert(true);


            // Create Ticket Content
            TicketBom.SetFilter("Item No.", '=%1', ItemNo);
            TicketBom.SetFilter("Variant Code", '=%1', VariantCode);
            if (TicketBom.FindSet()) then begin

            //-TM1.45 [378212]
            ResponseCode := CheckTicketBomSalesDateLimit (FailWithError, TicketBom, Quantity, Today, ResponseMessage);
            if (ResponseCode <> 0) then begin
              if (FailWithError) then
                Error (ResponseMessage);
              exit (ResponseCode);
            end;
            //+TM1.45 [378212]

                //-TM1.23 [285079]
                ReservationRequest."Primary Request Line" := true;
                //+TM1.23 [285079]

                // this is the request we are working with, which may or may not be correct regarding the admission code...
            //-TM1.45 [382535]
            // ReservationRequest."Admission Created" := TRUE;
            ReservationRequest."Admission Created" := (ReservationRequest."Admission Inclusion" <> ReservationRequest."Admission Inclusion"::NOT_SELECTED);
            CreateAdmission := ReservationRequest."Admission Created";
            //-TM1.45 [382535]

                ReservationRequest."Request Status" := ReservationRequest."Request Status"::REGISTERED;
                ReservationRequest."Expires Date Time" := CurrentDateTime + 1500 * 1000;
                ReservationRequest.Modify();

            repeat // Ticket BOM
                    Clear(AdmissionSchEntry);
                    TicketValidDate := Today;

                    Admission.Get(TicketBom."Admission Code");

                    // Lets see if there is a specific request for the admission code, then it might carry some additional scheduling information
                    ReservationRequest2.SetCurrentKey("Session Token ID");
                    ReservationRequest2.SetFilter("Session Token ID", '=%1', ReservationRequest."Session Token ID");
                    ReservationRequest2.SetFilter("Ext. Line Reference No.", '=%1', ReservationRequest."Ext. Line Reference No.");

              //-TM1.43 [368043]
              // ReservationRequest2.SETFILTER ("External Item Code", '=%1', ReservationRequest."External Item Code");
              ReservationRequest2.SetFilter ("Item No.", '=%1', ReservationRequest."Item No.");
              ReservationRequest2.SetFilter ("Variant Code", '=%1', ReservationRequest."Variant Code");
              //+TM1.43 [368043]

                    ReservationRequest2.SetFilter("Admission Code", '=%1', TicketBom."Admission Code");
                    if (ReservationRequest2.FindFirst()) then begin

                WaitingListReferenceCode := ReservationRequest2."Waiting List Reference Code"; //-+TM1.45 [380754]

                        if (ReservationRequest2."External Adm. Sch. Entry No." <> 0) then begin
                            AdmissionSchEntry.SetFilter("External Schedule Entry No.", '=%1', ReservationRequest2."External Adm. Sch. Entry No.");
                            AdmissionSchEntry.SetFilter(Cancelled, '=%1', false);
                            if (AdmissionSchEntry.FindFirst()) then begin

                                if (AdmissionSchEntry."Admission Code" <> TicketBom."Admission Code") then
                                    Error(WRONG_SCH_ENTRY, ReservationRequest2."External Adm. Sch. Entry No.", TicketBom."Admission Code");

                                TicketValidDate := AdmissionSchEntry."Admission Start Date";
                            end;
                        end;

                //-TM1.45 [382535]
                //ReservationRequest2."Admission Created" := TRUE;
                ReservationRequest2."Admission Created" := (ReservationRequest2."Admission Inclusion" <> ReservationRequest2."Admission Inclusion"::NOT_SELECTED);
                CreateAdmission := ReservationRequest2."Admission Created";
                //-TM1.45 [382535]
                        ReservationRequest2."Request Status" := ReservationRequest."Request Status"::REGISTERED;
                        ReservationRequest2."Expires Date Time" := CurrentDateTime + 1500 * 1000;
                        ReservationRequest2.Modify();

                    end else begin

                //-TM1.45 [380754]
                WaitingListReferenceCode := ReservationRequest."Waiting List Reference Code";

                //IF (ReservationRequest."Admission Code" <> '') THEN
                //  TicketBom2.GET (Ticket."Item No.", Ticket."Variant Code", ReservationRequest."Admission Code");
                //+TM1.45 [380754]

                        if (ReservationRequest."External Adm. Sch. Entry No." <> 0) then begin

                            AdmissionSchEntry.SetFilter("External Schedule Entry No.", '=%1', ReservationRequest."External Adm. Sch. Entry No.");
                            AdmissionSchEntry.SetFilter(Cancelled, '=%1', false);
                            if (not AdmissionSchEntry.FindFirst()) then
                                Error(INVALID_SCH_ENTRY, ReservationRequest."External Adm. Sch. Entry No.");

                            TicketValidDate := AdmissionSchEntry."Admission Start Date";

                            if (ReservationRequest."Admission Code" = '') and (AdmissionSchEntry."Admission Code" = TicketBom."Admission Code") then begin
                                Admission.Get(AdmissionSchEntry."Admission Code");
                            end else begin
                                // Schedule Entry is not for this admission
                                Clear(AdmissionSchEntry);
                            end;
                        end;
                    end;

                    TicketBom2.Get(Ticket."Item No.", Ticket."Variant Code", Admission."Admission Code");

                    if (Quantity < 0) then
                        TicketQuantity := Abs(TicketQuantity) * -1;

              //-TM1.45 [380754]
              if (i = 1) then begin
                ResponseCode := ValidateWaitingListReferenceCode (FailWithError, WaitingListReferenceCode, Admission."Admission Code", AdmissionSchEntry, ResponseMessage);
                if (ResponseCode <> 0) then
                  exit (ResponseCode);
              end;
              //+TM1.45 [380754]

              //-TM1.45 [382535]
              // ResponseCode := TicketManagement.CreateAdmissionAccessEntry (FailWithError, Ticket, TicketQuantity * TicketBom2.Quantity, TicketBom2."Admission Code", AdmissionSchEntry, ResponseMessage);
              ResponseCode := 0;
              if (CreateAdmission) then
                ResponseCode := TicketManagement.CreateAdmissionAccessEntry (FailWithError, Ticket, TicketQuantity * TicketBom2.Quantity, TicketBom2."Admission Code", AdmissionSchEntry, ResponseMessage);
              //+TM1.45 [382535]

                    if (ResponseCode <> 0) then begin
                        if (GetShowProgressBar()) then
                            Window.Close();
                        exit(ResponseCode);
                    end;

                    if (GetShowProgressBar()) then
                        if (i mod 10 = 0) then
                            Window.Update(1, Round(i / NumberOfTickets * 10000, 1));

                until (TicketBom.Next() = 0);
            end;

            if (TicketType."Ticket Configuration Source" = TicketType."Ticket Configuration Source"::TICKET_BOM) then begin
                TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
                if (TicketAccessEntry.FindSet()) then begin
                    repeat
                        TicketManagement.GetTicketAccessEntryValidDateBoundery(Ticket, LowDate, HighDate);
                        Ticket."Valid From Date" := LowDate;
                        Ticket."Valid To Date" := HighDate;
                        Ticket.Modify();
                    until (TicketAccessEntry.Next() = 0);
                end;

            end;
        end;

        if (GetShowProgressBar()) then
            Window.Close();
    end;

    local procedure _IssueNewTickets(ItemNo: Code[20];VariantCode: Code[10];Quantity: Integer;RequestEntryNo: Integer;FailWithError: Boolean;AdditionCost: Decimal;var ResponseMessage: Text) ResponseCode: Integer
    var
        Item: Record Item;
        TicketType: Record "TM Ticket Type";
        Ticket: Record "TM Ticket";
        AdmissionSchEntry: Record "TM Admission Schedule Entry";
        ReservationRequest: Record "TM Ticket Reservation Request";
        ReservationRequest2: Record "TM Ticket Reservation Request";
        TicketBom: Record "TM Ticket Admission BOM";
        TicketBom2: Record "TM Ticket Admission BOM";
        Admission: Record "TM Admission";
        TicketAccessEntry: Record "TM Ticket Access Entry";
        TicketManagement: Codeunit "TM Ticket Management";
        NumberOfTickets: Integer;
        TicketQuantity: Integer;
        i: Integer;
        TicketValidDate: Date;
        LowDate: Date;
        HighDate: Date;
        UserSetup: Record "User Setup";
        Window: Dialog;
        WaitingListReferenceCode: Code[10];
        CreateAdmission: Boolean;
        AdditionalAdmissionCosts: Decimal;
    begin

        //-TM1.45 [382535] - refactored
        Item.Get (ItemNo);
        if (not TicketType.Get(Item."Ticket Type")) then begin
          ResponseMessage := StrSubstNo (NOT_TICKET_ITEM, ItemNo, Item.FieldCaption ("Ticket Type"), Item."Ticket Type");
          Error (ResponseMessage);
        end;

        if ((not TicketType."Is Ticket") or (TicketType.Code = '')) then begin
          ResponseMessage := StrSubstNo (NOT_TICKET_ITEM, ItemNo, Item.FieldCaption ("Ticket Type"), Item."Ticket Type");
          Error (ResponseMessage);
        end;

        //-TM1.26 [295263]
        TicketBom.SetFilter ("Item No.", '=%1', ItemNo);
        TicketBom.SetFilter ("Variant Code", '=%1', VariantCode);
        if (TicketBom.IsEmpty ()) then begin
          ResponseMessage := StrSubstNo (NO_TICKET_BOM, TicketBom.TableCaption, TicketBom.GetFilters);
          Error (ResponseMessage);
        end;
        TicketBom.Reset ();
        //+TM1.26 [295263]

        TicketQuantity := Quantity;
        NumberOfTickets := Quantity;

        if (TicketType."Admission Registration" = TicketType."Admission Registration"::GROUP) then
          NumberOfTickets := 1;

        if (TicketType."Admission Registration" = TicketType."Admission Registration"::INDIVIDUAL) then
          TicketQuantity := 1;

        if (Quantity < 0) then
          TicketQuantity := Abs (TicketQuantity) * -1;

        ReservationRequest.Get (RequestEntryNo);
        if (ReservationRequest."Revoke Ticket Request") then
          exit;

        if (GetShowProgressBar()) then
          Window.Open ('Creating tickets... @1@@@@@@@@@@@@@');

        ReservationRequest."Primary Request Line" := true;
        ReservationRequest."Admission Created" := true;
        ReservationRequest."Request Status" := ReservationRequest."Request Status"::REGISTERED;
        ReservationRequest."Expires Date Time" := CurrentDateTime + 1500 * 1000;
        ReservationRequest.Modify ();

        for i := 1 to Abs (NumberOfTickets) do begin
          AdditionalAdmissionCosts := 0;

          ResponseCode := _IssueOneTicket (ItemNo, VariantCode, TicketQuantity, TicketType, ReservationRequest, FailWithError, AdditionalAdmissionCosts, ResponseMessage);
          if (ResponseCode <> 0) then begin
            if (GetShowProgressBar()) then
              Window.Close ();
            exit (ResponseCode);
          end;

          if (GetShowProgressBar()) then
            if (i mod 10 = 0) then
              Window.Update (1, Round (i / NumberOfTickets * 10000, 1));

          AdditionCost += AdditionalAdmissionCosts;

        end;

        if (GetShowProgressBar()) then
          Window.Close ();
        //+TM1.45 [382535]
    end;

    local procedure _IssueOneTicket(ItemNo: Code[20];VariantCode: Code[10];QuantityPerTicket: Integer;TicketType: Record "TM Ticket Type";ReservationRequest: Record "TM Ticket Reservation Request";FailWithError: Boolean;var AdditionalAdmissionCosts: Decimal;var ResponseMessage: Text) ResponseCode: Integer
    var
        Ticket: Record "TM Ticket";
        TicketBom: Record "TM Ticket Admission BOM";
        TicketAccessEntry: Record "TM Ticket Access Entry";
        TicketManagement: Codeunit "TM Ticket Management";
        LowDate: Date;
        HighDate: Date;
        UserSetup: Record "User Setup";
    begin

        //-TM1.45 [382535] - refactored
        Ticket.Init;
        Ticket."No."               := '';
        Ticket."No. Series"        := TicketType."No. Series";
        Ticket."Ticket Type Code"  := TicketType.Code;
        Ticket."Item No."          := ItemNo;
        Ticket."Variant Code"      := VariantCode;
        Ticket."Customer No."      := ReservationRequest."Customer No.";
        Ticket."Ticket Reservation Entry No." := ReservationRequest."Entry No.";
        Ticket."External Member Card No." := ReservationRequest."External Member No.";
        Ticket."Sales Receipt No." := ReservationRequest."Receipt No.";
        Ticket."Line No." := ReservationRequest."Line No.";

        if (UserSetup.Get (CopyStr (UserId, 1, MaxStrLen (UserSetup."User ID")))) then
          Ticket."Salesperson Code" := UserSetup."Salespers./Purch. Code";

        if (Ticket."Salesperson Code" = '') then
          Ticket."Salesperson Code" := CopyStr (UserId, 1, MaxStrLen (Ticket."Salesperson Code"));

        TicketManagement.SetTicketProperties (Ticket, Today);
        Ticket.Insert(true);

        ResponseCode := _IssueAdmissionsAppendToTicket (Ticket, QuantityPerTicket, ReservationRequest, FailWithError, AdditionalAdmissionCosts, ResponseMessage);

        // Update ticket valid from / to dates based on contents
        if (TicketType."Ticket Configuration Source" = TicketType."Ticket Configuration Source"::TICKET_BOM) then begin
          TicketAccessEntry.SetFilter ("Ticket No.", '=%1', Ticket."No.");
          if (TicketAccessEntry.FindSet ()) then begin
            repeat
              TicketManagement.GetTicketAccessEntryValidDateBoundery (Ticket, LowDate, HighDate);
              Ticket."Valid From Date" := LowDate;
              Ticket."Valid To Date" := HighDate;
              Ticket.Modify ();
            until (TicketAccessEntry.Next () = 0);
          end;
        end;
        //+TM1.45 [382535]
    end;

    local procedure _IssueAdmissionsAppendToTicket(Ticket: Record "TM Ticket";QuantityPerTicket: Integer;ReservationRequest: Record "TM Ticket Reservation Request";FailWithError: Boolean;var AdditionalAdmissionCosts: Decimal;var ResponseMessage: Text) ResponseCode: Integer
    var
        TicketBom: Record "TM Ticket Admission BOM";
        AdmissionUnitPrice: Decimal;
    begin

        //-TM1.45 [382535] - refactored
        // Create Ticket Content
        TicketBom.SetFilter ("Item No.", '=%1', Ticket."Item No.");
        TicketBom.SetFilter ("Variant Code", '=%1', Ticket."Variant Code" );
        if (TicketBom.FindSet ()) then begin

          ResponseCode := CheckTicketBomSalesDateLimit (FailWithError, TicketBom, QuantityPerTicket, Today, ResponseMessage);
          if (ResponseCode <> 0) then begin
            if (FailWithError) then
              Error (ResponseMessage);
            exit (ResponseCode);
          end;

          repeat
            AdmissionUnitPrice := 0;

            ResponseCode := _IssueOneAdmission (FailWithError, ReservationRequest, Ticket, TicketBom."Admission Code", QuantityPerTicket, true, AdmissionUnitPrice, ResponseMessage);
            if (ResponseCode <> 0) then
              exit (ResponseCode);

            AdditionalAdmissionCosts += AdmissionUnitPrice;
          until (TicketBom.Next () = 0);
        end;
        //+TM1.45 [382535]
    end;

    local procedure _IssueOneAdmission(FailWithError: Boolean;SourceRequest: Record "TM Ticket Reservation Request";Ticket: Record "TM Ticket";AdmissionCode: Code[20];QuantityPerTicket: Integer;ValidateWaitinglistReference: Boolean;var AdmissionUnitPrice: Decimal;var ResponseMessage: Text) ResponseCode: Integer
    var
        AdmissionSchEntry: Record "TM Admission Schedule Entry";
        ReservationRequest: Record "TM Ticket Reservation Request";
        TicketBom: Record "TM Ticket Admission BOM";
        Admission: Record "TM Admission";
        TicketManagement: Codeunit "TM Ticket Management";
        WaitingListReferenceCode: Code[10];
        CreateAdmission: Boolean;
    begin

        //-TM1.45 [382535] refactored and cleanup
        Clear (AdmissionSchEntry);

        Admission.Get (AdmissionCode);
        TicketBom.Get (Ticket."Item No.", Ticket."Variant Code", AdmissionCode);
        CreateAdmission := (TicketBom."Admission Inclusion" <> TicketBom."Admission Inclusion"::NOT_SELECTED);

        // Lets see if there is a specific request for the admission code, then it might carry some additional scheduling information
        ReservationRequest.SetCurrentKey ("Session Token ID");
        ReservationRequest.SetFilter ("Session Token ID", '=%1', SourceRequest."Session Token ID");
        ReservationRequest.SetFilter ("Ext. Line Reference No.", '=%1', SourceRequest."Ext. Line Reference No.");
        ReservationRequest.SetFilter ("Item No.", '=%1', Ticket."Item No.");
        ReservationRequest.SetFilter ("Variant Code", '=%1', Ticket."Variant Code");
        ReservationRequest.SetFilter ("Admission Code", '=%1', AdmissionCode);
        if (ReservationRequest.FindFirst ()) then begin

          WaitingListReferenceCode := ReservationRequest."Waiting List Reference Code";

          // Does the request carry schedule info for this admission?
          if (ReservationRequest."External Adm. Sch. Entry No." <> 0) then begin
            AdmissionSchEntry.SetFilter ("External Schedule Entry No.", '=%1', ReservationRequest."External Adm. Sch. Entry No.");
            AdmissionSchEntry.SetFilter (Cancelled, '=%1', false);
            if (AdmissionSchEntry.FindFirst ()) then begin

              if (AdmissionSchEntry."Admission Code" <> AdmissionCode) then
                Error (WRONG_SCH_ENTRY, ReservationRequest."External Adm. Sch. Entry No.", AdmissionCode);

            end;
          end;

          ReservationRequest."Admission Created" := (ReservationRequest."Admission Inclusion" <> ReservationRequest."Admission Inclusion"::NOT_SELECTED);
          CreateAdmission := ReservationRequest."Admission Created";
          ReservationRequest."Request Status" := ReservationRequest."Request Status"::REGISTERED;
          ReservationRequest."Expires Date Time" := CurrentDateTime + 1500 * 1000;
          ReservationRequest.Modify ();

        end else begin

          WaitingListReferenceCode := SourceRequest."Waiting List Reference Code";

          // Does the source requests schedule info apply to this admission?
          if (SourceRequest."External Adm. Sch. Entry No." <> 0) then begin
            AdmissionSchEntry.SetFilter ("External Schedule Entry No.", '=%1', SourceRequest."External Adm. Sch. Entry No.");
            AdmissionSchEntry.SetFilter (Cancelled, '=%1', false);
            if (not AdmissionSchEntry.FindFirst ()) then
              Error (INVALID_SCH_ENTRY, SourceRequest."External Adm. Sch. Entry No.");

            if (AdmissionSchEntry."Admission Code" <> AdmissionCode) then
              Clear (AdmissionSchEntry); // Schedule Entry is not for this admission

          end;
        end;

        if (not CreateAdmission) then
          exit (0);

        if (ValidateWaitinglistReference) then begin
          ResponseCode := ValidateWaitingListReferenceCode (FailWithError, WaitingListReferenceCode, Admission."Admission Code", AdmissionSchEntry, ResponseMessage);
          if (ResponseCode <> 0) then
            exit (ResponseCode);
        end;

        ResponseCode := TicketManagement.CreateAdmissionAccessEntry (FailWithError, Ticket, QuantityPerTicket * TicketBom.Quantity, AdmissionCode, AdmissionSchEntry, ResponseMessage);

        AdmissionUnitPrice := TicketBom."Admission Unit Price";
        if ((TicketBom."Admission Inclusion" <> SourceRequest."Admission Inclusion") and (TicketBom."Admission Inclusion" = TicketBom."Admission Inclusion"::NOT_SELECTED)) then
          AdmissionUnitPrice *= -1;

        exit (ResponseCode);
        //+TM1.45 [382535]
    end;

    local procedure ValidateWaitingListReferenceCode(FailWithError: Boolean;WaitingListReferenceCode: Code[10];AdmissionCode: Code[20];var AdmissionSchEntry: Record "TM Admission Schedule Entry";var ResponseMessage: Text) ResponseCode: Integer
    var
        AdmissionSchEntryWaitingList: Record "TM Admission Schedule Entry";
        TicketWaitingList: Record "TM Ticket Waiting List";
        TicketManagement: Codeunit "TM Ticket Management";
        TicketWaitingListMgr: Codeunit "TM Ticket Waiting List Mgr.";
    begin

        //-TM1.45 [380754]
        if (AdmissionSchEntry."Entry No." <= 0) then
          if (not AdmissionSchEntry.Get (TicketManagement.GetCurrentScheduleEntry (AdmissionCode, false))) then
            exit (0); // No default schedule - let someone else worry about that

        if (AdmissionSchEntry."Allocation By" = AdmissionSchEntry."Allocation By"::CAPACITY) then
          exit (0); // Normal

        if (WaitingListReferenceCode = '') then begin
          ResponseCode := -1202;
          ResponseMessage := StrSubstNo ('[%1] - %2', ResponseCode, WAITINGLIST_REQUIRED_1202);
          if (FailWithError) then
            Error (ResponseMessage);
          exit (ResponseCode);
        end;

        if (not TicketWaitingListMgr.GetWaitingListAdmSchEntry (WaitingListReferenceCode, CreateDateTime (Today, Time), true, AdmissionSchEntryWaitingList, TicketWaitingList, ResponseMessage)) then begin
          if (FailWithError) then
            Error (ResponseMessage);
          // WAITINGLIST_FAULT_1203
          exit (-1203);
        end;

        exit (0); // OK
        //+TM1.45 [380754]
    end;

    local procedure CheckTicketBomSalesDateLimit(FailWithError: Boolean;TicketBom: Record "TM Ticket Admission BOM";Quantity: Integer;ReferenceDate: Date;var ResponseMessage: Text) ResponseCode: Integer
    begin

        //+TM1.45 [378212]
        if ((TicketBom.Default) and (Quantity > 0)) then begin

          if ((TicketBom."Sales From Date" <> 0D) and (ReferenceDate < TicketBom."Sales From Date")) then begin
            ResponseMessage := StrSubstNo (SALES_NOT_STARTED_1200, TicketBom."Sales From Date", TicketBom."Admission Code", TicketBom."Item No.", TicketBom."Variant Code");
            if (FailWithError) then
              Error (ResponseMessage);
            ResponseCode := -1200;
            exit (ResponseCode);
          end;

          if ((TicketBom."Sales Until Date" <> 0D) and (ReferenceDate > TicketBom."Sales Until Date")) then begin
            ResponseMessage := StrSubstNo (SALES_STOPPED_1201, TicketBom."Sales Until Date", TicketBom."Admission Code", TicketBom."Item No.", TicketBom."Variant Code");
            if (FailWithError) then
              Error (ResponseMessage);
            ResponseCode := -1201;
            exit (ResponseCode);
          end;

        end;

        exit (0);
        //+TM1.45 [378212]
    end;

    procedure FinalizePayment(Token: Text[100])
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        Ticket: Record "TM Ticket";
        TicketManagement: Codeunit "TM Ticket Management";
    begin

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::CONFIRMED);
        TicketReservationRequest.FindSet();
        repeat
            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
            if (Ticket.FindSet()) then begin
                repeat

                    //-TM1.23 [284248]
                    if (TicketReservationRequest."Payment Option" <> TicketReservationRequest."Payment Option"::UNPAID) then
                        TicketManagement.CreatePaymentEntryType(Ticket, TicketReservationRequest."Payment Option", TicketReservationRequest."External Order No.", TicketReservationRequest."Customer No.");

                until (Ticket.Next() = 0);
            end;
        until (TicketReservationRequest.Next = 0);
    end;

    procedure ConfirmReservationRequest(Token: Text[100]; var ResponseMessage: Text) ReservationConfirmed: Boolean
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        TicketReservationResponse: Record "TM Ticket Reservation Response";
        Ticket: Record "TM Ticket";
        TicketManagement: Codeunit "TM Ticket Management";
    begin

        ReservationConfirmed := true;
        ResponseMessage := '';

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::EXPIRED);
        if (not TicketReservationRequest.IsEmpty()) then begin
            ResponseMessage := StrSubstNo(TOKEN_EXPIRED, Token);
            ReservationConfirmed := false;
        end;

        //TicketReservationRequest.SETFILTER ("Request Status", '=%1', TicketReservationRequest."Request Status"::REGISTERED);
        TicketReservationRequest.SetFilter("Request Status", '=%1|=%2', TicketReservationRequest."Request Status"::REGISTERED, TicketReservationRequest."Request Status"::RESERVED);
        if (not TicketReservationRequest.FindSet()) then begin
            ResponseMessage := StrSubstNo(TOKEN_NOT_FOUND, Token);
            ReservationConfirmed := false;
        end;

        // Rollback changes done
        if (not ReservationConfirmed) then
            asserterror Error('');

        // Update the response object
        TicketReservationResponse.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationResponse.ModifyAll(Status, ReservationConfirmed);
        TicketReservationResponse.ModifyAll(Confirmed, ReservationConfirmed);
        TicketReservationResponse.ModifyAll("Response Message", ResponseMessage);
        if (not ReservationConfirmed) then
            exit(false);

        // **************************
        // Success path

        TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::RESERVED);
        if (not TicketReservationRequest.IsEmpty()) then
            TicketReservationRequest.ModifyAll("Payment Option", TicketReservationRequest."Payment Option"::DIRECT);

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Request Status", '=%1|=%2', TicketReservationRequest."Request Status"::REGISTERED, TicketReservationRequest."Request Status"::RESERVED);

        TicketReservationRequest.ModifyAll("Request Status", TicketReservationRequest."Request Status"::CONFIRMED);
        TicketReservationRequest.ModifyAll("Request Status Date Time", CurrentDateTime);
        TicketReservationRequest.ModifyAll("Expires Date Time", CreateDateTime(0D, 0T));

        FinalizePayment(Token);

        exit(true);
    end;

    procedure ConfirmReservationRequestWithValidate(Token: Text[100])
    var
        ResponseMessage: Text;
    begin

        if (not ConfirmReservationRequest(Token, ResponseMessage)) then
            Error(ResponseMessage);
    end;

    procedure DeleteReservationTokenRequest(Token: Text[100])
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
    begin

        // Cancel a ticket request by deleting it - possible when it has not yet been confirmed.
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.FindSet();

        DeleteReservationRequest(TicketReservationRequest."Session Token ID", true);
    end;

    procedure RevokeReservationTokenRequest(Token: Text[100]; DeferUntilPosting: Boolean; FailWithError: Boolean; ResponseMessage: Text) ReturnCode: Integer
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        Ticket: Record "TM Ticket";
        TicketManagement: Codeunit "TM Ticket Management";
        TicketNo: Code[20];
    begin

        // revoke a ticket request when a ticket has been issued. This will block the created tickets
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindSet()) then begin
            repeat
                TicketReservationRequest."Request Status" := TicketReservationRequest."Request Status"::CANCELED;
                TicketReservationRequest.Modify();

                if (not DeferUntilPosting) then begin
                    ReturnCode := TicketManagement.RevokeTicketAccessEntry(TicketReservationRequest."Revoke Access Entry No.", FailWithError, ResponseMessage);

                    if (ReturnCode <> 0) then
                        exit(ReturnCode);

                end;

            until (TicketReservationRequest.Next() = 0);

        end;

        exit(0);
    end;

    procedure ExpireReservationRequests()
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        TicketReservationRequest2: Record "TM Ticket Reservation Request";
    begin

        // Perforance enhancement
        TicketReservationRequest.SetCurrentKey("Request Status");
        TicketReservationRequest.SetFilter("Expires Date Time", '>%1 & <%2', CreateDateTime(0D, 0T), CurrentDateTime);
        TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::REGISTERED);
        if (not TicketReservationRequest.IsEmpty()) then begin
            if (TicketReservationRequest.FindSet()) then begin
                repeat
                    DeleteReservationRequest(TicketReservationRequest."Session Token ID", false);

                    TicketReservationRequest2.SetCurrentKey("Session Token ID");
                    TicketReservationRequest2.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
                    TicketReservationRequest2.ModifyAll("Request Status", TicketReservationRequest2."Request Status"::EXPIRED);

                    //-#325345 [325345]
                    //TicketReservationRequest2.MODIFYALL ("Expires Date Time", CURRENTDATETIME + 3600 * 1000); // Expired transactions will be retained 1 hour
                    if (TicketReservationRequest."Revoke Ticket Request") then begin
                        TicketReservationRequest2.ModifyAll("Expires Date Time", CurrentDateTime - 10 * 1000); // Revoke transactions will not be retained when it has expired
                    end else begin
                        TicketReservationRequest2.ModifyAll("Expires Date Time", CurrentDateTime + 3600 * 1000); // Expired transactions will be retained 1 hour
                    end;
                    //+#325345 [325345]

                until (TicketReservationRequest.Next() = 0);

                Commit();
                LockResources();
            end;
        end;


        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Request Status");
        TicketReservationRequest.SetFilter("Expires Date Time", '>%1 & <%2', CreateDateTime(0D, 0T), CurrentDateTime);
        TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::EXPIRED);
        if (TicketReservationRequest.FindFirst()) then begin
            if (TicketReservationRequest.FindSet()) then begin
                repeat
                    DeleteReservationRequest(TicketReservationRequest."Session Token ID", true);
                until (TicketReservationRequest.Next() = 0);

                Commit();
                LockResources();
            end;
        end;
    end;

    procedure RegisterArrivalRequest(Token: Text[100])
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        TicketReservationRequest2: Record "TM Ticket Reservation Request";
        TicketReservationResponse: Record "TM Ticket Reservation Response";
        Ticket: Record "TM Ticket";
        TicketManagement: Codeunit "TM Ticket Management";
        ResponseMessage: Text;
    begin
        //-TM1.08

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::CONFIRMED);

        if (not (TicketReservationRequest.FindSet())) then
            Error(TOKEN_NOT_FOUND, Token);

        //-+TM1.20 [270164] TODO: Not might be working the way it should

        repeat
            // Find the linked tickets, ticket can only have reference to one request line (eg the first).
            TicketReservationRequest.TestField("Admission Code");
            Ticket.SetCurrentKey("Ticket Reservation Entry No.");
            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
            if (Ticket.FindSet()) then begin
                repeat

                    // For multiple request lines, loop the admission codes
                    TicketReservationRequest2.SetCurrentKey("Session Token ID");
                    TicketReservationRequest2.SetFilter("Session Token ID", '=%1', Token);

              //-TM1.43 [368043]
              // //-TM1.27 [302215]
              // TicketReservationRequest2.SETFILTER ("External Item Code", '=%1', TicketReservationRequest."External Item Code");
              // //+TM1.27 [302215]
              TicketReservationRequest2.SetFilter ("Item No.", '=%1', TicketReservationRequest."Item No.");
              TicketReservationRequest2.SetFilter ("Variant Code", '=%1', TicketReservationRequest."Variant Code");
              //+TM1.43 [368043]

                    TicketReservationRequest2.FindSet();
                    repeat
                        TicketManagement.ValidateTicketForArrival(0, Ticket."No.", TicketReservationRequest2."Admission Code", TicketReservationRequest2."External Adm. Sch. Entry No.", true, ResponseMessage);
                    until (TicketReservationRequest2.Next() = 0);

                until (Ticket.Next() = 0);
            end;

        until (TicketReservationRequest.Next() = 0);
        //+TM1.08
    end;

    procedure UpdateReservationQuantity(Token: Text[100]; Quantity: Integer)
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
    begin

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::CONFIRMED);
        if (TicketReservationRequest.FindFirst()) then
            Error(CHANGE_NOT_ALLOWED);

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.ModifyAll(Quantity, Quantity);
    end;

    procedure TranslateBarcodeToItemVariant(Barcode: Text[50]; var ItemNo: Code[20]; var VariantCode: Code[10]; var ResolvingTable: Integer) Found: Boolean
    var
        Item: Record Item;
        ItemCrossReference: Record "Item Cross Reference";
        AlternativeNo: Record "Alternative No.";
        ItemVariant: Record "Item Variant";
    begin

        // stolen from CU 6014662 Stock-Take

        ResolvingTable := 0;
        ItemNo := '';
        VariantCode := '';
        if (Barcode = '') then exit(false);

        // Try Item Table
        if (StrLen(Barcode) <= MaxStrLen(Item."No.")) then begin
            if (Item.Get(UpperCase(Barcode))) then begin
                ResolvingTable := DATABASE::Item;
                ItemNo := Item."No.";
                exit(true);
            end;
        end;

        // Try Item Cross Reference
        with ItemCrossReference do begin
            if (StrLen(Barcode) <= MaxStrLen("Cross-Reference No.")) then begin
                SetCurrentKey("Cross-Reference Type", "Cross-Reference No.");
                SetFilter("Cross-Reference Type", '=%1', "Cross-Reference Type"::"Bar Code");
                SetFilter("Cross-Reference No.", '=%1', UpperCase(Barcode));
                SetFilter("Discontinue Bar Code", '=%1', false);
                if (FindFirst()) then begin
                    ResolvingTable := DATABASE::"Item Cross Reference";
                    ItemNo := "Item No.";
                    VariantCode := "Variant Code";
                    exit(true);
                end;
            end;
        end;

        // Try Alternative No
        with AlternativeNo do begin
            if (StrLen(Barcode) <= MaxStrLen("Alt. No.")) then begin
                SetCurrentKey("Alt. No.", Type);
                SetFilter("Alt. No.", '=%1', UpperCase(Barcode));
                SetFilter(Type, '=%1', Type::Item);
                if (FindFirst()) then begin
                    if (not Item.Get(Code)) then
                        exit(false);
                    if ("Variant Code" <> '') then
                        if (not ItemVariant.Get(Code, "Variant Code")) then
                            exit(false);
                    ResolvingTable := DATABASE::"Alternative No.";
                    ItemNo := Code;
                    VariantCode := "Variant Code";
                    exit(true);
                end;
            end;
        end;

        exit(false);
    end;

    procedure CreateReservationRequest(ItemNo: Code[20]; VariantCode: Code[10]; Quantity: Integer; ExternalMemberNo: Code[20]) Token: Text[100]
    begin

        exit(POS_CreateReservationRequest('', 0, ItemNo, VariantCode, Quantity, ExternalMemberNo));
    end;

    procedure SetReservationRequestExtraInfo(Token: Text[100]; NotificationAddress: Text[80]; ExternalOrderNo: Code[20]): Boolean
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
    begin

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (not TicketReservationRequest.FindSet()) then
            exit(false);

        repeat
            TicketReservationRequest."Notification Method" := TicketReservationRequest."Notification Method"::NA;

            if (NotificationAddress <> '') then begin
                if (StrPos(NotificationAddress, '@') > 1) then
                    TicketReservationRequest."Notification Method" := TicketReservationRequest."Notification Method"::EMAIL;

                //-+TM1.17
                if (DelChr(NotificationAddress, '=', '0123456789+- ') = '') then
                    TicketReservationRequest."Notification Method" := TicketReservationRequest."Notification Method"::SMS;

                TicketReservationRequest."Notification Address" := NotificationAddress;
            end;

            TicketReservationRequest."External Order No." := ExternalOrderNo;
            //-TM1.23 [284248]
            if (ExternalOrderNo <> '') then
                TicketReservationRequest."Payment Option" := TicketReservationRequest."Payment Option"::PREPAID;

            if ((TicketReservationRequest."Receipt No." = '') and (TicketReservationRequest."External Order No." = '')) then
                TicketReservationRequest."Payment Option" := TicketReservationRequest."Payment Option"::UNPAID;
            //+TM1.23 [284248]

            TicketReservationRequest.Modify();
        until (TicketReservationRequest.Next = 0);

        exit(true);
    end;

    procedure POS_CreateReservationRequest(SalesReceiptNo: Code[20]; SalesLineNo: Integer; ItemNo: Code[20]; VariantCode: Code[10]; Quantity: Integer; ExternalMemberNo: Code[20]) Token: Text[100]
    var
        ReservationRequest: Record "TM Ticket Reservation Request";
        Admission: Record "TM Admission";
        TicketBom: Record "TM Ticket Admission BOM";
        TicketManagement: Codeunit "TM Ticket Management";
        AdmSchEntry: Record "TM Admission Schedule Entry";
    begin

        Token := GetNewToken();

        TicketBom.SetFilter("Item No.", '=%1', ItemNo);
        TicketBom.SetFilter("Variant Code", '=%1', VariantCode);
        TicketBom.FindSet();

        repeat

            //-TM1.19 [266372] code was inline, now made into function
            POS_AppendToReservationRequest(Token, SalesReceiptNo, SalesLineNo, ItemNo, VariantCode, TicketBom."Admission Code", Quantity, 0, ExternalMemberNo);

        until (TicketBom.Next() = 0);


        exit(Token);
    end;

    procedure POS_AppendToReservationRequest(Token: Text[100]; SalesReceiptNo: Code[20]; SalesLineNo: Integer; ItemNo: Code[20]; VariantCode: Code[10]; AdmissionCode: Code[20]; Quantity: Integer; ExternalAdmissionScheduleEntryNo: Integer; ExternalMemberNo: Code[20])
    begin

        //-TM1.31 [307230] change signature use overload 2
        //-TM1.42 [364739]
        //POS_AppendToReservationRequest2 (Token, SalesReceiptNo, SalesLineNo, ItemNo, VariantCode, AdmissionCode, Quantity, ExternalAdmissionScheduleEntryNo, ExternalMemberNo, '', '');
        POS_AppendToReservationRequest2 (Token, SalesReceiptNo, SalesLineNo, ItemNo, VariantCode, AdmissionCode, Quantity, ExternalAdmissionScheduleEntryNo, ExternalMemberNo, '', '', '');
        //+TM1.42 [364739]
    end;

    procedure POS_AppendToReservationRequest2(Token: Text[100];SalesReceiptNo: Code[20];SalesLineNo: Integer;ItemNo: Code[20];VariantCode: Code[10];AdmissionCode: Code[20];Quantity: Integer;ExternalAdmissionScheduleEntryNo: Integer;ExternalMemberNo: Code[20];ExternalOrderNo: Code[20];CustomerNo: Code[20];NotificationAddress: Text[80])
    var
        ReservationRequest: Record "TM Ticket Reservation Request";
        Admission: Record "TM Admission";
        TicketAdmissionBOM: Record "TM Ticket Admission BOM";
        TicketManagement: Codeunit "TM Ticket Management";
        AdmSchEntry: Record "TM Admission Schedule Entry";
    begin

        //-TM1.19 [266372]

        Admission.Get(AdmissionCode);

        Clear(ReservationRequest);
        ReservationRequest."Entry No." := 0;
        ReservationRequest."Session Token ID" := Token;
        ReservationRequest."Ext. Line Reference No." := 1;
        ReservationRequest."Admission Code" := AdmissionCode;
        ReservationRequest."Receipt No." := SalesReceiptNo;
        ReservationRequest."Line No." := SalesLineNo;

        //-TM1.45 [382535]
        TicketAdmissionBOM.Get (ItemNo, VariantCode, AdmissionCode);
        ReservationRequest."Admission Inclusion" := TicketAdmissionBOM."Admission Inclusion";
        //-TM1.45 [382535]

        ReservationRequest."External Item Code" := GetExternalNo(ItemNo, VariantCode);
        //-TM1.43 [368043]
        ReservationRequest."Item No." := ItemNo;
        ReservationRequest."Variant Code" := VariantCode;
        //+TM1.43 [368043]

        ReservationRequest.Quantity := Quantity;
        ReservationRequest."External Member No." := ExternalMemberNo;
        ReservationRequest."Admission Description" := Admission.Description;

        //-TM1.31 [307230]
        ReservationRequest."External Order No." := ExternalOrderNo;
        ReservationRequest."Customer No." := CustomerNo;
        //+TM1.31 [307230]

        //-TM1.42 [364739]
        ReservationRequest."Notification Method" := ReservationRequest."Notification Method"::NA;
        if (NotificationAddress <> '') then begin
          ReservationRequest."Notification Address" := NotificationAddress;
          ReservationRequest."Notification Method" := ReservationRequest."Notification Method"::SMS;
          if (StrPos (ReservationRequest."Notification Address", '@') > 1) then
            ReservationRequest."Notification Method" := ReservationRequest."Notification Method"::EMAIL;
        end;
        //+TM1.42 [364739]

        if (ExternalAdmissionScheduleEntryNo = 0) then begin
            case Admission."Default Schedule" of
                Admission."Default Schedule"::TODAY,
                Admission."Default Schedule"::NEXT_AVAILABLE:
                    begin
                        if (AdmSchEntry.Get(TicketManagement.GetCurrentScheduleEntry(Admission."Admission Code", true))) then begin
                            //-TM1.20 [271142]
                            // ReservationRequest."External Adm. Sch. Entry No." := AdmSchEntry."External Schedule Entry No.";
                            // ReservationRequest."Scheduled Time Description" := STRSUBSTNO ('%1 - %2', AdmSchEntry."Admission Start Date", AdmSchEntry."Admission Start Time");
                            if (AdmSchEntry."Admission Is" = AdmSchEntry."Admission Is"::OPEN) then begin
                                ReservationRequest."External Adm. Sch. Entry No." := AdmSchEntry."External Schedule Entry No.";
                                ReservationRequest."Scheduled Time Description" := StrSubstNo('%1 - %2', AdmSchEntry."Admission Start Date", AdmSchEntry."Admission Start Time");
                            end;
                            //-TM1.20 [271142]
                        end;
                    end;
            end;

        end else begin
            ReservationRequest."External Adm. Sch. Entry No." := ExternalAdmissionScheduleEntryNo;
        end;

        ReservationRequest."Created Date Time" := CurrentDateTime();
        ReservationRequest."Request Status" := ReservationRequest."Request Status"::WIP;
        ReservationRequest."Request Status Date Time" := CurrentDateTime();
        ReservationRequest."Expires Date Time" := CurrentDateTime + 1500 * 1000;
        ReservationRequest.Insert();

        //+TM1.19 [266372]
    end;

    procedure POS_CreateRevokeRequest(var Token: Text[100]; TicketNo: Code[20]; SalesReceiptNo: Code[20]; SalesLineNo: Integer; var AmountInOut: Decimal; var RevokeQuantity: Integer): Boolean
    var
        Ticket: Record "TM Ticket";
        ReservationRequest: Record "TM Ticket Reservation Request";
        Admission: Record "TM Admission";
        TicketBOM: Record "TM Ticket Admission BOM";
        TicketAccessEntry: Record "TM Ticket Access Entry";
        DetTicketAccessEntry: Record "TM Det. Ticket Access Entry";
        DetTicketAccessEntry2: Record "TM Det. Ticket Access Entry";
        TicketManagement: Codeunit "TM Ticket Management";
        InitialQuantity: Integer;
        TotalRefundAmount: Decimal;
        AdmissionRefundAmount: Decimal;
        TotalPct: Decimal;
        UsePctDistribution: Boolean;
        AdmissionCount: Integer;
        UnitPrice: Decimal;
    begin

        Ticket.Get(TicketNo);

        //-TM1.31 [306040]
        if (Ticket.Blocked) then
            exit(false);
        //+TM1.31 [306040]

        //-+TM1.20 [269171] Check refund price distribution
        TicketBOM.SetFilter("Item No.", '=%1', Ticket."Item No.");
        TicketBOM.SetFilter("Variant Code", '=%1', Ticket."Variant Code"); // -+ #333705 [333705]
        TicketBOM.FindSet();
        repeat
            TotalPct += TicketBOM."Refund Price %";
            AdmissionCount += 1;
        until (TicketBOM.Next() = 0);
        UsePctDistribution := (TotalPct = 100);

        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.FindSet();

        if (Token = '') then
            Token := GetNewToken();

        repeat
            //-#310947 [310947]
            DetTicketAccessEntry2.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
            DetTicketAccessEntry2.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::INITIAL_ENTRY);
            DetTicketAccessEntry2.FindFirst();
            InitialQuantity := DetTicketAccessEntry2.Quantity;
            //+#310947 [310947]

            Admission.Get(TicketAccessEntry."Admission Code");
            AdmissionRefundAmount := 0;

            //-TM1.18 [262095]
            TicketBOM.Get(Ticket."Item No.", Ticket."Variant Code", Admission."Admission Code");
            RevokeQuantity := TicketAccessEntry.Quantity;
            //-#310947 [310947]
            //UnitPrice := AmountInOut;
            UnitPrice := AmountInOut / InitialQuantity;
            //+#310947 [310947]

            case TicketBOM."Revoke Policy" of
                TicketBOM."Revoke Policy"::UNUSED:
                    begin

                        DetTicketAccessEntry.Reset();
                        DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
                        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::ADMITTED);
                        if (DetTicketAccessEntry.FindFirst()) then begin
                            //-TM1.20 [269171]
                            DetTicketAccessEntry2.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
                            DetTicketAccessEntry2.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::INITIAL_ENTRY);
                            DetTicketAccessEntry2.FindFirst();
                            if (TicketAccessEntry.Quantity >= DetTicketAccessEntry2.Quantity) then
                                Error(REVOKE_UNUSED_ERROR, TicketNo, Admission.Description, DetTicketAccessEntry."Created Datetime", Ticket."Item No.", TicketAccessEntry."Admission Code");

                            //-#310947 [310947]
                            //UnitPrice := AmountInOut / DetTicketAccessEntry2.Quantity;
                            //+#310947 [310947]

                            RevokeQuantity := DetTicketAccessEntry2.Quantity - TicketAccessEntry.Quantity;

                            //-#310947 [310947]
                            AmountInOut := UnitPrice * RevokeQuantity;
                            //+#310947 [310947]

                            if (UsePctDistribution) then
                                AdmissionRefundAmount := RevokeQuantity * UnitPrice * TicketBOM."Refund Price %" / 100;

                            if (not UsePctDistribution) then
                                AdmissionRefundAmount := RevokeQuantity * UnitPrice / AdmissionCount;
                            //+TM1.20 [269171]

                        end else begin
                            if (UsePctDistribution) then
                                AdmissionRefundAmount := TicketAccessEntry.Quantity * UnitPrice * TicketBOM."Refund Price %" / 100;

                            if (not UsePctDistribution) then
                                AdmissionRefundAmount := TicketAccessEntry.Quantity * UnitPrice / AdmissionCount;
                        end;

                    end;
                TicketBOM."Revoke Policy"::NEVER:
                    Error(REVOKE_NEVER_ERROR, TicketNo, Ticket."Item No.", TicketAccessEntry."Admission Code");


                TicketBOM."Revoke Policy"::ALWAYS:
                    //   //AdmissionRefundAmount := UnitPrice; //-+TM1.20 [269171] [250631] Full return of Unitprice when always
                    //  AdmissionRefundAmount := AmountInOut; //-=#310947 [310947] Should be amount, not unit prices
                    AdmissionRefundAmount := AmountInOut / AdmissionCount; //-TM1.39 [343585]

                else
                    Error(INVALID_POLICY, TicketBOM."Revoke Policy");
            end;

            DetTicketAccessEntry.Reset();
            DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
            DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::CANCELED);
            if (DetTicketAccessEntry.FindFirst()) then
                Error(TICKET_CANCELLED, TicketNo, DetTicketAccessEntry."Created Datetime");

            DetTicketAccessEntry.Reset();
            DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
            DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::INITIAL_ENTRY);
            DetTicketAccessEntry.FindFirst();

            // Ticket is prepaid by third party
            DetTicketAccessEntry.Reset();
            DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
            DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::PREPAID);
            if (DetTicketAccessEntry.FindFirst()) then begin
                if (AdmissionRefundAmount <> 0) then
                    if (not Confirm(PREPAID_REFUND, false, Admission."Admission Code", DetTicketAccessEntry."Sales Channel No.")) then
                        AdmissionRefundAmount := 0;
            end;

            // Ticket will be post paid after admission, by claim from us to third party. we will claim ticket if admission was registered.
            DetTicketAccessEntry.Reset();
            DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
            DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::POSTPAID);
            if (DetTicketAccessEntry.FindFirst()) then begin
                if (AdmissionRefundAmount <> 0) then
                    if (not Confirm(POSTPAID_REFUND, false, Admission."Admission Code", DetTicketAccessEntry."Sales Channel No.")) then
                        AdmissionRefundAmount := 0;
            end;

            TotalRefundAmount += AdmissionRefundAmount;

            Clear(ReservationRequest);
            ReservationRequest."Entry No." := 0;
            ReservationRequest."Session Token ID" := Token;
            ReservationRequest."Ext. Line Reference No." := 1;

          //-TM1.43 [368043]
          ReservationRequest."Item No." := Ticket."Item No.";
          ReservationRequest."Variant Code" := Ticket."Variant Code";
          ReservationRequest."External Item Code" := GetExternalNo (Ticket."Item No.", Ticket."Variant Code");
          //+TM1.43 [368043]

            ReservationRequest."Admission Code" := TicketAccessEntry."Admission Code";
            ReservationRequest."Receipt No." := SalesReceiptNo;
            ReservationRequest."Line No." := SalesLineNo;

            ReservationRequest."External Ticket Number" := Ticket."External Ticket No."; //-+TM1.31 [306040

            ReservationRequest."Revoke Ticket Request" := true;
            ReservationRequest."Revoke Access Entry No." := TicketAccessEntry."Entry No.";
            ReservationRequest.Quantity := RevokeQuantity; //-+TM1.20 [269171]

            ReservationRequest."External Member No." := Ticket."External Member Card No.";
            ReservationRequest."Admission Description" := Admission.Description;

            ReservationRequest."Created Date Time" := CurrentDateTime();
            //-#325345 [325345]
            //ReservationRequest."Request Status" := ReservationRequest."Request Status"::WIP;
            ReservationRequest."Request Status" := ReservationRequest."Request Status"::REGISTERED;
            //+#325345 [325345]

            ReservationRequest."Request Status Date Time" := CurrentDateTime();
            ReservationRequest."Expires Date Time" := CurrentDateTime + 1500 * 1000;
            ReservationRequest.Insert();

        until (TicketAccessEntry.Next() = 0);

        //-TM1.31 [313742]
        //AmountInOut := ROUND (TotalRefundAmount, 1); //-+TM1.20 [269171]
        AmountInOut := Round(TotalRefundAmount, 0.01);
        //+TM1.31 [313742]

        //-TM1.31 [306040]
        exit(true);
        //+TM1.31 [306040]
    end;

    procedure RevalidateRequestForTicketReuse(var TmpTicketReservationRequest: Record "TM Ticket Reservation Request" temporary; var ReusedTokenId: Text; var ResponseMessage: Text): Boolean
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        Ticket: Record "TM Ticket";
        TicketManagement: Codeunit "TM Ticket Management";
        IsRepeatedEntry: Boolean;
        AbortTicketRevalidate: Boolean;
    begin

        //-TM1.43 [335889]
        // Precheck if member has tickets for today with same item numbers and qty. If so try to reuse those tickets.
        IsRepeatedEntry := true;
        //-TM1.40 [350287]
        //TicketReservationRequest.RESET;
        //TicketReservationRequest.FINDSET ();
        TmpTicketReservationRequest.Reset;
        TmpTicketReservationRequest.FindSet();
        //+TM1.40 [350287]

        repeat
          //-TM1.43 [368043]
          //TicketReservationRequest.SETFILTER ("External Item Code", '=%1', TmpTicketReservationRequest."External Item Code");
          TicketReservationRequest.SetFilter ("Item No.", '=%1', TmpTicketReservationRequest."Item No.");
          TicketReservationRequest.SetFilter ("Variant Code", '=%1', TmpTicketReservationRequest."Variant Code");
          //+TM1.43 [368043]
            TicketReservationRequest.SetFilter("External Member No.", '=%1', TmpTicketReservationRequest."External Member No.");
            TicketReservationRequest.SetFilter("Created Date Time", '%1..%2', CreateDateTime(Today, 0T), CreateDateTime(Today, 235959T));
            TicketReservationRequest.SetFilter(Quantity, '=%1', TmpTicketReservationRequest.Quantity);

            IsRepeatedEntry := (IsRepeatedEntry and (TmpTicketReservationRequest."External Member No." <> ''));
            IsRepeatedEntry := (IsRepeatedEntry and TicketReservationRequest.FindLast());
            if (IsRepeatedEntry) then
                TicketReservationRequest.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");

        until (TmpTicketReservationRequest.Next() = 0);

        if (IsRepeatedEntry) then begin

            TicketReservationRequest.Reset();
            TicketReservationRequest.SetCurrentKey("Session Token ID");
            TicketReservationRequest.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
            if (TicketReservationRequest.FindSet()) then begin
                AbortTicketRevalidate := false;

                repeat
                    Ticket.SetCurrentKey("Ticket Reservation Entry No.");
                    Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
                    if (Ticket.FindSet()) then begin
                        repeat
                            AbortTicketRevalidate := (0 <> TicketManagement.ValidateTicketForArrival(0, Ticket."No.", '', 0, false, ResponseMessage));
                        until ((Ticket.Next() = 0) or (AbortTicketRevalidate));
                    end;
                until ((TicketReservationRequest.Next() = 0) or (AbortTicketRevalidate));

                //-TM1.40 [350287]
                // IF (NOT AbortTicketRevalidate) THEN
                //   EXIT (TRUE); // Arrival was successfully registered on tickets previously created - we are done
                if (not AbortTicketRevalidate) then begin
                    ReusedTokenId := TicketReservationRequest."Session Token ID";
                    exit(true); // Arrival was successfully registered on tickets previously created - we are done
                end;
                //+TM1.40 [350287]

            end;
        end;

        exit(false);
        //+TM1.43 [335889]
    end;

    procedure IsReservationRequest(Token: Text[100]): Boolean
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
    begin

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindFirst()) then
            exit(not TicketReservationRequest."Revoke Ticket Request");

        exit(false);
    end;

    procedure IsRevokeRequest(Token: Text[100]): Boolean
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
    begin

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindFirst()) then
            exit(TicketReservationRequest."Revoke Ticket Request");

        exit(false);
    end;

    procedure IsRequestStatusReservation(Token: Text[100]): Boolean
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
    begin

        //-TM1.23 [284248]
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindFirst()) then
            exit(TicketReservationRequest."Request Status" = TicketReservationRequest."Request Status"::RESERVED);

        exit(false);
        //+TM1.23 [284248]
    end;

    procedure GetTokenFromReceipt(ReceiptNo: Code[20]; LineNumber: Integer; var Token: Text[100]): Boolean
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
    begin
        Token := '';

        TicketReservationRequest.SetCurrentKey("Receipt No.");
        TicketReservationRequest.SetFilter("Receipt No.", '=%1', ReceiptNo);
        TicketReservationRequest.SetFilter("Line No.", '=%1', LineNumber);

        if (TicketReservationRequest.FindFirst()) then
            Token := TicketReservationRequest."Session Token ID";

        exit(Token <> '');
    end;

    procedure GetReceiptFromToken(var ReceiptNo: Code[20]; var LineNumber: Integer; Token: Text[100]): Boolean
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
    begin
        ReceiptNo := '';
        LineNumber := 0;

        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (not TicketReservationRequest.FindFirst()) then
            exit(false);

        ReceiptNo := TicketReservationRequest."Receipt No.";
        LineNumber := TicketReservationRequest."Line No.";

        exit(true);
    end;

    procedure SetReceiptForToken(ReceiptNo: Code[20]; LineNumber: Integer; Token: Text[100]): Boolean
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
    begin

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindSet()) then begin
            repeat


            until (TicketReservationRequest.Next() = 0);
            exit(true);

        end;
        exit(false);
    end;

    procedure GetTokenTicket(Token: Text[100]; var TicketNo: Code[20]): Boolean
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        Ticket: Record "TM Ticket";
    begin

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindSet()) then begin
            repeat
                if (TicketReservationRequest."Admission Created") then begin
                    Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
                    if (Ticket.FindFirst()) then begin
                        TicketNo := Ticket."No.";
                        exit(true);
                    end;
                end;
            until (TicketReservationRequest.Next() = 0);
        end;

        exit(false);
    end;

    procedure GetTicketToken(InternalTicketNo: Code[20]; var Token: Text[100]): Boolean
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        Ticket: Record "TM Ticket";
    begin
        Token := '';

        if (not Ticket.Get(InternalTicketNo)) then
            exit(false);

        if (not TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No.")) then
            exit(false);

        Token := TicketReservationRequest."Session Token ID";
        exit(true);
    end;

    procedure GetExternalNo(ItemNo: Code[20]; VariantCode: Code[10]) ExternalNo: Code[50]
    var
        ItemCrossReference: Record "Item Cross Reference";
    begin
        ExternalNo := ItemNo;

        //-TM1.43 [368043]
        //-TM1.41 [352873]
        // IF (VariantCode = '') THEN
        //   EXIT;
        //+TM1.41 [352873]
        //+TM1.43 [368043]

        //-#335653 [335653]
        ItemCrossReference.SetFilter("Item No.", '=%1', ItemNo);
        ItemCrossReference.SetFilter("Variant Code", '=%1', VariantCode);
        ItemCrossReference.SetFilter("Discontinue Bar Code", '=%1', false);
        ItemCrossReference.SetFilter("Cross-Reference Type", '=%1', ItemCrossReference."Cross-Reference Type"::"Bar Code");
        if (ItemCrossReference.FindFirst()) then
            ExternalNo := ItemCrossReference."Cross-Reference No.";

        // IF (VariantCode <> '') THEN BEGIN
        //  AlternativeNo.SETFILTER (Type, '=%1', AlternativeNo.Type::Item);
        //  AlternativeNo.SETFILTER (Code, '=%1', ItemNo);
        //  AlternativeNo.SETFILTER ("Variant Code", '=%1', VariantCode);
        //  IF (AlternativeNo.FINDFIRST ()) THEN BEGIN
        //    ExternalNo := AlternativeNo."Alt. No.";
        //  END ELSE BEGIN
        //    // try item cross ref
        //    ItemCrossReference.SETFILTER ("Item No.", '=%1', ItemNo);
        //    ItemCrossReference.SETFILTER ("Variant Code", '=%1', VariantCode);
        //    ItemCrossReference.SETFILTER ("Cross-Reference Type", '=%1', ItemCrossReference."Cross-Reference Type"::"Bar Code");
        //    IF (ItemCrossReference.FINDFIRST ()) THEN BEGIN
        //      ExternalNo := ItemCrossReference."Cross-Reference No.";
        //    END ELSE BEGIN
        //      ERROR ("XREF-NOT-FOUND", ItemNo, VariantCode);
        //    END;
        //  END;
        // END;
        //+#335653 [335653]

        exit(ExternalNo);
    end;

    procedure POS_OnModifyQuantity(SaleLinePOS: Record "Sale Line POS")
    var
        Token: Text[100];
        ReservationRequest: Record "TM Ticket Reservation Request";
        ReservationResponse: Record "TM Ticket Reservation Response";
        ResponseMessage: Text;
        ResponseCode: Integer;
        Ticket: Record "TM Ticket";
        TicketCount: Integer;
        RevokeQuantity: Integer;
    begin

        if (not (GetTokenFromReceipt(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token))) then
            exit;

        ReservationRequest.SetCurrentKey("Session Token ID");
        ReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (ReservationRequest.FindFirst()) then begin

            //-TM1.31 [306040] Refactored
            if (SaleLinePOS.Quantity > 0) then begin
                if (ReservationRequest.Quantity = SaleLinePOS.Quantity) then
                    exit;

            //-TM1.43 [368043]
            // IF (ReservationRequest."External Item Code" <> GetExternalNo (SaleLinePOS."No.", SaleLinePOS."Variant Code")) THEN  BEGIN
            if (ReservationRequest."Item No." <> SaleLinePOS."No.") or (ReservationRequest."Variant Code" <> SaleLinePOS."Variant Code") then begin
            //+TM1.43 [368043]

                    if (ReservationRequest."Admission Created") then
                        Error(EXTERNAL_ITEM_CHANGE);

                    ReservationRequest.DeleteAll();
                    exit;
                end;

                if (ReservationRequest."Request Status" = ReservationRequest."Request Status"::CONFIRMED) then
                    Error(CHANGE_NOT_ALLOWED);

                DeleteReservationRequest(Token, false);
                UpdateReservationQuantity(Token, SaleLinePOS.Quantity);
                ResponseCode := IssueTicketFromReservationToken(Token, false, ResponseMessage);
                if (ResponseCode <> 0) then
                    Error(ResponseMessage);
            end;

            // Return sales
            if (SaleLinePOS.Quantity < 0) then begin
                Ticket.SetFilter("Sales Receipt No.", '=%1', SaleLinePOS."Return Sale Sales Ticket No.");
                Ticket.SetFilter("Line No.", '=%1', SaleLinePOS."Line No.");
                if (Ticket.FindSet()) then begin
                    DeleteReservationRequest(Token, true);
                    repeat
                        //-#335653 [335653]
                        // IF (POS_CreateRevokeRequest (Token, Ticket."No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", SaleLinePOS."Unit Price")) THEN
                        //  TicketCount += 1;
                        if (POS_CreateRevokeRequest(Token, Ticket."No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", SaleLinePOS."Unit Price", RevokeQuantity)) then
                            TicketCount += RevokeQuantity;
                        //+#335653 [335653]

                    until ((Ticket.Next() = 0) or (TicketCount >= Abs(SaleLinePOS.Quantity)));

                    if (TicketCount < Abs(SaleLinePOS.Quantity)) then
                        Error(MAX_TO_REVOKE, TicketCount);

                end;
            end;
            //+TM1.31 [306040]

        end;
    end;

    procedure OnDeleteSaleLinePos(SaleLinePOS: Record "Sale Line POS")
    var
        Token: Text[100];
        ReservationRequest: Record "TM Ticket Reservation Request";
    begin

        if (not (GetTokenFromReceipt(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token))) then
            exit;

        ReservationRequest.SetCurrentKey("Session Token ID");
        ReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        ReservationRequest.SetFilter("Request Status", '=%1', ReservationRequest."Request Status"::CONFIRMED);
        if (ReservationRequest.IsEmpty()) then
            DeleteReservationRequest(Token, true);
    end;

    procedure ReadyToConfirm(Token: Text[100]): Boolean
    var
        ReservationRequest: Record "TM Ticket Reservation Request";
    begin

        ReservationRequest.SetCurrentKey("Session Token ID");
        ReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        ReservationRequest.SetFilter("Request Status", '=%1', ReservationRequest."Request Status"::REGISTERED);
        exit(ReservationRequest.FindFirst());
    end;

    procedure ReadyToCancel(Token: Text[100]): Boolean
    var
        ReservationRequest: Record "TM Ticket Reservation Request";
    begin

        ReservationRequest.SetCurrentKey("Session Token ID");
        ReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        ReservationRequest.SetFilter("Request Status", '=%1', ReservationRequest."Request Status"::CONFIRMED);
        exit(ReservationRequest.FindFirst());
    end;

    procedure SetTicketMember(Token: Text[100]; ExternalMemberNo: Code[20])
    var
        Ticket: Record "TM Ticket";
        TicketNo: Code[20];
    begin

        if (not (GetTokenTicket(Token, TicketNo))) then
            exit;

        Ticket.Get(TicketNo);
        Ticket."External Member Card No." := ExternalMemberNo;
        Ticket.Modify();
    end;

    procedure SetShowProgressBar(ShowProgressBarIn: Boolean)
    begin
        showProgressBar := (ShowProgressBarIn and GuiAllowed);
    end;

    local procedure GetShowProgressBar(): Boolean
    begin
        exit(showProgressBar);
    end;

    procedure ExportTicketRequestListToClientExcel(var TicketReservationRequest: Record "TM Ticket Reservation Request")
    var
        TicketReservationRequest2: Record "TM Ticket Reservation Request";
        TempFile: File;
        Name: Text;
        NewStream: InStream;
        ToFile: Text;
        ReturnValue: Boolean;
        FileManagement: Codeunit "File Management";
    begin

        // The link to ticket is only on the first request
        TicketReservationRequest.FindFirst();
        TicketReservationRequest2.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
        TicketReservationRequest2.FindFirst();

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetFilter("Entry No.", '=%1', TicketReservationRequest2."Entry No.");
        TicketReservationRequest.FindFirst();

        TempFile.TextMode(false);
        TempFile.WriteMode(true);

        Name := FileManagement.ServerTempFileName('tmp');

        TempFile.Create(Name);
        TempFile.Close;

        REPORT.SaveAsExcel(REPORT::"TM Ticket Batch Response", Name, TicketReservationRequest);

        TempFile.Open(Name);
        TempFile.CreateInStream(NewStream);
        ToFile := 'TicketReport.xls';

        ReturnValue := DownloadFromStream(
          NewStream,
          'Save file to client',
          '',
          'Excel File *.xls| *.xls',
          ToFile);

        TempFile.Close();
    end;

    local procedure "--EVENTS"()
    begin
    end;

    [IntegrationEvent(FALSE, FALSE)]
    procedure OnAfterBlockTicketPublisher(TicketNo: Code[20])
    begin
    end;

    [IntegrationEvent(FALSE, FALSE)]
    procedure OnAfterUnblockTicketPublisher(TicketNo: Code[20])
    begin
    end;

    local procedure "-- NP-Pass eTicket Integration"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060119, 'OnAfterBlockTicketPublisher', '', true, true)]
    local procedure OnAfterBlockTicketSubscriber(TicketNo: Code[20])
    var
        ResponseText: Text;
        Token: Text[100];
    begin

        SendETicketVoidRequest(TicketNo, true, ResponseText);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060119, 'OnAfterUnblockTicketPublisher', '', true, true)]
    local procedure OnAfterUnblockTicketSubscriber(TicketNo: Code[20])
    var
        ResponseText: Text;
        Token: Text[100];
    begin

        SendETicketVoidRequest(TicketNo, false, ResponseText);
    end;

    local procedure SendETicketVoidRequest(TicketNo: Code[20]; VoidETicket: Boolean; var ResponseMessage: Text): Boolean
    var
        TicketNotificationEntry: Record "TM Ticket Notification Entry";
        RecordToText: Text;
    begin

        TicketNotificationEntry.SetFilter("Ticket No.", '=%1', TicketNo);
        TicketNotificationEntry.SetFilter ("Notification Trigger", '=%1', TicketNotificationEntry."Notification Trigger"::ETICKET_CREATE);
        if (TicketNotificationEntry.IsEmpty()) then
            exit(false);

        RecordToText := Format(TicketNotificationEntry, 0, 9);

        TicketNotificationEntry.FindLast();
        TicketNotificationEntry."Notification Trigger" := TicketNotificationEntry."Notification Trigger"::ETICKET_UPDATE;
        TicketNotificationEntry.Voided := VoidETicket;

        if ((RecordToText = Format(TicketNotificationEntry, 0, 9)) and
            (TicketNotificationEntry."Notification Send Status" <> TicketNotificationEntry."Notification Send Status"::FAILED)) then
            exit(false); // We have already sent this message

        TicketNotificationEntry."Entry No." := 0;
        TicketNotificationEntry."Notification Send Status" := TicketNotificationEntry."Notification Send Status"::PENDING;

        //-TM1.45 [374620]
        case VoidETicket of
          true : TicketNotificationEntry."Ticket Trigger Type" := TicketNotificationEntry."Ticket Trigger Type"::CANCEL_RESERVE;
          false: TicketNotificationEntry."Ticket Trigger Type" := TicketNotificationEntry."Ticket Trigger Type"::RESERVE;
        end;
        //+TM1.45 [374620]

        TicketNotificationEntry.Insert();

        //-TM1.39 [310057]
        //EXIT (SendETicketNotification (TicketNotificationEntry."Entry No.", ResponseMessage));
        exit(SendETicketNotification(TicketNotificationEntry."Entry No.", false, ResponseMessage));
        //+TM1.39 [310057]
    end;

    procedure IsETicket(TicketNo: Code[20]): Boolean
    var
        TicketSetup: Record "TM Ticket Setup";
        Ticket: Record "TM Ticket";
        TicketAdmissionBOM: Record "TM Ticket Admission BOM";
    begin

        if (not TicketSetup.Get()) then
            exit(false);

        if (not Ticket.Get(TicketNo)) then
            exit(false);

        TicketAdmissionBOM.SetFilter("Item No.", '=%1', Ticket."Item No.");
        TicketAdmissionBOM.SetFilter("Variant Code", '=%1', Ticket."Variant Code");
        TicketAdmissionBOM.SetFilter("Publish As eTicket", '=%1', true);
        exit(not TicketAdmissionBOM.IsEmpty());
    end;

    procedure CreateAndSendETicket(TicketNo: Code[20]; var ReasonText: Text): Boolean
    var
        Ticket: Record "TM Ticket";
        TmpTicketNotificationEntry: Record "TM Ticket Notification Entry" temporary;
    begin

        Ticket.Get(TicketNo);

        //-TM1.39 [310057]
        //IF (NOT CreateETicketNotificationEntry (Ticket, TmpTicketNotificationEntry, ReasonText)) THEN
        //  EXIT (FALSE);
        if (not CreateETicketNotificationEntry(Ticket, TmpTicketNotificationEntry, false, ReasonText)) then
            exit(false);
        //+TM1.39 [310057]

        TmpTicketNotificationEntry.Reset();
        TmpTicketNotificationEntry.FindSet();
        repeat

            //-TM1.39 [310057]
            // IF (NOT SendETicketNotification (TmpTicketNotificationEntry."Entry No.", ReasonText)) THEN
            //   EXIT (FALSE);

            if (not SendETicketNotification(TmpTicketNotificationEntry."Entry No.", false, ReasonText)) then
                exit(false);
            //+TM1.39 [310057]

        until (TmpTicketNotificationEntry.Next() = 0);

        ReasonText := '';
        exit(true);
    end;

    procedure CreateETicketNotificationEntry(Ticket: Record "TM Ticket"; var TmpNotificationsCreated: Record "TM Ticket Notification Entry" temporary; NotifyWithExternalModule: Boolean; var ReasonText: Text): Boolean
    var
        TicketNotificationEntry: Record "TM Ticket Notification Entry";
        TicketNotificationEntry2: Record "TM Ticket Notification Entry";
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        TicketAdmissionBOM: Record "TM Ticket Admission BOM";
        Admission: Record "TM Admission";
        Admission2: Record "TM Admission";
        TicketType: Record "TM Ticket Type";
        Item: Record Item;
        TicketSetup: Record "TM Ticket Setup";
        TicketAccessEntry: Record "TM Ticket Access Entry";
        DetTicketAccessEntry: Record "TM Det. Ticket Access Entry";
        AdmissionScheduleEntry: Record "TM Admission Schedule Entry";
        SeatingReservationEntry: Record "TM Seating Reservation Entry";
        SeatingTemplate: Record "TM Seating Template";
    begin

        TicketNotificationEntry.Init;
        TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No.");

        //-TM1.39 [310057]
        // If this is an update, duplicate the lines (one per admisson code) and set status pending
        TicketNotificationEntry.SetFilter("Ticket Token", '=%1', TicketReservationRequest."Session Token ID");
        if (TicketNotificationEntry.FindLast()) then begin

            TicketNotificationEntry.SetFilter("Notification Group Id", '=%1', TicketNotificationEntry."Notification Group Id");
            TicketNotificationEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
            if (TicketNotificationEntry.FindSet()) then begin
                repeat
                    TicketNotificationEntry2.TransferFields(TicketNotificationEntry, false);
                    TicketNotificationEntry2."Entry No." := 0;
                    TicketNotificationEntry2."Notification Group Id" += 1;
                    TicketNotificationEntry2."Notification Trigger" := TicketNotificationEntry."Notification Trigger"::ETICKET_UPDATE;

                    TicketNotificationEntry2."Notification Send Status" := TicketNotificationEntry."Notification Send Status"::PENDING;
                    TicketNotificationEntry2.Insert();

                    TmpNotificationsCreated.TransferFields(TicketNotificationEntry2, true);
                    TmpNotificationsCreated.Insert();
                until (TicketNotificationEntry.Next() = 0);

                exit(true);
            end;
        end;
        //+TM1.39 [310057]

        if (TicketReservationRequest."Notification Method" = TicketReservationRequest."Notification Method"::NA) then begin

            //-TM1.39 [310057]
            //  ReasonText := STRSUBSTNO (MISSING_RECIPIENT, TicketReservationRequest.FIELDCAPTION ("Notification Method"));
            //  EXIT (FALSE);

            if (not NotifyWithExternalModule) then begin
                ReasonText := StrSubstNo(MISSING_RECIPIENT, TicketReservationRequest.FieldCaption("Notification Method"));
                exit(false);
            end;
            //+TM1.39 [310057]

        end;

        TicketAdmissionBOM.SetFilter("Item No.", '=%1', Ticket."Item No.");
        TicketAdmissionBOM.SetFilter("Variant Code", '=%1', Ticket."Variant Code");
        TicketAdmissionBOM.SetFilter("Publish As eTicket", '=%1', true);
        if (TicketAdmissionBOM.IsEmpty()) then begin
            ReasonText := StrSubstNo(NOT_ETICKET, Ticket."Item No.", TicketAdmissionBOM.FieldCaption("Admission Code"), TicketAdmissionBOM.FieldCaption("Publish As eTicket"), TicketAdmissionBOM.TableCaption());
            exit(false);
        end;

        TicketSetup.Get();
        Item.Get(Ticket."Item No.");
        TicketType.Get(Ticket."Ticket Type Code");

        TicketAdmissionBOM.FindSet();
        repeat
            Admission.Get(TicketAdmissionBOM."Admission Code");

            TicketNotificationEntry.Init;
            TicketNotificationEntry."Entry No." := 0;
            //-TM1.39 [310057]
            TicketNotificationEntry."Notification Group Id" := 1;
            //-TM1.39 [310057]

            TicketNotificationEntry."Ticket Token" := TicketReservationRequest."Session Token ID";
            TicketNotificationEntry."eTicket Pass Id" := GetNewToken();
            TicketNotificationEntry."Notification Send Status" := TicketNotificationEntry."Notification Send Status"::PENDING;
            case TicketReservationRequest."Notification Method" of
                TicketReservationRequest."Notification Method"::SMS:
                    TicketNotificationEntry."Notification Method" := TicketNotificationEntry."Notification Method"::SMS;
                TicketReservationRequest."Notification Method"::EMAIL:
                    TicketNotificationEntry."Notification Method" := TicketNotificationEntry."Notification Method"::EMAIL;
            end;
            TicketNotificationEntry."Notification Address" := TicketReservationRequest."Notification Address";

            //-TM1.39 [310057]
            if (NotifyWithExternalModule) then begin
                TicketNotificationEntry."Notification Method" := TicketNotificationEntry."Notification Method"::NA;
            end;
            //+TM1.39 [310057]

            TicketNotificationEntry."Notification Trigger" := TicketNotificationEntry."Notification Trigger"::ETICKET_UPDATE;

            TicketNotificationEntry2.SetFilter("Ticket No.", '=%1', Ticket."No.");
            TicketNotificationEntry2.SetFilter("Notification Send Status", '=%1', TicketNotificationEntry2."Notification Send Status"::SENT);
            if (TicketNotificationEntry2.IsEmpty()) then
                TicketNotificationEntry."Notification Trigger" := TicketNotificationEntry."Notification Trigger"::ETICKET_CREATE;

            TicketNotificationEntry."Ticket Type Code" := TicketType.Code;
            TicketNotificationEntry."eTicket Type Code" := TicketType."eTicket Type Code";

            TicketNotificationEntry."Ticket BOM Adm. Description" := TicketAdmissionBOM."Admission Description";
            TicketNotificationEntry."Ticket BOM Description" := TicketAdmissionBOM.Description;

            // Ticket Level data
            TicketNotificationEntry."Ticket No." := Ticket."No.";
            TicketNotificationEntry."Ticket List Price" := Item."Unit Price";
            TicketNotificationEntry."External Ticket No." := Ticket."External Ticket No.";
            TicketNotificationEntry."Ticket No. for Printing" := Ticket."Ticket No. for Printing";
            TicketNotificationEntry."Relevant Datetime" := CreateDateTime(Ticket."Valid From Date", Ticket."Valid From Time");
            TicketNotificationEntry."Relevant Date" := Ticket."Valid From Date";
            TicketNotificationEntry."Relevant Time" := Ticket."Valid From Time";
            TicketNotificationEntry."Expire Datetime" := CreateDateTime(Ticket."Valid To Date", Ticket."Valid To Time");
            TicketNotificationEntry."Expire Date" := Ticket."Valid To Date";
            TicketNotificationEntry."Expire Time" := Ticket."Valid To Time";

            // Admission Level Data
            //-TM1.39 [310057]
            TicketNotificationEntry."Admission Code" := Admission."Admission Code";
            //+TM1.39 [310057]

            TicketNotificationEntry."Adm. Event Description" := Admission.Description;
            if (Admission."eTicket Type Code" <> '') then
                TicketNotificationEntry."eTicket Type Code" := Admission."eTicket Type Code";

            TicketNotificationEntry."Adm. Location Description" := Admission.Description;
            if (Admission."Location Admission Code" <> '') then
                if (Admission2.Get(Admission."Location Admission Code")) then
                    TicketNotificationEntry."Adm. Location Description" := Admission2.Description;

          //-TM1.45 [322432]
          if (Admission."Capacity Control" = Admission."Capacity Control"::SEATING) then begin
            SeatingReservationEntry.SetFilter ("Ticket Token", '=%1', TicketNotificationEntry."Ticket Token");
            SeatingReservationEntry.SetFilter ("Admission Code", '=%1', TicketNotificationEntry."Admission Code");
            if (SeatingReservationEntry.FindSet ()) then begin
              AdmissionScheduleEntry.SetFilter ("External Schedule Entry No.", '=%1', SeatingReservationEntry."External Schedule Entry No.");
              AdmissionScheduleEntry.SetFilter (Cancelled, '=%1', false);
              if (AdmissionScheduleEntry.FindFirst ()) then begin
                TicketNotificationEntry."Event Start Date" := AdmissionScheduleEntry."Admission Start Date";
                TicketNotificationEntry."Event Start Time" := AdmissionScheduleEntry."Admission Start Time";
                TicketNotificationEntry."Relevant Date" := AdmissionScheduleEntry."Admission Start Date";
                TicketNotificationEntry."Relevant Time" := AdmissionScheduleEntry."Event Arrival From Time";
              end;
              TicketNotificationEntry."Quantity To Admit" := 1;
              repeat
                SeatingTemplate.SetFilter ("Admission Code", '=%1', TicketNotificationEntry."Admission Code");
                SeatingTemplate.SetFilter (ElementId, '=%1', SeatingReservationEntry.ElementId);
                if (SeatingTemplate.FindFirst ()) then begin
                  TicketNotificationEntry.Seat := SeatingTemplate.Description;
                  if (SeatingTemplate.Get (SeatingTemplate."Parent Entry No.")) then begin
                    TicketNotificationEntry.Row := SeatingTemplate.Description;
                    if (SeatingTemplate.Get (SeatingTemplate."Parent Entry No.")) then begin
                      TicketNotificationEntry.Section := SeatingTemplate.Description;
                    end;
                  end;
                end;
                TicketNotificationEntry."Entry No." := 0;
                TicketNotificationEntry.Insert ();
                TmpNotificationsCreated.TransferFields (TicketNotificationEntry, true);
                TmpNotificationsCreated.Insert ();
              until (SeatingReservationEntry.Next () = 0);
            end;
          end;
          //+TM1.45 [322432]

          if (Admission."Capacity Control" <> Admission."Capacity Control"::SEATING) then begin //-+TM1.45 [322432]
            TicketAccessEntry.SetFilter ("Ticket No.", '=%1', Ticket."No.");
            TicketAccessEntry.SetFilter ("Admission Code", '=%1', TicketAdmissionBOM."Admission Code");
            if (TicketAccessEntry.FindFirst ()) then begin

              TicketNotificationEntry."Quantity To Admit" := TicketAccessEntry.Quantity;

              DetTicketAccessEntry.SetFilter ("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
              DetTicketAccessEntry.SetFilter (Type, '=%1', DetTicketAccessEntry.Type::RESERVATION);
              if (DetTicketAccessEntry.IsEmpty ()) then
                DetTicketAccessEntry.SetFilter (Type, '=%1', DetTicketAccessEntry.Type::INITIAL_ENTRY);

              if (DetTicketAccessEntry.FindFirst ()) then begin
                AdmissionScheduleEntry.SetFilter ("External Schedule Entry No.", '=%1', DetTicketAccessEntry."External Adm. Sch. Entry No.");
                AdmissionScheduleEntry.SetFilter (Cancelled, '=%1', false);
                if (AdmissionScheduleEntry.FindFirst ()) then begin
                  TicketNotificationEntry."Event Start Date" := AdmissionScheduleEntry."Admission Start Date";
                  TicketNotificationEntry."Event Start Time" := AdmissionScheduleEntry."Admission Start Time";
                  TicketNotificationEntry."Relevant Date" := AdmissionScheduleEntry."Admission Start Date";
                  TicketNotificationEntry."Relevant Time" := AdmissionScheduleEntry."Event Arrival From Time";
                end;
              end;

            end;
            TicketNotificationEntry."Entry No." := 0; //-+TM1.45 [322432]
            TicketNotificationEntry.Insert ();
            TmpNotificationsCreated.TransferFields (TicketNotificationEntry, true);
            TmpNotificationsCreated.Insert ();
          end; //-+TM1.45 [322432]

        until (TicketAdmissionBOM.Next() = 0);

        exit(true);
    end;

    procedure SendETicketNotification(NotificationEntryNo: Integer; NotifyWithExternalModule: Boolean; var ResponseMessage: Text): Boolean
    var
        TicketNotificationEntry: Record "TM Ticket Notification Entry";
    begin
        TicketNotificationEntry.Get(NotificationEntryNo);

        if (TicketNotificationEntry."Notification Send Status" <> TicketNotificationEntry."Notification Send Status"::PENDING) then begin
            ResponseMessage := 'Incorrect send status.';
            exit(false);
        end;

        if (not NotifyWithExternalModule) then begin //-+TM1.39 [310057]
            if (TicketNotificationEntry."Notification Address" = '') then begin
                ResponseMessage := 'Missing notification address.';
                exit(false);
            end;

            if (TicketNotificationEntry."Notification Method" <> TicketNotificationEntry."Notification Method"::SMS) then begin
                ResponseMessage := 'Only SMS is supported.';
                exit(false);
            end;
        end; //-+TM1.39 [310057]

        if (not CreateETicket(TicketNotificationEntry, ResponseMessage)) then begin
            TicketNotificationEntry."Failed With Message" := CopyStr(ResponseMessage, 1, MaxStrLen(TicketNotificationEntry."Failed With Message"));
            TicketNotificationEntry."Notification Send Status" := TicketNotificationEntry."Notification Send Status"::FAILED;
            TicketNotificationEntry.Modify();
            exit(false);
        end;


        if (not NotifyWithExternalModule) then begin //-+TM1.39 [310057]
            if (TicketNotificationEntry."Notification Trigger" = TicketNotificationEntry."Notification Trigger"::ETICKET_CREATE) then begin
                if (not SendSMS(TicketNotificationEntry, ResponseMessage)) then begin
                    TicketNotificationEntry."Failed With Message" := CopyStr(ResponseMessage, 1, MaxStrLen(TicketNotificationEntry."Failed With Message"));
                    TicketNotificationEntry."Notification Send Status" := TicketNotificationEntry."Notification Send Status"::FAILED;
                    TicketNotificationEntry.Modify();
                    exit(false);
                end;
            end;
        end; //-+TM1.39 [310057]

        TicketNotificationEntry."Notification Send Status" := TicketNotificationEntry."Notification Send Status"::SENT;
        TicketNotificationEntry."Notification Sent At" := CurrentDateTime();
        TicketNotificationEntry."Notification Sent By User" := UserId;
        TicketNotificationEntry.Modify;
        ResponseMessage := '';
        Commit; // External System State can not roll back

        exit(true);
    end;

    local procedure CreateETicket(var TicketNotificationEntry: Record "TM Ticket Notification Entry"; var ReasonMessage: Text): Boolean
    var
        TicketSetup: Record "TM Ticket Setup";
        PassData: Text;
    begin

        PassData := GetETicketPassData(TicketNotificationEntry);

        //JObject := JObject.Parse (PassData);
        //MESSAGE ('image type %1', GetStringValue (JObject, 'data.images[:1].type'));
        //ERROR ('Pass Data %1', COPYSTR (PassData, 1, 2048));

        if (TicketSetup.Get()) then
            if (TicketSetup."Show Message Body (Debug)") then
                Message('Pass Data %1', CopyStr(PassData, 1, 2048));

        if (CreatePass(TicketNotificationEntry, PassData, ReasonMessage)) then
            if (not SetPassUrl(TicketNotificationEntry, ReasonMessage)) then
                exit(false);

        exit(true);
    end;

    procedure GetETicketPassData(TicketNotificationEntry: Record "TM Ticket Notification Entry") PassData: Text
    var
        TicketType: Record "TM Ticket Type";
        RecRef: RecordRef;
        instream: InStream;
        templateText: Text;
    begin

        TicketType.Get(TicketNotificationEntry."Ticket Type Code");
        if (not TicketType."eTicket Activated") then
            exit('');

        RecRef.GetTable(TicketNotificationEntry);

        TicketType.CalcFields("eTicket Template");
        if (TicketType."eTicket Template".HasValue()) then begin
            TicketType."eTicket Template".CreateInStream(instream);
            while (not instream.EOS()) do begin
                instream.ReadText(templateText);
                PassData += AssignDataToPassTemplate(RecRef, templateText);
            end;

            if (templateText = '') then begin
                templateText := GetDefaultTemplate();
                PassData += AssignDataToPassTemplate(RecRef, templateText);
            end;

        end else begin
            templateText := GetDefaultTemplate();
            PassData += AssignDataToPassTemplate(RecRef, templateText);
        end;
    end;

    local procedure CreatePass(var TicketNotificationEntry: Record "TM Ticket Notification Entry"; PassData: Text; var ReasonMessage: Text): Boolean
    var
        JSONResult: Text;
    begin

        exit(NPPassServerInvokeApi('PUT', TicketNotificationEntry, ReasonMessage, PassData, JSONResult));
    end;

    local procedure SetPassUrl(var TicketNotificationEntry: Record "TM Ticket Notification Entry"; var ReasonMessage: Text): Boolean
    var
        JSONResult: Text;
        FailReason: Text;
        JObject: DotNet JObject;
    begin

        if not (NPPassServerInvokeApi('GET', TicketNotificationEntry, ReasonMessage, '', JSONResult)) then
            exit(false);

        if (JSONResult = '') then
            exit(false);

        JObject := JObject.Parse(JSONResult);
        TicketNotificationEntry."eTicket Pass Default URL" := GetStringValue(JObject, 'public_url.default');
        TicketNotificationEntry."eTicket Pass Andriod URL" := GetStringValue(JObject, 'public_url.android');
        TicketNotificationEntry."eTicket Pass Landing URL" := GetStringValue(JObject, 'public_url.landing');

        exit(true);
    end;

    local procedure GetStringValue(JObject: DotNet JObject; "Key": Text): Text
    var
        JToken: DotNet JToken;
    begin

        JToken := JObject.SelectToken(Key, false);
        if (IsNull(JToken)) then
            exit('');

        exit(JToken.ToString());
    end;

    procedure AssignDataToPassTemplate(var RecRef: RecordRef; Line: Text) NewLine: Text
    var
        FieldRef: FieldRef;
        "Count": Integer;
        EndPos: Integer;
        FieldNo: Integer;
        i: Integer;
        OptionInt: Integer;
        StartPos: Integer;
        OptionCaption: Text[1024];
        StartSeparator: Text[10];
        EndSeparator: Text[10];
        SeparatorLength: Integer;
        MemberNotificationEntry: Record "MM Member Notification Entry";
        MemberEntryNo: Integer;
        MembershipManagement: Codeunit "MM Membership Management";
        B64Image: Text;
    begin
        StartSeparator := '{[';
        EndSeparator := ']}';
        SeparatorLength := StrLen(StartSeparator);

        NewLine := Line;
        while (StrPos(NewLine, StartSeparator) > 0) do begin
            StartPos := StrPos(NewLine, StartSeparator);
            EndPos := StrPos(NewLine, EndSeparator);

            Evaluate(FieldNo, CopyStr(NewLine, StartPos + SeparatorLength, EndPos - StartPos - SeparatorLength));
            if (RecRef.FieldExist(FieldNo)) then begin

                FieldRef := RecRef.Field(FieldNo);
                if UpperCase(Format(FieldRef.Class)) = 'FLOWFIELD' then
                    FieldRef.CalcField;

                NewLine := DelStr(NewLine, StartPos, EndPos - StartPos + SeparatorLength);

                if (UpperCase(Format(Format(FieldRef.Type)))) = 'OPTION' then begin
                    OptionCaption := Format(FieldRef.OptionString);
                    Evaluate(OptionInt, Format(FieldRef.Value));
                    for i := 1 to OptionInt do
                        OptionCaption := DelStr(OptionCaption, 1, StrPos(OptionCaption, ','));
                    if (StrPos(OptionCaption, ',') <> 0) then
                        OptionCaption := DelStr(OptionCaption, StrPos(OptionCaption, ','));
                    NewLine := InsStr(NewLine, OptionCaption, StartPos);
                end else
                    if (UpperCase(Format(Format(FieldRef.Type)))) = 'DATETIME' then begin
                        NewLine := InsStr(NewLine, Format(FieldRef.Value, 0, 9), StartPos);
                    end else
                        if (UpperCase(Format(Format(FieldRef.Type)))) = 'BOOLEAN' then begin
                            NewLine := InsStr(NewLine, LowerCase(Format(FieldRef.Value, 0, 9)), StartPos);
                        end else begin
                            NewLine := InsStr(NewLine, DelChr(Format(FieldRef.Value), '<=>', '"'), StartPos);
                        end;
            end else
                //    CASE FieldNo OF
                //      -100 : // thumbnail
                //        BEGIN
                //          FieldRef := RecRef.FIELD (MemberNotificationEntry.FIELDNO ("Member Entry No."));
                //          MemberEntryNo := FieldRef.VALUE;
                //
                //          NewLine := DELSTR (NewLine, StartPos, EndPos - StartPos + SeparatorLength);
                //          IF (NOT MembershipManagement.GetMemberImage (MemberEntryNo, B64Image)) THEN
                //              B64Image := '';
                //          NewLine := INSSTR (NewLine, B64Image, StartPos);
                //        END;
                //      ELSE
                //        ERROR(BAD_REFERENCE, FieldNo, Line);
                //    END;
                Line := NewLine;
        end;

        exit(NewLine);
    end;

    procedure GetDefaultTemplate() template: Text
    var
        CRLF: Text[2];
    begin

        CRLF[1] := 13;
        CRLF[2] := 10;

        template :=
        '{"data":{' + CRLF +
            '"customer": {' + CRLF +
            '"email": "{[160]}",' + CRLF +
            '"name": "{[165]}"' + CRLF +
            '},' + CRLF +
            '"event": {' + CRLF +
            ' "description": "{[170]}",' + CRLF +
            '"date": "{[175]}",' + CRLF +
            '"time": "{[176]}",' + CRLF +
            '"title": "{[173]}",' + CRLF +
            '"venue": "{[172]}"' + CRLF +
            '},' + CRLF +
            '"expiration_date": "{[97]}",' + CRLF +
            '"relevant_date": "{[92]}",' + CRLF +
            '"voided": {[98]},' + CRLF +
            '"ticket": {' + CRLF +
            '"barcode": {' + CRLF +
            '"alt_text": "{[100]}",' + CRLF +
            '"value": "{[100]}"' + CRLF +
            '},' + CRLF +
            '"price": "{[65]} DKK",' + CRLF +
            '"quantity": {[180]},' + CRLF +
            '"url": "http://ticket.shop.dummyshop.dk/ticket/{[100]}"' + CRLF +
            '}' + CRLF +
          '}}';

        exit(template);
    end;

    local procedure SendSMS(TicketNotificationEntry: Record "TM Ticket Notification Entry"; var ResponseMessage: Text): Boolean
    var
        RecordRef: RecordRef;
        SMSManagement: Codeunit "SMS Management";
        SMSTemplateHeader: Record "SMS Template Header";
        SmsBody: Text;
    begin

        RecordRef.GetTable(TicketNotificationEntry);

        if (TicketNotificationEntry."Notification Address" = '') then
            ResponseMessage := 'Phone number is missing.';

        if (TicketNotificationEntry."Notification Address" <> '') then begin
            Commit;
            ResponseMessage := 'Template not found.';
            if (SMSManagement.FindTemplate(RecordRef, SMSTemplateHeader)) then begin
                SmsBody := SMSManagement.MakeMessage(SMSTemplateHeader, TicketNotificationEntry);
                SMSManagement.SendSMS(TicketNotificationEntry."Notification Address", SMSTemplateHeader."Alt. Sender", SmsBody);
                ResponseMessage := '';
            end;
        end;

        exit(ResponseMessage = '');
    end;

    procedure NPPassServerInvokeApi(Method: Code[10]; TicketNotificationEntry: Record "TM Ticket Notification Entry"; var ReasonText: Text; JSONIn: Text; var JSONOut: Text): Boolean
    var
        TicketSetup: Record "TM Ticket Setup";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        WebException: DotNet npNetWebException;
        Url: Text;
        ResponseText: Text;
        Exception: DotNet npNetException;
        StatusCode: Code[10];
        StatusDescription: Text[50];
    begin

        TicketSetup.Get();

        ReasonText := '';
        Url := StrSubstNo('%1%2?sync=%3', TicketSetup."NP-Pass Server Base URL",
                                           StrSubstNo(TicketSetup."NP-Pass API", TicketNotificationEntry."eTicket Type Code", TicketNotificationEntry."eTicket Pass Id"),
                                           Format(TicketSetup."NP-Pass Notification Method", 0, 9));

        HttpWebRequest := HttpWebRequest.Create(Url);
        HttpWebRequest.Timeout := 10000;
        HttpWebRequest.KeepAlive(true);

        HttpWebRequest.Method := Method;
        HttpWebRequest.ContentType := 'application/json';
        HttpWebRequest.Accept := 'application/json';
        HttpWebRequest.UseDefaultCredentials(false);
        HttpWebRequest.Headers.Add('Authorization', StrSubstNo('Bearer %1', TicketSetup."NP-Pass Token"));

        NpXmlDomMgt.SetTrustedCertificateValidation(HttpWebRequest);

        if (TrySendWebRequest(JSONIn, HttpWebRequest, HttpWebResponse)) then begin
            TryReadResponseText(HttpWebResponse, ResponseText);
            JSONOut := ResponseText;
            exit(true);
        end;

        ReasonText := StrSubstNo('Error from API %1\\%2', GetLastErrorText, Url);

        Exception := GetLastErrorObject();
        if ((Format(GetDotNetType(Exception.GetBaseException()))) <> (Format(GetDotNetType(WebException)))) then
            Error(Exception.ToString());

        WebException := Exception.GetBaseException();
        TryReadExceptionResponseText(WebException, StatusCode, StatusDescription, ResponseText);

        if (StrLen(ResponseText) > 0) then
            Error(ResponseText);

        if (StrLen(ResponseText) = 0) then
            Error(StrSubstNo(
              '<Fault>' +
                '<faultstatus>%1</faultstatus>' +
                '<faultstring>%2 - %3</faultstring>' +
              '</Fault>',
              StatusCode,
              StatusDescription,
              Url));

        exit(false);
    end;

    [TryFunction]
    local procedure TrySendWebRequest(JSON: Text; HttpWebRequest: DotNet npNetHttpWebRequest; var HttpWebResponse: DotNet npNetHttpWebResponse)
    var
        MemoryStreamOut: DotNet npNetMemoryStream;
        MemoryStreamIn: DotNet npNetMemoryStream;
        Encoding: DotNet npNetEncoding;
    begin

        if (StrLen(JSON) > 0) then begin
            MemoryStreamIn := MemoryStreamIn.MemoryStream(Encoding.UTF8.GetBytes(JSON));
            MemoryStreamOut := HttpWebRequest.GetRequestStream();

            MemoryStreamIn.WriteTo(MemoryStreamOut);

            MemoryStreamOut.Flush;
            MemoryStreamOut.Close;
            Clear(MemoryStreamOut);

            MemoryStreamIn.Close();
            Clear(MemoryStreamIn);
        end;
        HttpWebResponse := HttpWebRequest.GetResponse;
    end;

    [TryFunction]
    local procedure TryReadResponseText(var HttpWebResponse: DotNet npNetHttpWebResponse; var ResponseText: Text)
    var
        StreamReader: DotNet npNetStreamReader;
    begin

        StreamReader := StreamReader.StreamReader(HttpWebResponse.GetResponseStream());

        //ResponseText := HttpWebResponse.Headers().ToString();
        ResponseText := StreamReader.ReadToEnd;

        StreamReader.Close;
        Clear(StreamReader);
    end;

    [TryFunction]
    local procedure TryReadExceptionResponseText(var WebException: DotNet npNetWebException; var StatusCode: Code[10]; var StatusDescription: Text; var ResponseXml: Text)
    var
        StreamReader: DotNet npNetStreamReader;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        WebExceptionStatus: DotNet npNetWebExceptionStatus;
        SystemConvert: DotNet npNetConvert;
        StatusCodeInt: Integer;
        DotNetType: DotNet npNetType;
    begin

        ResponseXml := '';

        // No respone body on time out
        if (WebException.Status.Equals(WebExceptionStatus.Timeout)) then begin
            DotNetType := GetDotNetType(StatusCodeInt);
            StatusCodeInt := SystemConvert.ChangeType(WebExceptionStatus.Timeout, DotNetType);
            StatusCode := Format(StatusCodeInt);
            StatusDescription := WebExceptionStatus.Timeout.ToString();
            exit;
        end;


        // This happens for unauthorized and server side faults (4xx and 5xx)
        // The response stream in unauthorized fails in XML transformation later
        if (WebException.Status.Equals(WebExceptionStatus.ProtocolError)) then begin
            HttpWebResponse := WebException.Response();
            DotNetType := GetDotNetType(StatusCodeInt);
            StatusCodeInt := SystemConvert.ChangeType(HttpWebResponse.StatusCode, DotNetType);
            StatusCode := Format(StatusCodeInt);
            StatusDescription := HttpWebResponse.StatusDescription;
            if (StatusCode[1] = '4') then // 4xx messages
                exit;
        end;

        StreamReader := StreamReader.StreamReader(WebException.Response().GetResponseStream());
        ResponseXml := StreamReader.ReadToEnd;

        StreamReader.Close;
        Clear(StreamReader);
    end;
}

