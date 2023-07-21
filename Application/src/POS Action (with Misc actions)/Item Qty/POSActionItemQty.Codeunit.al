codeunit 6150856 "NPR POS Action: Item Qty." implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        ActionDescription: Label 'Insert Item and Set Quantity directly from Barcode';
        Text001: Label 'Item not found';
        Text002: Label 'Invalid Quantity';
        POSActItemQtyB: Codeunit "NPR POS Action: Item Qty. B";

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ParamBarcode_CptLbl: Label 'Barcode';
        ParamBarcode_DescLbl: Label 'Predefined Barcode';
        ParamItemNoBegin_CptLbl: Label 'Item No. Begin';
        ParamItemNoBegin_DescLbl: Label 'Defines Item No. start position in barcode';
        ParamItemNoEnd_CptLbl: Label 'Item No. End';
        ParamItemNoEnd_DescLbl: Label 'Defines Item No. end position in barcode';
        ParamQtyBegin_CptLbl: Label 'Quantity Begin';
        ParamQtyBegin_DescLbl: Label 'Defines Quantity start position in barcode';
        ParamQtyEnd_CptLbl: Label 'Quantity End';
        ParamQtyEnd_DescLbl: Label 'Defines Quantity end position in barcode';
        ParamQtyDecimal_CptLbl: Label 'Quantity Decimal Position';
        ParamQtyDecimal_DescLbl: Label 'Defines Quantity decimal position in barcode';
        ItemReference: Record "Item Reference";
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddTextParameter('barcode', '', ParamBarcode_CptLbl, ParamBarcode_DescLbl);
        WorkflowConfig.AddIntegerParameter('Item_No_Begin', 1, ParamItemNoBegin_CptLbl, ParamItemNoBegin_DescLbl);
        WorkflowConfig.AddIntegerParameter('Item_No_End', 8, ParamItemNoEnd_CptLbl, ParamItemNoEnd_DescLbl);
        WorkflowConfig.AddIntegerParameter('Quantity_Begin', 9, ParamQtyBegin_CptLbl, ParamQtyBegin_DescLbl);
        WorkflowConfig.AddIntegerParameter('Quantity_Decimal_Position', 11, ParamQtyDecimal_CptLbl, ParamQtyDecimal_DescLbl);
        WorkflowConfig.AddIntegerParameter('Quantity_End', 12, ParamQtyEnd_CptLbl, ParamQtyEnd_DescLbl);
        WorkflowConfig.AddLabel('Barcode', Format(ItemReference."Reference Type"::"Bar Code"));
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'InsertItemQty':
                FrontEnd.WorkflowResponse(InsertItemQty(Context));
        end;
    end;

    local procedure InsertItemQty(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        Item: Record Item;
        Quantity: Decimal;
    begin
        if not FindItem(Context, Item) then
            Error(Text001);
        if not FindQuantity(Context, Quantity) then
            Error(Text002);

        Response.Add('workflowName', 'ITEM');
        Response.Add('itemno', Item."No.");
        Response.Add('itemQuantity', Quantity);
        Response.Add('itemIdentifierType', 0); //0 = ItemNumber
    end;

    local procedure FindItem(Context: Codeunit "NPR POS JSON Helper"; var Item: Record Item) ItemFound: Boolean
    var
        ItemNoBegin: Integer;
        ItemNoEnd: Integer;
        Barcode: Text;
    begin
        ItemNoBegin := Context.GetIntegerParameter('Item_No_Begin');
        ItemNoEnd := Context.GetIntegerParameter('Item_No_End');
        Barcode := UpperCase(Context.GetString('BarCode'));

        ItemFound := POSActItemQtyB.FindItem(ItemNoBegin, ItemNoEnd, Barcode, Item);
    end;

    local procedure FindQuantity(Context: Codeunit "NPR POS JSON Helper"; var Quantity: Decimal) QtyFound: Boolean
    var
        QuantityBegin: Integer;
        QuantityEnd: Integer;
        QuantityDecimalPosition: Integer;
        Barcode: Text;
    begin
        QuantityBegin := Context.GetIntegerParameter('Quantity_Begin');
        QuantityEnd := Context.GetIntegerParameter('Quantity_End');
        QuantityDecimalPosition := Context.GetIntegerParameter('Quantity_Decimal_Position');
        Barcode := Context.GetString('BarCode');

        QtyFound := POSActItemQtyB.FindQty(QuantityBegin, QuantityEnd, QuantityDecimalPosition, Barcode, Quantity)
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
            EanBoxEvent.Description := CopyStr(ActionDescription, 1, MaxStrLen(EanBoxEvent.Description));
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
        JSON: Codeunit "NPR POS JSON Helper";
        JObject: JsonObject;
        JObjectParam: JsonObject;
        Quantity: Decimal;
    begin
        if EanBoxSetupEvent."Event Code" <> EventCodeItemQty() then
            exit;

        JObject.Add('BarCode', EanBoxValue);

        JObjectParam.Add('Item_No_Begin', GetParameterValue(EanBoxSetupEvent, 'Item_No_Begin'));
        JObjectParam.Add('Item_No_End', GetParameterValue(EanBoxSetupEvent, 'Item_No_End'));
        JObjectParam.Add('Quantity_Begin', GetParameterValue(EanBoxSetupEvent, 'Quantity_Begin'));
        JObjectParam.Add('Quantity_Decimal_Position', GetParameterValue(EanBoxSetupEvent, 'Quantity_Decimal_Position'));
        JObjectParam.Add('Quantity_End', GetParameterValue(EanBoxSetupEvent, 'Quantity_End'));

        JObject.Add('parameters', JObjectParam);

        JSON.InitializeJObjectParser(JObject);
        JSON.GetJObject(JObject);

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

    local procedure ActionCode(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::ITEM_QTY));
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionItemQty.js###
'let main=async({workflow:e,captions:a,parameters:t})=>{if(t.barcode)barcode=t.barcode;else if(barcode=await popup.input({caption:a.Barcode}),barcode===null)return" ";const{workflowName:i,itemno:n,itemQuantity:r,itemIdentifierType:o}=await e.respond("InsertItemQty",{BarCode:barcode});await e.run(i,{parameters:{itemNo:n,itemQuantity:r,itemIdentifierType:o}})};'
        )
    end;
}

