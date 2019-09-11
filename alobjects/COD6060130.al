codeunit 6060130 "MM Member Ticket Manager"
{
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM80.1.08/TSA/20160222  CASE 232494 Validating Member Assign Tickets in the self service ticket validation
    // MM1.17/TSA/20161208  CASE 259671 Extended functionality for handling the start date of membership, signature change on IsMembershipActive
    // MM1.36/TSA /20181119 CASE 335889 Fixed casting between external and internal item nos
    // MM1.36/TSA /20181119 CASE 335889 Reactored, relocated PromptForMemberGuestArrival() and MemberFastCheckIn()
    // MM1.37/TSA /20190327 CASE 350288 Signature Change
    // MM1.40/TSA /20190812 CASE 364741 Signature Change


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

    procedure ValidateMemberAssignedTickets(Token: Text[100];FailWithError: Boolean) Success: Boolean
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        TmpTicketReservationRequest: Record "TM Ticket Reservation Request" temporary;
    begin
        TicketReservationRequest.SetFilter ("Session Token ID", '=%1', Token);
        if (not (TicketReservationRequest.FindSet ())) then
          Error (TOKEN_NOT_FOUND, Token);

        //-MM1.36 [335889]
        repeat
          TmpTicketReservationRequest.TransferFields (TicketReservationRequest, true);
          TmpTicketReservationRequest.Insert ();
        until (TicketReservationRequest.Next () = 0);

        exit (PreValidateMemberGuestTicketRequest (TmpTicketReservationRequest, FailWithError));

        //+MM1.36 [335889]
        // Code moved to worker function PreValidateMemberAssignedTickesRequest();
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
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
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
        MembershipAdmissionSetup.SetFilter ("Membership  Code", '=%1', Membership."Membership Code");
        MembershipAdmissionSetup.SetFilter ("Admission Code", '=%1', TmpTicketReservationRequest."Admission Code");
        ExternalMemberNo := TmpTicketReservationRequest."External Member No.";

        repeat
          TmpTicketReservationRequest.TestField ("Admission Code");
          TmpTicketReservationRequest.TestField ("External Item Code");

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
            //-MM1.36 [335889]
            TicketRequestManager.TranslateBarcodeToItemVariant (TmpTicketReservationRequest."External Item Code", ItemNo, VariantCode, ResolvingTable);
            MembershipAdmissionSetup.SetFilter ("Ticket No. Type", '=%1', MembershipAdmissionSetup."Ticket No. Type"::ITEM);
            MembershipAdmissionSetup.SetFilter ("Ticket No.", '=%1', ItemNo);
            if (not (MembershipAdmissionSetup.FindFirst ())) then begin
              if (not (FailWithError)) then
                exit (false);
              Error (INVALID_EXTERNAL_ITEM, TmpTicketReservationRequest."External Item Code", Membership."Membership Code");
            end;
            //IF (NOT (FailWithError)) THEN
            //  EXIT (FALSE);
            //ERROR (INVALID_EXTERNAL_ITEM, TicketReservationRequest."External Item Code", Membership."Membership Code");
            //+MM1.36 [335889]
          end;

          if (MembershipAdmissionSetup."Cardinality Type" = MembershipAdmissionSetup."Cardinality Type"::LIMITED) then begin
            if (TmpTicketReservationRequest.Quantity > MembershipAdmissionSetup."Max Cardinality") then begin
              if (not (FailWithError)) then
                exit (false);
              Error (TICKET_COUNT_EXCEEDED, MembershipAdmissionSetup."Max Cardinality", TmpTicketReservationRequest."External Item Code", Membership."Membership Code", TmpTicketReservationRequest."Admission Code");
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

    procedure PromptForMemberGuestArrival(ExternalMemberCardNo: Text[100];AdmissionCode: Code[20]): Boolean
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
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
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

        if (not BuildMemberGuestRequest (Membership."Membership Code", Member, TmpTicketReservationRequest))
          then exit;

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
          exit (false); // all lined deleted - no guests

        PreValidateMemberGuestTicketRequest (TmpTicketReservationRequest, true);

        //-MM1.37 [350288]
        // IF (TicketRequestManager.RevalidateRequestForTicketReuse (TmpTicketReservationRequest, ReusedToken, ResponseMessage)) THEN
        //  EXIT (TRUE); // previously created tickets are reused.
        if (TicketRequestManager.RevalidateRequestForTicketReuse (TmpTicketReservationRequest, ReusedToken, ResponseMessage)) then
          exit (true); // previously created tickets are reused.
        //+MM1.37 [350288]

        // No ticket reuse.
        asserterror Error (''); // Rollback any partial updates done by RevalidateRequestForTicketReuse()

        // Create the actual ticket request for the guests
        TmpTicketReservationRequest.Reset ();
        TmpTicketReservationRequest.FindSet ();
        Token := TicketRequestManager.GetNewToken();
        repeat
          MemberRetailIntegration.TranslateBarcodeToItemVariant (TmpTicketReservationRequest."External Item Code", ItemNo, VariantCode, ResolvingTable);

          TicketAdmissionBOM.SetFilter ("Item No.", '=%1', ItemNo);
          TicketAdmissionBOM.SetFilter ("Variant Code", '=%1', VariantCode);
          if (TmpTicketReservationRequest."Admission Code" <> '') then
            TicketAdmissionBOM.SetFilter ("Admission Code", '=%1', TmpTicketReservationRequest."Admission Code");

          if (TicketAdmissionBOM.FindSet ()) then begin
            repeat
              //-MM1.40 [364741]
              // TicketRequestManager.POS_AppendToReservationRequest2 (Token,
              //   '', 0,
              //   ItemNo, VariantCode, TicketAdmissionBOM."Admission Code",
              //  TmpTicketReservationRequest.Quantity, -1, Member."External Member No.", Member."External Member No.", '');

              TicketRequestManager.POS_AppendToReservationRequest2 (Token,
                '', 0,
                ItemNo, VariantCode, TicketAdmissionBOM."Admission Code",
                TmpTicketReservationRequest.Quantity, -1, Member."External Member No.", Member."External Member No.", '', TmpTicketReservationRequest."Notification Address");
              //+MM1.40 [364741]

            until (TicketAdmissionBOM.Next () = 0);

          end else begin
            Error (MEMBERGUEST_TICKET, MembershipAdmissionSetup.TableCaption,
              MembershipAdmissionSetup."Membership  Code", TmpTicketReservationRequest."Admission Code",
              StrSubstNo ('%1 [%2;%3]',TmpTicketReservationRequest."External Item Code", ItemNo, VariantCode),
              TicketAdmissionBOM.TableCaption);
          end;
        until (TmpTicketReservationRequest.Next() = 0);

        Commit;
        ResponseMessage := '';

        // Issue the tickets, validate, confirm and register arrival.
        SaleLinePOS."No." := ItemNo;
        SaleLinePOS."Variant Code" := VariantCode;

        if (not TicketRetailManagement.IssueTicket (Token, Member."External Member No.", false, ResponseCode, ResponseMessage, SaleLinePOS, false)) then begin
          TicketRequestManager.DeleteReservationRequest (Token, false);
          Error (ResponseMessage);
        end;

        if (not TicketRequestManager.ConfirmReservationRequest (Token, ResponseMessage)) then begin
          TicketRequestManager.DeleteReservationRequest (Token, false);
          Error (ResponseMessage);
        end;

        TicketRequestManager.RegisterArrivalRequest (Token);
        exit (true);
    end;

    procedure MemberFastCheckIn(ExternalMemberCardNo: Text[100];ExternalItemNo: Code[20];AdmissionCode: Code[20];Qty: Integer)
    var
        MemberRetailIntegration: Codeunit "MM Member Retail Integration";
        MembershipManagement: Codeunit "MM Membership Management";
        TicketManagement: Codeunit "TM Ticket Management";
        Ticket: Record "TM Ticket";
        Member: Record "MM Member";
        MemberEntryNo: Integer;
        TicketNo: Code[20];
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        ResponseCode: Integer;
    begin

        MemberEntryNo := MembershipManagement.GetMemberFromExtCardNo (ExternalMemberCardNo, Today, ErrorReason);
        if (not Member.Get (MemberEntryNo)) then
          Error (ErrorReason);

        if not (MemberRetailIntegration.TranslateBarcodeToItemVariant (ExternalItemNo, ItemNo, VariantCode, ResolvingTable)) then
          Error (MISSING_CROSSREF);

        //-MM1.36 [335889]
        // MemberRetailIntegration.IssueTicketFromMemberScan (TRUE, ItemNo, VariantCode, Member, TicketNo, ErrorReason);
        // TicketManagement.ValidateTicketForArrival (0, TicketNo, AdmissionCode, -1, TRUE, ErrorReason);

        Ticket.SetCurrentKey ("External Member Card No.");
        Ticket.SetFilter ("Item No.", '=%1', ItemNo);
        Ticket.SetFilter ("Variant Code", '=%1', VariantCode);
        Ticket.SetFilter ("Document Date", '=%', Today);
        Ticket.SetFilter ("External Member Card No.", '=%1', Member."External Member No.");
        ResponseCode := -1;
        if (Ticket.FindLast ()) then
          ResponseCode := TicketManagement.ValidateTicketForArrival (0, Ticket."No.", AdmissionCode, -1, false, ErrorReason); // Reuse existing ticket (if possible)

        // Create new ticket
        if (ResponseCode <> 0) then begin
          MemberRetailIntegration.IssueTicketFromMemberScan (true, ItemNo, VariantCode, Member, TicketNo, ErrorReason);
          TicketManagement.ValidateTicketForArrival (0, TicketNo, AdmissionCode, -1, true, ErrorReason);
        end;
        //+MM1.36 [335889]

        Message (WELCOME, Member."Display Name");
    end;

    local procedure BuildMemberGuestRequest(MembershipCode: Code[20];Member: Record "MM Member";var TmpTicketReservationRequest: Record "TM Ticket Reservation Request" temporary): Boolean
    var
        MembershipAdmissionSetup: Record "MM Membership Admission Setup";
        ItemCrossReference: Record "Item Cross Reference";
        Admission: Record "TM Admission";
    begin

        // Build a new temporary request based on the admission setup lines for this membership code
        MembershipAdmissionSetup.SetFilter ("Membership  Code", '=%1', MembershipCode);
        if (not MembershipAdmissionSetup.FindSet ()) then
          exit;

        repeat

          case MembershipAdmissionSetup."Ticket No. Type" of
            MembershipAdmissionSetup."Ticket No. Type"::ITEM :
              begin
                ItemCrossReference.SetFilter ("Item No.", '=%1', MembershipAdmissionSetup."Ticket No.");
                ItemCrossReference.SetFilter ("Cross-Reference Type", '=%1', ItemCrossReference."Cross-Reference Type"::"Bar Code");
                ItemCrossReference.SetFilter ("Discontinue Bar Code", '=%1', false);
                ItemCrossReference.FindFirst ();
                TmpTicketReservationRequest."External Item Code" := ItemCrossReference."Cross-Reference No.";
              end;

            MembershipAdmissionSetup."Ticket No. Type"::ITEM_CROSS_REF :
              begin
                TmpTicketReservationRequest."External Item Code" := CopyStr (MembershipAdmissionSetup."Ticket No.", 1, MaxStrLen (TmpTicketReservationRequest."External Item Code"));
              end;

            MembershipAdmissionSetup."Ticket No. Type"::ALTERNATIVE_NUMBER :
              begin
                Error ('Alternative numbers are being deprecated. Use Item Cross References instead. MembershipAdmissionSetup %1 %2 %3',
                  MembershipAdmissionSetup."Membership  Code", MembershipAdmissionSetup."Admission Code", MembershipAdmissionSetup."Ticket No.");
              end;
          end;

          TmpTicketReservationRequest."Admission Code" := MembershipAdmissionSetup."Admission Code";
          TmpTicketReservationRequest."Admission Description" := CopyStr (MembershipAdmissionSetup.Description, 1, MaxStrLen (TmpTicketReservationRequest."Admission Description"));

          //-MM1.36 [335889]
          if (TmpTicketReservationRequest."Admission Description" = '') then begin
            if (Admission.Get (MembershipAdmissionSetup."Admission Code")) then
              TmpTicketReservationRequest."Admission Description" := Admission.Description;
          end;

          TmpTicketReservationRequest."Notification Method" := Member."Notification Method";
          TmpTicketReservationRequest."Notification Address" := Member."E-Mail Address";
          TmpTicketReservationRequest."External Member No." := Member."External Member No.";
          //+MM1.36 [335889]

          TmpTicketReservationRequest."Entry No." += 1;
          TmpTicketReservationRequest.Insert ();

        until (MembershipAdmissionSetup.Next () = 0);

        exit (not TmpTicketReservationRequest.IsEmpty ());
    end;
}

