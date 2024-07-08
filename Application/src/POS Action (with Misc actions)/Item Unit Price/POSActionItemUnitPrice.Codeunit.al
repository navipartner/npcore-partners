codeunit 6150857 "NPR POS Action: Item UnitPrice" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        ActionDescription: Label 'Insert Item and set Unit Price from Barcode';

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ParamBarcode_CptLbl: Label 'Barcode';
        ParamBarcode_DescLbl: Label 'Predefined Barcode';
        ParamItemNoBegin_CptLbl: Label 'Item No. Begin';
        ParamItemNoBegin_DescLbl: Label 'Defines Item No. start position in barcode';
        ParamItemNoEnd_CptLbl: Label 'Item No. End';
        ParamItemNoEnd_DescLbl: Label 'Defines Item No. end position in barcode';
        ParamUnitPriceBegin_CptLbl: Label 'Unit Price Begin';
        ParamUnitPriceBegin_DescLbl: Label 'Defines Unit Price start position in barcode';
        ParamUnitPriceEnd_CptLbl: Label 'Unit Price End';
        ParamUnitPriceEnd_DescLbl: Label 'Defines Unit Price end position in barcode';
        ParamUnitPriceDecimal_CptLbl: Label 'Unit Price Decimal Position';
        ParamUnitPriceDecimal_DescLbl: Label 'Defines Unit Price decimal position in barcode';
        ItemReference: Record "Item Reference";
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddTextParameter('barcode', '', ParamBarcode_CptLbl, ParamBarcode_DescLbl);
        WorkflowConfig.AddIntegerParameter('Item_No_Begin', 1, ParamItemNoBegin_CptLbl, ParamItemNoBegin_DescLbl);
        WorkflowConfig.AddIntegerParameter('Item_No_End', 8, ParamItemNoEnd_CptLbl, ParamItemNoEnd_DescLbl);
        WorkflowConfig.AddIntegerParameter('Unit_Price_Begin', 9, ParamUnitPriceBegin_CptLbl, ParamUnitPriceBegin_DescLbl);
        WorkflowConfig.AddIntegerParameter('Unit_Price_Decimal_Position', 11, ParamUnitPriceDecimal_CptLbl, ParamUnitPriceDecimal_DescLbl);
        WorkflowConfig.AddIntegerParameter('Unit_Price_End', 12, ParamUnitPriceEnd_CptLbl, ParamUnitPriceEnd_DescLbl);
        WorkflowConfig.AddLabel('Barcode', Format(ItemReference."Reference Type"::"Bar Code"));
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var

    begin
        case Step of
            'InsertItemUnitPrice':
                FrontEnd.WorkflowResponse(InsertItemUnitPrice(Context));
        end;
    end;

    local procedure InsertItemUnitPrice(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        Item: Record Item;
        UnitPrice: Decimal;
        ItemNotFoundErr: Label 'Item not found';
        InvalidUnitPriceErr: Label 'Invalid Unit Price';
    begin
        if not FindItem(Context, Item) then
            Error(ItemNotFoundErr);
        if not FindUnitPrice(Context, UnitPrice) then
            Error(InvalidUnitPriceErr);

        Response.Add('workflowName', 'ITEM');
        Response.Add('itemno', Item."No.");
        Response.Add('itemQuantity', 1);
        Response.Add('itemIdentifierType', 0); //0 = ItemNumber
        Response.Add('usePreSetUnitPrice', true);
        Response.Add('preSetUnitPrice', UnitPrice);
    end;

    local procedure FindItem(Context: Codeunit "NPR POS JSON Helper"; var Item: Record Item): Boolean
    var
        ItemNoBegin: Integer;
        ItemNoEnd: Integer;
        Barcode: Text;
        ItemNo: Text;
    begin

        ItemNoBegin := Context.GetIntegerParameter('Item_No_Begin');
        ItemNoEnd := Context.GetIntegerParameter('Item_No_End');

        if ItemNoBegin <= 0 then
            exit(false);
        if ItemNoBegin > ItemNoEnd then
            exit(false);

        Barcode := UpperCase(Context.GetString('BarCode'));
        if Barcode = '' then
            exit(false);

        ItemNo := CopyStr(Barcode, ItemNoBegin, ItemNoEnd - ItemNoBegin + 1);
        if StrLen(ItemNo) > MaxStrLen(Item."No.") then
            exit(false);

        exit(Item.Get(ItemNo));
    end;

    local procedure FindUnitPrice(Context: Codeunit "NPR POS JSON Helper"; var UnitPrice: Decimal): Boolean
    var
        UnitPriceBegin: Integer;
        UnitPriceEnd: Integer;
        UnitPriceDecimalPosition: Integer;
        Barcode: Text;
    begin

        UnitPriceBegin := Context.GetIntegerParameter('Unit_Price_Begin');
        UnitPriceEnd := Context.GetIntegerParameter('Unit_Price_End');
        UnitPriceDecimalPosition := Context.GetIntegerParameter('Unit_Price_Decimal_Position');

        Barcode := Context.GetString('BarCode');
        if Barcode = '' then
            exit;

        if UnitPriceBegin <= 0 then
            exit(false);
        if UnitPriceBegin > UnitPriceEnd then
            exit(false);

        Barcode := CopyStr(Barcode, UnitPriceBegin, UnitPriceEnd - UnitPriceBegin + 1);
        if not Evaluate(UnitPrice, Barcode) then
            exit(false);

        if (UnitPriceDecimalPosition >= UnitPriceBegin) and (UnitPriceDecimalPosition <= UnitPriceEnd) then
            UnitPrice /= Power(10, UnitPriceEnd - UnitPriceDecimalPosition + 1);

        exit(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    var
        Item: Record Item;
    begin
        if not EanBoxEvent.Get(ActionCode()) then begin
            EanBoxEvent.Init();
            EanBoxEvent.Code := ActionCode();
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
            ActionCode():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'barcode', true, '');
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Evt Handler", 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeItemUnitPrice(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        Item: Record Item;
        Context: Codeunit "NPR POS JSON Helper";
        JObject: JsonObject;
        JObjectParam: JsonObject;
        UnitPrice: Decimal;
    begin
        if EanBoxSetupEvent."Event Code" <> ActionCode() then
            exit;

        JObject.Add('BarCode', EanBoxValue);

        JObjectParam.Add('Item_No_Begin', GetParameterValue(EanBoxSetupEvent, 'Item_No_Begin'));
        JObjectParam.Add('Item_No_End', GetParameterValue(EanBoxSetupEvent, 'Item_No_End'));
        JObjectParam.Add('Unit_Price_Begin', GetParameterValue(EanBoxSetupEvent, 'Unit_Price_Begin'));
        JObjectParam.Add('Unit_Price_Decimal_Position', GetParameterValue(EanBoxSetupEvent, 'Unit_Price_Decimal_Position'));
        JObjectParam.Add('Unit_Price_End', GetParameterValue(EanBoxSetupEvent, 'Unit_Price_End'));

        JObject.Add('parameters', JObjectParam);

        Context.InitializeJObjectParser(JObject);
        Context.GetJObject(JObject);

        if not FindItem(Context, Item) then
            exit;
        if FindUnitPrice(Context, UnitPrice) then
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
        exit(CODEUNIT::"NPR POS Action: Item UnitPrice");
    end;

    local procedure ActionCode(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::ITEM_UNIT_PRICE));
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionItemUnitPrice.js###
'let main=async({workflow:e,captions:i,parameters:t})=>{if(t.barcode)barcode=t.barcode;else if(barcode=await popup.input({caption:i.Barcode}),barcode===null)return" ";const{workflowName:r,itemno:a,itemQuantity:n,itemIdentifierType:c,usePreSetUnitPrice:o,preSetUnitPrice:d}=await e.respond("InsertItemUnitPrice",{BarCode:barcode});await e.run(r,{parameters:{itemNo:a,itemQuantity:n,itemIdentifierType:c,usePreSetUnitPrice:o,preSetUnitPrice:d}})};'
        )
    end;
}

