codeunit 6150735 "NPR POS Workflows 2.0: Require"
{
    var
        Text001: Label 'Custom Require method handler for require type "%1" was not found.';

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnCustomMethod', '', false, false)]
    local procedure OnRequire(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        ID: Integer;
        Type: Text;
        CustomHandled: Boolean;
    begin
        if Method <> 'Require' then
            exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        ID := JSON.GetInteger('id', true);
        Type := JSON.GetString('type', true);
        case Type of
            'action':
                RequireAction(POSSession, ID, JSON, FrontEnd);
            'script':
                RequireScript(ID, JSON, FrontEnd);
            'image':
                RequireImage(ID, JSON, FrontEnd);
            else begin
                    OnRequireCustom(ID, Type, JSON, FrontEnd, CustomHandled);
                    if not CustomHandled then begin
                        FrontEnd.ReportBug(StrSubstNo(Text001, Type));
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
        JSON.SetScope('context', true);
        ScriptId := JSON.GetString('script', true);

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
        WorkflowJson: JsonObject;
    begin
        JSON.SetScope('context', true);
        ActionCode := JSON.GetString('action', true);

        if not POSSession.RetrieveSessionAction(ActionCode, POSAction) then begin
            if not POSAction.Get(ActionCode) or (POSAction."Workflow Engine Version" <> '2.0') or not POSAction.Workflow.HasValue then
                exit;
            POSAction.CalcFields(Workflow);
        end;

        POSAction.Workflow.CreateInStream(InStr);
        WorkflowAction.GetWorkflow(Workflow);
        Workflow.DeserializeFromJsonStream(InStr);
        if POSAction."Bound to DataSource" then
            WorkflowAction.Content.Add('DataBinding', true);
        if POSAction."Custom JavaScript Logic".HasValue then begin
            JavaScriptJson := POSAction.GetCustomJavaScriptLogic();
            WorkflowAction.Content.Add('CustomJavaScript', JavaScriptJson);
        end;
        if POSAction.Description <> '' then
            WorkflowAction.Content.Add('Description', POSAction.Description);

        POSActionParam.SetRange("POS Action Code", POSAction.Code);
        if POSActionParam.FindSet then
            repeat
                POSParam."Action Code" := POSAction.Code;
                POSParam.Name := POSActionParam.Name;
                POSParam."Data Type" := POSActionParam."Data Type";
                POSParam.Value := POSActionParam."Default Value";
                POSParam.AddParameterToAction(WorkflowAction);
            until POSActionParam.Next = 0;

        FrontEnd.RequireResponse(ID, WorkflowAction.GetJson());
    end;

    local procedure RequireImage(ID: Integer; JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        WebClientDependency: Record "NPR Web Client Dependency";
        ImageCode: Code[20];
    begin
        JSON.SetScope('context', true);
        ImageCode := JSON.GetString('code', true);
        FrontEnd.RequireResponse(ID, WebClientDependency.GetDataUri(ImageCode));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRequireCustom(ID: Integer; Type: Text; Context: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
    end;
}
