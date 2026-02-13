codeunit 6151366 "NPR POS Action Member MgtWF3-B"
{
    Access = Internal;
    internal procedure ChooseMemberCardViaMemberSearchUI(var ExtMemberCardNo: Text[100]): Boolean
    var
        Member: Record "NPR MM Member";
        MemberCard: Record "NPR MM Member Card";
        MemberCardList: Page "NPR MM Member Card List";
        MemberCardListPhone: Page "NPR MM Member Card List MPos";
        MemberCardCount: Integer;
    begin
        Member.SetFilter(Blocked, '=%1', false);
        if (not ChooseMemberWithSearchUIWorkList(Member)) then
            exit;

        MemberCard.SetCurrentKey("Member Entry No.");
        MemberCard.SetFilter("Member Entry No.", '=%1', Member."Entry No.");
        MemberCard.SetFilter(Blocked, '=%1', false);
        MemberCard.SetFilter("Valid Until", '=%1|>=%2', 0D, Today());
        MemberCardCount := MemberCard.Count();

        case true of
            MemberCardCount > 1:
                begin
                    if (Session.CurrentClientType = Session.CurrentClientType::Phone) then begin
                        MemberCardListPhone.SetTableView(MemberCard);
                        MemberCardListPhone.Editable(false);
                        MemberCardListPhone.LookupMode(true);
                        if (Action::LookupOK <> MemberCardListPhone.RunModal()) then
                            exit(false);

                        MemberCardListPhone.GetRecord(MemberCard);
                    end else begin
                        MemberCardList.SetTableView(MemberCard);
                        MemberCardList.Editable(false);
                        MemberCardList.LookupMode(true);
                        if (Action::LookupOK <> MemberCardList.RunModal()) then
                            exit(false);

                        MemberCardList.GetRecord(MemberCard);
                    end;
                end;
            MemberCardCount = 1:
                begin
                    MemberCard.FindFirst();
                end;
            else begin
                MemberCard.Reset();
                MemberCard.SetFilter("Member Entry No.", '=%1', Member."Entry No.");
                MemberCard.SetFilter(Blocked, '=%1', false);
                MemberCardCount := MemberCard.Count();
                case true of
                    MemberCardCount > 1:
                        begin
                            if (Session.CurrentClientType = Session.CurrentClientType::Phone) then begin
                                MemberCardListPhone.SetTableView(MemberCard);
                                MemberCardListPhone.Editable(false);
                                MemberCardListPhone.LookupMode(true);
                                if (Action::LookupOK <> MemberCardListPhone.RunModal()) then
                                    exit;
                                MemberCardListPhone.GetRecord(MemberCard);
                            end else begin
                                MemberCardList.SetTableView(MemberCard);
                                MemberCardList.Editable(false);
                                MemberCardList.LookupMode(true);
                                if (Action::LookupOK <> MemberCardList.RunModal()) then
                                    exit;
                                MemberCardList.GetRecord(MemberCard);
                            end;
                        end;
                    else begin
                        if (not MemberCard.FindFirst()) then
                            exit;
                    end;
                end;
            end;
        end;

        ExtMemberCardNo := MemberCard."External Card No.";
        exit(true);

    end;

    local procedure ChooseMemberWithSearchUIWorkList(var Member: Record "NPR MM Member"): Boolean
    var
        MemberList: Page "NPR MM Members";
        MemberListPhone: Page "NPR MM Members MPos";
        PageAction: Action;
    begin
        if (Session.CurrentClientType() = ClientType::Phone) then begin
            MemberListPhone.LookupMode(true);
            MemberListPhone.SetTableView(Member);
            PageAction := MemberListPhone.RunModal();
            if (PageAction = Action::LookupOK) then
                MemberListPhone.GetRecord(Member);

        end else begin
            MemberList.LookupMode(true);
            MemberList.SetTableView(Member);
            PageAction := MemberList.RunModal();
            if (PageAction = Action::LookupOK) then
                MemberList.GetRecord(Member);
        end;

        exit(Member."External Member No." <> '');
    end;

    procedure ChooseMemberCard(var ExtMemberCardNo: Text[100]; ForeignCommunityCode: Code[20]): Boolean
    var
        NPRMembershipMgt: Codeunit "NPR MM NPR Membership";
    begin
        if (ForeignCommunityCode <> '') then
            exit(NPRMembershipMgt.SearchForeignMembers(ForeignCommunityCode, ExtMemberCardNo));

        exit(ChooseMemberCardViaMemberSearchUI(ExtMemberCardNo));
    end;

    internal procedure GetMembershipFromCardNumberWithUI(InputMethod: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT; var ExternalMemberCardNo: Text[100]; var Membership: Record "NPR MM Membership"; var MemberCard: Record "NPR MM Member Card"; WithActivate: Boolean)
    begin
        GetMembershipFromCardNumberWithUI(InputMethod, ExternalMemberCardNo, Membership, MemberCard, WithActivate, '');
    end;

    internal procedure GetMembershipFromCardNumberWithUI(InputMethod: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT; var ExternalMemberCardNo: Text[100]; var Membership: Record "NPR MM Membership"; var MemberCard: Record "NPR MM Member Card"; WithActivate: Boolean; ForeignCommunityCode: Code[20])
    var
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        MEMBERSHIP_BLOCKED_NOT_FOUND: Label 'Membership %1 is either blocked or not found.', Comment = '%1= CardNo.';
        FailReasonText: Text;
    begin
        if (InputMethod = InputMethod::CARD_SCAN) then
            InputMethod := InputMethod::NO_PROMPT;

        if ((ExternalMemberCardNo = '') and (InputMethod = InputMethod::NO_PROMPT)) then begin
            if (not ChooseMemberCard(ExternalMemberCardNo, ForeignCommunityCode)) then
                Error('');
        end;
        MemberRetailIntegration.POS_ValidateMemberCardNo(true, true, InputMethod, WithActivate, ExternalMemberCardNo);

        if (Membership.Get(MembershipManagement.GetMembershipFromExtCardNo(ExternalMemberCardNo, Today, FailReasonText))) then begin
            MemberCard.Get(MembershipManagement.GetCardEntryNoFromExtCardNo(ExternalMemberCardNo));
            exit;
        end;

        if (FailReasonText <> '') then
            Error(FailReasonText) else
            Error(MEMBERSHIP_BLOCKED_NOT_FOUND, ExternalMemberCardNo);
    end;

    procedure AssignMembershipToPOSWorker(var SalePOS: Record "NPR POS Sale"; MembershipEntryNo: Integer; ExternalMemberCardNo: Text[100]): Boolean
    var
        Membership: Record "NPR MM Membership";
        POSSalesInfo: Record "NPR MM POS Sales Info";
        MembershipSetup: Record "NPR MM Membership Setup";
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
    begin

        if (not Membership.Get(MembershipEntryNo)) then
            exit(false);
        Sentry.StartSpan(Span, 'bc.pos.membermgtwf3.assignmembershiptopos');
        if (Membership."Customer No." <> '') then begin
            SalePOS."Customer No." := '';
            SalePOS.Validate("Customer No.", Membership."Customer No.");
        end else begin
            SalePOS."Customer No." := '';

            MembershipSetup.Get(Membership."Membership Code");
            if (MembershipSetup."Membership Customer No." <> '') then
                SalePOS."Customer No." := '';

            SalePOS.Validate("Customer No.", Membership."Customer No.");
        end;

        if (not POSSalesInfo.Get(POSSalesInfo."Association Type"::HEADER, SalePOS."Sales Ticket No.", 0)) then begin
            POSSalesInfo."Association Type" := POSSalesInfo."Association Type"::HEADER;
            POSSalesInfo."Receipt No." := SalePOS."Sales Ticket No.";
            POSSalesInfo."Line No." := 0;
            POSSalesInfo.Insert();
        end;

        POSSalesInfo.Init();
        POSSalesInfo."Membership Entry No." := MembershipEntryNo;
        POSSalesInfo."Scanned Card Data" := ExternalMemberCardNo;
        POSSalesInfo.Modify();
        Span.Finish();
        exit(true);

    end;

    procedure POSMemberArrival(FrontEndInputMethod: Option; ExternalMemberCardNo: Text[100]; ForeignCommunityCode: Code[20]) MemberCardEntryNo: Integer
    var
        Member: Record "NPR MM Member";
        MemberCard: Record "NPR MM Member Card";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSession: Codeunit "NPR POS Session";
        MemberLimitationMgr: Codeunit "NPR MM Member Lim. Mgr.";
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        MembershipEvents: Codeunit "NPR MM Membership Events";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        ExternalItemNo: Code[50];
        LogEntryNo: Integer;
        ResponseCode: Integer;
        ItemDescription: Text;
        ResponseMessage: Text;
        PlaceHolderLbl: Label '%1/%2', Locked = true;
    begin
        GetMembershipFromCardNumberWithUI(FrontEndInputMethod, ExternalMemberCardNo, Membership, MemberCard, true, ForeignCommunityCode);
        MemberCardEntryNo := MemberCard."Entry No.";

        MemberLimitationMgr.POS_CheckLimitMemberCardArrival(ExternalMemberCardNo, '', 'POS', LogEntryNo, ResponseMessage, ResponseCode);
        Commit(); // so log entry stays
        if (ResponseCode <> 0) then
            Error(ResponseMessage);

        MembershipSetup.Get(Membership."Membership Code");

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(SaleLinePOS);

        Commit();
        MembershipEvents.OnBeforePOSMemberArrival(SaleLinePOS, MembershipSetup."Community Code", MembershipSetup.Code, Membership."Entry No.", Member."Entry No.", MemberCard."Entry No.", ExternalMemberCardNo);

        ItemDescription := '';
        MembershipEvents.OnCustomItemDescription(MembershipSetup."Community Code", MembershipSetup.Code, MemberCard."Entry No.", ItemDescription);

        ExternalItemNo := MemberRetailIntegration.POS_GetExternalTicketItemFromMembership(ExternalMemberCardNo);
        AddItemToPOS(POSSaleLine, 0, ExternalItemNo, CopyStr(ItemDescription, 1, MaxStrLen(SaleLinePOS.Description)), StrSubstNo(PlaceHolderLbl, Membership."External Membership No.", ExternalMemberCardNo), 1, 0, SaleLinePOS);

        case MembershipSetup."Member Information" of
            MembershipSetup."Member Information"::ANONYMOUS:
                begin
                    Clear(Member);
                    UpdatePOSSalesInfo(SaleLinePOS, Membership."Entry No.", 0, MemberCard."Entry No.", ExternalMemberCardNo);
                    MembershipEvents.OnAssociateSaleWithMember(POSSession, Membership."External Membership No.", CopyStr(ExternalMemberCardNo, 1, MaxStrLen(Member."External Member No.")));
                end;

            MembershipSetup."Member Information"::NAMED:
                begin
                    Member.Get(MembershipManagement.GetMemberFromExtCardNo(ExternalMemberCardNo, Today, ResponseMessage));
                    UpdatePOSSalesInfo(SaleLinePOS, Membership."Entry No.", Member."Entry No.", MemberCard."Entry No.", ExternalMemberCardNo);
                    MembershipEvents.OnAssociateSaleWithMember(POSSession, Membership."External Membership No.", Member."External Member No.");
                end;
        end;
    end;

    local procedure AddItemToPOS(POSSaleLine: Codeunit "NPR POS Sale Line"; MemberInfoEntryNo: Integer; ExternalItemNo: Code[50]; Description: Text[100]; Description2: Text[80]; Quantity: Decimal; UnitPrice: Decimal; var SaleLinePOS: Record "NPR POS Sale Line")
    var
        Line: Record "NPR POS Sale Line";

        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        ItemNo: Code[20];
        VariantCode: Code[10];
        Resolver: Integer;
        NotFoundErr: Label 'Item number %1 not found.';
    begin
        POSSaleLine.GetNewSaleLine(Line);
        DeleteMemberInfoCapture(Line); // If I somehow reused an existing entry, delete it. (New entry does not have receipt number set yet)

        if (not MemberRetailIntegration.TranslateBarcodeToItemVariant(ExternalItemNo, ItemNo, VariantCode, Resolver)) then
            Error(NotFoundErr, ExternalItemNo);

        Line."Line Type" := Line."Line Type"::Item;
        Line."No." := ItemNo;
        Line."Variant Code" := VariantCode;
        Line.Description := Description;
        Line.Quantity := Abs(Quantity);
        if (UnitPrice < 0) then
            Line.Quantity := -1 * Abs(Quantity);

        Line."Unit Price" := Abs(UnitPrice);

        if (MemberInfoEntryNo <> 0) then
            SetReceiptReference(MemberInfoEntryNo, Line."Sales Ticket No.", Line."Line No.");

        POSSaleLine.InsertLine(Line);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        SaleLinePOS."Description 2" := CopyStr(Description2, 1, MaxStrLen(SaleLinePOS."Description 2"));
        SaleLinePOS.Modify();
    end;

    local procedure DeleteMemberInfoCapture(SaleLinePOS: Record "NPR POS Sale Line")
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin

        MemberInfoCapture.SetFilter("Receipt No.", '=%1', SaleLinePOS."Sales Ticket No.");
        MemberInfoCapture.SetFilter("Line No.", '=%1', SaleLinePOS."Line No.");
        if (MemberInfoCapture.IsEmpty()) then
            exit;

        MemberInfoCapture.DeleteAll();
    end;

    local procedure SetReceiptReference(EntryNo: Integer; ReceiptNo: Code[20]; LineNo: Integer)
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin
        if (MemberInfoCapture.Get(EntryNo)) then begin
            MemberInfoCapture."Receipt No." := ReceiptNo;
            MemberInfoCapture."Line No." := LineNo;
            MemberInfoCapture.Modify();
        end;
    end;

    local procedure UpdatePOSSalesInfo(var SaleLinePOS: Record "NPR POS Sale Line"; MembershipEntryNo: Integer; MemberEntryNo: Integer; MemberCardEntryNo: Integer; ScannedCardData: Text[200])
    var
        POSSalesInfo: Record "NPR MM POS Sales Info";
    begin
        if (not POSSalesInfo.Get(POSSalesInfo."Association Type"::LINE, SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.")) then begin
            POSSalesInfo."Association Type" := POSSalesInfo."Association Type"::LINE;
            POSSalesInfo."Receipt No." := SaleLinePOS."Sales Ticket No.";
            POSSalesInfo."Line No." := SaleLinePOS."Line No.";
            POSSalesInfo.Insert();
        end;

        POSSalesInfo.Init();
        POSSalesInfo."Membership Entry No." := MembershipEntryNo;
        POSSalesInfo."Member Entry No." := MemberEntryNo;
        POSSalesInfo."Member Card Entry No." := MemberCardEntryNo;
        POSSalesInfo."Scanned Card Data" := ScannedCardData;
        POSSalesInfo.Modify();
    end;

    procedure SelectMembership(FrontEndInputMethod: Option; ExternalMemberCardNo: Text[100]; ForeignCommunityCode: Code[20]; SelectReq: Boolean) MemberCardEntryNo: Integer
    var
        MemberCardOut: Record "NPR MM Member Card";
        MembershipOut: Record "NPR MM Membership";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        MembershipSelected: Boolean;
        Member: Record "NPR MM Member";
        ExtMemberNo: Code[20];
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        Sentry: Codeunit "NPR Sentry";
        SelectMembershipSpan, GetMembershipSpan : Codeunit "NPR Sentry Span";
        POSMemberCardEdit: Page "NPR MM Member Card";
        SelectingMemberError: Label 'There was an error selecting member %1:\\%2';
    begin
        Sentry.StartSpan(SelectMembershipSpan, 'bc.pos.membermgtwf3.selectmembership');
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find();
        POSSale.Refresh(SalePOS);

        if SelectReq then begin

            ClearLastError();
            repeat
                MembershipSelected := false;

                if ChooseMemberWithSearchUIWorkList(Member) then
                    ExtMemberNo := Member."External Member No.";

                if (Member.Get(MembershipManagement.GetMemberFromExtMemberNo(ExtMemberNo))) then begin

                    Clear(POSMemberCardEdit);

                    POSMemberCardEdit.SetRecord(Member);
                    POSMemberCardEdit.LookupMode(true);
                    ClearLastError();
                    if (POSMemberCardEdit.RunModal() = Action::LookupOK) then
                        MembershipSelected := AssignPOSMember(SalePOS, ExtMemberNo, MemberCardOut);
                end;

                if (not MembershipSelected) then begin
                    Message(SelectingMemberError, ExtMemberNo, GetLastErrorText());
                    ExtMemberNo := '';
                end;

            until (MembershipSelected);

        end else begin
            Sentry.StartSpan(GetMembershipSpan, 'bc.pos.membermgtwf3.getmembershipfromcard');
            GetMembershipFromCardNumberWithUI(FrontEndInputMethod, ExternalMemberCardNo, MembershipOut, MemberCardOut, true, ForeignCommunityCode);
            GetMembershipSpan.Finish();
            if (AssignMembershipToPOSWorker(SalePOS, MembershipOut."Entry No.", ExternalMemberCardNo)) then begin
                POSSale.Refresh(SalePOS);
                POSSale.Modify(false, false);
            end;
            SelectMembershipSpan.Finish();
            exit(MemberCardOut."Entry No.");
        end;
        SelectMembershipSpan.Finish();
    end;

    local procedure AssignPOSMember(var SalePOS: Record "NPR POS Sale"; var ExternalMemberNo: Code[20]; var MemberCard: Record "NPR MM Member Card"): Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        MemberEntryNo: Integer;
        ExternalMemberCardNo: Text[100];
    begin

        if (ExternalMemberNo = '') then
            if (not ChooseMember(ExternalMemberNo)) then
                exit(false);

        MemberEntryNo := MembershipManagement.GetMemberFromExtMemberNo(ExternalMemberNo);

        if (Membership.Get(MembershipManagement.GetMembershipFromExtMemberNo(ExternalMemberNo))) then
            if (MemberCard.Get(MembershipManagement.GetMemberCardEntryNo(MemberEntryNo, Membership."Membership Code", Today))) then
                ExternalMemberCardNo := MemberCard."External Card No.";

        exit(AssignMembershipToPOSWorker(SalePOS, Membership."Entry No.", ExternalMemberCardNo));

    end;

    local procedure ChooseMember(var ExtMemberNo: Code[20]): Boolean
    var
        Member: Record "NPR MM Member";
    begin
        ExtMemberNo := '';

        if (ChooseMemberWithSearchUIWorkList(Member)) then
            ExtMemberNo := Member."External Member No.";

        exit(ExtMemberNo <> '');
    end;



    internal procedure ExecuteMembershipAlteration(POSSaleLine: Codeunit "NPR POS Sale Line"; AlterationType: Option; ExternalMemberCardNo: Text[100]; ItemNo: Code[20]; AutoAdmitMember: Option DECIDED_BY_BACKEND,NO,YES,PROMPT)
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        Membership: Record "NPR MM Membership";
        MemberCard: Record "NPR MM Member Card";
        SaleLinePOS: Record "NPR POS Sale Line";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        MemberInfoEntryNo: Integer;
        ADMIT_MEMBERS: Label 'Do you want to admit the member(s) automatically?';
        InputMethod: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT;
    begin

        if (ExternalMemberCardNo = '') then
            GetMembershipFromCardNumberWithUI(InputMethod::NO_PROMPT, ExternalMemberCardNo, Membership, MemberCard, false);

        case AlterationType of
            MembershipAlterationSetup."Alteration Type"::REGRET:
                MemberInfoEntryNo := MembershipManagement.CreateRegretMemberInfoRequest(ExternalMemberCardNo, ItemNo);
            MembershipAlterationSetup."Alteration Type"::RENEW:
                MemberInfoEntryNo := MembershipManagement.CreateRenewMemberInfoRequest(ExternalMemberCardNo, ItemNo);
            MembershipAlterationSetup."Alteration Type"::EXTEND:
                MemberInfoEntryNo := MembershipManagement.CreateExtendMemberInfoRequest(ExternalMemberCardNo, ItemNo);
            MembershipAlterationSetup."Alteration Type"::UPGRADE:
                MemberInfoEntryNo := MembershipManagement.CreateUpgradeMemberInfoRequest(ExternalMemberCardNo, ItemNo);
            MembershipAlterationSetup."Alteration Type"::CANCEL:
                MemberInfoEntryNo := MembershipManagement.CreateCancelMemberInfoRequest(ExternalMemberCardNo, ItemNo);
        end;

        MemberInfoCapture.Get(MemberInfoEntryNo);

        MembershipAlterationSetup.Get(AlterationType, MemberInfoCapture."Membership Code", MemberInfoCapture."Item No.");
        if AutoAdmitMember = AutoAdmitMember::DECIDED_BY_BACKEND then begin
            if (MembershipAlterationSetup."Auto-Admit Member On Sale" = MembershipAlterationSetup."Auto-Admit Member On Sale"::ASK) then
                MemberInfoCapture."Auto-Admit Member" := Confirm(ADMIT_MEMBERS, true);

            if (MembershipAlterationSetup."Auto-Admit Member On Sale" = MembershipAlterationSetup."Auto-Admit Member On Sale"::YES) then
                MemberInfoCapture."Auto-Admit Member" := true;
        end else begin
            if AutoAdmitMember = AutoAdmitMember::PROMPT then
                MemberInfoCapture."Auto-Admit Member" := Confirm(ADMIT_MEMBERS, true);
            if AutoAdmitMember = AutoAdmitMember::YES then
                MemberInfoCapture."Auto-Admit Member" := true;
        end;

        MemberInfoCapture.Modify();

        AddItemToPOS(POSSaleLine, MemberInfoEntryNo, ItemNo, MembershipAlterationSetup.Description, CopyStr(ExternalMemberCardNo, 1, 80), 1, MemberInfoCapture."Unit Price", SaleLinePOS);

    end;

    internal procedure EditMembership()
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSession: Codeunit "NPR POS Session";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        NOT_MEMBERSHIP_SALES: Label 'The selected sales line is not a membership sales.';
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        if (SaleLinePOS."Sales Ticket No." = '') then
            exit;

        MemberInfoCapture.SetCurrentKey("Receipt No.", "Line No.");
        MemberInfoCapture.SetFilter("Receipt No.", '=%1', SaleLinePOS."Sales Ticket No.");
        MemberInfoCapture.SetFilter("Line No.", '=%1', SaleLinePOS."Line No.");
        if (MemberInfoCapture.IsEmpty()) then
            Error(NOT_MEMBERSHIP_SALES);

        if (MemberRetailIntegration.DisplayMemberInfoCaptureDialog(SaleLinePOS)) then begin
            if (MemberInfoCapture.FindSet()) then begin
                repeat
                    MembershipManagement.UpdateMember(MemberInfoCapture."Membership Entry No.", MemberInfoCapture."Member Entry No", MemberInfoCapture);
                until (MemberInfoCapture.Next() = 0);
            end;
        end;

    end;

    internal procedure ShowMember(FrontEndInputMethod: Option; ExternalMemberCardNo: Text[100]; ForeignCommunityCode: Code[20])
    var
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
    begin
        if ((FrontEndInputMethod = MemberSelectionMethod::NO_PROMPT) and (ExternalMemberCardNo = '')) then
            if (not ChooseMemberCard(ExternalMemberCardNo, ForeignCommunityCode)) then
                Error('');

        if ((FrontEndInputMethod = MemberSelectionMethod::CARD_SCAN)) then begin
            if (ExternalMemberCardNo = '') then
                if (not ChooseMemberCard(ExternalMemberCardNo, ForeignCommunityCode)) then
                    Error('');
            FrontEndInputMethod := MemberSelectionMethod::NO_PROMPT;
        end;

        MemberRetailIntegration.POS_ShowMemberCard(FrontEndInputMethod, ExternalMemberCardNo);

    end;

    internal procedure EditActiveMembership()
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        Membership: Record "NPR MM Membership";
        POSSession: Codeunit "NPR POS Session";
    begin
        POSSession.GetSale(POSSale);
        POSSale.RefreshCurrent();
        POSSale.GetCurrentSale(SalePOS);

        if (SalePOS."Customer No." = '') then
            exit;

        Membership.SetFilter("Customer No.", '=%1', SalePOS."Customer No.");
        if (not Membership.FindFirst()) then
            exit;

        PAGE.RunModal(PAGE::"NPR MM Membership Card", Membership);

    end;

    internal procedure CancelAutoRenew(ExternalMemberCardNo: Text[100])
    var
        Membership: Record "NPR MM Membership";
        MemberCard: Record "NPR MM Member Card";
        InputMethod: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT;
        MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";

    begin
        if (ExternalMemberCardNo = '') then
            GetMembershipFromCardNumberWithUI(InputMethod::NO_PROMPT, ExternalMemberCardNo, Membership, MemberCard, false);

        MembershipMgtInternal.CancelAutoRenew(ExternalMemberCardNo);
    end;

    internal procedure TerminateSubscription(ExternalMemberCardNo: Text[100]; FrontEndInputMethod: Option) Result: JsonObject
    var
        MemberCard: Record "NPR MM Member Card";
        Membership: Record "NPR MM Membership";
        Subscription: Record "NPR MM Subscription";
        RequestTermination: Page "NPR MM SubsRequestTermination";
    begin
        GetMembershipFromCardNumberWithUI(FrontEndInputMethod, ExternalMemberCardNo, Membership, MemberCard, false);
        Subscription.SetRange("Membership Entry No.", Membership."Entry No.");
        Subscription.FindFirst();
        RequestTermination.SetMembership(Membership, Subscription);
        if RequestTermination.RunModal() <> Action::Yes then
            Result.Add('success', false)
    end;

    var
        MemberSelectionMethod: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT;
}

