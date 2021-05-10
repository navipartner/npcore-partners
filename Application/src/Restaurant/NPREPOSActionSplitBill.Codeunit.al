codeunit 6150670 "NPR NPRE POS Action: SplitBill"
{
    SingleInstance = true;

    var
        Text000: Label 'Split Bill (Waiter Pad) into multiple Bills';
        CurrNPREWaiterPad: Record "NPR NPRE Waiter Pad";
        [WithEvents]
        Model: DotNet NPRNetModel;
        ActiveModelID: Guid;
        Text001: Label 'Split Bill';
        Text002: Label 'Bill';
        Text003: Label 'Add new Bill';
        Text004: Label 'Approve';
        Text005: Label 'Cancel';
        ReadingErr: Label 'reading in %1';

    local procedure ActionCode(): Text
    begin
        exit('SPLIT_BILL');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
          ActionCode(),
          Text000,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple)
        then begin
            Sender.RegisterWorkflowStep('addPresetValuesToContext', 'respond();');
            Sender.RegisterWorkflowStep('seatingInput',
          'if (!context.seatingCode) {' +
          '  if (param.FixedSeatingCode) {' +
          '    context.seatingCode = param.FixedSeatingCode;' +
          '    respond();' +
          '  } else {' +
          '    switch(param.InputType + "") {' +
          '      case "0":' +
          '        stringpad(labels["InputTypeLabel"]).respond("seatingCode").cancel(abort);' +
          '        break;' +
          '      case "1":' +
          '        intpad(labels["InputTypeLabel"]).respond("seatingCode").cancel(abort);' +
          '        break;' +
          '      case "2":' +
          '        respond();' +
          '        break;' +
          '    }' +
          '  }' +
          '}'
        );
            Sender.RegisterWorkflowStep('selectWaiterPad',
              'if (!context.waiterPadNo) {' +
              '  if (context.seatingCode) {' +
              '    respond();' +
              '  }' +
              '}'
            );
            Sender.RegisterWorkflowStep('splitWaiterPad',
              'if (context.waiterPadNo) {' +
              '  respond();' +
              '}'
            );
            Sender.RegisterWorkflow(false);

            Sender.RegisterOptionParameter('InputType', 'stringPad,intPad,List', 'stringPad');
            Sender.RegisterTextParameter('FixedSeatingCode', '');
            Sender.RegisterTextParameter('SeatingFilter', '');
            Sender.RegisterTextParameter('LocationFilter', '');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    var
        NPRESeating: Record "NPR NPRE Seating";
    begin
        Captions.AddActionCaption(ActionCode(), 'InputTypeLabel', NPRESeating.TableCaption);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        case WorkflowStep of
            'addPresetValuesToContext':
                OnActionAddPresetValuesToContext(JSON, FrontEnd, POSSession);
            'seatingInput':
                OnActionSeatingInput(JSON, FrontEnd);
            'selectWaiterPad':
                OnActionSelectWaiterPad(JSON, FrontEnd);
            'splitWaiterPad':
                OnActionSplitWaiterPad(JSON, FrontEnd);
        end;

        Handled := true;
    end;

    local procedure OnActionAddPresetValuesToContext(JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session")
    var
        NPRESeating: Record "NPR NPRE Seating";
        NPRESeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        NPREWaiterPad: Record "NPR NPRE Waiter Pad";
        SalePOS: Record "NPR POS Sale";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSetup(POSSetup);

        JSON.SetContext('restaurantCode', POSSetup.RestaurantCode());

        if SalePOS."NPRE Pre-Set Seating Code" <> '' then begin
            NPRESeating.Get(SalePOS."NPRE Pre-Set Seating Code");
            JSON.SetContext('seatingCode', SalePOS."NPRE Pre-Set Seating Code");
        end;

        if SalePOS."NPRE Pre-Set Waiter Pad No." <> '' then begin
            NPREWaiterPad.Get(SalePOS."NPRE Pre-Set Waiter Pad No.");
            if SalePOS."NPRE Pre-Set Seating Code" <> '' then
                if not NPRESeatingWaiterPadLink.Get(NPRESeating.Code, NPREWaiterPad."No.") then
                    WaiterPadMgt.AddNewWaiterPadForSeating(NPRESeating.Code, NPREWaiterPad, NPRESeatingWaiterPadLink);
            WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, NPREWaiterPad, false);
            JSON.SetContext('waiterPadNo', SalePOS."NPRE Pre-Set Waiter Pad No.");
        end;

        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure OnActionSeatingInput(JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        NPRESeating: Record "NPR NPRE Seating";
        NPREWaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        NPREWaiterPadPOSMgt.FindSeating(JSON, NPRESeating);

        JSON.SetContext('seatingCode', NPRESeating.Code);

        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure OnActionSelectWaiterPad(JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        NPREWaiterPad: Record "NPR NPRE Waiter Pad";
        NPRESeating: Record "NPR NPRE Seating";
        NPREWaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        NPREWaiterPadPOSMgt.FindSeating(JSON, NPRESeating);
        if not NPREWaiterPadPOSMgt.SelectWaiterPad(NPRESeating, NPREWaiterPad) then
            exit;

        JSON.SetContext('waiterPadNo', NPREWaiterPad."No.");

        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure OnActionSplitWaiterPad(JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        NPRESeating: Record "NPR NPRE Seating";
        NPREWaiterPad: Record "NPR NPRE Waiter Pad";
        NPREWaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        WaiterPadNo: Code[20];
    begin
        NPREWaiterPadPOSMgt.FindSeating(JSON, NPRESeating);
        JSON.SetScopeRoot();
        WaiterPadNo := JSON.GetStringOrFail('waiterPadNo', StrSubstNo(ReadingErr, ActionCode()));
        NPREWaiterPad.Get(WaiterPadNo);

        CreateUserInterface(NPREWaiterPad);
        ActiveModelID := FrontEnd.ShowModel(Model);
    end;

    local procedure CreateUserInterface(NPREWaiterPad: Record "NPR NPRE Waiter Pad")
    begin
        CurrNPREWaiterPad := NPREWaiterPad;
        CurrNPREWaiterPad.CalcFields("Current Seating FF");

        Model := Model.Model();
        Model.AddHtml(InitHtml());
        Model.AddStyle(InitCss());
        Model.AddScript(InitScript());
    end;

    local procedure InitCss() Css: Text
    var
        WebClientDependency: Record "NPR Web Client Dependency";
        InStr: InStream;
    begin
        if WebClientDependency.Get(WebClientDependency.Type::CSS, ActionCode()) and WebClientDependency.BLOB.HasValue() then begin
            WebClientDependency.CalcFields(BLOB);
            WebClientDependency.BLOB.CreateInStream(InStr);
            InStr.Read(Css);

            exit(Css);
        end;
    end;

    local procedure InitHtml() Html: Text
    var
        WebClientDependency: Record "NPR Web Client Dependency";
        InStr: InStream;
    begin
        if WebClientDependency.Get(WebClientDependency.Type::HTML, ActionCode()) and WebClientDependency.BLOB.HasValue() then begin
            WebClientDependency.CalcFields(BLOB);
            WebClientDependency.BLOB.CreateInStream(InStr);
            InStr.Read(Html);

            exit(Html);
        end;
    end;

    local procedure InitScript() Script: Text
    var
        RetailModelScriptLibrary: Codeunit "NPR Retail Model Script Lib.";
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
        NPREWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        BillLine: Text;
        ArrayIndex: Integer;
        i: Integer;
    begin
        Script := '$scope.bill_lines = [';

        NPREWaiterPadLine.SetRange("Waiter Pad No.", CurrNPREWaiterPad."No.");
        if NPREWaiterPadLine.FindSet() then
            repeat
                if NPREWaiterPadLine.RemainingQtyToBill() > 0 then
                    for i := 1 to NPREWaiterPadLine.RemainingQtyToBill() do begin
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
            until NPREWaiterPadLine.Next() = 0;

        Script += '];';
        exit(Script);
    end;

    local procedure InitScriptLabels() Script: Text
    var
        NPREWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnProtocolUIResponse', '', true, true)]
    local procedure OnProtocolUIResponse(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; ModelID: Guid; Sender: Text; EventName: Text; var Handled: Boolean)
    begin
        if ModelID <> ActiveModelID then
            exit;

        Handled := true;

        case Sender of
            'approve':
                begin
                    Approve(EventName, FrontEnd);
                    FrontEnd.CloseModel(ModelID);
                end;
            'cancel', 'close':
                begin
                    FrontEnd.CloseModel(ModelID);
                end;
        end;
    end;

    local procedure Approve(JsonText: Text; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        TempNPREWaiterPad: Record "NPR NPRE Waiter Pad" temporary;
        NPREWaiterPad: Record "NPR NPRE Waiter Pad";
        SalePOS: Record "NPR POS Sale";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSession: Codeunit "NPR POS Session";
        POSJavaScriptInterface: Codeunit "NPR POS JavaScript Interface";
        BillLines: JsonToken;
        BillLine: JsonToken;
        BillLine2: JsonToken;
        BillLineList: JsonArray;
        JObject: JsonObject;
    begin
        BillLines.ReadFrom(JsonText);
        BillLineList := BillLines.AsArray();
        JObject := BillLine.AsObject();
        if JObject.Get('bill_id', BillLine2) and (BillLine2.AsValue().AsInteger() > 1) then begin
            foreach BillLine in BillLineList do begin
                FindBill(BillLine, TempNPREWaiterPad, NPREWaiterPad);
                ApproveBillLine(BillLine, NPREWaiterPad);
            end;
        end;

        FrontEnd.GetSession(POSSession);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.DeleteAll();

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        WaiterPadPOSMgt.ClearSaleHdrNPREPresetFields(SalePOS, false);
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true, false);

        WaiterPadMgt.CloseWaiterPad(CurrNPREWaiterPad, false);
        if not CurrNPREWaiterPad.Closed then
            WaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(CurrNPREWaiterPad, POSSession);
        POSSession.RequestRefreshData();
        POSJavaScriptInterface.RefreshData(POSSession, FrontEnd);
    end;

    local procedure ApproveBillLine(BillLine: JsonToken; NPREWaiterPad: Record "NPR NPRE Waiter Pad")
    var
        NPREWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        Qty: Decimal;
        LineNo: Integer;
    begin
        LineNo := GetValueAsInt(BillLine, 'line_no');
        if not NPREWaiterPadLine.Get(CurrNPREWaiterPad."No.", LineNo) then
            exit;
        Qty := GetValueAsDec(BillLine, 'qty');

        WaiterPadPOSMgt.SplitWaiterPadLine(CurrNPREWaiterPad, NPREWaiterPadLine, Qty, NPREWaiterPad);
    end;

    local procedure FindBill(BillLine: JsonToken; var TempNPREWaiterPad: Record "NPR NPRE Waiter Pad" temporary; var NPREWaiterPad: Record "NPR NPRE Waiter Pad")
    var
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        BillId: Code[20];
    begin
        BillId := GetValueAsString(BillLine, 'bill_id');
        if TempNPREWaiterPad.Get(BillId) then begin
            NPREWaiterPad.Get(TempNPREWaiterPad.Description);
            exit;
        end;

        Clear(NPREWaiterPad);
        WaiterPadMgt.DuplicateWaiterPadHdr(CurrNPREWaiterPad, NPREWaiterPad);
        WaiterPadMgt.MoveNumberOfGuests(CurrNPREWaiterPad, NPREWaiterPad, 1);
        TempNPREWaiterPad.Init();
        TempNPREWaiterPad."No." := BillId;
        TempNPREWaiterPad.Description := NPREWaiterPad."No.";
        TempNPREWaiterPad.Insert();
    end;

    local procedure GetValueAsString(JToken: JsonToken; JPath: Text): Text
    var
        JToken2: JsonToken;
    begin
        JToken.SelectToken(JPath, JToken2);
        if JToken2.AsValue().IsNull() then
            exit('');

        exit(Format(JToken2));
    end;

    local procedure GetValueAsInt(JToken: JsonToken; JPath: Text) IntValue: Integer
    var
        JToken2: JsonToken;
    begin
        JToken.SelectToken(JPath, JToken2);
        if JToken2.AsValue().IsNull() then
            exit(0);

        if not Evaluate(IntValue, Format(JToken2), 9) then
            exit(0);

        exit(IntValue);
    end;

    local procedure GetValueAsDec(JToken: JsonToken; JPath: Text) DecValue: Decimal
    var
        JToken2: JsonToken;
    begin
        JToken.SelectToken(JPath, JToken2);
        if JToken2.AsValue().IsNull() then
            exit(0);

        if not Evaluate(DecValue, Format(JToken2), 9) then
            exit(0);

        exit(DecValue);
    end;

    local procedure GetAddOnQty(SaleLinePOS: Record "NPR POS Sale Line"; ItemAddOnLine: Record "NPR NpIa Item AddOn Line") Qty: Decimal
    var
        SaleLinePOS2: Record "NPR POS Sale Line";
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
        ItemAddOnMgt: Codeunit "NPR NpIa Item AddOn Mgt.";
    begin
        ItemAddOnMgt.FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS, SaleLinePOSAddOn);
        SaleLinePOSAddOn.SetFilter("Sale Line No.", '<>%1', SaleLinePOS."Line No.");
        SaleLinePOSAddOn.SetRange("Applies-to Line No.", SaleLinePOS."Line No.");
        SaleLinePOSAddOn.SetRange("AddOn Line No.", ItemAddOnLine."Line No.");
        if not SaleLinePOSAddOn.FindFirst() then
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

    local procedure GetNextPOSAddOnLineNo(SaleLinePOS: Record "NPR POS Sale Line") LineNo: Integer
    var
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
        ItemAddOnMgt: Codeunit "NPR NpIa Item AddOn Mgt.";
    begin
        ItemAddOnMgt.FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS, SaleLinePOSAddOn);
        if SaleLinePOSAddOn.FindLast() then;
        LineNo := SaleLinePOSAddOn."Line No." + 10000;

        exit(LineNo);
    end;
}
