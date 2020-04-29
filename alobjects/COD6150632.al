codeunit 6150632 "JavaScript Bridge Management"
{

    trigger OnRun()
    begin
    end;

    var
        [RunOnClient]
        Bridge: DotNet npNetIBridge;
        Initialized: Boolean;
        Text_BridgeNotInitialzied: Label 'JavaScript Bridge has not been initialized. Please, make sure to call Initialize before invoking individual Bridge functions.';
        Text_RequestedDependencyScriptNotFound: Label 'Requested dependency script %1 is not available in your instance of Microsoft Dynamics NAV. It must be deployed in Web Client Dependencies before you can use this module.';
        AdHocModuleId: Integer;

    procedure Initialize(BridgeIn: DotNet npNetIFramework0)
    begin
        Bridge := BridgeIn;
        Initialized := true;
    end;

    procedure InvokeMethod(Method: Text;EventContent: DotNet npNetObject): Boolean
    begin
        case Method of
          'RequestModule': Method_RequestModule(EventContent);
          else
            exit(false);
        end;

        exit(true);
    end;

    local procedure "--- Common public methods ---"()
    begin
    end;

    procedure SetSize(Width: Text;Height: Text)
    var
        SetSizeRequest: DotNet npNetDictionary_Of_T_U;
    begin
        InitializeRequest('SetSize',SetSizeRequest);
        if Width <> '' then
          SetSizeRequest.Add('width',Width);
        if Height <> '' then
          SetSizeRequest.Add('height',Height);
        InvokeFrontEndAsync(SetSizeRequest);
    end;

    procedure SetStyle(Style: Text)
    var
        SetStyleRequest: DotNet npNetDictionary_Of_T_U;
    begin
        // Sets a stylesheet. You can set as many different styles as you want.

        InitializeRequest('SetStyleSheet',SetStyleRequest);
        SetStyleRequest.Add('style',Style);
        InvokeFrontEndAsync(SetStyleRequest);
    end;

    procedure SetScript(Script: Text)
    var
        SetScriptRequest: DotNet npNetDictionary_Of_T_U;
    begin
        // Invokes a simple JavaScript. This should only be used for simpler features, and not for full-blown modules.
        // The scripts invoked through SetScript will execute immediately without any safety checks, but they don't
        // come with the safety check of dependencies. They always run, and thus may cause runtime errors.

        InitializeRequest('SetScript',SetScriptRequest);
        SetScriptRequest.Add('script',Script);
        InvokeFrontEndAsync(SetScriptRequest);
    end;

    procedure RegisterAdHocModule(ModuleName: Text;Html: Text;Css: Text;Script: Text)
    var
        RegisterModuleRequest: DotNet npNetDictionary_Of_T_U;
    begin
        SetStyle(Css);
        AdHocModuleId += 1;

        InitializeRequest('RegisterModule',RegisterModuleRequest);
        RegisterModuleRequest.Add('Name',ModuleName + Format(AdHocModuleId));
        RegisterModuleRequest.Add('Script',
          '(function() {' +
          Script + '; ' +
          '  var $_ctrl_add_in_$ = document.getElementById("controlAddIn"); ' +
          '  $_ctrl_add_in_$.innerHTML = ''' + Html + ''';' +
          '})()');
        InvokeFrontEndAsync(RegisterModuleRequest);
    end;

    local procedure "--- End-to-end public methods to perform specific bridge operations ---"()
    begin
    end;

    procedure EmbedHtml(Html: Text)
    begin
        RegisterAdHocModule('EmbeddedHtml',Html,'','');
    end;

    local procedure "--- InvokeMethod method implementations ---"()
    begin
    end;

    local procedure Method_RequestModule(EventContent: DotNet npNetObject)
    var
        Web: Record "Web Client Dependency";
        JSON: Codeunit "POS JSON Management";
        FrontEnd: Codeunit "POS Front End Management";
        RegisterModuleRequest: DotNet npNetDictionary_Of_T_U;
        Module: Text;
        Script: Text;
    begin
        JSON.InitializeJObjectParser(EventContent,FrontEnd);
        Module := JSON.GetString('module',true);

        Script := Web.GetJavaScript(Module);
        if Script = '' then
          Error(Text_RequestedDependencyScriptNotFound,Module);

        InitializeRequest('RegisterModule',RegisterModuleRequest);
        RegisterModuleRequest.Add('Name',Module);
        RegisterModuleRequest.Add('Script',Script);
        InvokeFrontEndAsync(RegisterModuleRequest);
    end;

    local procedure "--- Internal, local methods ---"()
    begin
    end;

    local procedure MakeSureBridgeIsInitialized()
    begin
        if IsNull(Bridge) or (not Initialized) then
          Error(Text_BridgeNotInitialzied);
    end;

    local procedure InitializeRequest(Method: Text;var Request: DotNet npNetDictionary_Of_T_U)
    begin
        Request := Request.Dictionary();
        Request.Add('Method',Method);
    end;

    local procedure InvokeFrontEndAsync(Request: DotNet npNetDictionary_Of_T_U)
    begin
        MakeSureBridgeIsInitialized();
        Bridge.InvokeFrontEndAsync(Request);
    end;

    trigger Bridge::OnFrameworkReady()
    begin
    end;

    trigger Bridge::OnInvokeMethod(method: Text;eventContent: Variant)
    begin
    end;
}

