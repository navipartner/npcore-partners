codeunit 6150856 "NPR POS Action: Item Qty."
{
    Access = Internal;
    var
        Text000: Label 'Insert Item and Set Quantity directly from Barcode';
        Text001: Label 'Item not found';
        Text002: Label 'Invalid Quantity';

    local procedure ActionCode(): Code[20]
    begin
        exit('ITEM_QTY');
    end;

    local procedure ActionVersion(): Text[30]
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
          Sender."Subscriber Instances Allowed"::Single)
        then begin
            Sender.RegisterWorkflowStep('barcode',
              'if (param.barcode) {' +
              '  context.$barcode = {};' +
              '  context.$barcode.input = param.barcode;' +
              '} else {' +
              '  input({title: labels.Barcode, caption: labels.Barcode}).cancel(abort);' +
              '}');
            Sender.RegisterWorkflowStep('InsertItemQty', 'respond();');
            Sender.RegisterWorkflow(false);

            Sender.RegisterTextParameter('barcode', '');
            Sender.RegisterIntegerParameter('Item_No_Begin', 1);
            Sender.RegisterIntegerParameter('Item_No_End', 8);
            Sender.RegisterIntegerParameter('Quantity_Begin', 9);
            Sender.RegisterIntegerParameter('Quantity_Decimal_Position', 11);
            Sender.RegisterIntegerParameter('Quantity_End', 12);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    var
        ItemReference: Record "Item Reference";
    begin
        Captions.AddActionCaption(ActionCode(), 'Barcode', Format(ItemReference."Reference Type"::"Bar Code"));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        case WorkflowStep of
            'InsertItemQty':
                OnActionInsertItemQty(JSON, FrontEnd);
        end;
    end;

    local procedure OnActionInsertItemQty(JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Item: Record Item;
        POSAction: Record "NPR POS Action";
        Quantity: Decimal;
    begin
        if not FindItem(JSON, Item) then
            Error(Text001);
        if not FindQuantity(JSON, Quantity) then
            Error(Text002);

        POSAction.Get('ITEM');
        POSAction.SetWorkflowInvocationParameter('itemNo', Item."No.", FrontEnd);
        POSAction.SetWorkflowInvocationParameter('itemQuantity', Quantity, FrontEnd);
        POSAction.SetWorkflowInvocationParameter('itemIdentifyerType', 0, FrontEnd); //0 = ItemNumber
        FrontEnd.InvokeWorkflow(POSAction);
    end;

    local procedure FindItem(JSON: Codeunit "NPR POS JSON Management"; var Item: Record Item): Boolean
    var
        ItemNoBegin: Integer;
        ItemNoEnd: Integer;
        Barcode: Text;
        ItemNo: Text;
    begin
        if not JSON.SetScope('/') then
            exit(false);
        if not JSON.SetScope('parameters') then
            exit(false);
        ItemNoBegin := JSON.GetIntegerParameter('Item_No_Begin');
        ItemNoEnd := JSON.GetIntegerParameter('Item_No_End');
        if ItemNoBegin <= 0 then
            exit(false);
        if ItemNoBegin > ItemNoEnd then
            exit(false);

        JSON.SetScope('/');
        if not JSON.SetScope('$barcode') then
            exit(false);
        Barcode := UpperCase(JSON.GetString('input'));
        if Barcode = '' then
            exit(false);

        ItemNo := CopyStr(Barcode, ItemNoBegin, ItemNoEnd - ItemNoBegin + 1);
        if StrLen(ItemNo) > MaxStrLen(Item."No.") then
            exit(false);

        exit(Item.Get(ItemNo));
    end;

    local procedure FindQuantity(JSON: Codeunit "NPR POS JSON Management"; var Quantity: Decimal): Boolean
    var
        QuantityBegin: Integer;
        QuantityEnd: Integer;
        QuantityDecimalPosition: Integer;
        Barcode: Text;
    begin
        if not JSON.SetScope('/') then
            exit(false);
        if not JSON.SetScope('parameters') then
            exit(false);
        QuantityBegin := JSON.GetIntegerParameter('Quantity_Begin');
        QuantityEnd := JSON.GetIntegerParameter('Quantity_End');
        QuantityDecimalPosition := JSON.GetIntegerParameter('Quantity_Decimal_Position');
        JSON.SetScope('/');
        if not JSON.SetScope('$barcode') then
            exit(false);
        Barcode := JSON.GetString('input');
        if Barcode = '' then
            exit;

        if QuantityBegin <= 0 then
            exit(false);
        if QuantityBegin > QuantityEnd then
            exit(false);

        Barcode := CopyStr(Barcode, QuantityBegin, QuantityEnd - QuantityBegin + 1);
        if not Evaluate(Quantity, Barcode) then
            exit(false);

        if (QuantityDecimalPosition >= QuantityBegin) and (QuantityDecimalPosition <= QuantityEnd) then
            Quantity /= Power(10, QuantityEnd - QuantityDecimalPosition + 1);

        exit(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    var
        Item: Record Item;
    begin
        if not EanBoxEvent.Get(EventCodeItemQty()) then begin
            EanBoxEvent.Init();
            EanBoxEvent.Code := EventCodeItemQty();
            EanBoxEvent."Module Name" := CopyStr(Item.TableCaption, 1, MaxStrLen(EanBoxEvent."Module Name"));
            EanBoxEvent.Description := CopyStr(Text000, 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := CopyStr(ActionCode(), 1, MaxStrLen(EanBoxEvent."Action Code"));
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "NPR POS Input Box Setup Mgt."; EanBoxEvent: Record "NPR Ean Box Event")
    begin
        case EanBoxEvent.Code of
            EventCodeItemQty():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'barcode', true, '');
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Evt Handler", 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeItemQty(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        Item: Record Item;
        JSON: Codeunit "NPR POS JSON Management";
        FrontEnd: Codeunit "NPR POS Front End Management";
        JObject: JsonObject;
        Quantity: Decimal;
    begin
        if EanBoxSetupEvent."Event Code" <> EventCodeItemQty() then
            exit;

        JObject.ReadFrom(
          '{' +
            '"$barcode": {' +
              '"input": "' + EanBoxValue + '"' +
            '},' +
            '"parameters": {' +
              '"Item_No_Begin": ' + GetParameterValue(EanBoxSetupEvent, 'Item_No_Begin') + ',' +
              '"Item_No_End": ' + GetParameterValue(EanBoxSetupEvent, 'Item_No_End') + ',' +
              '"Quantity_Begin": ' + GetParameterValue(EanBoxSetupEvent, 'Quantity_Begin') + ',' +
              '"Quantity_Decimal_Position": ' + GetParameterValue(EanBoxSetupEvent, 'Quantity_Decimal_Position') + ',' +
              '"Quantity_End": ' + GetParameterValue(EanBoxSetupEvent, 'Quantity_End') +
            '}' +
          '}'
        );
        JSON.InitializeJObjectParser(JObject, FrontEnd);
        if not FindItem(JSON, Item) then
            exit;
        if FindQuantity(JSON, Quantity) then
            InScope := true;
    end;

    local procedure GetParameterValue(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; ParameterName: Text): Text
    var
        EanBoxParameter: Record "NPR Ean Box Parameter";
    begin
        if not EanBoxParameter.Get(EanBoxSetupEvent."Setup Code", EanBoxSetupEvent."Event Code", EanBoxSetupEvent."Action Code", ParameterName) then
            exit('');

        exit(EanBoxParameter.Value);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR POS Action: Item Qty.");
    end;

    local procedure EventCodeItemQty(): Code[20]
    begin
        exit('ITEMQTY');
    end;
}

