codeunit 6150735 "NPR POS Workflows 2.0: Require"
{
    var
        CustomHandlerMissingErr: Label 'Custom Require method handler for require type "%1" was not found.';
        LookupTemplateMissingErr: Label 'Lookup template wiht code "%1" was not found.';
        ReadingErr: Label 'reading in %1';
        SettingScopeErr: Label 'setting scope in %1';

    local procedure MethodName(): Text
    begin
        exit('Require');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnCustomMethod', '', false, false)]
    local procedure OnRequire(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        ID: Integer;
        Type: Text;
        CustomHandled: Boolean;
    begin
        if Method <> MethodName() then
            exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        ID := JSON.GetIntegerOrFail('id', StrSubstNo(ReadingErr, MethodName()));
        Type := JSON.GetStringOrFail('type', StrSubstNo(ReadingErr, MethodName()));
        case Type of
            'action':
                RequireAction(POSSession, ID, JSON, FrontEnd);
            'script':
                RequireScript(ID, JSON, FrontEnd);
            'image':
                RequireImage(ID, JSON, FrontEnd);
            'picture.item':
                RequireItemPicture(ID, JSON, FrontEnd);
            'lookup':
                RequireLookupTemplate(ID, JSON, FrontEnd);
            else begin
                    OnRequireCustom(ID, Type, JSON, FrontEnd, CustomHandled);
                    if not CustomHandled then begin
                        FrontEnd.ReportBugAndThrowError(StrSubstNo(CustomHandlerMissingErr, Type));
                        exit;
                    end;
                end;
        end;
    end;

    local procedure RequireScript(ID: Integer; JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        WebClientDependency: Record "NPR Web Client Dependency";
        Script: Text;
        ScriptId: Code[10];
    begin
        JSON.SetScope('context', StrSubstNo(SettingScopeErr, MethodName()));
        ScriptId := CopyStr(JSON.GetStringOrFail('script', StrSubstNo(ReadingErr, MethodName())), 1, MaxStrLen(ScriptId));

        if not WebClientDependency.Get(WebClientDependency.Type::JavaScript, ScriptId) then
            exit;

        Script := WebClientDependency.GetJavaScript(ScriptId);
        if Script <> '' then
            FrontEnd.RequireResponse(ID, Script);
    end;

    local procedure RequireAction(POSSession: Codeunit "NPR POS Session"; ID: Integer; JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSAction: Record "NPR POS Action";
        POSActionParam: Record "NPR POS Action Parameter";
        POSParam: Record "NPR POS Parameter Value";
        WorkflowAction: Codeunit "NPR Workflow Action";
        Workflow: Codeunit "NPR Workflow";
        JavaScriptJson: JsonObject;
        InStr: InStream;
        ActionCode: Code[20];
    begin
        JSON.SetScope('context', StrSubstNo(SettingScopeErr, MethodName()));
        ActionCode := CopyStr(JSON.GetStringOrFail('action', StrSubstNo(ReadingErr, MethodName())), 1, MaxStrLen(ActionCode));

        if not POSSession.RetrieveSessionAction(ActionCode, POSAction) then begin
            if not POSAction.Get(ActionCode) or (POSAction."Workflow Engine Version" <> '2.0') or not POSAction.Workflow.HasValue() then
                exit;
            POSAction.CalcFields(Workflow);
        end;

        POSAction.Workflow.CreateInStream(InStr);
        WorkflowAction.GetWorkflow(Workflow);
        Workflow.DeserializeFromJsonStream(InStr);
        if POSAction."Bound to DataSource" then
            WorkflowAction.Content().Add('DataBinding', true);
        if POSAction."Custom JavaScript Logic".HasValue() then begin
            JavaScriptJson := POSAction.GetCustomJavaScriptLogic();
            WorkflowAction.Content().Add('CustomJavaScript', JavaScriptJson);
        end;
        if POSAction.Description <> '' then
            WorkflowAction.Content().Add('Description', POSAction.Description);

        POSActionParam.SetRange("POS Action Code", POSAction.Code);
        if POSActionParam.FindSet() then
            repeat
                POSParam."Action Code" := POSAction.Code;
                POSParam.Name := POSActionParam.Name;
                POSParam."Data Type" := POSActionParam."Data Type";
                POSParam.Value := POSActionParam."Default Value";
                POSParam.AddParameterToAction(WorkflowAction);
            until POSActionParam.Next() = 0;

        FrontEnd.RequireResponse(ID, WorkflowAction.GetJson());
    end;

    local procedure RequireImage(ID: Integer; JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        WebClientDependency: Record "NPR Web Client Dependency";
        ImageCode: Code[10];
    begin
        JSON.SetScope('context', StrSubstNo(SettingScopeErr, MethodName()));
        ImageCode := CopyStr(JSON.GetStringOrFail('code', StrSubstNo(ReadingErr, MethodName())), 1, MaxStrLen(ImageCode));
        FrontEnd.RequireResponse(ID, WebClientDependency.GetDataUri(ImageCode));
    end;

    local procedure RequireItemPicture(ID: Integer; JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        ItemNo: Code[20];
        Item: Record Item;
        Media: Record "Tenant Media";
        Base64: Codeunit "Base64 Convert";
        Stream: InStream;
        DataUri: Text;
        MediaId: Guid;
        DataUriLabel: Label 'data:%1;base64,%2', Locked = true;
    begin
        JSON.SetScope('context', StrSubstNo(SettingScopeErr, MethodName()));
        ItemNo := CopyStr(JSON.GetStringOrFail('id', StrSubstNo(ReadingErr, MethodName())), 1, MaxStrLen(ItemNo));
        if Item.Get(ItemNo) and (Item.Picture.Count > 0) then begin
            MediaId := Item.Picture.Item(1);
            Media.Get(MediaId);
            if (Media.Content.HasValue()) then begin
                Media.CalcFields(Content);
                Media.Content.CreateInStream(Stream);
                DataUri := StrSubstNo(DataUriLabel, Media."Mime Type", Base64.ToBase64(Stream));
            end;
        end;
        FrontEnd.RequireResponse(ID, DataUri);
    end;

    local procedure RequireLookupTemplate(ID: Integer; JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Template: JsonObject;
        TemplateCode: Text;
        Handled: Boolean;
    begin
        JSON.SetScope('context', StrSubstNo(SettingScopeErr, MethodName()));
        TemplateCode := JSON.GetStringOrFail('code', StrSubstNo(ReadingErr, MethodName()));
        OnRequireLookupTemplate(TemplateCode, Template, Handled);
        if not Handled then
            FrontEnd.ReportBugAndThrowError(StrSubstNo(LookupTemplateMissingErr, TemplateCode))
        else
            FrontEnd.RequireResponse(ID, Template);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRequireCustom(ID: Integer; Type: Text; Context: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRequireLookupTemplate(TemplateCode: Text; Template: JsonObject; var Handled: Boolean)
    begin
    end;
}
