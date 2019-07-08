codeunit 6151127 "POS Action - Insert Item AddOn"
{
    // NPR5.48/MHA /20181113  CASE 334922 Object created - Insert Item AddOns directly from POS Action

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        CurrNpIaItemAddOn: Record "NpIa Item AddOn";
        [WithEvents]
        Model: DotNet npNetModel;
        ActiveModelID: Guid;
        Text000: Label 'Insert Item AddOns directly from POS Action';

    local procedure ActionCode(): Text
    begin
        exit('INSERT_ITEM_ADDONS');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
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
            RegisterWorkflowStep('select_addon',
              'if (param.ItemAddOnNo) {' +
              '  context.item_addon = param.ItemAddOnNo;' +
              '} else {' +
              '  respond();' +
              '}'
            );
            RegisterWorkflowStep('insert_addons',
              'if (context.item_addon) {' +
              '  respond();' +
              '}'
            );
            RegisterWorkflow(false);

            RegisterTextParameter('ItemAddOnNo','');
          end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', true, true)]
    local procedure OnLookupItemAddOn(var POSParameterValue: Record "POS Parameter Value";Handled: Boolean)
    var
        NpIaItemAddOn: Record "NpIa Item AddOn";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
          exit;
        if POSParameterValue.Name <> 'ItemAddOnNo' then
          exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
          exit;

        Handled := true;

        NpIaItemAddOn.SetRange(Enabled,true);
        if PAGE.RunModal(0,NpIaItemAddOn) = ACTION::LookupOK then
          POSParameterValue.Value := NpIaItemAddOn."No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        case WorkflowStep of
          'select_addon':
            OnActionSelectAddOn(JSON,FrontEnd);
          'insert_addons' :
            OnActionInsertAddOns(JSON,POSSession,FrontEnd);
        end;

        Handled := true;
    end;

    local procedure OnActionSelectAddOn(JSON: Codeunit "POS JSON Management";FrontEnd: Codeunit "POS Front End Management")
    var
        NpIaItemAddOn: Record "NpIa Item AddOn";
    begin
        NpIaItemAddOn.SetRange(Enabled,true);
        if PAGE.RunModal(0,NpIaItemAddOn) <> ACTION::LookupOK then
          exit;

        JSON.SetContext('item_addon',NpIaItemAddOn."No.");
        FrontEnd.SetActionContext(ActionCode(),JSON);
    end;

    local procedure OnActionInsertAddOns(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        NpIaItemAddOn: Record "NpIa Item AddOn";
        SalePOS: Record "Sale POS";
        POSSale: Codeunit "POS Sale";
        AddOnNo: Code[20];
    begin
        JSON.SetScope('/',true);
        AddOnNo := JSON.GetString('item_addon',true);
        NpIaItemAddOn.Get(AddOnNo);
        NpIaItemAddOn.TestField(Enabled);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        CurrNpIaItemAddOn := NpIaItemAddOn;
        CreateUserInterface(SalePOS,NpIaItemAddOn);
        ActiveModelID := FrontEnd.ShowModel(Model);
    end;

    local procedure "--- UI"()
    begin
    end;

    local procedure CreateUserInterface(SalePOS: Record "Sale POS";NpIaItemAddOn: Record "NpIa Item AddOn")
    begin
        Model := Model.Model();
        Model.AddHtml(InitHtml());
        Model.AddStyle(InitCss());
        Model.AddScript(InitScript(SalePOS,NpIaItemAddOn));
    end;

    local procedure "--- Init"()
    begin
    end;

    local procedure WebDepCode(): Code[10]
    begin
        exit('ITEM_ADDON');
    end;

    local procedure InitCss() Css: Text
    var
        WebClientDependency: Record "Web Client Dependency";
        StreamReader: DotNet npNetStreamReader;
        InStr: InStream;
    begin
        if WebClientDependency.Get(WebClientDependency.Type::CSS,WebDepCode()) and WebClientDependency.BLOB.HasValue then begin
          WebClientDependency.CalcFields(BLOB);
          WebClientDependency.BLOB.CreateInStream(InStr);
          StreamReader := StreamReader.StreamReader(InStr);
          Css := StreamReader.ReadToEnd;

          exit(Css);
        end;
    end;

    local procedure InitHtml() Html: Text
    var
        WebClientDependency: Record "Web Client Dependency";
        StreamReader: DotNet npNetStreamReader;
        InStr: InStream;
    begin
        if WebClientDependency.Get(WebClientDependency.Type::HTML,WebDepCode()) and WebClientDependency.BLOB.HasValue then begin
          WebClientDependency.CalcFields(BLOB);
          WebClientDependency.BLOB.CreateInStream(InStr);
          StreamReader := StreamReader.StreamReader(InStr);
          Html := StreamReader.ReadToEnd;

          exit(Html);
        end;
    end;

    local procedure InitScript(SalePOS: Record "Sale POS";NpIaItemAddOn: Record "NpIa Item AddOn") Script: Text
    var
        RetailModelScriptLibrary: Codeunit "Retail Model Script Library";
    begin
        Script := RetailModelScriptLibrary.InitAngular();
        Script += RetailModelScriptLibrary.InitJQueryUi();
        Script += RetailModelScriptLibrary.InitTouchPunch();
        Script += RetailModelScriptLibrary.InitEscClose();
        Script += InitScriptData(SalePOS,NpIaItemAddOn);

        exit(Script);
    end;

    local procedure InitScriptData(SalePOS: Record "Sale POS";NpIaItemAddOn: Record "NpIa Item AddOn") Script: Text
    var
        NpIaItemAddOnMgt: Codeunit "NpIa Item AddOn Mgt.";
    begin
        Script := '$(function () {' +
          'var appElement = document.querySelector(''[ng-app=navApp]'');' +
          'var $scope = angular.element(appElement).scope();' +
          '$scope.$apply(function() {';

        Script += NpIaItemAddOnMgt.InitScriptAddOnLines(SalePOS,0,NpIaItemAddOn);
        Script += NpIaItemAddOnMgt.InitScriptLabels(NpIaItemAddOn);

        Script += '});' +
          '});';
    end;

    local procedure "--- Approve"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnProtocolUIResponse', '', true, true)]
    local procedure OnProtocolUIResponse(POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";ModelID: Guid;Sender: Text;EventName: Text;var Handled: Boolean)
    begin
        if ModelID <> ActiveModelID then
          exit;

        Handled := true;

        case Sender of
          'approve':
            begin
              Approve(EventName,FrontEnd);
              FrontEnd.CloseModel(ModelID);
            end;
          'cancel','close':
            begin
              FrontEnd.CloseModel(ModelID);
            end;
        end;
    end;

    local procedure Approve(JsonText: Text;FrontEnd: Codeunit "POS Front End Management")
    var
        POSSession: Codeunit "POS Session";
        NpIaItemAddOnMgt: Codeunit "NpIa Item AddOn Mgt.";
        POSJavaScriptInterface: Codeunit "POS JavaScript Interface";
        AddOnLines: DotNet npNetJToken;
    begin
        AddOnLines := AddOnLines.Parse(JsonText);
        FrontEnd.GetSession(POSSession);
        NpIaItemAddOnMgt.InsertPOSAddOnLines(CurrNpIaItemAddOn,AddOnLines,POSSession,0);

        POSSession.RequestRefreshData();
        POSJavaScriptInterface.RefreshData(POSSession,FrontEnd);
    end;

    trigger Model::OnModelControlEvent(control: DotNet npNetControl;eventName: Text;data: DotNet npNetDictionary_Of_T_U)
    begin
    end;

    trigger Model::OnTimer()
    begin
    end;
}

