codeunit 6150670 "NPRE POS Action - Split Bill"
{
    // NPR5.47/MHA /20181026 CASE 326640 Object created - Hospitality Split Bill with Html UI
    // NPR5.48/MHA /20181120 CASE 326640 Bumped version list to 1.0
    // NPR5.55/ALPO/20200615 CASE 399170 Restaurant flow change: support for waiter pad related manipulations directly inside a POS sale
    // NPR5.55/ALPO/20200730 CASE 414938 POS Store/POS Unit - Restaurant link (filter seatings by restaurant)

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Split Bill (Waiter Pad) into multiple Bills';
        CurrNPREWaiterPad: Record "NPRE Waiter Pad";
        [WithEvents]
        Model: DotNet npNetModel;
        ActiveModelID: Guid;
        Text001: Label 'Split Bill';
        Text002: Label 'Bill';
        Text003: Label 'Add new Bill';
        Text004: Label 'Approve';
        Text005: Label 'Cancel';

    local procedure ActionCode(): Text
    begin
        exit('SPLIT_BILL');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
        begin
            if DiscoverAction(
              ActionCode(),
              Text000,
              ActionVersion(),
              Type::Generic,
              "Subscriber Instances Allowed"::Multiple)
            then begin
            RegisterWorkflowStep('addPresetValuesToContext','respond();');  //NPR5.55 [399170]
                RegisterWorkflowStep('seatingInput',
              'if (!context.seatingCode) {' +  //NPR5.55 [399170]
              '  if (param.FixedSeatingCode) {' +
              '    context.seatingCode = param.FixedSeatingCode;' +
              '    respond();' +
              '  } else {' +
              '    switch(param.InputType + "") {' +
              '      case "0":' +
              //'      stringpad(labels["InputTypeLabel"]).respond("seatingCode");' +  //NPR5.55 [399170]-revoked
              '        stringpad(labels["InputTypeLabel"]).respond("seatingCode").cancel(abort);' +  //NPR5.55 [399170]
              '        break;' +
              '      case "1":' +
              //'      intpad(labels["InputTypeLabel"]).respond("seatingCode");' +  //NPR5.55 [399170]-revoked
              '        intpad(labels["InputTypeLabel"]).respond("seatingCode").cancel(abort);' +  //NPR5.55 [399170]
              '        break;' +
              '      case "2":' +
              '        respond();' +
              '        break;' +
              '    }' +
              '  }' +  //NPR5.55 [399170]
              '}'
            );
            RegisterWorkflowStep('selectWaiterPad',
              'if (!context.waiterPadNo) {' +  //NPR5.55 [399170]
              '  if (context.seatingCode) {' +
              '    respond();' +
              '  }' +  //NPR5.55 [399170]
              '}'
            );
            RegisterWorkflowStep('splitWaiterPad',
              'if (context.waiterPadNo) {' +
              '  respond();' +
              '}'
            );
            RegisterWorkflow(false);

                RegisterOptionParameter('InputType', 'stringPad,intPad,List', 'stringPad');
                RegisterTextParameter('FixedSeatingCode', '');
                RegisterTextParameter('SeatingFilter', '');
                RegisterTextParameter('LocationFilter', '');
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    var
        NPRESeating: Record "NPRE Seating";
    begin
        Captions.AddActionCaption(ActionCode(), 'InputTypeLabel', NPRESeating.TableCaption);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        case WorkflowStep of
          //-NPR5.55 [399170]
          'addPresetValuesToContext':
            OnActionAddPresetValuesToContext(JSON,FrontEnd,POSSession);
          //+NPR5.55 [399170]
'seatingInput' :
                OnActionSeatingInput(JSON, FrontEnd);
'selectWaiterPad' :
                OnActionSelectWaiterPad(JSON, FrontEnd);
'splitWaiterPad' :
                OnActionSplitWaiterPad(JSON, FrontEnd);
        end;

        Handled := true;
    end;

    local procedure OnActionAddPresetValuesToContext(JSON: Codeunit "POS JSON Management";FrontEnd: Codeunit "POS Front End Management";POSSession: Codeunit "POS Session")
    var
        NPRESeating: Record "NPRE Seating";
        NPRESeatingWaiterPadLink: Record "NPRE Seating - Waiter Pad Link";
        NPREWaiterPad: Record "NPRE Waiter Pad";
        SalePOS: Record "Sale POS";
        WaiterPadMgt: Codeunit "NPRE Waiter Pad Management";
        WaiterPadPOSMgt: Codeunit "NPRE Waiter Pad POS Management";
        POSSale: Codeunit "POS Sale";
        POSSetup: Codeunit "POS Setup";
        ConfirmString: Text;
    begin
        //-NPR5.55 [399170]
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        //-NPR5.55 [414938]
        POSSession.GetSetup(POSSetup);

        JSON.SetContext('restaurantCode', POSSetup.RestaurantCode());
        //+NPR5.55 [414938]

        if SalePOS."NPRE Pre-Set Seating Code" <> '' then begin
          NPRESeating.Get(SalePOS."NPRE Pre-Set Seating Code");
          JSON.SetContext('seatingCode',SalePOS."NPRE Pre-Set Seating Code");
        end;

        if SalePOS."NPRE Pre-Set Waiter Pad No." <> '' then begin
          NPREWaiterPad.Get(SalePOS."NPRE Pre-Set Waiter Pad No.");
          if SalePOS."NPRE Pre-Set Seating Code" <> '' then
            if not NPRESeatingWaiterPadLink.Get(NPRESeating.Code,NPREWaiterPad."No.") then
              WaiterPadMgt.AddNewWaiterPadForSeating(NPRESeating.Code,NPREWaiterPad,NPRESeatingWaiterPadLink);
          WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS,NPREWaiterPad,false);
          JSON.SetContext('waiterPadNo',SalePOS."NPRE Pre-Set Waiter Pad No.");
        end;

        FrontEnd.SetActionContext(ActionCode(),JSON);
        //+NPR5.55 [399170]
    end;

    local procedure OnActionSeatingInput(JSON: Codeunit "POS JSON Management"; FrontEnd: Codeunit "POS Front End Management")
    var
        NPRESeating: Record "NPRE Seating";
        NPREWaiterPadPOSMgt: Codeunit "NPRE Waiter Pad POS Management";
    begin
        NPREWaiterPadPOSMgt.FindSeating(JSON, NPRESeating);

        JSON.SetContext('seatingCode', NPRESeating.Code);

        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure OnActionSelectWaiterPad(JSON: Codeunit "POS JSON Management"; FrontEnd: Codeunit "POS Front End Management")
    var
        NPREWaiterPad: Record "NPRE Waiter Pad";
        NPRESeating: Record "NPRE Seating";
        NPREWaiterPadPOSMgt: Codeunit "NPRE Waiter Pad POS Management";
    begin
        NPREWaiterPadPOSMgt.FindSeating(JSON, NPRESeating);
        if not NPREWaiterPadPOSMgt.SelectWaiterPad(NPRESeating, NPREWaiterPad) then
            exit;

        JSON.SetContext('waiterPadNo', NPREWaiterPad."No.");

        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure OnActionSplitWaiterPad(JSON: Codeunit "POS JSON Management"; FrontEnd: Codeunit "POS Front End Management")
    var
        NPRESeating: Record "NPRE Seating";
        NPREWaiterPad: Record "NPRE Waiter Pad";
        NPREWaiterPadPOSMgt: Codeunit "NPRE Waiter Pad POS Management";
        WaiterPadNo: Code[20];
    begin
        NPREWaiterPadPOSMgt.FindSeating(JSON, NPRESeating);
        JSON.SetScope('/', true);
        WaiterPadNo := JSON.GetString('waiterPadNo', true);
        NPREWaiterPad.Get(WaiterPadNo);

        CreateUserInterface(NPREWaiterPad);
        ActiveModelID := FrontEnd.ShowModel(Model);
    end;

    local procedure "--- UI"()
    begin
    end;

    local procedure CreateUserInterface(NPREWaiterPad: Record "NPRE Waiter Pad")
    begin
        CurrNPREWaiterPad := NPREWaiterPad;
        CurrNPREWaiterPad.CalcFields("Current Seating FF");

        Model := Model.Model();
        Model.AddHtml(InitHtml());
        Model.AddStyle(InitCss());
        Model.AddScript(InitScript());
    end;

    local procedure "--- Init"()
    begin
    end;

    local procedure InitCss() Css: Text
    var
        WebClientDependency: Record "Web Client Dependency";
        StreamReader: DotNet npNetStreamReader;
        InStr: InStream;
    begin
        if WebClientDependency.Get(WebClientDependency.Type::CSS, ActionCode()) and WebClientDependency.BLOB.HasValue then begin
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
        if WebClientDependency.Get(WebClientDependency.Type::HTML, ActionCode()) and WebClientDependency.BLOB.HasValue then begin
            WebClientDependency.CalcFields(BLOB);
            WebClientDependency.BLOB.CreateInStream(InStr);
            StreamReader := StreamReader.StreamReader(InStr);
            Html := StreamReader.ReadToEnd;

            exit(Html);
        end;
    end;

    local procedure InitScript() Script: Text
    var
        RetailModelScriptLibrary: Codeunit "Retail Model Script Library";
    begin
        Script := RetailModelScriptLibrary.InitAngular();
        Script += RetailModelScriptLibrary.InitJQueryUi();
        Script += RetailModelScriptLibrary.InitTouchPunch();
        Script += RetailModelScriptLibrary.InitEscClose();
        Script += InitScriptData();

        exit(Script);
    end;

    local procedure InitScriptData() Script: Text
    begin
        Script := '$(function () {' +
          'var appElement = document.querySelector(''[ng-app=navApp]'');' +
          'var $scope = angular.element(appElement).scope();' +
          '$scope.$apply(function() {';

        Script += InitScriptBillLines();
        Script += InitScriptLabels();

        Script += '});' +
          '});';
    end;

    local procedure InitScriptBillLines() Script: Text
    var
        NPREWaiterPadLine: Record "NPRE Waiter Pad Line";
        BillLine: Text;
        ArrayIndex: Integer;
        i: Integer;
    begin
        Script := '$scope.bill_lines = [';

        NPREWaiterPadLine.SetRange("Waiter Pad No.", CurrNPREWaiterPad."No.");
        if NPREWaiterPadLine.FindSet then
            repeat
            //FOR i := 1 TO NPREWaiterPadLine.Quantity DO BEGIN  //NPR5.55 [399170]-revoked
            //-NPR5.55 [399170]
            if NPREWaiterPadLine.RemainingQtyToBill > 0 then
              for i := 1 to NPREWaiterPadLine.RemainingQtyToBill do begin
            //+NPR5.55 [399170]
                BillLine := '{ bill_id: 1';
                BillLine += ', array_index: ' + Format(ArrayIndex);
                BillLine += ', line_no: ' + Format(NPREWaiterPadLine."Line No.");
                BillLine += ', item_no: "' + Format(NPREWaiterPadLine."No.") + '"';
                BillLine += ', variant_code: "' + NPREWaiterPadLine."Variant Code" + '"';
                BillLine += ', description: "' + NPREWaiterPadLine.Description + '"';
                BillLine += ', qty: 1 },';
                Script += BillLine;

                ArrayIndex += 1;
              end;
            until NPREWaiterPadLine.Next = 0;

        Script += '];';
        exit(Script);
    end;

    local procedure InitScriptLabels() Script: Text
    var
        NPREWaiterPadLine: Record "NPRE Waiter Pad Line";
    begin
        Script := '$scope.labels = ' +
          '{ ' +
            ' title: "' + Text001 + '"' +
            ', bill: "' + Text002 + '"' +
            ', quantity: "' + NPREWaiterPadLine.FieldCaption(Quantity) + '"' +
            ', add_new_bill: "' + Text003 + '"' +
            ', approve: "' + Text004 + '"' +
            ', cancel: "' + Text005 + '" ' +
          '}';

        exit(Script);
    end;

    local procedure "--- Approve"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnProtocolUIResponse', '', true, true)]
    local procedure OnProtocolUIResponse(POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; ModelID: Guid; Sender: Text; EventName: Text; var Handled: Boolean)
    begin
        if ModelID <> ActiveModelID then
            exit;

        Handled := true;

        case Sender of
'approve' :
        begin
            Approve(EventName, FrontEnd);
            FrontEnd.CloseModel(ModelID);
        end;
'cancel', 'close' :
        begin
            FrontEnd.CloseModel(ModelID);
        end;
        end;
    end;

    local procedure Approve(JsonText: Text; FrontEnd: Codeunit "POS Front End Management")
    var
        TempNPREWaiterPad: Record "NPRE Waiter Pad" temporary;
        NPREWaiterPad: Record "NPRE Waiter Pad";
        SalePOS: Record "Sale POS";
        WaiterPadMgt: Codeunit "NPRE Waiter Pad Management";
        WaiterPadPOSMgt: Codeunit "NPRE Waiter Pad POS Management";
        POSSale: Codeunit "POS Sale";
        POSSaleLine: Codeunit "POS Sale Line";
        POSSession: Codeunit "POS Session";
        POSJavaScriptInterface: Codeunit "POS JavaScript Interface";
        BillLines: DotNet JToken;
        BillLine: DotNet JToken;
        BillLineList: DotNet npNetIList;
        NetConvHelper: Variant;
    begin
        BillLines := BillLines.Parse(JsonText);
        NetConvHelper := BillLines.SelectTokens('$[?(@[''bill_id''] > 1)]');
        BillLineList := NetConvHelper;
        foreach BillLine in BillLineList do
        begin
            FindBill(BillLine, TempNPREWaiterPad, NPREWaiterPad);
            ApproveBillLine(BillLine, NPREWaiterPad);
        end;

        FrontEnd.GetSession(POSSession);
        POSSession.GetSaleLine(POSSaleLine);
        //NPREWaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(CurrNPREWaiterPad,POSSaleLine);  //NPR5.55 [399170]-revoked
        //-NPR5.55 [399170]
        POSSaleLine.DeleteAll;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        WaiterPadPOSMgt.ClearSaleHdrNPREPresetFields(SalePOS,false);
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true,false);

        WaiterPadMgt.CloseWaiterPad(CurrNPREWaiterPad,false);
        if not CurrNPREWaiterPad.Closed then
          WaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(CurrNPREWaiterPad,POSSession);
        //+NPR5.55 [399170]
        POSSession.RequestRefreshData();
        POSJavaScriptInterface.RefreshData(POSSession, FrontEnd);
    end;

    local procedure ApproveBillLine(BillLine: DotNet JToken; NPREWaiterPad: Record "NPRE Waiter Pad")
    var
        NPREWaiterPadLine: Record "NPRE Waiter Pad Line";
        WaiterPadPOSMgt: Codeunit "NPRE Waiter Pad POS Management";
        Qty: Decimal;
        LineNo: Integer;
    begin
        LineNo := GetValueAsInt(BillLine, 'line_no');
        if not NPREWaiterPadLine.Get(CurrNPREWaiterPad."No.", LineNo) then
            exit;
        Qty := GetValueAsDec(BillLine, 'qty');
        
        WaiterPadPOSMgt.SplitWaiterPadLine(CurrNPREWaiterPad,NPREWaiterPadLine,Qty,NPREWaiterPad);
        //-NPR5.55 [399170]-revoked
        /*
        IF Qty > NPREWaiterPadLine.Quantity THEN
          Qty := NPREWaiterPadLine.Quantity;
        
        IF Qty = 0 THEN BEGIN
          NPREWaiterPadLine.DELETE(TRUE);
          EXIT;
        END;
        
        IF NOT NPREWaiterPadLine2.GET(NPREWaiterPad."No.",LineNo) THEN BEGIN
          NPREWaiterPadLine2.INIT;
          NPREWaiterPadLine2 := NPREWaiterPadLine;
          NPREWaiterPadLine2."Waiter Pad No." := NPREWaiterPad."No.";
          NPREWaiterPadLine2.Quantity := 0;
          NPREWaiterPadLine2."Amount Incl. VAT" := 0;
          NPREWaiterPadLine2."Amount Excl. VAT" := 0;
          NPREWaiterPadLine2."Discount Amount" := 0;
          NPREWaiterPadLine2.INSERT;
        END;
        
        NPREWaiterPadLine2.Quantity += Qty;
        NPREWaiterPadLine2.VALIDATE(Quantity);
        NPREWaiterPadLine2.MODIFY(TRUE);
        
        NPREWaiterPadLine.Quantity -= Qty;
        IF NPREWaiterPadLine.Quantity = 0 THEN
          NPREWaiterPadLine.DELETE(TRUE)
        ELSE
          NPREWaiterPadLine.MODIFY(TRUE);
        EXIT;
        */
        //+NPR5.55 [399170]-revoked

    end;

    local procedure FindBill(BillLine: DotNet JToken; var TempNPREWaiterPad: Record "NPRE Waiter Pad" temporary; var NPREWaiterPad: Record "NPRE Waiter Pad")
    var
        SeatingWaiterPadLink: Record "NPRE Seating - Waiter Pad Link";
        WaiterPadMgt: Codeunit "NPRE Waiter Pad Management";
        BillId: Code[20];
    begin
        BillId := GetValueAsString(BillLine, 'bill_id');
        if TempNPREWaiterPad.Get(BillId) then begin
            NPREWaiterPad.Get(TempNPREWaiterPad.Description);
            exit;
        end;

        Clear(NPREWaiterPad);
        //WaiterPadPOSManagement.AddNewWaiterPadForSeating(CurrNPREWaiterPad."Current Seating FF",NPREWaiterPad,SeatingWaiterPadLink);  //NPR5.55 [399170]-revoked
        //-NPR5.55 [399170]
        WaiterPadMgt.DuplicateWaiterPadHdr(CurrNPREWaiterPad,NPREWaiterPad);
        WaiterPadMgt.MoveNumberOfGuests(CurrNPREWaiterPad,NPREWaiterPad,1);
        //+NPR5.55 [399170]
        TempNPREWaiterPad.Init;
        TempNPREWaiterPad."No." := BillId;
        TempNPREWaiterPad.Description := NPREWaiterPad."No.";
        TempNPREWaiterPad.Insert;
    end;

    local procedure "--- Json Mgt"()
    begin
    end;

    local procedure GetValueAsString(JToken: DotNet JToken; JPath: Text): Text
    var
        JToken2: DotNet JToken;
    begin
        JToken2 := JToken.SelectToken(JPath);
        if IsNull(JToken2) then
            exit('');

        exit(Format(JToken2));
    end;

    local procedure GetValueAsInt(JToken: DotNet JToken; JPath: Text) IntValue: Integer
    var
        JToken2: DotNet JToken;
    begin
        JToken2 := JToken.SelectToken(JPath);
        if IsNull(JToken2) then
            exit(0);

        if not Evaluate(IntValue, Format(JToken2), 9) then
            exit(0);

        exit(IntValue);
    end;

    local procedure GetValueAsDec(JToken: DotNet JToken; JPath: Text) DecValue: Decimal
    var
        JToken2: DotNet JToken;
    begin
        JToken2 := JToken.SelectToken(JPath);
        if IsNull(JToken2) then
            exit(0);

        if not Evaluate(DecValue, Format(JToken2), 9) then
            exit(0);

        exit(DecValue);
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure GetAddOnQty(SaleLinePOS: Record "Sale Line POS"; ItemAddOnLine: Record "NpIa Item AddOn Line") Qty: Decimal
    var
        SaleLinePOS2: Record "Sale Line POS";
        SaleLinePOSAddOn: Record "NpIa Sale Line POS AddOn";
        ItemAddOnMgt: Codeunit "NpIa Item AddOn Mgt.";
    begin
        ItemAddOnMgt.FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS, SaleLinePOSAddOn);
        SaleLinePOSAddOn.SetFilter("Sale Line No.", '<>%1', SaleLinePOS."Line No.");
        SaleLinePOSAddOn.SetRange("Applies-to Line No.", SaleLinePOS."Line No.");
        SaleLinePOSAddOn.SetRange("AddOn Line No.", ItemAddOnLine."Line No.");
        if not SaleLinePOSAddOn.FindFirst then
            exit(0);

        if SaleLinePOS2.Get(
          SaleLinePOSAddOn."Register No.",
          SaleLinePOSAddOn."Sales Ticket No.",
          SaleLinePOSAddOn."Sale Date",
          SaleLinePOSAddOn."Sale Type",
          SaleLinePOSAddOn."Sale Line No.")
        then
            Qty := SaleLinePOS2.Quantity;

        exit(Qty);
    end;

    local procedure GetNextPOSAddOnLineNo(SaleLinePOS: Record "Sale Line POS") LineNo: Integer
    var
        SaleLinePOSAddOn: Record "NpIa Sale Line POS AddOn";
        ItemAddOnMgt: Codeunit "NpIa Item AddOn Mgt.";
    begin
        ItemAddOnMgt.FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS, SaleLinePOSAddOn);
        if SaleLinePOSAddOn.FindLast then;
        LineNo := SaleLinePOSAddOn."Line No." + 10000;

        exit(LineNo);
    end;

}

