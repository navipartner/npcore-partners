codeunit 6060140 "MM POS Action - Member Arrival"
{
    // 
    // MM1.21/TSA/20170616  CASE 279495 MemberArrival had duplicate member validation dialogs when doing POS validation.
    // MM1.21/TSA /20170721 CASE 284653 Added POS_CheckLimitMemberCardArrival in MemberArrival();
    // MM1.22/TSA /20170809 CASE 276102 Changed condition for showing dialog and dialog type passed to facial recognition
    // MM1.28/TSA /20180323 CASE 307113 Member Arrival consider named/anonymous setting
    // MM1.28/TSA /20180411 CASE 307113 Added the call publisher for member arrival
    // MM1.29/TSA /20180508 CASE 307230 Member guest checkin
    // MM1.29.02/TSA/20180529 CASE 317673 Minor fixes, found during testing
    // MM1.33/TSA /20180814 CASE 323744 Added DefaultInputValue handling for EAN box support
    // MM1.33/MHA /20180817  CASE 326754 Added Ean Box Event Handler functions
    // MM1.36/TSA /20181119 CASE 335889 Refactored MemberArrival with Guests
    // MM1.37/MHA /20190328  CASE 350288 Added MaxStrLen to EanBox.Description in DiscoverEanBoxEvents()


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This action handles member arrival functions.';
        MemberCardPrompt: Label 'Enter Member Card Number:';
        MemberNumberPrompt: Label 'Enter Member Number:';
        MembershipNumberPrompt: Label 'Enter Membership Number:';
        MembershipTitle: Label 'Member Arrival - Membership Management.';
        DialogMethod: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT;
        POSWorkflowMethod: Option POS,Automatic,GuestCheckin;
        MEMBER_REQUIRED: Label 'Member identification must be specified.';
        ErrorReason: Text;
        WELCOME: Label 'Welcome %1.';

    local procedure "--Subscribers"()
    begin
    end;

    local procedure ActionCode(): Text
    begin
        exit ('MM_MEMBER_ARRIVAL');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.2');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverActions(var Sender: Record "POS Action")
    var
        FunctionOptionString: Text;
        JSArr: Text;
        OptionName: Text;
        N: Integer;
    begin
        if Sender.DiscoverAction(
          ActionCode(),
          ActionDescription,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple)
        then begin
          //-MM1.22 [276102]

          Sender.RegisterWorkflowStep ('membercard_number',   '(param.DefaultInputValue.length == 0 && param.DialogPrompt == 1) && input ({caption: labels.MemberCardPrompt, title: labels.MembershipTitle, value: param.DefaultInputValue}).cancel(abort);');
          //+MM1.22 [276102]

          //Sender.RegisterWorkflowStep ('member_number',       '(param.DialogPrompt == 0) && input ({caption: labels.MemberNumberPrompt, title: labels.MembershipTitle}).cancel(abort);');
          //Sender.RegisterWorkflowStep ('membership_number',   '(param.DialogPrompt == 2) && input ({caption: labels.MembershipNumberPrompt, title: labels.MembershipTitle}).cancel(abort);');
          Sender.RegisterWorkflowStep ('9', 'respond ();');
          Sender.RegisterWorkflow (false);

          Sender.RegisterOptionParameter ('DialogPrompt', 'Member Number,Member Card Number,Membership Number,Facial Recognition,No Prompt', 'Member Card Number');
          Sender.RegisterOptionParameter ('POSWorkflow', 'POSSales,Automatic,With Guests', 'POSSales');
          Sender.RegisterTextParameter ('AdmissionCode', '');
          Sender.RegisterBooleanParameter ('ConfirmMember', true);
          Sender.RegisterTextParameter ('DefaultInputValue', '');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        Captions.AddActionCaption (ActionCode, 'MemberCardPrompt', MemberCardPrompt);
        Captions.AddActionCaption (ActionCode, 'MemberNumberPrompt', MemberNumberPrompt);
        Captions.AddActionCaption (ActionCode, 'MembershipNumberPrompt', MembershipNumberPrompt);
        Captions.AddActionCaption (ActionCode, 'MembershipTitle', MembershipTitle);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', true, true)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        MembershipManagement: Codeunit "MM Membership Management";
        Membership: Record "MM Membership";
        FunctionId: Integer;
        MemberCardNumber: Text[100];
        MembershipEntryNo: Integer;
        DialogPrompt: Integer;
        DialogMethodType: Option;
        POSWorkflowType: Option;
        AdmissionCode: Code[20];
        ConfirmMember: Boolean;
        DefaultInputValue: Text;
    begin

        if (not Action.IsThisAction (ActionCode ())) then
          exit;

        JSON.InitializeJObjectParser (Context, FrontEnd);
        DefaultInputValue := JSON.GetStringParameter ('DefaultInputValue', true);
        DialogPrompt := JSON.GetIntegerParameter ('DialogPrompt', true);
        if (DialogPrompt < 0) then
          DialogPrompt := 1;

        DialogMethodType := DialogMethod::CARD_SCAN;

        case DialogPrompt of
          0: MemberCardNumber := ''; //COPYSTR (GetInput (JSON, 'member_number'), 1, MAXSTRLEN (MemberCardNumber));
          1: begin
               DialogMethodType := DialogMethod::NO_PROMPT;
               MemberCardNumber := CopyStr (GetInput (JSON, 'membercard_number'), 1, MaxStrLen (MemberCardNumber));
             end;
          2: MemberCardNumber := ''; //COPYSTR (GetInput (JSON, 'membership_number'), 1, MAXSTRLEN (MemberCardNumber));
          3: DialogMethodType := DialogMethod::FACIAL_RECOGNITION;
          4: if (DefaultInputValue <> '') then
               DialogMethodType := DialogMethod::NO_PROMPT;
          else
            Error ('POS Action: Dialog Prompt with ID %1 is not implemented.', DialogPrompt);
        end;

        JSON.InitializeJObjectParser (Context, FrontEnd);
        POSWorkflowType := JSON.GetIntegerParameter ('POSWorkflow', false);
        if (POSWorkflowType < 0) then
          POSWorkflowType := POSWorkflowMethod::POS;

        JSON.InitializeJObjectParser (Context, FrontEnd);
        AdmissionCode := JSON.GetStringParameter ('Admission Code', false);

        JSON.InitializeJObjectParser (Context, FrontEnd);
        ConfirmMember := JSON.GetBooleanParameter ('ConfirmMember', true);

        if (DefaultInputValue <> '') then
          MemberCardNumber := DefaultInputValue;

        if (WorkflowStep = '9') then
          MemberArrival (POSSession, DialogMethodType, POSWorkflowType, ConfirmMember, MemberCardNumber, AdmissionCode);

        Handled := true;
    end;

    local procedure "--Workers"()
    begin
    end;

    local procedure MemberArrival(POSSession: Codeunit "POS Session";InputMethod: Option;POSWorkflowType: Option;ConfirmMember: Boolean;ExternalMemberCardNo: Text[100];AdmissionCode: Code[20])
    var
        Member: Record "MM Member";
        Membership: Record "MM Membership";
        MemberCard: Record "MM Member Card";
        MembershipSetup: Record "MM Membership Setup";
        ThisShouldBeEmpty_SaleLinePOS: Record "Sale Line POS";
        MemberRetailIntegration: Codeunit "MM Member Retail Integration";
        MemberLimitationMgr: Codeunit "MM Member Limitation Mgr.";
        POSActionMemberManagement: Codeunit "MM POS Action - Member Mgmt.";
        MemberTicketManager: Codeunit "MM Member Ticket Manager";
        MembershipManagement: Codeunit "MM Membership Management";
        ExternalItemNo: Code[20];
        ResponseMessage: Text;
        ResponseCode: Integer;
        Token: Text[100];
        Parameter: Code[20];
    begin

        if (InputMethod = DialogMethod::NO_PROMPT) and (ExternalMemberCardNo = '') then
          if (not SelectMemberCardUI (ExternalMemberCardNo)) then
            Error (MEMBER_REQUIRED);

        case POSWorkflowType of
          POSWorkflowMethod::POS : POSActionMemberManagement.MemberArrival (POSSession, InputMethod, ExternalMemberCardNo);
          POSWorkflowMethod::Automatic,
          POSWorkflowMethod::GuestCheckin :
            begin
              MemberRetailIntegration.POS_ValidateMemberCardNo (true, ConfirmMember, InputMethod, true, ExternalMemberCardNo);

              MemberLimitationMgr.POS_CheckLimitMemberCardArrival (ExternalMemberCardNo, AdmissionCode, 'POS', ResponseMessage, ResponseCode);
              if (ResponseCode <> 0) then
                Error (ResponseMessage);

              MemberCard.Get (MembershipManagement.GetCardEntryNoFromExtCardNo (ExternalMemberCardNo));
              Membership.Get (MemberCard."Membership Entry No.");
              MembershipSetup.Get (Membership."Membership Code");

              POSActionMemberManagement.OnBeforePOSMemberArrival (ThisShouldBeEmpty_SaleLinePOS, MembershipSetup."Community Code", MembershipSetup.Code, Membership."Entry No.", Member."Entry No.", MemberCard."Entry No.", ExternalMemberCardNo);

              ExternalItemNo := MemberRetailIntegration.POS_GetExternalTicketItemFromMembership (ExternalMemberCardNo);

              if (POSWorkflowType = POSWorkflowMethod::Automatic) then
                MemberTicketManager.MemberFastCheckIn (ExternalMemberCardNo, ExternalItemNo, AdmissionCode, 1);

              if (POSWorkflowType = POSWorkflowMethod::GuestCheckin) then begin
                MemberTicketManager.PromptForMemberGuestArrival (ExternalMemberCardNo, AdmissionCode);
                MemberTicketManager.MemberFastCheckIn (ExternalMemberCardNo, ExternalItemNo, AdmissionCode, 1);
              end;

            end;
        end;
    end;

    local procedure GetInput(JSON: Codeunit "POS JSON Management";Path: Text): Text
    begin

        if (not JSON.SetScopeRoot (false)) then
          exit ('');

        if (not JSON.SetScope ('$'+Path, false)) then
          exit ('');

        exit (JSON.GetString ('input', false));
    end;

    local procedure SelectMemberCardUI(var ExtMemberCardNo: Text[100]): Boolean
    var
        MemberCard: Record "MM Member Card";
    begin

        if (ACTION::LookupOK <> PAGE.RunModal (0, MemberCard)) then
          exit (false);

        ExtMemberCardNo := MemberCard."External Card No.";
        exit (ExtMemberCardNo <> '');
    end;

    local procedure "--- Ean Box Event Handling"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "Ean Box Event")
    var
        MMMember: Record "MM Member";
        MMMemberCard: Record "MM Member Card";
        MMMembership: Record "MM Membership";
    begin
        //-MM1.33 [326754]
        if not EanBoxEvent.Get(EventCodeExtMemberCardNo()) then begin
          EanBoxEvent.Init;
          EanBoxEvent.Code := EventCodeExtMemberCardNo();
          EanBoxEvent."Module Name" := 'Membership Management';
          //-MM1.37 [350288]
          //EanBoxEvent.Description := MMMemberCard.FIELDCAPTION("External Card No.");
          EanBoxEvent.Description := CopyStr(MMMemberCard.FieldCaption("External Card No."),1,MaxStrLen(EanBoxEvent.Description));
          //+MM1.37 [350288]
          EanBoxEvent."Action Code" := ActionCode();
          EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
          EanBoxEvent."Event Codeunit" := CurrCodeunitId();
          EanBoxEvent.Insert(true);
        end;
        //+MM1.33 [326754]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "Ean Box Setup Mgt.";EanBoxEvent: Record "Ean Box Event")
    begin
        //-MM1.33 [326754]
        case EanBoxEvent.Code of
          EventCodeExtMemberCardNo():
            begin
              Sender.SetNonEditableParameterValues(EanBoxEvent,'DefaultInputValue',true,'');
              Sender.SetNonEditableParameterValues(EanBoxEvent,'DialogPrompt',false,'No Prompt');
              Sender.SetNonEditableParameterValues(EanBoxEvent,'Function',false,'Member Arrival');
            end;
        end;
        //+MM1.33 [326754]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060107, 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeMemberCardNo(EanBoxSetupEvent: Record "Ean Box Setup Event";EanBoxValue: Text;var InScope: Boolean)
    var
        MMMemberCard: Record "MM Member Card";
    begin
        //-MM1.33 [326754]
        if EanBoxSetupEvent."Event Code" <> EventCodeExtMemberCardNo() then
          exit;
        if StrLen(EanBoxValue) > MaxStrLen(MMMemberCard."External Card No.") then
          exit;

        MMMemberCard.SetRange("External Card No.",UpperCase(EanBoxValue));
        if MMMemberCard.FindFirst then
          InScope := true;
        //+MM1.33 [326754]
    end;

    local procedure EventCodeExtMemberCardNo(): Code[20]
    begin
        //-MM1.33 [326754]
        exit('MEMBER_ARRIVAL');
        //+MM1.33 [326754]
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        //-MM1.33 [326754]
        exit(CODEUNIT::"MM POS Action - Member Arrival");
        //+MM1.33 [326754]
    end;
}

