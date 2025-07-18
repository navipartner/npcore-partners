codeunit 6150947 "NPR POS Action Member Mgt WF3" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        MemberSelectionMethod: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        Action_Description: Label 'This action handles member management functions for workflow 3.0.';
        ParamFunction_CptLbl: Label 'Function';
        ParamFunction_DescLbl: Label 'Specifies the Function used.';
        ParamFunction_OptLbl: Label 'Member Arrival,Select Membership,View Membership Entry,Regret Membership Entry,Renew Membership,Extend Membership,Upgrade Membership,Cancel Membership,Edit Membership,Show Member,Edit Current Membership,Cancel Auto-Renew', Locked = true;
        ParamFunction_OptCptLbl: Label 'Member Arrival,Select Membership,View Membership Entry,Regret Membership Entry,Renew Membership,Extend Membership,Upgrade Membership,Cancel Membership,Edit Membership,Show Member,Edit Current Membership,Cancel Auto-Renew';
        ParamDialogPrompt_CptLbl: Label 'Dialog Prompt';
        ParamDialogPrompt_DescLbl: Label 'Specifies the type of Dialog Prompt';
        ParamDialogPrompt_OptLbl: Label 'Member Card Number,Facial Recognition,No Dialog', Locked = true;
        ParamDialogPrompt_OptCptLbl: Label 'Member Card Number,Facial Recognition,No Dialog';
        ParamAutoAdmit_CptLbl: Label 'Auto-Admit on Alteration';
        ParamAutoAdmit_DescLbl: Label 'Specifies if the member should be admitted after the alteration. Decided by Backend (default) will use the setting from the Alteration Setup.';
        ParamAutoAdmit_OptLbl: Label 'Decided by Backend,No,Yes,Prompt', Locked = true;
        ParamAutoAdmit_OptCptLbl: Label 'Decided by Backend,No,Yes,Prompt';
        MemberCardPromptLbl: Label 'Enter Member Card Number';
        MemberNumberPromptLbl: Label 'Enter Member Number';
        MembershipNumberPromptLbl: Label 'Enter Membership Number';
        DialogTitleLbl: Label '%1 - Membership Management.';
        ParamDefaultInput_CptLbl: Label 'Default Input Value';
        ParamDefaultInput_DescLbl: Label 'Specifies the default value of the Input';
        ParamForeignCommunity_CptLbl: Label 'Foreign Community Code';
        ParamForeignCommunity_DescLbl: Label 'Specifies the Foreign Community Code';
        ToastMessageCaption: Label 'Toast Message Timer';
        ToastMessageDescription: Label 'Specifies the time in seconds the toast message is displayed.';
    begin
        WorkflowConfig.AddActionDescription(Action_Description);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddOptionParameter('Function',
                                        ParamFunction_OptLbl,
#pragma warning disable AA0139
                                        SelectStr(1, ParamFunction_OptLbl),
#pragma warning restore 
                                        ParamFunction_CptLbl,
                                        ParamFunction_DescLbl,
                                        ParamFunction_OptCptLbl);
        WorkflowConfig.AddOptionParameter('DialogPrompt',
                                        ParamDialogPrompt_OptLbl,
#pragma warning disable AA0139
                                        SelectStr(1, ParamDialogPrompt_OptLbl),
#pragma warning restore 
                                        ParamDialogPrompt_CptLbl,
                                        ParamDialogPrompt_DescLbl,
                                        ParamDialogPrompt_OptCptLbl);
        WorkflowConfig.AddTextParameter('DefaultInputValue', '', ParamDefaultInput_CptLbl, ParamDefaultInput_DescLbl);
        WorkflowConfig.AddTextParameter('ForeignCommunityCode', '', ParamForeignCommunity_CptLbl, ParamForeignCommunity_DescLbl);
        WorkflowConfig.AddIntegerParameter('ToastMessageTimer', 15, ToastMessageCaption, ToastMessageDescription);
        WorkflowConfig.AddLabel('MemberCardPrompt', MemberCardPromptLbl);
        WorkflowConfig.AddLabel('MemberNumberPrompt', MemberNumberPromptLbl);
        WorkflowConfig.AddLabel('MembershipNumberPrompt', MembershipNumberPromptLbl);
        WorkflowConfig.AddLabel('DialogTitle', DialogTitleLbl);
        WorkflowConfig.AddOptionParameter('AutoAdmitMember',
                                        ParamAutoAdmit_OptLbl,
#pragma warning disable AA0139
                                        SelectStr(1, ParamAutoAdmit_OptLbl),
#pragma warning restore 
                                        ParamAutoAdmit_CptLbl,
                                        ParamAutoAdmit_DescLbl,
                                        ParamAutoAdmit_OptCptLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        case Step of
            'GetMembershipAlterationLookup':
                FrontEnd.WorkflowResponse(GetMembershipAlterationLookupChoices(Context, POSSession, FrontEnd));
            'DoManageMembership':
                FrontEnd.WorkflowResponse(ManageMembershipAction(Context, POSSession, FrontEnd));
            'CheckMemberInitialized':
                FrontEnd.WorkflowResponse(MemberInitialized());
            else
                exit;
        end;
    end;

    procedure ManageMembershipAction(Context: Codeunit "NPR POS JSON Helper"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management") Response: JsonObject
    var
        FunctionId: Integer;
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        POSActionMemberMgtWF3B: Codeunit "NPR POS Action Member MgtWF3-B";
        FrontEndInputMethod: Option;
        ExternalMemberCardNo: Text[100];
        SelectReq: Boolean;
        ForeignCommunityCode: Code[20];
        MemberCardEntryNo: Integer;
        MemberArrival: Codeunit "NPR POS Action: MM Member ArrB";
        POSMemberSession: Codeunit "NPR POS Member Session";
    begin
        if (not Context.GetIntegerParameter('Function', FunctionId)) then
            FunctionId := 0;

        GetCustomParam(Context, SelectReq);
        GetFrontEndInputs(Context, ExternalMemberCardNo, FrontEndInputMethod);
        ForeignCommunityCode := CopyStr(Context.GetStringParameter('ForeignCommunityCode'), 1, MaxStrLen(ForeignCommunityCode));

        if (ExternalMemberCardNo <> '') then
            POSMemberSession.SetMember(ExternalMemberCardNo);

        case FunctionId of
            0:
                begin
                    MemberCardEntryNo := POSActionMemberMgtWF3B.POSMemberArrival(FrontEndInputMethod, ExternalMemberCardNo, ForeignCommunityCode);
                    MemberArrival.AddToastMemberScannedData(MemberCardEntryNo, 0, Response);
                end;
            1:
                begin
                    MemberCardEntryNo := POSActionMemberMgtWF3B.SelectMembership(FrontEndInputMethod, ExternalMemberCardNo, ForeignCommunityCode, SelectReq);
                    MemberArrival.AddToastMemberScannedData(MemberCardEntryNo, 1, Response);
                end;
            2:
                Response := GetMembershipEntryLookupJson(FrontEndInputMethod, ExternalMemberCardNo);
            3:
                ExecuteMembershipAlteration(Context, MembershipAlterationSetup."Alteration Type"::REGRET, ExternalMemberCardNo);
            4:
                ExecuteMembershipAlteration(Context, MembershipAlterationSetup."Alteration Type"::RENEW, ExternalMemberCardNo);
            5:
                ExecuteMembershipAlteration(Context, MembershipAlterationSetup."Alteration Type"::EXTEND, ExternalMemberCardNo);
            6:
                ExecuteMembershipAlteration(Context, MembershipAlterationSetup."Alteration Type"::UPGRADE, ExternalMemberCardNo);
            7:
                ExecuteMembershipAlteration(Context, MembershipAlterationSetup."Alteration Type"::CANCEL, ExternalMemberCardNo);
            8:
                POSActionMemberMgtWF3B.EditMembership();
            9:
                POSActionMemberMgtWF3B.ShowMember(FrontEndInputMethod, ExternalMemberCardNo, ForeignCommunityCode);
            10:
                POSActionMemberMgtWF3B.EditActiveMembership();
            11:
                POSActionMemberMgtWF3B.CancelAutoRenew(ExternalMemberCardNo);
        end;
        exit(Response);
    end;

    local procedure MemberInitialized() Response: JsonObject
    var
        POSMemberSession: Codeunit "NPR POS Member Session";
        MemberExternalCardNo: Text[100];
    begin
        if not POSMemberSession.IsInitialized() then
            exit;

        MemberExternalCardNo := POSMemberSession.GetMemberCardExternalCardNo();
        Response.Add('memberExternalCardNo', MemberExternalCardNo);
    end;

    local procedure GetMembershipEntryLookupJson(FrontEndInputMethod: Option; ExternalMemberCardNo: Text[100]) LookupProperties: JsonObject;
    var
        MembershipEntry: Record "NPR MM Membership Entry";
        Membership: Record "NPR MM Membership";
        MemberCard: Record "NPR MM Member Card";
        POSActionMemberMgtWF3B: Codeunit "NPR POS Action Member MgtWF3-B";

        MembershipEntries: JsonArray;
        MEMBERSHIP_ENTRIES: Label 'Membership Entries.';
    begin
        POSActionMemberMgtWF3B.GetMembershipFromCardNumberWithUI(FrontEndInputMethod, ExternalMemberCardNo, Membership, MemberCard, false);

        MembershipEntry.SetCurrentKey("Entry No.");
        MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        MembershipEntry.Ascending(false);

        MembershipEntries.ReadFrom('[]');
        if (MembershipEntry.FindSet()) then begin
            repeat
                MembershipEntries.Add(GetMembershipEntryLookupDataToJson(MembershipEntry))
            until (MembershipEntry.Next() = 0);
        end;

        LookupProperties.Add('title', MEMBERSHIP_ENTRIES);
        LookupProperties.Add('data', MembershipEntries);
        LookupProperties.Add('layout', GetMembershipEntryLayout());
    end;

    local procedure ExecuteMembershipAlteration(Context: Codeunit "NPR POS JSON Helper"; AlterationType: Option; ExternalMemberCardNo: Text[100])
    var
        POSActionMemberMgtWF3B: Codeunit "NPR POS Action Member MgtWF3-B";
        POSSession: Codeunit "NPR POS Session";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        ItemNo: Code[20];
        AutoAdmitMember: Integer;
    begin
        POSSession.GetSaleLine(POSSaleLine);
        ItemNo := CopyStr(Context.GetString('itemNumber'), 1, MaxStrLen(ItemNo));
        if not Context.GetIntegerParameter('AutoAdmitMember', AutoAdmitMember) then
            AutoAdmitMember := 0;
        POSActionMemberMgtWF3B.ExecuteMembershipAlteration(POSSaleLine, AlterationType, ExternalMemberCardNo, ItemNo, AutoAdmitMember);
    end;

    procedure GetMembershipAlterationLookupChoices(Context: Codeunit "NPR POS JSON Helper"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management") LookupProperties: JsonObject
    var
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        Membership: Record "NPR MM Membership";
        MemberCard: Record "NPR MM Member Card";
        POSActionMemberMgtWF3B: Codeunit "NPR POS Action Member MgtWF3-B";
        POSMemberSession: Codeunit "NPR POS Member Session";
        FunctionId: Integer;
        REGRET_OPTION: Label 'Regret options...';
        EXTEND_OPTION: Label 'Extend options...';
        RENEW_OPTION: Label 'Renew options...';
        REGRET_NOT_VALID: Label 'There are no valid regret products for this membership at this time.';
        EXTEND_NOT_VALID: Label 'There are no valid extend products for this membership at this time.';
        RENEW_NOT_VALID: Label 'There are no valid renewal products for this membership at this time.';
        UPGRADE_NOT_VALID: Label 'There are no valid upgrade products for this membership at this time.';
        CANCEL_NOT_VALID: Label 'There are no valid cancel products for this membership at this time.';
        UPGRADE_OPTION: Label 'Upgrade options...';
        CANCEL_OPTION: Label 'Cancel options...';
        ExternalMemberCardNo: Text[100];
        TextOut: Text;
        IntegerOut: Integer;
    begin

        if (not Context.GetIntegerParameter('Function', IntegerOut)) then
            IntegerOut := 0;
        FunctionId := IntegerOut;

        if (not Context.GetString('memberCardInput', TextOut)) then
            TextOut := '';
        ExternalMemberCardNo := CopyStr(TextOut, 1, MaxStrLen(ExternalMemberCardNo));

        if (ExternalMemberCardNo <> '') then
            POSMemberSession.SetMember(ExternalMemberCardNo);

        POSActionMemberMgtWF3B.GetMembershipFromCardNumberWithUI(MemberSelectionMethod::NO_PROMPT, ExternalMemberCardNo, Membership, MemberCard, false);

        MembershipAlterationSetup.SetFilter("From Membership Code", '=%1', Membership."Membership Code");
        case FunctionId of
            3:
                begin
                    MembershipAlterationSetup.SetFilter("Alteration Type", '=%1', MembershipAlterationSetup."Alteration Type"::REGRET);
                    LookupProperties.Add('notFoundMessage', REGRET_NOT_VALID);
                    LookupProperties.Add('title', REGRET_OPTION);
                end;
            4:
                begin
                    MembershipAlterationSetup.SetFilter("Alteration Type", '=%1', MembershipAlterationSetup."Alteration Type"::RENEW);
                    LookupProperties.Add('notFoundMessage', RENEW_NOT_VALID);
                    LookupProperties.Add('title', RENEW_OPTION);
                end;
            5:
                begin
                    MembershipAlterationSetup.SetFilter("Alteration Type", '=%1', MembershipAlterationSetup."Alteration Type"::EXTEND);
                    LookupProperties.Add('notFoundMessage', EXTEND_NOT_VALID);
                    LookupProperties.Add('title', EXTEND_OPTION);
                end;
            6:
                begin
                    MembershipAlterationSetup.SetFilter("Alteration Type", '=%1', MembershipAlterationSetup."Alteration Type"::UPGRADE);
                    LookupProperties.Add('notFoundMessage', UPGRADE_NOT_VALID);
                    LookupProperties.Add('title', UPGRADE_OPTION);
                end;
            7:
                begin
                    MembershipAlterationSetup.SetFilter("Alteration Type", '=%1', MembershipAlterationSetup."Alteration Type"::CANCEL);
                    LookupProperties.Add('notFoundMessage', CANCEL_NOT_VALID);
                    LookupProperties.Add('title', CANCEL_OPTION);
                end;

        end;
        LookupProperties.Add('cardnumber', ExternalMemberCardNo);
        LookupProperties.Add('data', CreateAlterMembershipOptions(Membership."Entry No.", GetAlterationGroup(POSSession), MembershipAlterationSetup));
        LookupProperties.Add('layout', GetAlterMembershipLayout());

    end;

    local procedure CreateAlterMembershipOptions(MembershipEntryNo: Integer; AlterationGroup: Code[10]; var MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup") OptionsArray: JsonArray
    var
        TempMembershipEntry: Record "NPR MM Membership Entry" temporary;
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin

        if (not MembershipAlterationSetup.FindFirst()) then
            exit;

        if (not MembershipManagement.GetMembershipChangeOptions(MembershipEntryNo, AlterationGroup, MembershipAlterationSetup, TempMembershipEntry)) then
            exit;

        TempMembershipEntry.Reset();
        TempMembershipEntry.FindSet();

        repeat
            OptionsArray.Add(GetMembershipEntryLookupDataToJson(TempMembershipEntry));
        until (TempMembershipEntry.Next() = 0);

    end;

    local procedure GetMembershipEntryLookupDataToJson(var TmpMembershipEntry: Record "NPR MM Membership Entry" temporary) ChangeOption: JsonObject
    begin
        ChangeOption.Add('itemno', TmpMembershipEntry."Item No.");
        ChangeOption.Add('fromdate', Format(TmpMembershipEntry."Valid From Date"));
        ChangeOption.Add('untildate', Format(TmpMembershipEntry."Valid Until Date"));
        ChangeOption.Add('unitprice', Format(TmpMembershipEntry."Unit Price"));
        ChangeOption.Add('description', TmpMembershipEntry.Description);
        ChangeOption.Add('amount', Format(TmpMembershipEntry."Amount Incl VAT"));
        ChangeOption.Add('context', Format(TmpMembershipEntry.Context));
        ChangeOption.Add('originalcontext', Format(TmpMembershipEntry."Original Context"));

        ChangeOption.Add('fromdate_date', TmpMembershipEntry."Valid From Date");
        ChangeOption.Add('untildate_date', TmpMembershipEntry."Valid Until Date");
        ChangeOption.Add('unitprice_decimal', TmpMembershipEntry."Unit Price");
        ChangeOption.Add('amount_decimal', TmpMembershipEntry."Amount Incl VAT");

        exit(ChangeOption);
    end;

    local procedure GetMembershipEntryLayout() MembershipEntryFieldLayout: JsonObject;
    var
        TmpMembershipEntry: Record "NPR MM Membership Entry";
        Control: JsonArray;
        Row: JsonObject;
        Rows: JsonArray;

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
    end;

    local procedure GetAlterMembershipLayout() AlterMembershipFieldLayout: JsonObject
    var
        TmpMembershipEntry: Record "NPR MM Membership Entry";
        Control: JsonArray;
        Row: JsonObject;
        Rows: JsonArray;
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

    procedure UpdateMembershipOnSaleLineInsert(SaleLinePOS: Record "NPR POS Sale Line")
    var
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        ReturnCode: Integer;
    begin
        if (SaleLinePOS.IsTemporary) then
            exit;

        ReturnCode := MemberRetailIntegration.NewMemberSalesInfoCapture(SaleLinePOS);
        if (ReturnCode < 0) then
            if (ReturnCode <> -1102) then
                Message('%1', MemberRetailIntegration.GetErrorText(ReturnCode));
    end;

    local procedure GetFrontEndInputs(Context: Codeunit "NPR POS JSON Helper"; var ExternalMemberCardNo: Text[100]; var FrontEndInputMethod: Option)
    var
        TextOut: Text;
    begin
        if (not Context.GetString('memberCardInput', TextOut)) then
            TextOut := '';
        ExternalMemberCardNo := CopyStr(TextOut, 1, MaxStrLen(ExternalMemberCardNo));

        // DialogPrompt can be obsoleted, alway returns NO_PROMPT
        //if not Context.GetInteger('DialogPrompt', IntegerOut) then
        //    IntegerOut := 0;
        FrontEndInputMethod := MemberSelectionMethod::NO_PROMPT;
    end;


    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionMemberMgtWF3.js### 
'let main=async({workflow:u,context:n,popup:l,captions:a,parameters:e})=>{e.Function<0&&(e.Function=e.Function["Member Arrival"]);debugger;let r=await u.respond("CheckMemberInitialized");r!=null&&r.memberExternalCardNo!=null&&r.memberExternalCardNo!==""&&(n.memberCardInput=r.memberExternalCardNo);let g=a.DialogTitle.substitute(e.Function);if(e.DefaultInputValue.length==0&&e.DialogPrompt<=e.DialogPrompt["Member Card Number"]&&(n.memberCardInput=await l.input({caption:a.MemberCardPrompt,title:a.windowTitle,value:n.memberCardInput}),n.memberCardInput===null))return;if(e.DefaultInputValue.length>0&&(n.memberCardInput=e.DefaultInputValue),e.Function>=e.Function["Regret Membership Entry"]&&e.Function<=e.Function["Cancel Membership"]){let i=await u.respond("GetMembershipAlterationLookup");if(n.memberCardInput=i.cardnumber,i.data?.length==0){await l.error({title:a.windowTitle,caption:i.notFoundMessage});return}let o=data.createArrayDriver(i.data),m=data.createDataSource(o);m.loadAll=!1;let d=await l.lookup({title:i.title,configuration:{className:"custom-lookup",styleSheet:"",layout:i.layout,result:c=>c?c.map(s=>s?s.itemno:null):null},source:m});if(d===null||d.length===0)return;n.itemNumber=d[0].itemno}let t=await u.respond("DoManageMembership");if(e.Function==e.Function["View Membership Entry"]){let i=data.createArrayDriver(t.data),o=data.createDataSource(i),m=await l.lookup({title:t.title,configuration:{className:"custom-lookup",styleSheet:"",layout:t.layout},source:o})}debugger;const b=e.ToastMessageTimer!==null&&e.ToastMessageTimer!==void 0&&e.ToastMessageTimer!==0?e.ToastMessageTimer:15;t.MemberScanned&&b>0&&toast.memberScanned({memberImg:t.MemberScanned.ImageDataUrl,memberName:t.MemberScanned.Name,validForAdmission:t.MemberScanned.Valid,hideAfter:b,memberExpiry:t.MemberScanned.ExpiryDate})};'
        )
    end;

    local procedure GetCustomParam(var Context: Codeunit "NPR POS JSON Helper"; var SelectReq: Boolean)
    var
        PrevScopeID: Guid;
    begin
        if Context.HasProperty('customParameters') then begin
            PrevScopeID := Context.StoreScope();

            Context.SetScope('customParameters');
            if not Context.GetBoolean('SelectionRequired', SelectReq) then
                SelectReq := false;

            Context.RestoreScope(PrevScopeID);
        end;
    end;

    local procedure GetAlterationGroup(POSSession: Codeunit "NPR POS Session"): Code[10]
    var
        SalePOS: Record "NPR POS Sale";
        POSUnit: Record "NPR POS Unit";
        POSMemberProfile: Record "NPR MM POS Member Profile";
        POSSale: Codeunit "NPR POS Sale";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if not POSUnit.Get(SalePOS."Register No.") then
            exit('');

        if not POSUnit.GetProfile(POSMemberProfile) then
            exit('');

        exit(POSMemberProfile."Alteration Group");
    end;
}

