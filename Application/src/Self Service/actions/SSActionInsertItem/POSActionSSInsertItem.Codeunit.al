codeunit 6151289 "NPR POSAction: SS Insert Item" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This is a built-in action for self-service, inserting an item line into the current transaction';
        ParamItemIdentifierType_CaptionLbl: Label 'Item Identifier Type';
        ParamItemIdentifierType_DescLbl: Label 'Specifies the Item Identifier Type';
        ParamItemIdentifierOptionsLbl: Label 'ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference', Locked = true;
        ParamItemIdentifierOptions_CaptionLbl: Label 'ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference';
        ParamItemNo_CaptionLbl: Label 'Item No.';
        ParamItemNo_DescLbl: Label 'Specifies the Item No.';
        ParamItemQty_CaptionLbl: Label 'Item Quantity';
        ParamItemQty_DescLbl: Label 'Specifies the Item Quantity';
        ParamEditDescription_CaptionLbl: Label 'Edit Description';
        ParamEditDescription_DescLbl: Label 'Enable/Disable Edit Description';
        ParamUsePreSetUnitPrice_CaptionLbl: Label 'usePreSetUnitPrice';
        ParamUsePreSetUnitPrice_DescLbl: Label 'Enable/Disable preset of Unit Price';
        ParamPreSetUnitPrice_CaptionLbl: Label 'Preset Unit Price';
        ParamPreSetUnitPrice_DescLbl: Label 'Specifies the Preset Unit Price';
        ParamMinQty_CaptionLbl: Label 'Minimum Allowed Quantity';
        ParamMinQty_DescLbl: Label 'Specifies the Minimum Allowed Quantity';
        ParamMaxQty_CaptionLbl: Label 'Maximum Allowed Quantity';
        ParamMaxQty_DescLbl: Label 'Specifies the Maximum Allowed Quantity';
        ParamQtyDialogThreshold_CaptionLbl: Label 'Quantity Dialog Thershold';
        ParamQtyDialogThreshold_DescLbl: Label 'Specifies the Quantity Dialog Thershold';
        ValidRangeText: Label 'The valid range is %1 to %2.';
        EnterQuantityCaption: Label 'Enter Quantity';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddOptionParameter(
                       'itemIdentifyerType',
                       ParamItemIdentifierOptionsLbl,
# pragma warning disable AA0139
                       SelectStr(1, ParamItemIdentifierOptionsLbl),
# pragma warning restore
                       ParamItemIdentifierType_CaptionLbl,
                       ParamItemIdentifierType_DescLbl,
                       ParamItemIdentifierOptions_CaptionLbl);
        WorkflowConfig.AddTextParameter('itemNo', '', ParamItemNo_CaptionLbl, ParamItemNo_DescLbl);
        WorkflowConfig.AddDecimalParameter('itemQuantity', 1, ParamItemQty_CaptionLbl, ParamItemQty_DescLbl);
        WorkflowConfig.AddBooleanParameter('descriptionEdit', false, ParamEditDescription_CaptionLbl, ParamEditDescription_DescLbl);
        WorkflowConfig.AddBooleanParameter('usePreSetUnitPrice', false, ParamUsePreSetUnitPrice_CaptionLbl, ParamUsePreSetUnitPrice_DescLbl);
        WorkflowConfig.AddDecimalParameter('preSetUnitPrice', 0, ParamPreSetUnitPrice_CaptionLbl, ParamPreSetUnitPrice_DescLbl);
        WorkflowConfig.AddDecimalParameter('minimumAllowedQuantity', 1, ParamMinQty_CaptionLbl, ParamMinQty_DescLbl);
        WorkflowConfig.AddDecimalParameter('maximalAllowedQuantity', 0, ParamMaxQty_CaptionLbl, ParamMaxQty_DescLbl);
        WorkflowConfig.AddDecimalParameter('qtyDialogThreshold', 10, ParamQtyDialogThreshold_CaptionLbl, ParamQtyDialogThreshold_DescLbl);
        WorkflowConfig.AddLabel('EnterQuantityCaption', EnterQuantityCaption);
        WorkflowConfig.AddLabel('ValidRangeText', ValidRangeText);
        WorkflowConfig.SetNonBlockingUI();
        WorkflowConfig.SetWorkflowTypeUnattended();
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; SaleMgr: codeunit "NPR POS Sale"; SaleLineMgr: codeunit "NPR POS Sale Line"; PaymentLineMgr: codeunit "NPR POS Payment Line"; SetupMgr: codeunit "NPR POS Setup");
    begin
        case Step of
            'AddSalesLine':
                FrontEnd.WorkflowResponse(Step_AddSalesLine(Context, FrontEnd));
            'IncreaseQuantity':
                Step_IncreaseQuantity(Context, FrontEnd);
            'DecreaseQuantity':
                Step_DecreaseQuantity(Context);
            'SetSpecificQuantity':
                Step_SetQuantity(Context, FrontEnd);
        end;
    end;

    local procedure Step_AddSalesLine(Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management") Response: JsonObject
    var
        UsePresetUnitPrice: Boolean;
        ItemQuantity: Decimal;
        ItemMinQuantity: Decimal;
        PresetUnitPrice: Decimal;
        ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch;
        ItemIdentifier: Text;
        WorkflowVersion: Integer;
        POSAction: Record "NPR POS Action";
        SSActionInsertItemB: Codeunit "NPR POSAction: SS Insert ItemB";
        Item: Record Item;
    begin
        ItemIdentifier := Context.GetStringParameter('itemNo');
        ItemIdentifierType := Context.GetIntegerParameter('itemIdentifyerType');
        ItemQuantity := Context.GetDecimalParameter('itemQuantity');
        ItemMinQuantity := Context.GetDecimalParameter('minimumAllowedQuantity');
        UsePresetUnitPrice := Context.GetBooleanParameter('usePreSetUnitPrice');
        PresetUnitPrice := Context.GetDecimalParameter('preSetUnitPrice');

        SSActionInsertItemB.AddSalesLine(ItemIdentifierType, ItemIdentifier, ItemMinQuantity, ItemQuantity, PresetUnitPrice, UsePresetUnitPrice);

        if Item."NPR Item AddOn No." <> '' then begin
            POSAction.Get('SS-ITEM-ADDON');
            if (POSAction."Workflow Implementation" = POSAction."Workflow Implementation"::LEGACY) then begin
                WorkflowVersion := 1;
                AddItemAddOns(FrontEnd, Item);
            end else begin
                WorkflowVersion := 3;
                Response.Add('AddItemAddOn', true);
                Response.Add('workflowVersion', WorkflowVersion);
            end;
        end else
            Response.Add('AddItemAddOn', false);
    end;

    local procedure Step_DecreaseQuantity(Context: codeunit "NPR POS JSON Helper")
    var
        ItemIdentifier: Text;
        ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch;
        DecreaseByQty: Decimal;
        ItemMinQuantity: Decimal;
        SSActionInsertItemB: Codeunit "NPR POSAction: SS Insert ItemB";
    begin
        ItemIdentifier := Context.GetStringParameter('itemNo');
        ItemIdentifierType := Context.GetIntegerParameter('itemIdentifyerType');
        DecreaseByQty := Context.GetDecimalParameter('itemQuantity');
        ItemMinQuantity := Context.GetDecimalParameter('minimumAllowedQuantity');

        SSActionInsertItemB.DecreaseQuantity(ItemIdentifier, ItemIdentifierType, DecreaseByQty, ItemMinQuantity);
    end;

    local procedure Step_IncreaseQuantity(Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management")
    var
        IncreaseByQty: Decimal;
        ItemMaxQty: Decimal;
        ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch;
        ItemIdentifier: Text;
        SSActionInsertItemB: Codeunit "NPR POSAction: SS Insert ItemB";
    begin
        ItemIdentifier := Context.GetStringParameter('itemNo');
        ItemIdentifierType := Context.GetIntegerParameter('itemIdentifyerType');
        IncreaseByQty := Context.GetDecimalParameter('itemQuantity');
        ItemMaxQty := Context.GetDecimalParameter('maximalAllowedQuantity');

        if not SSActionInsertItemB.IncreaseQuantity(ItemIdentifier, ItemIdentifierType, IncreaseByQty, ItemMaxQty) then
            Step_AddSalesLine(Context, FrontEnd);


    end;

    local procedure Step_SetQuantity(Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management")
    var
        ItemIdentifier: Text;
        ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch;
        ItemQuantity: Decimal;
        SSActionInsertItemB: Codeunit "NPR POSAction: SS Insert ItemB";
    begin
        ItemIdentifier := Context.GetStringParameter('itemNo');
        ItemIdentifierType := Context.GetIntegerParameter('itemIdentifyerType');
        ItemQuantity := Context.GetDecimal('specificQuantity');

        if not SSActionInsertItemB.SetQuantity(ItemIdentifier, ItemIdentifierType, ItemQuantity) then
            Step_AddSalesLine(Context, FrontEnd);
    end;


    local procedure AddItemAddOns(POSFrontEnd: Codeunit "NPR POS Front End Management"; Item: Record Item)
    var
        POSAction: Record "NPR POS Action";
    begin
        if Item."NPR Item AddOn No." = '' then
            exit;

        POSAction.Get('SS-ITEM-ADDON');
        POSFrontEnd.InvokeWorkflow(POSAction);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
    begin
        if not EanBoxEvent.Get(EventCodeItemNo()) then begin
            EanBoxEvent.Init();
            EanBoxEvent.Code := EventCodeItemNo();
            EanBoxEvent."Module Name" := CopyStr(Item.TableCaption, 1, MaxStrLen(EanBoxEvent."Module Name"));
            EanBoxEvent.Description := CopyStr(ItemReference.FieldCaption("Item No."), 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;

        if not EanBoxEvent.Get(EventCodeItemRef()) then begin
            EanBoxEvent.Init();
            EanBoxEvent.Code := EventCodeItemRef();
            EanBoxEvent."Module Name" := CopyStr(Item.TableCaption, 1, MaxStrLen(EanBoxEvent."Module Name"));
            EanBoxEvent.Description := CopyStr(ItemReference.TableCaption, 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;

        if not EanBoxEvent.Get(EventCodeItemSearch()) then begin
            EanBoxEvent.Init();
            EanBoxEvent.Code := EventCodeItemSearch();
            EanBoxEvent."Module Name" := CopyStr(Item.TableCaption, 1, MaxStrLen(EanBoxEvent."Module Name"));
            EanBoxEvent.Description := CopyStr(Item.FieldCaption("Search Description"), 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;
        if not EanBoxEvent.Get(EventCodeSerialNoItemRef()) then begin
            EanBoxEvent.Init();
            EanBoxEvent.Code := EventCodeSerialNoItemRef();
            EanBoxEvent."Module Name" := CopyStr(Item.TableCaption, 1, MaxStrLen(EanBoxEvent."Module Name"));
            EanBoxEvent.Description := CopyStr(ItemReference.TableCaption, 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "NPR POS Input Box Setup Mgt."; EanBoxEvent: Record "NPR Ean Box Event")
    begin
        case EanBoxEvent.Code of
            EventCodeItemNo():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'itemNo', true, '');
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'itemIdentifyerType', false, 'ItemNo');
                end;
            EventCodeItemRef():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'itemNo', true, '');
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'itemIdentifyerType', false, 'ItemCrossReference');
                end;
            EventCodeItemSearch():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'itemNo', true, '');
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'itemIdentifyerType', false, 'ItemSearch');
                end;
            EventCodeSerialNoItemRef():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'itemNo', true, '');
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'itemIdentifyerType', false, 'SerialNoItemCrossReference');
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Evt Handler", 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeItemNo(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        Item: Record Item;
    begin
        if EanBoxSetupEvent."Event Code" <> EventCodeItemNo() then
            exit;
        if StrLen(EanBoxValue) > MaxStrLen(Item."No.") then
            exit;

        Item.SetLoadFields("No.");
        Item.SetRange("No.", UpperCase(EanBoxValue));
        if not Item.IsEmpty() then
            InScope := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Evt Handler", 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeItemCrossRef(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        ItemReference: Record "Item Reference";
    begin
        if EanBoxSetupEvent."Event Code" <> EventCodeItemRef() then
            exit;
        if StrLen(EanBoxValue) > MaxStrLen(ItemReference."Reference No.") then
            exit;

        ItemReference.SetLoadFields("Reference No.");
        ItemReference.SetCurrentKey("Reference Type", "Reference No.");
        ItemReference.SetRange("Reference No.", UpperCase(EanBoxValue));
        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
        if not ItemReference.IsEmpty() then
            InScope := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Evt Handler", 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeItemSearch(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        Item: Record Item;
        SSActionInsertItemB: Codeunit "NPR POSAction: SS Insert ItemB";
    begin
        if EanBoxSetupEvent."Event Code" <> EventCodeItemSearch() then
            exit;

        SSActionInsertItemB.SetItemSearchFilter(EanBoxValue, Item);
        if not Item.IsEmpty() then
            InScope := true;
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR POS Action: Insert Item");
    end;

    local procedure EventCodeItemNo(): Code[20]
    begin
        exit('SS_ITEMNO');
    end;

    local procedure EventCodeItemRef(): Code[20]
    begin
        exit('SS_ITEM_X_REF_NO');
    end;

    local procedure EventCodeItemSearch(): Code[20]
    begin
        exit('SS_ITEM_SEARCH');
    end;

    local procedure EventCodeSerialNoItemRef(): Code[20]
    begin
        exit('SS_SERIALNO_X_REF');
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionSSInsertItem.js###
'let main=async({workflow:s,context:i,popup:o,runtime:f,parameters:t,captions:l})=>{debugger;let u="AddSalesLine";if(i.hasOwnProperty("_additionalContext")){i._additionalContext.hasOwnProperty("plusMinus")&&(u=i._additionalContext.quantity>0?"IncreaseQuantity":"DecreaseQuantity");let a=f.getData("BUILTIN_SALELINE").find(e=>e[6]===t.itemNo)||null;if(console.log("Searching for item: "+t.itemNo+" found row: "+JSON.stringify(a)),a!=null&&t.qtyDialogThreshold>0&&(a[12]>=t.qtyDialogThreshold&&i._additionalContext.quantity>0||a[12]>t.qtyDialogThreshold&&i._additionalContext.quantity<0)){let e=t.itemQuantity>0?t.itemQuantity:1,n=t.minimumAllowedQuantity||1,d=t.maximalAllowedQuantity>0?t.maximalAllowedQuantity:n<100?100:n,y=i._additionalContext.quantity>0?a[12]+e:a[12]-e;if(Math.abs(y)<n&&(y=0),i.specificQuantity=await o.intpad({title:l.EnterQuantityCaption,caption:l.EnterQuantityCaption,value:y}),i.specificQuantity===null)return;if(Math.abs(i.specificQuantity)>d||i.specificQuantity!=0&&Math.abs(i.specificQuantity)<n){await o.message({title:l.EnterQuantityCaption,caption:l.ValidRangeText.substitute(n,d)});return}u="SetSpecificQuantity"}}await s.respond(u)};'
        );
    end;

    local procedure ActionCode(): Code[20]

    begin
        exit(Format(Enum::"NPR POS Workflow"::"SS-ITEM"));
    end;

}
