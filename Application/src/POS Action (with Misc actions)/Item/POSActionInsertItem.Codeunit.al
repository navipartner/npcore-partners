codeunit 6150723 "NPR POS Action: Insert Item" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        UnitPriceCaption: Label 'This is item is an item group. Specify the unit price for item.';
        UnitPriceTitle: Label 'Unit price is required';
        StartTime: DateTime;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This is a built-in action for inserting an item line into the current transaction';
        ParamItemIdentifierType_CaptionLbl: Label 'Item Identifier Type';
        ParamItemIdentifierType_DescLbl: Label 'Specifies the Item Identifier Type';
        ParamItemIdentifierOptionsLbl: Label 'ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference', Locked = true;
        ParamItemIdentifierOptions_CaptionLbl: Label 'ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference';
        ParamItemNo_CaptionLbl: Label 'Item No.';
        ParamItemNo_DescLbl: Label 'Specifies the Item No.';
        ParamEditDescription_CaptionLbl: Label 'Edit Description';
        ParamEditDescription_DescLbl: Label 'Enable/Disable Edit Description';
        ParamEditDescription2_CaptionLbl: Label 'Edit Description 2';
        ParamEditDescription2_DescLbl: Label 'Enable/Disable Edit Description 2';
        ParamUsePreSetUnitPrice_CaptionLbl: Label 'usePreSetUnitPrice';
        ParamUsePreSetUnitPrice_DescLbl: Label 'Enable/Disable preset of Unit Price';
        ParamPreSetUnitPrice_CaptionLbl: Label 'Preset Unit Price';
        ParamPreSetUnitPrice_DescLbl: Label 'Specifies the Preset Unit Price';
        ParamSelectSerialNo_CaptionLbl: Label 'Select Serial No.';
        ParamSelectSerialNo_DescLbl: Label 'Enable/Disable select Serial No. from the list';
        ParamSkipItemAvailabilityCheck_CaptionLbl: Label 'Skip Item Availability Check';
        ParamSkipItemAvailabilityCheck_DescLbl: Label 'Enable/Disable skip Item Availability Check';
        ParamItemQty_CaptionLbl: Label 'Item Quantity';
        ParamItemQty_DescLbl: Label 'Specifies the Item Quantity';
        ItemTracking_TitleLbl: Label 'Enter Serial Number';
        ItemTracking_LeadLbl: Label 'This item requires serial number, enter serial number.';
        EditDesc_titleLbl: Label 'Add or change description.';
        EditDesc2_titleLbl: Label 'Add or change description 2.';
        ItemTracking_InstrLbl: Label 'Enter serial number now and press OK. Press Cancel to enter serial number later.';

    begin
        WorkflowConfig.SetNonBlockingUI();
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddLabel('itemTracking_title', ItemTracking_TitleLbl);
        WorkflowConfig.AddLabel('itemTracking_lead', ItemTracking_LeadLbl);
        WorkflowConfig.AddLabel('UnitPriceTitle', UnitPriceTitle);
        WorkflowConfig.AddLabel('UnitPriceCaption', UnitPriceCaption);
        WorkflowConfig.AddLabel('editDesc_title', EditDesc_titleLbl);
        WorkflowConfig.AddLabel('editDesc_lead', EditDesc_titleLbl);
        WorkflowConfig.AddLabel('editDesc2_lead', EditDesc2_titleLbl);
        WorkflowConfig.AddLabel('itemTracking_instructions', ItemTracking_InstrLbl);

        WorkflowConfig.AddOptionParameter(
                       'itemIdentifierType',
                       ParamItemIdentifierOptionsLbl,
#pragma warning disable AA0139
                       SelectStr(1, ParamItemIdentifierOptionsLbl),
#pragma warning restore 
                       ParamItemIdentifierType_CaptionLbl,
                       ParamItemIdentifierType_DescLbl,
                       ParamItemIdentifierOptions_CaptionLbl);
        WorkflowConfig.AddTextParameter('itemNo', '', ParamItemNo_CaptionLbl, ParamItemNo_DescLbl);
        WorkflowConfig.AddDecimalParameter('itemQuantity', 1, ParamItemQty_CaptionLbl, ParamItemQty_DescLbl);
        WorkflowConfig.AddBooleanParameter('EditDescription', false, ParamEditDescription_CaptionLbl, ParamEditDescription_DescLbl);
        WorkflowConfig.AddBooleanParameter('EditDescription2', false, ParamEditDescription2_CaptionLbl, ParamEditDescription2_DescLbl);
        WorkflowConfig.AddBooleanParameter('usePreSetUnitPrice', false, ParamUsePreSetUnitPrice_CaptionLbl, ParamUsePreSetUnitPrice_DescLbl);
        WorkflowConfig.AddDecimalParameter('preSetUnitPrice', 0, ParamPreSetUnitPrice_CaptionLbl, ParamPreSetUnitPrice_DescLbl);
        WorkflowConfig.AddBooleanParameter('SelectSerialNo', false, ParamSelectSerialNo_CaptionLbl, ParamSelectSerialNo_DescLbl);
        WorkflowConfig.AddBooleanParameter('SkipItemAvailabilityCheck', false, ParamSkipItemAvailabilityCheck_CaptionLbl, ParamSkipItemAvailabilityCheck_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
    begin
        case Step of
            'addSalesLine':
                FrontEnd.WorkflowResponse(Step_AddSalesLine(Context, FrontEnd, Setup));
            'checkAvailability':
                CheckAvailability(Context);
        end;
    end;

    local procedure IfAddItemAddOns(Item: Record Item): Boolean
    begin
        exit(Item."NPR Item Addon No." <> '')
    end;

    local procedure Step_AddSalesLine(Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Setup: Codeunit "NPR POS Setup") Response: JsonObject
    var
        UseSpecificTracking: Boolean;
        InputSerial: Code[50];
        UnitPrice: Decimal;
        ItemIdentifier: Text;
        ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference;
        Item: Record Item;
        ItemReference: Record "Item Reference";
        ItemQuantity: Decimal;
        UsePresetUnitPrice: Boolean;
        PresetUnitPrice: Decimal;
        CustomDescription: Text;
        CustomDescription2: Text;
        ValidatedVariantCode: Text;
        PosInventoryProfile: Record "NPR POS Inventory Profile";
        PosItemCheckAvail: Codeunit "NPR POS Item-Check Avail.";
        SkipItemAvailabilityCheck: Boolean;
        POSSession: Codeunit "NPR POS Session";
        EditDesc: Boolean;
        EditDesc2: Boolean;
        POSActionInsertItemB: Codeunit "NPR POS Action: Insert Item B";
        SerialSelectionFromList: Boolean;
        SerialNumberInput: Text;
        UserInformationErrorWarning: Text;
        POSStore: Record "NPR POS Store";
        Success: Boolean;
        GetPromptSerial: Boolean;
        BaseLineNo: Integer;
    begin
        ItemIdentifier := Context.GetStringParameter('itemNo');
        ItemIdentifierType := Context.GetIntegerParameter('itemIdentifierType');
        ItemQuantity := Context.GetDecimalParameter('itemQuantity');
        UsePresetUnitPrice := Context.GetBooleanParameter('usePreSetUnitPrice');
        PresetUnitPrice := Context.GetDecimalParameter('preSetUnitPrice');
        SkipItemAvailabilityCheck := Context.GetBooleanParameter('SkipItemAvailabilityCheck');
        EditDesc := Context.GetBooleanParameter('EditDescription');
        EditDesc2 := Context.GetBooleanParameter('EditDescription2');
        SerialSelectionFromList := Context.GetBooleanParameter('SelectSerialNo');

        if ItemIdentifierType < 0 then
            ItemIdentifierType := 0;

        POSActionInsertItemB.GetItem(Item, ItemReference, ItemIdentifier, ItemIdentifierType);

        LogStartTelem();

        if EditDesc then
            CustomDescription := Context.GetString('Desc1');

        if EditDesc2 then
            CustomDescription2 := Context.GetString('Desc2');

        if UsePresetUnitPrice then
            UnitPrice := PresetUnitPrice;

        if Item."NPR Group sale" then begin
            Response.ReadFrom('{}');
            Response.Add('ItemGroupSale', true);
        end;

        if POSActionInsertItemB.ItemRequiresSerialNumberOnSale(Item, UseSpecificTracking) then begin
            Response.Add('GetPromptSerial', true);
            GetPromptSerial := true;
        end;

        Response.Add('useSpecTracking', UseSpecificTracking);

        Success := (not UseSpecificTracking) and (not Item."NPR Group sale") and (not GetPromptSerial);
        Response.Add('Success', Success);

        If Not Success then
            If Context.GetBoolean('GetPrompt') = true then begin
                if SerialSelectionFromList then begin
                    while not POSActionInsertItemB.SerialNumberCanBeUsedForItem(ItemReference, CopyStr(SerialNumberInput, 1, MaxStrLen(InputSerial)), UserInformationErrorWarning, SerialSelectionFromList) do begin
                        if SerialNumberInput <> '' then
                            Message(UserInformationErrorWarning);
                        SerialNumberInput := '';
                        Setup.GetPOSStore(POSStore);
                        POSActionInsertItemB.SelectSerialNoFromList(ItemReference, POSStore."Location Code", SerialNumberInput);
                        if SerialNumberInput = '' then
                            Error('');
                    end;
                end else
                    if not POSActionInsertItemB.SerialNumberCanBeUsedForItem(ItemReference, CopyStr(SerialNumberInput, 1, MaxStrLen(InputSerial)), UserInformationErrorWarning, SerialSelectionFromList) then begin
                        SerialNumberInput := '';
                    end;
                ValidatedVariantCode := ItemReference."Variant Code";

                if Item."NPR Group sale" then
                    UnitPrice := Context.GetDecimal('UnitPrice');

                if SerialNumberInput = '' then begin
                    if (UseSpecificTracking) or (GetPromptSerial) then
                        InputSerial := CopyStr(Context.GetString('SerialNo'), 1, MaxStrLen(InputSerial))
                end else
                    InputSerial := CopyStr(SerialNumberInput, 1, MaxStrLen(InputSerial));

            end else
                exit;

        Clear(PosItemCheckAvail);
        if not SkipItemAvailabilityCheck then begin
            PosItemCheckAvail.GetPosInvtProfile(POSSession, PosInventoryProfile);
            if PosInventoryProfile."Stockout Warning" then
                PosItemCheckAvail.SetxDataset(POSSession);
            POSSession.SetAvailabilityCheckState(PosItemCheckAvail);
        end;

        POSActionInsertItemB.AddItemLine(Item, ItemReference, ItemIdentifierType, ItemQuantity, UnitPrice, CustomDescription, CustomDescription2, InputSerial, POSSession, FrontEnd);
        if IfAddItemAddOns(Item) then begin
            Response.Add('AddItemAddOn', true);
            BaseLineNo := POSActionInsertItemB.GetLineNo();
            Response.Add('BaseLineNo', BaseLineNo);
        end else
            if not SkipItemAvailabilityCheck then
                CheckAvailability(PosInventoryProfile, PosItemCheckAvail);

        LogFinishTelem();
    end;

    local procedure LogStartTelem()
    begin
        StartTime := CurrentDateTime();
    end;

    local procedure LogFinishTelem()
    var
        FinishEventIdTok: Label 'NPR_POSActAddItem', Locked = true;
        LogDict: Dictionary of [Text, Text];
        MsgTok: Label 'Company:%1, Tenant: %2, Instance: %3, Server: %4, Duration: %5';
        Msg: Text;
        ActiveSession: Record "Active Session";
        ItemAddedDur: Duration;
        DurationMs: Integer;
    begin
        if not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId()) then
            Clear(ActiveSession);
        ItemAddedDur := CurrentDateTime() - StartTime;
        DurationMs := ItemAddedDur;

        LogDict.Add('NPR_Server', ActiveSession."Server Computer Name");
        LogDict.Add('NPR_Instance', ActiveSession."Server Instance Name");
        LogDict.Add('NPR_TenantId', Database.TenantId());
        LogDict.Add('NPR_CompanyName', CompanyName());
        LogDict.Add('NPR_UserID', ActiveSession."User ID");
        LogDict.Add('NPR_POSInitializationDuration', Format(DurationMs, 0, 9));
        Msg := StrSubstNo(MsgTok, CompanyName(), Database.TenantId(), ActiveSession."Server Instance Name", ActiveSession."Server Computer Name", Format(DurationMs, 0, 9));
        Session.LogMessage(FinishEventIdTok, 'POS Action Add Item: ' + Msg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, LogDict);
    end;


    local procedure CheckAvailability(Context: Codeunit "NPR POS JSON Helper")
    var
        PosInventoryProfile: Record "NPR POS Inventory Profile";
        SkipItemAvailabilityCheck: Boolean;
        PosItemCheckAvail: Codeunit "NPR POS Item-Check Avail.";
        POSSession: Codeunit "NPR POS Session";
    begin
        SkipItemAvailabilityCheck := Context.GetBooleanParameter('SkipItemAvailabilityCheck');

        if not SkipItemAvailabilityCheck then begin
            POSSession.GetAvailabilityCheckState(PosItemCheckAvail);
            PosItemCheckAvail.GetPosInvtProfile(POSSession, PosInventoryProfile);
            CheckAvailability(PosInventoryProfile, PosItemCheckAvail);
        end;
    end;

    local procedure CheckAvailability(PosInventoryProfile: Record "NPR POS Inventory Profile"; PosItemCheckAvail: Codeunit "NPR POS Item-Check Avail.")
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        if PosInventoryProfile."Stockout Warning" then
            PosItemCheckAvail.DefineScopeAndCheckAvailability(POSSession, false);
        POSSession.ClearAvailabilityCheckState();
    end;

    procedure ActionCode(): Text
    begin
        exit(Format(enum::"NPR POS Workflow"::ITEM));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    var
        Item: Record Item;
        ItemRef: Record "Item Reference";
    begin
        if not EanBoxEvent.Get(EventCodeItemNo()) then begin
            EanBoxEvent.Init();
            EanBoxEvent.Code := EventCodeItemNo();
            EanBoxEvent."Module Name" := CopyStr(Item.TableCaption, 1, MaxStrLen(EanBoxEvent."Module Name"));
            EanBoxEvent.Description := CopyStr(ItemRef.FieldCaption("Item No."), 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := CopyStr(ActionCode(), 1, MaxStrLen(EanBoxEvent."Action Code"));
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;

        if not EanBoxEvent.Get(EventCodeItemRef()) then begin
            EanBoxEvent.Init();
            EanBoxEvent.Code := EventCodeItemRef();
            EanBoxEvent."Module Name" := CopyStr(Item.TableCaption, 1, MaxStrLen(EanBoxEvent."Module Name"));
            EanBoxEvent.Description := CopyStr(ItemRef.TableCaption, 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := CopyStr(ActionCode(), 1, MaxStrLen(EanBoxEvent."Action Code"));
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;

        if not EanBoxEvent.Get(EventCodeItemSearch()) then begin
            EanBoxEvent.Init();
            EanBoxEvent.Code := EventCodeItemSearch();
            EanBoxEvent."Module Name" := CopyStr(Item.TableCaption, 1, MaxStrLen(EanBoxEvent."Module Name"));
            EanBoxEvent.Description := CopyStr(Item.FieldCaption("Search Description"), 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := CopyStr(ActionCode(), 1, MaxStrLen(EanBoxEvent."Action Code"));
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;

        if not EanBoxEvent.Get(EventCodeSerialNoItemRef()) then begin
            EanBoxEvent.Init();
            EanBoxEvent.Code := EventCodeSerialNoItemRef();
            EanBoxEvent."Module Name" := CopyStr(Item.TableCaption, 1, MaxStrLen(EanBoxEvent."Module Name"));
            EanBoxEvent.Description := CopyStr(ItemRef.TableCaption, 1, MaxStrLen(EanBoxEvent.Description));
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
            EventCodeItemNo():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'itemNo', true, '');
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'itemIdentifierType', false, 'ItemNo');
                end;
            EventCodeItemRef():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'itemNo', true, '');
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'itemIdentifierType', false, 'ItemCrossReference');
                end;
            EventCodeItemSearch():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'itemNo', true, '');
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'itemIdentifierType', false, 'ItemSearch');
                end;
            EventCodeSerialNoItemRef():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'itemNo', true, '');
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'itemIdentifierType', false, 'SerialNoItemCrossReference');
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
        POSActionInsertItemB: Codeunit "NPR POS Action: Insert Item B";
    begin
        if EanBoxSetupEvent."Event Code" <> EventCodeItemSearch() then
            exit;

        POSActionInsertItemB.SetItemSearchFilter(EanBoxValue, Item, false);
        if Item.IsEmpty() then
            exit;

        POSActionInsertItemB.SetItemSearchFilter(EanBoxValue, Item, true);
        if not Item.IsEmpty() then
            InScope := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Evt Handler", 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeSerialNoItemCrossRef(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        ItemReference: Record "Item Reference";
    begin
        if EanBoxSetupEvent."Event Code" <> EventCodeSerialNoItemRef() then
            exit;

        if StrLen(EanBoxValue) > MaxStrLen(ItemReference."Reference No.") then
            exit;

        ItemReference.SetCurrentKey("Reference Type", "Reference No.");
        ItemReference.SetRange("Reference No.", UpperCase(EanBoxValue));
        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"NPR Retail Serial No.");
        if not ItemReference.IsEmpty() then
            InScope := true;
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR POS Action: Insert Item");
    end;

    local procedure EventCodeItemNo(): Code[20]
    begin
        exit('ITEMNO');
    end;

    local procedure EventCodeItemRef(): Code[20]
    begin
        exit('ITEMCROSSREFERENCENO');
    end;

    local procedure EventCodeItemSearch(): Code[20]
    begin
        exit('ITEMSEARCH');
    end;

    local procedure EventCodeSerialNoItemRef(): Code[20]
    begin
        exit('SERIALNOITEMCROSSREF');
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionInsertItem.js###
'let main=async({workflow:e,context:c,scope:S,popup:i,parameters:n,captions:t})=>{if(e.context.GetPrompt=!1,n.EditDescription&&(e.context.Desc1=await i.input({title:t.editDesc_title,caption:t.editDesc_lead,value:c.defaultDescription}),e.context.Desc1===null)||n.EditDescription2&&(e.context.Desc2=await i.input({title:t.editDesc2_title,caption:t.editDesc2_lead,value:c.defaultDescription}),e.context.Desc2===null))return" ";const{ItemGroupSale:l,useSpecTracking:a,GetPromptSerial:d,Success:u,AddItemAddOn:r,BaseLineNo:s}=await e.respond("addSalesLine");if(!u){if(e.context.GetPrompt=!0,l&&!n.usePreSetUnitPrice&&(e.context.UnitPrice=await i.numpad({title:t.UnitpriceTitle,caption:t.UnitPriceCaption}),e.context.UnitPrice===null)||a&&!n.SelectSerialNo&&(e.context.SerialNo=await i.input({title:t.itemTracking_title,caption:t.itemTracking_lead}),e.context.SerialNo===null)||!a&&d&&(e.context.SerialNo=await i.input({title:t.itemTracking_title,caption:t.itemTracking_lead}),e.context.SerialNo===null))return" ";e.context.useSpecTracking=a,await e.respond("addSalesLine")}r&&(await e.run("RUN_ITEM_ADDONS",{context:{BaseLineNo:s},parameters:{SkipItemAvailabilityCheck:!0}}),await e.respond("checkAvailability"))};'
        );
    end;

}
