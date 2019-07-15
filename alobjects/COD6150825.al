codeunit 6150825 "POS Action - MPOS Native"
{
    // NPR5.34/CLVA/20170703 CASE 280444 Upgrading MPOS functionality to transcendence
    // NPR5.39/CLVA/20170703 CASE 301776 Adding Scandit/barcode functionality to IOS
    // NPR5.50/CLVA/20190304 CASE 332844 Added parameters COUNTSALESFLOOR,COUNTSTOCKROOM,ASSIGNTAG,LOCATETAG and REFILL
    //                                   Added function BuildJSONGenericParams

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built-in action for running a report';
        POSSetup: Codeunit "POS Setup";
        Err_AdmissionFailed: Label 'Error opening the admission webpage';
        Err_EODFailed: Label 'Error running EndOfDay on the terminal';
        Err_LFRFailed: Label 'Error printing last receipt on the terminal';
        Err_ScanditFailed: Label 'Error running the Scandit Barcode Reader';
        Model: DotNet npNetModel;
        ProtocolError: Label 'An unexpected error ocurred in the %1 protocol:\%2';
        ERROR_SESSION: Label 'Critical Error: Session object could not be retrieved for %1. ';
        ActiveModelID: Guid;
        TransactionDone: Boolean;
        LOADER: Label 'Handling data...';
        Err_RFIDStockTake: Label 'Error running the RFID Stock-Take';
        Err_CSStockTakes: Label 'There are no active counting sheets for store %1';
        Err_SalesfloorClosed: Label 'Sales floor is already counted';
        Err_StockroomClosed: Label 'Stockroom is already counted';
        Err_Refill: Label 'Both Salesfloor and Stockroom needs to be counted before Refill';
        Err_RFIDRefill: Label 'Error running the RFID Refill';
        Err_StockroomNotClosed: Label 'Stockroom needs to be counted before the Sales floor';
        Err_NotApproved: Label 'Counting has not been approved';
        Err_Approved: Label 'Counting is already approved';
        Err_RefillClosed: Label 'Refill is already closed';

    local procedure ActionCode(): Text
    begin
        exit ('MPOSNATIVE');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.3');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
          if DiscoverAction(
            ActionCode,
            ActionDescription,
            ActionVersion,
            Type::Generic,
            "Subscriber Instances Allowed"::Multiple)
          then begin
            RegisterWorkflowStep('1','respond();');
            RegisterWorkflow(false);
            RegisterOptionParameter ('NativeAction', 'ADMISSION,EOD,PRINTLASTRECEIPT,SCANDITITEMINFO,SCANDITFINDITEM,COUNTSALESFLOOR,COUNTSTOCKROOM,ASSIGNTAG,LOCATETAG,REFILL,APPROVE', 'ADMISSION');
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        NativeActionSetting: Option ADMISSION,EOD,PRINTLASTRECEIPT,SCANDITITEMINFO,SCANDITFINDITEM,COUNTSALESFLOOR,COUNTSTOCKROOM,ASSIGNTAG,LOCATETAG,REFILL,APPROVE;
        MPOSAppSetup: Record "MPOS App Setup";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
        JSONString: Text;
        MPOSPaymentGateway: Record "MPOS Payment Gateway";
        POSSaleLine: Codeunit "POS Sale Line";
        SaleLinePOS: Record "Sale Line POS";
        Barcode: Text;
        Register: Record Register;
        StockTakeWorksheet: Record "Stock-Take Worksheet";
        CSStockTakes: Record "CS Stock-Takes";
        CSHelperFunctions: Codeunit "CS Helper Functions";
        CSTotalItemsbyLocations: Query "CS Total Items by Locations";
        SumInventory: Decimal;
        SumInventoryInt: Integer;
        CSStockTakesData: Record "CS Stock-Takes Data";
        CSRefillData: Record "CS Refill Data";
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        //-NPR5.39
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        //+NPR5.39
        if not MPOSAppSetup.Get(SalePOS."Register No.") then
          exit;

        if not MPOSAppSetup.Enable then
          exit;

        InitState();

        JSON.InitializeJObjectParser(Context,FrontEnd);
        JSON.SetScope('parameters',true);

        NativeActionSetting := JSON.GetInteger ('NativeAction', true);

        case NativeActionSetting of
          NativeActionSetting::ADMISSION :
            begin
              MPOSAppSetup.TestField("Ticket Admission Web Url");
              JSONString := BuildJSONParams(Format(NativeActionSetting),MPOSAppSetup."Ticket Admission Web Url", '', '', '', Err_AdmissionFailed);
            end;
          NativeActionSetting::EOD :
            begin
              MPOSAppSetup.TestField("Payment Gateway");
              MPOSPaymentGateway.Get(MPOSAppSetup."Payment Gateway");
              MPOSPaymentGateway.TestField("Merchant Id");
              JSONString := BuildJSONParams(Format(NativeActionSetting),MPOSPaymentGateway."Merchant Id", '', '', '', Err_EODFailed);
            end;
          NativeActionSetting::PRINTLASTRECEIPT :
            begin
              MPOSAppSetup.TestField("Payment Gateway");
              MPOSPaymentGateway.Get(MPOSAppSetup."Payment Gateway");
              MPOSPaymentGateway.TestField("Merchant Id");
              JSONString := BuildJSONParams(Format(NativeActionSetting),MPOSPaymentGateway."Merchant Id", '', '', '', Err_EODFailed);
            end;
          //-NPR5.39
          NativeActionSetting::SCANDITITEMINFO :
            begin
              JSONString := BuildJSONParams(Format(NativeActionSetting),'-1', '10', '', '10', Err_ScanditFailed);
            end;
          NativeActionSetting::SCANDITFINDITEM :
            begin
              FindItemBarcode(SaleLinePOS,Barcode);
              if Barcode <> '' then
                JSONString := BuildJSONParams(Format(NativeActionSetting),'0', '10', Barcode, '10', Err_ScanditFailed)
            end;
          //+NPR5.39
          //-NPR5.50 [332844]
          NativeActionSetting::COUNTSTOCKROOM :
            begin
              SelectLatestVersion;
              Register.Get(SalePOS."Register No.");
              Register.TestField("Location Code");
              CSStockTakes.SetRange(Location,Register."Location Code");
              CSStockTakes.SetRange(Closed,0DT);
              if CSStockTakes.FindFirst then begin
                if CSStockTakes."Stockroom Closed" <> 0DT then
                  Error(Err_StockroomClosed);
                if CSStockTakes."Stockroom Started" = 0DT then begin
                  CSStockTakes."Stockroom Started" := CurrentDateTime;
                  CSStockTakes."Stockroom Started By" := UserId;
                  CSStockTakes.Modify(true);
                end;
                CSTotalItemsbyLocations.SetFilter(Location_Filter,Register."Location Code");
                CSTotalItemsbyLocations.Open;
                while CSTotalItemsbyLocations.Read do begin
                  SumInventory := CSTotalItemsbyLocations.Sum_Inventory;
                end;
                Evaluate(SumInventoryInt,Format(SumInventory));
                CSTotalItemsbyLocations.Close;
                CSHelperFunctions.CreateStockTakeWorksheet(Register."Location Code",'STOCKROOM',StockTakeWorksheet);
                JSONString := BuildJSONGenericParams(Format(NativeActionSetting),CSStockTakes."Stock-Take Id",Register."Location Code",StockTakeWorksheet.Name,Format(SumInventoryInt),'',Err_RFIDStockTake);
              end else
                Error(Err_CSStockTakes,Register."Location Code");
            end;
          NativeActionSetting::COUNTSALESFLOOR :
            begin
              SelectLatestVersion;
              Register.Get(SalePOS."Register No.");
              Register.TestField("Location Code");
              CSStockTakes.SetRange(Location,Register."Location Code");
              CSStockTakes.SetRange(Closed,0DT);
              if CSStockTakes.FindFirst then begin

                if CSStockTakes."Stockroom Closed" = 0DT then
                  Error(Err_StockroomNotClosed);

                if CSStockTakes."Salesfloor Closed" <> 0DT then
                  Error(Err_SalesfloorClosed);

                if CSStockTakes."Salesfloor Started" = 0DT then begin
                  CSStockTakes."Salesfloor Started" := CurrentDateTime;
                  CSStockTakes."Salesfloor Started By" := UserId;
                  CSStockTakes.Modify(true);
                end;

                CSTotalItemsbyLocations.SetFilter(Location_Filter,Register."Location Code");
                CSTotalItemsbyLocations.Open;
                while CSTotalItemsbyLocations.Read do begin
                  SumInventory := CSTotalItemsbyLocations.Sum_Inventory;
                end;
                CSTotalItemsbyLocations.Close;

                CSStockTakesData.SetRange("Stock-Take Id",CSStockTakes."Stock-Take Id");
                CSStockTakesData.SetRange("Worksheet Name",'STOCKROOM');
                if SumInventory > CSStockTakesData.Count then
                  SumInventory := SumInventory - CSStockTakesData.Count;

                Evaluate(SumInventoryInt,Format(SumInventory));

                CSHelperFunctions.CreateStockTakeWorksheet(Register."Location Code",'SALESFLOOR',StockTakeWorksheet);
                JSONString := BuildJSONGenericParams(Format(NativeActionSetting),CSStockTakes."Stock-Take Id",Register."Location Code",StockTakeWorksheet.Name,Format(SumInventoryInt),'',Err_RFIDStockTake);
              end else
                Error(Err_CSStockTakes,Register."Location Code");
            end;
          NativeActionSetting::REFILL :
            begin
              SelectLatestVersion;
              Register.Get(SalePOS."Register No.");
              Register.TestField("Location Code");
              CSStockTakes.SetRange(Location,Register."Location Code");
              CSStockTakes.SetRange(Closed,0DT);
              if CSStockTakes.FindFirst then begin
                if (CSStockTakes."Refill Closed" <> 0DT) then
                  Error(Err_RefillClosed);
                if (CSStockTakes."Stockroom Closed" = 0DT) or (CSStockTakes."Salesfloor Closed" = 0DT) then
                  Error(Err_Refill);
                if CSStockTakes."Refill Started" = 0DT then begin
                  CSStockTakes."Refill Started" := CurrentDateTime;
                  CSStockTakes."Refill Started By" := UserId;
                  CSStockTakes.Modify(true);
                end;
                JSONString := BuildJSONGenericParams(Format(NativeActionSetting),CSStockTakes."Stock-Take Id",'','','','0',Err_RFIDRefill);
              end else
                Error(Err_CSStockTakes,Register."Location Code");
            end;
          NativeActionSetting::APPROVE:
            begin
              SelectLatestVersion;
              Register.Get(SalePOS."Register No.");
              Register.TestField("Location Code");
              CSStockTakes.SetRange(Location,Register."Location Code");
              CSStockTakes.SetRange(Closed,0DT);
              if CSStockTakes.FindFirst then begin
                if (CSStockTakes.Approved <> 0DT) then
                  Error(Err_Approved);
                CSRefillData.SetRange("Stock-Take Id",CSStockTakes."Stock-Take Id");
                JSONString := BuildJSONGenericParams(Format(NativeActionSetting),CSStockTakes."Stock-Take Id",'','','','1',Err_RFIDRefill);
              end else
                Error(Err_CSStockTakes,Register."Location Code");
            end;
          //-NPR5.50 [332844]
        end;

        if JSONString <> '' then
          ExecuteNativeAction(Format(NativeActionSetting),JSONString);
        Handled := true;
    end;

    local procedure BuildJSONParams(RequestMethod: Text;BaseAddress: Text;Endpoint: Text;PrintJob: Text;RequestType: Text;ErrorCaption: Text) JSON: Text
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

    local procedure BuildJSONGenericParams(RequestMethod: Text;Value1: Text;Value2: Text;Value3: Text;Value4: Text;Value5: Text;ErrorCaption: Text) JSON: Text
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

    local procedure ExecuteNativeAction(RequestMethod: Text;JSON: Text)
    var
        JSBridge: Page "JS Bridge";
        POSFrontEnd: Codeunit "POS Front End Management";
        POSSession: Codeunit "POS Session";
    begin
        //-NPR5.50 [332844]
        //JSBridge.SetParameters(RequestMethod, JSON, '');
        //JSBridge.RUNMODAL;
        if not POSSession.IsActiveSession(POSFrontEnd) then
          Error(ERROR_SESSION,'MPOSNATIVE');

        CreateUserInterface(JSON);
        ActiveModelID := POSFrontEnd.ShowModel(Model);
        RequestClose(POSFrontEnd);
        //+NPR5.50 [332844]
    end;

    local procedure FindItemBarcode(SaleLinePOS: Record "Sale Line POS";var Barcode: Text): Boolean
    var
        BarcodeLibrary: Codeunit "Barcode Library";
        ResolvingTable: Integer;
    begin
        if not (SaleLinePOS.Type = SaleLinePOS.Type::Item) then
          exit(false);

        BarcodeLibrary.GetItemVariantBarcode(Barcode,SaleLinePOS."No.",SaleLinePOS."Variant Code", ResolvingTable, true);
        exit(true);
    end;

    local procedure CreateUserInterface(JsonObject: Text)
    var
        WebClientDependency: Record "Web Client Dependency";
        Factory: DotNet npNetControlFactory;
    begin
        Model := Model.Model();
        Model.AddScript('function CallNativeFunction(jsonObject) {console.log(jsonObject); window.webkit.messageHandlers.invokeAction.postMessage(jsonObject);}');
        Model.AddScript('CallNativeFunction('+JsonObject+');');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnProtocolUIResponse', '', false, false)]
    local procedure OnProtocolUIResponse(POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";ModelID: Guid;Sender: Text;EventName: Text;var Handled: Boolean)
    var
        WebClientDependency: Record "Web Client Dependency";
        ModelIDVar: Variant;
        EFTTransactionRequest: Record "EFT Transaction Request";
        EFTInterface: Codeunit "EFT Interface";
    begin
        if ModelID <> ActiveModelID then
          exit;

        Handled := true;

        if TransactionDone then
          exit;

        case Sender of
          'btnClose' : RequestClose(FrontEnd);
          'timerLabel' : RequestClose(FrontEnd);
        end;
    end;

    local procedure RequestClose(FrontEnd: Codeunit "POS Front End Management")
    var
        EFTTransactionRequest: Record "EFT Transaction Request";
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

    local procedure HandleProtocolError(FrontEnd: Codeunit "POS Front End Management")
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

