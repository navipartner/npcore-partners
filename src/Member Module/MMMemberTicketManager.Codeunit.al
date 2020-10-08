codeunit 6060130 "NPR MM Member Ticket Manager"
{

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

    procedure ValidateMemberAssignedTickets(Token: Text[100]; FailWithError: Boolean) Success: Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary;
    begin
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (not (TicketReservationRequest.FindSet())) then
            Error(TOKEN_NOT_FOUND, Token);

        repeat
            TmpTicketReservationRequest.TransferFields(TicketReservationRequest, true);
            TmpTicketReservationRequest.Insert();
        until (TicketReservationRequest.Next() = 0);

        exit(PreValidateMemberGuestTicketRequest(TmpTicketReservationRequest, FailWithError));
    end;

    procedure PreValidateMemberGuestTicketRequest(var TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary; FailWithError: Boolean) Success: Boolean
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        MemberManagement: Codeunit "NPR MM Membership Mgt.";
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
        if (not (MemberManagement.IsMembershipActive(MembershipEntryNo, WorkDate, true))) then begin
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
                    Error(INVALID_EXTERNAL_ITEM, TmpTicketReservationRequest."Item No.", Membership."Membership Code");

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

    procedure PromptForMemberGuestArrival(ExternalMemberCardNo: Text[100]; AdmissionCode: Code[20]; var TicketToken: Text[100]): Boolean
    var
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        MembershipAdmissionSetup: Record "NPR MM Members. Admis. Setup";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary;
        Admission: Record "NPR TM Admission";
        ItemCrossReference: Record "Item Cross Reference";
        TicketAdmissionBOM: Record "NPR TM Ticket Admission BOM";
        Ticket: Record "NPR TM Ticket";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketRetailManagement: Codeunit "NPR TM Ticket Retail Mgt.";
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MemberTicketManager: Codeunit "NPR MM Member Ticket Manager";
        EntryNo: Integer;
        TicketRequestMini: Page "NPR TM Ticket Req. Mini";
        PageAction: Action;
        ResponseMessage: Text;
        ResponseCode: Integer;
        SaleLinePOS: Record "NPR Sale Line POS";
        Token: Code[100];
        MembershipEntryNo: Integer;
        MemberEntryNo: Integer;
        ReusedToken: Text;
    begin

        MembershipEntryNo := MembershipManagement.GetMembershipFromExtCardNo(ExternalMemberCardNo, Today, ErrorReason);
        if (not Membership.Get(MembershipEntryNo)) then
            Error(ErrorReason);

        MemberEntryNo := MembershipManagement.GetMemberFromExtCardNo(ExternalMemberCardNo, Today, ErrorReason);
        if (not Member.Get(MemberEntryNo)) then
            Error(ErrorReason);

        if (not BuildMemberGuestRequest(MembershipEntryNo, MemberEntryNo, TmpTicketReservationRequest)) then
            exit;

        // Let user specify guest count for each ticket type
        Commit();
        TicketRequestMini.FillRequestTable(TmpTicketReservationRequest);
        TicketRequestMini.LookupMode(true);
        PageAction := TicketRequestMini.RunModal();

        if (not (PageAction = ACTION::LookupOK)) then
            exit(false); // cancel from the guest dialog - no guests

        Clear(TmpTicketReservationRequest);
        TmpTicketReservationRequest.DeleteAll();
        TicketRequestMini.GetTicketRequest(TmpTicketReservationRequest);

        TmpTicketReservationRequest.SetFilter(Quantity, '=%1', 0);
        TmpTicketReservationRequest.DeleteAll();
        TmpTicketReservationRequest.Reset();
        if (TmpTicketReservationRequest.IsEmpty()) then
            exit(false); // all lines deleted - no guests

        PreValidateMemberGuestTicketRequest(TmpTicketReservationRequest, true);

        if (TicketRequestManager.RevalidateRequestForTicketReuse(TmpTicketReservationRequest, ReusedToken, ResponseMessage)) then begin
            TicketToken := ReusedToken;
            Commit();

            PrintReusedGuestTickets(MembershipEntryNo, TmpTicketReservationRequest);

            exit(true); // previously created tickets are reused.
        end;

        // No ticket reuse.
        asserterror Error(''); // Rollback any partial updates done by RevalidateRequestForTicketReuse()

        // Create the actual ticket request for the guests
        TmpTicketReservationRequest.Reset();
        TmpTicketReservationRequest.FindSet();
        Token := TicketRequestManager.GetNewToken();
        repeat
            TicketAdmissionBOM.SetFilter("Item No.", '=%1', TmpTicketReservationRequest."Item No.");
            TicketAdmissionBOM.SetFilter("Variant Code", '=%1', TmpTicketReservationRequest."Variant Code");

            if (TmpTicketReservationRequest."Admission Code" <> '') then
                TicketAdmissionBOM.SetFilter("Admission Code", '=%1', TmpTicketReservationRequest."Admission Code");

            if (TicketAdmissionBOM.FindSet()) then begin
                repeat

                    TicketRequestManager.POS_AppendToReservationRequest2(Token,
                      '', 0,
                      TmpTicketReservationRequest."Item No.", TmpTicketReservationRequest."Variant Code", TicketAdmissionBOM."Admission Code",
                      //TmpTicketReservationRequest.Quantity, -1, Member."External Member No.", Member."External Member No.", '', TmpTicketReservationRequest."Notification Address");
                      TmpTicketReservationRequest.Quantity, 0, Member."External Member No.", Member."External Member No.", '', TmpTicketReservationRequest."Notification Address");

                until (TicketAdmissionBOM.Next() = 0);

            end else begin
                Error(MEMBERGUEST_TICKET, MembershipAdmissionSetup.TableCaption,
                  MembershipAdmissionSetup."Membership  Code", TmpTicketReservationRequest."Admission Code",
                  StrSubstNo('%1 [%2;%3]', TmpTicketReservationRequest."External Item Code", TmpTicketReservationRequest."Item No.", TmpTicketReservationRequest."Variant Code"),

                  TicketAdmissionBOM.TableCaption);
            end;
        until (TmpTicketReservationRequest.Next() = 0);

        Commit();
        ResponseMessage := '';

        // Issue the tickets, validate, confirm and register arrival.
        if (not TicketRetailManagement.IssueTicket(Token, Member."External Member No.", false, ResponseCode, ResponseMessage, SaleLinePOS, false)) then begin
            TicketRequestManager.DeleteReservationRequest(Token, false);
            Error(ResponseMessage);
        end;

        if (not TicketRequestManager.ConfirmReservationRequest(Token, ResponseMessage)) then begin
            TicketRequestManager.DeleteReservationRequest(Token, false);
            Error(ResponseMessage);
        end;

        TicketRequestManager.RegisterArrivalRequest(Token);

        Commit();
        TicketToken := Token;

        PrintGuestTicketBatch(MembershipEntryNo, Token);

        exit(true);
    end;

    procedure MemberFastCheckIn(ExternalMemberCardNo: Text[100]; ExternalItemNo: Code[20]; AdmissionCode: Code[20]; Qty: Integer; TicketTokenToIgnore: Text[100])
    var
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        Ticket: Record "NPR TM Ticket";
        TicketToPrint: Record "NPR TM Ticket";
        Member: Record "NPR MM Member";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberEntryNo: Integer;
        TicketNo: Code[20];
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        ResponseCode: Integer;
        MembershipEntryNo: Integer;
    begin

        MemberEntryNo := MembershipManagement.GetMemberFromExtCardNo(ExternalMemberCardNo, Today, ErrorReason);
        if (not Member.Get(MemberEntryNo)) then
            Error(ErrorReason);

        MembershipEntryNo := MembershipManagement.GetMembershipFromExtCardNo(ExternalMemberCardNo, Today, ErrorReason);
        if (MembershipEntryNo = 0) then
            Error(ErrorReason);

        if not (MemberRetailIntegration.TranslateBarcodeToItemVariant(ExternalItemNo, ItemNo, VariantCode, ResolvingTable)) then
            Error(MISSING_CROSSREF);

        Ticket.SetCurrentKey("External Member Card No.");
        Ticket.SetFilter("Item No.", '=%1', ItemNo);
        Ticket.SetFilter("Variant Code", '=%1', VariantCode);
        Ticket.SetFilter("Document Date", '=%', Today);
        Ticket.SetFilter("External Member Card No.", '=%1', Member."External Member No.");
        Ticket.SetFilter(Blocked, '=%1', false);
        ResponseCode := -1;

        if (Ticket.FindSet()) then begin
            repeat
                if (TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No.")) then
                    if (TicketReservationRequest."Session Token ID" <> TicketTokenToIgnore) then
                        if (TicketReservationRequest.Quantity = 1) then begin
                            TicketReservationRequest.SetCurrentKey("Session Token ID");
                            TicketReservationRequest.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
                            TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::CONFIRMED);
                            if (TicketReservationRequest.Count() = 1) then
                                ResponseCode := TicketManagement.ValidateTicketForArrival(0, Ticket."No.", AdmissionCode, -1, false, ErrorReason); // Reuse existing ticket (if possible)
                        end;
            until ((Ticket.Next() = 0) or (ResponseCode = 0));

            if (ResponseCode = 0) then
                TicketToPrint.Get(Ticket."No.");
            TicketToPrint.SetRecFilter();

        end;

        // Create new ticket
        if (ResponseCode <> 0) then begin
            MemberRetailIntegration.IssueTicketFromMemberScan(true, ItemNo, VariantCode, Member, TicketNo, ErrorReason);
            TicketManagement.ValidateTicketForArrival(0, TicketNo, AdmissionCode, -1, true, ErrorReason);

            TicketToPrint.Get(TicketNo);
            TicketToPrint.SetRecFilter();

        end;

        Message(WELCOME, Member."Display Name");

        if (TicketToPrint.GetFilters() <> '') then begin
            Membership.Get(MembershipEntryNo);
            MembershipSetup.Get(Membership."Membership Code");
            PrintTicket(MembershipSetup, TicketToPrint);
        end;

    end;

    local procedure BuildMemberGuestRequest(MembershipEntryNo: Integer; MemberEntryNo: Integer; var TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary): Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipAdmissionSetup: Record "NPR MM Members. Admis. Setup";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ExternalItemNo: Code[20];
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
    begin

        Membership.Get(MembershipEntryNo);
        MembershipAdmissionSetup.SetFilter("Membership  Code", '=%1', Membership."Membership Code");
        if (not MembershipAdmissionSetup.FindSet()) then
            exit;

        repeat

            ItemNo := MembershipAdmissionSetup."Ticket No.";
            VariantCode := '';
            if (MembershipAdmissionSetup."Ticket No. Type" = MembershipAdmissionSetup."Ticket No. Type"::ITEM_CROSS_REF) then

                //IF (NOT TicketRequestManager.TranslateBarcodeToItemVariant (ExternalItemNo, ItemNo, VariantCode, ResolvingTable)) THEN
                //  ERROR ('Invalid Item Cross Reference barcode %1, it does not translate to an item / variant.', ItemNo);
                if (not TicketRequestManager.TranslateBarcodeToItemVariant(MembershipAdmissionSetup."Ticket No.", ItemNo, VariantCode, ResolvingTable)) then
                    Error('Invalid Item Cross Reference barcode %1, it does not translate to an item / variant.', ItemNo);

            PrefillTicketRequest(MemberEntryNo, MembershipEntryNo, ItemNo, VariantCode, MembershipAdmissionSetup."Admission Code", TmpTicketReservationRequest);

            if (MembershipAdmissionSetup.Description <> '') then
                TmpTicketReservationRequest."Admission Description" := CopyStr(MembershipAdmissionSetup.Description, 1, MaxStrLen(TmpTicketReservationRequest."Admission Description"));

            TmpTicketReservationRequest."Entry No." += 1;
            TmpTicketReservationRequest.Insert();

        until (MembershipAdmissionSetup.Next() = 0);

        exit(not TmpTicketReservationRequest.IsEmpty());
    end;

    procedure PrefillTicketRequest(MemberEntryNo: Integer; MembershipEntryNo: Integer; ItemNo: Code[20]; VariantCode: Code[10]; AdmissionCode: Code[20]; var TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary)
    var
        Admission: Record "NPR TM Admission";
        Member: Record "NPR MM Member";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        Method: Code[10];
        Address: Text[200];
    begin

        Admission.Get(AdmissionCode);
        Member.Get(MemberEntryNo);

        TmpTicketReservationRequest.Quantity := 1;
        TmpTicketReservationRequest."Admission Code" := AdmissionCode;
        TmpTicketReservationRequest."Admission Description" := Admission.Description;

        TmpTicketReservationRequest."External Item Code" := TicketRequestManager.GetExternalNo(ItemNo, VariantCode);
        TmpTicketReservationRequest."Item No." := ItemNo;
        TmpTicketReservationRequest."Variant Code" := VariantCode;

        MembershipManagement.GetCommunicationMethod_Ticket(Member."Entry No.", MembershipEntryNo, Method, TmpTicketReservationRequest."Notification Address");
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

    local procedure PrintTicket(MembershipSetup: Record "NPR MM Membership Setup"; var Ticket: Record "NPR TM Ticket")
    var
        ObjectOutputMgt: Codeunit "NPR Object Output Mgt.";
        LinePrintMgt: Codeunit "NPR RP Line Print Mgt.";
        ReportPrinterInterface: Codeunit "NPR Report Printer Interface";
        PrintTemplateMgt: Codeunit "NPR RP Template Mgt.";
    begin

        case MembershipSetup."Ticket Print Object Type" of
            MembershipSetup."Ticket Print Object Type"::NO_PRINT:
                exit;

            MembershipSetup."Ticket Print Object Type"::CODEUNIT:
                if (ObjectOutputMgt.GetCodeunitOutputPath(MembershipSetup."Ticket Print Object ID") <> '') then
                    LinePrintMgt.ProcessCodeunit(MembershipSetup."Ticket Print Object ID", Ticket)
                else
                    CODEUNIT.Run(MembershipSetup."Ticket Print Object ID", Ticket);

            MembershipSetup."Ticket Print Object Type"::REPORT:
                ReportPrinterInterface.RunReport(MembershipSetup."Ticket Print Object ID", false, false, Ticket);

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

