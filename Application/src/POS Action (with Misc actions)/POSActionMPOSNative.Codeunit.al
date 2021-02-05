codeunit 6150825 "NPR POS Action - MPOS Native"
{
    SingleInstance = true;

    var
        ActionDescription: Label 'This is a built-in action for running a report';
        Err_AdmissionFailed: Label 'Error opening the admission webpage';
        Err_EODFailed: Label 'Error running EndOfDay on the terminal';
        Err_ScanditFailed: Label 'Error running the Scandit Barcode Reader';
        Model: DotNet NPRNetModel;
        ProtocolError: Label 'An unexpected error ocurred in the %1 protocol:\%2';
        ERROR_SESSION: Label 'Critical Error: Session object could not be retrieved for %1. ';
        Err_ExternalActionNotHandled: Label 'External Action %1 not handled.';
        ActiveModelID: Guid;
        TransactionDone: Boolean;

    local procedure ActionCode(): Text
    begin
        exit('MPOSNATIVE');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.3');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    var
        NativeActionSetting: Enum "NPR POS Native Action Setting";
        ActionSettingName: Text;
        Options: Text;
    begin
        with Sender do
            if DiscoverAction(
              ActionCode,
              ActionDescription,
              ActionVersion,
              Type::Generic,
              "Subscriber Instances Allowed"::Multiple)
            then begin
                RegisterWorkflowStep('1', 'respond();');
                RegisterWorkflow(false);

                foreach ActionSettingName in NativeActionSetting.Names do begin
                    if Options <> '' then
                        Options += ';';
                    Options += ActionSettingName;
                end;
                RegisterOptionParameter('NativeAction', Options, 'ADMISSION');
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        NativeActionSetting: Enum "NPR POS Native Action Setting";
        actiontype: Enum "NPR Action Type";
        MPOSAppSetup: Record "NPR MPOS App Setup";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR Sale POS";
        POSStore: Record "NPR POS Store";
        JSONString: Text;
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR Sale Line POS";
        Barcode: Text;
        ExternalActionHandled: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSStore.get(SalePOS."POS Store Code");

        //-NPR5.39
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        if not MPOSAppSetup.Get(SalePOS."Register No.") then
            exit;

        if not MPOSAppSetup.Enable then
            exit;

        InitState();

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScope('parameters', true);

        NativeActionSetting := Enum::"NPR POS Native Action Setting".FromInteger(JSON.GetInteger('NativeAction', true));

        case NativeActionSetting of
            NativeActionSetting::ADMISSION:
                begin
                    MPOSAppSetup.TestField("Ticket Admission Web Url");
                    JSONString := BuildJSONParams(Format(NativeActionSetting), MPOSAppSetup."Ticket Admission Web Url", '', '', '', Err_AdmissionFailed);
                end;
            NativeActionSetting::EOD:
                begin
                    JSONString := BuildJSONParams(Format(NativeActionSetting), '', SalePOS."Register No.", '', '', Err_EODFailed);
                end;
            NativeActionSetting::PRINTLASTRECEIPT:
                begin
                    JSONString := BuildJSONParams(Format(NativeActionSetting), '', '', '', '', Err_EODFailed);
                end;
            NativeActionSetting::SCANDITITEMINFO:
                begin
                    JSONString := BuildJSONParams(Format(NativeActionSetting), '-1', '10', '', '10', Err_ScanditFailed);
                end;
            NativeActionSetting::SCANDITFINDITEM:
                begin
                    FindItemBarcode(SaleLinePOS, Barcode);
                    if Barcode <> '' then
                        JSONString := BuildJSONParams(Format(NativeActionSetting), '0', '10', Barcode, '10', Err_ScanditFailed)
                end;
            NativeActionSetting::SCANDITSCAN:
                begin
                    JSONString := BuildJSONParams(Format(NativeActionSetting), '0', '0', '0', '0', Err_ScanditFailed)
                end;
            else begin
                    OnExternalAction(SalePOS, SaleLinePOS, NativeActionSetting, JSONString, ExternalActionHandled);
                    if not ExternalActionHandled then
                        Error(Err_ExternalActionNotHandled, NativeActionSetting);
                end;

        end;

        if JSONString <> '' then
            ExecuteNativeAction(Format(NativeActionSetting), JSONString);
        Handled := true;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnExternalAction(SalePOS: Record "NPR Sale POS"; SaleLinePOS: Record "NPR Sale Line POS"; NativeActionSetting: Enum "NPR POS Native Action Setting"; var JSONString: Text; var Handled: Boolean)
    begin
    end;

    local procedure BuildJSONParams(RequestMethod: Text; BaseAddress: Text; Endpoint: Text; PrintJob: Text; RequestType: Text; ErrorCaption: Text) JSON: Text
    begin
        JSON := '{';
        JSON += '"RequestMethod": "' + RequestMethod + '",';
        JSON += '"BaseAddress": "' + BaseAddress + '",';
        JSON += '"Endpoint": "' + Endpoint + '",';
        JSON += '"PrintJob": "' + PrintJob + '",';
        JSON += '"RequestType": "' + RequestType + '",';
        JSON += '"ErrorCaption": "' + ErrorCaption + '"';
        JSON += '}';
    end;

    procedure BuildJSONGenericParams(RequestMethod: Text; Value1: Text; Value2: Text; Value3: Text; Value4: Text; Value5: Text; ErrorCaption: Text) JSON: Text
    begin
        JSON := '{';
        JSON += '"RequestMethod": "' + RequestMethod + '",';
        JSON += '"Value1": "' + Value1 + '",';
        JSON += '"Value2": "' + Value2 + '",';
        JSON += '"Value3": "' + Value3 + '",';
        JSON += '"Value4": "' + Value4 + '",';
        JSON += '"Value5": "' + Value5 + '",';
        JSON += '"ErrorCaption": "' + ErrorCaption + '"';
        JSON += '}';
    end;

    local procedure ExecuteNativeAction(RequestMethod: Text; JSON: Text)
    var
        JSBridge: Page "NPR JS Bridge";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
    begin
        if not POSSession.IsActiveSession(POSFrontEnd) then
            Error(ERROR_SESSION, 'MPOSNATIVE');

        CreateUserInterface(JSON);
        ActiveModelID := POSFrontEnd.ShowModel(Model);
        RequestClose(POSFrontEnd);
    end;

    local procedure FindItemBarcode(SaleLinePOS: Record "NPR Sale Line POS"; var Barcode: Text): Boolean
    var
        BarcodeLibrary: Codeunit "NPR Barcode Library";
        ResolvingTable: Integer;
    begin
        if not (SaleLinePOS.Type = SaleLinePOS.Type::Item) then
            exit(false);

        BarcodeLibrary.GetItemVariantBarcode(Barcode, SaleLinePOS."No.", SaleLinePOS."Variant Code", ResolvingTable, true);
        exit(true);
    end;

    local procedure CreateUserInterface(JsonObject: Text)
    var
        WebClientDependency: Record "NPR Web Client Dependency";
        Factory: DotNet NPRNetControlFactory;
        JSString: Text;
    begin
        Model := Model.Model();
        JSString := 'function CallNativeFunction(jsonobject) { ';
        JSString += 'debugger; ';
        JSString += 'var userAgent = navigator.userAgent || navigator.vendor || window.opera; if (/android/i.test(userAgent)) { ';
        JSString += 'window.top.mpos.handleBackendMessage(jsonobject); } ';
        JSString += 'if (/iPad|iPhone|iPod|Macintosh/.test(userAgent) && !window.MSStream) { ';
        JSString += 'window.webkit.messageHandlers.invokeAction.postMessage(jsonobject);}}';
        Model.AddScript(JSString);
        Model.AddScript('CallNativeFunction(' + JsonObject + ');');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnProtocolUIResponse', '', false, false)]
    local procedure OnProtocolUIResponse(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; ModelID: Guid; Sender: Text; EventName: Text; var Handled: Boolean)
    var
        WebClientDependency: Record "NPR Web Client Dependency";
        ModelIDVar: Variant;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTInterface: Codeunit "NPR EFT Interface";
    begin
        if ModelID <> ActiveModelID then
            exit;

        Handled := true;

        if TransactionDone then
            exit;

        case Sender of
            'btnClose':
                RequestClose(FrontEnd);
            'timerLabel':
                RequestClose(FrontEnd);
        end;
    end;

    local procedure RequestClose(FrontEnd: Codeunit "NPR POS Front End Management")
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        TransactionDone := true;
        FrontEnd.CloseModel(ActiveModelID);
        Clear(ActiveModelID);
    end;

    local procedure InitState()
    begin
        Clear(Model);
        Clear(ActiveModelID);
        Clear(TransactionDone);
    end;

    local procedure HandleProtocolError(FrontEnd: Codeunit "NPR POS Front End Management")
    var
        ErrorText: Text;
    begin
        TransactionDone := true;
        ErrorText := StrSubstNo(ProtocolError, 'MPOSNATIVE', GetLastErrorText);

        if not IsNullGuid(ActiveModelID) then
            FrontEnd.CloseModel(ActiveModelID);

        Message(ErrorText);
    end;
}