codeunit 6060131 "NPR MM Member Retail Integr."
{
    Access = Internal;

    var
        MEMBER_NOT_RECOGNIZED: Label 'Can''t identify member.';
        ILLEGAL_VALUE: Label 'Value %1 is not a valid %2.';
        MEMBERSHIP_NOT_VALID: Label 'The membership %1 is not valid for today.';
        MEMBERSHIP_NOT_VALID_2: Label 'Membership %1 is not valid for today. Membership validity runs from %2 until %3.';
        BLOCKED_NOT_FOUND: Label 'Member %1 is either blocked or not found.';
        CARD_BLOCKED_NOT_FOUND: Label 'Member Card %1 is either blocked or not found.';
        NO_PRINTOUT: Label 'Membership %1 is not setup for printing.';

        MSG_1102: Label 'Member registration aborted.';
        MSG_1103: Label 'Membership code specified on sales item was not found.';
        MSG_1105: Label 'Nothing to edit.';
        MEMBER_NAME: Label 'Member - %1';
        TICKET_NOT_FOUND: Label 'Ticket not found.';
        UI: Codeunit "NPR MM Member POS UI";
        MEMBER_CARD_EXPIRED: Label 'The member card %1 has expired.';
        gLastMessage: Text;
        Text000: Label 'Print Membership';
        ADMIT_MEMBERS: Label 'Do you want to admit the member(s)?';
        CONFIRM_CARD_BLOCKED: Label 'This member card is blocked, do you want to continue anyway?';

    trigger OnRun()
    var
    begin

    end;

    procedure POS_ValidateMemberCardNo(FailWithError: Boolean; AllowVerboseMode: Boolean; InputMode: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT; ActivateMembership: Boolean; var ExternalMemberCardNo: Text[100]): Boolean
    begin

        exit(
          POS_ValidateMemberCardNoWorker(FailWithError, AllowVerboseMode, InputMode, ActivateMembership, ExternalMemberCardNo, false));
    end;

    procedure POS_ShowMemberCard(InputMode: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT; var ExternalMemberCardNo: Text[100]): Boolean
    begin

        exit(
          POS_ValidateMemberCardNoWorker(true, true, InputMode, false, ExternalMemberCardNo, true));

    end;

    local procedure POS_ValidateMemberCardNoWorker(FailWithError: Boolean; AllowVerboseMode: Boolean; InputMode: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT; ActivateMembership: Boolean; var ExternalMemberCardNo: Text[100]; ForcedConfirmMember: Boolean): Boolean
    var
        MembershipEntryNo: Integer;
        MemberManagement: Codeunit "NPR MM MembershipMgtInternal";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        Member: Record "NPR MM Member";
        MemberEntryNo: Integer;
        MemberCard: Record "NPR MM Member Card";
        RequestMemberFieldUpdate: Record "NPR MM Request Member Update";
        NotFoundReasonText: Text;
        MustActivate: Boolean;
        POSMemberCard: Page "NPR MM POS Member Card";
        MemberUpdateRequestPage: Page "NPR MM Remote Member Update";
        ForeignMembershipMgr: Codeunit "NPR MM Foreign Members. Mgr.";
        ForeignCardIsValid: Boolean;
        ForeignMembershipEntryNo: Integer;
        FormattedCardNumber: Text[100];
        FormattedForeignCardNumber: Text[100];
        ShowMemberDialog: Boolean;
        ValidFrom: Date;
        ValidUntil: Date;
    begin

        case InputMode of
            InputMode::NO_PROMPT:
                ; // Pre validated
            InputMode::CARD_SCAN:
                Error('CARD_SCAN is an obsolete feature of POS_ValidateMemberCardNoWorker()');
            InputMode::FACIAL_RECOGNITION:
                begin
                    ExternalMemberCardNo := '';
                    if (UI.MemberSearchWithFacialRecognition(MemberEntryNo)) then begin
                        MemberCard.SetCurrentKey("Member Entry No.");
                        MemberCard.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
                        MemberCard.SetFilter(Blocked, '=%1', false);
                        MemberCard.SetFilter("Valid Until", '>=%1', Today);
                        // should display list when multiple valid cards
                        if (MemberCard.FindFirst()) then
                            ExternalMemberCardNo := MemberCard."External Card No.";

                        if (ExternalMemberCardNo = '') then
                            Error('You do not have a valid membership...');

                    end else begin
                        Error(MEMBER_NOT_RECOGNIZED);
                    end;
                end;
        end;

        if (ExternalMemberCardNo = '') then begin
            if (FailWithError) then
                Error('');
            exit(false);
        end;

        // Check card number if it exists locally
        if (StrLen(ExternalMemberCardNo) <= 50) then begin
            MembershipEntryNo := MemberManagement.GetMembershipFromExtCardNo(ExternalMemberCardNo, Today, NotFoundReasonText);
            FormattedCardNumber := ExternalMemberCardNo;
        end;

        ForeignMembershipEntryNo := ForeignMembershipMgr.DispatchToReplicateForeignMemberCard('', ExternalMemberCardNo, false, FormattedForeignCardNumber, ForeignCardIsValid, NotFoundReasonText);
        if (ForeignCardIsValid) then begin
            MembershipEntryNo := ForeignMembershipEntryNo;
            FormattedCardNumber := FormattedForeignCardNumber;
        end;

        if (MembershipEntryNo = 0) then begin
            if (FailWithError) then
                if (NotFoundReasonText <> '') then
                    Error(NotFoundReasonText)
                else
                    Error(CARD_BLOCKED_NOT_FOUND, ExternalMemberCardNo);
            exit(false);
        end;

        if (not MemberManagement.IsMemberCardActive(FormattedCardNumber, Today)) then begin
            if (FailWithError) then begin

                if (AllowVerboseMode) then begin
                    if (not (Confirm(MEMBER_CARD_EXPIRED, true, ExternalMemberCardNo))) then begin
                        Error(MEMBER_CARD_EXPIRED, ExternalMemberCardNo);
                    end;
                end else begin
                    Error(MEMBER_CARD_EXPIRED, ExternalMemberCardNo);
                end;

            end else begin
                exit(false);
            end;
        end;

        if (not Membership.Get(MembershipEntryNo)) then begin
            if (FailWithError) then
                Error(CARD_BLOCKED_NOT_FOUND, ExternalMemberCardNo);
            exit(false);
        end;

        if (not MemberManagement.IsMembershipActive(MembershipEntryNo, Today, false)) then begin
            MustActivate := MemberManagement.MembershipNeedsActivation(MembershipEntryNo);
            MemberManagement.GetMembershipValidDate(MembershipEntryNo, Today, ValidFrom, ValidUntil);

            if (ActivateMembership) then
                if (not MustActivate) then begin
                    if (FailWithError) then
                        Error(MEMBERSHIP_NOT_VALID_2, ExternalMemberCardNo, ValidFrom, ValidUntil);
                    exit(false);
                end;

            if (MustActivate) then
                if (not ActivateMembership) then begin
                    if (FailWithError) then
                        Error(MEMBERSHIP_NOT_VALID_2, ExternalMemberCardNo, ValidFrom, ValidUntil);
                    exit(false);
                end;
        end;

        MembershipSetup.Get(Membership."Membership Code");

        if (MembershipSetup."Member Information" = MembershipSetup."Member Information"::NAMED) then begin
            if (not (Member.Get(MemberManagement.GetMemberFromExtCardNo(FormattedCardNumber, Today, NotFoundReasonText)))) then begin
                if (FailWithError) then
                    Error(NotFoundReasonText);
                exit(false);
            end;

            RequestMemberFieldUpdate.SetFilter("Member Entry No.", '=%1', Member."Entry No.");
            RequestMemberFieldUpdate.SetFilter(Handled, '=%1', false);
            if (not RequestMemberFieldUpdate.IsEmpty()) then begin
                MemberUpdateRequestPage.SetMembershipAndMember(MembershipEntryNo, Member."Entry No.");
                MemberUpdateRequestPage.LookupMode(true);
                Commit();
                MemberUpdateRequestPage.RunModal();
            end;

            ShowMemberDialog := (AllowVerboseMode and MembershipSetup."Confirm Member On Card Scan") or (ForcedConfirmMember);
            if (ShowMemberDialog) then begin
                Commit(); // When Facial Recognition is used and a face is written

                POSMemberCard.LookupMode(true);
                POSMemberCard.SetRecord(Member);
                POSMemberCard.SetMembershipEntryNo(Membership."Entry No.");

                if (POSMemberCard.RunModal() <> Action::LookupOK) then
                    Error('');
            end;

        end;

        if (MustActivate) and (ActivateMembership) then begin
            MemberManagement.ActivateMembershipLedgerEntry(MembershipEntryNo, Today);
        end;

        exit(true);
    end;

    procedure POS_GetExternalTicketItemFromMembership(ExternalMemberCardNo: Text[100]) TicketItemBarcode: Code[50]
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberManagement: Codeunit "NPR MM MembershipMgtInternal";
        NotFoundReasonText: Text;
    begin

        if (not Membership.Get(MemberManagement.GetMembershipFromExtCardNo(ExternalMemberCardNo, Today, NotFoundReasonText))) then
            if (NotFoundReasonText <> '') then
                Error(NotFoundReasonText)
            else
                Error(MEMBERSHIP_NOT_VALID, ExternalMemberCardNo);

        MembershipSetup.Get(Membership."Membership Code");
        MembershipSetup.TestField("Ticket Item Barcode");

        exit(MembershipSetup."Ticket Item Barcode");
    end;

    procedure POS_GetExternalTicketItemForMembership(MembershipEntryNo: Integer; FailOnError: Boolean) TicketItemBarcode: Code[50]
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
    begin
        Membership.Get(MembershipEntryNo);
        MembershipSetup.Get(Membership."Membership Code");
        if (FailOnError) then
            MembershipSetup.TestField("Ticket Item Barcode");

        exit(MembershipSetup."Ticket Item Barcode");
    end;

    procedure PrintMembershipOnEndOfSales(SalesReceiptNo: Code[20])
    begin

        PrintMembershipOnEndOfSalesWorker(SalesReceiptNo, false);

    end;

    local procedure PrintMembershipOnEndOfSalesWorker(SalesReceiptNo: Code[20]; ForceCardPrint: Boolean)
    var
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipSetup: Record "NPR MM Membership Setup";
        ShouldPrint: Boolean;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        MemberCard: Record "NPR MM Member Card";
        MemberCard2: Record "NPR MM Member Card";
    begin

        if (not MembershipEntry.SetCurrentKey("Receipt No.")) then;
        MembershipEntry.SetFilter("Receipt No.", '=%1', SalesReceiptNo);
        if (not (MembershipEntry.FindSet())) then
            exit;

        repeat
            ShouldPrint := Membership.Get(MembershipEntry."Membership Entry No.");
            ShouldPrint := ShouldPrint and MembershipSetup.Get(Membership."Membership Code");

            if (ShouldPrint) then begin
                Membership.Reset();
                Membership.SetFilter("Entry No.", '=%1', MembershipEntry."Membership Entry No.");

                case MembershipSetup."POS Print Action" of
                    MembershipSetup."POS Print Action"::DIRECT:
                        begin
                            PrintMembershipSalesReceiptWorker(Membership, MembershipSetup);

                            if (ForceCardPrint or (CheckSalesSetupForCardPrint(MembershipEntry."Item No."))) then begin
                                if (MembershipEntry."Member Card Entry No." <> 0) then begin
                                    MemberCard2.SetFilter("Entry No.", '%1..', MembershipEntry."Member Card Entry No.");
                                    MemberCard2.SetFilter("Membership Entry No.", '=%1', MembershipEntry."Membership Entry No.");
                                    if (MemberCard2.FindSet()) then begin
                                        repeat
                                            MemberCard.Get(MemberCard2."Entry No.");
                                            MemberCard.SetRecFilter();
                                            PrintMemberCardWorker(MemberCard, MembershipSetup);
                                        until (MemberCard2.Next() = 0);
                                    end;
                                end;
                            end;

                        end;
                    MembershipSetup."POS Print Action"::OFFLINE:
                        begin
                            MembershipManagement.PrintOffline(MemberInfoCapture."Information Context"::PRINT_MEMBERSHIP, MembershipEntry."Membership Entry No.");

                            if (ForceCardPrint or (CheckSalesSetupForCardPrint(MembershipEntry."Item No."))) then begin
                                if (MembershipEntry."Member Card Entry No." <> 0) then begin
                                    MemberCard.SetFilter("Entry No.", '%1..', MembershipEntry."Member Card Entry No.");
                                    MemberCard.SetFilter("Membership Entry No.", '=%1', MembershipEntry."Membership Entry No.");
                                    if (MemberCard.FindSet()) then begin
                                        repeat
                                            MembershipManagement.PrintOffline(MemberInfoCapture."Information Context"::PRINT_CARD, MemberCard."Entry No.");
                                        until (MemberCard.Next() = 0);
                                    end;
                                end;
                            end;

                        end;
                end;
            end;

        until (MembershipEntry.Next() = 0);

    end;

    procedure PrintMembershipSalesReceiptWorker(var Membership: Record "NPR MM Membership"; var MembershipSetup: Record "NPR MM Membership Setup")
    var
        PrintTemplateMgt: Codeunit "NPR RP Template Mgt.";
    begin

        case MembershipSetup."Receipt Print Object Type" of
            MembershipSetup."Receipt Print Object Type"::NO_PRINT:
                ;

            MembershipSetup."Receipt Print Object Type"::CODEUNIT:
                Codeunit.Run(MembershipSetup."Receipt Print Object ID", Membership);

            MembershipSetup."Receipt Print Object Type"::REPORT:
                Report.Run(MembershipSetup."Receipt Print Object ID", false, false, Membership);

            MembershipSetup."Receipt Print Object Type"::TEMPLATE:
                PrintTemplateMgt.PrintTemplate(MembershipSetup."Receipt Print Template Code", Membership, 0);
        end;
    end;

    procedure PrintMemberAccountCard(ExternalMemberNo: Code[20])
    var
        Member: Record "NPR MM Member";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberEntryNo: Integer;
        MembershipEntryNo: Integer;
        MemberManagement: Codeunit "NPR MM MembershipMgtInternal";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin

        MemberEntryNo := MemberManagement.GetMemberFromExtMemberNo(ExternalMemberNo);
        if (not Member.Get(MemberEntryNo)) then
            Error(BLOCKED_NOT_FOUND, ExternalMemberNo);

        MembershipEntryNo := MemberManagement.GetMembershipFromExtMemberNo(ExternalMemberNo);
        if (not Membership.Get(MembershipEntryNo)) then
            Error(BLOCKED_NOT_FOUND, ExternalMemberNo);

        MembershipSetup.Get(Membership."Membership Code");
        Member.SetFilter("Entry No.", '=%1', Member."Entry No.");

        case MembershipSetup."POS Print Action" of
            MembershipSetup."POS Print Action"::DIRECT:
                PrintMemberAccountCardWorker(Member, MembershipSetup);
            MembershipSetup."POS Print Action"::OFFLINE:
                MemberManagement.PrintOffline(MemberInfoCapture."Information Context"::PRINT_ACCOUNT, Member."Entry No.");
        end;
    end;

    procedure PrintMemberAccountCardWorker(var Member: Record "NPR MM Member"; var MembershipSetup: Record "NPR MM Membership Setup")
    var
        PrintTemplateMgt: Codeunit "NPR RP Template Mgt.";
    begin

        case MembershipSetup."Account Print Object Type" of
            MembershipSetup."Account Print Object Type"::NO_PRINT:
                Error(NO_PRINTOUT, MembershipSetup.Code);

            MembershipSetup."Account Print Object Type"::CODEUNIT:
                CODEUNIT.Run(MembershipSetup."Account Print Object ID", Member);

            MembershipSetup."Account Print Object Type"::REPORT:
                Report.Run(MembershipSetup."Account Print Object ID", false, false, Member);

            MembershipSetup."Account Print Object Type"::TEMPLATE:
                PrintTemplateMgt.PrintTemplate(MembershipSetup."Account Print Template Code", Member, 0);

            else
                Error(ILLEGAL_VALUE, MembershipSetup."Account Print Object Type", MembershipSetup.FieldCaption("Account Print Object Type"));
        end;
    end;

    procedure PrintMemberCard(MemberEntryNo: Integer; MemberCardEntryNo: Integer)
    var
        Member: Record "NPR MM Member";
        MemberCard: Record "NPR MM Member Card";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberManagement: Codeunit "NPR MM MembershipMgtInternal";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin

        if (not MemberCard.Get(MemberCardEntryNo)) then
            Error(CARD_BLOCKED_NOT_FOUND, MemberCardEntryNo);

        if (MemberEntryNo <> MemberCard."Member Entry No.") then
            Error(CARD_BLOCKED_NOT_FOUND, MemberCardEntryNo);

        if (not Member.Get(MemberEntryNo)) then
            Error(BLOCKED_NOT_FOUND, MemberEntryNo);

        Membership.Get(MemberCard."Membership Entry No.");
        MembershipSetup.Get(Membership."Membership Code");

        MemberCard.SetFilter("Entry No.", '=%1', MemberCard."Entry No.");
        MemberCard.FindFirst();

        if ((MemberCard.Blocked) or (Membership.Blocked)) then
            if (not Confirm(CONFIRM_CARD_BLOCKED, true)) then
                Error('');

        case MembershipSetup."POS Print Action" of
            MembershipSetup."POS Print Action"::DIRECT:
                PrintMemberCardWorker(MemberCard, MembershipSetup);
            MembershipSetup."POS Print Action"::OFFLINE:
                MemberManagement.PrintOffline(MemberInfoCapture."Information Context"::PRINT_CARD, MemberCard."Entry No.");
        end;
    end;

    procedure PrintMemberCardWorker(var MemberCard: Record "NPR MM Member Card"; var MembershipSetup: Record "NPR MM Membership Setup")
    var
        PrintTemplateMgt: Codeunit "NPR RP Template Mgt.";
    begin

        case MembershipSetup."Card Print Object Type" of
            MembershipSetup."Card Print Object Type"::NO_PRINT:
                Error(NO_PRINTOUT, MembershipSetup.Code);

            MembershipSetup."Card Print Object Type"::CODEUNIT:
                CODEUNIT.Run(MembershipSetup."Card Print Object ID", MemberCard);

            MembershipSetup."Card Print Object Type"::REPORT:
                Report.Run(MembershipSetup."Card Print Object ID", false, false, MemberCard);

            MembershipSetup."Receipt Print Object Type"::TEMPLATE:
                PrintTemplateMgt.PrintTemplate(MembershipSetup."Card Print Template Code", MemberCard, 0);

            else
                Error(ILLEGAL_VALUE, MembershipSetup."Card Print Object Type", MembershipSetup.FieldCaption("Card Print Object Type"));
        end;
    end;

    local procedure CheckSalesSetupForCardPrint(ItemNo: Code[20]): Boolean
    var
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
    begin

        MembershipSalesSetup.SetFilter(Type, '=%1', MembershipSalesSetup.Type::ITEM);
        MembershipSalesSetup.SetFilter("No.", '=%1', ItemNo);
        if (not MembershipSalesSetup.FindFirst()) then
            exit(true); // the setup was deleted - assume true

        exit(MembershipSalesSetup."Member Card Type" in [MembershipSalesSetup."Member Card Type"::CARD, MembershipSalesSetup."Member Card Type"::CARD_PASSSERVER]);
    end;

    procedure IssueTicketFromMemberScan(Member: Record "NPR MM Member"; ItemCrossReference: Code[50]; var TicketNo: Code[20]; var ResponseMessage: Text): Integer
    var
        InvalidItemNo: Label 'Invalid Item Number %1';
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
    begin
        if (not TranslateBarcodeToItemVariant(ItemCrossReference, ItemNo, VariantCode, ResolvingTable)) then begin
            ResponseMessage := StrSubstNo(InvalidItemNo, ItemCrossReference);
            exit(-1);
        end;

        exit(IssueTicketFromMemberScan(true, ItemNo, VariantCode, Member, TicketNo, ResponseMessage));
    end;

    procedure IssueTicketFromMemberScan(FailWithError: Boolean; ItemNo: Code[20]; VariantCode: Code[10]; Member: Record "NPR MM Member"; var TicketNo: Code[20]; var ResponseMessage: Text) ResponseCode: Integer
    var
        Item: Record Item;
        TicketType: Record "NPR TM Ticket Type";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        Token: Text[100];
        InvalidTicketType: Label 'Item number %1 has no ticket type specified.';
        NotTicket: Label 'Ticket Type %1 is not a ticket.';
        NotificationAddress: Text[100];
        NotificationMethod: Code[10];
        NotificationEngine: Option;
    begin

        Item.Get(ItemNo);
        if (not TicketType.Get(Item."NPR Ticket Type")) then begin
            ResponseMessage := StrSubstNo(InvalidTicketType, ItemNo);
            exit(-1);
        end;
        if (not TicketType."Is Ticket") then begin
            ResponseMessage := StrSubstNo(NotTicket, TicketType.Code);
            exit(-1);
        end;

        MembershipManagement.GetCommunicationMethod_Ticket(Member."Entry No.", 0, NotificationMethod, NotificationAddress, NotificationEngine);

        TicketRequestManager.LockResources('IssueTicketFromMemberScan');

        Token := TicketRequestManager.CreateReservationRequest(ItemNo, VariantCode, 1, Member."External Member No.");
        TicketRequestManager.SetReservationRequestExtraInfo(Token, NotificationAddress, Member."External Member No.", Member."Display Name");
        ResponseCode := TicketRequestManager.IssueTicketFromReservationToken(Token, FailWithError, ResponseMessage);
        if (ResponseCode <> 0) then
            exit(ResponseCode);

        TicketRequestManager.ConfirmReservationRequestWithValidate(Token);
        if (not TicketRequestManager.GetTokenTicket(Token, TicketNo)) then
            Error(TICKET_NOT_FOUND);

        exit(0);
    end;

    procedure NewMemberSalesInfoCapture(SaleLinePOS: Record "NPR POS Sale Line") ReturnCode: Integer
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        Item: Record Item;
        MembershipSetup: Record "NPR MM Membership Setup";
        i: Integer;
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MemberLinesToSuggest: Integer;
        ReasonMessage: Text;
        AttemptCreateMembership: Codeunit "NPR Membership Attempt Create";
        POSSession: Codeunit "NPR POS Session";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin

        if (SaleLinePOS.Quantity < 0) then
            exit(0); // Not for us, is cancel/regret

        if (not MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, SaleLinePOS."No.")) then
            exit(0);

        if (not Item.Get(SaleLinePOS."No.")) then
            exit(0);

        if (SaleLinePOS.Quantity <> 1) then
            exit(-1101);

        if (not CheckCrossLineSalesRules(SaleLinePOS, gLastMessage)) then
            exit(-1100);

        if ((MembershipSalesSetup."Membership Code" = '') and
          (MembershipSalesSetup."Business Flow Type" in [MembershipSalesSetup."Business Flow Type"::ADD_CARD, MembershipSalesSetup."Business Flow Type"::REPLACE_CARD])) then begin
            MembershipSetup.Init();
        end else begin
            if (not MembershipSetup.Get(MembershipSalesSetup."Membership Code")) then
                exit(-1103);
        end;

        if (MembershipSetup."Membership Member Cardinality" < 2) then
            MembershipSetup."Membership Member Cardinality" := 1;

        if (MembershipSetup."Membership Type" = MembershipSetup."Membership Type"::INDIVIDUAL) then begin
            MembershipSetup."Membership Member Cardinality" := 1;
            MembershipSalesSetup."Suggested Membercount In Sales" := 1;
        end;

        MemberInfoCapture.SetCurrentKey("Receipt No.", "Line No.");
        MemberInfoCapture.SetFilter("Receipt No.", '=%1', SaleLinePOS."Sales Ticket No.");
        MemberInfoCapture.SetFilter("Line No.", '=%1', SaleLinePOS."Line No.");

        // create defaults depending how my "revisit" to member info capture occurs
        if (MemberInfoCapture.IsEmpty()) then begin
            case MembershipSalesSetup."Business Flow Type" of
                MembershipSalesSetup."Business Flow Type"::MEMBERSHIP:
                    begin
                        MemberLinesToSuggest := MembershipSetup."Membership Member Cardinality";
                        if ((MembershipSalesSetup."Suggested Membercount In Sales" > 0) and
                            (MembershipSalesSetup."Suggested Membercount In Sales" < MembershipSetup."Membership Member Cardinality"))
                        then
                            MemberLinesToSuggest := MembershipSalesSetup."Suggested Membercount In Sales";

                        for i := 1 to MemberLinesToSuggest do begin
                            MemberInfoCapture.Init();
                            MemberInfoCapture."Entry No." := 0;
                            MemberInfoCapture."Receipt No." := SaleLinePOS."Sales Ticket No.";
                            MemberInfoCapture."Line No." := SaleLinePOS."Line No.";
                            MemberInfoCapture."First Name" := StrSubstNo(MEMBER_NAME, i);
                            MemberInfoCapture."Item No." := SaleLinePOS."No.";
                            MemberInfoCapture."Membership Code" := MembershipSalesSetup."Membership Code";
                            MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::NEW;
                            MemberInfoCapture.Insert();
                        end;
                    end;

                MembershipSalesSetup."Business Flow Type"::ADD_NAMED_MEMBER,
                MembershipSalesSetup."Business Flow Type"::ADD_ANONYMOUS_MEMBER,
                MembershipSalesSetup."Business Flow Type"::ADD_CARD,
                MembershipSalesSetup."Business Flow Type"::REPLACE_CARD:
                    begin
                        MemberInfoCapture.Init();
                        MemberInfoCapture."Entry No." := 0;
                        MemberInfoCapture."Receipt No." := SaleLinePOS."Sales Ticket No.";
                        MemberInfoCapture."Line No." := SaleLinePOS."Line No.";
                        MemberInfoCapture."Item No." := SaleLinePOS."No.";
                        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::NEW;
                        MemberInfoCapture.Insert();
                    end;

                else
                    Error('Business Flow Type %1 not handled when preparing user input.', MembershipSalesSetup."Business Flow Type");
            end;
        end;

        Commit();
        if (DisplayMemberInfoCaptureDialog(SaleLinePOS)) then begin
            Commit();

            MemberInfoCapture.FindFirst();

            if (MemberInfoCapture."Information Context" = MemberInfoCapture."Information Context"::NEW) then begin
                if (MembershipSalesSetup."Auto-Admit Member On Sale" = MembershipSalesSetup."Auto-Admit Member On Sale"::ASK) then
                    if (Confirm(ADMIT_MEMBERS, true)) then
                        MemberInfoCapture.ModifyAll("Auto-Admit Member", true);

                if (MembershipSalesSetup."Auto-Admit Member On Sale" = MembershipSalesSetup."Auto-Admit Member On Sale"::YES) then
                    MemberInfoCapture.ModifyAll("Auto-Admit Member", true);
            end;

            Commit();
            AttemptCreateMembership.SetAttemptCreateMembershipForcedRollback();
            if (not AttemptCreateMembership.run(MemberInfoCapture)) then
                if (not AttemptCreateMembership.WasSuccessful(ReasonMessage)) then
                    Error(ReasonMessage);

            if (SaleLinePOS.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Sale Type", SaleLinePOS."Line No.")) then begin
                SaleLinePOS."Description 2" := MemberInfoCapture."External Membership No.";
                SaleLinePOS.Modify();
            end;

            Commit();
            exit(1);
        end;

        DeleteMemberInfoCapture(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.");

        // When a sales line is created as part of web service (f.ex coupon complimentary item)
        if (not GuiAllowed()) then
            exit(-1100);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.DeleteLine();

        Commit();

        if (ReasonMessage <> '') then begin
            gLastMessage := ReasonMessage;
            exit(-1100);
        end;

        exit(-1102);
    end;

    internal procedure CheckCrossLineSalesRules(SaleLinePOS: Record "NPR POS Sale Line"; var ReasonText: Text): Boolean
    var
        ValidateAcrossSalesLines: Record "NPR POS Sale Line";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MixedSaleRuleOption: Option ALLOW,MEMBERSHIP_ITEM,SAME_ITEM,DISALLOW;
        TotalItemCount: Integer;
        MembershipItemCount: Integer;
        LimitedByItem: Code[20];
        MixedSalesNotAllowedLbl: Label 'Mixed sales is not allowed due to policy specified on item %1 in %2';
    begin
        MixedSaleRuleOption := MixedSaleRuleOption::ALLOW;

        ValidateAcrossSalesLines.SetFilter("Register No.", '=%1', SaleLinePOS."Register No.");
        ValidateAcrossSalesLines.SetFilter("Sales Ticket No.", '=%1', SaleLinePOS."Sales Ticket No.");
        if (ValidateAcrossSalesLines.FindSet()) then begin
            repeat
                if (MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, ValidateAcrossSalesLines."No.")) then
                    if (MembershipSalesSetup."Mixed Sale Policy" > MixedSaleRuleOption) then begin
                        MixedSaleRuleOption := MembershipSalesSetup."Mixed Sale Policy";
                        LimitedByItem := ValidateAcrossSalesLines."No.";
                    end;
            until (ValidateAcrossSalesLines.Next() = 0);

            if (MixedSaleRuleOption > MixedSaleRuleOption::ALLOW) then begin
                ValidateAcrossSalesLines.FindSet();
                repeat
                    TotalItemCount += 1;
                    if (MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, ValidateAcrossSalesLines."No.")) then begin

                        if (MixedSaleRuleOption = MixedSaleRuleOption::SAME_ITEM) then
                            if (SaleLinePOS."No." = ValidateAcrossSalesLines."No.") then
                                MembershipItemCount += 1;

                        if (MixedSaleRuleOption = MixedSaleRuleOption::MEMBERSHIP_ITEM) then
                            if (MembershipSalesSetup."Business Flow Type" = MembershipSalesSetup."Business Flow Type"::MEMBERSHIP) then
                                MembershipItemCount += 1;

                        if (MixedSaleRuleOption = MixedSaleRuleOption::DISALLOW) then
                            MembershipItemCount := 1;
                    end;
                until (ValidateAcrossSalesLines.Next() = 0);

                if (TotalItemCount <> MembershipItemCount) then begin
                    ReasonText := StrSubstNo(MixedSalesNotAllowedLbl, LimitedByItem, MembershipSalesSetup.TableCaption());
                    exit(false);
                end;
            end;
        end;

        exit(true);
    end;

    procedure DisplayMemberInfoCaptureDialog(SaleLinePOS: Record "NPR POS Sale Line") LookupOK: Boolean
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipEvents: Codeunit "NPR MM Membership Events";
        MemberInfoCapturePage: Page "NPR MM Member Info Capture";
        MemberInfoCaptureListPage: Page "NPR MM Member Capture List";
        PageAction: Action;
        ShowStandardUserInterface: Boolean;
    begin

        MemberInfoCapture.Reset();
        MemberInfoCapture.FilterGroup(2);
        MemberInfoCapture.Reset();

        MemberInfoCapture.SetCurrentKey("Receipt No.", "Line No.");
        MemberInfoCapture.SetFilter("Receipt No.", '=%1', SaleLinePOS."Sales Ticket No.");
        MemberInfoCapture.SetFilter("Line No.", '=%1', SaleLinePOS."Line No.");
        MemberInfoCapture.FilterGroup(0);
        MemberInfoCapture.FindSet();

        ShowStandardUserInterface := true;
        LookupOK := true;
        MembershipEvents.OnBeforeMembInfoCaptureDialog(MemberInfoCapture, ShowStandardUserInterface);

        if (ShowStandardUserInterface) then begin
            if (GuiAllowed()) then begin
                if (MemberInfoCapture.Count() > 1) then begin
                    MemberInfoCaptureListPage.SetTableView(MemberInfoCapture);
                    MemberInfoCaptureListPage.SetPOSUnit(SaleLinePOS."Register No.");
                    MemberInfoCaptureListPage.LookupMode(true);
                    MemberInfoCaptureListPage.Editable(true);
                    PageAction := MemberInfoCaptureListPage.RunModal();
                end else begin
                    MemberInfoCapturePage.SetTableView(MemberInfoCapture);
                    MemberInfoCapturePage.SetPOSUnit(SaleLinePOS."Register No.");
                    MemberInfoCapturePage.LookupMode(true);
                    MemberInfoCapturePage.Editable(true);
                    PageAction := MemberInfoCapturePage.RunModal();
                end;
                LookupOK := (PageAction = Action::LookupOK);
            end else begin
                LookupOK := false;
            end;
        end;

        MembershipEvents.OnAfterMembInfoCaptureDialog(MemberInfoCapture, ShowStandardUserInterface, LookupOK);
        exit(LookupOK);
    end;

    [EventSubscriber(ObjectType::"Codeunit", Codeunit::"NPR POS Create Entry", 'OnAfterInsertPOSSalesLine', '', true, true)]
    local procedure IssueMembersFromPosEntrySaleLine(POSEntry: Record "NPR POS Entry"; var POSSalesLine: Record "NPR POS Entry Sales Line")
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin

        MemberInfoCapture.SetCurrentKey("Receipt No.", "Line No.");
        MemberInfoCapture.SetFilter("Receipt No.", '=%1', POSEntry."Document No.");
        MemberInfoCapture.SetFilter("Line No.", '=%1', POSSalesLine."Line No.");
        if (not MemberInfoCapture.FindSet()) then
            exit;

        if (POSSalesLine."No." <> MemberInfoCapture."Item No.") then
            exit;

        IssueMembershipFromEndOfSaleWorker(POSEntry."Document No.",
            POSSalesLine."Line No.", POSEntry."Document Date",
            POSSalesLine."Unit Price", POSSalesLine."Amount Excl. VAT", POSSalesLine."Amount Incl. VAT", POSSalesLine.Description, POSSalesLine.Quantity);
    end;

    internal procedure IssueMembershipFromEndOfSaleWorker(ReceiptNo: Code[20]; ReceiptLine: Integer; SalesDate: Date; UnitPrice: Decimal; Amount_LCY: Decimal; AmountInclVat_LCY: Decimal; Description: Text; Quantity: Decimal)
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        CreateMembership: Codeunit "NPR Membership Attempt Create";
    begin
        MemberInfoCapture.LockTable(true);
        MemberInfoCapture.SetCurrentKey("Receipt No.", "Line No.");
        MemberInfoCapture.SetFilter("Receipt No.", '=%1', ReceiptNo);
        MemberInfoCapture.SetFilter("Line No.", '=%1', ReceiptLine);
        if (not MemberInfoCapture.FindSet()) then
            exit;

        repeat
            MemberInfoCapture."Unit Price" := UnitPrice;
            MemberInfoCapture.Amount := Amount_LCY;
            MemberInfoCapture."Amount Incl VAT" := AmountInclVat_LCY;
            MemberInfoCapture.Description := CopyStr(Description, 1, MaxStrLen(MemberInfoCapture.Description));
            MemberInfoCapture.Quantity := Quantity;
            MemberInfoCapture."Document Date" := SalesDate;
            MemberInfoCapture.Modify();
        until (MemberInfoCapture.Next() = 0);

        CreateMembership.SetCreateMembership();
        CreateMembership.Run(MemberInfoCapture);
    end;

    // This is outside of the end sales transactions, issuing tickets is considered same as printing
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnAfterEndSale', '', true, true)]
    local procedure AdmitMembersOnEndOfSales(SalePOS: Record "NPR POS Sale")
    var
        MemberInfoCaptureSales: Record "NPR MM Member Info Capture";
        MemberInfoCaptureLine: Record "NPR MM Member Info Capture";
        ReasonCode: Integer;
        ReasonText: Text;
        PreviousLineNo: Integer;
        AdmittedCount: Integer;
        MemberTicketAdmitError: Label 'When auto-admitting member %1, the following error occurred: %2';
        MemberTicketConfirm: Label '%1 member(s) automatically admitted.';
    begin

        if (SalePOS."Sales Ticket No." = '') then
            exit;

        MemberInfoCaptureSales.SetCurrentKey("Receipt No.", "Line No.");
        MemberInfoCaptureSales.SetFilter("Receipt No.", '=%1', SalePOS."Sales Ticket No.");
        if (not MemberInfoCaptureSales.FindSet()) then
            exit;

        PreviousLineNo := -1;
        repeat
            ReasonCode := 0;
            if (PreviousLineNo <> MemberInfoCaptureSales."Line No.") then begin
                MemberInfoCaptureLine.SetCurrentKey("Receipt No.", "Line No.");
                MemberInfoCaptureLine.SetFilter("Receipt No.", '=%1', MemberInfoCaptureSales."Receipt No.");
                MemberInfoCaptureLine.SetFilter("Line No.", '=%1', MemberInfoCaptureSales."Line No.");

                if (not AdmitMembersOnEndOfSalesWorker(MemberInfoCaptureLine, AdmittedCount, SalePOS."Register No.", ReasonCode, ReasonText)) then
                    Message(MemberTicketAdmitError, MemberInfoCaptureLine."First Name" + ' ' + MemberInfoCaptureLine."Last Name", ReasonText);
            end;
            PreviousLineNo := MemberInfoCaptureSales."Line No.";
        until ((MemberInfoCaptureSales.Next() = 0));

        MemberInfoCaptureSales.DeleteAll();
        Commit();

        if (AdmittedCount > 0) then
            Message(MemberTicketConfirm, AdmittedCount);

    end;

    local procedure AdmitMembersOnEndOfSalesWorker(var MemberInfoCapture: Record "NPR MM Member Info Capture"; var AdmittedCount: Integer; PosUnitNo: Code[10]; var ReasonCode: Integer; var ReasonText: Text) MemberArrivalOk: Boolean
    var
        MemberCard: Record "NPR MM Member Card";
        AttemptArrival: Codeunit "NPR MM Attempt Member Arrival";
        MemberLimitationMgr: Codeunit "NPR MM Member Lim. Mgr.";
        LogEntryNo: Integer;
    begin
        MemberInfoCapture.FindSet();

        if (not MemberInfoCapture."Auto-Admit Member") then
            exit(true); // Is consistent for all members on the same sales line

        if (not (MemberInfoCapture."Information Context" in [MemberInfoCapture."Information Context"::NEW,
                                              MemberInfoCapture."Information Context"::RENEW,
                                              MemberInfoCapture."Information Context"::UPGRADE,
                                              MemberInfoCapture."Information Context"::EXTEND])) then
            exit(true); // Nothing to do

        // Check that member limitations allow arrival
        repeat
            MemberCard.Get(MemberInfoCapture."Card Entry No.");
            MemberLimitationMgr.POS_CheckLimitMemberCardArrival(MemberCard."External Card No.", '', '<auto>', LogEntryNo, ReasonText, ReasonCode);
            if (ReasonCode <> 0) then
                exit(false);
        until (MemberInfoCapture.Next() = 0);

        // Batch register arrival creating tickets.
        Commit();
        AttemptArrival.AttemptMemberArrival(MemberInfoCapture, '', PosUnitNo, '<auto>');
        MemberArrivalOk := AttemptArrival.Run();

        // Log arrival message. 
        ReasonCode := AttemptArrival.GetAttemptMemberArrivalResponse(ReasonText);
        MemberLimitationMgr.UpdateLogEntry(LogEntryNo, ReasonCode, ReasonText); // TODO: Add LogEntryNo to InfoCapture and update all entries ... 

        AdmittedCount += MemberInfoCapture.Count();
        exit(MemberArrivalOk);

    end;

    procedure DeletePreemptiveMembership(ReceiptNo: Code[20]; LineNo: Integer)
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MemberManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin

        MemberInfoCapture.SetCurrentKey("Receipt No.", "Line No.");
        MemberInfoCapture.SetFilter("Receipt No.", '=%1', ReceiptNo);
        MemberInfoCapture.SetFilter("Line No.", '=%1', LineNo);
        if (not MemberInfoCapture.FindFirst()) then
            exit;

        if (not MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, MemberInfoCapture."Item No.")) then
            exit;

        case MembershipSalesSetup."Business Flow Type" of
            MembershipSalesSetup."Business Flow Type"::MEMBERSHIP:
                MemberManagement.DeleteMembership(MemberInfoCapture."Membership Entry No.", true);
        end;
    end;

    procedure GetErrorText(MsgNo: Integer) ErrorText: Text
    begin

        ErrorText := '';
        case MsgNo of
            -1100:
                exit(gLastMessage);
            -1102:
                exit(MSG_1102);
            -1103:
                exit(MSG_1103);
            -1104:
                exit(CARD_BLOCKED_NOT_FOUND);
            -1105:
                exit(MSG_1105);
        end;

    end;

    local procedure DeleteMemberInfoCapture(ReceiptNo: Code[20]; LineNo: Integer)
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin

        MemberInfoCapture.SetCurrentKey("Receipt No.", "Line No.");

        MemberInfoCapture.SetFilter("Receipt No.", '=%1', ReceiptNo);
        MemberInfoCapture.SetFilter("Line No.", '=%1', LineNo);
        if (not MemberInfoCapture.IsEmpty()) then begin
            MemberInfoCapture.DeleteAll();
            Commit();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sales Workflow Step", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "NPR POS Sales Workflow Step"; RunTrigger: Boolean)
    begin

        if (Rec."Subscriber Codeunit ID" <> CurrCodeunitId()) then
            exit;
        if (Rec."Subscriber Function" <> 'PrintMembershipsOnSale') then
            exit;

        Rec.Description := Text000;
        Rec."Sequence No." := 100;
    end;

    local procedure CurrCodeunitId(): Integer
    begin

        exit(CODEUNIT::"NPR MM Member Retail Integr.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnFinishSale', '', true, true)]
    local procedure PrintMembershipsOnSale(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SalePOS: Record "NPR POS Sale")
    var
        POSEntry: Record "NPR POS Entry";
    begin

        if (POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId()) then
            exit;
        if (POSSalesWorkflowStep."Subscriber Function" <> 'PrintMembershipsOnSale') then
            exit;

        POSEntry.SetFilter("Document No.", '=%1', SalePOS."Sales Ticket No.");
        if (POSEntry.isempty()) then
            exit;

        PrintMembershipOnEndOfSalesWorker(SalePOS."Sales Ticket No.", false);

    end;

    procedure TranslateBarcodeToItemVariant(Barcode: Text[50]; var ItemNo: Code[20]; var VariantCode: Code[10]; var ResolvingTable: Integer) Found: Boolean
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
    begin

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

        if (StrLen(Barcode) <= MaxStrLen(ItemReference."Reference No.")) then begin
            ItemReference.SetCurrentKey("Reference Type", "Reference No.");
            ItemReference.SetFilter("Reference Type", '=%1', ItemReference."Reference Type"::"Bar Code");
            ItemReference.SetFilter("Reference No.", '=%1', UpperCase(Barcode));
            if (ItemReference.FindFirst()) then begin
                ResolvingTable := DATABASE::"Item Reference";
                ItemNo := ItemReference."Item No.";
                VariantCode := ItemReference."Variant Code";
                exit(true);
            end;
        end;
        exit(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Sales Doc. Exp. Mgt.", 'OnAfterDebitSalePostEvent', '', true, true)]
    local procedure OnAfterDebitSalePostSubscriber(var Sender: Codeunit "NPR Sales Doc. Exp. Mgt."; SalePOS: Record "NPR POS Sale"; SalesHeader: Record "Sales Header"; Posted: Boolean)
    begin

        if (SalePOS."Sales Ticket No." = '') then
            exit;

        PrintMembershipOnEndOfSalesWorker(SalePOS."Sales Ticket No.", false);
    end;

    internal procedure CreateMembershipFromJson(JObject: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management"): JsonObject
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        PosSale: Record "NPR POS Sale";
        POSActionInsertItemB: Codeunit "NPR POS Action: Insert Item B";
        Sale: Codeunit "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        POSSession: Codeunit "NPR POS Session";
        Base64: Codeunit "Base64 Convert";
        TextHelper: Codeunit "NPR MM Text Helper";
        JToken: JsonToken;
        ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference,ItemGtin;
        ItemIdentifier: Text;
    begin

        if (JObject.Get('data', JToken)) then
            // payload is base 64 encoded
            JObject.ReadFrom(Base64.FromBase64(JToken.AsValue().AsText()));

        // {"in":"320100","m":[]}
        ItemIdentifier := TextHelper.AsText('in', JObject, 100);
        POSActionInsertItemB.GetItem(Item, ItemReference, ItemIdentifier, ItemIdentifierType);
        POSSession.GetSale(Sale);
        POSSession.GetSaleLine(SaleLine);
        Sale.GetCurrentSale(PosSale);

        JObject.Get('m', JToken);
        PreloadMemberInfoBuffer(PosSale."Sales Ticket No.", SaleLine.GetNextLineNo(), Item."No.", JToken.AsArray());

        POSActionInsertItemB.AddItemLine(Item, ItemReference, ItemIdentifierType::ItemNo, 1, 0, '', '', '', POSSession, FrontEnd);
    end;

    internal procedure PreloadMemberInfoBuffer(SalesTicketNo: Code[20]; LineNo: Integer; ItemNo: Code[20]; Members: JsonArray)
    var
        MemberInfo: Record "NPR MM Member Info Capture";
        MemberToken: JsonToken;
        Member: JsonObject;

    begin
        foreach MemberToken in Members do begin
            // {"fn":"Tim","ln":"Sannes","ad":"Spaljevägen 9","pc":"197 36","ct":"Bro","cc":"SE","em":"tsa@navipartner.dk","pn":"0732542026"}
            Member := MemberToken.AsObject();

            Clear(MemberInfo);
            MemberInfo."Receipt No." := SalesTicketNo;
            MemberInfo."Line No." := LineNo;
            MemberInfo."Item No." := ItemNo;
            MemberJSonToMemberInfo(Member, MemberInfo);
            MemberInfo.Insert();
        end;
    end;

    internal procedure MemberJSonToMemberInfo(Member: JsonObject; var MemberInfo: Record "NPR MM Member Info Capture")
    var
        TextHelper: Codeunit "NPR MM Text Helper";
    begin
        MemberInfo."First Name" := TextHelper.AsText50('fn', Member);
        MemberInfo."Last Name" := TextHelper.AsText50('ln', Member);
        MemberInfo.Address := TextHelper.AsText100('ad', Member);
        MemberInfo.City := TextHelper.AsText50('ct', Member);
        MemberInfo."Post Code Code" := TextHelper.AsText20('pc', Member);
        MemberInfo."Country Code" := TextHelper.AsText10('cc', Member);
        MemberInfo."E-Mail Address" := LowerCase(TextHelper.AsText80('em', Member));
        MemberInfo."Phone No." := TextHelper.AsText30('pn', Member);

        MemberInfo."News Letter" := GetNewsLetter(Member);
        MemberInfo.Gender := GetGender(Member);
    end;

    local procedure GetNewsLetter(JObject: JsonObject): Option
    var
        JToken: JsonToken;
        MemberInfo: Record "NPR MM Member Info Capture";
    begin
        if (not (JObject.Get('nl', JToken))) then
            exit(MemberInfo."News Letter"::NOT_SPECIFIED);

        case UpperCase(JToken.AsValue().AsText()) of
            'YES', 'Y', 'TRUE':
                exit(MemberInfo."News Letter"::YES);
            'NO', 'N', 'FALSE':
                exit(MemberInfo."News Letter"::NO);
            else
                exit(MemberInfo."News Letter"::NOT_SPECIFIED);
        end;
    end;

    local procedure GetGender(JObject: JsonObject): Option
    var
        JToken: JsonToken;
        MemberInfo: Record "NPR MM Member Info Capture";
    begin
        if (not (JObject.Get('gr', JToken))) then
            exit(MemberInfo.Gender::NOT_SPECIFIED);

        case UpperCase(JToken.AsValue().AsText()) of
            'MALE', 'M':
                exit(MemberInfo.Gender::MALE);
            'FEMALE', 'F':
                exit(MemberInfo.Gender::FEMALE);
            'OTHER':
                exit(MemberInfo.Gender::OTHER);
            else
                exit(MemberInfo.Gender::NOT_SPECIFIED);
        end;
    end;

}


