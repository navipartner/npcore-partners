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
        ParamFunction_OptLbl: Label 'Member Arrival,Select Membership,View Membership Entry,Regret Membership Entry,Renew Membership,Extend Membership,Upgrade Membership,Cancel Membership,Edit Membership,Show Member,Edit Current Membership', Locked = true;
        ParamFunction_OptCptLbl: Label 'Member Arrival,Select Membership,View Membership Entry,Regret Membership Entry,Renew Membership,Extend Membership,Upgrade Membership,Cancel Membership,Edit Membership,Show Member,Edit Current Membership';
        ParamDialogPrompt_CptLbl: Label 'Dialog Prompt';
        ParamDialogPrompt_DescLbl: Label 'Specifies the type of Dialog Prompt';
        ParamDialogPrompt_OptLbl: Label 'Member Card Number,Facial Recognition,No Dialog', Locked = true;
        ParamDialogPrompt_OptCptLbl: Label 'Member Card Number,Facial Recognition,No Dialog';
        MemberCardPromptLbl: Label 'Enter Member Card Number';
        MemberNumberPromptLbl: Label 'Enter Member Number';
        MembershipNumberPromptLbl: Label 'Enter Membership Number';
        DialogTitleLbl: Label '%1 - Membership Management.';
        ParamDefaultInput_CptLbl: Label 'Default Input Value';
        ParamDefaultInput_DescLbl: Label 'Specifies the default value of the Input';
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
        WorkflowConfig.AddLabel('MemberCardPrompt', MemberCardPromptLbl);
        WorkflowConfig.AddLabel('MemberNumberPrompt', MemberNumberPromptLbl);
        WorkflowConfig.AddLabel('MembershipNumberPrompt', MembershipNumberPromptLbl);
        WorkflowConfig.AddLabel('DialogTitle', DialogTitleLbl);
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
            else
                exit;
        end;
    end;

    procedure ManageMembershipAction(Context: Codeunit "NPR POS JSON Helper"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management") JsonText: Text
    var
        FunctionId: Integer;
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        POSActionMemberMgtWF3B: Codeunit "NPR POS Action Member MgtWF3-B";
        FrontEndInputMethod: Option;
        ExternalMemberCardNo: Text[100];
        SelectReq: Boolean;
    begin
        if not Context.GetIntegerParameter('Function', FunctionId) then
            FunctionId := 0;
        GetCustomParam(Context, SelectReq);
        GetFrontEndInputs(Context, ExternalMemberCardNo, FrontEndInputMethod);

        JsonText := '{}';
        case FunctionId of
            0:
                POSActionMemberMgtWF3B.POSMemberArrival(FrontEndInputMethod, ExternalMemberCardNo);
            1:
                POSActionMemberMgtWF3B.SelectMembership(FrontEndInputMethod, ExternalMemberCardNo, SelectReq);
            2:
                JsonText := GetMembershipEntryLookupJson(FrontEndInputMethod, ExternalMemberCardNo);
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
                POSActionMemberMgtWF3B.ShowMember(FrontEndInputMethod, ExternalMemberCardNo);
            10:
                POSActionMemberMgtWF3B.EditActiveMembership();
        end;
        exit(JsonText);
    end;

    local procedure GetMembershipEntryLookupJson(FrontEndInputMethod: Option; ExternalMemberCardNo: Text[100]) JsonText: Text
    var
        MembershipEntry: Record "NPR MM Membership Entry";
        Membership: Record "NPR MM Membership";
        MemberCard: Record "NPR MM Member Card";
        POSActionMemberMgtWF3B: Codeunit "NPR POS Action Member MgtWF3-B";
        LookupProperties: JsonObject;
        MembershipEntries: JsonArray;
        MEMBERSHIP_ENTRIES: Label 'Membership Entries.';
        MembershipEntriesJsonText: Text;
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
        MembershipEntries.WriteTo(MembershipEntriesJsonText);

        LookupProperties.Add('title', MEMBERSHIP_ENTRIES);
        LookupProperties.Add('data', MembershipEntriesJsonText);
        LookupProperties.Add('layout', GetMembershipEntryLayout());
        LookupProperties.WriteTo(JsonText);

    end;

    local procedure ExecuteMembershipAlteration(Context: Codeunit "NPR POS JSON Helper"; AlterationType: Option; ExternalMemberCardNo: Text[100])
    var
        POSActionMemberMgtWF3B: Codeunit "NPR POS Action Member MgtWF3-B";
        POSSession: Codeunit "NPR POS Session";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        ItemNo: Code[20];
    begin
        POSSession.GetSaleLine(POSSaleLine);
        ItemNo := CopyStr(Context.GetString('itemNumber'), 1, MaxStrLen(ItemNo));
        POSActionMemberMgtWF3B.ExecuteMembershipAlteration(POSSaleLine, AlterationType, ExternalMemberCardNo, ItemNo);
    end;

    procedure GetMembershipAlterationLookupChoices(Context: Codeunit "NPR POS JSON Helper"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management") JsonText: Text
    var
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        Membership: Record "NPR MM Membership";
        MemberCard: Record "NPR MM Member Card";
        POSActionMemberMgtWF3B: Codeunit "NPR POS Action Member MgtWF3-B";
        FunctionId: Integer;
        LookupProperties: JsonObject;
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
        if not Context.GetIntegerParameter('Function', IntegerOut) then
            IntegerOut := 0;
        FunctionId := IntegerOut;

        if not Context.GetString('memberCardInput', TextOut) then
            TextOut := '';
        ExternalMemberCardNo := CopyStr(TextOut, 1, MaxStrLen(ExternalMemberCardNo));
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
        LookupProperties.Add('data', CreateAlterMembershipOptions(Membership."Entry No.", MembershipAlterationSetup));
        LookupProperties.Add('layout', GetAlterMembershipLayout());
        LookupProperties.WriteTo(JsonText);

    end;

    local procedure CreateAlterMembershipOptions(MembershipEntryNo: Integer; var MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup") Options: Text
    var
        TempMembershipEntry: Record "NPR MM Membership Entry" temporary;
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
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
        until (TempMembershipEntry.Next() = 0);

        OptionsArray.WriteTo(Options);
    end;

    local procedure GetMembershipEntryLookupDataToJson(var TmpMembershipEntry: Record "NPR MM Membership Entry" temporary) ChangeOption: JsonObject
    begin
        ChangeOption.Add('itemno', TmpMembershipEntry."Item No.");
        ChangeOption.Add('fromdate', TmpMembershipEntry."Valid From Date");
        ChangeOption.Add('untildate', TmpMembershipEntry."Valid Until Date");
        ChangeOption.Add('unitprice', Format(TmpMembershipEntry."Unit Price", 0, '<Sign><Integer><Decimals,3>'));
        ChangeOption.Add('description', TmpMembershipEntry.Description);
        ChangeOption.Add('amount', Format(TmpMembershipEntry."Amount Incl VAT", 0, '<Sign><Integer><Decimals,3>'));
        ChangeOption.Add('context', Format(TmpMembershipEntry.Context));
        ChangeOption.Add('originalcontext', Format(TmpMembershipEntry."Original Context"));

        exit(ChangeOption);
    end;

    local procedure GetMembershipEntryLayout() FieldLayout: Text
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

    local procedure GetAlterMembershipLayout() FieldLayout: Text
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

    local procedure GetFrontEndInputs(Context: Codeunit "NPR POS JSON Helper"; var ExternalMemberCardNo: Text[100]; FrontEndInputMethod: Option)
    var
        TextOut: Text;
        IntegerOut: Integer;
    begin
        if not Context.GetString('memberCardInput', TextOut) then
            TextOut := '';
        ExternalMemberCardNo := CopyStr(TextOut, 1, MaxStrLen(ExternalMemberCardNo));

        if not Context.GetInteger('DialogPrompt', IntegerOut) then
            IntegerOut := 0;
        FrontEndInputMethod := IntegerOut;
    end;


    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionMemberMgtWF3.js### 
'let main=async({workflow:c,context:l,popup:i,captions:u,parameters:e})=>{e.Function<0&&(e.Function=e.Function["Member Arrival"]);let b=u.DialogTitle.substitute(e.Function);if(e.DefaultInputValue.length==0&&e.DialogPrompt<=e.DialogPrompt["Member Card Number"]&&(l.memberCardInput=await i.input({caption:u.MemberCardPrompt,title:u.windowTitle}),l.memberCardInput===null))return;if(e.DefaultInputValue.length>0&&(l.memberCardInput=e.DefaultInputValue),e.Function>=e.Function["Regret Membership Entry"]&&e.Function<=e.Function["Cancel Membership"]){let t=JSON.parse(await c.respond("GetMembershipAlterationLookup"));l.memberCardInput=t.cardnumber;let n=JSON.parse(t.data);if(n.length==0){await i.error({title:u.windowTitle,caption:t.notFoundMessage});return}let a=data.createArrayDriver(n),r=data.createDataSource(a);r.loadAll=!1;let o=await i.lookup({title:t.title,configuration:{className:"custom-lookup",styleSheet:"",layout:JSON.parse(t.layout),result:d=>d?d.map(s=>s?s.itemno:null):null},source:r});if(o===null||o.length===0)return;l.itemNumber=o[0].itemno}let m=await c.respond("DoManageMembership");if(e.Function==e.Function["View Membership Entry"]){let t=JSON.parse(m),n=data.createArrayDriver(JSON.parse(t.data)),a=data.createDataSource(n),r=await i.lookup({title:t.title,configuration:{className:"custom-lookup",styleSheet:"",layout:JSON.parse(t.layout)},source:a})}};'
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
}

