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

    procedure RunWorkflow(Step: Text;
                          Context: Codeunit "NPR POS JSON Helper";
                          FrontEnd: Codeunit "NPR POS Front End Management";
                          Sale: Codeunit "NPR POS Sale";
                          SaleLine: Codeunit "NPR POS Sale Line";
                          PaymentLine: Codeunit "NPR POS Payment Line";
                          Setup: Codeunit "NPR POS Setup")
    var
    begin
        case Step of
            'addSalesLine':
                FrontEnd.WorkflowResponse(Step_AddSalesLine(Context,
                                                             FrontEnd,
                                                             Setup));
            'checkAvailability':
                CheckAvailability(Context);

            'assignSerialNo':
                FrontEnd.WorkflowResponse(AssignSerialNo(Context,
                                          Setup));
        end;
    end;

    local procedure IfAddItemAddOns(Item: Record Item): Boolean
    begin
        exit(Item."NPR Item Addon No." <> '')
    end;

    local procedure Step_AddSalesLine(Context: Codeunit "NPR POS JSON Helper";
                                      FrontEnd: Codeunit "NPR POS Front End Management";
                                      Setup: Codeunit "NPR POS Setup") Response: JsonObject
    var
        UseSpecificTracking: Boolean;
        InputSerial: Text[50];
        ItemIdentifier: Text;
        ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference,ItemGtin;
        Item: Record Item;
        ItemReference: Record "Item Reference";
        PosInventoryProfile: Record "NPR POS Inventory Profile";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSActionInsertItemB: Codeunit "NPR POS Action: Insert Item B";
        PosItemCheckAvail: Codeunit "NPR POS Item-Check Avail.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSession: Codeunit "NPR POS Session";
        NPRPOSTrackingUtils: Codeunit "NPR POS Tracking Utils";
        EditDesc: Boolean;
        EditDesc2: Boolean;
        GetPromptSerial: Boolean;
        SerialSelectionFromList: Boolean;
        SkipItemAvailabilityCheck: Boolean;
        Success: Boolean;
        UsePresetUnitPrice: Boolean;
        ItemQuantity: Decimal;
        PresetUnitPrice: Decimal;
        UnitPrice: Decimal;
        BaseLineNo: Integer;
        ChildBOMLinesWithoutSerialNoJsonArray: JsonArray;
        CustomDescription: Text;
        CustomDescription2: Text;
        UnitOfMeasure: Text;
    begin
        ItemIdentifier := Context.GetStringParameter('itemNo');
        UnitOfMeasure := Context.GetStringParameter('unitOfMeasure');
        ItemIdentifierType := Context.GetIntegerParameter('itemIdentifierType');
        ItemQuantity := Context.GetDecimalParameter('itemQuantity');
        UsePresetUnitPrice := Context.GetBooleanParameter('usePreSetUnitPrice');
        PresetUnitPrice := Context.GetDecimalParameter('preSetUnitPrice');
        SkipItemAvailabilityCheck := Context.GetBooleanParameter('SkipItemAvailabilityCheck');
        EditDesc := Context.GetBooleanParameter('EditDescription');
        EditDesc2 := Context.GetBooleanParameter('EditDescription2');
        if not Context.GetBooleanParameter('SelectSerialNo', SerialSelectionFromList) then;

        if ItemIdentifierType < 0 then
            ItemIdentifierType := 0;

        POSActionInsertItemB.GetItem(Item,
                                     ItemReference,
                                     ItemIdentifier,
                                     ItemIdentifierType);

        LogStartTelem();

        if EditDesc then
            CustomDescription := Context.GetString('Desc1');

        if EditDesc2 then
            CustomDescription2 := Context.GetString('Desc2');

        if UsePresetUnitPrice then
            UnitPrice := PresetUnitPrice;

        Response.Add('ItemGroupSale', Item."NPR Group sale");

        Item.CalcFields("Assembly BOM");
        if not (Item."Assembly BOM" and Item."NPR Explode BOM auto") then
            GetPromptSerial := NPRPOSTrackingUtils.ItemRequiresSerialNumber(Item,
                                                                            UseSpecificTracking);

        Response.Add('GetPromptSerial', GetPromptSerial);

        Response.Add('useSpecTracking', UseSpecificTracking);

        Success := (not UseSpecificTracking) and
                   (not Item."NPR Group sale") and
                   (not GetPromptSerial);

        Response.Add('Success', Success);



        If (not Success) then begin

            if (not Context.GetBoolean('GetPrompt')) then
                exit;

            if Context.HasProperty('SerialNo') then
#pragma warning disable AA0139
                InputSerial := Context.GetString('SerialNo');
#pragma warning restore AA0139
            NPRPOSTrackingUtils.ValidateSerialNo(ItemReference."Item No.",
                                                 ItemReference."Variant Code",
                                                 InputSerial,
                                                 SerialSelectionFromList,
                                                 Setup);

            if Item."NPR Group sale" then
                UnitPrice := Context.GetDecimal('UnitPrice');

        end;

        Clear(PosItemCheckAvail);
        if not SkipItemAvailabilityCheck then begin

            PosItemCheckAvail.GetPosInvtProfile(POSSession, PosInventoryProfile);

            if PosInventoryProfile."Stockout Warning" then
                PosItemCheckAvail.SetxDataset(POSSession);

            POSSession.SetAvailabilityCheckState(PosItemCheckAvail);
        end;

        POSActionInsertItemB.AddItemLine(Item,
                                         ItemReference,
                                         ItemIdentifierType,
                                         ItemQuantity,
                                         CopyStr(UnitOfMeasure, 1, 10),
                                         UnitPrice,
                                         CustomDescription,
                                         CustomDescription2,
                                         InputSerial,
                                         POSSession,
                                         FrontEnd);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        ChildBOMLinesWithoutSerialNoJsonArray := CreateChildBOMLinesSerialNoAssignmentResponse(SaleLinePOS);
        Response.Add('childBOMLinesWithoutSerialNo', ChildBOMLinesWithoutSerialNoJsonArray);

        if IfAddItemAddOns(Item) then begin

            Response.Add('AddItemAddOn', true);

            BaseLineNo := POSActionInsertItemB.GetLineNo();

            Response.Add('BaseLineNo', BaseLineNo);

        end else
            if not SkipItemAvailabilityCheck then
                CheckAvailability(PosInventoryProfile,
                                  PosItemCheckAvail);

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

    #region CreateChildBOMLinesSerialNoAssignmentResponse
    local procedure CreateChildBOMLinesSerialNoAssignmentResponse(SaleLinePOS: Record "NPR POS Sale Line") ResponseJsonArray: JsonArray;
    var
        Item: Record Item;
        ParentItem: Record Item;
        ChildBOMLines: Record "NPR POS Sale Line";
        POSActionInsertItemB: Codeunit "NPR POS Action: Insert Item B";
        POSTrackingUtils: Codeunit "NPR POS Tracking Utils";
        useSpecTracking: boolean;
        CurrJsonObject: JsonObject;

    begin

        POSActionInsertItemB.GetChildBOMLines(SaleLinePOS,
                                              ChildBOMLines);

        ChildBOMLines.SetLoadFields("No.", "Variant Code",
                                    "Parent BOM Item No.",
                                    Description,
                                    "Parent BOM Line No.");

        if not ChildBOMLines.FindSet(false) then
            exit;

        repeat

            Item.Get(ChildBOMLines."No.");
            if POSTrackingUtils.ItemRequiresSerialNumber(Item,
                                                         useSpecTracking)
            then begin
                ParentItem.Get(ChildBOMLines."Parent BOM Item No.");

                Clear(CurrJsonObject);
                CurrJsonObject.Add('registerNo', ChildBOMLines."Register No.");
                CurrJsonObject.Add('salesTicketNo', ChildBOMLines."Sales Ticket No.");
                CurrJsonObject.Add('lineNo', ChildBOMLines."Line No.");
                CurrJsonObject.Add('no', ChildBOMLines."No.");
                CurrJsonObject.Add('description', ChildBOMLines.Description);
                CurrJsonObject.Add('variantCode', ChildBOMLines."Variant Code");
                CurrJsonObject.Add('parentBOMItemNo', ChildBOMLines."Parent BOM Item No.");
                CurrJsonObject.Add('parentBOMLineNo', ChildBOMLines."Parent BOM Line No.");
                CurrJsonObject.Add('parentBOMDescription', ParentItem.Description);
                CurrJsonObject.Add('useSpecTracking', useSpecTracking);
                CurrJsonObject.Add('recordID', Format(ChildBOMLines.RecordId));
                CurrJsonObject.Add('systemID', ChildBOMLines.SystemId);
                ResponseJsonArray.Add(CurrJsonObject);
            end;
        until ChildBOMLines.Next() = 0;


    end;
    #endregion CreateChildBOMLinesSerialNoAssignmentResponse

    #region AssignSerialNo
    local procedure AssignSerialNo(Context: Codeunit "NPR POS JSON Helper";
                                   Setup: Codeunit "NPR POS Setup") ResponseJsonObject: JsonObject
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSActionItemInsertTry: Codeunit "NPR POS Action Item Insert Try";
        AssignSerialNoSuccess: Boolean;
        SerialSelectionFromList: Boolean;
        ChildBOMLineJsonObject: JsonObject;
        ResultToken: JsonToken;
        AssignSerialNoSuccessErrorText: Text;
        ChildSystemID: Text;
        InputSerial: Text[50];
        WrongSerial_InstrLbl: Label ' Press Yes to re-enter serial number now. Press No to enter serial number later.';
    begin
#pragma warning disable AA0139
        InputSerial := Context.GetString('SerialNo');
#pragma warning restore AA0139
        if not Context.GetBooleanParameter('SelectSerialNo', SerialSelectionFromList) then;

        Clear(ChildBOMLineJsonObject);
        ChildBOMLineJsonObject := Context.GetJsonObject('childBOMLineWithoutSerialNo');

        Clear(ResultToken);
        ChildBOMLineJsonObject.Get('systemID', ResultToken);
        ChildSystemID := ResultToken.AsValue().AsText();

        SaleLinePOS.GetBySystemId(ChildSystemID);

        ClearLastError();
        Clear(POSActionItemInsertTry);
        POSActionItemInsertTry.SetSaleLine(SaleLinePOS);
        POSActionItemInsertTry.SetSerialNoInput(InputSerial);
        POSActionItemInsertTry.SetSerialSelectionFromList(SerialSelectionFromList);
        POSActionItemInsertTry.SetSetup(Setup);
        POSActionItemInsertTry.SetFunctionToExecute('AssignSerialNo');

        AssignSerialNoSuccess := POSActionItemInsertTry.Run();

        AssignSerialNoSuccessErrorText := '';
        if not AssignSerialNoSuccess then begin
            AssignSerialNoSuccessErrorText := GetLastErrorText();
            if AssignSerialNoSuccessErrorText <> '' then
                AssignSerialNoSuccessErrorText += WrongSerial_InstrLbl;
        end;

        ResponseJsonObject.Add('AssignSerialNoSuccess', AssignSerialNoSuccess);
        ResponseJsonObject.Add('AssignSerialNoSuccessErrorText', AssignSerialNoSuccessErrorText);

    end;
    #endregion AssignSerialNo

    local procedure AddPostWorkflowsToRun(Context: Codeunit "NPR POS JSON Helper"; SaleLinePOS: Record "NPR POS Sale Line") PostWorkflows: JsonObject
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
'let main=async({workflow:t,context:n,scope:g,popup:i,parameters:a,captions:e})=>{debugger;if(t.context.GetPrompt=!1,a.EditDescription&&(t.context.Desc1=await i.input({title:e.editDesc_title,caption:e.editDesc_lead,value:n.defaultDescription}),t.context.Desc1===null)||a.EditDescription2&&(t.context.Desc2=await i.input({title:e.editDesc2_title,caption:e.editDesc2_lead,value:n.defaultDescription}),t.context.Desc2===null))return" ";const{childBOMLinesWithoutSerialNo:d,ItemGroupSale:N,useSpecTracking:s,GetPromptSerial:o,Success:x,AddItemAddOn:h,BaseLineNo:m,postAddWorkflows:S}=await t.respond("addSalesLine");if(x)for(var c=0;c<d.length;c++)for(var l=!0,r;l;)l=!1,c!="remove"&&c!="add"&&c!="addRange"&&c!="aggregate"&&(t.context.SerialNo="",t.context.childBOMLineWithoutSerialNo=d[c],a.SelectSerialNo&&t.context.childBOMLineWithoutSerialNo.useSpecTracking?(r=await t.respond("assignSerialNo"),!r.AssignSerialNoSuccess&&r.AssignSerialNoSuccessErrorText&&await i.confirm({title:e.serialNoError_title,caption:r.AssignSerialNoSuccessErrorText})&&(l=!0)):(t.context.SerialNo=await i.input({title:e.itemTracking_title,caption:format(e.bomItemTracking_Lead,t.context.childBOMLineWithoutSerialNo.description,t.context.childBOMLineWithoutSerialNo.parentBOMDescription)}),t.context.SerialNo&&(r=await t.respond("assignSerialNo"),!r.AssignSerialNoSuccess&&r.AssignSerialNoSuccessErrorText&&await i.confirm({title:e.serialNoError_title,caption:r.AssignSerialNoSuccessErrorText})&&(l=!0))));else{if(t.context.GetPrompt=!0,N&&!a.usePreSetUnitPrice&&(t.context.UnitPrice=await i.numpad({title:e.UnitpriceTitle,caption:e.UnitPriceCaption}),t.context.UnitPrice===null)||s&&!a.SelectSerialNo&&(t.context.SerialNo=await i.input({title:e.itemTracking_title,caption:e.itemTracking_lead}),t.context.SerialNo===null)||!s&&o&&(t.context.SerialNo=await i.input({title:e.itemTracking_title,caption:e.itemTracking_lead}),t.context.SerialNo===null))return" ";t.context.useSpecTracking=s,await t.respond("addSalesLine")}if(h&&(await t.run("RUN_ITEM_ADDONS",{context:{BaseLineNo:m},parameters:{SkipItemAvailabilityCheck:!0}}),await t.respond("checkAvailability")),S)for(const f of Object.entries(S)){let[u,D]=f;u&&await t.run(u,{parameters:D})}};function format(t,...n){if(!t.match(/^(?:(?:(?:[^{}]|(?:\{\{)|(?:\}\}))+)|(?:\{[0-9]+\}))+$/))throw new Error("invalid format string.");return t.replace(/((?:[^{}]|(?:\{\{)|(?:\}\}))+)|(?:\{([0-9]+)\})/g,(g,i,a)=>{if(i)return i.replace(/(?:{{)|(?:}})/g,e=>e[0]);if(a>=n.length)throw new Error("argument index is out of range in format");return n[a]})}'
        );
    end;

}
