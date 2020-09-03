codeunit 6060138 "NPR MM POS Action: MemberMgmt."
{
    // NPR5.30/TSA/20161213  CASE 260817 Initial version for Transcendence compliance
    // NPR5.32/NPKNAV/20170526  CASE 270909 Transport NPR5.32 - 26 May 2017
    // MM1.22/TSA /20170721 CASE 284653 Added POS_CheckLimitMemberCardArrival in MemberArrival();
    // MM1.22/TSA /20170817 CASE 287080 Made an exception to qty change for anonymous member item sales
    // MM1.22/TSA /20170901 CASE 288919 Refactored AddItemToPOS to update Member Info Capture with correct receipt no and line
    // MM1.22/TSA /20170908 CASE 289169 Added Edit Membership function
    // MM1.25/TSA /20171011 CASE 257011 Adding support for MM POS Sales Info table
    // MM1.25/TSA /20171014 CASE 257011 Changed assignment of CustomerNo when selecting membership
    // MM1.25/TSA /20171129 CASE 298110 Added DeletePreEmptiveMembership in the OnDelete subscriber for membership sales delete
    // MM1.26/TSA /20180124 CASE 299690 Show Member Card
    // MM1.27/TSA /20180323 CASE 307113 Member Arrival consider named / anonymous member
    // MM1.28/TSA /20180409 CASE 310148 Added IsTemporary check in OnAfterInsertPOSSaleLine(),OnBeforeDeletePOSSaleLine(),OnBeforeSetQuantity()
    // MM1.28/TSA /20180323 CASE 307113 Added publisher OnAfterPOSMemberArrival
    // MM1.29/TSA /20180503 CASE 313585 UnitPrice must remain positive when downgrading
    // MM1.31/MHA /20180619 CASE 319425 Added OnAfterInsertSaleLine POS Sales Workflow
    // MM1.32/TSA /20180710 CASE 319477 Enhanced error handling since sale line is commited before sales workflow starts
    // MM1.33/TSA /20180725 CASE 320446 Added Description2 value on Membership Alterations
    // MM1.33/TSA /20180801 CASE 323744 Added DefaultInputValue parameter for EAN box support
    // MM1.33.01/TSA /20180912 CASE 328398 Fixed external to internal item number convert
    // MM1.36/TSA /20181112 CASE 335828 New function for show member card
    // MM1.40/TSA /20190730 CASE 360275 Added Auto-Admit for renew, upgrade, extend
    // MM1.41/TSA /20190918 CASE 368608 Add the select member onAfterLogin workflow
    // MM1.41/TSA /20191002 CASE 368608 Adding new action to edit current membership
    // MM1.42/TSA /20200114 CASE 385449 Changed the member lookup on login to show member list rather than member card list due to search limits on pages shown in browser
    // MM1.43/TSA /20200226 CASE 392087 Switching from the POS Member Card page to the full Member Card page after a member is selected after login
    // MM1.44/TSA /20200420 CASE 395991 Changed the listing page when membership card is not provided.
    // MM1.45/ALPO/20200617 CASE 407500 Clear last error before running member selection UI
    // #416870/TSA /20200813 CASE 416870 Added a new subscriber for handling load save sale


    trigger OnRun()
    begin
    end;

    var
        ILLEGAL_VALUE: Label 'Value %1 is not a valid %2.';
        ABORTED: Label 'Aborted.';
        ERRORTITLE: Label 'Error.';
        QTY_CANT_CHANGE: Label 'Changing quantity for membership sales is not possible.';
        ActionDescription: Label 'This action handles member management functions.';
        MemberCardPrompt: Label 'Enter Member Card Number:';
        MemberNumberPrompt: Label 'Enter Member Number:';
        MembershipNumberPrompt: Label 'Enter Membership Number:';
        MembershipTitle: Label '%1 - Membership Management.';
        RENEW_NOT_VALID: Label 'There are no valid renewal products for this membership at this time.';
        EXTEND_NOT_VALID: Label 'There are no valid extend products for this membership at this time.';
        UPGRADE_NOT_VALID: Label 'There are no valid upgrade products for this membership at this time.';
        CANCEL_NOT_VALID: Label 'Membership can''t be canceled with a refund at this time.';
        REGRET_NOT_VALID: Label 'A membership regret rule, explicitly disallows regret at this time.';
        MEMBERSHIP_BLOCKED_NOT_FOUND: Label 'Membership %1 is either blocked or not found.';
        CHANGEMEMBERSHIP_LOOKUP_CAPTION: Label '%1 - %2: %3';
        UI: Codeunit "NPR MM Member POS UI";
        SELECT_PRODUCT: Label 'Select product...';
        DialogMethod: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT;
        MEMBER_REQUIRED: Label 'Member identification must be specified.';
        NOT_MEMBERSHIP_SALES: Label 'The selected sales line is not a membership sales.';
        Text000: Label 'Update Membership metadata on Sale Line Insert';
        ADMIT_MEMBERS: Label 'Do you want to admit the member(s) automatically?';

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
            //-MM1.41 [368608]
            // FunctionOptionString := 'Member Arrival,'+
            //                         'Select Membership,'+
            //                         'View Membership Entry,Regret Membership Entry,'+
            //                         'Renew Membership,Extend Membership,Upgrade Membership,Cancel Membership,Edit Membership,Show Member';
            // FOR N := 1 TO 10 DO
            //   JSArr += STRSUBSTNO ('"%1",', SELECTSTR (N, FunctionOptionString));
            // JSArr := STRSUBSTNO ('var optionNames = [%1];', COPYSTR (JSArr, 1, STRLEN(JSArr)-1));

            FunctionOptionString := 'Member Arrival,' +
                                    'Select Membership,' +
                                    'View Membership Entry,Regret Membership Entry,' +
                                    'Renew Membership,Extend Membership,Upgrade Membership,Cancel Membership,Edit Membership,Show Member,Edit Current Membership';
            for N := 1 to 11 do
                JSArr += StrSubstNo('"%1",', SelectStr(N, FunctionOptionString));
            JSArr := StrSubstNo('var optionNames = [%1];', CopyStr(JSArr, 1, StrLen(JSArr) - 1));
            //+MM1.41 [368608]


            Sender.RegisterWorkflowStep('0', JSArr + 'windowTitle = labels.MembershipTitle.substitute (optionNames[param.Function].toString()); ');

            //-MM1.33 [323744]
            //Sender.RegisterWorkflowStep ('membercard_number',   '(param.DialogPrompt <= 0) && input ({caption: labels.MemberCardPrompt, title: windowTitle}).cancel(abort);');
            Sender.RegisterWorkflowStep('membercard_number', '(param.DefaultInputValue.length == 0) && (param.DialogPrompt <= 0) && input ({caption: labels.MemberCardPrompt, title: windowTitle}).cancel(abort);');
            //+MM1.33 [323744]

            //Sender.RegisterWorkflowStep ('member_number',       '(param.DialogPrompt == 3xx) && input ({caption: labels.MemberNumberPrompt, title: labels.MembershipTitle}).cancel(abort);');
            //Sender.RegisterWorkflowStep ('membership_number',   '(param.DialogPrompt == 4xx) && input ({caption: labels.MembershipNumberPrompt, title: labels.MembershipTitle}).cancel(abort);');

            Sender.RegisterWorkflowStep('9', 'respond ();');
            Sender.RegisterWorkflow(false);

            Sender.RegisterOptionParameter('Function', FunctionOptionString, 'Member Arrival');
            Sender.RegisterOptionParameter('DialogPrompt', 'Member Card Number,Facial Recognition,No Dialog', 'Member Card Number');

            //-MM1.33 [323744]
            Sender.RegisterTextParameter('DefaultInputValue', '');
            //+MM1.33 [323744]

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode, 'MemberCardPrompt', MemberCardPrompt);
        Captions.AddActionCaption(ActionCode, 'MemberNumberPrompt', MemberNumberPrompt);
        Captions.AddActionCaption(ActionCode, 'MembershipNumberPrompt', MembershipNumberPrompt);
        Captions.AddActionCaption(ActionCode, 'MembershipTitle', MembershipTitle);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', true, true)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        Membership: Record "NPR MM Membership";
        FunctionId: Integer;
        MemberCardNumber: Text[100];
        MembershipEntryNo: Integer;
        DialogPrompt: Integer;
        DialogMethodType: Option;
        DefaultInputValue: Text;
    begin

        if (not Action.IsThisAction(ActionCode())) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        FunctionId := JSON.GetIntegerParameter('Function', true);
        if (FunctionId < 0) then
            FunctionId := 0;

        //-MM1.33 [323744]
        DefaultInputValue := JSON.GetStringParameter('DefaultInputValue', true);
        //+MM1.33 [323744]

        DialogPrompt := JSON.GetIntegerParameter('DialogPrompt', true);
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

        //-MM1.33 [323744]
        if (DefaultInputValue <> '') then
            MemberCardNumber := CopyStr(DefaultInputValue, 1, MaxStrLen(MemberCardNumber));
        //+MM1.33 [323744]

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
                //-MM1.41 [368608]
                10:
                    EditActiveMembership(POSSession, DialogMethodType, MemberCardNumber);
                //+MM1.41 [368608]
                else
                    Error('POS Action: Function with ID %1 is not implemented.', FunctionId);
            end;
        end;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150706, 'OnAfterInsertSaleLine', '', true, true)]
    local procedure UpdateMembershipOnSaleLineInsert(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SaleLinePOS: Record "NPR Sale Line POS")
    var
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        ReturnCode: Integer;
    begin
        //-MM1.31 [319425]
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;

        if POSSalesWorkflowStep."Subscriber Function" <> 'UpdateMembershipOnSaleLineInsert' then
            exit;
        //+MM1.31 [319425]

        if (SaleLinePOS.IsTemporary) then
            exit;

        ReturnCode := MemberRetailIntegration.NewMemberSalesInfoCapture(SaleLinePOS);
        if (ReturnCode < 0) then
            if (ReturnCode <> -1102) then
                Message('%1', MemberRetailIntegration.GetErrorText(ReturnCode));
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150706, 'OnBeforeDeletePOSSaleLine', '', true, true)]
    local procedure OnBeforeDeletePOSSaleLine(SaleLinePOS: Record "NPR Sale Line POS")
    var
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
    begin
        if (SaleLinePOS.IsTemporary) then
            exit;

        //-MM1.25 [298110]
        MemberRetailIntegration.DeletePreemptiveMembership(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.");
        //+MM1.25 [298110]

        DeleteMemberInfoCapture(SaleLinePOS);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150706, 'OnBeforeSetQuantity', '', true, true)]
    local procedure OnBeforeSetQuantity(SaleLinePOS: Record "NPR Sale Line POS"; var NewQuantity: Decimal)
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MemberManagement: Codeunit "NPR MM Membership Mgt.";
    begin

        if (SaleLinePOS.IsTemporary) then
            exit;

        MemberInfoCapture.SetCurrentKey("Receipt No.", "Line No.");
        MemberInfoCapture.SetFilter("Receipt No.", '=%1', SaleLinePOS."Sales Ticket No.");
        MemberInfoCapture.SetFilter("Line No.", '=%1', SaleLinePOS."Line No.");

        //-#287080 [287080]
        // IF (MemberInfoCapture.FINDFIRST ()) THEN
        //  IF (SaleLinePOS."No." = MemberInfoCapture."Item No.") THEN
        //    ERROR (QTY_CANT_CHANGE);

        if (MemberInfoCapture.FindFirst()) then begin
            if (SaleLinePOS."No." = MemberInfoCapture."Item No.") then begin
                if (MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, MemberInfoCapture."Item No.")) then;
                case MembershipSalesSetup."Business Flow Type" of
                    MembershipSalesSetup."Business Flow Type"::ADD_ANONYMOUS_MEMBER:
                        begin
                            MemberManagement.AddAnonymousMember(MemberInfoCapture, NewQuantity);
                            asserterror Error(''); // force a rollback, membercreation will be redone at checkout
                        end;
                    else
                        Error(QTY_CANT_CHANGE);
                end;
            end;
        end;
        //+#287080 [287080]
    end;

    local procedure "--Workers"()
    begin
    end;

    procedure MemberArrival(POSSession: Codeunit "NPR POS Session"; InputMethod: Option; ExternalMemberCardNo: Text[100])
    var
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        ExternalItemNo: Code[20];
        SaleLinePOS: Record "NPR Sale Line POS";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        Member: Record "NPR MM Member";
        Membership: Record "NPR MM Membership";
        MemberCard: Record "NPR MM Member Card";
        ResponseMessage: Text;
        ResponseCode: Integer;
        MemberLimitationMgr: Codeunit "NPR MM Member Lim. Mgr.";
        MembershipSetup: Record "NPR MM Membership Setup";
        ItemDescription: Text;
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin

        if (InputMethod = DialogMethod::NO_PROMPT) and (ExternalMemberCardNo = '') then
            if (not SelectMemberCardUI(ExternalMemberCardNo)) then
                Error(MEMBER_REQUIRED);

        MemberRetailIntegration.POS_ValidateMemberCardNo(true, true, InputMethod, true, ExternalMemberCardNo);

        //-#284653 [284653]
        MemberLimitationMgr.POS_CheckLimitMemberCardArrival(ExternalMemberCardNo, '', 'POS', ResponseMessage, ResponseCode);
        if (ResponseCode <> 0) then
            Error(ResponseMessage);
        //+#284653 [284653]

        //-#307113 [307113] refactored
        // Membership.GET (MembershipManagement.GetMembershipFromExtCardNo (ExternalMemberCardNo, TODAY, ResponseMessage));
        // Membership.GET (MemberCard."Membership Entry No.");
        // MembershipSetup.GET (Membership."Membership Code");

        MemberCard.Get(MembershipManagement.GetCardEntryNoFromExtCardNo(ExternalMemberCardNo));
        Membership.Get(MemberCard."Membership Entry No.");
        MembershipSetup.Get(Membership."Membership Code");

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(SaleLinePOS);

        Commit;
        OnBeforePOSMemberArrival(SaleLinePOS, MembershipSetup."Community Code", MembershipSetup.Code, Membership."Entry No.", Member."Entry No.", MemberCard."Entry No.", ExternalMemberCardNo);

        ItemDescription := '';
        OnCustomItemDescription(MembershipSetup."Community Code", MembershipSetup.Code, MemberCard."Entry No.", ItemDescription);

        //-#328398 [328398]
        //ItemNo := MemberRetailIntegration.POS_GetExternalTicketItemFromMembership (ExternalMemberCardNo);
        //AddItemToPOS (POSSession, 0, ItemNo, COPYSTR (ItemDescription, 1, MAXSTRLEN (SaleLinePOS.Description)), STRSUBSTNO ('%1/%2',Membership."External Membership No.", ExternalMemberCardNo), 1, 0, SaleLinePOS);
        ExternalItemNo := MemberRetailIntegration.POS_GetExternalTicketItemFromMembership(ExternalMemberCardNo);
        AddItemToPOS(POSSession, 0, ExternalItemNo, CopyStr(ItemDescription, 1, MaxStrLen(SaleLinePOS.Description)), StrSubstNo('%1/%2', Membership."External Membership No.", ExternalMemberCardNo), 1, 0, SaleLinePOS);
        //+#328398 [328398]

        case MembershipSetup."Member Information" of
            MembershipSetup."Member Information"::ANONYMOUS:
                begin
                    Clear(Member);
                    UpdatePOSSalesInfo(SaleLinePOS, Membership."Entry No.", 0, MemberCard."Entry No.", ExternalMemberCardNo);
                    OnAssociateSaleWithMember(POSSession, Membership."External Membership No.", CopyStr(ExternalMemberCardNo, 1, MaxStrLen(Member."External Member No.")));
                end;

            MembershipSetup."Member Information"::NAMED:
                begin
                    Member.Get(MembershipManagement.GetMemberFromExtCardNo(ExternalMemberCardNo, Today, ResponseMessage));
                    UpdatePOSSalesInfo(SaleLinePOS, Membership."Entry No.", Member."Entry No.", MemberCard."Entry No.", ExternalMemberCardNo);
                    OnAssociateSaleWithMember(POSSession, Membership."External Membership No.", Member."External Member No.");
                end;
        end;



        // Member.GET (MembershipManagement.GetMemberFromExtCardNo (ExternalMemberCardNo, TODAY, ResponseMessage));
        // Membership.GET (MembershipManagement.GetMembershipFromExtCardNo (ExternalMemberCardNo, TODAY, ResponseMessage));
        // UpdatePOSSalesInfo (SaleLinePOS, Membership."Entry No.", Member."Entry No.", 0, ExternalMemberCardNo);
        //
        // OnAssociateSaleWithMember (POSSession, Membership."External Membership No.", Member."External Member No.");
        //+#307113 [307113]
    end;

    procedure SelectMembership(POSSession: Codeunit "NPR POS Session"; InputMethod: Option; var ExternalMemberCardNo: Text[100]) MembershipSelected: Boolean
    var
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        POSSale: Codeunit "NPR POS Sale";
        ItemNo: Code[20];
        SaleLinePOS: Record "NPR Sale Line POS";
        SalePOS: Record "NPR Sale POS";
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
        SaleLinePOS: Record "NPR Sale Line POS";
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
        SaleLinePOS: Record "NPR Sale Line POS";
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

        //-MM1.40 [360275]
        if (MembershipAlterationSetup."Auto-Admit Member On Sale" = MembershipAlterationSetup."Auto-Admit Member On Sale"::ASK) then
            if (Confirm(ADMIT_MEMBERS, true)) then
                MemberInfoCapture."Auto-Admit Member" := true;

        if (MembershipAlterationSetup."Auto-Admit Member On Sale" = MembershipAlterationSetup."Auto-Admit Member On Sale"::YES) then
            MemberInfoCapture."Auto-Admit Member" := true;

        MemberInfoCapture.Modify();
        //+MM1.40 [360275]

        AddItemToPOS(POSSession, MemberInfoEntryNo, ItemNo, MembershipAlterationSetup.Description, ExternalMemberCardNo, 1, MemberInfoCapture."Unit Price", SaleLinePOS);
    end;

    local procedure UpgradeMembership(POSSession: Codeunit "NPR POS Session"; InputMethod: Option; ExternalMemberCardNo: Text[100])
    var
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        SaleLinePOS: Record "NPR Sale Line POS";
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
        SaleLinePOS: Record "NPR Sale Line POS";
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
        SaleLinePOS: Record "NPR Sale Line POS";
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
        TmpRetailList: Record "NPR Retail List" temporary;
        LookupRecRef: RecordRef;
        MembershipEntryNo: Integer;
        ReasonNotFound: Text;
        LineNo: Integer;
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
                LineNo += 1;
                TmpRetailList.Number := LineNo;
                TmpRetailList.Choice := StrSubstNo('%1: (%2) period %3 => %4', DT2Date(MembershipEntry."Created At"), MembershipEntry.Context, MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date");
                TmpRetailList.Value := MembershipEntry."Item No.";
                TmpRetailList.Insert();
            until (MembershipEntry.Next() = 0);

            LookupRecRef.GetTable(TmpRetailList);
            UI.DoLookup(SELECT_PRODUCT, LookupRecRef);
        end;
    end;

    local procedure AssignPOSMembership(var SalePOS: Record "NPR Sale POS"; var ExternalMemberCardNo: Text[100]): Boolean
    var
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        ReasonNotFound: Text;
        MembershipEntryNo: Integer;
    begin

        if (ExternalMemberCardNo = '') then
            if (not SelectMemberCardUI(ExternalMemberCardNo)) then
                exit(false);

        MembershipEntryNo := MembershipManagement.GetMembershipFromExtCardNo(ExternalMemberCardNo, Today, ReasonNotFound);

        //-MM1.42 [385449] refactored into local function
        if (MembershipEntryNo = 0) then
            Error(ReasonNotFound);

        exit(AssignMembershipToPOSWorker(SalePOS, MembershipEntryNo, ExternalMemberCardNo));
        //+MM1.42 [385449]
    end;

    local procedure AssignPOSMember(var SalePOS: Record "NPR Sale POS"; var ExternalMemberNo: Code[20]): Boolean
    var
        Membership: Record "NPR MM Membership";
        MemberCard: Record "NPR MM Member Card";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        ReasonNotFound: Text;
        MemberEntryNo: Integer;
        MembershipEntryNo: Integer;
        ExternalMemberCardNo: Text;
    begin

        //-MM1.42 [385449]
        if (ExternalMemberNo = '') then
            if (not SelectMemberUI(ExternalMemberNo)) then
                exit(false);

        MemberEntryNo := MembershipManagement.GetMemberFromExtMemberNo(ExternalMemberNo);

        if (Membership.Get(MembershipManagement.GetMembershipFromExtMemberNo(ExternalMemberNo))) then
            if (MemberCard.Get(MembershipManagement.GetMemberCardEntryNo(MemberEntryNo, Membership."Membership Code", Today))) then
                ExternalMemberCardNo := MemberCard."External Card No.";

        exit(AssignMembershipToPOSWorker(SalePOS, Membership."Entry No.", ExternalMemberCardNo));
        //+MM1.42 [385449]
    end;

    local procedure AssignMembershipToPOSWorker(var SalePOS: Record "NPR Sale POS"; MembershipEntryNo: Integer; ExternalMemberCardNo: Text[200]): Boolean
    var
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        Membership: Record "NPR MM Membership";
        POSSalesInfo: Record "NPR MM POS Sales Info";
        MembershipSetup: Record "NPR MM Membership Setup";
    begin

        //-MM1.42 [385449]
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
        //+MM1.42 [385449]
    end;

    local procedure UpdatePOSSalesInfo(var SaleLinePOS: Record "NPR Sale Line POS"; MembershipEntryNo: Integer; MemberEntryNo: Integer; MembercardEntryNo: Integer; ScannedCardData: Text[200])
    var
        POSSalesInfo: Record "NPR MM POS Sales Info";
    begin

        //-MM1.25 [257011]
        //-#307113 [307113]
        //IF (NOT POSSalesInfo.GET (POSSalesInfo."Association Type"::HEADER, SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.")) THEN BEGIN
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
        //+MM1.25 [257011]
    end;

    local procedure EditMembership(POSSession: Codeunit "NPR POS Session"; InputMethod: Option; ExternalMemberCardNo: Text[100])
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        SaleLinePOS: Record "NPR Sale Line POS";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin

        //-MM1.22 [289169]
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

        //+MM1.22 [289169]
    end;

    local procedure EditActiveMembership(POSSession: Codeunit "NPR POS Session"; InputMethod: Option; ExternalMemberCardNo: Text[100])
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR Sale POS";
        Membership: Record "NPR MM Membership";
    begin

        //-MM1.41 [368608]
        POSSession.GetSale(POSSale);
        POSSale.RefreshCurrent();
        POSSale.GetCurrentSale(SalePOS);

        if (SalePOS."Customer No." = '') then
            exit;

        Membership.SetFilter("Customer No.", '=%1', SalePOS."Customer No.");
        if (not Membership.FindFirst()) then
            exit;

        PAGE.RunModal(PAGE::"NPR MM Membership Card", Membership);
        //+MM1.41 [368608]
    end;

    procedure ShowMember(POSSession: Codeunit "NPR POS Session"; InputMethod: Option; var ExternalMemberCardNo: Text[100])
    var
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
    begin

        if (ExternalMemberCardNo = '') then
            if (not SelectMemberCardUI(ExternalMemberCardNo)) then
                exit;

        //-MM1.36 [335828]
        //MemberRetailIntegration.POS_ValidateMemberCardNo (TRUE, TRUE, InputMethod, FALSE, ExternalMemberCardNo);
        MemberRetailIntegration.POS_ShowMemberCard(InputMethod, ExternalMemberCardNo);
        //+MM1.36 [335828]
    end;

    local procedure "--Helpers"()
    begin
    end;

    local procedure GetInput(JSON: Codeunit "NPR POS JSON Management"; Path: Text): Text
    begin

        JSON.SetScope('/', true);
        if (not JSON.SetScope('$' + Path, false)) then
            exit('');

        exit(JSON.GetString('input', false));
    end;

    local procedure AddItemToPOS(POSSession: Codeunit "NPR POS Session"; MemberInfoEntryNo: Integer; ExternalItemNo: Code[20]; Description: Text[80]; Description2: Text[80]; Quantity: Decimal; UnitPrice: Decimal; var SaleLinePOS: Record "NPR Sale Line POS")
    var
        Line: Record "NPR Sale Line POS";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        ItemNo: Code[20];
        VariantCode: Code[10];
        Resolver: Integer;
    begin

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(Line);
        DeleteMemberInfoCapture(Line); // If I somehow reused an existing entry, delete it. (New entry does not have receipt number set yet)

        //-#328398 [328398]
        if (not MemberRetailIntegration.TranslateBarcodeToItemVariant(ExternalItemNo, ItemNo, VariantCode, Resolver)) then
            ItemNo := ExternalItemNo;
        //+#328398 [328398]

        Line.Type := Line.Type::Item;
        Line."No." := ItemNo;

        //-#328398 [328398]
        Line."Variant Code" := VariantCode;
        //+#328398 [328398]

        Line.Description := Description;
        Line.Quantity := Abs(Quantity);
        if (UnitPrice < 0) then
            Line.Quantity := -1 * Abs(Quantity);
        //-MM1.29 [313585]
        //Line."Unit Price" := UnitPrice;
        Line."Unit Price" := Abs(UnitPrice);
        //+MM1.29 [313585]


        // update info entry with this receipt number
        if (MemberInfoEntryNo <> 0) then
            SetReceiptReference(MemberInfoEntryNo, Line."Sales Ticket No.", Line."Line No.");

        POSSaleLine.InsertLine(Line);

        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLinePOS.Validate("Unit Price", Abs(UnitPrice));

        //-MM1.33 [320446]
        SaleLinePOS."Description 2" := CopyStr(Description2, 1, MaxStrLen(SaleLinePOS."Description 2"));
        //+MM1.33 [320446]

        SaleLinePOS.Modify();

        POSSession.RequestRefreshData();
    end;

    local procedure DeleteMemberInfoCapture(SaleLinePOS: Record "NPR Sale Line POS")
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
    begin

        MemberInfoCapture.SetFilter("Receipt No.", '=%1', SaleLinePOS."Sales Ticket No.");
        MemberInfoCapture.SetFilter("Line No.", '=%1', SaleLinePOS."Line No.");
        if (MemberInfoCapture.IsEmpty()) then
            exit;

        //-MM1.25 [298110]

        MemberInfoCapture.DeleteAll();
    end;

    local procedure ShowAlterMembershipItemSelection(Type: Option; ExternalCardNo: Text[100]; ReferenceDate: Date; NotValidMessage: Text) SalesItemNo: Code[20]
    var
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        Membership: Record "NPR MM Membership";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
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

    local procedure GetAlterMembershipItemSelection(Type: Option; ExternalCardNo: Text[100]; ReferenceDate: Date; NotValidMessage: Text) SalesItemNo: Code[20]
    var
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        Membership: Record "NPR MM Membership";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
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

    local procedure DoLookupRetailList(var TmpRetailList: Record "NPR Retail List" temporary) ItemNo: Code[20]
    var
        LookupRecRef: RecordRef;
        LineNo: Integer;
        Position: Text;
    begin
        ItemNo := '';

        LookupRecRef.GetTable(TmpRetailList);
        // ConfigureLookupTemplate (Template, LookupRecRef);
        // Position := Marshaller.Lookup(SELECT_PRODUCT, Template, LookupRecRef);
        Position := UI.DoLookup(SELECT_PRODUCT, LookupRecRef);

        if (Position <> '') then begin
            LookupRecRef.SetPosition(Position);
            if (LookupRecRef.Find()) then begin
                LookupRecRef.SetTable(TmpRetailList);
                ItemNo := TmpRetailList.Value;
            end;
        end;

        exit(ItemNo);
    end;

    local procedure DoLookupMembershipEntry(LookupCaption: Text; var TmpMembershipEntry: Record "NPR MM Membership Entry" temporary) ItemNo: Code[20]
    var
        LookupRecRef: RecordRef;
        LineNo: Integer;
        Position: Text;
    begin
        ItemNo := '';

        LookupRecRef.GetTable(TmpMembershipEntry);
        //ConfigureLookupTemplate (Template, LookupRecRef);
        //Position := Marshaller.Lookup(LookupCaption, Template, LookupRecRef);
        Position := UI.DoLookup(LookupCaption, LookupRecRef);

        if (Position <> '') then begin
            LookupRecRef.SetPosition(Position);
            if (LookupRecRef.Find()) then begin
                LookupRecRef.SetTable(TmpMembershipEntry);
                ItemNo := TmpMembershipEntry."Item No.";
            end;
        end;

        exit(ItemNo);
    end;

    local procedure SelectMembershipUI(var ExtMembershipNo: Text[100]): Boolean
    var
        Membership: Record "NPR MM Membership";
    begin

        if (ACTION::LookupOK <> PAGE.RunModal(0, Membership)) then
            exit(false);

        ExtMembershipNo := Membership."External Membership No.";
        exit(ExtMembershipNo <> '');
    end;

    local procedure SelectMemberCardUI(var ExtMemberCardNo: Text[100]): Boolean
    var
        MemberCard: Record "NPR MM Member Card";
    begin

        //-MM1.44 [395991]
        // IF (ACTION::LookupOK <> PAGE.RUNMODAL (0, MemberCard)) THEN
        //  EXIT (FALSE);
        //
        // ExtMemberCardNo := MemberCard."External Card No.";
        // EXIT (ExtMemberCardNo <> '');

        exit(SelectMemberCardViaMemberUI(ExtMemberCardNo));
        //+MM1.44 [395991]
    end;

    local procedure SelectMemberUI(var ExtMemberNo: Code[20]): Boolean
    var
        Member: Record "NPR MM Member";
    begin

        //-MM1.42 [385449]
        if (ACTION::LookupOK <> PAGE.RunModal(0, Member)) then
            exit(false);

        ExtMemberNo := Member."External Member No.";
        exit(ExtMemberNo <> '');
        //+MM1.42 [385449]
    end;

    local procedure SelectMemberCardViaMemberUI(var ExtMemberCardNo: Text[100]): Boolean
    var
        Member: Record "NPR MM Member";
        MemberCard: Record "NPR MM Member Card";
        MemberCardList: Page "NPR MM Member Card List";
        ExtMemberNo: Code[20];
    begin

        //-MM1.44 [395991]
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

        //+MM1.44 [395991]
    end;

    local procedure "--- Publisher"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAssociateSaleWithMember(POSSession: Codeunit "NPR POS Session"; ExternalMembershipNo: Code[20]; ExternalMemberNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforePOSMemberArrival(SaleLinePOS: Record "NPR Sale Line POS"; CommunityCode: Code[20]; MembershipCode: Code[20]; MembershipEntryNo: Integer; MemberEntryNo: Integer; MemberCardEntryNo: Integer; ScannedCardNumber: Text[100])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCustomItemDescription(CommunityCode: Code[20]; MembershipCode: Code[20]; MemberCardEntryNo: Integer; var NewDescription: Text)
    begin
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
        POSSalesInfo2: Record "NPR MM POS Sales Info";
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

        //-MM1.25 [257011]
        if (POSSalesInfo.Get(POSSalesInfo."Association Type"::HEADER, OriginalSalesTicketNo, 0)) then begin
            POSSalesInfo."Receipt No." := NewSalesTicketNo;
            if not (POSSalesInfo.Insert()) then;
        end;

        POSSalesInfo.SetFilter("Association Type", '=%1', POSSalesInfo."Association Type"::LINE);
        POSSalesInfo.SetFilter("Receipt No.", '=%1', OriginalSalesTicketNo);
        if (POSSalesInfo.FindSet()) then begin
            repeat
                POSSalesInfo."Receipt No." := NewSalesTicketNo;
                if (not POSSalesInfo.Insert()) then;
            until (POSSalesInfo.Next() = 0);
        end;
        //+MM1.25 [257011]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151005, 'OnAfterLoadFromQuote', '', true, true)]
    local procedure OnBeforeLoadSavedSaleSubscriber(POSQuoteEntry: Record "NPR POS Quote Entry"; var SalePOS: Record "NPR Sale POS")
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberInfoCapture2: Record "NPR MM Member Info Capture";
        POSSalesInfo: Record "NPR MM POS Sales Info";
        POSSalesInfo2: Record "NPR MM POS Sales Info";
        OriginalSalesTicketNo: Code[20];
        NewSalesTicketNo: Code[20];
    begin

        //-#416870 [416870]
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

        //-MM1.25 [257011]
        if (POSSalesInfo.Get(POSSalesInfo."Association Type"::HEADER, OriginalSalesTicketNo, 0)) then begin
            POSSalesInfo."Receipt No." := NewSalesTicketNo;
            if not (POSSalesInfo.Insert()) then;
        end;

        POSSalesInfo.SetFilter("Association Type", '=%1', POSSalesInfo."Association Type"::LINE);
        POSSalesInfo.SetFilter("Receipt No.", '=%1', OriginalSalesTicketNo);
        if (POSSalesInfo.FindSet()) then begin
            repeat
                POSSalesInfo."Receipt No." := NewSalesTicketNo;
                if (not POSSalesInfo.Insert()) then;
            until (POSSalesInfo.Next() = 0);
        end;
        //+#416870 [416870]
    end;

    local procedure "--- OnAfterInsertSaleLine Workflow"()
    begin
        //-MM1.31 [319425]
        //+MM1.31 [319425]
    end;

    [EventSubscriber(ObjectType::Table, 6150730, 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "NPR POS Sales Workflow Step"; RunTrigger: Boolean)
    begin
        //-MM1.31 [319425]
        if Rec."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;

        case Rec."Subscriber Function" of
            'UpdateMembershipOnSaleLineInsert':
                begin
                    Rec.Description := Text000;
                    Rec."Sequence No." := 30;
                end;
        end;
        //+MM1.31 [319425]
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        //-MM1.31 [319425]
        exit(CODEUNIT::"NPR MM POS Action: MemberMgmt.");
        //+MM1.31 [319425]
    end;

    local procedure "--POS Workflow"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150728, 'OnAfterLogin', '', true, true)]
    local procedure OnAfterLogin_SelectMemberRequired(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; var POSSession: Codeunit "NPR POS Session")
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        SalePOS: Record "NPR Sale POS";
        Member: Record "NPR MM Member";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        POSSale: Codeunit "NPR POS Sale";
        POSMemberCard: Page "NPR MM POS Member Card";
        POSMemberCardEdit: Page "NPR MM Member Card";
        ExternalMemberCardNo: Text[100];
        ExternalMemberNo: Code[20];
        MembershipSelected: Boolean;
    begin

        //-MM1.41 [368608]
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;

        if POSSalesWorkflowStep."Subscriber Function" <> 'OnAfterLogin_SelectMemberRequired' then
            exit;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find();
        POSSale.Refresh(SalePOS);

        ClearLastError;

        repeat
            //-MM1.42 [385449]
            //  MembershipSelected := FALSE;
            //
            //  IF (ExternalMemberCardNo = '') THEN
            //    IF (NOT SelectMemberCardUI (ExternalMemberCardNo)) THEN
            //      EXIT;
            //
            // IF (MemberRetailIntegration.POS_ValidateMemberCardNo (FALSE, TRUE, DialogMethod::NO_PROMPT, TRUE, ExternalMemberCardNo)) THEN
            //    MembershipSelected := AssignPOSMembership (SalePOS, ExternalMemberCardNo);
            //
            //  IF (NOT MembershipSelected) THEN BEGIN
            //    MESSAGE ('There was an error selecting member %1:\\%2', ExternalMemberCardNo, GETLASTERRORTEXT);
            //    ExternalMemberCardNo := '';
            //  END;

            MembershipSelected := false;

            if (ExternalMemberNo = '') then
                SelectMemberUI(ExternalMemberNo);

            if (Member.Get(MembershipManagement.GetMemberFromExtMemberNo(ExternalMemberNo))) then begin

                //-MM1.44 [395991]
                Clear(POSMemberCardEdit);
                //-MM1.44 [395991]

                //-MM1.43 [392087]
                //  POSMemberCard.LOOKUPMODE (TRUE);
                //  POSMemberCard.SETRECORD (Member);
                //  //POSMemberCard.SetMembershipEntryNo (Membership."Entry No.");
                //
                //  IF (POSMemberCard.RUNMODAL() = ACTION::LookupOK) THEN
                //    MembershipSelected := AssignPOSMember (SalePOS, ExternalMemberNo);

                POSMemberCardEdit.SetRecord(Member);
                POSMemberCardEdit.LookupMode(true);
                ClearLastError;  //MM1.45 [407500]
                if (POSMemberCardEdit.RunModal() = ACTION::LookupOK) then
                    MembershipSelected := AssignPOSMember(SalePOS, ExternalMemberNo);
                //+MM1.43 [392087]

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

        //+MM1.41 [368608]
    end;

    [EventSubscriber(ObjectType::Table, 6150730, 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnAfterLoginDiscovery(var Rec: Record "NPR POS Sales Workflow Step"; RunTrigger: Boolean)
    begin

        //-MM1.41 [368608]
        if Rec."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;

        case Rec."Subscriber Function" of
            'OnAfterLogin_SelectMemberRequired':
                begin
                    Rec.Description := CopyStr('On After Login, Select Member (Required)', 1, MaxStrLen(Rec.Description));
                    Rec."Sequence No." := CurrCodeunitId();
                    Rec.Enabled := false;
                end;
        end;
        //+MM1.41 [368608]
    end;
}

