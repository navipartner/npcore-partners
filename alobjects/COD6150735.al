codeunit 6150735 "POS Workflows 2.0 - Require"
{
    // NPR5.50/JAKUBV/20190603  CASE 338666 Transport NPR5.50 - 3 June 2019


    trigger OnRun()
    begin
    end;

    var
        Text001: Label 'Custom Require method handler for require type "%1" was not found.';

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnCustomMethod', '', false, false)]
    local procedure OnRequire(Method: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        ID: Integer;
        Type: Text;
        CustomHandled: Boolean;
    begin
        if Method <> 'Require' then
          exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        ID := JSON.GetInteger('id',true);
        Type := JSON.GetString('type',true);
        case Type of
          'action':  RequireAction(POSSession,ID,JSON,FrontEnd);
          'script':  RequireScript(ID,JSON,FrontEnd);
          else
            begin
              OnRequireCustom(ID,Type,JSON,FrontEnd,CustomHandled);
              if not CustomHandled then begin
                FrontEnd.ReportBug(StrSubstNo(Text001,Type));
                exit;
              end;
            end;
        end;
    end;

    local procedure RequireScript(ID: Integer;JSON: Codeunit "POS JSON Management";FrontEnd: Codeunit "POS Front End Management")
    var
        WebClientDependency: Record "Web Client Dependency";
        Script: Text;
        ScriptId: Code[10];
    begin
        JSON.SetScope('context',true);
        ScriptId := JSON.GetString('script',true);

        if not WebClientDependency.Get(WebClientDependency.Type::JavaScript,ScriptId) then
          exit;

        Script := WebClientDependency.GetJavaScript(ScriptId);
        if Script <> '' then
          FrontEnd.RequireResponse(ID,Script);
    end;

    local procedure RequireAction(POSSession: Codeunit "POS Session";ID: Integer;JSON: Codeunit "POS JSON Management";FrontEnd: Codeunit "POS Front End Management")
    var
        POSAction: Record "POS Action";
        POSActionParam: Record "POS Action Parameter";
        POSParam: Record "POS Parameter Value";
        WorkflowAction: DotNet npNetWorkflowAction;
        WorkflowObj: DotNet npNetWorkflow;
        StreamReader: DotNet npNetStreamReader;
        "Object": DotNet npNetObject;
        InStr: InStream;
        ActionCode: Code[20];
    begin
        JSON.SetScope('context',true);
        ActionCode := JSON.GetString('action',true);

        if not POSSession.RetrieveSessionAction(ActionCode,POSAction) then begin
          if not POSAction.Get(ActionCode) or (POSAction."Workflow Engine Version" <> '2.0') or not POSAction.Workflow.HasValue then
            exit;
          POSAction.CalcFields(Workflow);
        end;

        WorkflowAction := WorkflowAction.WorkflowAction();
        POSAction.Workflow.CreateInStream(InStr);
        StreamReader := StreamReader.StreamReader(InStr);
        WorkflowAction.Workflow := WorkflowObj.FromJsonString(StreamReader.ReadToEnd(),GetDotNetType(WorkflowObj));
        if POSAction."Bound to DataSource" then
          WorkflowAction.Content.Add('DataBinding',true);
        if POSAction."Custom JavaScript Logic".HasValue then begin
          POSAction.GetCustomJavaScriptLogic(Object);
          WorkflowAction.Content.Add('CustomJavaScript',Object);
        end;
        if POSAction.Description <> '' then
          WorkflowAction.Content.Add('Description', POSAction.Description);

        POSActionParam.SetRange("POS Action Code",POSAction.Code);
        if POSActionParam.FindSet then
          repeat
            POSParam."Action Code" := POSAction.Code;
            POSParam.Name := POSActionParam.Name;
            POSParam."Data Type" := POSActionParam."Data Type";
            POSParam.Value := POSActionParam."Default Value";
            POSParam.AddParameterToAction(WorkflowAction);
          until POSActionParam.Next = 0;

        FrontEnd.RequireResponse(ID,WorkflowAction);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRequireCustom(ID: Integer;Type: Text;Context: Codeunit "POS JSON Management";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    begin
    end;
}

