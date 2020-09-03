codeunit 6150740 "NPR POS Method - Wysiwyg"
{
    // NPR5.40/VB  /20171206 CASE 255773 Front-end WYSIWYG editor support.
    // 
    // COMMENT FOR MERGE/RELEASE:
    // - This codeunit is still in development. If it has been released, it's because we needed it for demo, but no individual #CASEID tracking tags will be included in changed code until this is fully completed and officially released.
    // 
    // DO NOT CHANGE THIS CODEUNIT! IF YOU BELIEVE THAT ANYTHING IN HERE SHOULD BE CHANGED, PLEASE CONTACT VJEKO AT npvb@navipartner.dk
    // IF YOU CHANGE ANYTHING IN HERE, IT WILL BE LOST AT MY NEXT DEPLOYMENT, AS I AM NOT MERGING THIS CODEUNIT; I AM MERELY IMPORTING THE FOB.
    // 
    // NPR5.53/VB  /20190917  CASE 362777 Fixes a bug discovered during development of case 362777.


    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnCustomMethod', '', false, false)]
    local procedure OnWysiwygMethod(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        Request: DotNet NPRNetJsonRequest;
        RequestMethod: Text;
        RequestId: Guid;
        Success: Boolean;
    begin
        if Method <> 'Wysiwyg' then
            exit;

        Request := Request.JsonRequest;
        Request.Method := 'WysiwygResponse';

        JSON.InitializeJObjectParser(Context, FrontEnd);
        RequestMethod := JSON.GetString('method', true);
        case RequestMethod of
            'save':
                Success := SaveConfiguration(Request, JSON, POSSession, FrontEnd);
            'lookup_action':
                Success := LookupAction(Request, JSON, POSSession, FrontEnd);
            'lookup_item':
                Success := LookupItem(Request, JSON, POSSession, FrontEnd);
            'lookup_customer':
                Success := LookupCustomer(Request, JSON, POSSession, FrontEnd);
            'lookup_parameters':
                Success := LookupParameters(Request, JSON, POSSession, FrontEnd);
            'lookup_popup':
                Success := LookupPopup(Request, JSON, POSSession, FrontEnd);
        end;
        JSON.SetScopeRoot(true);
        Request.Content.Add('requestId', JSON.GetString('requestId', true));
        Request.Content.Add('success', Success);

        FrontEnd.InvokeFrontEndMethod(Request);

        Handled := true;
    end;

    local procedure SaveConfiguration(Request: DotNet NPRNetJsonRequest; JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"): Boolean
    var
        POSAction: Record "NPR POS Action";
        TargetType: Text;
        Length: Integer;
        i: Integer;
    begin
        //-NPR5.53 [362777]
        POSAction.DiscoverActions();
        //+NPR5.53 [362777]

        JSON.SetScope('data', true);
        Length := JSON.GetInteger('length', true);
        for i := 0 to Length - 1 do begin
            JSON.SetScopePath(StrSubstNo('$.data.%1', i), true);
            TargetType := JSON.GetString('targetType', false);
            case TargetType of
                'button':
                    SaveButtonConfiguration(JSON);
            end;
        end;
    end;

    local procedure SaveButtonConfiguration(JSON: Codeunit "NPR POS JSON Management")
    var
        POSMenuButton: Record "NPR POS Menu Button";
        KeyMenu: Text;
        KeyId: Integer;
        ParentKeyId: Integer;
    begin
        KeyMenu := JSON.GetString('keyMenu', true);
        KeyId := JSON.GetInteger('keyId', false);
        ParentKeyId := JSON.GetInteger('parentKeyId', false);

        if KeyId = 0 then begin
            CreateNewButton(KeyMenu, JSON, ParentKeyId)
        end else begin
            if POSMenuButton.Get(KeyMenu, KeyId) then
                SaveExistingButton(POSMenuButton, JSON);
        end;
    end;

    local procedure CreateNewButton(MenuCode: Code[20]; JSON: Codeunit "NPR POS JSON Management"; ParentKeyId: Integer)
    var
        POSMenu: Record "NPR POS Menu";
        POSMenuButton: Record "NPR POS Menu Button";
    begin
        if not POSMenu.Get(MenuCode) then
            // TODO: Report error to front end
            exit;

        with POSMenuButton do begin
            "Menu Code" := MenuCode;
            Level := 0;
            if ParentKeyId > 0 then
                Validate("Parent ID", ParentKeyId);
            Insert(true);
            SaveExistingButton(POSMenuButton, JSON);
        end;
    end;

    local procedure SaveExistingButton(POSMenuButton: Record "NPR POS Menu Button"; JSON: Codeunit "NPR POS JSON Management")
    var
        ParamValue: Record "NPR POS Parameter Value";
        ActionMoniker: Text;
        Type: Text;
        ActionCode: Code[20];
        Caption: Text;
        Icon: Text;
        Background: Text;
        Modified: Boolean;
    begin
        ActionMoniker := JSON.GetString('action', false);
        if ActionMoniker = 'delete' then begin
            POSMenuButton.SetUnattendedDeleteFlag();
            POSMenuButton.Delete(true);
            exit;
        end;

        Caption := JSON.GetString('caption', false);
        if Caption <> '' then begin
            POSMenuButton.Caption := Caption;
            Modified := true;
        end;

        Type := JSON.GetString('type', false);
        if Type <> '' then begin
            Evaluate(POSMenuButton."Action Type", Type);
            POSMenuButton.Validate("Action Type");
            Modified := true;
        end;

        case POSMenuButton."Action Type" of
            POSMenuButton."Action Type"::Action:
                begin
                    ActionCode := JSON.GetString('action', false);
                    if ActionCode <> '' then begin
                        POSMenuButton.Validate("Action Code", ActionCode);
                        Modified := true;
                    end;
                    if SaveParameters(POSMenuButton, JSON) then
                        Modified := true;
                end;
            POSMenuButton."Action Type"::Item:
                begin
                    ActionCode := JSON.GetString('item', false);
                    if ActionCode <> '' then begin
                        POSMenuButton.Validate("Action Code", ActionCode);
                        Modified := true;
                    end;
                end;
            POSMenuButton."Action Type"::PopupMenu:
                begin
                    ActionCode := JSON.GetString('popupMenu', false);
                    if ActionCode <> '' then begin
                        POSMenuButton.Validate("Action Code", ActionCode);
                        Modified := true;
                    end;

                    if JSON.HasProperty('columns') then begin
                        ParamValue.GetParameter(POSMenuButton.RecordId, POSMenuButton.ID, 'Columns');
                        ParamValue.Validate(Value, JSON.GetString('columns', false));
                        ParamValue.Modify;
                    end;

                    if JSON.HasProperty('rows') then begin
                        ParamValue.GetParameter(POSMenuButton.RecordId, POSMenuButton.ID, 'Rows');
                        ParamValue.Validate(Value, JSON.GetString('rows', false));
                        ParamValue.Modify;
                    end;
                end;
        end;

        Icon := JSON.GetString('icon', false);
        if Icon <> '' then begin
            POSMenuButton."Icon Class" := Icon;
            Modified := true;
        end;

        Background := JSON.GetString('background', false);
        if Background <> '' then begin
            POSMenuButton."Background Color" := Background;
            Modified := true;
        end;

        if JSON.HasProperty('backgroundUrl') then begin
            POSMenuButton."Background Image Url" := JSON.GetString('backgroundUrl', false);
            Modified := true;
        end;

        if JSON.HasProperty('captionPosition') then begin
            POSMenuButton."Caption Position" := JSON.GetInteger('captionPosition', false);
            Modified := true;
        end;

        if JSON.HasProperty('tooltip') then begin
            POSMenuButton.Tooltip := JSON.GetString('tooltip', false);
            Modified := true;
        end;

        if JSON.HasProperty('column') then begin
            POSMenuButton."Position X" := JSON.GetInteger('column', false);
            Modified := true;
        end;

        if JSON.HasProperty('row') then begin
            POSMenuButton."Position Y" := JSON.GetInteger('row', false);
            Modified := true;
        end;

        if Modified then
            POSMenuButton.Modify();
    end;

    local procedure LookupAction(Request: DotNet NPRNetJsonRequest; JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"): Boolean
    var
        POSAction: Record "NPR POS Action";
        POSActions: Page "NPR POS Actions";
        ActionCode: Code[20];
        Check: Boolean;
    begin
        ActionCode := JSON.GetString('current', false);
        Check := JSON.GetBoolean('check', false);
        if (ActionCode <> '') or Check then begin
            if POSSession.RetrieveSessionAction(ActionCode, POSAction) then begin
                if Check then begin
                    Request.Content.Add('checkOk', true);
                    Request.Content.Add('actionCode', POSAction.Code);
                    exit(true);
                end;
            end else begin
                if Check then begin
                    Request.Content.Add('checkOk', false);
                    exit(true);
                end;
            end;
        end;

        POSActions.LookupMode := true;
        POSActions.SetRecord(POSAction);
        if POSActions.RunModal = ACTION::LookupOK then begin
            POSActions.GetRecord(POSAction);
            Request.Content.Add('actionCode', POSAction.Code);
            exit(true);
        end;
    end;

    local procedure LookupItem(Request: DotNet NPRNetJsonRequest; JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"): Boolean
    var
        Item: Record Item;
        Items: Page "Item List";
        ItemNo: Code[20];
        Check: Boolean;
    begin
        ItemNo := JSON.GetString('current', false);
        Check := JSON.GetBoolean('check', false);
        if (ItemNo <> '') or Check then begin
            if Item.Get(ItemNo) then begin
                if Check then begin
                    Request.Content.Add('checkOk', true);
                    Request.Content.Add('itemNo', Item."No.");
                    Request.Content.Add('itemDesc', Item.Description);
                    exit(true);
                end;
            end else begin
                if Check then begin
                    Request.Content.Add('checkOk', false);
                    exit(true);
                end;
            end;
        end;

        Items.LookupMode := true;
        Items.SetRecord(Item);
        if Items.RunModal = ACTION::LookupOK then begin
            Items.GetRecord(Item);
            Request.Content.Add('itemNo', Item."No.");
            Request.Content.Add('itemDesc', Item.Description);
            exit(true);
        end;
    end;

    local procedure LookupCustomer(Request: DotNet NPRNetJsonRequest; JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"): Boolean
    var
        Cust: Record Customer;
        Customers: Page "Customer List";
        CustNo: Code[20];
        Check: Boolean;
    begin
        CustNo := JSON.GetString('current', false);
        Check := JSON.GetBoolean('check', false);
        if (CustNo <> '') or Check then begin
            if Cust.Get(CustNo) then begin
                if Check then begin
                    Request.Content.Add('checkOk', true);
                    Request.Content.Add('custNo', Cust."No.");
                    Request.Content.Add('custName', Cust.Name);
                    exit(true);
                end;
            end else begin
                if Check then begin
                    Request.Content.Add('checkOk', false);
                    exit(true);
                end;
            end;
        end;

        Customers.LookupMode := true;
        Customers.SetRecord(Cust);
        if Customers.RunModal = ACTION::LookupOK then begin
            Customers.GetRecord(Cust);
            Request.Content.Add('custNo', Cust."No.");
            Request.Content.Add('custName', Cust.Name);
            exit(true);
        end;
    end;

    local procedure LookupParameters(Request: DotNet NPRNetJsonRequest; JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"): Boolean
    var
        POSAction: Record "NPR POS Action";
        POSParam: Record "NPR POS Action Parameter";
        TempParam: Record "NPR POS Parameter Value" temporary;
        ParamMgt: Codeunit "NPR POS Action Param. Mgt.";
        JObject: JsonObject;
        JToken: JsonToken;
        ParamStr: Text;
        JsonText: Text;
    begin
        POSSession.DiscoverActionsOnce();
        POSAction.Get(JSON.GetString('action', true));
        CopyParametersFromActionToTempParam(POSAction.Code, TempParam);

        ParamStr := JSON.GetString('parameters', false);
        if ParamStr = '' then
            ParamStr := '{}';
        JObject.ReadFrom(ParamStr);

        if TempParam.FindSet then
            repeat
                if POSParam.Get(POSAction.Code, TempParam.Name) then begin
                    if (JObject.Get(TempParam.Name, JToken)) then begin
                        POSParam.Validate("Default Value", JToken.AsValue().AsText());
                        TempParam.Value := POSParam."Default Value";
                        TempParam.Modify(false);
                    end;
                end;
            until TempParam.Next = 0;

        EditParametersDirect(TempParam);
        Clear(JObject);
        if TempParam.FindSet then
            repeat
                TempParam.AddParameterToJObject(JObject);
            until TempParam.Next = 0;

        JObject.WriteTo(JsonText);
        Request.Content.Add('parameters', JsonText);
        exit(true);
    end;

    local procedure LookupPopup(Request: DotNet NPRNetJsonRequest; JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"): Boolean
    var
        POSMenu: Record "NPR POS Menu";
        POSMenus: Page "NPR POS Menus";
        MenuCode: Code[20];
        Check: Boolean;
    begin
        MenuCode := JSON.GetString('current', false);
        Check := JSON.GetBoolean('check', false);
        if (MenuCode <> '') or Check then begin
            if POSMenu.Get(MenuCode) then begin
                if Check then begin
                    Request.Content.Add('checkOk', true);
                    Request.Content.Add('menuCode', POSMenu.Code);
                    Request.Content.Add('caption', POSMenu.Caption);
                    exit(true);
                end;
            end else begin
                if Check then begin
                    Request.Content.Add('checkOk', false);
                    exit(true);
                end;
            end;
        end;


        POSMenus.LookupMode := true;
        POSMenus.SetRecord(POSMenu);
        if POSMenus.RunModal = ACTION::LookupOK then begin
            POSMenus.GetRecord(POSMenu);
            Request.Content.Add('menuCode', POSMenu.Code);
            Request.Content.Add('caption', POSMenu.Caption);
            exit(true);
        end;
    end;

    local procedure SaveParameters(var POSMenuButton: Record "NPR POS Menu Button"; JSON: Codeunit "NPR POS JSON Management"): Boolean
    var
        TempParam: Record "NPR POS Parameter Value" temporary;
        Param: Record "NPR POS Parameter Value";
        JToken: JsonObject;
        RecRef: RecordRef;
        FieldRef: FieldRef;
        ScopeID: Guid;
    begin
        CopyParametersFromActionToTempParam(POSMenuButton."Action Code", TempParam);
        ScopeID := JSON.StoreScope;
        if not JSON.SetScope('parameters', false) then
            exit(false);

        if TempParam.FindSet then
            repeat
                Param.Init();
                Param."Table No." := DATABASE::"NPR POS Menu Button";
                Param.Code := POSMenuButton."Menu Code";
                Param.ID := POSMenuButton.ID;
                Param."Record ID" := POSMenuButton.RecordId;
                Param.Name := TempParam.Name;
                if not Param.Find then
                    Param.Insert;
                Param."Action Code" := TempParam."Action Code";
                Param."Data Type" := TempParam."Data Type";
                Param.Validate(Value, JSON.GetString(TempParam.Name, false));
                Param.Modify(false);
            until TempParam.Next = 0;

        JSON.RestoreScope(ScopeID);
        exit(true);
    end;

    procedure CopyParametersFromActionToTempParam(ActionCode: Code[20]; var TempParam: Record "NPR POS Parameter Value")
    var
        ActionParam: Record "NPR POS Action Parameter";
    begin
        with ActionParam do begin
            SetRange("POS Action Code", ActionCode);
            if FindSet then
                repeat
                    TempParam."Action Code" := ActionCode;
                    TempParam.Name := Name;
                    TempParam."Data Type" := "Data Type";
                    TempParam.Value := "Default Value";
                    TempParam.Insert;
                until Next = 0;
        end;
    end;

    procedure EditParametersDirect(var TempParam: Record "NPR POS Parameter Value" temporary)
    var
        EditParams: Page "NPR POS Param. Values Temp.";
    begin
        EditParams.SetDataToEdit(TempParam);
        EditParams.RunModal();
        EditParams.GetEditedData(TempParam);
    end;
}

