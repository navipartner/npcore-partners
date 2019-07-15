codeunit 6150856 "POS Action - Item Qty."
{
    // NPR5.46/MHA /20180910  CASE 294159 Object created - Parses Item No. and Qty. from Barcode
    // NPR5.47/MHA /20181024  CASE 294159 Corrected Codeunit Id in CurrCodeunitId()
    // NPR5.49/MHA /20190328  CASE 350374 Added MaxStrLen to EanBox.Description in DiscoverEanBoxEvents()


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Insert Item and Set Quantity directly from Barcode';
        Text001: Label 'Item not found';
        Text002: Label 'Invalid Quantity';

    local procedure ActionCode(): Text
    begin
        exit ('ITEM_QTY');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    var
        itemTrackingCode: Text;
    begin
        if Sender.DiscoverAction(
          ActionCode,
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
          Sender.RegisterWorkflowStep('InsertItemQty','respond();');
          Sender.RegisterWorkflow(false);

          Sender.RegisterTextParameter('barcode','');
          Sender.RegisterIntegerParameter('Item_No_Begin',1);
          Sender.RegisterIntegerParameter('Item_No_End',8);
          Sender.RegisterIntegerParameter('Quantity_Begin',9);
          Sender.RegisterIntegerParameter('Quantity_Decimal_Position',11);
          Sender.RegisterIntegerParameter('Quantity_End',12);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    var
        ItemCrossReference: Record "Item Cross Reference";
    begin
        Captions.AddActionCaption(ActionCode,'Barcode',Format(ItemCrossReference."Cross-Reference Type"::"Bar Code"));
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        ControlId: Text;
        Value: Text;
        DoNotClearTextBox: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        case WorkflowStep of
          'InsertItemQty':
            OnActionInsertItemQty(JSON,POSSession,FrontEnd);
        end;
    end;

    local procedure OnActionInsertItemQty(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        Item: Record Item;
        POSAction: Record "POS Action";
        Quantity: Decimal;
    begin
        if not FindItem(JSON,Item) then
          Error(Text001);
        if not FindQuantity(JSON,Quantity) then
          Error(Text002);

        POSAction.Get('ITEM');
        POSAction.SetWorkflowInvocationParameter('itemNo',Item."No.",FrontEnd);
        POSAction.SetWorkflowInvocationParameter('itemQuantity',Quantity,FrontEnd);
        POSAction.SetWorkflowInvocationParameter('itemIdentifyerType',0,FrontEnd); //0 = ItemNumber
        FrontEnd.InvokeWorkflow(POSAction);
    end;

    local procedure FindItem(JSON: Codeunit "POS JSON Management";var Item: Record Item): Boolean
    var
        ItemNoBegin: Integer;
        ItemNoEnd: Integer;
        Barcode: Text;
        ItemNo: Text;
    begin
        if not JSON.SetScope('/',false) then
          exit(false);
        if not JSON.SetScope('parameters',false) then
          exit(false);
        ItemNoBegin := JSON.GetIntegerParameter('Item_No_Begin',false);
        ItemNoEnd := JSON.GetIntegerParameter('Item_No_End',false);
        if ItemNoBegin <= 0 then
          exit(false);
        if ItemNoBegin > ItemNoEnd then
          exit(false);

        JSON.SetScope('/',false);
        if not JSON.SetScope('$barcode',false) then
          exit(false);
        Barcode := UpperCase(JSON.GetString('input',false));
        if Barcode = '' then
          exit(false);

        ItemNo := CopyStr(Barcode,ItemNoBegin,ItemNoEnd - ItemNoBegin + 1);
        if StrLen(ItemNo) > MaxStrLen(Item."No.") then
          exit(false);

        exit(Item.Get(ItemNo));
    end;

    local procedure FindQuantity(JSON: Codeunit "POS JSON Management";var Quantity: Decimal): Boolean
    var
        QuantityBegin: Integer;
        QuantityEnd: Integer;
        QuantityDecimalPosition: Integer;
        Barcode: Text;
    begin
        if not JSON.SetScope('/',false) then
          exit(false);
        if not JSON.SetScope('parameters',false) then
          exit(false);
        QuantityBegin := JSON.GetIntegerParameter('Quantity_Begin',false);
        QuantityEnd := JSON.GetIntegerParameter('Quantity_End',false);
        QuantityDecimalPosition := JSON.GetIntegerParameter('Quantity_Decimal_Position',false);
        JSON.SetScope('/',false);
        if not JSON.SetScope('$barcode',false) then
          exit(false);
        Barcode := JSON.GetString('input',false);
        if Barcode = '' then
          exit;

        if QuantityBegin <= 0 then
          exit(false);
        if QuantityBegin > QuantityEnd then
          exit(false);

        Barcode := CopyStr(Barcode,QuantityBegin,QuantityEnd - QuantityBegin + 1);
        if not Evaluate(Quantity,Barcode) then
          exit(false);

        if (QuantityDecimalPosition >= QuantityBegin) and (QuantityDecimalPosition <= QuantityEnd) then
          Quantity /= Power(10,QuantityEnd - QuantityDecimalPosition + 1);

        exit(true);
    end;

    local procedure "--- Ean Box Event Handling"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "Ean Box Event")
    var
        Item: Record Item;
        ItemCrossReference: Record "Item Cross Reference";
    begin
        if not EanBoxEvent.Get(EventCodeItemQty()) then begin
          EanBoxEvent.Init;
          EanBoxEvent.Code := EventCodeItemQty();
          EanBoxEvent."Module Name" := Item.TableCaption;
          //-NPR5.49 [350374]
          //EanBoxEvent.Description := Text000;
          EanBoxEvent.Description := CopyStr(Text000,1,MaxStrLen(EanBoxEvent.Description));;
          //+NPR5.49 [350374]
          EanBoxEvent."Action Code" := ActionCode();
          EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
          EanBoxEvent."Event Codeunit" := CurrCodeunitId();
          EanBoxEvent.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "Ean Box Setup Mgt.";EanBoxEvent: Record "Ean Box Event")
    begin
        case EanBoxEvent.Code of
          EventCodeItemQty():
            begin
              Sender.SetNonEditableParameterValues(EanBoxEvent,'barcode',true,'');
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060107, 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeItemQty(EanBoxSetupEvent: Record "Ean Box Setup Event";EanBoxValue: Text;var InScope: Boolean)
    var
        Item: Record Item;
        JSON: Codeunit "POS JSON Management";
        FrontEnd: Codeunit "POS Front End Management";
        JObject: DotNet JObject;
        Quantity: Decimal;
    begin
        if EanBoxSetupEvent."Event Code" <> EventCodeItemQty() then
          exit;

        JObject := JObject.Parse(
          '{' +
            '"$barcode": {' +
              '"input": "' + EanBoxValue + '"' +
            '},' +
            '"parameters": {' +
              '"Item_No_Begin": ' + GetParameterValue(EanBoxSetupEvent,'Item_No_Begin') + ',' +
              '"Item_No_End": ' + GetParameterValue(EanBoxSetupEvent,'Item_No_End') + ',' +
              '"Quantity_Begin": ' + GetParameterValue(EanBoxSetupEvent,'Quantity_Begin') + ',' +
              '"Quantity_Decimal_Position": ' + GetParameterValue(EanBoxSetupEvent,'Quantity_Decimal_Position') + ',' +
              '"Quantity_End": ' + GetParameterValue(EanBoxSetupEvent,'Quantity_End') +
            '}' +
          '}'
        );
        JSON.InitializeJObjectParser(JObject,FrontEnd);
        if not FindItem(JSON,Item) then
          exit;
        if FindQuantity(JSON,Quantity) then
          InScope := true;
    end;

    local procedure GetParameterValue(EanBoxSetupEvent: Record "Ean Box Setup Event";ParameterName: Text): Text
    var
        EanBoxParameter: Record "Ean Box Parameter";
    begin
        if not EanBoxParameter.Get(EanBoxSetupEvent."Setup Code",EanBoxSetupEvent."Event Code",EanBoxSetupEvent."Action Code",ParameterName) then
          exit('');

        exit(EanBoxParameter.Value);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        //-NPR5.47 [333409]
        //EXIT(CODEUNIT::"POS Action - Ret. Amt. Dialog");
        exit(CODEUNIT::"POS Action - Item Qty.");
        //+NPR5.47 [333409]
    end;

    local procedure EventCodeItemQty(): Code[20]
    begin
        exit('ITEMQTY');
    end;
}

