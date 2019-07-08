codeunit 6151128 "POS Action - Run Item AddOn"
{
    // NPR5.48/MHA /20181113  CASE 334922 Object created - Insert Item AddOns from the currently selected POS Sales Line

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        CurrNpIaItemAddOn: Record "NpIa Item AddOn";
        [WithEvents]
        Model: DotNet npNetModel;
        ActiveModelID: Guid;
        Text000: Label 'Insert Item AddOns from the currently selected POS Sales Line';

    local procedure ActionCode(): Text
    begin
        exit('RUN_ITEM_ADDONS');
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
            RegisterWorkflowStep('run_addons','respond();');

            RegisterWorkflow(false);
            Sender.RegisterDataSourceBinding('BUILTIN_SALELINE');
            Sender.RegisterCustomJavaScriptLogic('enable','return row.getField("ItemAddOn.ItemAddOn").rawValue;');
          end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        case WorkflowStep of
          'run_addons' :
            OnActionRunAddOns(POSSession,FrontEnd);
        end;

        Handled := true;
    end;

    local procedure OnActionRunAddOns(POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        Item: Record Item;
        NpIaItemAddOn: Record "NpIa Item AddOn";
        SalePOS: Record "Sale POS";
        SaleLinePOS: Record "Sale Line POS";
        POSSale: Codeunit "POS Sale";
        POSSaleLine: Codeunit "POS Sale Line";
        AddOnNo: Code[20];
        AppliesToLineNo: Integer;
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        AppliesToLineNo := FindAppliesToLineNo(SaleLinePOS);
        SaleLinePOS.Get(SaleLinePOS."Register No.",SaleLinePOS."Sales Ticket No.",SaleLinePOS.Date,SaleLinePOS."Sale Type",AppliesToLineNo);

        if SaleLinePOS.Type <> SaleLinePOS.Type::Item then
          exit;
        Item.Get(SaleLinePOS."No.");
        Item.TestField("Item AddOn No.");

        NpIaItemAddOn.Get(Item."Item AddOn No.");
        NpIaItemAddOn.TestField(Enabled);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        CurrNpIaItemAddOn := NpIaItemAddOn;
        CreateUserInterface(SalePOS,AppliesToLineNo,NpIaItemAddOn);
        ActiveModelID := FrontEnd.ShowModel(Model);
    end;

    local procedure "--- UI"()
    begin
    end;

    local procedure CreateUserInterface(SalePOS: Record "Sale POS";AppliesToLineNo: Integer;NpIaItemAddOn: Record "NpIa Item AddOn")
    begin
        Model := Model.Model();
        Model.AddHtml(InitHtml());
        Model.AddStyle(InitCss());
        Model.AddScript(InitScript(SalePOS,AppliesToLineNo,NpIaItemAddOn));
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

    local procedure InitScript(SalePOS: Record "Sale POS";AppliesToLineNo: Integer;NpIaItemAddOn: Record "NpIa Item AddOn") Script: Text
    var
        RetailModelScriptLibrary: Codeunit "Retail Model Script Library";
    begin
        Script := RetailModelScriptLibrary.InitAngular();
        Script += RetailModelScriptLibrary.InitJQueryUi();
        Script += RetailModelScriptLibrary.InitTouchPunch();
        Script += RetailModelScriptLibrary.InitEscClose();
        Script += InitScriptData(SalePOS,AppliesToLineNo,NpIaItemAddOn);

        exit(Script);
    end;

    local procedure InitScriptData(SalePOS: Record "Sale POS";AppliesToLineNo: Integer;NpIaItemAddOn: Record "NpIa Item AddOn") Script: Text
    var
        NpIaItemAddOnMgt: Codeunit "NpIa Item AddOn Mgt.";
    begin
        Script := '$(function () {' +
          'var appElement = document.querySelector(''[ng-app=navApp]'');' +
          'var $scope = angular.element(appElement).scope();' +
          '$scope.$apply(function() {';

        Script += NpIaItemAddOnMgt.InitScriptAddOnLines(SalePOS,AppliesToLineNo,NpIaItemAddOn);
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
        SaleLinePOS: Record "Sale Line POS";
        POSSaleLine: Codeunit "POS Sale Line";
        POSSession: Codeunit "POS Session";
        NpIaItemAddOnMgt: Codeunit "NpIa Item AddOn Mgt.";
        POSJavaScriptInterface: Codeunit "POS JavaScript Interface";
        AddOnLines: DotNet npNetJToken;
        AppliesToLineNo: Integer;
    begin
        AddOnLines := AddOnLines.Parse(JsonText);
        FrontEnd.GetSession(POSSession);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        AppliesToLineNo := FindAppliesToLineNo(SaleLinePOS);
        NpIaItemAddOnMgt.InsertPOSAddOnLines(CurrNpIaItemAddOn,AddOnLines,POSSession,AppliesToLineNo);

        POSSession.RequestRefreshData();
        POSJavaScriptInterface.RefreshData(POSSession,FrontEnd);
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure FindAppliesToLineNo(SaleLinePOS: Record "Sale Line POS"): Integer
    var
        NpIaSaleLinePOSAddOn: Record "NpIa Sale Line POS AddOn";
    begin
        NpIaSaleLinePOSAddOn.SetRange("Register No.",SaleLinePOS."Register No.");
        NpIaSaleLinePOSAddOn.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
        NpIaSaleLinePOSAddOn.SetRange("Sale Type",SaleLinePOS."Sale Type");
        NpIaSaleLinePOSAddOn.SetRange("Sale Date",SaleLinePOS.Date);
        NpIaSaleLinePOSAddOn.SetRange("Sale Line No.",SaleLinePOS."Line No.");
        if NpIaSaleLinePOSAddOn.FindFirst then
          exit(NpIaSaleLinePOSAddOn."Applies-to Line No.");

        if SaleLinePOS.Accessory then
          exit(SaleLinePOS."Main Line No.");

        exit(SaleLinePOS."Line No.");
    end;

    trigger Model::OnModelControlEvent(control: DotNet npNetControl;eventName: Text;data: DotNet npNetDictionary_Of_T_U)
    begin
    end;

    trigger Model::OnTimer()
    begin
    end;
}

