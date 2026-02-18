codeunit 6060130 "NPR MM Member Ticket Manager"
{
    Access = Internal;

    trigger OnRun()
    begin
    end;

    var
        NO_MEMBER: Label 'Member Number must not be blank when validating member ticket assignments.';
        TICKET_COUNT_EXCEEDED: Label 'A maximum of %1 tickets can be assigned for ticket type %2, membership code %3, admission code %4.';
        TOTAL_TICKETS_EXCEEDED: Label 'The total ticket count of %1 is exceeded, membership code %2, admission code %3.';
        TOKEN_NOT_FOUND: Label 'The token %1 was not found.';
        MEMBERSHIP_NOT_ACTIVE: Label 'Membership for member %1, is not active.';
        INVALID_EXTERNAL_ITEM: Label 'The ticket item %1 is not valid in context of membership %2, admission code %3.';
        NOT_SAME_MEMBER: Label 'All request lines need to have the same member number.';
        MEMBERGUEST_TICKET: Label 'Setup for %1 has an invalid entry for membership code %2, admission code %3, item %4. Setup does not match setup in %5.';
        MISSING_CROSSREF: Label 'The external number %1 does not translate to an item. Check Item Reference for setup.';
        ILLEGAL_VALUE: Label 'Value %1 is not a valid %2.';

    procedure ValidateMemberAssignedTickets(Token: Text[100]; FailWithError: Boolean) Success: Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TempTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary;
    begin
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (not (TicketReservationRequest.FindSet())) then
            Error(TOKEN_NOT_FOUND, Token);

        repeat
            TempTicketReservationRequest.TransferFields(TicketReservationRequest, true);
            TempTicketReservationRequest.Insert();
        until (TicketReservationRequest.Next() = 0);

        exit(PreValidateMemberGuestTicketRequest(TempTicketReservationRequest, FailWithError));
    end;

    procedure PreValidateMemberGuestTicketRequest(var TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary; FailWithError: Boolean) Success: Boolean
    var
        MemberManagement: Codeunit "NPR MM MembershipMgtInternal";
        MembershipAdmissionSetup: Record "NPR MM Members. Admis. Setup";
        MembershipEntryNo: Integer;
        Membership: Record "NPR MM Membership";
        TotalTickets: Integer;
        ExternalMemberNo: Code[20];
        FoundSetup: Boolean;
    begin
        TmpTicketReservationRequest.Reset();
        TmpTicketReservationRequest.FindSet();

        if (TmpTicketReservationRequest."External Member No." = '') then begin
            // Not a member guest request
            if (not (FailWithError)) then
                exit(false);
            Error(NO_MEMBER);
        end;

        MembershipEntryNo := MemberManagement.GetMembershipFromExtMemberNo(TmpTicketReservationRequest."External Member No.");
        if (not (MemberManagement.IsMembershipActive(MembershipEntryNo, WorkDate(), true))) then begin
            if (not (FailWithError)) then
                exit(false);
            Error(MEMBERSHIP_NOT_ACTIVE, TmpTicketReservationRequest."External Member No.");
        end;

        Membership.Get(MembershipEntryNo);
        ExternalMemberNo := TmpTicketReservationRequest."External Member No.";

        repeat
            TmpTicketReservationRequest.TestField("Admission Code");

            if (TmpTicketReservationRequest."External Member No." <> ExternalMemberNo) then begin
                if (not (FailWithError)) then
                    exit(false);
                Error(NOT_SAME_MEMBER);
            end;

            if (TmpTicketReservationRequest."External Member No." = '') then begin
                if (not (FailWithError)) then
                    exit(false);
                Error(NO_MEMBER);
            end;

            MembershipAdmissionSetup.SetFilter("Ticket No.", '=%1', TmpTicketReservationRequest."External Item Code");
            if (not (MembershipAdmissionSetup.FindFirst())) then begin
                if (TmpTicketReservationRequest."External Item Code" <> '') then begin
                    MembershipAdmissionSetup.Reset();
                    MembershipAdmissionSetup.SetFilter("Membership  Code", '=%1', Membership."Membership Code");
                    MembershipAdmissionSetup.SetFilter("Admission Code", '=%1', TmpTicketReservationRequest."Admission Code");
                    MembershipAdmissionSetup.SetFilter("Ticket No. Type", '=%1', MembershipAdmissionSetup."Ticket No. Type"::ITEM_CROSS_REF);
                    MembershipAdmissionSetup.SetFilter("Ticket No.", '=%1', TmpTicketReservationRequest."External Item Code");
                    FoundSetup := MembershipAdmissionSetup.FindFirst();
                end;
                if (not FoundSetup) then begin
                    MembershipAdmissionSetup.Reset();
                    MembershipAdmissionSetup.SetFilter("Membership  Code", '=%1', Membership."Membership Code");
                    MembershipAdmissionSetup.SetFilter("Admission Code", '=%1', TmpTicketReservationRequest."Admission Code");
                    MembershipAdmissionSetup.SetFilter("Ticket No. Type", '=%1', MembershipAdmissionSetup."Ticket No. Type"::ITEM);
                    MembershipAdmissionSetup.SetFilter("Ticket No.", '=%1', TmpTicketReservationRequest."Item No.");
                end;

                if (not (MembershipAdmissionSetup.FindFirst())) then begin
                    if (not (FailWithError)) then
                        exit(false);
                    Error(INVALID_EXTERNAL_ITEM, TmpTicketReservationRequest."Item No.", Membership."Membership Code", TmpTicketReservationRequest."Admission Code");

                end;
            end;

            if (MembershipAdmissionSetup."Cardinality Type" = MembershipAdmissionSetup."Cardinality Type"::LIMITED) then begin
                if (TmpTicketReservationRequest.Quantity > MembershipAdmissionSetup."Max Cardinality") then begin
                    if (not (FailWithError)) then
                        exit(false);
                    Error(TICKET_COUNT_EXCEEDED, MembershipAdmissionSetup."Max Cardinality", TmpTicketReservationRequest."Item No.", Membership."Membership Code", TmpTicketReservationRequest."Admission Code");
                end;
            end;

            TotalTickets += TmpTicketReservationRequest.Quantity;

        until (TmpTicketReservationRequest.Next() = 0);

        MembershipAdmissionSetup.Reset();
        MembershipAdmissionSetup.SetFilter("Membership  Code", '=%1', Membership."Membership Code");
        MembershipAdmissionSetup.SetFilter("Admission Code", '=%1', TmpTicketReservationRequest."Admission Code");
        MembershipAdmissionSetup.SetFilter("Ticket No. Type", '=%1', MembershipAdmissionSetup."Ticket No. Type"::NA);
        MembershipAdmissionSetup.SetFilter("Ticket No.", '=%1', '');
        if (MembershipAdmissionSetup.FindFirst()) then begin
            if (MembershipAdmissionSetup."Cardinality Type" = MembershipAdmissionSetup."Cardinality Type"::LIMITED) then begin
                if (TotalTickets > MembershipAdmissionSetup."Max Cardinality") then begin
                    if (not (FailWithError)) then
                        exit(false);
                    Error(TOTAL_TICKETS_EXCEEDED, MembershipAdmissionSetup."Max Cardinality", Membership."Membership Code", TmpTicketReservationRequest."Admission Code");
                end;
            end;
        end;
    end;

    procedure PromptForMemberGuestArrival(ExternalMemberCardNo: Text[100]; AdmissionCode: Code[20]; PosUnitNo: Code[10]; var TicketToken: Text[100]): Boolean
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        MembershipEntryNo: Integer;
        MemberEntryNo: Integer;
        ErrorReason: Text;
    begin
        ErrorReason := '';
        MembershipEntryNo := MembershipManagement.GetMembershipFromExtCardNo(ExternalMemberCardNo, Today, ErrorReason);
        if (MembershipEntryNo = 0) then
            Error(ErrorReason);

        MemberEntryNo := MembershipManagement.GetMemberFromExtCardNo(ExternalMemberCardNo, Today, ErrorReason);
        if (MemberEntryNo = 0) then
            Error(ErrorReason);

        exit(PromptForMemberGuestArrival(MembershipEntryNo, MemberEntryNo, AdmissionCode, PosUnitNo, TicketToken));
    end;

    internal procedure PromptForMemberGuestArrival(MembershipEntryNo: Integer; MemberEntryNo: Integer; AdmissionCode: Code[20]; PosUnitNo: Code[10]; var TicketToken: Text[100]): Boolean
    var
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        MembershipAdmissionSetup: Record "NPR MM Members. Admis. Setup";
        TempTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary;
        TicketAdmissionBOM: Record "NPR TM Ticket Admission BOM";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketRetailManagement: Codeunit "NPR TM Ticket Retail Mgt.";
        TicketAttemptCreate: Codeunit "NPR Ticket Attempt Create";
        TicketRequestMini: Page "NPR TM Ticket Req. Mini";
        PageAction: Action;
        ResponseMessage: Text;
        ResponseCode: Integer;
        SaleLinePOS: Record "NPR POS Sale Line";
        Token: Code[100];


        ReusedToken: Text[100];
        PlaceHolderLbl: Label '%1 [%2;%3]', Locked = true;
    begin

        Membership.Get(MembershipEntryNo);
        Member.Get(MemberEntryNo);

        if (not BuildMemberGuestRequest(MembershipEntryNo, MemberEntryNo, TempTicketReservationRequest)) then
            exit;

        // Let user specify guest count for each ticket type
        Commit();
        TicketRequestMini.FillRequestTable(TempTicketReservationRequest);
        TicketRequestMini.LookupMode(true);
        PageAction := TicketRequestMini.RunModal();

        if (not (PageAction = ACTION::LookupOK)) then
            exit(false); // cancel from the guest dialog - no guests

        Clear(TempTicketReservationRequest);
        TempTicketReservationRequest.DeleteAll();
        TicketRequestMini.GetTicketRequest(TempTicketReservationRequest);

        TempTicketReservationRequest.SetFilter(Quantity, '=%1', 0);
        TempTicketReservationRequest.DeleteAll();
        TempTicketReservationRequest.Reset();
        if (TempTicketReservationRequest.IsEmpty()) then
            exit(false); // all lines deleted - no guests

        PreValidateMemberGuestTicketRequest(TempTicketReservationRequest, true);

        Commit();
        if (TicketAttemptCreate.AttemptValidateRequestForTicketReuse(TempTicketReservationRequest, ReusedToken, ResponseMessage)) then begin
            TicketToken := ReusedToken;
            Commit();

            PrintReusedGuestTickets(MembershipEntryNo, TempTicketReservationRequest);
            exit(true); // previously created tickets are reused.
        end;

        // Create the actual ticket request for the guests
        TempTicketReservationRequest.Reset();
        TempTicketReservationRequest.FindSet();
        Token := TicketRequestManager.GetNewToken();
        repeat
            TicketAdmissionBOM.SetFilter("Item No.", '=%1', TempTicketReservationRequest."Item No.");
            TicketAdmissionBOM.SetFilter("Variant Code", '=%1', TempTicketReservationRequest."Variant Code");

            if (TempTicketReservationRequest."Admission Code" <> '') then
                TicketAdmissionBOM.SetFilter("Admission Code", '=%1', TempTicketReservationRequest."Admission Code");

            if (TicketAdmissionBOM.FindSet()) then begin
                repeat

                    TicketRequestManager.POS_AppendToReservationRequest2(Token,
                      '', 0,
                      TempTicketReservationRequest."Item No.", TempTicketReservationRequest."Variant Code", TicketAdmissionBOM."Admission Code",
                      TempTicketReservationRequest.Quantity, 0, Member."External Member No.", Member."External Member No.", '', TempTicketReservationRequest."Notification Address", TempTicketReservationRequest."Ext. Line Reference No.");

                until (TicketAdmissionBOM.Next() = 0);

            end else begin
                Error(MEMBERGUEST_TICKET, MembershipAdmissionSetup.TableCaption,
                  MembershipAdmissionSetup."Membership  Code", TempTicketReservationRequest."Admission Code",
                  StrSubstNo(PlaceHolderLbl, TempTicketReservationRequest."External Item Code", TempTicketReservationRequest."Item No.", TempTicketReservationRequest."Variant Code"),

                  TicketAdmissionBOM.TableCaption);
            end;
        until (TempTicketReservationRequest.Next() = 0);

        Commit();
        ResponseMessage := '';

        // Issue the tickets, validate, confirm and register arrival.
        if (not TicketRetailManagement.IssueTicket(Token, Member."External Member No.", ResponseCode, ResponseMessage, SaleLinePOS, false)) then begin
            TicketRequestManager.DeleteReservationRequest(Token, false);
            Error(ResponseMessage);
        end;

        if (not TicketRequestManager.ConfirmReservationRequest(Token, ResponseMessage)) then begin
            TicketRequestManager.DeleteReservationRequest(Token, false);
            Error(ResponseMessage);
        end;

        TicketRequestManager.RegisterArrivalRequest(Token, PosUnitNo);

        Commit();
        TicketToken := Token;

        PrintGuestTicketBatch(MembershipEntryNo, Token);

        exit(true);
    end;

    internal procedure SelectReusableTicket(MemberEntryNo: Integer; ExternalItemNo: Code[50]; AdmissionCode: Code[20]; PosUnitNo: Code[10]; Qty: Integer; TicketTokenToIgnore: Text[100]; var TicketToReuse: Record "NPR TM Ticket"): Boolean
    var
        AttemptTicket: Codeunit "NPR Ticket Attempt Create";
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        Ticket: Record "NPR TM Ticket";
        Member: Record "NPR MM Member";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketIsReused: Boolean;
        ErrorReason: Text;
        ResolvingTable: Integer;
        VariantCode: Code[10];
        ItemNo: Code[20];
    begin
        if (not Member.Get(MemberEntryNo)) then
            exit(false);

        Ticket.SetCurrentKey("External Member Card No.");
        Ticket.SetFilter("Document Date", '=%1', Today);
        Ticket.SetFilter("External Member Card No.", '=%1', Member."External Member No.");
        Ticket.SetFilter(Blocked, '=%1', false);

        if (ExternalItemNo <> '') then begin
            if (MemberRetailIntegration.TranslateBarcodeToItemVariant(ExternalItemNo, ItemNo, VariantCode, ResolvingTable)) then begin
                Ticket.SetFilter("Item No.", '=%1', ItemNo);
                Ticket.SetFilter("Variant Code", '=%1', VariantCode);
            end;
        end;

        TicketIsReused := false;
        if (Ticket.FindSet()) then begin
            repeat
                if (TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No.")) then
                    if (TicketReservationRequest."Session Token ID" <> TicketTokenToIgnore) then
                        if (TicketReservationRequest.Quantity = Qty) then begin
                            TicketReservationRequest.SetCurrentKey("Session Token ID");
                            TicketReservationRequest.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
                            TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::CONFIRMED);
                            if (not TicketReservationRequest.IsEmpty()) then // Something is "paid" on this request - admission could be blank and could be determined by pos unit later.
                                TicketIsReused := AttemptTicket.AttemptValidateTicketForArrival("NPR TM TicketIdentifierType"::INTERNAL_TICKET_NO, Ticket."No.", AdmissionCode, -1, PosUnitNo, '', ErrorReason); // Reuse existing ticket (if possible)
                        end;
            until ((Ticket.Next() = 0) or (TicketIsReused));

            if (TicketIsReused) then
                TicketToReuse.Get(Ticket."No.");
            TicketToReuse.SetRecFilter();

            exit(TicketIsReused);
        end;
    end;

    internal procedure AttemptMemberFastCheckIn(MembershipEntryNo: Integer; MemberEntryNo: Integer; AdmissionCode: Code[20]; PosUnitNo: Code[10]; Qty: Integer; TicketTokenToIgnore: Text[100]; var ExternalTicketNo: Text[30]; var ErrorReason: Text; var ErrorCode: Integer): Boolean
    var
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        AttemptTicket: Codeunit "NPR Ticket Attempt Create";
        TicketToPrint: Record "NPR TM Ticket";
        Member: Record "NPR MM Member";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberTicketNotSetup: Label 'No ticket reservation found for member %1 that is valid for today, with admission code [%2] or an admission code selected from POS unit [%3].';
        TicketNo: Code[20];
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        TicketIsReused: Boolean;
        ExternalItemNo: Code[50];
    // WELCOME: Label 'Welcome %1.';
    begin

        Membership.Get(MembershipEntryNo);
        Member.Get(MemberEntryNo);
        ExternalItemNo := MemberRetailIntegration.POS_GetExternalTicketItemForMembership(MembershipEntryNo, false);

        TicketIsReused := SelectReusableTicket(Member."Entry No.", '', AdmissionCode, PosUnitNo, Qty, TicketTokenToIgnore, TicketToPrint);
        if ((not TicketIsReused) and (ExternalItemNo = '')) then begin
            ErrorCode := -10;
            ErrorReason := StrSubstNo(MemberTicketNotSetup, Member."External Member No.", AdmissionCode, PosUnitNo);
            exit(false);
        end;

        // Create new ticket - only possible when ExternalItemNo <> ''
        if (not TicketIsReused) then begin
            if (not (MemberRetailIntegration.TranslateBarcodeToItemVariant(ExternalItemNo, ItemNo, VariantCode, ResolvingTable))) then begin
                ErrorCode := -11;
                ErrorReason := StrSubstNo(MISSING_CROSSREF, ExternalItemNo);
                exit(false);
            end;

            ErrorCode := MemberRetailIntegration.IssueTicketFromMemberScan(false, ItemNo, VariantCode, Member, TicketNo, ErrorReason);
            if (ErrorCode <> 0) then
                exit(false);

            if (not AttemptTicket.AttemptValidateTicketForArrival("NPR TM TicketIdentifierType"::INTERNAL_TICKET_NO, TicketNo, AdmissionCode, -1, PosUnitNo, '', ErrorReason)) then begin
                ErrorCode := -12;
                exit(false);
            end;

            TicketToPrint.Get(TicketNo);
            TicketToPrint.SetRecFilter();
        end;

        if (TicketToPrint.GetFilters() <> '') then begin
            MembershipSetup.Get(Membership."Membership Code");
            PrintTicket(MembershipSetup, TicketToPrint);
            if (TicketToPrint.find()) then
                ExternalTicketNo := TicketToPrint."External Ticket No.";
        end;

        exit(true);
    end;

    internal procedure MemberFastCheckIn(MembershipEntryNo: Integer; MemberEntryNo: Integer; AdmissionCode: Code[20]; PosUnitNo: Code[10]; Qty: Integer; TicketTokenToIgnore: Text[100]; var ExternalTicketNo: Text[30])
    var
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        TicketToPrint: Record "NPR TM Ticket";
        Member: Record "NPR MM Member";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberTicketNotSetup: Label 'No ticket reservation found for member %1 that is valid for today, with admission code [%2] or an admission code selected from POS unit [%3].';
        TicketNo: Code[20];
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        TicketIsReused: Boolean;
        ErrorReason: Text;
        ExternalItemNo: Code[50];
    // WELCOME: Label 'Welcome %1.';
    begin

        Membership.Get(MembershipEntryNo);
        Member.Get(MemberEntryNo);
        ExternalItemNo := MemberRetailIntegration.POS_GetExternalTicketItemForMembership(MembershipEntryNo, false);

        TicketIsReused := SelectReusableTicket(Member."Entry No.", '', AdmissionCode, PosUnitNo, Qty, TicketTokenToIgnore, TicketToPrint);
        if ((not TicketIsReused) and (ExternalItemNo = '')) then
            Error(MemberTicketNotSetup, Member."External Member No.", AdmissionCode, PosUnitNo);

        // Create new ticket - only possible when ExternalItemNo <> ''
        if (not TicketIsReused) then begin
            if (not (MemberRetailIntegration.TranslateBarcodeToItemVariant(ExternalItemNo, ItemNo, VariantCode, ResolvingTable))) then
                Error(MISSING_CROSSREF, ExternalItemNo);

            MemberRetailIntegration.IssueTicketFromMemberScan(true, ItemNo, VariantCode, Member, TicketNo, ErrorReason);
            TicketManagement.RegisterArrivalScanTicket("NPR TM TicketIdentifierType"::INTERNAL_TICKET_NO, TicketNo, AdmissionCode, -1, PosUnitNo, '', false);
            TicketToPrint.Get(TicketNo);
            TicketToPrint.SetRecFilter();
        end;

        if (TicketToPrint.GetFilters() <> '') then begin
            MembershipSetup.Get(Membership."Membership Code");
            PrintTicket(MembershipSetup, TicketToPrint);
            if (TicketToPrint.find()) then
                ExternalTicketNo := TicketToPrint."External Ticket No.";
        end;

    end;

    internal procedure MemberFastCheckInNoPrint(MembershipEntryNo: Integer; MemberEntryNo: Integer; AdmissionCode: Code[20]; PosUnitNo: Code[10]; Qty: Integer; TicketTokenToIgnore: Text[100]; var ExternalTicketNo: Text[30])
    var
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        Member: Record "NPR MM Member";
        Membership: Record "NPR MM Membership";
        MemberTicketNotSetup: Label 'No ticket reservation found for member %1 that is valid for today, with admission code [%2] or an admission code selected from POS unit [%3].';
        TicketNo: Code[20];
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        TicketIsReused: Boolean;
        ErrorReason: Text;
        ExternalItemNo: Code[50];
        Ticket: Record "NPR TM Ticket";
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
    begin
        Sentry.StartSpan(Span, 'bc.membership.fast-check-in-no-print.find-reusable-ticket');

        Membership.Get(MembershipEntryNo);
        Member.Get(MemberEntryNo);
        ExternalItemNo := MemberRetailIntegration.POS_GetExternalTicketItemForMembership(MembershipEntryNo, false);

        TicketIsReused := SelectReusableTicket(Member."Entry No.", ExternalItemNo, AdmissionCode, PosUnitNo, Qty, TicketTokenToIgnore, Ticket);
        if ((not TicketIsReused) and (ExternalItemNo = '')) then
            Error(MemberTicketNotSetup, Member."External Member No.", AdmissionCode, PosUnitNo);
        Span.Finish();

        // Create new ticket - only possible when ExternalItemNo <> ''
        if (not TicketIsReused) then begin
            Sentry.StartSpan(Span, 'bc.membership.fast-check-in-no-print.issue-ticket');
            if (not (MemberRetailIntegration.TranslateBarcodeToItemVariant(ExternalItemNo, ItemNo, VariantCode, ResolvingTable))) then
                Error(MISSING_CROSSREF, ExternalItemNo);

            MemberRetailIntegration.IssueTicketFromMemberScan(true, ItemNo, VariantCode, Member, TicketNo, ErrorReason);
            TicketManagement.RegisterArrivalScanTicket("NPR TM TicketIdentifierType"::INTERNAL_TICKET_NO, TicketNo, AdmissionCode, -1, PosUnitNo, '', false);
            Ticket.Get(TicketNo);
            Span.Finish();
        end;

        ExternalTicketNo := Ticket."External Ticket No.";
    end;

    internal procedure MemberGuestFastCheckInNoPrint(MembershipAdmissionSetupId: Guid; AttemptTicketReuse: Boolean; MembershipEntryNo: Integer; MemberEntryNo: Integer; AdmissionCode: Code[20]; PosUnitNo: Code[10]; Qty: Integer; TicketTokenToIgnore: Text[100]; var ExternalTicketNo: Text[30])
    var
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        MembershipAdmissionSetup: Record "NPR MM Members. Admis. Setup";
        Member: Record "NPR MM Member";
        Membership: Record "NPR MM Membership";
        MemberTicketNotSetup: Label 'No ticket reservation found for member %1 that is valid for today, with admission code [%2] or an admission code selected from POS unit [%3].';
        TicketNo: Code[20];
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        TicketIsReused: Boolean;
        ErrorReason: Text;
        ExternalItemNo: Code[50];
        Ticket: Record "NPR TM Ticket";
    begin
        MembershipAdmissionSetup.GetBySystemId(MembershipAdmissionSetupId);
        Membership.Get(MembershipEntryNo);
        Member.Get(MemberEntryNo);

        ExternalItemNo := MembershipAdmissionSetup."Ticket No.";

        if (AttemptTicketReuse) then
            TicketIsReused := SelectReusableTicket(Member."Entry No.", ExternalItemNo, AdmissionCode, PosUnitNo, Qty, TicketTokenToIgnore, Ticket);

        if ((not TicketIsReused) and (ExternalItemNo = '')) then
            Error(MemberTicketNotSetup, Member."External Member No.", AdmissionCode, PosUnitNo);

        // Create new ticket - only possible when ExternalItemNo <> ''
        if (not TicketIsReused) then begin
            if (not (MemberRetailIntegration.TranslateBarcodeToItemVariant(ExternalItemNo, ItemNo, VariantCode, ResolvingTable))) then
                Error(MISSING_CROSSREF, ExternalItemNo);

            MemberRetailIntegration.IssueTicketFromMemberScan(true, ItemNo, VariantCode, Member, TicketNo, ErrorReason);
            TicketManagement.RegisterArrivalScanTicket("NPR TM TicketIdentifierType"::INTERNAL_TICKET_NO, TicketNo, AdmissionCode, -1, PosUnitNo, '', false);
            Ticket.Get(TicketNo);
        end;

        ExternalTicketNo := Ticket."External Ticket No.";
    end;


    local procedure BuildMemberGuestRequest(MembershipEntryNo: Integer; MemberEntryNo: Integer; var TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary): Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipAdmissionSetup: Record "NPR MM Members. Admis. Setup";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ItemNo, PrevItemNo : Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
    begin

        Membership.Get(MembershipEntryNo);
        MembershipAdmissionSetup.SetFilter("Membership  Code", '=%1', Membership."Membership Code");
        if (not MembershipAdmissionSetup.FindSet()) then
            exit;

        repeat
            if MembershipAdmissionSetup."Ticket No. Type" = MembershipAdmissionSetup."Ticket No. Type"::ITEM then begin
                ItemNo := CopyStr(MembershipAdmissionSetup."Ticket No.", 1, MaxStrLen(ItemNo));
                VariantCode := '';
            end;
            if (MembershipAdmissionSetup."Ticket No. Type" = MembershipAdmissionSetup."Ticket No. Type"::ITEM_CROSS_REF) then
                if (not TicketRequestManager.TranslateBarcodeToItemVariant(MembershipAdmissionSetup."Ticket No.", ItemNo, VariantCode, ResolvingTable)) then
                    Error('Invalid Item Reference barcode %1, it does not translate to an item / variant.', ItemNo);

            PrefillTicketRequest(MemberEntryNo, MembershipEntryNo, ItemNo, VariantCode, MembershipAdmissionSetup."Admission Code", TmpTicketReservationRequest);

            if (MembershipAdmissionSetup.Description <> '') then
                TmpTicketReservationRequest."Admission Description" := CopyStr(MembershipAdmissionSetup.Description, 1, MaxStrLen(TmpTicketReservationRequest."Admission Description"));

            TmpTicketReservationRequest."Entry No." += 1;
            if (PrevItemNo <> ItemNo) then begin
                PrevItemNo := ItemNo;
                TmpTicketReservationRequest."Ext. Line Reference No." := TmpTicketReservationRequest."Entry No."; // Separate different items as different ticket requests within the token.
            end;
            TmpTicketReservationRequest.Insert();

        until (MembershipAdmissionSetup.Next() = 0);

        exit(not TmpTicketReservationRequest.IsEmpty());
    end;

    procedure PrefillTicketRequest(MemberEntryNo: Integer; MembershipEntryNo: Integer; ItemNo: Code[20]; VariantCode: Code[10]; AdmissionCode: Code[20]; var TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary)
    var
        Member: Record "NPR MM Member";
        Admission: Record "NPR TM Admission";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        Method: Code[10];
        NotificationEngine: Option;
    begin

        Admission.Get(AdmissionCode);
        Member.Get(MemberEntryNo);

        TmpTicketReservationRequest.Quantity := 1;
        TmpTicketReservationRequest."Admission Code" := AdmissionCode;
        TmpTicketReservationRequest."Admission Description" := Admission.Description;

        TmpTicketReservationRequest."External Item Code" := TicketRequestManager.GetExternalNo(ItemNo, VariantCode);
        TmpTicketReservationRequest."Item No." := ItemNo;
        TmpTicketReservationRequest."Variant Code" := VariantCode;

        MembershipManagement.GetCommunicationMethod_Ticket(Member."Entry No.", MembershipEntryNo, Method, TmpTicketReservationRequest."Notification Address", NotificationEngine);
        case Method of
            'SMS':
                TmpTicketReservationRequest."Notification Method" := TmpTicketReservationRequest."Notification Method"::SMS;
            'EMAIL':
                TmpTicketReservationRequest."Notification Method" := TmpTicketReservationRequest."Notification Method"::EMAIL;
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

    end;

    internal procedure PrintTicket(MembershipSetup: Record "NPR MM Membership Setup"; var Ticket: Record "NPR TM Ticket")
    var
        PrintTemplateMgt: Codeunit "NPR RP Template Mgt.";
    begin

        case MembershipSetup."Ticket Print Object Type" of
            MembershipSetup."Ticket Print Object Type"::NO_PRINT:
                exit;

            MembershipSetup."Ticket Print Object Type"::CODEUNIT:
                Codeunit.Run(MembershipSetup."Ticket Print Object ID", Ticket);

            MembershipSetup."Ticket Print Object Type"::REPORT:
                Report.Run(MembershipSetup."Ticket Print Object ID", false, false, Ticket);

            MembershipSetup."Ticket Print Object Type"::TEMPLATE:
                PrintTemplateMgt.PrintTemplate(MembershipSetup."Ticket Print Template Code", Ticket, 0);

            else
                Error(ILLEGAL_VALUE, MembershipSetup."Ticket Print Object Type", MembershipSetup.FieldCaption("Ticket Print Object Type"));
        end;

    end;

    local procedure PrintGuestTicketBatch(MembershipEntryNo: Integer; RequestToken: Text[100])
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        Ticket: Record "NPR TM Ticket";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin

        Membership.Get(MembershipEntryNo);
        MembershipSetup.Get(Membership."Membership Code");

        if (MembershipSetup."Ticket Print Model" = MembershipSetup."Ticket Print Model"::CONDENSED) then
            exit;

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', RequestToken);
        if (TicketReservationRequest.FindSet()) then begin
            repeat
                Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
                if (not Ticket.IsEmpty()) then
                    PrintTicket(MembershipSetup, Ticket);
            until (TicketReservationRequest.Next() = 0);
        end;

    end;

    local procedure PrintReusedGuestTickets(MembershipEntryNo: Integer; var TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary)
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        Ticket: Record "NPR TM Ticket";
    begin

        Membership.Get(MembershipEntryNo);
        MembershipSetup.Get(Membership."Membership Code");

        if (MembershipSetup."Ticket Print Model" = MembershipSetup."Ticket Print Model"::CONDENSED) then
            exit;

        TmpTicketReservationRequest.Reset();
        TmpTicketReservationRequest.FindSet();
        repeat
            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TmpTicketReservationRequest."Entry No.");
            if (not Ticket.IsEmpty()) then
                PrintTicket(MembershipSetup, Ticket);
        until (TmpTicketReservationRequest.Next() = 0);

    end;
}

