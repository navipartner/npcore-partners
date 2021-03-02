codeunit 6150632 "NPR JavaScript Bridge Mgt."
{
    var
        Initialized: Boolean;
        Bridge: ControlAddIn "NPR Bridge";
        AdHocModuleId: Integer;
        BridgeNotInitialziedErr: Label 'JavaScript Bridge has not been initialized. Please, make sure to call Initialize before invoking individual Bridge functions.';
        RequestedDependencyScriptNotFoundErr: Label 'Requested dependency script %1 is not available in your instance of Microsoft Dynamics NAV. It must be deployed in Web Client Dependencies before you can use this module.', Comment = '%1 = Requested dependency script';

    procedure Initialize(BridgeIn: ControlAddIn "NPR Bridge")
    begin
        Bridge := BridgeIn;
        Initialized := true;
    end;

    procedure InvokeMethod(Method: Text; EventContent: JsonObject): Boolean
    begin
        case Method of
            'RequestModule':
                Method_RequestModule(EventContent);
            else
                exit(false);
        end;

        exit(true);
    end;

    procedure SetSize(Width: Text; Height: Text)
    var
        SetSizeRequest: JsonObject;
    begin
        InitializeRequest('SetSize', SetSizeRequest);
        if Width <> '' then
            SetSizeRequest.Add('width', Width);
        if Height <> '' then
            SetSizeRequest.Add('height', Height);
        InvokeFrontEndAsync(SetSizeRequest);
    end;

    procedure SetStyle(Style: Text)
    var
        SetStyleRequest: JsonObject;
    begin
        // Sets a stylesheet. You can set as many different styles as you want.

        InitializeRequest('SetStyleSheet', SetStyleRequest);
        SetStyleRequest.Add('style', Style);
        InvokeFrontEndAsync(SetStyleRequest);
    end;

    procedure SetScript(Script: Text)
    var
        SetScriptRequest: JsonObject;
    begin
        // Invokes a simple JavaScript. This should only be used for simpler features, and not for full-blown modules.
        // The scripts invoked through SetScript will execute immediately without any safety checks, but they don't
        // come with the safety check of dependencies. They always run, and thus may cause runtime errors.
        InitializeRequest('SetScript', SetScriptRequest);
        SetScriptRequest.Add('script', Script);
        InvokeFrontEndAsync(SetScriptRequest);
    end;

    procedure RegisterAdHocModule(ModuleName: Text; Html: Text; Css: Text; Script: Text)
    var
        RegisterModuleRequest: JsonObject;
    begin
        SetStyle(Css);
        AdHocModuleId += 1;

        InitializeRequest('RegisterModule', RegisterModuleRequest);
        RegisterModuleRequest.Add('Name', ModuleName + Format(AdHocModuleId));
        RegisterModuleRequest.Add('Script',
          '(function() {' +
          Script + '; ' +
          '  var $_ctrl_add_in_$ = document.getElementById("controlAddIn"); ' +
          '  $_ctrl_add_in_$.innerHTML = ''' + Html + ''';' +
          '})()');
        InvokeFrontEndAsync(RegisterModuleRequest);
    end;

    procedure EmbedHtml(Html: Text)
    begin
        RegisterAdHocModule('EmbeddedHtml', Html, '', '');
    end;

    local procedure Method_RequestModule(EventContent: JsonObject)
    var
        Web: Record "NPR Web Client Dependency";
        FrontEnd: Codeunit "NPR POS Front End Management";
        JSON: Codeunit "NPR POS JSON Management";
        RegisterModuleRequest: JsonObject;
        Module: Text;
        Script: Text;
        RequestModuleErr: Label 'reading from RequestModule context';
    begin
        JSON.InitializeJObjectParser(EventContent, FrontEnd);
        Module := JSON.GetStringOrFail('module', RequestModuleErr);

        Script := Web.GetJavaScript(Module);
        if Script = '' then
            Error(RequestedDependencyScriptNotFoundErr, Module);

        InitializeRequest('RegisterModule', RegisterModuleRequest);
        RegisterModuleRequest.Add('Name', Module);
        RegisterModuleRequest.Add('Script', Script);
        InvokeFrontEndAsync(RegisterModuleRequest);
    end;

    local procedure MakeSureBridgeIsInitialized()
    begin
        if not Initialized then
            Error(BridgeNotInitialziedErr);
    end;

    local procedure InitializeRequest(Method: Text; var Request: JsonObject)
    begin
        Request.Add('Method', Method);
    end;

    local procedure InvokeFrontEndAsync(Request: JsonObject)
    begin
        MakeSureBridgeIsInitialized();
        Bridge.InvokeFrontEndAsync(Request);
    end;
}

