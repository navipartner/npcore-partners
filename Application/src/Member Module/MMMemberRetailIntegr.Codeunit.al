codeunit 6060131 "NPR MM Member Retail Integr."
{

    var
        MEMBER_MANAGEMENT: Label 'Member Services';
        MEMBER_CARD_NO: Label 'Member Card Number';
        MEMBER_NOT_RECOGNIZED: Label 'Can''t identify member.';
        ILLEGAL_VALUE: Label 'Value %1 is not a valid %2.';
        MEMBERSHIP_NOT_VALID: Label 'The membership %1 is not valid for today.';
        BLOCKED_NOT_FOUND: Label 'Member %1 is either blocked or not found.';
        CARD_BLOCKED_NOT_FOUND: Label 'Member Card %1 is either blocked or not found.';
        NO_PRINTOUT: Label 'Membership %1 is not setup for printing.';

        MSG_1102: Label 'Member registration aborted.';
        MSG_1103: Label 'Membership code specified on sales item was not found.';
        MSG_1105: Label 'Nothing to edit.';
        MEMBER_NAME: Label 'Member - %1';
        TICKET_NOT_FOUND: Label 'Ticket not found.';
        UI: Codeunit "NPR MM Member POS UI";
        MEMBERCARD_EXPIRED: Label 'The membercard %1 has expired.';
        gLastMessage: Text;
        Text000: Label 'Print Membership';
        INVALID_TICKET_ITEM: Label 'Ticket Item specified on %1 %2, is not valid. ';
        ADMIT_MEMBERS: Label 'Do you want to admit the member(s)?';
        CONFIRM_CARD_BLOCKED: Label 'This membercard is blocked, do you want to continue anyway?';


    trigger OnRun()
    var
    begin

    end;


    procedure POS_ValidateMemberCardNo(FailWithError: Boolean; AllowVerboseMode: Boolean; InputMode: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT; ActivateMembership: Boolean; var ExternalMemberCardNo: Text[100]): Boolean
    var
        MembershipEntryNo: Integer;
        MemberManagement: Codeunit "NPR MM Membership Mgt.";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        Member: Record "NPR MM Member";
        MemberEntryNo: Integer;
        MemberCard: Record "NPR MM Member Card";
        NotFoundReasonText: Text;
        MustActivate: Boolean;
        POSMemberCard: Page "NPR MM POS Member Card";
        ForeignMembershipMgr: Codeunit "NPR MM Foreign Members. Mgr.";
        ForeignCardIsValid: Boolean;
        ForeignMembershipEntryNo: Integer;
        ForeignCommunityCode: Code[20];
        ForeignManagerCode: Code[20];
        FormatedCardNumber: Text[50];
        FormatedForeignCardNumber: Text[50];
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
        MemberManagement: Codeunit "NPR MM Membership Mgt.";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        Member: Record "NPR MM Member";
        MemberEntryNo: Integer;
        MemberCard: Record "NPR MM Member Card";
        NotFoundReasonText: Text;
        MustActivate: Boolean;
        POSMemberCard: Page "NPR MM POS Member Card";
        ForeignMembershipMgr: Codeunit "NPR MM Foreign Members. Mgr.";
        ForeignCardIsValid: Boolean;
        ForeignMembershipEntryNo: Integer;
        ForeignCommunityCode: Code[20];
        ForeignManagerCode: Code[20];
        FormatedCardNumber: Text[100];
        FormatedForeignCardNumber: Text[100];
        ShowMemberDialog: Boolean;
        PageAction: Action;
    begin

        case InputMode of
            InputMode::NO_PROMPT:
                ; // Prevalidated
            InputMode::CARD_SCAN:
                Error('CARD_SCAN is an obsolete feature of POS_ValidateMemberCardNoWorker()');
            InputMode::FACIAL_RECOGNITION:
                begin
                    ExternalMemberCardNo := '';
                    if (UI.MemberSearchWithFacialRecognition(MemberEntryNo)) then begin
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
            FormatedCardNumber := ExternalMemberCardNo;
        end;

        ForeignMembershipEntryNo := ForeignMembershipMgr.DispatchToReplicateForeignMemberCard('', ExternalMemberCardNo, FormatedForeignCardNumber, ForeignCardIsValid, NotFoundReasonText);
        if (ForeignCardIsValid) then begin
            MembershipEntryNo := ForeignMembershipEntryNo;
            FormatedCardNumber := FormatedForeignCardNumber;
        end;

        if (MembershipEntryNo = 0) then begin
            if (FailWithError) then
                if (NotFoundReasonText <> '') then
                    Error(NotFoundReasonText)
                else
                    Error(CARD_BLOCKED_NOT_FOUND, ExternalMemberCardNo);
            exit(false);
        end;

        if (not MemberManagement.IsMemberCardActive(FormatedCardNumber, Today)) then begin
            if (FailWithError) then begin

                if (AllowVerboseMode) then begin
                    if (not (Confirm(MEMBERCARD_EXPIRED, true, ExternalMemberCardNo))) then begin
                        Error(MEMBERCARD_EXPIRED, ExternalMemberCardNo);
                    end;
                end else begin
                    Error(MEMBERCARD_EXPIRED, ExternalMemberCardNo);
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

            if (ActivateMembership) then
                if (not MustActivate) then begin
                    if (FailWithError) then
                        Error(MEMBERSHIP_NOT_VALID, ExternalMemberCardNo);
                    exit(false);
                end;

            if (MustActivate) then
                if (not ActivateMembership) then begin
                    if (FailWithError) then
                        Error(MEMBERSHIP_NOT_VALID, ExternalMemberCardNo);
                    exit(false);
                end;
        end;

        MembershipSetup.Get(Membership."Membership Code");

        if (MembershipSetup."Member Information" = MembershipSetup."Member Information"::NAMED) then begin
            if (not (Member.Get(MemberManagement.GetMemberFromExtCardNo(FormatedCardNumber, Today, NotFoundReasonText)))) then begin
                if (FailWithError) then
                    Error(NotFoundReasonText);
                exit(false);
            end;

            ShowMemberDialog := (AllowVerboseMode and MembershipSetup."Confirm Member On Card Scan") or (ForcedConfirmMember);
            if (ShowMemberDialog) then begin
                Commit(); // When Facial Recongnition is used and a face is written

                POSMemberCard.LookupMode(true);
                POSMemberCard.SetRecord(Member);
                POSMemberCard.SetMembershipEntryNo(Membership."Entry No.");

                if (POSMemberCard.RunModal() <> ACTION::LookupOK) then
                    Error('');

            end;

        end;

        if (MustActivate) and (ActivateMembership) then begin
            MemberManagement.ActivateMembershipLedgerEntry(MembershipEntryNo, Today);
        end;

        exit(true);
    end;

    procedure POS_GetExternalTicketItemFromMembership(ExternalMemberCardNo: Text[100]) TicketItemBarcode: Code[20]
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberManagement: Codeunit "NPR MM Membership Mgt.";
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

    procedure PrintMembershipOnEndOfSales(SalesReceiptNo: Code[20])
    var
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipSetup: Record "NPR MM Membership Setup";
        ShouldPrint: Boolean;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MemberCard: Record "NPR MM Member Card";
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
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MemberCard: Record "NPR MM Member Card";
        MemberCard2: Record "NPR MM Member Card";
    begin

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
        ObjectOutputMgt: Codeunit "NPR Object Output Mgt.";
        LinePrintMgt: Codeunit "NPR RP Line Print Mgt.";
        ReportPrinterInterface: Codeunit "NPR Report Printer Interface";
        PrintTemplateMgt: Codeunit "NPR RP Template Mgt.";
    begin

        case MembershipSetup."Receipt Print Object Type" of
            MembershipSetup."Receipt Print Object Type"::NO_PRINT:
                ;

            MembershipSetup."Receipt Print Object Type"::CODEUNIT:
                if (ObjectOutputMgt.GetCodeunitOutputPath(MembershipSetup."Receipt Print Object ID") <> '') then
                    LinePrintMgt.ProcessCodeunit(MembershipSetup."Receipt Print Object ID", Membership)
                else
                    CODEUNIT.Run(MembershipSetup."Receipt Print Object ID", Membership);

            MembershipSetup."Receipt Print Object Type"::REPORT:
                ReportPrinterInterface.RunReport(MembershipSetup."Receipt Print Object ID", false, false, Membership);

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
        MemberManagement: Codeunit "NPR MM Membership Mgt.";
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
        ObjectOutputMgt: Codeunit "NPR Object Output Mgt.";
        LinePrintMgt: Codeunit "NPR RP Line Print Mgt.";
        ReportPrinterInterface: Codeunit "NPR Report Printer Interface";
        PrintTemplateMgt: Codeunit "NPR RP Template Mgt.";
    begin

        case MembershipSetup."Account Print Object Type" of
            MembershipSetup."Account Print Object Type"::NO_PRINT:
                Error(NO_PRINTOUT, MembershipSetup.Code);

            MembershipSetup."Account Print Object Type"::CODEUNIT:
                if (ObjectOutputMgt.GetCodeunitOutputPath(MembershipSetup."Account Print Object ID") <> '') then
                    LinePrintMgt.ProcessCodeunit(MembershipSetup."Account Print Object ID", Member)
                else
                    CODEUNIT.Run(MembershipSetup."Account Print Object ID", Member);

            MembershipSetup."Account Print Object Type"::REPORT:
                ReportPrinterInterface.RunReport(MembershipSetup."Account Print Object ID", false, false, Member);

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
        MemberManagement: Codeunit "NPR MM Membership Mgt.";
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
        ObjectOutputMgt: Codeunit "NPR Object Output Mgt.";
        LinePrintMgt: Codeunit "NPR RP Line Print Mgt.";
        ReportPrinterInterface: Codeunit "NPR Report Printer Interface";
        PrintTemplateMgt: Codeunit "NPR RP Template Mgt.";
    begin

        case MembershipSetup."Card Print Object Type" of
            MembershipSetup."Card Print Object Type"::NO_PRINT:
                Error(NO_PRINTOUT, MembershipSetup.Code);

            MembershipSetup."Card Print Object Type"::CODEUNIT:
                if (ObjectOutputMgt.GetCodeunitOutputPath(MembershipSetup."Card Print Object ID") <> '') then
                    LinePrintMgt.ProcessCodeunit(MembershipSetup."Card Print Object ID", MemberCard)
                else
                    CODEUNIT.Run(MembershipSetup."Card Print Object ID", MemberCard);

            MembershipSetup."Card Print Object Type"::REPORT:
                ReportPrinterInterface.RunReport(MembershipSetup."Card Print Object ID", false, false, MemberCard);

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

    procedure IssueTicketFromMemberScan(FailWithError: Boolean; ItemNo: Code[20]; VariantCode: Code[10]; Member: Record "NPR MM Member"; var TicketNo: Code[20]; var ResponseMessage: Text) ResponseCode: Integer
    var
        Item: Record Item;
        TicketType: Record "NPR TM Ticket Type";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        Token: Text[100];
        TMDetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin

        Item.Get(ItemNo);
        if (not TicketType.Get(Item."NPR Ticket Type")) then
            exit;
        if (not TicketType."Is Ticket") then
            exit;

        Token := TicketRequestManager.CreateReservationRequest(ItemNo, VariantCode, 1, Member."External Member No.");
        TicketRequestManager.SetReservationRequestExtraInfo(Token, Member."E-Mail Address", Member."External Member No.");

        ResponseCode := TicketRequestManager.IssueTicketFromReservationToken(Token, FailWithError, ResponseMessage);
        if (ResponseCode <> 0) then
            exit(ResponseCode);

        TicketRequestManager.ConfirmReservationRequestWithValidate(Token);

        if (not TicketRequestManager.GetTokenTicket(Token, TicketNo)) then
            Error(TICKET_NOT_FOUND);

        exit(0);
    end;

    procedure NewMemberSalesInfoCapture(SaleLinePOS: Record "NPR Sale Line POS") ReturnCode: Integer
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        Item: Record Item;
        MembershipSetup: Record "NPR MM Membership Setup";
        i: Integer;
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MemberLinesToSuggest: Integer;
        ReasonMessage: Text;
        AttemptCreateMembership: Codeunit "NPR Membership Attempt Create";
    begin

        if (SaleLinePOS.Quantity < 0) then
            exit(0); // Not for us, is cancel/regret

        if (not MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, SaleLinePOS."No.")) then
            exit(0);

        if (not Item.Get(SaleLinePOS."No.")) then
            exit(0);

        if (SaleLinePOS.Quantity <> 1) then
            exit(-1101);

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
        case MembershipSalesSetup."Business Flow Type" of

            MembershipSalesSetup."Business Flow Type"::MEMBERSHIP:
                begin
                    MemberLinesToSuggest := MembershipSetup."Membership Member Cardinality";
                    if ((MembershipSalesSetup."Suggested Membercount In Sales" > 0) and
                        (MembershipSalesSetup."Suggested Membercount In Sales" < MembershipSetup."Membership Member Cardinality")) then
                        MemberLinesToSuggest := MembershipSalesSetup."Suggested Membercount In Sales";

                    if (MemberLinesToSuggest <> MemberInfoCapture.Count()) then begin
                        if (MemberInfoCapture.FindFirst()) then
                            MemberInfoCapture.DeleteAll();

                        for i := 1 to MemberLinesToSuggest do begin
                            MemberInfoCapture.Init();
                            MemberInfoCapture."Entry No." := 0;
                            MemberInfoCapture."Receipt No." := SaleLinePOS."Sales Ticket No.";
                            MemberInfoCapture."Line No." := SaleLinePOS."Line No.";
                            MemberInfoCapture."First Name" := StrSubstNo(MEMBER_NAME, i);
                            MemberInfoCapture.Insert();
                        end;
                    end;

                    MemberInfoCapture.Reset();
                    MemberInfoCapture.SetCurrentKey("Receipt No.", "Line No.");
                    MemberInfoCapture.SetFilter("Receipt No.", '=%1', SaleLinePOS."Sales Ticket No.");
                    MemberInfoCapture.SetFilter("Line No.", '=%1', SaleLinePOS."Line No.");
                    MemberInfoCapture.FindSet();
                    repeat
                        MemberInfoCapture."Item No." := SaleLinePOS."No.";
                        MemberInfoCapture."Membership Code" := MembershipSalesSetup."Membership Code";
                        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::NEW;
                        MemberInfoCapture.Modify();
                    until (MemberInfoCapture.Next() = 0);
                end;

            MembershipSalesSetup."Business Flow Type"::ADD_NAMED_MEMBER,
            MembershipSalesSetup."Business Flow Type"::ADD_ANONYMOUS_MEMBER,
            MembershipSalesSetup."Business Flow Type"::ADD_CARD,
            MembershipSalesSetup."Business Flow Type"::REPLACE_CARD:
                begin
                    if (MemberInfoCapture.IsEmpty()) then begin
                        MemberInfoCapture.Init();
                        MemberInfoCapture."Entry No." := 0;
                        MemberInfoCapture."Receipt No." := SaleLinePOS."Sales Ticket No.";
                        MemberInfoCapture."Line No." := SaleLinePOS."Line No.";
                        MemberInfoCapture."Item No." := SaleLinePOS."No.";
                        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::NEW;
                        MemberInfoCapture.Insert();
                    end;
                end;

            else
                Error('Business Flow Type %1 not handled when preparing user input.', MembershipSalesSetup."Business Flow Type");
        end;

        Commit();

        // When a sales line is created as part of web service (f.ex coupon complimentary item)
        if (not GuiAllowed()) then
            exit(-1100);

        if (DisplayMemberInfoCaptureDialog(SaleLinePOS)) then begin
            Commit();

            MemberInfoCapture.LockTable();

            MemberInfoCapture.Reset();
            MemberInfoCapture.SetCurrentKey("Receipt No.", "Line No.");
            MemberInfoCapture.SetFilter("Receipt No.", '=%1', SaleLinePOS."Sales Ticket No.");
            MemberInfoCapture.SetFilter("Line No.", '=%1', SaleLinePOS."Line No.");

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
        if (SaleLinePOS.Delete()) then;
        Commit();

        if (ReasonMessage <> '') then begin
            gLastMessage := ReasonMessage;
            exit(-1100);
        end;

        exit(-1102);
    end;

    procedure DisplayMemberInfoCaptureDialog(SaleLinePOS: Record "NPR Sale Line POS") LookupOK: Boolean
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberInfoCapturePage: Page "NPR MM Member Info Capture";
        PageAction: Action;
    begin

        MemberInfoCapture.Reset();
        MemberInfoCapture.FilterGroup(2);
        MemberInfoCapture.Reset();

        MemberInfoCapture.SetCurrentKey("Receipt No.", "Line No.");
        MemberInfoCapture.SetFilter("Receipt No.", '=%1', SaleLinePOS."Sales Ticket No.");
        MemberInfoCapture.SetFilter("Line No.", '=%1', SaleLinePOS."Line No.");
        MemberInfoCapture.FilterGroup(0);

        MemberInfoCapturePage.SetTableView(MemberInfoCapture);
        MemberInfoCapture.FindSet();

        MemberInfoCapturePage.LookupMode(true);
        MemberInfoCapturePage.Editable(true);

        PageAction := MemberInfoCapturePage.RunModal();

        exit(PageAction = ACTION::LookupOK);
    end;

    [EventSubscriber(ObjectType::"Codeunit", Codeunit::"NPR POS Create Entry", 'OnAfterInsertPOSSalesLine', '', true, true)]
    local procedure IssueMembersFromPosEntrySaleLine(POSEntry: Record "NPR POS Entry"; var POSSalesLine: Record "NPR POS Sales Line")
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

    local procedure IssueMembershipFromEndOfSaleWorker(ReceiptNo: Code[20]; ReceiptLine: Integer; SalesDate: Date; UnitPrice: Decimal; Amount_LCY: Decimal; AmountInclVat_LCY: Decimal; Description: Text; Quantity: Decimal)
    var
        Membership: Record "NPR MM Membership";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MemberManagement: Codeunit "NPR MM Membership Mgt.";
        MemberNotification: Codeunit "NPR MM Member Notification";
        CreateMembership: Codeunit "NPR Membership Attempt Create";
        MembershipStartDate: Date;
        MembershipUntilDate: Date;
        ResponseMessage: Text;
        ReasonCode: Integer;
        LogEntryNo: Integer;
    begin

        MemberInfoCapture.SetCurrentKey("Receipt No.", "Line No.");
        MemberInfoCapture.SetFilter("Receipt No.", '=%1', ReceiptNo);
        MemberInfoCapture.SetFilter("Line No.", '=%1', ReceiptLine);
        if (not MemberInfoCapture.FindSet()) then
            exit;

        MemberInfoCapture.LockTable(true);
        MemberInfoCapture.FindSet();

        repeat
            MemberInfoCapture."Unit Price" := UnitPrice;
            MemberInfoCapture.Amount := Amount_LCY;
            MemberInfoCapture."Amount Incl VAT" := AmountInclVat_LCY;
            MemberInfoCapture.Description := CopyStr(Description, 1, MaxStrLen(MemberInfoCapture.Description));
            MemberInfoCapture.Quantity := Quantity;
            MemberInfoCapture."Document Date" := SalesDate;
            MemberInfoCapture.Modify();
        until (MemberInfoCapture.Next() = 0);

        Commit();
        CreateMembership.SetCreateMembership();
        if (not CreateMembership.run(MemberInfoCapture)) then begin
            Message('There was a issue when handling the membership on sales line %1 during end-of-sales: %2', ReceiptLine, GetLastErrorText());
            exit;
        end;

        if (not AdmitMembersOnEndOfSalesWorker(MemberInfoCapture, ResponseMessage)) then begin
            Message(ResponseMessage);
            exit;
        end;

        MemberInfoCapture.DeleteAll();
        Commit();
    end;


    local procedure AdmitMembersOnEndOfSalesWorker(var MemberInfoCapture: Record "NPR MM Member Info Capture"; var ReasonText: Text): Boolean;
    var
        Member: Record "NPR MM Member";
        MemberCard: Record "NPR MM Member Card";
        MembershipSetup: Record "NPR MM Membership Setup";
        AttemptArrival: Codeunit "NPR MM Attempt Member Arrival";
        MemberLimitationMgr: Codeunit "NPR MM Member Lim. Mgr.";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketVariantCode: Code[10];
        TicketItemNo: Code[20];
        LogEntryNo: Integer;
        ReasonCode: Integer;
        ResolvingTable: Integer;
        Token: Text[100];
    begin

        MemberInfoCapture.FindSet();

        if (not MemberInfoCapture."Auto-Admit Member") then
            exit(true); // Must be consistent for all members on the same sales line

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
        AttemptArrival.AttemptMemberArrival(MemberInfoCapture, '', '<auto>');
        if (not AttemptArrival.Run()) then begin
            ReasonCode := AttemptArrival.GetAttemptMemberArrivalResponse(ReasonText);
            MemberLimitationMgr.UpdateLogEntry(LogEntryNo, ReasonCode, ReasonText); // TODO: Add LogEntryNo to InfoCapture and update all entries ... 
            exit(false);
        end;

        exit(true);

    end;

    procedure DeletePreemptiveMembership(ReceiptNo: Code[20]; LineNo: Integer)
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MemberManagement: Codeunit "NPR MM Membership Mgt.";
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

    local procedure "--Helpers for remote memberships"()
    begin
    end;


    [EventSubscriber(ObjectType::Table, 6150730, 'OnBeforeInsertEvent', '', true, true)]
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

    [EventSubscriber(ObjectType::Codeunit, 6150705, 'OnFinishSale', '', true, true)]
    local procedure PrintMembershipsOnSale(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SalePOS: Record "NPR Sale POS")
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
        ItemCrossReference: Record "Item Cross Reference";
        AlternativeNo: Record "NPR Alternative No.";
        ItemVariant: Record "Item Variant";
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
                    ResolvingTable := DATABASE::"NPR Alternative No.";
                    ItemNo := Code;
                    VariantCode := "Variant Code";
                    exit(true);
                end;
            end;
        end;

        exit(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014407, 'OnAfterDebitSalePostEvent', '', true, true)]
    local procedure OnAfterDebitSalePostSubscriber(var Sender: Codeunit "NPR Sales Doc. Exp. Mgt."; SalePOS: Record "NPR Sale POS"; SalesHeader: Record "Sales Header"; Posted: Boolean; WriteInAuditRoll: Boolean)
    begin

        if (SalePOS."Sales Ticket No." = '') then
            exit;

        PrintMembershipOnEndOfSalesWorker(SalePOS."Sales Ticket No.", false);
    end;

}

