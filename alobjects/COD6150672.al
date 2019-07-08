codeunit 6150672 "POS Action - View Web Depen."
{
    // NPR5.47/MHA /20181026  CASE 326640 Object created - view Web Client Dependency

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'View Web Client Dependency';
        [WithEvents]
        Model: DotNet Model;
        ActiveModelID: Guid;

    local procedure ActionCode(): Text
    begin
        exit ('VIEW_WEB_DEP');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('0.1');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do begin
          if DiscoverAction(
            ActionCode(),
            Text000,
            ActionVersion(),
            Type::Generic,
            "Subscriber Instances Allowed"::Multiple)
          then begin
            RegisterWorkflowStep('view_web_dependency','respond();');
            RegisterWorkflow(false);

            RegisterTextParameter('css_code','');
            RegisterTextParameter('html_code','');
          end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', true, true)]
    local procedure OnLookupCssCode(var POSParameterValue: Record "POS Parameter Value";Handled: Boolean)
    var
        WebClientDependency: Record "Web Client Dependency";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
          exit;
        if POSParameterValue.Name <> 'css_code' then
          exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
          exit;

        Handled := true;

        WebClientDependency.SetRange(Type,WebClientDependency.Type::CSS);
        if PAGE.RunModal(PAGE::"Web Client Dependencies",WebClientDependency) = ACTION::LookupOK then
          POSParameterValue.Value := WebClientDependency.Code;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', true, true)]
    local procedure OnLookupHtmlCode(var POSParameterValue: Record "POS Parameter Value";Handled: Boolean)
    var
        WebClientDependency: Record "Web Client Dependency";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
          exit;
        if POSParameterValue.Name <> 'html_code' then
          exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
          exit;

        Handled := true;

        WebClientDependency.SetRange(Type,WebClientDependency.Type::HTML);
        if PAGE.RunModal(PAGE::"Web Client Dependencies",WebClientDependency) = ACTION::LookupOK then
          POSParameterValue.Value := WebClientDependency.Code;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        case WorkflowStep of
          'view_web_dependency':
            OnActionViewWebDependency(JSON,FrontEnd);
        end;

        Handled := true;
    end;

    local procedure OnActionViewWebDependency(JSON: Codeunit "POS JSON Management";FrontEnd: Codeunit "POS Front End Management")
    begin
        CreateUserInterface(JSON);
        ActiveModelID := FrontEnd.ShowModel(Model);
    end;

    local procedure "--- UI"()
    begin
    end;

    local procedure CreateUserInterface(JSON: Codeunit "POS JSON Management")
    begin
        Model := Model.Model();
        Model.AddHtml(InitHtml(JSON));
        Model.AddStyle(InitCss(JSON));
        Model.AddScript(InitScript());
    end;

    local procedure InitCss(JSON: Codeunit "POS JSON Management") Css: Text
    var
        WebClientDependency: Record "Web Client Dependency";
        StreamReader: DotNet StreamReader;
        InStr: InStream;
        CssCode: Code[10];
    begin
        CssCode := JSON.GetStringParameter('css_code',true);
        WebClientDependency.Get(WebClientDependency.Type::CSS,CssCode);
        WebClientDependency.CalcFields(BLOB);
        WebClientDependency.BLOB.CreateInStream(InStr);
        StreamReader := StreamReader.StreamReader(InStr);
        Css := StreamReader.ReadToEnd();

        exit(Css);
    end;

    local procedure InitHtml(JSON: Codeunit "POS JSON Management") Html: Text
    var
        WebClientDependency: Record "Web Client Dependency";
        StreamReader: DotNet StreamReader;
        InStr: InStream;
        HtmlCode: Code[10];
    begin
        HtmlCode := JSON.GetStringParameter('html_code',true);
        WebClientDependency.Get(WebClientDependency.Type::HTML,HtmlCode);
        WebClientDependency.CalcFields(BLOB);
        WebClientDependency.BLOB.CreateInStream(InStr);
        StreamReader := StreamReader.StreamReader(InStr);
        Html := StreamReader.ReadToEnd();

        exit(Html);
    end;

    local procedure InitScript() Script: Text
    var
        RetailModelScriptLibrary: Codeunit "Retail Model Script Library";
    begin
        Script := RetailModelScriptLibrary.InitAngular();
        Script += RetailModelScriptLibrary.InitJQueryUi();
        Script += RetailModelScriptLibrary.InitTouchPunch();
        Script += RetailModelScriptLibrary.InitEscClose();

        exit(Script);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnProtocolUIResponse', '', true, true)]
    local procedure OnProtocolUIResponse(POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";ModelID: Guid;Sender: Text;EventName: Text;var Handled: Boolean)
    begin
        if ModelID <> ActiveModelID then
          exit;

        Handled := true;

        case Sender of
          'close':
            begin
              FrontEnd.CloseModel(ModelID);
            end;
          else begin
            Message('%1\%2',Sender,EventName);
            FrontEnd.CloseModel(ModelID);
          end;
        end;
    end;

    trigger Model::OnModelControlEvent(control: DotNet Control;eventName: Text;data: DotNet Dictionary_Of_T_U)
    begin
    end;

    trigger Model::OnTimer()
    begin
    end;
}

