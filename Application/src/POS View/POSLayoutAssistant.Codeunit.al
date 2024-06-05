codeunit 6059925 "NPR POS Layout Assistant"
{
    Access = Internal;

    var
        _JsonHelper: Codeunit "NPR Json Helper";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnCustomMethod', '', true, true)]
    local procedure OnRequestPOSLayoutRelatedData(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if Method in
            ['RequestPOSLayoutData',
             'SavePOSLayoutData',
             'AssignPOSLayout',
             'GetAssignedPOSLayout',
             'POSLayout_SelectItem',
             'POSLayout_SelectCustomer',
             'POSLayout_SelectPaymentMethod',
             'POSLayout_SelectPOSAction',
             'POSLayout_GetPOSActionParameterList',
             'POSLayout_SetPOSActionParameters',
             'RequestWorkflowList',
             'UserCulture',
             'CallRefreshData',
             'LegacyPOSMenus']
        then
            Handled := true;

        case Method of
            'RequestPOSLayoutData':
                RefreshPOSLayoutData(Context, FrontEnd);
            'SavePOSLayoutData':
                SavePOSLayoutData(Context);
            'AssignPOSLayout':
                AssignPOSLayout(Context);
            'GetAssignedPOSLayout':
                GetAssignedPOSLayout(Context, FrontEnd);
            'POSLayout_SelectItem', 'POSLayout_SelectCustomer', 'POSLayout_SelectPaymentMethod', 'POSLayout_SelectPOSAction':
                SelectEntity(Method, Context, FrontEnd);
            'POSLayout_GetPOSActionParameterList':
                GetPOSActionParameterList(Context, FrontEnd);
            'POSLayout_SetPOSActionParameters':
                AdjustPOSActionParameters(Context, FrontEnd);
            'RequestWorkflowList':
                GenerateWorkflowList(Context, FrontEnd);
            'UserCulture':
                GetUserCultureName(Context, FrontEnd);
            'CallRefreshData':
                CallRefreshData();
            'LegacyPOSMenus':
                GetPOSMenus(Context, FrontEnd);
        end;
    end;

    local procedure RefreshPOSLayoutData(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSLayout: Record "NPR POS Layout";
        POSLayoutList: JsonArray;
        POSLayoutContent: JsonObject;
        Response: JsonObject;
        POSLayoutFilter: Text;
    begin
        POSLayoutFilter := _JsonHelper.GetJText(Context.AsToken(), 'layoutId', false);
        if POSLayoutFilter <> '' then
            POSLayout.SetFilter(Code, POSLayoutFilter);
        if POSLayout.FindSet() then
            repeat
                Clear(POSLayoutContent);
                AddPOSLayoutToJson(POSLayout, POSLayoutContent);
                POSLayoutList.Add(POSLayoutContent);
            until POSLayout.Next() = 0;

        Response.Add('layouts', POSLayoutList);
        FrontEnd.RespondToFrontEndMethod(Context, Response, FrontEnd);
    end;

    local procedure SavePOSLayoutData(Context: JsonObject)
    var
        POSLayout: JsonToken;
        POSLayouts: JsonToken;
        JToken: JsonToken;
    begin
        POSLayouts := _JsonHelper.GetJsonToken(Context.AsToken(), 'layouts');
        if not POSLayouts.IsArray() then
            exit;

        foreach POSLayout in POSLayouts.AsArray() do begin
            POSLayout.SelectToken('type_of_change', JToken);
            case JToken.AsValue().AsText() of
                'new':
                    NewPOSLayout(POSLayout);
                'modify':
                    ModifyPOSLayout(POSLayout);
                'delete':
                    DeletePOSLayout(POSLayout);
            end;
        end;
    end;

    local procedure NewPOSLayout(POSLayoutJToken: JsonToken)
    var
        POSLayout: Record "NPR POS Layout";
    begin
        POSLayout.Code := CopyStr(_JsonHelper.GetJText(POSLayoutJToken, 'id', false), 1, MaxStrLen(POSLayout.Code));
        if (POSLayout.Code = '') or POSLayout.Find() then begin
            POSLayout.Code := '000';
            repeat
                POSLayout.Code := IncStr(POSLayout.Code);
            until not POSLayout.Find();
        end;

        POSLayout.Init();
        TransferToPosLayout(POSLayoutJToken, POSLayout);
        POSLayout.Insert(true);
    end;

    local procedure ModifyPOSLayout(POSLayoutJToken: JsonToken)
    var
        POSLayout: Record "NPR POS Layout";
    begin
        if not POSLayout.Get(CopyStr(_JsonHelper.GetJText(POSLayoutJToken, 'id', true), 1, MaxStrLen(POSLayout.Code))) then begin
            NewPOSLayout(POSLayoutJToken);
            exit;
        end;

        TransferToPosLayout(POSLayoutJToken, POSLayout);
        POSLayout.Modify(true);
    end;

    local procedure DeletePOSLayout(POSLayoutJToken: JsonToken)
    var
        POSLayout: Record "NPR POS Layout";
    begin
        if not POSLayout.Get(CopyStr(_JsonHelper.GetJText(POSLayoutJToken, 'id', true), 1, MaxStrLen(POSLayout.Code))) then
            exit;

        POSLayout.Delete(true);
    end;

    local procedure TransferToPosLayout(POSLayoutJToken: JsonToken; var POSLayout: Record "NPR POS Layout")
    var
        OutStr: OutStream;
    begin
        POSLayout.Description := CopyStr(_JsonHelper.GetJText(POSLayoutJToken, 'caption', false), 1, MaxStrLen(POSLayout.Description));
        POSLayout."Template Name" := CopyStr(_JsonHelper.GetJText(POSLayoutJToken, 'template', false), 1, MaxStrLen(POSLayout."Template Name"));
        POSLayout."Frontend Properties".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.Write(_JsonHelper.GetJsonToken(POSLayoutJToken, 'blob').AsValue().AsText());
    end;

    local procedure AssignPOSLayout(Context: JsonObject)
    var
        POSLayout: Record "NPR POS Layout";
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        Setup: Codeunit "NPR POS Setup";
    begin
        POSLayout.Get(CopyStr(_JsonHelper.GetJText(Context.AsToken(), 'layoutId', true), 1, MaxStrLen(POSLayout.Code)));
        POSUnit.Get(CopyStr(_JsonHelper.GetJText(Context.AsToken(), 'POSUnitCode', true), 1, MaxStrLen(POSUnit."No.")));
        POSUnit."POS Layout Code" := POSLayout.Code;
        POSUnit.Modify();

        if not POSSession.IsInitialized() then
            exit;
        POSSession.GetSetup(Setup);
        Setup.SetPOSUnit(POSUnit);
    end;

    local procedure GetAssignedPOSLayout(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSUnit: Record "NPR POS Unit";
        Response: JsonObject;
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
        POSLayout: Record "NPR POS Layout";
        POSLayoutObject: JsonObject;
    begin
        POSSession.GetSetup(POSSetup);
        POSUnit.Get(POSSetup.GetPOSUnitNo());
        Response.Add('layoutId', POSUnit."POS Layout Code");
        if POSLayout.Get(POSUnit."POS Layout Code") then begin
            AddPOSLayoutToJson(POSLayout, POSLayoutObject);
            Response.Add('POSLayout', POSLayoutObject)
        end;
        FrontEnd.RespondToFrontEndMethod(Context, Response, FrontEnd);
    end;

    local procedure SelectEntity(Method: Text; Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Customer: Record Customer;
        Item: Record Item;
        POSAction: Record "NPR POS Action";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSActionMgt: Codeunit "NPR POS Action Management";
        CustomerList: Page "Customer List";
        ItemList: Page "Item List";
        POSPaymentMethodList: Page "NPR POS Payment Method List";
        Response: JsonObject;
        xSelectedEntityCode: Code[20];
        UnsupportedMethodErr: Label 'Unsupported method "%1"', Comment = '%1 - method name';
    begin
        xSelectedEntityCode := CopyStr(_JsonHelper.GetJText(Context.AsToken(), 'xSelectedEntityId', false), 1, MaxStrLen(xSelectedEntityCode));

        case Method of
            'POSLayout_SelectItem':
                begin
                    if xSelectedEntityCode <> '' then begin
                        Item."No." := xSelectedEntityCode;
                        if Item.Find('=><') then
                            ItemList.SetRecord(Item);
                    end;
                    ItemList.LookupMode := true;
                    if ItemList.RunModal() <> Action::LookupOK then
                        Error('');
                    ItemList.GetRecord(Item);
                    Response.Add('selectedEntityId', Item."No.");
                end;

            'POSLayout_SelectCustomer':
                begin
                    if xSelectedEntityCode <> '' then begin
                        Customer."No." := xSelectedEntityCode;
                        if Customer.Find('=><') then
                            CustomerList.SetRecord(Customer);
                    end;
                    CustomerList.LookupMode := true;
                    if CustomerList.RunModal() <> Action::LookupOK then
                        Error('');
                    CustomerList.GetRecord(Customer);
                    Response.Add('selectedEntityId', Customer."No.");
                end;

            'POSLayout_SelectPaymentMethod':
                begin
                    if xSelectedEntityCode <> '' then begin
                        POSPaymentMethod.Code := CopyStr(xSelectedEntityCode, 1, MaxStrLen(POSPaymentMethod.Code));
                        if POSPaymentMethod.Find('=><') then
                            POSPaymentMethodList.SetRecord(POSPaymentMethod);
                    end;
                    POSPaymentMethodList.LookupMode := true;
                    if POSPaymentMethodList.RunModal() <> Action::LookupOK then
                        Error('');
                    POSPaymentMethodList.GetRecord(POSPaymentMethod);
                    Response.Add('selectedEntityId', POSPaymentMethod.Code);
                end;

            'POSLayout_SelectPOSAction':
                begin
                    POSAction.Code := xSelectedEntityCode;
                    if not POSActionMgt.LookupAction(POSAction.Code) then
                        Error('');
                    POSAction.Find();
                    Response.Add('selectedEntityId', POSAction.Code);
                    AddPOSActionParametersToResponse(POSAction, Response);
                end;
            else
                Error(UnsupportedMethodErr, Method);
        end;

        FrontEnd.RespondToFrontEndMethod(Context, Response, FrontEnd);
    end;

    local procedure AddPOSActionParametersToResponse(POSAction: Record "NPR POS Action"; var Response: JsonObject)
    var
        ActionParam: Record "NPR POS Action Parameter";
        ParameterSetJArray: JsonArray;
        ParameterJObject: JsonObject;
        OptionJObject: JsonObject;
        WorkflowCaptionBuffer: Codeunit "NPR Workflow Caption Buffer";
        ParameterDescription: Text;
        ParameterNameCaption: Text;
    begin
        Response.Add('dataSourceName', POSAction."Data Source Name");

        clear(ParameterSetJArray);
        ActionParam.SetRange("POS Action Code", POSAction.Code);
        if ActionParam.FindSet() then
            repeat
                Clear(ParameterJObject);
                Clear(ParameterDescription);
                Clear(ParameterNameCaption);

                ParameterDescription := WorkflowCaptionBuffer.GetParameterDescriptionCaption(ActionParam."POS Action Code", ActionParam.Name);
                if (ParameterDescription <> '') then begin
                    ParameterJObject.Add('description', ParameterDescription);
                end;

                ParameterNameCaption := WorkflowCaptionBuffer.GetParameterNameCaption(ActionParam."POS Action Code", ActionParam.Name);
                if (ParameterNameCaption <> '') then begin
                    ParameterJObject.Add('name_caption', ParameterNameCaption);
                end;

                ParameterJObject.Add('name', ActionParam.Name);
                ParameterJObject.Add('data_type', Format(ActionParam."Data Type", 0, 9));
                if ActionParam."Data Type" = ActionParam."Data Type"::Option then begin
                    ActionParam.GetOptionsDictionary(OptionJObject);
                    ParameterJObject.Add('options', OptionJObject);
                end;
                ParameterJObject.Add('default_value', ActionParam."Default Value");
                ParameterSetJArray.Add(ParameterJObject);
            until ActionParam.Next() = 0;
        Response.Add('parameterSet', ParameterSetJArray);
    end;

    local procedure GetPOSActionParameterList(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSAction: Record "NPR POS Action";
        Response: JsonObject;
    begin
        POSAction.Get(CopyStr(_JsonHelper.GetJText(Context.AsToken(), 'actionCode', true), 1, MaxStrLen(POSAction.Code)));
        AddPOSActionParametersToResponse(POSAction, Response);
        FrontEnd.RespondToFrontEndMethod(Context, Response, FrontEnd);
    end;

    local procedure AdjustPOSActionParameters(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        ActionParam: Record "NPR POS Action Parameter";
        POSAction: Record "NPR POS Action";
        TempPOSParameterValue: Record "NPR POS Parameter Value" temporary;
        ParameterSetJArray: JsonArray;
        ParameterJObject: JsonObject;
        Response: JsonObject;
        JToken: JsonToken;
        xParameterSet: JsonToken;
    begin
        POSAction.Get(CopyStr(_JsonHelper.GetJText(Context.AsToken(), 'actionCode', true), 1, MaxStrLen(POSAction.Code)));
        if _JsonHelper.GetJsonToken(Context.AsToken(), 'xParameterSet', xParameterSet) then
            if xParameterSet.IsArray() then
                ParameterSetJArray := xParameterSet.AsArray();

        ActionParam.SetRange("POS Action Code", POSAction.Code);
        if ActionParam.FindSet() then begin
            repeat
                TempPOSParameterValue.Name := ActionParam.Name;
                TempPOSParameterValue."Action Code" := POSAction.Code;
                TempPOSParameterValue."Data Type" := ActionParam."Data Type";
                TempPOSParameterValue.Value := ActionParam."Default Value";
                TempPOSParameterValue.Insert();
            until ActionParam.Next() = 0;

            if ParameterSetJArray.Count > 0 then
                foreach JToken in ParameterSetJArray do
                    if JToken.IsObject() then begin
                        ParameterJObject := JToken.AsObject();
                        ParameterJObject.Get('name', JToken);
                        TempPOSParameterValue.Name := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(TempPOSParameterValue.Name));
                        if TempPOSParameterValue.Find() then begin
                            ParameterJObject.Get('data_type', JToken);
                            if JToken.AsValue().AsInteger() = TempPOSParameterValue."Data Type" then begin
                                ParameterJObject.Get('value', JToken);
                                TempPOSParameterValue.Value := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(TempPOSParameterValue.Value));
                                TempPOSParameterValue.Modify();
                            end;
                        end;
                    end;

            Page.RunModal(Page::"NPR POS Parameter Values", TempPOSParameterValue);

            clear(ParameterSetJArray);
            TempPOSParameterValue.FindSet();
            repeat
                Clear(ParameterJObject);
                ParameterJObject.Add('name', TempPOSParameterValue.Name);
                ParameterJObject.Add('data_type', Format(TempPOSParameterValue."Data Type", 0, 9));
                ParameterJObject.Add('value', TempPOSParameterValue.Value);
                ParameterSetJArray.Add(ParameterJObject);
            until TempPOSParameterValue.Next() = 0;
        end else
            clear(ParameterSetJArray);

        Response.Add('parameterSet', ParameterSetJArray);
        FrontEnd.RespondToFrontEndMethod(Context, Response, FrontEnd);
    end;

    local procedure GenerateWorkflowList(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSAction: Record "NPR POS Action";
        Workflow: Codeunit "NPR Workflow";
        InStr: InStream;
        Response: JsonObject;
        ActionWorkflow: JsonObject;
        ActionWorkflows: JsonArray;
        SkipDiscovery: Boolean;
    begin
        SkipDiscovery := _JsonHelper.GetJBoolean(Context.AsToken(), 'skipDiscovery', false);
        if not SkipDiscovery then
            POSAction.DiscoverActions();
        POSAction.SetAutoCalcFields(Workflow, "Custom JavaScript Logic");
        if POSAction.FindSet() then
            repeat
                if POSAction.Workflow.HasValue() then begin
                    POSAction.Workflow.CreateInStream(InStr);
                    Workflow.DeserializeFromJsonStream(InStr);
                    if POSAction."Bound to DataSource" then
                        Workflow.Content().Add('DataBinding', true);
                    if POSAction."Custom JavaScript Logic".HasValue() then
                        Workflow.Content().Add('CustomJavaScript', POSAction.GetCustomJavaScriptLogic());
                    if POSAction."Blocking UI" then
                        Workflow.Content().Add('Blocking', true);

                    Clear(ActionWorkflow);
                    ActionWorkflow.Add('Name', Workflow.Name());
                    ActionWorkflow.Add('RequestContext', Workflow.RequestContext());
                    ActionWorkflow.Add('Steps', Workflow.Steps());
                    ActionWorkflow.Add('Content', Workflow.Content());
                    AddPOSActionParametersToResponse(POSAction, ActionWorkflow);
                    ActionWorkflows.Add(ActionWorkflow);
                end;
            until POSAction.Next() = 0;
        Response.Add('workflowList', ActionWorkflows);
        FrontEnd.RespondToFrontEndMethod(Context, Response, FrontEnd);
    end;

    local procedure CallRefreshData()
    var
        POSRefreshData: Codeunit "NPR POS Refresh Data";
    begin
        POSRefreshData.SetFullRefresh();
        POSRefreshData.Refresh();
    end;

    local procedure GetUserCultureName(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        TypeHelper: Codeunit "Type Helper";
        Response: JsonObject;
    begin
        Response.Add('userCultureName', TypeHelper.GetCultureName());
        FrontEnd.RespondToFrontEndMethod(Context, Response, FrontEnd);
    end;

    local procedure AddPOSLayoutToJson(POSLayout: Record "NPR POS Layout"; var POSLayoutContentOut: JsonObject)
    var
        Instr: InStream;
        PropertiesString: Text;
    begin
        POSLayoutContentOut.Add('id', POSLayout.Code);
        POSLayoutContentOut.Add('caption', POSLayout.Description);
        POSLayoutContentOut.Add('template', POSLayout."Template Name");
        if POSLayout."Frontend Properties".HasValue() then begin
            POSLayout.CalcFields("Frontend Properties");
            POSLayout."Frontend Properties".CreateInStream(Instr, TextEncoding::UTF8);
            Instr.Read(PropertiesString);
            POSLayoutContentOut.Add('blob', PropertiesString);
        end else
            POSLayoutContentOut.Add('blob', '');
        POSLayoutContentOut.Add('assignedToPOSUnits', POSLayout.AssignedToPOSUnits());
    end;

    local procedure GetPOSMenus(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Menu: Record "NPR POS Menu";
        POSUIManagement: Codeunit "NPR POS UI Management";
        Response: JsonObject;
    begin
        Response.Add('POSMenus', POSUIManagement.InitializeMenus(Menu));
        FrontEnd.RespondToFrontEndMethod(Context, Response, FrontEnd);
    end;
}
