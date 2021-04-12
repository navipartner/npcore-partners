codeunit 6060138 "NPR MM POS Action: MemberMgmt."
{

    trigger OnRun()
    begin
    end;

    var
        QTY_CANT_CHANGE: Label 'Changing quantity for membership sales is not possible.';
        ActionDescription: Label 'This action handles member management functions.';
        MemberCardPrompt: Label 'Enter Member Card Number';
        MemberNumberPrompt: Label 'Enter Member Number';
        MembershipNumberPrompt: Label 'Enter Membership Number';
        MembershipTitle: Label '%1 - Membership Management.';
        RENEW_NOT_VALID: Label 'There are no valid renewal products for this membership at this time.';
        EXTEND_NOT_VALID: Label 'There are no valid extend products for this membership at this time.';
        UPGRADE_NOT_VALID: Label 'There are no valid upgrade products for this membership at this time.';
        CANCEL_NOT_VALID: Label 'Membership can''t be canceled with a refund at this time.';
        REGRET_NOT_VALID: Label 'A membership regret rule, explicitly disallows regret at this time.';
        MEMBERSHIP_BLOCKED_NOT_FOUND: Label 'Membership %1 is either blocked or not found.';
        CHANGEMEMBERSHIP_LOOKUP_CAPTION: Label '%1 - %2: %3';
        DialogMethod: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT;
        MEMBER_REQUIRED: Label 'Member identification must be specified.';
        NOT_MEMBERSHIP_SALES: Label 'The selected sales line is not a membership sales.';
        Text000: Label 'Update Membership metadata on Sale Line Insert';
        ADMIT_MEMBERS: Label 'Do you want to admit the member(s) automatically?';
        MembershipEvents: Codeunit "NPR MM Membership Events";

    local procedure "--Subscribers"()
    begin
    end;

    local procedure ActionCode(): Text
    begin
        exit('MM_MEMBERMGT');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.5');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverActions(var Sender: Record "NPR POS Action")
    var
        FunctionOptionString: Text;
        JSArr: Text;
        N: Integer;
    begin
        if Sender.DiscoverAction(
          ActionCode(),
          ActionDescription,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple)
        then begin

            FunctionOptionString := 'Member Arrival,' +
                                    'Select Membership,' +
                                    'View Membership Entry,Regret Membership Entry,' +
                                    'Renew Membership,Extend Membership,Upgrade Membership,Cancel Membership,Edit Membership,Show Member,Edit Current Membership';
            for N := 1 to 11 do
                JSArr += StrSubstNo('"%1",', SelectStr(N, FunctionOptionString));
            JSArr := StrSubstNo('var optionNames = [%1];', CopyStr(JSArr, 1, StrLen(JSArr) - 1));

            Sender.RegisterWorkflowStep('0', JSArr + 'windowTitle = labels.MembershipTitle.substitute (optionNames[param.Function].toString()); ');
            Sender.RegisterWorkflowStep('membercard_number', '(param.DefaultInputValue.length == 0) && (param.DialogPrompt <= 0) && input ({caption: labels.MemberCardPrompt, title: windowTitle}).cancel(abort);');
            Sender.RegisterWorkflowStep('9', 'respond ();');
            Sender.RegisterWorkflow(false);

            Sender.RegisterOptionParameter('Function', FunctionOptionString, 'Member Arrival');
            Sender.RegisterOptionParameter('DialogPrompt', 'Member Card Number,Facial Recognition,No Dialog', 'Member Card Number');

            Sender.RegisterTextParameter('DefaultInputValue', '');

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'MemberCardPrompt', MemberCardPrompt);
        Captions.AddActionCaption(ActionCode(), 'MemberNumberPrompt', MemberNumberPrompt);
        Captions.AddActionCaption(ActionCode(), 'MembershipNumberPrompt', MembershipNumberPrompt);
        Captions.AddActionCaption(ActionCode(), 'MembershipTitle', MembershipTitle);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', true, true)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        FunctionId: Integer;
        MemberCardNumber: Text[100];
        DialogPrompt: Integer;
        DialogMethodType: Option;
        DefaultInputValue: Text;
    begin

        if (not Action.IsThisAction(ActionCode())) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        FunctionId := JSON.GetIntegerParameterOrFail('Function', ActionCode());
        if (FunctionId < 0) then
            FunctionId := 0;

        DefaultInputValue := JSON.GetStringParameterOrFail('DefaultInputValue', ActionCode());

        DialogPrompt := JSON.GetIntegerParameterOrFail('DialogPrompt', ActionCode());
        if (DialogPrompt < 0) then
            DialogPrompt := 1;

        DialogMethodType := DialogMethod::CARD_SCAN;
        case DialogPrompt of
            0:
                begin
                    DialogMethodType := DialogMethod::NO_PROMPT;
                    MemberCardNumber := CopyStr(GetInput(JSON, 'membercard_number'), 1, MaxStrLen(MemberCardNumber));
                end;
            1:
                DialogMethodType := DialogMethod::FACIAL_RECOGNITION;
            2:
                DialogMethodType := DialogMethod::NO_PROMPT;
            else
                Error('POS Action: Dialog Prompt with ID %1 is not implemented.', DialogPrompt);
        end;

        if (DefaultInputValue <> '') then
            MemberCardNumber := CopyStr(DefaultInputValue, 1, MaxStrLen(MemberCardNumber));

        if (WorkflowStep = '9') then begin
            case FunctionId of
                0:
                    MemberArrival(POSSession, DialogMethodType, MemberCardNumber);
                1:
                    SelectMembership(POSSession, DialogMethodType, MemberCardNumber);
                2:
                    ViewMembershipEntry(POSSession, DialogMethodType, MemberCardNumber);
                3:
                    RegretMembership(POSSession, DialogMethodType, MemberCardNumber);
                4:
                    RenewMembership(POSSession, DialogMethodType, MemberCardNumber);
                5:
                    ExtendMembership(POSSession, DialogMethodType, MemberCardNumber);
                6:
                    UpgradeMembership(POSSession, DialogMethodType, MemberCardNumber);
                7:
                    CancelMembership(POSSession, DialogMethodType, MemberCardNumber);
                8:
                    EditMembership(POSSession, DialogMethodType, MemberCardNumber);
                9:
                    ShowMember(POSSession, DialogMethodType, MemberCardNumber);

                10:
                    EditActiveMembership(POSSession, DialogMethodType, MemberCardNumber);

                else
                    Error('POS Action: Function with ID %1 is not implemented.', FunctionId);
            end;
        end;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150706, 'OnAfterInsertSaleLine', '', true, true)]
    local procedure UpdateMembershipOnSaleLineInsert(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SaleLinePOS: Record "NPR POS Sale Line")
    var
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        ReturnCode: Integer;
    begin

        if (POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId()) then
            exit;

        if (POSSalesWorkflowStep."Subscriber Function" <> 'UpdateMembershipOnSaleLineInsert') then
            exit;

        if (SaleLinePOS.IsTemporary) then
            exit;

        ReturnCode := MemberRetailIntegration.NewMemberSalesInfoCapture(SaleLinePOS);
        if (ReturnCode < 0) then
            if (ReturnCode <> -1102) then
                Message('%1', MemberRetailIntegration.GetErrorText(ReturnCode));
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150706, 'OnBeforeDeletePOSSaleLine', '', true, true)]
    local procedure OnBeforeDeletePOSSaleLine(SaleLinePOS: Record "NPR POS Sale Line")
    var
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
    begin
        if (SaleLinePOS.IsTemporary) then
            exit;

        MemberRetailIntegration.DeletePreemptiveMembership(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.");

        DeleteMemberInfoCapture(SaleLinePOS);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150706, 'OnBeforeSetQuantity', '', true, true)]
    local procedure OnBeforeSetQuantity(SaleLinePOS: Record "NPR POS Sale Line"; var NewQuantity: Decimal)
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        TmpMemberInfoCapture: Record "NPR MM Member Info Capture" temporary;
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MembershipAppemptCreate: Codeunit "NPR Membership Attempt Create";
        ReasonText: Text;
    begin

        if (SaleLinePOS.IsTemporary) then
            exit;

        MemberInfoCapture.SetCurrentKey("Receipt No.", "Line No.");
        MemberInfoCapture.SetFilter("Receipt No.", '=%1', SaleLinePOS."Sales Ticket No.");
        MemberInfoCapture.SetFilter("Line No.", '=%1', SaleLinePOS."Line No.");
        if (MemberInfoCapture.FindFirst()) then begin
            if (SaleLinePOS."No." = MemberInfoCapture."Item No.") then begin
                if (MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, MemberInfoCapture."Item No.")) then;

                if (MembershipSalesSetup."Business Flow Type" <> MembershipSalesSetup."Business Flow Type"::ADD_ANONYMOUS_MEMBER) then
                    Error(QTY_CANT_CHANGE);

                TmpMemberInfoCapture.TransferFields(MemberInfoCapture, true);
                TmpMemberInfoCapture.Quantity := NewQuantity;
                TmpMemberInfoCapture.Insert();

                MembershipAppemptCreate.SetAttemptCreateMembershipForcedRollback();
                if (not MembershipAppemptCreate.run(TmpMemberInfoCapture)) then
                    if (not MembershipAppemptCreate.WasSuccessful(ReasonText)) then
                        error(ReasonText);

            end;
        end;

    end;

    procedure MemberArrival(POSSession: Codeunit "NPR POS Session"; InputMethod: Option; ExternalMemberCardNo: Text[100])
    var
        Member: Record "NPR MM Member";
        MemberCard: Record "NPR MM Member Card";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        MemberLimitationMgr: Codeunit "NPR MM Member Lim. Mgr.";
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        ExternalItemNo: Code[50];
        LogEntryNo: Integer;
        ResponseCode: Integer;
        ItemDescription: Text;
        ResponseMessage: Text;
    begin

        if (InputMethod = DialogMethod::NO_PROMPT) and (ExternalMemberCardNo = '') then
            if (not SelectMemberCardUI(ExternalMemberCardNo)) then
                Error(MEMBER_REQUIRED);

        MemberRetailIntegration.POS_ValidateMemberCardNo(true, true, InputMethod, true, ExternalMemberCardNo);
        MemberLimitationMgr.POS_CheckLimitMemberCardArrival(ExternalMemberCardNo, '', 'POS', LogEntryNo, ResponseMessage, ResponseCode);
        Commit();

        if (ResponseCode <> 0) then
            Error(ResponseMessage);

        MemberCard.Get(MembershipManagement.GetCardEntryNoFromExtCardNo(ExternalMemberCardNo));
        Membership.Get(MemberCard."Membership Entry No.");
        MembershipSetup.Get(Membership."Membership Code");

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(SaleLinePOS);

        Commit();
        MembershipEvents.OnBeforePOSMemberArrival(SaleLinePOS, MembershipSetup."Community Code", MembershipSetup.Code, Membership."Entry No.", Member."Entry No.", MemberCard."Entry No.", ExternalMemberCardNo);

        ItemDescription := '';
        MembershipEvents.OnCustomItemDescription(MembershipSetup."Community Code", MembershipSetup.Code, MemberCard."Entry No.", ItemDescription);

        ExternalItemNo := MemberRetailIntegration.POS_GetExternalTicketItemFromMembership(ExternalMemberCardNo);
        AddItemToPOS(POSSession, 0, ExternalItemNo, CopyStr(ItemDescription, 1, MaxStrLen(SaleLinePOS.Description)), StrSubstNo('%1/%2', Membership."External Membership No.", ExternalMemberCardNo), 1, 0, SaleLinePOS);

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

    procedure SelectMembership(POSSession: Codeunit "NPR POS Session"; InputMethod: Option; var ExternalMemberCardNo: Text[100]) MembershipSelected: Boolean
    var
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        POSSale: Codeunit "NPR POS Sale";
        ItemNo: Code[20];
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
    begin

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find();
        POSSale.Refresh(SalePOS);

        if (ExternalMemberCardNo = '') then
            if (not SelectMemberCardUI(ExternalMemberCardNo)) then
                exit;

        MemberRetailIntegration.POS_ValidateMemberCardNo(true, true, InputMethod, true, ExternalMemberCardNo);
        MembershipSelected := AssignPOSMembership(SalePOS, ExternalMemberCardNo);

        if (MembershipSelected) then begin
            POSSale.Refresh(SalePOS);
            POSSale.Modify(false, false);
        end;

        POSSession.RequestRefreshData();

        exit(MembershipSelected);
    end;

    local procedure CancelMembership(POSSession: Codeunit "NPR POS Session"; InputMethod: Option; ExternalMemberCardNo: Text[100])
    var
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        ItemNo: Code[20];
        MemberInfoEntryNo: Integer;
    begin

        if (ExternalMemberCardNo = '') then
            if (not SelectMemberCardUI(ExternalMemberCardNo)) then
                exit;

        MemberRetailIntegration.POS_ValidateMemberCardNo(true, true, InputMethod, false, ExternalMemberCardNo);
        ItemNo := GetAlterMembershipItemSelection(MembershipAlterationSetup."Alteration Type"::CANCEL, ExternalMemberCardNo, Today, CANCEL_NOT_VALID);
        if (ItemNo = '') then
            Error('');

        MemberInfoEntryNo := MembershipManagement.CreateCancelMemberInfoRequest(ExternalMemberCardNo, ItemNo);
        MemberInfoCapture.Get(MemberInfoEntryNo);
        MembershipAlterationSetup.Get(MembershipAlterationSetup."Alteration Type"::CANCEL, MemberInfoCapture."Membership Code", MemberInfoCapture."Item No.");

        AddItemToPOS(POSSession, MemberInfoEntryNo, ItemNo, MembershipAlterationSetup.Description, ExternalMemberCardNo, -1, MemberInfoCapture."Unit Price", SaleLinePOS);
    end;

    local procedure RenewMembership(POSSession: Codeunit "NPR POS Session"; InputMethod: Option; ExternalMemberCardNo: Text[100])
    var
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        ItemNo: Code[20];
        MemberInfoEntryNo: Integer;
    begin

        if (ExternalMemberCardNo = '') then
            if (not SelectMemberCardUI(ExternalMemberCardNo)) then
                exit;

        MemberRetailIntegration.POS_ValidateMemberCardNo(true, true, InputMethod, false, ExternalMemberCardNo);
        ItemNo := GetAlterMembershipItemSelection(MembershipAlterationSetup."Alteration Type"::RENEW, ExternalMemberCardNo, Today, RENEW_NOT_VALID);
        if (ItemNo = '') then
            Error('');

        MemberInfoEntryNo := MembershipManagement.CreateRenewMemberInfoRequest(ExternalMemberCardNo, ItemNo);
        MemberInfoCapture.Get(MemberInfoEntryNo);
        MembershipAlterationSetup.Get(MembershipAlterationSetup."Alteration Type"::RENEW, MemberInfoCapture."Membership Code", MemberInfoCapture."Item No.");

        if (MembershipAlterationSetup."Auto-Admit Member On Sale" = MembershipAlterationSetup."Auto-Admit Member On Sale"::ASK) then
            if (Confirm(ADMIT_MEMBERS, true)) then
                MemberInfoCapture."Auto-Admit Member" := true;

        if (MembershipAlterationSetup."Auto-Admit Member On Sale" = MembershipAlterationSetup."Auto-Admit Member On Sale"::YES) then
            MemberInfoCapture."Auto-Admit Member" := true;

        MemberInfoCapture.Modify();

        AddItemToPOS(POSSession, MemberInfoEntryNo, ItemNo, MembershipAlterationSetup.Description, ExternalMemberCardNo, 1, MemberInfoCapture."Unit Price", SaleLinePOS);
    end;

    local procedure UpgradeMembership(POSSession: Codeunit "NPR POS Session"; InputMethod: Option; ExternalMemberCardNo: Text[100])
    var
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        ItemNo: Code[20];
        MemberInfoEntryNo: Integer;
    begin

        if (ExternalMemberCardNo = '') then
            if (not SelectMemberCardUI(ExternalMemberCardNo)) then
                exit;

        MemberRetailIntegration.POS_ValidateMemberCardNo(true, true, InputMethod, false, ExternalMemberCardNo);
        ItemNo := GetAlterMembershipItemSelection(MembershipAlterationSetup."Alteration Type"::UPGRADE, ExternalMemberCardNo, Today, UPGRADE_NOT_VALID);
        if (ItemNo = '') then
            Error('');

        MemberInfoEntryNo := MembershipManagement.CreateUpgradeMemberInfoRequest(ExternalMemberCardNo, ItemNo);
        MemberInfoCapture.Get(MemberInfoEntryNo);
        MembershipAlterationSetup.Get(MembershipAlterationSetup."Alteration Type"::UPGRADE, MemberInfoCapture."Membership Code", MemberInfoCapture."Item No.");

        AddItemToPOS(POSSession, MemberInfoEntryNo, ItemNo, MembershipAlterationSetup.Description, ExternalMemberCardNo, 1, MemberInfoCapture."Unit Price", SaleLinePOS);
    end;

    local procedure ExtendMembership(POSSession: Codeunit "NPR POS Session"; InputMethod: Option; ExternalMemberCardNo: Text[100])
    var
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        ItemNo: Code[20];
        MemberInfoEntryNo: Integer;
    begin

        if (ExternalMemberCardNo = '') then
            if (not SelectMemberCardUI(ExternalMemberCardNo)) then
                exit;

        MemberRetailIntegration.POS_ValidateMemberCardNo(true, true, InputMethod, false, ExternalMemberCardNo);
        ItemNo := GetAlterMembershipItemSelection(MembershipAlterationSetup."Alteration Type"::EXTEND, ExternalMemberCardNo, Today, EXTEND_NOT_VALID);
        if (ItemNo = '') then
            Error('');

        MemberInfoEntryNo := MembershipManagement.CreateExtendMemberInfoRequest(ExternalMemberCardNo, ItemNo);
        MemberInfoCapture.Get(MemberInfoEntryNo);
        MembershipAlterationSetup.Get(MembershipAlterationSetup."Alteration Type"::EXTEND, MemberInfoCapture."Membership Code", MemberInfoCapture."Item No.");

        AddItemToPOS(POSSession, MemberInfoEntryNo, ItemNo, MembershipAlterationSetup.Description, ExternalMemberCardNo, 1, MemberInfoCapture."Unit Price", SaleLinePOS);
    end;

    local procedure RegretMembership(POSSession: Codeunit "NPR POS Session"; InputMethod: Option; ExternalMemberCardNo: Text[100])
    var
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        ItemNo: Code[20];
        MemberInfoEntryNo: Integer;
    begin

        MemberRetailIntegration.POS_ValidateMemberCardNo(true, true, InputMethod, false, ExternalMemberCardNo);
        ItemNo := GetAlterMembershipItemSelection(MembershipAlterationSetup."Alteration Type"::REGRET, ExternalMemberCardNo, Today, REGRET_NOT_VALID);
        if (ItemNo = '') then
            Error('');

        MemberInfoEntryNo := MembershipManagement.CreateRegretMemberInfoRequest(ExternalMemberCardNo, ItemNo);
        MemberInfoCapture.Get(MemberInfoEntryNo);
        MembershipAlterationSetup.Get(MembershipAlterationSetup."Alteration Type"::REGRET, MemberInfoCapture."Membership Code", MemberInfoCapture."Item No.");

        AddItemToPOS(POSSession, MemberInfoEntryNo, ItemNo, MembershipAlterationSetup.Description, ExternalMemberCardNo, 1, MemberInfoCapture."Unit Price", SaleLinePOS);
    end;

    local procedure ViewMembershipEntry(POSSession: Codeunit "NPR POS Session"; InputMethod: Option; ExternalMemberCardNo: Text[100])
    var
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipEntry: Record "NPR MM Membership Entry";
        Membership: Record "NPR MM Membership";
        TmpMembershipEntries: Record "NPR MM Membership Entry" temporary;
        MembershipEntryNo: Integer;
        ReasonNotFound: Text;
        MembershipEntries: Page "NPR MM Membership Entries View";
    begin

        MemberRetailIntegration.POS_ValidateMemberCardNo(false, false, InputMethod, false, ExternalMemberCardNo);
        if (ExternalMemberCardNo = '') then
            if (not SelectMemberCardUI(ExternalMemberCardNo)) then
                exit;

        MembershipEntryNo := MembershipManagement.GetMembershipFromExtCardNo(ExternalMemberCardNo, Today, ReasonNotFound);
        if (not Membership.Get(MembershipEntryNo)) then
            Error(ReasonNotFound);

        MembershipEntry.SetCurrentKey("Entry No.");
        MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        MembershipEntry.Ascending(false);
        if (MembershipEntry.FindSet()) then begin
            repeat
                TmpMembershipEntries.TransferFields(MembershipEntry, true);
                TmpMembershipEntries.Insert();
            until (MembershipEntry.Next() = 0);

            MembershipEntries.LoadEntries(ExternalMemberCardNo, TmpMembershipEntries);
            MembershipEntries.RunModal();

        end;
    end;

    local procedure AssignPOSMembership(var SalePOS: Record "NPR POS Sale"; var ExternalMemberCardNo: Text[100]): Boolean
    var
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        ReasonNotFound: Text;
        MembershipEntryNo: Integer;
    begin

        if (ExternalMemberCardNo = '') then
            if (not SelectMemberCardUI(ExternalMemberCardNo)) then
                exit(false);

        MembershipEntryNo := MembershipManagement.GetMembershipFromExtCardNo(ExternalMemberCardNo, Today, ReasonNotFound);

        if (MembershipEntryNo = 0) then
            Error(ReasonNotFound);

        exit(AssignMembershipToPOSWorker(SalePOS, MembershipEntryNo, ExternalMemberCardNo));

    end;

    local procedure AssignPOSMember(var SalePOS: Record "NPR POS Sale"; var ExternalMemberNo: Code[20]): Boolean
    var
        Membership: Record "NPR MM Membership";
        MemberCard: Record "NPR MM Member Card";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MemberEntryNo: Integer;
        ExternalMemberCardNo: Text;
    begin

        if (ExternalMemberNo = '') then
            if (not SelectMemberUI(ExternalMemberNo)) then
                exit(false);

        MemberEntryNo := MembershipManagement.GetMemberFromExtMemberNo(ExternalMemberNo);

        if (Membership.Get(MembershipManagement.GetMembershipFromExtMemberNo(ExternalMemberNo))) then
            if (MemberCard.Get(MembershipManagement.GetMemberCardEntryNo(MemberEntryNo, Membership."Membership Code", Today))) then
                ExternalMemberCardNo := MemberCard."External Card No.";

        exit(AssignMembershipToPOSWorker(SalePOS, Membership."Entry No.", ExternalMemberCardNo));

    end;

    local procedure AssignMembershipToPOSWorker(var SalePOS: Record "NPR POS Sale"; MembershipEntryNo: Integer; ExternalMemberCardNo: Text[200]): Boolean
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

    local procedure EditMembership(POSSession: Codeunit "NPR POS Session"; InputMethod: Option; ExternalMemberCardNo: Text[100])
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        SaleLinePOS: Record "NPR POS Sale Line";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
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

    local procedure EditActiveMembership(POSSession: Codeunit "NPR POS Session"; InputMethod: Option; ExternalMemberCardNo: Text[100])
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

    procedure ShowMember(POSSession: Codeunit "NPR POS Session"; InputMethod: Option; var ExternalMemberCardNo: Text[100])
    var
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
    begin

        if (ExternalMemberCardNo = '') then
            if (not SelectMemberCardUI(ExternalMemberCardNo)) then
                exit;

        MemberRetailIntegration.POS_ShowMemberCard(InputMethod, ExternalMemberCardNo);

    end;

    local procedure "--Helpers"()
    begin
    end;

    local procedure GetInput(JSON: Codeunit "NPR POS JSON Management"; Path: Text): Text
    begin

        JSON.SetScopeRoot();
        if (not JSON.SetScope('$' + Path)) then
            exit('');

        exit(JSON.GetString('input'));
    end;

    local procedure AddItemToPOS(POSSession: Codeunit "NPR POS Session"; MemberInfoEntryNo: Integer; ExternalItemNo: Code[50]; Description: Text[100]; Description2: Text[100]; Quantity: Decimal; UnitPrice: Decimal; var SaleLinePOS: Record "NPR POS Sale Line")
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

        // update info entry with this receipt number
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

    local procedure ShowAlterMembershipItemSelection(Type: Option; ExternalCardNo: Text[100]; ReferenceDate: Date; NotValidMessage: Text): Code[20]
    var
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        Membership: Record "NPR MM Membership";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        ItemNo: Code[20];
        NotFoundReasonText: Text;
    begin

        if (not Membership.Get(MembershipManagement.GetMembershipFromExtCardNo(ExternalCardNo, ReferenceDate, NotFoundReasonText))) then
            if (NotFoundReasonText <> '') then
                Error(NotFoundReasonText)
            else
                Error(MEMBERSHIP_BLOCKED_NOT_FOUND, ExternalCardNo);

        MembershipAlterationSetup.SetFilter("Alteration Type", '=%1', Type);
        MembershipAlterationSetup.SetFilter("From Membership Code", '=%1', Membership."Membership Code");

        ItemNo := ShowAlterMembershipLookupList(Membership."Entry No.",
          MembershipAlterationSetup,
          StrSubstNo(CHANGEMEMBERSHIP_LOOKUP_CAPTION, Format(MembershipAlterationSetup."Alteration Type"), Membership."External Membership No.", Membership."Membership Code"),
          NotValidMessage);

        exit(ItemNo);
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

    local procedure "--GUI"()
    begin
    end;

    local procedure GetAlterMembershipItemSelection(Type: Option; ExternalCardNo: Text[100]; ReferenceDate: Date; NotValidMessage: Text): Code[20]
    var
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        Membership: Record "NPR MM Membership";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        ItemNo: Code[20];
        NotFoundReasonText: Text;
    begin

        if (not Membership.Get(MembershipManagement.GetMembershipFromExtCardNo(ExternalCardNo, ReferenceDate, NotFoundReasonText))) then
            if (NotFoundReasonText <> '') then
                Error(NotFoundReasonText)
            else
                Error(MEMBERSHIP_BLOCKED_NOT_FOUND, ExternalCardNo);

        MembershipAlterationSetup.SetFilter("Alteration Type", '=%1', Type);
        MembershipAlterationSetup.SetFilter("From Membership Code", '=%1', Membership."Membership Code");
        if (not MembershipAlterationSetup.FindFirst()) then
            Error(NotValidMessage);

        ItemNo := ShowAlterMembershipLookupList(Membership."Entry No.",
          MembershipAlterationSetup,
          StrSubstNo(CHANGEMEMBERSHIP_LOOKUP_CAPTION, Format(MembershipAlterationSetup."Alteration Type"), Membership."Membership Code", Membership."External Membership No."),
          NotValidMessage);

        exit(ItemNo);
    end;

    local procedure ShowAlterMembershipLookupList(MembershipEntryNo: Integer; var MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup"; LookupCaption: Text; NotFoundMessage: Text) ItemNo: Code[20]
    var
        TmpMembershipEntry: Record "NPR MM Membership Entry" temporary;
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
    begin

        if (not MembershipAlterationSetup.FindFirst()) then
            Error(NotFoundMessage);

        if (not MembershipManagement.GetMembershipChangeOptions(MembershipEntryNo, MembershipAlterationSetup, TmpMembershipEntry)) then
            Error(NotFoundMessage);

        ItemNo := DoLookupMembershipEntry(LookupCaption, TmpMembershipEntry);

        exit(ItemNo);
    end;

    local procedure DoLookupMembershipEntry(LookupCaption: Text; var TmpMembershipEntry: Record "NPR MM Membership Entry" temporary) ItemNo: Code[20]
    var
        SelectAlteration: page "NPR MM Select Alteration";
        PageAction: Action;
        TmpMembershipEntryResponse: Record "NPR MM Membership Entry" temporary;
    begin
        ItemNo := '';

        SelectAlteration.LoadAlterationOption(LookupCaption, TmpMembershipEntry);
        SelectAlteration.LookupMode(true);
        PageAction := SelectAlteration.RunModal();
        if (PageAction = Action::LookupOK) then begin
            SelectAlteration.GetRecord(TmpMembershipEntryResponse);
            ItemNo := TmpMembershipEntryResponse."Item No.";
        end;

        exit(ItemNo);
    end;

    local procedure SelectMemberCardUI(var ExtMemberCardNo: Text[100]): Boolean
    begin

        exit(SelectMemberCardViaMemberUI(ExtMemberCardNo));

    end;

    local procedure SelectMemberUI(var ExtMemberNo: Code[20]): Boolean
    var
        Member: Record "NPR MM Member";
    begin

        if (ACTION::LookupOK <> PAGE.RunModal(0, Member)) then
            exit(false);

        ExtMemberNo := Member."External Member No.";
        exit(ExtMemberNo <> '');

    end;

    local procedure SelectMemberCardViaMemberUI(var ExtMemberCardNo: Text[100]): Boolean
    var
        Member: Record "NPR MM Member";
        MemberCard: Record "NPR MM Member Card";
        MemberCardList: Page "NPR MM Member Card List";
        ExtMemberNo: Code[20];
    begin

        if (not SelectMemberUI(ExtMemberNo)) then
            exit(false);

        Member.SetFilter("External Member No.", '=%1', ExtMemberNo);
        Member.SetFilter(Blocked, '=%1', false);
        if (not Member.FindFirst()) then
            exit(false);

        MemberCard.SetFilter("Member Entry No.", '=%1', Member."Entry No.");
        MemberCard.SetFilter(Blocked, '=%1', false);
        MemberCard.SetFilter("Valid Until", '=%1|>=%2', 0D, Today);
        if (MemberCard.Count() > 1) then begin
            MemberCardList.SetTableView(MemberCard);
            MemberCardList.Editable(false);
            MemberCardList.LookupMode(true);
            if (ACTION::LookupOK <> MemberCardList.RunModal()) then
                exit(false);

            MemberCardList.GetRecord(MemberCard);

        end else begin
            if (not MemberCard.FindFirst()) then begin
                MemberCard.Reset();
                MemberCard.SetFilter("Member Entry No.", '=%1', Member."Entry No.");
                MemberCard.SetFilter(Blocked, '=%1', false);
                if (MemberCard.Count() > 1) then begin
                    MemberCardList.SetTableView(MemberCard);
                    MemberCardList.Editable(false);
                    MemberCardList.LookupMode(true);
                    if (ACTION::LookupOK <> MemberCardList.RunModal()) then
                        exit(false);
                    MemberCardList.GetRecord(MemberCard);
                end else begin
                    if (not MemberCard.FindFirst()) then
                        exit(false);
                end;
            end;
        end;

        ExtMemberCardNo := MemberCard."External Card No.";
        exit(true);

    end;

    local procedure "--- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150705, 'OnBeforeLoadSavedSale', '', true, true)]
    local procedure OnBeforeLoadSavedSaleSubscriber_discontinued(var Sender: Codeunit "NPR POS Sale"; OriginalSalesTicketNo: Code[20]; NewSalesTicketNo: Code[20])
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberInfoCapture2: Record "NPR MM Member Info Capture";
        POSSalesInfo: Record "NPR MM POS Sales Info";
    begin

        MemberInfoCapture.SetCurrentKey("Receipt No.");
        MemberInfoCapture.SetFilter("Receipt No.", '=%1', OriginalSalesTicketNo);
        if (MemberInfoCapture.FindSet()) then begin
            repeat
                MemberInfoCapture2.Get(MemberInfoCapture."Entry No.");
                MemberInfoCapture2."Receipt No." := NewSalesTicketNo;
                MemberInfoCapture2.Modify();
            until (MemberInfoCapture.Next() = 0);
        end;

        if (POSSalesInfo.Get(POSSalesInfo."Association Type"::HEADER, OriginalSalesTicketNo, 0)) then begin
            POSSalesInfo."Receipt No." := NewSalesTicketNo;
            if (not (POSSalesInfo.Insert())) then;
        end;

        POSSalesInfo.SetFilter("Association Type", '=%1', POSSalesInfo."Association Type"::LINE);
        POSSalesInfo.SetFilter("Receipt No.", '=%1', OriginalSalesTicketNo);
        if (POSSalesInfo.FindSet()) then begin
            repeat
                POSSalesInfo."Receipt No." := NewSalesTicketNo;
                if (not POSSalesInfo.Insert()) then;
            until (POSSalesInfo.Next() = 0);
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, 6151005, 'OnAfterLoadFromQuote', '', true, true)]
    local procedure OnBeforeLoadSavedSaleSubscriber(POSQuoteEntry: Record "NPR POS Saved Sale Entry"; var SalePOS: Record "NPR POS Sale")
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberInfoCapture2: Record "NPR MM Member Info Capture";
        POSSalesInfo: Record "NPR MM POS Sales Info";
        OriginalSalesTicketNo: Code[20];
        NewSalesTicketNo: Code[20];
    begin

        OriginalSalesTicketNo := POSQuoteEntry."Sales Ticket No.";
        NewSalesTicketNo := SalePOS."Sales Ticket No.";

        MemberInfoCapture.SetCurrentKey("Receipt No.");
        MemberInfoCapture.SetFilter("Receipt No.", '=%1', OriginalSalesTicketNo);
        if (MemberInfoCapture.FindSet()) then begin
            repeat
                MemberInfoCapture2.Get(MemberInfoCapture."Entry No.");
                MemberInfoCapture2."Receipt No." := NewSalesTicketNo;
                MemberInfoCapture2.Modify();
            until (MemberInfoCapture.Next() = 0);
        end;

        if (POSSalesInfo.Get(POSSalesInfo."Association Type"::HEADER, OriginalSalesTicketNo, 0)) then begin
            POSSalesInfo."Receipt No." := NewSalesTicketNo;
            if (not (POSSalesInfo.Insert())) then;
        end;

        POSSalesInfo.SetFilter("Association Type", '=%1', POSSalesInfo."Association Type"::LINE);
        POSSalesInfo.SetFilter("Receipt No.", '=%1', OriginalSalesTicketNo);
        if (POSSalesInfo.FindSet()) then begin
            repeat
                POSSalesInfo."Receipt No." := NewSalesTicketNo;
                if (not POSSalesInfo.Insert()) then;
            until (POSSalesInfo.Next() = 0);
        end;

    end;

    local procedure "--- OnAfterInsertSaleLine Workflow"()
    begin

    end;

    [EventSubscriber(ObjectType::Table, 6150730, 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "NPR POS Sales Workflow Step"; RunTrigger: Boolean)
    begin

        if (Rec."Subscriber Codeunit ID" <> CurrCodeunitId()) then
            exit;

        case Rec."Subscriber Function" of
            'UpdateMembershipOnSaleLineInsert':
                begin
                    Rec.Description := Text000;
                    Rec."Sequence No." := 30;
                end;
        end;

    end;

    local procedure CurrCodeunitId(): Integer
    begin

        exit(CODEUNIT::"NPR MM POS Action: MemberMgmt.");

    end;

    local procedure "--POS Workflow"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150728, 'OnAfterLogin', '', true, true)]
    local procedure OnAfterLogin_SelectMemberRequired(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; var POSSession: Codeunit "NPR POS Session")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        Member: Record "NPR MM Member";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        POSMemberCardEdit: Page "NPR MM Member Card";
        ExternalMemberNo: Code[20];
        MembershipSelected: Boolean;
    begin

        if (POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId()) then
            exit;

        if (POSSalesWorkflowStep."Subscriber Function" <> 'OnAfterLogin_SelectMemberRequired') then
            exit;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find();
        POSSale.Refresh(SalePOS);

        ClearLastError;

        repeat

            //  MembershipSelected := false;
            //
            //  if (ExternalMemberCardNo = '') then
            //    if (not SelectMemberCardUI (ExternalMemberCardNo)) then
            //      exit;
            //
            // if (MemberRetailIntegration.POS_ValidateMemberCardNo (false, true, DialogMethod::NO_PROMPT, true, ExternalMemberCardNo)) then
            //    MembershipSelected := AssignPOSMembership (SalePOS, ExternalMemberCardNo);
            //
            //  if (not MembershipSelected) then begin
            //    MESSAGE ('There was an error selecting member %1:\\%2', ExternalMemberCardNo, GetLASTERRORTEXT);
            //    ExternalMemberCardNo := '';
            //  end;

            MembershipSelected := false;

            if (ExternalMemberNo = '') then
                SelectMemberUI(ExternalMemberNo);

            if (Member.Get(MembershipManagement.GetMemberFromExtMemberNo(ExternalMemberNo))) then begin

                Clear(POSMemberCardEdit);

                //  POSMemberCard.LOOKUPMODE (true);
                //  POSMemberCard.SETRECORD (Member);
                //  //POSMemberCard.SetMembershipEntryNo (Membership."Entry No.");
                //
                //  if (POSMemberCard.RUNMODAL() = ACTION::LookupOK) then
                //    MembershipSelected := AssignPOSMember (SalePOS, ExternalMemberNo);

                POSMemberCardEdit.SetRecord(Member);
                POSMemberCardEdit.LookupMode(true);
                ClearLastError;  //MM1.45 [407500]
                if (POSMemberCardEdit.RunModal() = ACTION::LookupOK) then
                    MembershipSelected := AssignPOSMember(SalePOS, ExternalMemberNo);

            end;

            if (not MembershipSelected) then begin
                Message('There was an error selecting member %1:\\%2', ExternalMemberNo, GetLastErrorText);
                ExternalMemberNo := '';
            end;

        until (MembershipSelected);

        if (MembershipSelected) then begin
            POSSale.Refresh(SalePOS);
            POSSale.Modify(false, false);
        end;

        POSSession.RequestRefreshData();

    end;

    [EventSubscriber(ObjectType::Table, 6150730, 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnAfterLoginDiscovery(var Rec: Record "NPR POS Sales Workflow Step"; RunTrigger: Boolean)
    begin

        if (Rec."Subscriber Codeunit ID" <> CurrCodeunitId()) then
            exit;

        case Rec."Subscriber Function" of
            'OnAfterLogin_SelectMemberRequired':
                begin
                    Rec.Description := CopyStr('On After Login, Select Member (Required)', 1, MaxStrLen(Rec.Description));
                    Rec."Sequence No." := CurrCodeunitId();
                    Rec.Enabled := false;
                end;
        end;

    end;
}

