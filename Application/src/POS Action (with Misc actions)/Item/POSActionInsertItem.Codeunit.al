codeunit 6150723 "NPR POS Action: Insert Item" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        StartTime: DateTime;
        UnitPriceCaption: Label 'This is item is an item group. Specify the unit price for item.';
        UnitPriceTitle: Label 'Unit price is required';

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This is a built-in action for inserting an item line into the current transaction';
        BOMItemTracking_LeadLbl: Label 'BOM component item {0} of BOM item {1} requires serial number. Please enter serial number.';
        SerialNoError_titleLbl: Label 'Serial No. error';
        EditDesc2_titleLbl: Label 'Add or change description 2.';
        EditDesc_titleLbl: Label 'Add or change description.';
        ItemTracking_InstrLbl: Label 'Enter serial number now and press OK. Press Cancel to enter serial number later.';
        ItemTracking_LeadLbl: Label 'This item requires serial number, enter serial number.';
        ItemTracking_TitleLbl: Label 'Enter Serial Number';
        ParamEditDescription2_CaptionLbl: Label 'Edit Description 2';
        ParamEditDescription2_DescLbl: Label 'Enable/Disable Edit Description 2';
        ParamEditDescription_CaptionLbl: Label 'Edit Description';
        ParamEditDescription_DescLbl: Label 'Enable/Disable Edit Description';
        ParamItemIdentifierOptions_CaptionLbl: Label 'ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference';
        ParamItemIdentifierOptionsLbl: Label 'ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference', Locked = true;
        ParamItemIdentifierType_CaptionLbl: Label 'Item Identifier Type';
        ParamItemIdentifierType_DescLbl: Label 'Specifies the Item Identifier Type';
        ParamItemNo_CaptionLbl: Label 'Item No.';
        ParamItemNo_DescLbl: Label 'Specifies the Item No.';
        ParamItemQty_CaptionLbl: Label 'Item Quantity';
        ParamItemQty_DescLbl: Label 'Specifies the Item Quantity';
        ParamPreSetUnitPrice_CaptionLbl: Label 'Preset Unit Price';
        ParamPreSetUnitPrice_DescLbl: Label 'Specifies the Preset Unit Price';
        ParamSelectSerialNo_CaptionLbl: Label 'Select Serial No.';
        ParamSelectSerialNo_DescLbl: Label 'Enable/Disable select Serial No. from the list';
        ParamSkipItemAvailabilityCheck_CaptionLbl: Label 'Skip Item Availability Check';
        ParamSkipItemAvailabilityCheck_DescLbl: Label 'Enable/Disable skip Item Availability Check';
        ParamUsePreSetUnitPrice_CaptionLbl: Label 'usePreSetUnitPrice';
        ParamUsePreSetUnitPrice_DescLbl: Label 'Enable/Disable preset of Unit Price';
        ParamUnitOfMeasure_CaptionLbl: Label 'Unit of Measure';
        ParamUnitOfMeasure_DescLbl: Label 'Specifies Unit of Measure for Item';

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
        WorkflowConfig.AddLabel('bomItemTracking_Lead', BOMItemTracking_LeadLbl);
        WorkflowConfig.AddLabel('serialNoError_title', SerialNoError_titleLbl);

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
        WorkflowConfig.AddTextParameter('unitOfMeasure', '', ParamUnitOfMeasure_CaptionLbl, ParamUnitOfMeasure_DescLbl);
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
            'assignSerialNo':
                FrontEnd.WorkflowResponse(AssignSerialNo(Context, Setup));
        end;
    end;

    local procedure IfAddItemAddOns(Item: Record Item): Boolean
    begin
        exit(Item."NPR Item Addon No." <> '')
    end;

    local procedure Step_AddSalesLine(Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Setup: Codeunit "NPR POS Setup") Response: JsonObject
    var
        InputSerial: Text[50];
        ItemIdentifier: Text;
        ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference,ItemGtin;
        Item: Record Item;
        ItemReference: Record "Item Reference";
        PosInventoryProfile: Record "NPR POS Inventory Profile";
        NPRPOSStore: Record "NPR POS Store";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSActionInsertItemB: Codeunit "NPR POS Action: Insert Item B";
        PosItemCheckAvail: Codeunit "NPR POS Item-Check Avail.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSession: Codeunit "NPR POS Session";
        NPRPOSTrackingUtils: Codeunit "NPR POS Tracking Utils";
        EditDesc: Boolean;
        EditDesc2: Boolean;
        SerialSelectionFromList: Boolean;
        SkipItemAvailabilityCheck: Boolean;
        RequiresAdditionalInformationCollection: Boolean;
        UsePresetUnitPrice: Boolean;
        RequiresSerialNoInput: Boolean;
        RequiresSerialNoInputPrompt: Boolean;
        RequiresUnitPriceInputPrompt: Boolean;
        RequiresSpecificSerialNo: Boolean;
        RequiresUnitPriceInput: Boolean;
        AdditionalInformationCollected: Boolean;
        ItemQuantity: Decimal;
        PresetUnitPrice: Decimal;
        UnitPrice: Decimal;
        BaseLineNo: Integer;
        BOMComponentLinesWithoutSerialNoJsonArray: JsonArray;
        CustomDescription: Text;
        CustomDescription2: Text;
        UnitOfMeasure: Text;
    begin
        ItemIdentifier := Context.GetStringParameter('itemNo');
        UnitOfMeasure := Context.GetStringParameter('unitOfMeasure');
        ItemIdentifierType := Context.GetIntegerParameter('itemIdentifierType');

        if ItemIdentifierType < 0 then
            ItemIdentifierType := 0;

        Item.SetLoadFields("NPR Explode BOM auto", "Assembly BOM", "NPR Group sale", "Item Category Code", "Price Includes VAT", "VAT Bus. Posting Gr. (Price)", "VAT Prod. Posting Group", "NPR Item Addon No.");
        Item.SetAutoCalcFields("Assembly BOM");
        POSActionInsertItemB.GetItem(Item, ItemReference, ItemIdentifier, ItemIdentifierType);

        LogStartTelem();

        POSActionInsertItemB.GetItemAdditionalInformationRequirements(Item, RequiresSerialNoInput, RequiresSpecificSerialNo, RequiresUnitPriceInput);

        if RequiresSerialNoInput then
            if not Context.GetBooleanParameter('SelectSerialNo', SerialSelectionFromList) then;

        if not Context.GetBooleanParameter('usePreSetUnitPrice', UsePresetUnitPrice) then;

        POSActionInsertItemB.CheckItemRequiresAdditionalInformationInput(RequiresSerialNoInput, RequiresUnitPriceInput, SerialSelectionFromList, UsePresetUnitPrice, RequiresSpecificSerialNo, RequiresUnitPriceInputPrompt, RequiresSerialNoInputPrompt, RequiresAdditionalInformationCollection);
        If RequiresAdditionalInformationCollection then begin
            if not Context.GetBoolean('additionalInformationCollected', AdditionalInformationCollected) then;

            if (not AdditionalInformationCollected) then begin
                Response.Add('requiresAdditionalInformationCollection', RequiresAdditionalInformationCollection);
                Response.Add('requiresUnitPriceInputPrompt', RequiresUnitPriceInputPrompt);
                Response.Add('requiresSerialNoInputPrompt', RequiresSerialNoInputPrompt);
                exit;
            end;

            if RequiresSerialNoInputPrompt then
#pragma warning disable AA0139
                if not Context.GetString('serialNoInput', InputSerial) then;
#pragma warning disable AA0139

            if RequiresUnitPriceInputPrompt then
                if not Context.GetDecimal('unitPriceInput', UnitPrice) then;
        end;

        if RequiresSerialNoInput then begin
            Setup.GetPOSStore(NPRPOSStore);
            NPRPOSTrackingUtils.ValidateSerialNo(ItemReference."Item No.", ItemReference."Variant Code", InputSerial, SerialSelectionFromList, NPRPOSStore);
        end;

        EditDesc := Context.GetBooleanParameter('EditDescription');
        EditDesc2 := Context.GetBooleanParameter('EditDescription2');
        ItemQuantity := Context.GetDecimalParameter('itemQuantity');
        PresetUnitPrice := Context.GetDecimalParameter('preSetUnitPrice');
        SkipItemAvailabilityCheck := Context.GetBooleanParameter('SkipItemAvailabilityCheck');

        if EditDesc then
            CustomDescription := Context.GetString('desc1');

        if EditDesc2 then
            CustomDescription2 := Context.GetString('desc2');

        if UsePresetUnitPrice then
            UnitPrice := PresetUnitPrice;

        Clear(PosItemCheckAvail);
        if not SkipItemAvailabilityCheck then begin
            PosItemCheckAvail.GetPosInvtProfile(POSSession, PosInventoryProfile);

            if PosInventoryProfile."Stockout Warning" then
                PosItemCheckAvail.SetxDataset(POSSession);

            POSSession.SetAvailabilityCheckState(PosItemCheckAvail);
        end;

        POSActionInsertItemB.AddItemLine(Item, ItemReference, ItemIdentifierType, ItemQuantity, CopyStr(UnitOfMeasure, 1, 10), UnitPrice, CustomDescription, CustomDescription2, InputSerial, POSSession, FrontEnd);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        if Item."Assembly BOM" then begin
            BOMComponentLinesWithoutSerialNoJsonArray := CreateBOMComponentLinesSerialNoAssignmentResponse(SaleLinePOS);
            Response.Add('bomComponentLinesWithoutSerialNo', BOMComponentLinesWithoutSerialNoJsonArray);
        end;

        if IfAddItemAddOns(Item) then begin
            Response.Add('addItemAddOn', true);
            BaseLineNo := POSActionInsertItemB.GetLineNo();
            Response.Add('baseLineNo', BaseLineNo);
        end else
            if not SkipItemAvailabilityCheck then
                CheckAvailability(PosInventoryProfile, PosItemCheckAvail);

        Response.Add('postAddWorkflows', AddPostWorkflowsToRun(Context, SaleLinePOS));

        LogFinishTelem();
    end;

    local procedure LogStartTelem()
    begin
        StartTime := CurrentDateTime();
    end;

    local procedure LogFinishTelem()
    var
        ActiveSession: Record "Active Session";
        LogDict: Dictionary of [Text, Text];
        ItemAddedDur: Duration;
        DurationMs: Integer;
        FinishEventIdTok: Label 'NPR_POSActAddItem', Locked = true;
        MsgTok: Label 'Company:%1, Tenant: %2, Instance: %3, Server: %4, Duration: %5';
        Msg: Text;
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
        PosItemCheckAvail: Codeunit "NPR POS Item-Check Avail.";
        POSSession: Codeunit "NPR POS Session";
        SkipItemAvailabilityCheck: Boolean;
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

    local procedure CreateBOMComponentLinesSerialNoAssignmentResponse(SaleLinePOS: Record "NPR POS Sale Line") ResponseJsonArray: JsonArray;
    var
        ParentItem: Record Item;
        BOMComponentLines: Record "NPR POS Sale Line";
        POSActionInsertItemB: Codeunit "NPR POS Action: Insert Item B";
        POSTrackingUtils: Codeunit "NPR POS Tracking Utils";
        RequiresSerialNoInput: Boolean;
        RequiresSpecificlSerialNo: Boolean;
        CurrJsonObject: JsonObject;
    begin
        POSActionInsertItemB.GetBOMComponentLines(SaleLinePOS, BOMComponentLines);

        BOMComponentLines.SetLoadFields("No.", "Variant Code", "Parent BOM Item No.", Description, "Parent BOM Line No.");

        if not BOMComponentLines.FindSet(false) then
            exit;

        repeat
            POSTrackingUtils.ItemRequiresSerialNumber(BOMComponentLines."No.", RequiresSerialNoInput, RequiresSpecificlSerialNo);

            if RequiresSerialNoInput then begin
                ParentItem.SetLoadFields(Description);
                ParentItem.Get(BOMComponentLines."Parent BOM Item No.");

                Clear(CurrJsonObject);
                CurrJsonObject.Add('registerNo', BOMComponentLines."Register No.");
                CurrJsonObject.Add('salesTicketNo', BOMComponentLines."Sales Ticket No.");
                CurrJsonObject.Add('lineNo', BOMComponentLines."Line No.");
                CurrJsonObject.Add('no', BOMComponentLines."No.");
                CurrJsonObject.Add('description', BOMComponentLines.Description);
                CurrJsonObject.Add('variantCode', BOMComponentLines."Variant Code");
                CurrJsonObject.Add('parentBOMItemNo', BOMComponentLines."Parent BOM Item No.");
                CurrJsonObject.Add('parentBOMLineNo', BOMComponentLines."Parent BOM Line No.");
                CurrJsonObject.Add('parentBOMDescription', ParentItem.Description);
                CurrJsonObject.Add('useSpecTracking', RequiresSpecificlSerialNo);
                CurrJsonObject.Add('recordID', Format(BOMComponentLines.RecordId));
                CurrJsonObject.Add('systemID', BOMComponentLines.SystemId);
                ResponseJsonArray.Add(CurrJsonObject);
            end;
        until BOMComponentLines.Next() = 0;
    end;

    local procedure AssignSerialNo(Context: Codeunit "NPR POS JSON Helper"; Setup: Codeunit "NPR POS Setup") ResponseJsonObject: JsonObject
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSStore: Record "NPR POS Store";
        POSActionItemInsertTry: Codeunit "NPR POS Action Item Insert Try";
        AssignSerialNoSuccess: Boolean;
        SerialSelectionFromList: Boolean;
        BOMComponentLineJsonObject: JsonObject;
        ResultToken: JsonToken;
        AssignSerialNoSuccessErrorText: Text;
        BomComponentSystemID: Text;
        InputSerial: Text[50];
        WrongSerial_InstrLbl: Label ' Press Yes to re-enter serial number now. Press No to enter serial number later.';
    begin
#pragma warning disable AA0139
        InputSerial := Context.GetString('serialNoInput');
#pragma warning restore AA0139
        if not Context.GetBooleanParameter('SelectSerialNo', SerialSelectionFromList) then;

        Clear(BOMComponentLineJsonObject);
        BOMComponentLineJsonObject := Context.GetJsonObject('bomComponentLineWithoutSerialNo');

        Clear(ResultToken);
        BOMComponentLineJsonObject.Get('systemID', ResultToken);
        BomComponentSystemID := ResultToken.AsValue().AsText();

        SaleLinePOS.GetBySystemId(BomComponentSystemID);

        Setup.GetPOSStore(POSStore);

        ClearLastError();
        Clear(POSActionItemInsertTry);
        POSActionItemInsertTry.SetSaleLine(SaleLinePOS);
        POSActionItemInsertTry.SetSerialNoInput(InputSerial);
        POSActionItemInsertTry.SetSerialSelectionFromList(SerialSelectionFromList);
        POSActionItemInsertTry.SetPOSStore(POSStore);
        POSActionItemInsertTry.SetFunctionToExecute('AssignSerialNo');

        AssignSerialNoSuccess := POSActionItemInsertTry.Run();

        AssignSerialNoSuccessErrorText := '';
        if not AssignSerialNoSuccess then begin
            AssignSerialNoSuccessErrorText := GetLastErrorText();
            if AssignSerialNoSuccessErrorText <> '' then
                AssignSerialNoSuccessErrorText += WrongSerial_InstrLbl;
        end;

        ResponseJsonObject.Add('assignSerialNoSuccess', AssignSerialNoSuccess);
        ResponseJsonObject.Add('assignSerialNoSuccessErrorText', AssignSerialNoSuccessErrorText);
    end;

    internal procedure SimpleItemInsert(Context: Codeunit "NPR POS JSON Helper"; ItemIdentifier: Text; ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference,ItemGtin; ItemQuantity: Decimal; UnitOfMeasureCode: Code[10]; UnitPrice: Decimal; SkipItemAvailabilityCheck: Boolean; SerialSelectionFromList: Boolean; UsePresetUnitPrice: Boolean; Setup: Codeunit "NPR POS Setup"; FrontEnd: Codeunit "NPR POS Front End Management"; var Response: JsonObject) Success: Boolean
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        POSStore: Record "NPR POS Store";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSActionInsertItemB: Codeunit "NPR POS Action: Insert Item B";
        POSActionInsertItem: Codeunit "NPR POS Action: Insert Item";
        PosItemCheckAvail: Codeunit "NPR POS Item-Check Avail.";
        POSSession: Codeunit "NPR POS Session";
        POSTrackingUtils: Codeunit "NPR POS Tracking Utils";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        ItemProcessingEvents: Codeunit "NPR POS Act. Insert Item Event";
        PosInventoryProfile: Record "NPR POS Inventory Profile";
        RequiresSerialNoInput: Boolean;
        RequiresUnitPriceInput: Boolean;
        RequiresSpecificSerialNo: Boolean;
        RequiresUnitPriceInputPrompt: Boolean;
        RequiresSerialNoInputPrompt: Boolean;
        RequiresAdditionalInformationCollection: Boolean;
        SimpleInsertCanBeExecuted: Boolean;
        AdditionalWorkflowsFound: Boolean;
        BOMComponentsNeedSerialNoInput: Boolean;
        InputSerial: Text[50];
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        AdditionalWorkflowsFound := POSActionInsertItem.AddPostWorkflowsToRun(Context, SaleLinePOS).Keys.Count <> 0;

        Item.SetLoadFields("NPR Explode BOM auto", "Assembly BOM", "NPR Group sale", "Item Category Code", "Price Includes VAT", "VAT Bus. Posting Gr. (Price)", "VAT Prod. Posting Group", "NPR Item Addon No.");
        Item.SetAutoCalcFields("Assembly BOM");

        POSActionInsertItemB.GetItem(Item, ItemReference, ItemIdentifier, ItemIdentifierType);
        POSActionInsertItemB.GetItemAdditionalInformationRequirements(Item, RequiresSerialNoInput, RequiresSpecificSerialNo, RequiresUnitPriceInput);
        POSActionInsertItemB.CheckItemRequiresAdditionalInformationInput(RequiresSerialNoInput, RequiresUnitPriceInput, SerialSelectionFromList, UsePresetUnitPrice, RequiresSpecificSerialNo, RequiresUnitPriceInputPrompt, RequiresSerialNoInputPrompt, RequiresAdditionalInformationCollection);

        if Item."Assembly BOM" and Item."NPR Explode BOM auto" then
            BOMComponentsNeedSerialNoInput := POSActionInsertItemB.CheckBOMComponentsNeedSerialNoInput(Item);

        SimpleInsertCanBeExecuted := (not AdditionalWorkflowsFound) and (not RequiresAdditionalInformationCollection) and (not ifAddItemAddOns(Item)) and (not BOMComponentsNeedSerialNoInput);
        ItemProcessingEvents.OnBeforeSimpleInsert(Context, ItemIdentifier, ItemIdentifierType, ItemQuantity, UnitPrice, SkipItemAvailabilityCheck, SerialSelectionFromList, UsePresetUnitPrice, Setup, FrontEnd, Response, Success, SimpleInsertCanBeExecuted);
        if not SimpleInsertCanBeExecuted then
            exit;

        Clear(PosItemCheckAvail);
        if not SkipItemAvailabilityCheck then begin
            PosItemCheckAvail.GetPosInvtProfile(POSSession, PosInventoryProfile);

            if PosInventoryProfile."Stockout Warning" then
                PosItemCheckAvail.SetxDataset(POSSession);

            POSSession.SetAvailabilityCheckState(PosItemCheckAvail);
        end;

        if RequiresSerialNoInput and not RequiresUnitPriceInputPrompt then begin
            Setup.GetPOSStore(POSStore);
            POSTrackingUtils.ValidateSerialNo(ItemReference."Item No.", ItemReference."Variant Code", InputSerial, SerialSelectionFromList, POSStore);
        end;

        POSActionInsertItemB.AddItemLine(Item, ItemReference, ItemIdentifierType, ItemQuantity, UnitOfMeasureCode, UnitPrice, '', '', InputSerial, POSSession, FrontEnd);

        if not SkipItemAvailabilityCheck then
            CheckAvailability(PosInventoryProfile, PosItemCheckAvail);

        Success := true;
    end;

    internal procedure AddPostWorkflowsToRun(Context: Codeunit "NPR POS JSON Helper"; SaleLinePOS: Record "NPR POS Sale Line") PostWorkflows: JsonObject
    var
        ItemProcessingEvents: Codeunit "NPR POS Act. Insert Item Event";
    begin
        ItemProcessingEvents.OnAddPostWorkflowsToRun(Context, SaleLinePOS, PostWorkflows);
    end;

    local procedure GetValueFromPOSParameters(var POSParameterValue: Record "NPR POS Parameter Value"; ValueName: Text) POSParameterValueTExt: Text
    var
        TempPOSParameterValue: Record "NPR POS Parameter Value" temporary;
    begin
        TempPOSParameterValue := POSParameterValue;
        TempPOSParameterValue.CopyFilters(POSParameterValue);

        POSParameterValue.SetRange(Name, ValueName);
        if POSParameterValue.FindFirst() then
            POSParameterValueTExt := POSParameterValue.Value;

        POSParameterValue := TempPOSParameterValue;
        POSParameterValue.CopyFilters(TempPOSParameterValue);
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

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', true, true)]
    local procedure OnLookupUnitOfMeasureCode(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        ItemNo: Text;
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;
        if POSParameterValue.Name <> 'unitOfMeasure' then
            exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
            exit;

        Handled := true;

        ItemNo := GetValueFromPOSParameters(POSParameterValue, 'itemNo');
        if ItemNo = '' then
            exit;

        ItemUnitOfMeasure.Reset();
        ItemUnitOfMeasure.SetRange("Item No.", ItemNo);

        if ItemUnitOfMeasure.IsEmpty() then
            exit;

        if Page.RunModal(0, ItemUnitOfMeasure) = Action::LookupOK then
            POSParameterValue.Value := ItemUnitOfMeasure.Code;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', true, false)]
    local procedure OnValidateUnitOfMeasureCode(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        UOMErr: Label 'Inserted Unit of Measure does not exist for Item No. parameter field';
        ItemNo: Text;
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;
        if POSParameterValue.Name <> 'unitOfMeasure' then
            exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
            exit;
        if POSParameterValue.Value = '' then
            exit;

        ItemNo := GetValueFromPOSParameters(POSParameterValue, 'itemNo');

        if not ItemUnitOfMeasure.Get(ItemNo, POSParameterValue.Value) then
            Error(UOMErr);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnAfterValidateEvent', 'Value', true, false)]
    local procedure OnAfterValidateItemNoValue(var Rec: Record "NPR POS Parameter Value")
    var
        TempPOSParameterValue: Record "NPR POS Parameter Value" temporary;
    begin
        if Rec."Action Code" <> ActionCode() then
            exit;
        if Rec.Name <> 'itemNo' then
            exit;
        if Rec."Data Type" <> Rec."Data Type"::Text then
            exit;

        TempPOSParameterValue := Rec;
        TempPOSParameterValue.CopyFilters(Rec);

        Rec.SetRange(Name, 'unitOfMeasure');
        if Rec.FindFirst() then begin
            Rec.Value := '';
            Rec.Modify(true);
        end;

        Rec := TempPOSParameterValue;
        Rec.CopyFilters(TempPOSParameterValue);
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
'let main=async({workflow:t,context:i,popup:r,parameters:n,captions:e})=>{debugger;if(i.additionalInformationCollected=!1,n.EditDescription&&(i.desc1=await r.input({title:e.editDesc_title,caption:e.editDesc_lead,value:i.defaultDescription}),i.desc1===null)||n.EditDescription2&&(i.desc2=await r.input({title:e.editDesc2_title,caption:e.editDesc2_lead,value:i.defaultDescription}),i.desc2===null))return;const{bomComponentLinesWithoutSerialNo:l,requiresUnitPriceInputPrompt:o,requiresSerialNoInputPrompt:s,requiresAdditionalInformationCollection:a,addItemAddOn:c,baseLineNo:f,postAddWorkflows:u}=await t.respond("addSalesLine");if(a){if(o&&(i.unitPriceInput=await r.numpad({title:e.UnitPriceTitle,caption:e.unitPriceCaption}),i.unitPriceInput===null)||s&&(i.serialNoInput=await r.input({title:e.itemTracking_title,caption:e.itemTracking_lead}),i.serialNoInput===null))return;i.additionalInformationCollected=!0,await t.respond("addSalesLine")}if(await processBomComponentLinesWithoutSerialNo(l,t,i,n,r,e),c&&(await t.run("RUN_ITEM_ADDONS",{context:{baseLineNo:f},parameters:{SkipItemAvailabilityCheck:!0}}),await t.respond("checkAvailability")),u)for(const m of Object.entries(u)){let[d,N]=m;d&&await t.run(d,{parameters:N})}};async function processBomComponentLinesWithoutSerialNo(t,i,r,n,e,l){if(!!t)for(var o=0;o<t.length;o++){let s=!0,a;for(;s;)s=!1,r.serialNoInput="",r.bomComponentLineWithoutSerialNo=t[o],n.SelectSerialNo&&r.bomComponentLineWithoutSerialNo.requiresSpecificSerialNo?(a=await i.respond("assignSerialNo"),!a.assignSerialNoSuccess&&a.assignSerialNoSuccessErrorText&&await e.confirm({title:l.serialNoError_title,caption:a.assignSerialNoSuccessErrorText})&&(s=!0)):(r.serialNoInput=await e.input({title:l.itemTracking_title,caption:format(l.bomItemTracking_Lead,r.bomComponentLineWithoutSerialNo.description,r.bomComponentLineWithoutSerialNo.parentBOMDescription)}),r.serialNoInput&&(a=await i.respond("assignSerialNo"),!a.assignSerialNoSuccess&&a.assignSerialNoSuccessErrorText&&await e.confirm({title:l.serialNoError_title,caption:a.assignSerialNoSuccessErrorText})&&(s=!0)))}}function format(t,...i){if(!t.match(/^(?:(?:(?:[^{}]|(?:\{\{)|(?:\}\}))+)|(?:\{[0-9]+\}))+$/))throw new Error("invalid format string.");return t.replace(/((?:[^{}]|(?:\{\{)|(?:\}\}))+)|(?:\{([0-9]+)\})/g,(r,n,e)=>{if(n)return n.replace(/(?:{{)|(?:}})/g,l=>l[0]);if(e>=i.length)throw new Error("argument index is out of range in format");return i[e]})}'
        );
    end;

}
