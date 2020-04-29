codeunit 6060130 "MM Member Ticket Manager"
{
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM80.1.08/TSA/20160222  CASE 232494 Validating Member Assign Tickets in the self service ticket validation
    // MM1.17/TSA/20161208  CASE 259671 Extended functionality for handling the start date of membership, signature change on IsMembershipActive
    // MM1.36/TSA /20181119 CASE 335889 Fixed casting between external and internal item nos
    // MM1.36/TSA /20181119 CASE 335889 Refactored, relocated PromptForMemberGuestArrival() and MemberFastCheckIn()
    // MM1.37/TSA /20190327 CASE 350288 Signature Change
    // MM1.40/TSA /20190812 CASE 364741 Signature Change
    // MM1.41/TSA /20190906 CASE 367779 Signature Change to PromptForMemberGuestArrival() and MemberFastCheckIn() to include token used for ticket arrival
    // MM1.41/TSA /20190910 CASE 368119 Refactored usage of "External Item Code"
    // MM1.42/TSA /20191220 CASE 382728 Refactored usage of Notification Method
    // MM1.43/TSA /20200214 CASE 391044 Incorrect table in BuildMemberGuestRequest ()
    // MM1.43/TSA /20200302 CASE 337112 Printing of tickets from membercard scan
    // MM1.43/TSA /20200305 CASE 337112 Removed green code


    trigger OnRun()
    begin
    end;

    var
        NO_MEMBER: Label 'Member Number must not be blank when validating member ticket assignments.';
        MEMBER_NOT_VALID: Label 'Member Number %1 is not valid.';
        TICKET_COUNT_EXCEEDED: Label 'A maximum of %1 tickets can be assigned for ticket type %2, membership code %3, admission code %4.';
        TOTAL_TICKETS_EXCEEDED: Label 'The total ticket count of %1 is exceeded, membership code %2, admission code %3.';
        TOKEN_NOT_FOUND: Label 'The token %1 was not found.';
        MEMBERSHIP_NOT_ACTIVE: Label 'Membership for member %1, is not active.';
        INVALID_EXTERNAL_ITEM: Label 'The ticket item %1 is not valid in context of membership %2, admission code %3.';
        NOT_SAME_MEMBER: Label 'All request lines need to have the same member number.';
        ErrorReason: Text;
        MEMBERGUEST_TICKET: Label 'Setup for %1 has an invalid entry for membership code %2, admission code %3, item %4. Setup does not match setup in %5.';
        MISSING_CROSSREF: Label 'The external number %1 does not translate to an item. Check Item Cross Reference for setup.';
        WELCOME: Label 'Welcome %1.';
        ILLEGAL_VALUE: Label 'Value %1 is not a valid %2.';

    procedure ValidateMemberAssignedTickets(Token: Text[100];FailWithError: Boolean) Success: Boolean
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        TmpTicketReservationRequest: Record "TM Ticket Reservation Request" temporary;
    begin
        TicketReservationRequest.SetFilter ("Session Token ID", '=%1', Token);
        if (not (TicketReservationRequest.FindSet ())) then
          Error (TOKEN_NOT_FOUND, Token);

        repeat
          TmpTicketReservationRequest.TransferFields (TicketReservationRequest, true);
          TmpTicketReservationRequest.Insert ();
        until (TicketReservationRequest.Next () = 0);

        exit (PreValidateMemberGuestTicketRequest (TmpTicketReservationRequest, FailWithError));
    end;

    procedure PreValidateMemberGuestTicketRequest(var TmpTicketReservationRequest: Record "TM Ticket Reservation Request" temporary;FailWithError: Boolean) Success: Boolean
    var
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        MemberManagement: Codeunit "MM Membership Management";
        MembershipAdmissionSetup: Record "MM Membership Admission Setup";
        MembershipEntryNo: Integer;
        Membership: Record "MM Membership";
        TotalTickets: Integer;
        ExternalMemberNo: Code[20];
        FoundSetup: Boolean;
    begin
        TmpTicketReservationRequest.Reset ();
        TmpTicketReservationRequest.FindSet ();

        if (TmpTicketReservationRequest."External Member No." = '') then begin
          // Not a member guest request
          if (not (FailWithError)) then
            exit (false);
          Error (NO_MEMBER);
        end;


        MembershipEntryNo := MemberManagement.GetMembershipFromExtMemberNo (TmpTicketReservationRequest."External Member No.");
        if (not (MemberManagement.IsMembershipActive (MembershipEntryNo, WorkDate, true))) then begin
          if (not (FailWithError)) then
            exit (false);
          Error (MEMBERSHIP_NOT_ACTIVE, TmpTicketReservationRequest."External Member No.");
        end;

        Membership.Get (MembershipEntryNo);
        ExternalMemberNo := TmpTicketReservationRequest."External Member No.";

        repeat
          TmpTicketReservationRequest.TestField ("Admission Code");

          if (TmpTicketReservationRequest."External Member No." <> ExternalMemberNo) then begin
            if (not (FailWithError)) then
              exit (false);
            Error (NOT_SAME_MEMBER);
          end;

          if (TmpTicketReservationRequest."External Member No." = '') then begin
            if (not (FailWithError)) then
              exit (false);
            Error (NO_MEMBER);
          end;

          MembershipAdmissionSetup.SetFilter ("Ticket No.", '=%1', TmpTicketReservationRequest."External Item Code");
          if (not (MembershipAdmissionSetup.FindFirst ())) then begin
            if (TmpTicketReservationRequest."External Item Code" <> '') then begin
              MembershipAdmissionSetup.Reset ();
              MembershipAdmissionSetup.SetFilter ("Membership  Code", '=%1', Membership."Membership Code");
              MembershipAdmissionSetup.SetFilter ("Admission Code", '=%1', TmpTicketReservationRequest."Admission Code");
              MembershipAdmissionSetup.SetFilter ("Ticket No. Type", '=%1', MembershipAdmissionSetup."Ticket No. Type"::ITEM_CROSS_REF);
              MembershipAdmissionSetup.SetFilter ("Ticket No.", '=%1', TmpTicketReservationRequest."External Item Code");
              FoundSetup := MembershipAdmissionSetup.FindFirst ();
            end;
            if (not FoundSetup) then begin
              MembershipAdmissionSetup.Reset ();
              MembershipAdmissionSetup.SetFilter ("Membership  Code", '=%1', Membership."Membership Code");
              MembershipAdmissionSetup.SetFilter ("Admission Code", '=%1', TmpTicketReservationRequest."Admission Code");
              MembershipAdmissionSetup.SetFilter ("Ticket No. Type", '=%1', MembershipAdmissionSetup."Ticket No. Type"::ITEM);
              MembershipAdmissionSetup.SetFilter ("Ticket No.", '=%1', TmpTicketReservationRequest."Item No.");
            end;

            if (not (MembershipAdmissionSetup.FindFirst ())) then begin
              if (not (FailWithError)) then
                exit (false);
              Error (INVALID_EXTERNAL_ITEM, TmpTicketReservationRequest."Item No.", Membership."Membership Code");

            end;
          end;

          if (MembershipAdmissionSetup."Cardinality Type" = MembershipAdmissionSetup."Cardinality Type"::LIMITED) then begin
            if (TmpTicketReservationRequest.Quantity > MembershipAdmissionSetup."Max Cardinality") then begin
              if (not (FailWithError)) then
                exit (false);
              Error (TICKET_COUNT_EXCEEDED, MembershipAdmissionSetup."Max Cardinality", TmpTicketReservationRequest."Item No.", Membership."Membership Code", TmpTicketReservationRequest."Admission Code");
            end;
          end;

          TotalTickets += TmpTicketReservationRequest.Quantity;

        until (TmpTicketReservationRequest.Next() = 0);

        MembershipAdmissionSetup.Reset ();
        MembershipAdmissionSetup.SetFilter ("Membership  Code", '=%1', Membership."Membership Code");
        MembershipAdmissionSetup.SetFilter ("Admission Code", '=%1', TmpTicketReservationRequest."Admission Code");
        MembershipAdmissionSetup.SetFilter ("Ticket No. Type", '=%1', MembershipAdmissionSetup."Ticket No. Type"::NA);
        MembershipAdmissionSetup.SetFilter ("Ticket No.", '=%1', '');
        if (MembershipAdmissionSetup.FindFirst ()) then begin
          if (MembershipAdmissionSetup."Cardinality Type" = MembershipAdmissionSetup."Cardinality Type"::LIMITED) then begin
            if (TotalTickets > MembershipAdmissionSetup."Max Cardinality") then begin
              if (not (FailWithError)) then
                exit (false);
              Error (TOTAL_TICKETS_EXCEEDED, MembershipAdmissionSetup."Max Cardinality", Membership."Membership Code", TmpTicketReservationRequest."Admission Code");
            end;
          end;
        end;
    end;

    procedure PromptForMemberGuestArrival(ExternalMemberCardNo: Text[100];AdmissionCode: Code[20];var TicketToken: Text[100]): Boolean
    var
        Membership: Record "MM Membership";
        Member: Record "MM Member";
        MembershipAdmissionSetup: Record "MM Membership Admission Setup";
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        TmpTicketReservationRequest: Record "TM Ticket Reservation Request" temporary;
        Admission: Record "TM Admission";
        ItemCrossReference: Record "Item Cross Reference";
        TicketAdmissionBOM: Record "TM Ticket Admission BOM";
        Ticket: Record "TM Ticket";
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        TicketRetailManagement: Codeunit "TM Ticket Retail Management";
        MemberRetailIntegration: Codeunit "MM Member Retail Integration";
        MembershipManagement: Codeunit "MM Membership Management";
        MemberTicketManager: Codeunit "MM Member Ticket Manager";
        EntryNo: Integer;
        TicketRequestMini: Page "TM Ticket Request Mini";
        PageAction: Action;
        ResponseMessage: Text;
        ResponseCode: Integer;
        SaleLinePOS: Record "Sale Line POS";
        Token: Code[100];
        MembershipEntryNo: Integer;
        MemberEntryNo: Integer;
        ReusedToken: Text;
    begin

        MembershipEntryNo := MembershipManagement.GetMembershipFromExtCardNo (ExternalMemberCardNo, Today, ErrorReason);
        if (not Membership.Get (MembershipEntryNo)) then
          Error (ErrorReason);

        MemberEntryNo := MembershipManagement.GetMemberFromExtCardNo (ExternalMemberCardNo, Today, ErrorReason);
        if (not Member.Get (MemberEntryNo)) then
          Error (ErrorReason);

        if (not BuildMemberGuestRequest (MembershipEntryNo, MemberEntryNo, TmpTicketReservationRequest)) then
          exit;

        // Let user specify guest count for each ticket type
        Commit;
        TicketRequestMini.FillRequestTable (TmpTicketReservationRequest);
        TicketRequestMini.LookupMode (true);
        PageAction := TicketRequestMini.RunModal ();

        if (not (PageAction = ACTION::LookupOK)) then
          exit (false); // cancel from the guest dialog - no guests

        Clear (TmpTicketReservationRequest);
        TmpTicketReservationRequest.DeleteAll ();
        TicketRequestMini.GetTicketRequest (TmpTicketReservationRequest);

        TmpTicketReservationRequest.SetFilter (Quantity, '=%1', 0);
        TmpTicketReservationRequest.DeleteAll ();
        TmpTicketReservationRequest.Reset ();
        if (TmpTicketReservationRequest.IsEmpty ()) then
          exit (false); // all lines deleted - no guests

        PreValidateMemberGuestTicketRequest (TmpTicketReservationRequest, true);

        if (TicketRequestManager.RevalidateRequestForTicketReuse (TmpTicketReservationRequest, ReusedToken, ResponseMessage)) then begin
          TicketToken := ReusedToken;
          Commit;
          //-MM1.43 [337112] Ticket print
          PrintReusedGuestTickets (MembershipEntryNo, TmpTicketReservationRequest);
          //+MM1.43 [337112]
          exit (true); // previously created tickets are reused.
        end;

        // No ticket reuse.
        asserterror Error (''); // Rollback any partial updates done by RevalidateRequestForTicketReuse()

        // Create the actual ticket request for the guests
        TmpTicketReservationRequest.Reset ();
        TmpTicketReservationRequest.FindSet ();
        Token := TicketRequestManager.GetNewToken();
        repeat
          TicketAdmissionBOM.SetFilter ("Item No.", '=%1', TmpTicketReservationRequest."Item No.");
          TicketAdmissionBOM.SetFilter ("Variant Code", '=%1', TmpTicketReservationRequest."Variant Code");

          if (TmpTicketReservationRequest."Admission Code" <> '') then
            TicketAdmissionBOM.SetFilter ("Admission Code", '=%1', TmpTicketReservationRequest."Admission Code");

          if (TicketAdmissionBOM.FindSet ()) then begin
            repeat

              TicketRequestManager.POS_AppendToReservationRequest2 (Token,
                '', 0,
                TmpTicketReservationRequest."Item No.", TmpTicketReservationRequest."Variant Code", TicketAdmissionBOM."Admission Code",
                //TmpTicketReservationRequest.Quantity, -1, Member."External Member No.", Member."External Member No.", '', TmpTicketReservationRequest."Notification Address");
                TmpTicketReservationRequest.Quantity, 0, Member."External Member No.", Member."External Member No.", '', TmpTicketReservationRequest."Notification Address");

            until (TicketAdmissionBOM.Next () = 0);

          end else begin
            Error (MEMBERGUEST_TICKET, MembershipAdmissionSetup.TableCaption,
              MembershipAdmissionSetup."Membership  Code", TmpTicketReservationRequest."Admission Code",
              StrSubstNo ('%1 [%2;%3]',TmpTicketReservationRequest."External Item Code", TmpTicketReservationRequest."Item No.", TmpTicketReservationRequest."Variant Code"),

              TicketAdmissionBOM.TableCaption);
          end;
        until (TmpTicketReservationRequest.Next() = 0);

        Commit;
        ResponseMessage := '';

        // Issue the tickets, validate, confirm and register arrival.
        if (not TicketRetailManagement.IssueTicket (Token, Member."External Member No.", false, ResponseCode, ResponseMessage, SaleLinePOS, false)) then begin
          TicketRequestManager.DeleteReservationRequest (Token, false);
          Error (ResponseMessage);
        end;

        if (not TicketRequestManager.ConfirmReservationRequest (Token, ResponseMessage)) then begin
          TicketRequestManager.DeleteReservationRequest (Token, false);
          Error (ResponseMessage);
        end;

        TicketRequestManager.RegisterArrivalRequest (Token);

        Commit;
        TicketToken := Token;

        //-MM1.43 [337112] Ticket print
        PrintGuestTicketBatch (MembershipEntryNo, Token);
        //+MM1.43 [337112]

        exit (true);
    end;

    procedure MemberFastCheckIn(ExternalMemberCardNo: Text[100];ExternalItemNo: Code[20];AdmissionCode: Code[20];Qty: Integer;TicketTokenToIgnore: Text[100])
    var
        MemberRetailIntegration: Codeunit "MM Member Retail Integration";
        MembershipManagement: Codeunit "MM Membership Management";
        TicketManagement: Codeunit "TM Ticket Management";
        Ticket: Record "TM Ticket";
        TicketToPrint: Record "TM Ticket";
        Member: Record "MM Member";
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        MemberEntryNo: Integer;
        TicketNo: Code[20];
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        ResponseCode: Integer;
        MembershipEntryNo: Integer;
    begin

        MemberEntryNo := MembershipManagement.GetMemberFromExtCardNo (ExternalMemberCardNo, Today, ErrorReason);
        if (not Member.Get (MemberEntryNo)) then
          Error (ErrorReason);

        //-MM1.43 [337112]
        MembershipEntryNo := MembershipManagement.GetMembershipFromExtCardNo (ExternalMemberCardNo, Today, ErrorReason);
        if (MembershipEntryNo = 0) then
          Error (ErrorReason);
        //+MM1.43 [337112]

        if not (MemberRetailIntegration.TranslateBarcodeToItemVariant (ExternalItemNo, ItemNo, VariantCode, ResolvingTable)) then
          Error (MISSING_CROSSREF);

        Ticket.SetCurrentKey ("External Member Card No.");
        Ticket.SetFilter ("Item No.", '=%1', ItemNo);
        Ticket.SetFilter ("Variant Code", '=%1', VariantCode);
        Ticket.SetFilter ("Document Date", '=%', Today);
        Ticket.SetFilter ("External Member Card No.", '=%1', Member."External Member No.");
        Ticket.SetFilter (Blocked, '=%1', false);
        ResponseCode := -1;

        if (Ticket.FindSet()) then begin
          repeat
            if (TicketReservationRequest.Get (Ticket."Ticket Reservation Entry No.")) then
              if (TicketReservationRequest."Session Token ID" <> TicketTokenToIgnore) then
                if (TicketReservationRequest.Quantity = 1) then begin
                  TicketReservationRequest.SetCurrentKey ("Session Token ID");
                  TicketReservationRequest.SetFilter ("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
                  TicketReservationRequest.SetFilter ("Request Status", '=%1', TicketReservationRequest."Request Status"::CONFIRMED);
                  if (TicketReservationRequest.Count () = 1) then
                    ResponseCode := TicketManagement.ValidateTicketForArrival (0, Ticket."No.", AdmissionCode, -1, false, ErrorReason); // Reuse existing ticket (if possible)
                end;
          until ((Ticket.Next () = 0) or (ResponseCode = 0));
          //-MM1.43 [337112]
          if (ResponseCode = 0) then
            TicketToPrint.Get (Ticket."No.");
            TicketToPrint.SetRecFilter ();
          //+MM1.43 [337112]
        end;

        // Create new ticket
        if (ResponseCode <> 0) then begin
          MemberRetailIntegration.IssueTicketFromMemberScan (true, ItemNo, VariantCode, Member, TicketNo, ErrorReason);
          TicketManagement.ValidateTicketForArrival (0, TicketNo, AdmissionCode, -1, true, ErrorReason);
          //-MM1.43 [337112]
          TicketToPrint.Get (TicketNo);
          TicketToPrint.SetRecFilter ();
          //+MM1.43 [337112]
        end;

        Message (WELCOME, Member."Display Name");

        //-MM1.43 [337112]
        if (TicketToPrint.GetFilters () <> '') then begin
          Membership.Get (MembershipEntryNo);
          MembershipSetup.Get (Membership."Membership Code");
          PrintTicket (MembershipSetup, TicketToPrint);
        end;
        //-MM1.43 [337112]
    end;

    local procedure BuildMemberGuestRequest(MembershipEntryNo: Integer;MemberEntryNo: Integer;var TmpTicketReservationRequest: Record "TM Ticket Reservation Request" temporary): Boolean
    var
        Membership: Record "MM Membership";
        MembershipAdmissionSetup: Record "MM Membership Admission Setup";
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        ExternalItemNo: Code[20];
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
    begin

        Membership.Get (MembershipEntryNo);
        MembershipAdmissionSetup.SetFilter ("Membership  Code", '=%1', Membership."Membership Code");
        if (not MembershipAdmissionSetup.FindSet ()) then
          exit;

        repeat

          ItemNo := MembershipAdmissionSetup."Ticket No.";
          VariantCode := '';
          if (MembershipAdmissionSetup."Ticket No. Type" = MembershipAdmissionSetup."Ticket No. Type"::ITEM_CROSS_REF) then
            //-MM1.43 [337112]
            //IF (NOT TicketRequestManager.TranslateBarcodeToItemVariant (ExternalItemNo, ItemNo, VariantCode, ResolvingTable)) THEN
            //  ERROR ('Invalid Item Cross Reference barcode %1, it does not translate to an item / variant.', ItemNo);
            if (not TicketRequestManager.TranslateBarcodeToItemVariant (MembershipAdmissionSetup."Ticket No.", ItemNo, VariantCode, ResolvingTable)) then
              Error ('Invalid Item Cross Reference barcode %1, it does not translate to an item / variant.', ItemNo);
            //+MM1.43 [337112]

          PrefillTicketRequest (MemberEntryNo, MembershipEntryNo, ItemNo, VariantCode, MembershipAdmissionSetup."Admission Code", TmpTicketReservationRequest);

          if (MembershipAdmissionSetup.Description <> '') then
            TmpTicketReservationRequest."Admission Description" := CopyStr (MembershipAdmissionSetup.Description, 1, MaxStrLen (TmpTicketReservationRequest."Admission Description"));

          TmpTicketReservationRequest."Entry No." += 1;
          TmpTicketReservationRequest.Insert ();

        until (MembershipAdmissionSetup.Next () = 0);

        exit (not TmpTicketReservationRequest.IsEmpty ());
    end;

    procedure PrefillTicketRequest(MemberEntryNo: Integer;MembershipEntryNo: Integer;ItemNo: Code[20];VariantCode: Code[10];AdmissionCode: Code[20];var TmpTicketReservationRequest: Record "TM Ticket Reservation Request" temporary)
    var
        Admission: Record "TM Admission";
        Member: Record "MM Member";
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        MembershipManagement: Codeunit "MM Membership Management";
        Method: Code[10];
        Address: Text[200];
    begin

        //-MM1.42 [382728]
        Admission.Get (AdmissionCode);
        Member.Get (MemberEntryNo);

        TmpTicketReservationRequest.Quantity := 1;
        TmpTicketReservationRequest."Admission Code" := AdmissionCode;
        TmpTicketReservationRequest."Admission Description" := Admission.Description;

        TmpTicketReservationRequest."External Item Code" := TicketRequestManager.GetExternalNo (ItemNo, VariantCode);
        TmpTicketReservationRequest."Item No." := ItemNo;
        TmpTicketReservationRequest."Variant Code" := VariantCode;

        MembershipManagement.GetCommunicationMethod_Ticket (Member."Entry No.", MembershipEntryNo, Method, TmpTicketReservationRequest."Notification Address");
        case Method of
          'SMS'  : TmpTicketReservationRequest."Notification Method" := TmpTicketReservationRequest."Notification Method"::SMS;
          'EMAIL': TmpTicketReservationRequest."Notification Method" := TmpTicketReservationRequest."Notification Method"::EMAIL;
          'W-SMS':
            begin
              TmpTicketReservationRequest."Notification Method" := TmpTicketReservationRequest."Notification Method"::SMS;
              TmpTicketReservationRequest."Notification Format" := TmpTicketReservationRequest."Notification Format"::WALLET;
            end;
          'W-EMAIL':
            begin
              TmpTicketReservationRequest."Notification Method" := TmpTicketReservationRequest."Notification Method"::EMAIL;
              TmpTicketReservationRequest."Notification Format" := TmpTicketReservationRequest."Notification Format"::WALLET;
            end;
        else
          TmpTicketReservationRequest."Notification Method" := TmpTicketReservationRequest."Notification Method"::NA;
        end;

        TmpTicketReservationRequest."External Member No." := Member."External Member No.";

        //+MM1.42 [382728]
    end;

    local procedure PrintTicket(MembershipSetup: Record "MM Membership Setup";var Ticket: Record "TM Ticket")
    var
        ObjectOutputMgt: Codeunit "Object Output Mgt.";
        LinePrintMgt: Codeunit "RP Line Print Mgt.";
        ReportPrinterInterface: Codeunit "Report Printer Interface";
        PrintTemplateMgt: Codeunit "RP Template Mgt.";
    begin
        //-MM1.43 [337112]

        case MembershipSetup."Ticket Print Object Type" of
          MembershipSetup."Ticket Print Object Type"::NO_PRINT :
            exit;

          MembershipSetup."Ticket Print Object Type"::CODEUNIT :
            if (ObjectOutputMgt.GetCodeunitOutputPath (MembershipSetup."Ticket Print Object ID") <> '') then
              LinePrintMgt.ProcessCodeunit (MembershipSetup."Ticket Print Object ID", Ticket)
            else
              CODEUNIT.Run (MembershipSetup."Ticket Print Object ID", Ticket);

          MembershipSetup."Ticket Print Object Type"::REPORT :
            ReportPrinterInterface.RunReport (MembershipSetup."Ticket Print Object ID", false, false, Ticket);

          MembershipSetup."Ticket Print Object Type"::TEMPLATE :
            PrintTemplateMgt.PrintTemplate (MembershipSetup."Ticket Print Template Code", Ticket, 0);

          else
            Error (ILLEGAL_VALUE, MembershipSetup."Ticket Print Object Type", MembershipSetup.FieldCaption ("Ticket Print Object Type"));
        end;

        //+MM1.43 [337112]
    end;

    local procedure PrintGuestTicketBatch(MembershipEntryNo: Integer;RequestToken: Text[100])
    var
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        Ticket: Record "TM Ticket";
        TicketReservationRequest: Record "TM Ticket Reservation Request";
    begin

        //-MM1.43 [337112]
        Membership.Get (MembershipEntryNo);
        MembershipSetup.Get (Membership."Membership Code");

        if (MembershipSetup."Ticket Print Model" = MembershipSetup."Ticket Print Model"::CONDENSED) then
          exit;

        TicketReservationRequest.Reset ();
        TicketReservationRequest.SetFilter ("Session Token ID", '=%1', RequestToken);
        if (TicketReservationRequest.FindSet ()) then begin
          repeat
            Ticket.SetFilter ("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
            if (not Ticket.IsEmpty ()) then
              PrintTicket (MembershipSetup, Ticket);
          until (TicketReservationRequest.Next () = 0);
        end;
        //+MM1.43 [337112]
    end;

    local procedure PrintReusedGuestTickets(MembershipEntryNo: Integer;var TmpTicketReservationRequest: Record "TM Ticket Reservation Request" temporary)
    var
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        Ticket: Record "TM Ticket";
    begin

        //-MM1.43 [337112]
        Membership.Get (MembershipEntryNo);
        MembershipSetup.Get (Membership."Membership Code");

        if (MembershipSetup."Ticket Print Model" = MembershipSetup."Ticket Print Model"::CONDENSED) then
          exit;

        TmpTicketReservationRequest.Reset ();
        TmpTicketReservationRequest.FindSet ();
        repeat
          Ticket.SetFilter ("Ticket Reservation Entry No.", '=%1', TmpTicketReservationRequest."Entry No.");
          if (not Ticket.IsEmpty ()) then
            PrintTicket (MembershipSetup, Ticket);
        until (TmpTicketReservationRequest.Next () = 0);
        //+MM1.43 [337112]
    end;
}

