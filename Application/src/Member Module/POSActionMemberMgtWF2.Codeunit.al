codeunit 6014479 "NPR POS Action Member Mgt WF2"
{
    var
        MemberSelectionMethod: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT;

    local procedure ActionCode(): Code[20]
    begin
        exit('MM_MEMBERMGMT_WF2');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('2.0');
    end;

    [EventSubscriber(ObjectType::Table, CodeUnit::"NPR POS JSON Management", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverActions(var Sender: Record "NPR POS Action")
    var
        FunctionOptionString: Text;
        ACTION_DESCRIPTION: Label 'This action handles member management functions for workflow 2.0.';
    begin

        FunctionOptionString := 'Member Arrival,' +
                                'Select Membership,' +
                                'View Membership Entry,Regret Membership Entry,' +
                                'Renew Membership,Extend Membership,Upgrade Membership,' +
                                'Cancel Membership,Edit Membership,Show Member,Edit Current Membership';

        if (Sender.DiscoverAction20(ActionCode(), ACTION_DESCRIPTION, ActionVersion())) then begin
            Sender.RegisterWorkflow20(

                'if ($parameters.Function < 0) {$parameters.Function = $parameters.Function["Member Arrival"];};' +
                'let windowTitle = $labels.DialogTitle.substitute ($parameters.Function);' +

                // Prompt for member card number    
                'if ($parameters.DefaultInputValue.length == 0 && $parameters.DialogPrompt <= $parameters.DialogPrompt ["Member Card Number"]) {' +
                    '$context.memberCardInput = await popup.input ({caption: $labels.MemberCardPrompt, title: windowTitle});' +
                    'if ($context.memberCardInput === null) {return;}' +
                '}' +
                // When data is pass from EAN box f.ex.
                'if ($parameters.DefaultInputValue.length > 0) {' +
                    '$context.memberCardInput = $parameters.DefaultInputValue;' +
                '}' +

                // If function is one of the membership alteration actions, fetch the options and prompt teller to choose 
                'if ($parameters.Function >= $parameters.Function["Renew Membership"] && $parameters.Function <= $parameters.Function["Upgrade Membership"] ) {' +
                    'let lookupProperties = JSON.parse (await workflow.respond ("GetMembershipAlterationLookup"));' +
                    '$context.memberCardInput = lookupProperties.cardnumber;' +
                    'let lookupDataArray = JSON.parse(lookupProperties.data);' +
                    'if (lookupDataArray.length == 0) {' +
                        'await popup.error ({title: windowTitle, caption: lookupProperties.notFoundMessage});' +
                        'return;' +
                    '}' +

                    'let driver = data.createArrayDriver(lookupDataArray);' +
                    'let source = data.createDataSource(driver);' +
                    'source.loadAll = false;' +
                    'let result = await popup.lookup({' +
                    '   title: lookupProperties.title,' +
                    '   configuration: {className: "custom-lookup", styleSheet: "", layout: JSON.parse(lookupProperties.layout), result: rows => rows ? rows.map (row => row ? row.itemno : null) : null}, source: source});' +

                    'if (result === null) {return;}' +
                    '$context.itemNumber = result[0].itemno;' +
                '}' +

                // Process the main request
                'let membershipResponse = await workflow.respond ("DoManageMembership");' +
                'if ($parameters.Function == $parameters.Function["View Membership Entry"]) {' +
                    'let membershipEntries = JSON.parse (membershipResponse);' +
                    'let driver = data.createArrayDriver(JSON.parse(membershipEntries.data));' +
                    'let source = data.createDataSource(driver);' +
                    'let result = await popup.lookup({' +
                    '   title: membershipEntries.title,' +
                    '   configuration: {className: "custom-lookup", styleSheet: "", layout: JSON.parse(membershipEntries.layout)}, source: source});' +
                '}'
            );

            Sender.RegisterOptionParameter('Function', FunctionOptionString, 'Member Arrival');
            Sender.RegisterOptionParameter('DialogPrompt', 'Member Card Number,Facial Recognition,No Dialog', 'Member Card Number');
            Sender.RegisterTextParameter('DefaultInputValue', '');
            Sender."Blocking UI" := true;

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    var
        MEMBERCARD_PROMPT: Label 'Enter Member Card Number';
        MEMBERNUMBER_PROMPT: Label 'Enter Member Number';
        MEMBERSHIPNUMBER_PROMPT: Label 'Enter Membership Number';
        DIALOG_TITLE: Label '%1 - Membership Management.';
    begin
        Captions.AddActionCaption(ActionCode(), 'MemberCardPrompt', MEMBERCARD_PROMPT);
        Captions.AddActionCaption(ActionCode(), 'MemberNumberPrompt', MEMBERNUMBER_PROMPT);
        Captions.AddActionCaption(ActionCode(), 'MembershipNumberPrompt', MEMBERSHIPNUMBER_PROMPT);
        Captions.AddActionCaption(ActionCode(), 'DialogTitle', DIALOG_TITLE);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', true, true)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin

        if (not Action.IsThisAction(ActionCode())) then
            exit;

        Handled := true;

        case (WorkflowStep) of
            'GetMembershipAlterationLookup':
                Frontend.WorkflowResponse(GetMembershipAlterationLookupChoices(Context, POSSession, State, Frontend));
            'DoManageMembership':
                Frontend.WorkflowResponse(ManageMembershipAction(Context, POSSession, State, Frontend));
            else
                exit;
        end;

    end;

    procedure ManageMembershipAction(Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management") JsonText: Text
    var
        FunctionId: Integer;
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
    begin
        FunctionId := Context.GetIntegerParameter('Function');

        JsonText := '{}';
        case FunctionId of
            0:
                POSMemberArrival(Context, POSSession, State, Frontend);
            1:
                SelectMembership(Context, POSSession, State, Frontend);
            2:
                JsonText := GetMembershipEntryLookupJson(Context);
            3:
                ExecuteMembershipAlteration(Context, POSSession, MembershipAlterationSetup."Alteration Type"::REGRET);
            4:
                ExecuteMembershipAlteration(Context, POSSession, MembershipAlterationSetup."Alteration Type"::RENEW);
            5:
                ExecuteMembershipAlteration(Context, POSSession, MembershipAlterationSetup."Alteration Type"::EXTEND);
            6:
                ExecuteMembershipAlteration(Context, POSSession, MembershipAlterationSetup."Alteration Type"::UPGRADE);
            7:
                ExecuteMembershipAlteration(Context, POSSession, MembershipAlterationSetup."Alteration Type"::CANCEL);
            8:
                EditMembership(POSSession);
            9:
                ShowMember(Context, POSSession, State, Frontend);
            10:
                EditActiveMembership(POSSession);
        end;
        exit(JsonText);
    end;

    procedure POSMemberArrival(Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Member: Record "NPR MM Member";
        MemberCard: Record "NPR MM Member Card";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        MemberLimitationMgr: Codeunit "NPR MM Member Lim. Mgr.";
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        MembershipEvents: Codeunit "NPR MM Membership Events";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        ExternalItemNo: Code[50];
        LogEntryNo: Integer;
        ResponseCode: Integer;
        FrontEndInputMethod: Option;
        ExternalMemberCardNo: Text[100];
        ItemDescription: Text;
        ResponseMessage: Text;
        PlaceHolderLbl: Label '%1/%2', Locked = true;
    begin

        ExternalMemberCardNo := CopyStr(Context.GetString('memberCardInput'), 1, MaxStrLen(ExternalMemberCardNo));
        FrontEndInputMethod := Context.GetInteger('DialogPrompt');

        GetMembershipFromCardNumberWithUI(FrontEndInputMethod, ExternalMemberCardNo, Membership, MemberCard, true);

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
        AddItemToPOS(POSSession, 0, ExternalItemNo, CopyStr(ItemDescription, 1, MaxStrLen(SaleLinePOS.Description)), StrSubstNo(PlaceHolderLbl, Membership."External Membership No.", ExternalMemberCardNo), 1, 0, SaleLinePOS);

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

    procedure SelectMembership(Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management") MembershipEntryNo: Integer
    var
        MemberCard: Record "NPR MM Member Card";
        Membership: Record "NPR MM Membership";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        FrontEndInputMethod: Option;
        ExternalMemberCardNo: Text[100];
    begin
        ExternalMemberCardNo := CopyStr(Context.GetString('memberCardInput'), 1, MaxStrLen(ExternalMemberCardNo));
        FrontEndInputMethod := Context.GetInteger('DialogPrompt');

        GetMembershipFromCardNumberWithUI(FrontEndInputMethod, ExternalMemberCardNo, Membership, MemberCard, true);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find();
        POSSale.Refresh(SalePOS);

        if (AssignMembershipToPOSWorker(SalePOS, Membership."Entry No.", ExternalMemberCardNo)) then begin
            POSSale.Refresh(SalePOS);
            POSSale.Modify(false, false);
        end;

        POSSession.RequestRefreshData();

        exit(Membership."Entry No.");
    end;

    local procedure GetMembershipEntryLookupJson(Context: Codeunit "NPR POS JSON Management") JsonText: Text
    var
        MembershipEntry: Record "NPR MM Membership Entry";
        Membership: Record "NPR MM Membership";
        MemberCard: Record "NPR MM Member Card";
        FrontEndInputMethod: Option;
        ExternalMemberCardNo: Text[100];
        LookupProperties: JsonObject;
        MembershipEntries: JsonArray;
        MEMBERSHIP_ENTRIES: Label 'Membership Entries.';
        MembershipEntriesJsonText: Text;
    begin
        ExternalMemberCardNo := CopyStr(Context.GetString('memberCardInput'), 1, MaxStrLen(ExternalMemberCardNo));
        FrontEndInputMethod := Context.GetInteger('DialogPrompt');

        GetMembershipFromCardNumberWithUI(FrontEndInputMethod, ExternalMemberCardNo, Membership, MemberCard, false);

        MembershipEntry.SetCurrentKey("Entry No.");
        MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        MembershipEntry.Ascending(false);

        MembershipEntries.ReadFrom('[]');
        if (MembershipEntry.FindSet()) then begin
            repeat
                MembershipEntries.Add(GetMembershipEntryLookupDataToJson(MembershipEntry))
            until (MembershipEntry.Next() = 0);
        end;
        MembershipEntries.WriteTo(MembershipEntriesJsonText);

        LookupProperties.Add('title', MEMBERSHIP_ENTRIES);
        LookupProperties.Add('data', MembershipEntriesJsonText);
        LookupProperties.Add('layout', GetMembershipEntryLayout());
        LookupProperties.WriteTo(JsonText);

    end;

    local procedure ExecuteMembershipAlteration(Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; AlterationType: Option)
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        Membership: Record "NPR MM Membership";
        MemberCard: Record "NPR MM Member Card";
        SaleLinePOS: Record "NPR POS Sale Line";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        ItemNo: Code[20];
        MemberInfoEntryNo: Integer;
        ADMIT_MEMBERS: Label 'Do you want to admit the member(s) automatically?';
        ExternalMemberCardNo: Text[100];
        ExecutingMembershipAlterationErr: Label 'executing membership alteration';
    begin
        ItemNo := CopyStr(Context.GetStringOrFail('itemNumber', ExecutingMembershipAlterationErr), 1, MaxStrLen(ItemNo));

        ExternalMemberCardNo := CopyStr(Context.GetString('memberCardInput'), 1, MaxStrLen(ExternalMemberCardNo));
        GetMembershipFromCardNumberWithUI(MemberSelectionMethod::NO_PROMPT, ExternalMemberCardNo, Membership, MemberCard, false);

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

        if (MembershipAlterationSetup."Auto-Admit Member On Sale" = MembershipAlterationSetup."Auto-Admit Member On Sale"::ASK) then
            MemberInfoCapture."Auto-Admit Member" := Confirm(ADMIT_MEMBERS, true);

        if (MembershipAlterationSetup."Auto-Admit Member On Sale" = MembershipAlterationSetup."Auto-Admit Member On Sale"::YES) then
            MemberInfoCapture."Auto-Admit Member" := true;

        MemberInfoCapture.Modify();

        AddItemToPOS(POSSession, MemberInfoEntryNo, ItemNo, MembershipAlterationSetup.Description, CopyStr(ExternalMemberCardNo, 1, 80), 1, MemberInfoCapture."Unit Price", SaleLinePOS);

    end;

    local procedure EditMembership(POSSession: Codeunit "NPR POS Session")
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        SaleLinePOS: Record "NPR POS Sale Line";
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

    local procedure EditActiveMembership(POSSession: Codeunit "NPR POS Session")
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        Membership: Record "NPR MM Membership";
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

    procedure ShowMember(Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        ExternalMemberCardNo: Text[100];
        FrontEndInputMethod: Option;
    begin
        ExternalMemberCardNo := CopyStr(Context.GetString('memberCardInput'), 1, MaxStrLen(ExternalMemberCardNo));
        FrontEndInputMethod := Context.GetInteger('DialogPrompt');

        if ((FrontEndInputMethod = MemberSelectionMethod::NO_PROMPT) and (ExternalMemberCardNo = '')) then
            if (not ChooseMemberCard(ExternalMemberCardNo)) then
                Error('');

        if ((FrontEndInputMethod = MemberSelectionMethod::CARD_SCAN)) then begin
            if (ExternalMemberCardNo = '') then
                if (not ChooseMemberCard(ExternalMemberCardNo)) then
                    Error('');
            FrontEndInputMethod := MemberSelectionMethod::NO_PROMPT;
        end;

        MemberRetailIntegration.POS_ShowMemberCard(FrontEndInputMethod, ExternalMemberCardNo);

    end;

    procedure GetMembershipAlterationLookupChoices(Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management") JsonText: Text
    var
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        Membership: Record "NPR MM Membership";
        MemberCard: Record "NPR MM Member Card";
        FunctionId: Integer;
        LookupProperties: JsonObject;
        EXTEND_OPTION: Label 'Extend options...';
        RENEW_OPTION: Label 'Renew options...';
        EXTEND_NOT_VALID: Label 'There are no valid extend products for this membership at this time.';
        RENEW_NOT_VALID: Label 'There are no valid renewal products for this membership at this time.';
        UPGRADE_NOT_VALID: Label 'There are no valid upgrade products for this membership at this time.';
        UPGRADE_OPTION: Label 'Upgrade options...';
        ExternalMemberCardNo: Text[100];
    begin
        FunctionId := Context.GetIntegerParameter('Function');

        ExternalMemberCardNo := CopyStr(Context.GetString('memberCardInput'), 1, MaxStrLen(ExternalMemberCardNo));
        GetMembershipFromCardNumberWithUI(MemberSelectionMethod::NO_PROMPT, ExternalMemberCardNo, Membership, MemberCard, false);

        MembershipAlterationSetup.setfilter("From Membership Code", '=%1', Membership."Membership Code");

        case FunctionId of
            4:
                begin
                    MembershipAlterationSetup.setfilter("Alteration Type", '=%1', MembershipAlterationSetup."Alteration Type"::RENEW);
                    LookupProperties.Add('notFoundMessage', RENEW_NOT_VALID);
                    LookupProperties.Add('title', RENEW_OPTION);
                end;
            5:
                begin
                    MembershipAlterationSetup.setfilter("Alteration Type", '=%1', MembershipAlterationSetup."Alteration Type"::EXTEND);
                    LookupProperties.Add('notFoundMessage', EXTEND_NOT_VALID);
                    LookupProperties.Add('title', EXTEND_OPTION);
                end;
            6:
                begin
                    MembershipAlterationSetup.setfilter("Alteration Type", '=%1', MembershipAlterationSetup."Alteration Type"::UPGRADE);
                    LookupProperties.Add('notFoundMessage', UPGRADE_NOT_VALID);
                    LookupProperties.Add('title', UPGRADE_OPTION);
                end;

        end;
        LookupProperties.Add('cardnumber', ExternalMemberCardNo);
        LookupProperties.Add('data', CreateAlterMembershipOptions(Membership."Entry No.", MembershipAlterationSetup));
        LookupProperties.Add('layout', GetAlterMembershipLayout());
        LookupProperties.WriteTo(JsonText);

    end;

    local procedure GetMembershipFromCardNumberWithUI(InputMethod: option; var ExternalMemberCardNo: Text[100]; var Membership: Record "NPR MM Membership"; MemberCard: Record "NPR MM Member Card"; WithActivate: Boolean)
    var
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MEMBERSHIP_BLOCKED_NOT_FOUND: Label 'Membership %1 is either blocked or not found.';
        MEMBERSHIP_NOT_SELECTED: Label 'No membership was selected.';

        FailReasonText: Text;
    begin

        if ((ExternalMemberCardNo = '') and (InputMethod in [MemberSelectionMethod::NO_PROMPT, MemberSelectionMethod::CARD_SCAN])) then begin
            InputMethod := MemberSelectionMethod::NO_PROMPT;
            if (not ChooseMemberCard(ExternalMemberCardNo)) then
                Error(MEMBERSHIP_NOT_SELECTED);
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

    local procedure AssignMembershipToPOSWorker(var SalePOS: Record "NPR POS Sale"; MembershipEntryNo: Integer; ExternalMemberCardNo: Text[100]): Boolean
    var
        Membership: Record "NPR MM Membership";
        POSSalesInfo: Record "NPR MM POS Sales Info";
        MembershipSetup: Record "NPR MM Membership Setup";
    begin

        if (not Membership.Get(MembershipEntryNo)) then
            exit(false);

        if (Membership."Customer No." <> '') then begin
            SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
            SalePOS."Customer No." := '';
            SalePOS.Validate("Customer No.", Membership."Customer No.");
        end else begin
            SalePOS."Customer Type" := SalePOS."Customer Type"::Cash;
            SalePOS."Customer No." := '';

            MembershipSetup.Get(Membership."Membership Code");
            if (MembershipSetup."Membership Customer No." <> '') then begin
                SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
                SalePOS."Customer No." := '';
            end;

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

        exit(true);

    end;

    local procedure UpdatePOSSalesInfo(var SaleLinePOS: Record "NPR POS Sale Line"; MembershipEntryNo: Integer; MemberEntryNo: Integer; MembercardEntryNo: Integer; ScannedCardData: Text[200])
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
        POSSalesInfo."Member Card Entry No." := MembercardEntryNo;
        POSSalesInfo."Scanned Card Data" := ScannedCardData;
        POSSalesInfo.Modify();

    end;

    local procedure CreateAlterMembershipOptions(MembershipEntryNo: Integer; var MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup") Options: Text
    var
        TempMembershipEntry: Record "NPR MM Membership Entry" temporary;
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        OptionsArray: JsonArray;
    begin

        if (not MembershipAlterationSetup.FindFirst()) then
            exit('[]');

        if (not MembershipManagement.GetMembershipChangeOptions(MembershipEntryNo, MembershipAlterationSetup, TempMembershipEntry)) then
            exit('[]');

        TempMembershipEntry.Reset();
        TempMembershipEntry.FindSet();

        repeat
            OptionsArray.Add(GetMembershipEntryLookupDataToJson(TempMembershipEntry));
        until (TempMembershipEntry.next() = 0);

        OptionsArray.WriteTo(Options);
    end;

    local procedure GetMembershipEntryLookupDataToJson(var TmpMembershipEntry: Record "NPR MM Membership Entry" temporary) ChangeOption: JsonObject
    begin
        ChangeOption.Add('itemno', TmpMembershipEntry."Item No.");
        ChangeOption.Add('fromdate', TmpMembershipEntry."Valid From Date");
        ChangeOption.Add('untildate', TmpMembershipEntry."Valid Until Date");
        ChangeOption.Add('unitprice', format(TmpMembershipEntry."Unit Price", 0, '<Sign><Integer><Decimals,3>'));
        ChangeOption.Add('description', TmpMembershipEntry.Description);
        ChangeOption.Add('amount', format(TmpMembershipEntry."Amount Incl VAT", 0, '<Sign><Integer><Decimals,3>'));
        ChangeOption.Add('context', format(TmpMembershipEntry.Context));
        ChangeOption.Add('originalcontext', format(TmpMembershipEntry."Original Context"));

        exit(ChangeOption);
    end;

    local procedure GetMembershipEntryLayout() FieldLayout: text
    var
        TmpMembershipEntry: Record "NPR MM Membership Entry";
        Control: JsonArray;
        Row: JsonObject;
        Rows: JsonArray;
        MembershipEntryFieldLayout: JsonObject;
    begin

        Control.ReadFrom('[]');
        Control.Add(CreatLookupControl('custom-lookup-field', TmpMembershipEntry.FieldCaption(Context), 'context', 'left', 'small', 'calc(20% - 2px)', false));
        Control.Add(CreatLookupControl('custom-lookup-field', TmpMembershipEntry.FieldCaption("Original Context"), 'originalcontext', 'left', 'small', 'calc(20% - 2px)', false));
        Control.Add(CreatLookupControl('custom-lookup-field', TmpMembershipEntry.FieldCaption("Valid From Date"), 'fromdate', 'left', 'small', 'calc(20% - 2px)', false));
        Control.Add(CreatLookupControl('custom-lookup-field', TmpMembershipEntry.FieldCaption("Valid Until Date"), 'untildate', 'left', 'small', 'calc(20% - 2px)', false));
        Control.Add(CreatLookupControl('custom-lookup-field', TmpMembershipEntry.FieldCaption(Amount), 'amount', 'right', 'small', 'calc(20% - 2px)', false));
        Row.ReadFrom('{}');
        Row.Add('className', 'custom-lookup-row-heading');
        Row.Add('controls', Control);
        Rows.Add(Row);

        Control.ReadFrom('[]');
        Control.Add(CreatLookupControl('custom-lookup-field-main', TmpMembershipEntry.FieldCaption(Description), 'description', 'left', 'medium', 'calc(100% - 2px)', true));
        Row.ReadFrom('{}');
        Row.Add('className', 'custom-lookup-row-main');
        Row.Add('main', true);
        Row.Add('controls', Control);
        Rows.Add(Row);

        MembershipEntryFieldLayout.ReadFrom('{}');
        MembershipEntryFieldLayout.Add('className', 'custom-lookup-row');
        MembershipEntryFieldLayout.Add('rows', Rows);

        MembershipEntryFieldLayout.WriteTo(FieldLayout);
    end;

    local procedure GetAlterMembershipLayout() FieldLayout: text
    var
        TmpMembershipEntry: Record "NPR MM Membership Entry";
        Control: JsonArray;
        Row: JsonObject;
        Rows: JsonArray;
        AlterMembershipFieldLayout: JsonObject;
    begin

        Control.ReadFrom('[]');
        Control.Add(CreatLookupControl('custom-lookup-field', TmpMembershipEntry.FieldCaption("Item No."), 'itemno', 'left', 'small', 'calc(25% - 2px)', false));
        Control.Add(CreatLookupControl('custom-lookup-field', TmpMembershipEntry.FieldCaption("Valid From Date"), 'fromdate', 'left', 'small', '25%', false));
        Control.Add(CreatLookupControl('custom-lookup-field', TmpMembershipEntry.FieldCaption("Valid Until Date"), 'untildate', 'left', 'small', '25%', false));
        Control.Add(CreatLookupControl('custom-lookup-field', TmpMembershipEntry.FieldCaption("Unit Price"), 'unitprice', 'right', 'small', '25%', false));
        Row.ReadFrom('{}');
        Row.Add('className', 'custom-lookup-row-heading');
        Row.Add('controls', Control);
        Rows.Add(Row);

        Control.ReadFrom('[]');
        Control.Add(CreatLookupControl('custom-lookup-field-main', TmpMembershipEntry.FieldCaption(Description), 'description', 'left', 'medium', 'calc(80% - 2px)', true));
        Control.Add(CreatLookupControl('custom-lookup-field-main', TmpMembershipEntry.FieldCaption(Amount), 'amount', 'right', 'medium', '20%', false));
        Row.ReadFrom('{}');
        Row.Add('className', 'custom-lookup-row-main');
        Row.Add('main', true);
        Row.Add('controls', Control);
        Rows.Add(Row);

        AlterMembershipFieldLayout.ReadFrom('{}');
        AlterMembershipFieldLayout.Add('className', 'custom-lookup-row');
        AlterMembershipFieldLayout.Add('rows', Rows);

        AlterMembershipFieldLayout.WriteTo(FieldLayout);
    end;

    local procedure CreatLookupControl(FieldClassName: Text; FieldCaption: Text; FieldId: Text; FieldAlignment: Text; FieldFontSize: Text; FieldWidth: Text; IsSearchable: Boolean) FieldMetaData: JsonObject
    begin
        FieldMetaData.Add('className', FieldClassName);
        FieldMetaData.Add('caption', FieldCaption);
        FieldMetaData.Add('fieldNo', FieldId);
        FieldMetaData.Add('align', FieldAlignment);
        FieldMetaData.Add('fontSize', FieldFontSize);
        FieldMetaData.Add('width', FieldWidth);
        FieldMetaData.Add('searchable', IsSearchable);

        exit(FieldMetaData);
    end;

    procedure ChooseMemberCard(var ExtMemberCardNo: Text[100]): Boolean
    begin
        exit(ChooseMemberCardViaMemberSearchUI(ExtMemberCardNo));
    end;

    local procedure ChooseMemberCardViaMemberSearchUI(var ExtMemberCardNo: Text[100]): Boolean
    var
        Member: Record "NPR MM Member";
        MemberCard: Record "NPR MM Member Card";
        MemberCardList: Page "NPR MM Member Card List";
        MemberCardCount: Integer;
    begin

        Member.SetFilter(Blocked, '=%1', false);
        if (not ChooseMemberWithSearchUI(Member)) then
            exit;

        MemberCard.SetCurrentKey("Member Entry No.");
        MemberCard.SetFilter("Member Entry No.", '=%1', Member."Entry No.");
        MemberCard.SetFilter(Blocked, '=%1', false);
        MemberCard.SetFilter("Valid Until", '=%1|>=%2', 0D, Today());
        MemberCardCount := MemberCard.Count();

        case true of
            MemberCardCount > 1:
                begin
                    MemberCardList.SetTableView(MemberCard);
                    MemberCardList.Editable(false);
                    MemberCardList.LookupMode(true);
                    if (Action::LookupOK <> MemberCardList.RunModal()) then
                        exit(false);

                    MemberCardList.GetRecord(MemberCard);
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
                                MemberCardList.SetTableView(MemberCard);
                                MemberCardList.Editable(false);
                                MemberCardList.LookupMode(true);
                                if (Action::LookupOK <> MemberCardList.RunModal()) then
                                    exit;
                                MemberCardList.GetRecord(MemberCard);
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

    local procedure ChooseMemberWithSearchUI(var Member: Record "NPR MM Member"): Boolean
    var
        MemberSearch: Page "NPR MM Member Search Fields";
        MemberList: Page "NPR MM Members";
        PageAction: Action;
        FullTextSearch: Label 'Are you not finding what you are looking for? Do you want to do a full text member search?';
    begin

        MemberSearch.LookupMode(true);
        PageAction := MemberSearch.RunModal();

        if (PageAction = Action::LookupOK) then begin
            Member.SetFilter("External Member No.", '=%1', MemberSearch.GetSelectedMemberNumber());
            if (Member.FindFirst()) then
                ;
        end else begin
            if (not Confirm(FullTextSearch, false)) then
                exit(false);

            MemberList.LookupMode(true);
            MemberList.SetTableView(Member);
            PageAction := MemberList.RunModal();
            if (PageAction = Action::LookupOK) then
                MemberList.GetRecord(Member);
        end;

        exit(Member."External Member No." <> '');
    end;

    local procedure AddItemToPOS(POSSession: Codeunit "NPR POS Session"; MemberInfoEntryNo: Integer; ExternalItemNo: Code[50]; Description: Text[100]; Description2: Text[80]; Quantity: Decimal; UnitPrice: Decimal; var SaleLinePOS: Record "NPR POS Sale Line")
    var
        Line: Record "NPR POS Sale Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        ItemNo: Code[20];
        VariantCode: Code[10];
        Resolver: Integer;
        NotFoundErr: Label 'Item number %1 not found.';
    begin

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(Line);
        DeleteMemberInfoCapture(Line); // If I somehow reused an existing entry, delete it. (New entry does not have receipt number set yet)

        if (not MemberRetailIntegration.TranslateBarcodeToItemVariant(ExternalItemNo, ItemNo, VariantCode, Resolver)) then
            Error(NotFoundErr, ExternalItemNo);

        Line.Type := Line.Type::Item;
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

        SaleLinePOS.Validate("Unit Price", Abs(UnitPrice));
        SaleLinePOS."Description 2" := CopyStr(Description2, 1, MaxStrLen(SaleLinePOS."Description 2"));
        SaleLinePOS.Modify();

        POSSession.RequestRefreshData();
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
}

