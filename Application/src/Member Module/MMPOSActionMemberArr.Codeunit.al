codeunit 6060140 "NPR MM POS Action: Member Arr."
{
    var
        ActionDescription: Label 'This action handles member arrival functions.';
        MemberCardPrompt: Label 'Enter Member Card Number';
        MemberNumberPrompt: Label 'Enter Member Number';
        MembershipNumberPrompt: Label 'Enter Membership Number';
        MembershipTitle: Label 'Member Arrival - Membership Management.';
        DialogMethod: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT;
        POSWorkflowMethod: Option POS,Automatic,GuestCheckin;
        MEMBER_REQUIRED: Label 'Member identification must be specified.';

    local procedure "--Subscribers"()
    begin
    end;

    local procedure ActionCode(): Text
    begin
        exit('MM_MEMBER_ARRIVAL');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.2');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverActions(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
          ActionCode(),
          ActionDescription,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple)
        then begin

            Sender.RegisterWorkflowStep('membercard_number', '(param.DefaultInputValue.length == 0 && param.DialogPrompt == 1) && input ({caption: labels.MemberCardPrompt, title: labels.MembershipTitle, value: param.DefaultInputValue}).cancel(abort);');

            Sender.RegisterWorkflowStep('9', 'respond ();');
            Sender.RegisterWorkflow(false);

            // NOTE: Dont forget to update the EAN box parameter setup in OnInitEanBoxParameters()
            Sender.RegisterOptionParameter('DialogPrompt', 'Member Number,Member Card Number,Membership Number,Facial Recognition,No Prompt', 'Member Card Number');
            Sender.RegisterOptionParameter('POSWorkflow', 'POSSales,Automatic,With Guests', 'POSSales');
            Sender.RegisterTextParameter('AdmissionCode', '');
            Sender.RegisterBooleanParameter('ConfirmMember', true);
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
        MemberCardNumber: Text[100];
        DialogPrompt: Integer;
        DialogMethodType: Option;
        POSWorkflowType: Option;
        AdmissionCode: Code[20];
        ConfirmMember: Boolean;
        DefaultInputValue: Text;
    begin

        if (not Action.IsThisAction(ActionCode())) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        DefaultInputValue := JSON.GetStringParameterOrFail('DefaultInputValue', ActionCode());
        DialogPrompt := JSON.GetIntegerParameterOrFail('DialogPrompt', ActionCode());
        if (DialogPrompt < 0) then
            DialogPrompt := 1;

        DialogMethodType := DialogMethod::CARD_SCAN;

        case DialogPrompt of
            0:
                MemberCardNumber := '';
            1:
                begin
                    DialogMethodType := DialogMethod::NO_PROMPT;
                    MemberCardNumber := CopyStr(GetInput(JSON, 'membercard_number'), 1, MaxStrLen(MemberCardNumber));
                end;
            2:
                MemberCardNumber := '';
            3:
                DialogMethodType := DialogMethod::FACIAL_RECOGNITION;
            4:
                if (DefaultInputValue <> '') then
                    DialogMethodType := DialogMethod::NO_PROMPT;
            else
                Error('POS Action: Dialog Prompt with ID %1 is not implemented.', DialogPrompt);
        end;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        POSWorkflowType := JSON.GetIntegerParameter('POSWorkflow');
        if (POSWorkflowType < 0) then
            POSWorkflowType := POSWorkflowMethod::POS;

        JSON.InitializeJObjectParser(Context, FrontEnd);

        AdmissionCode := JSON.GetStringParameter('AdmissionCode');

        JSON.InitializeJObjectParser(Context, FrontEnd);
        ConfirmMember := JSON.GetBooleanParameterOrFail('ConfirmMember', ActionCode());

        if (DefaultInputValue <> '') then
            MemberCardNumber := DefaultInputValue;

        if (WorkflowStep = '9') then
            MemberArrival(POSSession, DialogMethodType, POSWorkflowType, MemberCardNumber, AdmissionCode);

        Handled := true;
    end;

    local procedure "--Workers"()
    begin
    end;

    local procedure MemberArrival(POSSession: Codeunit "NPR POS Session"; InputMethod: Option; POSWorkflowType: Option; ExternalMemberCardNo: Text[100]; AdmissionCode: Code[20])
    var
        Member: Record "NPR MM Member";
        MemberCard: Record "NPR MM Member Card";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        ThisShouldBeEmpty_SaleLinePOS: Record "NPR POS Sale Line";
        MemberLimitationMgr: Codeunit "NPR MM Member Lim. Mgr.";
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MemberTicketManager: Codeunit "NPR MM Member Ticket Manager";
        POSActionMemberManagement: Codeunit "NPR MM POS Action: MemberMgmt.";
        MembershipEvents: Codeunit "NPR MM Membership Events";
        ExternalItemNo: Code[50];
        LogEntryNo: Integer;
        ResponseCode: Integer;
        ResponseMessage: Text;
        Token: Text[100];
    begin

        if (InputMethod = DialogMethod::NO_PROMPT) and (ExternalMemberCardNo = '') then
            if (not SelectMemberCardUI(ExternalMemberCardNo)) then
                Error(MEMBER_REQUIRED);

        case POSWorkflowType of
            POSWorkflowMethod::POS:
                POSActionMemberManagement.MemberArrival(POSSession, InputMethod, ExternalMemberCardNo);
            POSWorkflowMethod::Automatic,
            POSWorkflowMethod::GuestCheckin:
                begin
                    MemberLimitationMgr.POS_CheckLimitMemberCardArrival(ExternalMemberCardNo, AdmissionCode, 'POS', LogEntryNo, ResponseMessage, ResponseCode);
                    Commit();

                    if (ResponseCode <> 0) then
                        Error(ResponseMessage);

                    MemberCard.Get(MembershipManagement.GetCardEntryNoFromExtCardNo(ExternalMemberCardNo));
                    Membership.Get(MemberCard."Membership Entry No.");
                    MembershipSetup.Get(Membership."Membership Code");

                    MembershipEvents.OnBeforePOSMemberArrival(ThisShouldBeEmpty_SaleLinePOS, MembershipSetup."Community Code", MembershipSetup.Code, Membership."Entry No.", Member."Entry No.", MemberCard."Entry No.", ExternalMemberCardNo);

                    ExternalItemNo := MemberRetailIntegration.POS_GetExternalTicketItemFromMembership(ExternalMemberCardNo);

                    if (POSWorkflowType = POSWorkflowMethod::Automatic) then
                        MemberTicketManager.MemberFastCheckIn(ExternalMemberCardNo, ExternalItemNo, AdmissionCode, 1, '');

                    if (POSWorkflowType = POSWorkflowMethod::GuestCheckin) then begin
                        MemberTicketManager.PromptForMemberGuestArrival(ExternalMemberCardNo, AdmissionCode, Token);
                        MemberTicketManager.MemberFastCheckIn(ExternalMemberCardNo, ExternalItemNo, AdmissionCode, 1, Token);
                    end;

                end;
        end;
    end;

    local procedure GetInput(JSON: Codeunit "NPR POS JSON Management"; Path: Text): Text
    begin
        JSON.SetScopeRoot();
        if (not JSON.SetScope('$' + Path)) then
            exit('');

        exit(JSON.GetString('input'));
    end;

    local procedure SelectMemberCardUI(var ExtMemberCardNo: Text[100]): Boolean
    var
        MemberCard: Record "NPR MM Member Card";
    begin

        if (ACTION::LookupOK <> PAGE.RunModal(0, MemberCard)) then
            exit(false);

        ExtMemberCardNo := MemberCard."External Card No.";
        exit(ExtMemberCardNo <> '');
    end;

    local procedure "--- Ean Box Event Handling"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    var
        MMMemberCard: Record "NPR MM Member Card";
    begin

        if (not EanBoxEvent.Get(EventCodeExtMemberCardNo())) then begin
            EanBoxEvent.Init();
            EanBoxEvent.Code := EventCodeExtMemberCardNo();
            EanBoxEvent."Module Name" := 'Membership Management';

            EanBoxEvent.Description := CopyStr(MMMemberCard.FieldCaption("External Card No."), 1, MaxStrLen(EanBoxEvent.Description));

            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "NPR POS Input Box Setup Mgt."; EanBoxEvent: Record "NPR Ean Box Event")
    begin

        case EanBoxEvent.Code of
            EventCodeExtMemberCardNo():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'DefaultInputValue', true, '');
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'DialogPrompt', false, 'No Prompt');
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'Function', false, 'Member Arrival');
                end;
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, 6060107, 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeMemberCardNo(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        MMMemberCard: Record "NPR MM Member Card";
    begin

        if (EanBoxSetupEvent."Event Code" <> EventCodeExtMemberCardNo()) then
            exit;
        if (StrLen(EanBoxValue) > MaxStrLen(MMMemberCard."External Card No.")) then
            exit;

        MMMemberCard.SetRange("External Card No.", UpperCase(EanBoxValue));
        if (MMMemberCard.FindFirst()) then
            InScope := true;

    end;

    local procedure EventCodeExtMemberCardNo(): Code[20]
    begin

        exit('MEMBER_ARRIVAL');

    end;

    local procedure CurrCodeunitId(): Integer
    begin

        exit(CODEUNIT::"NPR MM POS Action: Member Arr.");

    end;
}
