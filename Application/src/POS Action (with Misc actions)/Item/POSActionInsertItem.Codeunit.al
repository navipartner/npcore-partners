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
        BOMItemTracking_LotNoLeadLbl: Label 'BOM component item {0} of BOM item {1} requires Lot No. Please enter Lot No.';
        SerialNoError_titleLbl: Label 'Serial No. error';
        LotNoError_titleLbl: Label 'Lot No. error';
        EditDesc2_titleLbl: Label 'Add or change description 2.';
        EditDesc_titleLbl: Label 'Add or change description.';
        ItemTracking_InstrLbl: Label 'Enter serial number now and press OK. Press Cancel to enter serial number later.';
        ItemTracking_LeadLbl: Label 'This item requires serial number, enter serial number.';
        ItemTracking_TitleLbl: Label 'Enter Serial Number';
        ParamEditDescription2_CaptionLbl: Label 'Edit Description 2';
        ParamEditDescription2_DescLbl: Label 'Enable/Disable Edit Description 2';
        ParamEditDescription_CaptionLbl: Label 'Edit Description';
        ParamEditDescription_DescLbl: Label 'Enable/Disable Edit Description';
        ParamItemIdentifierOptions_CaptionLbl: Label 'ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference,ItemGtin';
        ParamItemIdentifierOptionsLbl: Label 'ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference,ItemGtin', Locked = true;
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
        ParamSelectLotNo_CaptionLbl: Label 'Select Lot No.';
        ParamSelectLotNo_DescLbl: Label 'Choose option for selecting Lot No. from the list';
        ParamSelectLotNoOptionsLbl: Label 'NoSelection,SelectLotNoFromList,SelectLotNoFromListAfterInput', Locked = true;
        ParamSelectLotNoOptionsLbl_CaptionLbl: Label 'NoSelection,SelectLotNoFromList,SelectLotNoFromListAfterInput';
        ParamSelectSerialNoListEmptyInput_CaptionLbl: Label 'Select Serial No. List/Input';
        ParamSelectSerialNoListEmptyInput_DescLbl: Label 'Enable/Disable select Serial No. from the list after empty input.';
        ParamSkipItemAvailabilityCheck_CaptionLbl: Label 'Skip Item Availability Check';
        ParamSkipItemAvailabilityCheck_DescLbl: Label 'Enable/Disable skip Item Availability Check';
        ParamUsePreSetUnitPrice_CaptionLbl: Label 'usePreSetUnitPrice';
        ParamUsePreSetUnitPrice_DescLbl: Label 'Enable/Disable preset of Unit Price';
        ParamUnitOfMeasure_CaptionLbl: Label 'Unit of Measure';
        ParamUnitOfMeasure_DescLbl: Label 'Specifies Unit of Measure for Item';
        ItemTrackingLot_TitleLbl: Label 'Enter Lot No.';
        ItemTrackingLot_LeadLbl: Label 'This item requires Lot No., enter Lot No.';
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
        WorkflowConfig.AddLabel('itemTrackingLotNo_title', ItemTrackingLot_TitleLbl);
        WorkflowConfig.AddLabel('itemTrackingLot_lead', ItemTrackingLot_LeadLbl);
        WorkflowConfig.AddLabel('bomItemTrackingLot_Lead', BOMItemTracking_LotNoLeadLbl);
        WorkflowConfig.AddLabel('lotNoError_title', LotNoError_titleLbl);

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
        WorkflowConfig.AddOptionParameter('SelectLotNo',
                                        ParamSelectLotNoOptionsLbl,
#pragma warning disable AA0139
                                        SelectStr(1, ParamSelectLotNoOptionsLbl),
#pragma warning restore AA0139
                                        ParamSelectLotNo_CaptionLbl,
                                        ParamSelectLotNo_DescLbl,
                                        ParamSelectLotNoOptionsLbl_CaptionLbl);
        WorkflowConfig.AddBooleanParameter('SelectSerialNoListEmptyInput', false, ParamSelectSerialNoListEmptyInput_CaptionLbl, ParamSelectSerialNoListEmptyInput_DescLbl);
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
            'assignLotNo':
                FrontEnd.WorkflowResponse(AssignLotNo(Context, Setup));
            'cancelTicketItemLine':
                CancelTicketItemLine(Context);
            'getCurrentItemPriceCaption':
                FrontEnd.WorkflowResponse(GetCurrentItemPriceCaption(Context, Sale));
        end;
    end;


    local procedure CancelTicketItemLine(Context: Codeunit "NPR POS JSON Helper")
    var
        POSSession: Codeunit "NPR POS Session";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        DeletePOSLineB: Codeunit "NPR POSAct:Delete POS Line-B";
        POSActionDeleteLine: Codeunit "NPR POSAction: Delete POS Line";
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSActionDeleteLine.SetPositionForPOSSaleLine(Context, POSSaleLine);
        POSActionDeleteLine.OnBeforeDeleteSaleLinePOS(POSSaleLine);
        DeletePOSLineB.DeleteSaleLine(POSSaleLine);
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
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketRetailManager: Codeunit "NPR TM Ticket Retail Mgt.";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
        EditDesc: Boolean;
        EditDesc2: Boolean;
        SerialSelectionFromList: Boolean;
        SelectSerialNoListEmptyInput: Boolean;
        ValidateSerialSelectionFromList: Boolean;
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
        BOMComponentLinesWithoutSerialNoLotNoJsonArray: JsonArray;
        CustomDescription: Text;
        CustomDescription2: Text;
        UnitOfMeasure: Text;
        ItemNoId: Text;
        ItemReferenceId: Text;
        RequiresLotNoInput: Boolean;
        RequiresSpecificLotNo: Boolean;
        RequiresLotNoInputPrompt: Boolean;
        ExecuteGetItem: Boolean;
        LotSelectionFromList: Boolean;
        LotSelectionFromListOption: Option NoSelection,SelectLotNoFromList,SelectLotNoFromListAfterInput;
        InputLotNo: Text;
        TicketToken: Text;
    begin
        ItemIdentifier := Context.GetStringParameter('itemNo');
        UnitOfMeasure := Context.GetStringParameter('unitOfMeasure');
        ItemIdentifierType := Context.GetIntegerParameter('itemIdentifierType');
        if not Context.GetBoolean('additionalInformationCollected', AdditionalInformationCollected) then;

        if ItemIdentifierType < 0 then
            ItemIdentifierType := 0;

        Item.SetLoadFields("NPR Explode BOM auto", "Assembly BOM", "NPR Group sale", "Item Category Code", "Price Includes VAT", "VAT Bus. Posting Gr. (Price)", "VAT Prod. Posting Group", "NPR Item Addon No.");
        Item.SetAutoCalcFields("Assembly BOM");

        if FeatureFlagsManagement.IsEnabled('skipDoubleLookUpOnItemInsert') then begin
            ExecuteGetItem := (not AdditionalInformationCollected) or (not Context.GetString('itemNoId', itemNoId)) or (itemNoId = '');
            if not ExecuteGetItem then
                ExecuteGetItem := (not Item.GetBySystemId(itemNoId));

            if ExecuteGetItem then
                POSActionInsertItemB.GetItem(Item, ItemReference, ItemIdentifier, ItemIdentifierType)
            else begin
                ItemReference."Item No." := Item."No.";
                if Context.GetString('itemReferenceId', itemReferenceId) then
                    if not ItemReference.GetBySystemId(itemReferenceId) then
                        ItemReference."Item No." := Item."No."
            end;
        end else
            POSActionInsertItemB.GetItem(Item, ItemReference, ItemIdentifier, ItemIdentifierType);

        LogStartTelem();

        POSActionInsertItemB.GetItemAdditionalInformationRequirements(Item, RequiresSerialNoInput, RequiresSpecificSerialNo, RequiresUnitPriceInput, RequiresLotNoInput, RequiresSpecificLotNo);

        if RequiresSerialNoInput then begin
            if not Context.GetBooleanParameter('SelectSerialNo', SerialSelectionFromList) then;
            if not Context.GetBooleanParameter('SelectSerialNoListEmptyInput', SelectSerialNoListEmptyInput) then;
#pragma warning disable AA0139
            if not Context.GetString('serialNoInput', InputSerial) then;
#pragma warning disable AA0139
        end;

        if RequiresLotNoInput then begin
            if not Context.GetString('lotNoInput', InputLotNo) then;
            LotSelectionFromListOption := Context.GetIntegerParameter('SelectLotNo');
        end;

        if not Context.GetBooleanParameter('usePreSetUnitPrice', UsePresetUnitPrice) then;

        POSActionInsertItemB.CheckItemRequiresAdditionalInformationInput(RequiresSerialNoInput, RequiresUnitPriceInput, SerialSelectionFromList, UsePresetUnitPrice, RequiresSpecificSerialNo, RequiresUnitPriceInputPrompt, RequiresSerialNoInputPrompt, RequiresAdditionalInformationCollection, RequiresLotNoInputPrompt, RequiresLotNoInput, RequiresSpecificLotNo, SelectSerialNoListEmptyInput, InputSerial, LotSelectionFromListOption, InputLotNo);
        If RequiresAdditionalInformationCollection then begin

            if (not AdditionalInformationCollected) then begin
                Response.Add('requiresAdditionalInformationCollection', RequiresAdditionalInformationCollection);
                Response.Add('requiresUnitPriceInputPrompt', RequiresUnitPriceInputPrompt);
                Response.Add('requiresSerialNoInputPrompt', RequiresSerialNoInputPrompt);
                Response.Add('requiresLotNoInputPrompt', RequiresLotNoInputPrompt);
                Response.Add('itemNoId', Item.SystemId);
                Response.Add('itemReferenceId', ItemReference.SystemId);
                exit;
            end;

            if RequiresUnitPriceInputPrompt then
                if not Context.GetDecimal('unitPriceInput', UnitPrice) then;
        end;

        ValidateSerialSelectionFromList := (SelectSerialNoListEmptyInput and SerialSelectionFromList and (InputSerial = '')) or (SerialSelectionFromList and not SelectSerialNoListEmptyInput);
        if RequiresSerialNoInput then begin
            Setup.GetPOSStore(NPRPOSStore);
            NPRPOSTrackingUtils.ValidateSerialNo(ItemReference."Item No.", ItemReference."Variant Code", InputSerial, ValidateSerialSelectionFromList, NPRPOSStore);
        end;

        LotSelectionFromList := (LotSelectionFromListOption = 1) or ((LotSelectionFromListOption = 2) and (InputLotNo = ''));
        if RequiresLotNoInput then begin
            Setup.GetPOSStore(NPRPOSStore);
            NPRPOSTrackingUtils.ValidateLotNo(ItemReference."Item No.", ItemReference."Variant Code", InputLotNo, NPRPOSStore, LotSelectionFromList);
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

        POSActionInsertItemB.AddItemLine(Item, ItemReference, ItemIdentifierType, ItemQuantity, CopyStr(UnitOfMeasure, 1, 10), UnitPrice, CustomDescription, CustomDescription2, InputSerial, POSSession, FrontEnd, InputLotNo);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        if Item."Assembly BOM" then begin
            BOMComponentLinesWithoutSerialNoLotNoJsonArray := CreateBOMComponentLinesSerialNoLotNoAssignmentResponse(SaleLinePOS);
            Response.Add('bomComponentLinesWithoutSerialLotNo', BOMComponentLinesWithoutSerialNoLotNoJsonArray);
        end;

        if IfAddItemAddOns(Item) then begin
            Response.Add('addItemAddOn', true);
            BaseLineNo := POSActionInsertItemB.GetLineNo();
            Response.Add('baseLineNo', BaseLineNo);
        end else
            if not SkipItemAvailabilityCheck then
                CheckAvailability(PosInventoryProfile, PosItemCheckAvail);

        Response.Add('postAddWorkflows', AddPostWorkflowsToRun(Context, SaleLinePOS));

        if (TicketRetailManager.UseFrontEndScheduleUX()) then
            if (TicketRequestManager.GetTokenFromReceipt(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", TicketToken)) then begin
                if (TicketRequestManager.RequestRequiresAttention(TicketToken)) then
                    Response.Add('ticketToken', TicketToken);
            end;

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

    local procedure CreateBOMComponentLinesSerialNoLotNoAssignmentResponse(SaleLinePOS: Record "NPR POS Sale Line") ResponseJsonArray: JsonArray;
    var
        ParentItem: Record Item;
        BOMComponentLines: Record "NPR POS Sale Line";
        POSActionInsertItemB: Codeunit "NPR POS Action: Insert Item B";
        POSTrackingUtils: Codeunit "NPR POS Tracking Utils";
        RequiresSerialNoInput: Boolean;
        RequiresSpecificSerialNo: Boolean;
        CurrJsonObject: JsonObject;
        RequiresLotNoInput: Boolean;
        RequiresSpecificLotNo: Boolean;
        Item: Record Item;
    begin
        POSActionInsertItemB.GetBOMComponentLines(SaleLinePOS, BOMComponentLines);

        BOMComponentLines.SetLoadFields("No.", "Variant Code", "Parent BOM Item No.", Description, "Parent BOM Line No.");

        if not BOMComponentLines.FindSet(false) then
            exit;

        repeat
            RequiresLotNoInput := false;
            RequiresSpecificLotNo := false;
            RequiresSerialNoInput := false;
            RequiresLotNoInput := false;

            Item.SetLoadFields("No.", "Item Tracking Code");
            if Item.Get(BOMComponentLines."No.") then
                POSTrackingUtils.ItemRequiresLotNoSerialNo(Item, RequiresSpecificSerialNo, RequiresSpecificLotNo, RequiresSerialNoInput, RequiresLotNoInput);


            if (RequiresSerialNoInput or RequiresLotNoInput) then begin
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
                CurrJsonObject.Add('useSpecTrackingSerialNo', RequiresSpecificSerialNo);
                CurrJsonObject.Add('useSpecTrackingLotNo', RequiresSpecificLotNo);
                CurrJsonObject.Add('requiresSerialNoInput', RequiresSerialNoInput);
                CurrJsonObject.Add('requiresLotNoInput', RequiresLotNoInput);
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
        ValidateSerialSelectionFromList: Boolean;
        SelectSerialNoListEmptyInput: Boolean;
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
        if not Context.GetBooleanParameter('SelectSerialNoListEmptyInput', SelectSerialNoListEmptyInput) then;

        ValidateSerialSelectionFromList := (SelectSerialNoListEmptyInput and SerialSelectionFromList and (InputSerial = '')) or (SerialSelectionFromList and not SelectSerialNoListEmptyInput);

        Clear(BOMComponentLineJsonObject);
        BOMComponentLineJsonObject := Context.GetJsonObject('bomComponentLineWithoutSerialLotNo');

        Clear(ResultToken);
        BOMComponentLineJsonObject.Get('systemID', ResultToken);
        BomComponentSystemID := ResultToken.AsValue().AsText();

        SaleLinePOS.GetBySystemId(BomComponentSystemID);

        Setup.GetPOSStore(POSStore);

        ClearLastError();
        Clear(POSActionItemInsertTry);
        POSActionItemInsertTry.SetSaleLine(SaleLinePOS);
        POSActionItemInsertTry.SetSerialNoInput(InputSerial);
        POSActionItemInsertTry.SetSerialSelectionFromList(ValidateSerialSelectionFromList);
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

    local procedure AssignLotNo(Context: Codeunit "NPR POS JSON Helper"; Setup: Codeunit "NPR POS Setup") ResponseJsonObject: JsonObject
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSStore: Record "NPR POS Store";
        POSActionItemInsertTry: Codeunit "NPR POS Action Item Insert Try";
        AssignLotNoSuccess: Boolean;
        LotSelectionFromList: Boolean;
        LotSelectionFromListOption: Option NoSelection,SelectLotNoFromList,SelectLotNoFromListAfterInput;
        BOMComponentLineJsonObject: JsonObject;
        ResultToken: JsonToken;
        AssignLotNoSuccessErrorText: Text;
        BomComponentSystemID: Text;
        InputLot: Text[50];
        WrongLot_InstrLbl: Label ' Press Yes to re-enter Lot No now. Press No to enter Lot No. later.';
    begin
#pragma warning disable AA0139
        InputLot := Context.GetString('lotNoInput');
#pragma warning restore AA0139
        LotSelectionFromListOption := Context.GetIntegerParameter('SelectLotNo');

        Clear(BOMComponentLineJsonObject);
        BOMComponentLineJsonObject := Context.GetJsonObject('bomComponentLineWithoutSerialLotNo');

        Clear(ResultToken);
        BOMComponentLineJsonObject.Get('systemID', ResultToken);
        BomComponentSystemID := ResultToken.AsValue().AsText();

        SaleLinePOS.GetBySystemId(BomComponentSystemID);

        Setup.GetPOSStore(POSStore);

        LotSelectionFromList := (LotSelectionFromListOption in [LotSelectionFromListOption::SelectLotNoFromList]) or ((LotSelectionFromListOption in [LotSelectionFromListOption::SelectLotNoFromListAfterInput]) and (InputLot = ''));

        ClearLastError();
        Clear(POSActionItemInsertTry);
        POSActionItemInsertTry.SetSaleLine(SaleLinePOS);
        POSActionItemInsertTry.SetLotNoInput(InputLot);
        POSActionItemInsertTry.SetLotSelectionFromList(LotSelectionFromList);
        POSActionItemInsertTry.SetPOSStore(POSStore);
        POSActionItemInsertTry.SetFunctionToExecute('AssignLotNo');

        AssignLotNoSuccess := POSActionItemInsertTry.Run();

        AssignLotNoSuccessErrorText := '';
        if not AssignLotNoSuccess then begin
            AssignLotNoSuccessErrorText := GetLastErrorText();
            if AssignLotNoSuccessErrorText <> '' then
                AssignLotNoSuccessErrorText += WrongLot_InstrLbl;
        end;

        ResponseJsonObject.Add('assignLotNoSuccess', AssignLotNoSuccess);
        ResponseJsonObject.Add('assignLotNoSuccessErrorText', AssignLotNoSuccessErrorText);
    end;

    internal procedure SimpleItemInsert(Context: Codeunit "NPR POS JSON Helper"; ItemIdentifier: Text; ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference,ItemGtin; ItemQuantity: Decimal; UnitOfMeasureCode: Code[10]; UnitPrice: Decimal; SkipItemAvailabilityCheck: Boolean; SerialSelectionFromList: Boolean; LotSelectionFromList: Integer; UsePresetUnitPrice: Boolean; SelectSerialNoListEmptyInput: Boolean; Setup: Codeunit "NPR POS Setup"; FrontEnd: Codeunit "NPR POS Front End Management"; var Response: JsonObject) Success: Boolean
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        POSStore: Record "NPR POS Store";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSActionInsertItemB: Codeunit "NPR POS Action: Insert Item B";
        PosItemCheckAvail: Codeunit "NPR POS Item-Check Avail.";
        POSSession: Codeunit "NPR POS Session";
        POSTrackingUtils: Codeunit "NPR POS Tracking Utils";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        ItemProcessingEvents: Codeunit "NPR POS Act. Insert Item Event";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
        PosInventoryProfile: Record "NPR POS Inventory Profile";
        RequiresSerialNoInput: Boolean;
        RequiresUnitPriceInput: Boolean;
        RequiresSpecificSerialNo: Boolean;
        RequiresUnitPriceInputPrompt: Boolean;
        RequiresSerialNoInputPrompt: Boolean;
        RequiresAdditionalInformationCollection: Boolean;
        SimpleInsertCanBeExecuted: Boolean;
        PostworkflowSubscriptionExists: Boolean;
        BOMComponentsNeedSerialNoInput: Boolean;
        BOMComponentsNeedLotNoInput: Boolean;
        InputSerial: Text[50];
        RequiresLotNoInput: Boolean;
        RequiresSpecificLotNo: Boolean;
        RequiresLotNoInputPrompt: Boolean;
        ValidateLotSelectionFromList: Boolean;
        InputLot: Text[50];
        TicketPosAction: codeunit "NPR POSAction: Ticket Mgt.";
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        Item.SetAutoCalcFields("Assembly BOM");
        if FeatureFlagsManagement.IsEnabled('skipDoubleLookUpOnItemInsert') then begin
            if not POSActionInsertItemB.GetItem(Item, ItemReference, ItemIdentifier, ItemIdentifierType, true) then
                exit;
        end else
            POSActionInsertItemB.GetItem(Item, ItemReference, ItemIdentifier, ItemIdentifierType);

        PostworkflowSubscriptionExists := CheckPostworkflowSubscriptionExists();
        ItemProcessingEvents.OnAfterCheckPostworkflowSubscriptionExists(Item, PostworkflowSubscriptionExists);

        if (Item."NPR Ticket Type" <> '') then
            if (TicketPosAction.UseFrontEndUxForScheduleSelection()) then
                exit(false);

        POSActionInsertItemB.GetItemAdditionalInformationRequirements(Item, RequiresSerialNoInput, RequiresSpecificSerialNo, RequiresUnitPriceInput, RequiresLotNoInput, RequiresSpecificLotNo);
        POSActionInsertItemB.CheckItemRequiresAdditionalInformationInput(RequiresSerialNoInput, RequiresUnitPriceInput, SerialSelectionFromList, UsePresetUnitPrice, RequiresSpecificSerialNo, RequiresUnitPriceInputPrompt, RequiresSerialNoInputPrompt, RequiresAdditionalInformationCollection, RequiresLotNoInputPrompt, RequiresLotNoInput, RequiresSpecificLotNo, SelectSerialNoListEmptyInput, '', LotSelectionFromList, '');

        if Item."Assembly BOM" and Item."NPR Explode BOM auto" then
            POSActionInsertItemB.CheckBOMComponentsNeedLotNoSerialInput(Item, BOMComponentsNeedLotNoInput, BOMComponentsNeedSerialNoInput);

        SimpleInsertCanBeExecuted := (not PostworkflowSubscriptionExists) and (not RequiresAdditionalInformationCollection) and (not ifAddItemAddOns(Item)) and (not BOMComponentsNeedSerialNoInput) and (not BOMComponentsNeedLotNoInput);

        ItemProcessingEvents.OnBeforeSimpleInsert(Context, ItemIdentifier, ItemIdentifierType, ItemQuantity, UnitPrice, SkipItemAvailabilityCheck, SerialSelectionFromList, UsePresetUnitPrice, Setup, FrontEnd, Response, Success, SimpleInsertCanBeExecuted, Item);
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

        if RequiresLotNoInput and not RequiresUnitPriceInputPrompt then begin
            if LotSelectionFromList in [1, 2] then
                ValidateLotSelectionFromList := true;
            Setup.GetPOSStore(POSStore);
            POSTrackingUtils.ValidateLotNo(ItemReference."Item No.", ItemReference."Variant Code", InputLot, POSStore, ValidateLotSelectionFromList);
        end;

        POSActionInsertItemB.AddItemLine(Item, ItemReference, ItemIdentifierType, ItemQuantity, UnitOfMeasureCode, UnitPrice, '', '', InputSerial, POSSession, FrontEnd, InputLot);

        if not SkipItemAvailabilityCheck then
            CheckAvailability(PosInventoryProfile, PosItemCheckAvail);

        Success := true;
    end;

    internal procedure CheckPostworkflowSubscriptionExists() PostworkflowSubscriptionExists: Boolean;
    var
        EventSubscription: Record "Event Subscription";
    begin
        EventSubscription.Reset();
        EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
        EventSubscription.SetRange("Publisher Object ID", Codeunit::"NPR POS Act. Insert Item Event");
        EventSubscription.SetRange("Published Function", 'OnAddPostWorkflowsToRun');
        EventSubscription.SetRange(Active, true);
        PostworkflowSubscriptionExists := not EventSubscription.IsEmpty();
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

    local procedure GetCurrentItemPriceCaption(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"): Text
    var
        ItemIdentifier: Text;
        ItemIdentifierType: Integer;
        POSActionInsertItemB: Codeunit "NPR POS Action: Insert Item B";
        Item: Record Item;
        ItemReference: Record "Item Reference";
        ItemPrice: Decimal;
        Currency: Record Currency;
    begin
        ItemIdentifier := Context.GetStringParameter('itemNo');
        ItemIdentifierType := Context.GetIntegerParameter('itemIdentifierType');

        if (ItemIdentifierType < 0) then
            ItemIdentifierType := 0;

        Item.SetLoadFields("No.", "VAT Bus. Posting Gr. (Price)", "Unit Price", "NPR Ticket Type", "NPR Item AddOn No.");
        if (not POSActionInsertItemB.TryGetItem(Item, ItemReference, ItemIdentifier, ItemIdentifierType)) then
            exit;

        ItemPrice := POSActionInsertItemB.CalculateItemPrice(Item, ItemReference, Sale);

        Currency.InitRoundingPrecision();

        exit(Format(Round(ItemPrice, Currency."Amount Rounding Precision")));
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
'const DYNAMIC_CAPTION_CURR_PRICE="#CURRPRICE#",DYNAMIC_CAPTION_HAS_CURR_PRICE=1;let main=async({workflow:r,context:i,popup:e,parameters:n,captions:t})=>{debugger;if(i.additionalInformationCollected=!1,!(n.EditDescription&&(i.desc1=await e.input({title:t.editDesc_title,caption:t.editDesc_lead,value:i.defaultDescription}),i.desc1===null))&&!(n.EditDescription2&&(i.desc2=await e.input({title:t.editDesc2_title,caption:t.editDesc2_lead,value:i.defaultDescription}),i.desc2===null))){var{bomComponentLinesWithoutSerialLotNo:a,requiresUnitPriceInputPrompt:l,requiresSerialNoInputPrompt:s,requiresLotNoInputPrompt:o,requiresAdditionalInformationCollection:S,addItemAddOn:d,baseLineNo:N,postAddWorkflows:u,ticketToken:m,itemNoId:p,itemReferenceId:I}=await r.respond("addSalesLine");if(m){const c=await r.run("TM_SCHEDULE_SELECT",{context:{TicketToken:m,EditSchedule:!0}});debugger;if(c.cancel){await r.respond("cancelTicketItemLine");return}}if(S){if(l&&(i.unitPriceInput=await e.numpad({title:t.UnitPriceTitle,caption:t.unitPriceCaption}),i.unitPriceInput===null)||s&&(i.serialNoInput=await e.input({title:t.itemTracking_title,caption:t.itemTracking_lead}),i.serialNoInput===null)||o&&(i.lotNoInput=await e.input({title:t.itemTrackingLotNo_title,caption:t.itemTrackingLot_lead}),i.lotNoInput===null))return;i.additionalInformationCollected=!0,i.itemNoId=p,i.itemReferenceId=I;var{bomComponentLinesWithoutSerialLotNo:a,addItemAddOn:d,baseLineNo:N,postAddWorkflows:u}=await r.respond("addSalesLine")}if(await processBomComponentLinesWithoutSerialNoLotNo(a,r,i,n,e,t),d&&(await r.run("RUN_ITEM_ADDONS",{context:{baseLineNo:N},parameters:{SkipItemAvailabilityCheck:!0}}),await r.respond("checkAvailability")),u)for(const c of Object.entries(u)){let[f,L]=c;f&&await r.run(f,{parameters:L})}}};const getButtonCaption=async({workflow:r,context:i})=>{debugger;const e=getDynamicCaptionTypes(i.currentCaptions);if(e.length<=0)return i.currentCaptions;let n={...i.currentCaptions};if(e.includes(1)){const t=await r.respondInNewSession("getCurrentItemPriceCaption");t&&(n.caption=n.caption?.replace(DYNAMIC_CAPTION_CURR_PRICE,t),n.secondCaption=n.secondCaption?.replace(DYNAMIC_CAPTION_CURR_PRICE,t),n.thirdCaption=n.thirdCaption?.replace(DYNAMIC_CAPTION_CURR_PRICE,t))}return n};function getDynamicCaptionTypes(r){const i=[];return(r.caption?.includes(DYNAMIC_CAPTION_CURR_PRICE)||r.secondCaption?.includes(DYNAMIC_CAPTION_CURR_PRICE)||r.thirdCaption?.includes(DYNAMIC_CAPTION_CURR_PRICE))&&i.push(1),i}async function processBomComponentLinesWithoutSerialNoLotNo(r,i,e,n,t,a){if(r){debugger;for(var l=0;l<r.length;l++){let s=!0,o;for(;s;)s=!1,e.serialNoInput="",e.lotNoInput="",e.bomComponentLineWithoutSerialLotNo=r[l],e.bomComponentLineWithoutSerialLotNo.requiresSerialNoInput&&(n.SelectSerialNo&&!n.SelectSerialNoListEmptyInput&&e.bomComponentLineWithoutSerialLotNo.useSpecTrackingSerialNo?(o=await i.respond("assignSerialNo"),!o.assignSerialNoSuccess&&o.assignSerialNoSuccessErrorText&&await t.confirm({title:a.serialNoError_title,caption:o.assignSerialNoSuccessErrorText})&&(s=!0)):(e.serialNoInput=await t.input({title:a.itemTracking_title,caption:format(a.bomItemTracking_Lead,e.bomComponentLineWithoutSerialLotNo.description,e.bomComponentLineWithoutSerialLotNo.parentBOMDescription)}),(e.serialNoInput||n.SelectSerialNoListEmptyInput)&&(o=await i.respond("assignSerialNo"),!o.assignSerialNoSuccess&&o.assignSerialNoSuccessErrorText&&await t.confirm({title:a.serialNoError_title,caption:o.assignSerialNoSuccessErrorText})&&(s=!0)))),e.bomComponentLineWithoutSerialLotNo.requiresLotNoInput&&(n.SelectLotNo==1&&e.bomComponentLineWithoutSerialLotNo.useSpecTrackingLotNo?(o=await i.respond("assignLotNo"),!o.assignLotNoSuccess&&o.assignLotNoSuccessErrorText&&await t.confirm({title:a.lotNoError_title,caption:o.assignLotNoSuccessErrorText})&&(s=!0)):(e.lotNoInput=await t.input({title:a.ItemTrackingLot_TitleLbl,caption:format(a.bomItemTrackingLot_Lead,e.bomComponentLineWithoutSerialLotNo.description,e.bomComponentLineWithoutSerialLotNo.parentBOMDescription)}),(e.lotNoInput||n.SelectLotNo==2)&&(o=await i.respond("assignLotNo"),!o.assignLotNoSuccess&&o.assignLotNoSuccessErrorText&&await t.confirm({title:a.lotNoError_title,caption:o.assignLotNoSuccessErrorText})&&(s=!0))))}}}function format(r,...i){if(!r.match(/^(?:(?:(?:[^{}]|(?:\{\{)|(?:\}\}))+)|(?:\{[0-9]+\}))+$/))throw new Error("invalid format string.");return r.replace(/((?:[^{}]|(?:\{\{)|(?:\}\}))+)|(?:\{([0-9]+)\})/g,(e,n,t)=>{if(n)return n.replace(/(?:{{)|(?:}})/g,a=>a[0]);if(t>=i.length)throw new Error("argument index is out of range in format");return i[t]})}'
    )
    end;

}
