codeunit 6150723 "NPR POS Action: Insert Item"
{
    var
        ActionDescription: Label 'This is a built-in action for inserting an item line into the current transaction';
        TEXTitemTracking_title: Label 'Enter Serial Number';
        TEXTitemTracking_lead: Label 'This item requires serial number, enter serial number.';
        TEXTitemTracking_instructions: Label 'Enter serial number now and press OK. Press Cancel to enter serial number later.';
        TEXTActive: Label 'active';
        TEXTWrongSerialOnILE: Label 'Serial number %1 for item %2 - %3 can not be used since it can not be found as received.';
        TEXTWrongSerialOnSLP: Label 'Serial number %1 for item %2 - %3 can not be used since it is already on %4 sale %5 on register %6.';
        TEXTWrongSerial_Instr: Label ' \Press OK to re-enter serial number now. \Press Cancel to enter serial number later.\';
        UnitPriceCaption: Label 'This is item is an item group. Specify the unit price for item.';
        UnitPriceTitle: Label 'Unit price is required';
        TEXTeditDesc_title: Label 'Add or change description.';
        ERROR_ITEMSEARCH: Label 'Could not find a matching item for input %1';
        SerialSelectionFromList: Boolean;
        ReadingErr: Label 'reading in %1 of %2';
        SettingScopeErr: Label 'setting scope in %1';

    procedure ActionCode(): Text
    begin
        exit('ITEM');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.8');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
          ActionCode(),
          ActionDescription,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Single)
        then begin
            Sender.RegisterWorkflowStep('editDescription', 'param.descriptionEdit && input({title: labels.editDesc_title, caption: labels.editDesc_lead, value: context.defaultDescription}).cancel(abort);');
            Sender.RegisterWorkflowStep('skipContextDialogs', 'goto("addSalesLine")');

            Sender.RegisterWorkflowStep('promptContextDialogs', '');
            Sender.RegisterWorkflowStep('unitPrice', 'context.promptPrice && numpad({title: labels.UnitpriceTitle, caption: labels.UnitPriceCaption}).cancel(abort);');
            Sender.RegisterWorkflowStep('itemTrackingForce',
              'context.promptSerial && context.useSpecificTracking && input(labels.itemTracking_title, labels.itemTracking_lead, context.itemTracking_instructions, "", !param.AllowToSelectSerialNoFromList).respond().cancel(abort);');
            Sender.RegisterWorkflowStep('itemTrackingOptional', 'context.promptSerial && !context.useSpecificTracking && input(labels.itemTracking_title, labels.itemTracking_lead, context.itemTracking_instructions, "", true);');
            Sender.RegisterWorkflowStep('addSalesLine', 'respond();');
            Sender.RegisterWorkflow(false);
            Sender.RegisterOptionParameter('itemIdentifyerType', 'ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference', 'ItemNo');
            Sender.RegisterTextParameter('itemNo', '');
            Sender.RegisterDecimalParameter('itemQuantity', 1);
            Sender.RegisterBooleanParameter('descriptionEdit', false);
            Sender.RegisterBooleanParameter('usePreSetUnitPrice', false);
            Sender.RegisterDecimalParameter('preSetUnitPrice', 0);
            Sender.RegisterBooleanParameter('AllowToSelectSerialNoFromList', false);

            Sender.RegisterBlockingUI(false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'itemTracking_title', TEXTitemTracking_title);
        Captions.AddActionCaption(ActionCode(), 'itemTracking_lead', TEXTitemTracking_lead);
        Captions.AddActionCaption(ActionCode(), 'UnitpriceTitle', UnitPriceTitle);
        Captions.AddActionCaption(ActionCode(), 'UnitpriceCaption', UnitPriceCaption);
        Captions.AddActionCaption(ActionCode(), 'editDesc_title', TEXTeditDesc_title);
        Captions.AddActionCaption(ActionCode(), 'editDesc_lead', TEXTeditDesc_title);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin

        if not Action.IsThisAction(ActionCode()) then
            exit;

        case WorkflowStep of
            'itemTrackingForce':
                Step_ItemTracking(Context, POSSession, FrontEnd);
            'addSalesLine':
                Step_AddSalesLine(Context, POSSession, FrontEnd);
        end;

        Handled := true;
    end;

    local procedure Step_AddSalesLine(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        JSON: Codeunit "NPR POS JSON Management";
        UseSpecificTracking: Boolean;
        InputSerial: Code[20];
        UnitPrice: Decimal;
        ItemIdentifier: Text;
        ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference;
        Item: Record Item;
        ItemReference: Record "Item Reference";
        ItemQuantity: Decimal;
        HasPrompted: Boolean;
        UsePresetUnitPrice: Boolean;
        PresetUnitPrice: Decimal;
        DialogContext: Codeunit "NPR POS JSON Management";
        DialogPrompt: Boolean;
        SetUnitPrice: Boolean;
        CustomDescription: Text;
        ValidatedSerialNumber: Text;
        ValidatedVariantCode: Text;
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);
        HasPrompted := JSON.GetBoolean('promptPrice') or JSON.GetBoolean('promptSerial');
        JSON.SetScopeParameters(ActionCode());
        ItemIdentifier := JSON.GetStringOrFail('itemNo', StrSubstNo(ReadingErr, 'Step_AddSalesLine', ActionCode()));
        ItemIdentifierType := JSON.GetInteger('itemIdentifyerType');
        ItemQuantity := JSON.GetDecimal('itemQuantity');
        UsePresetUnitPrice := JSON.GetBoolean('usePreSetUnitPrice');
        PresetUnitPrice := JSON.GetDecimal('preSetUnitPrice');

        if ItemIdentifierType < 0 then
            ItemIdentifierType := 0;

        GetItem(Item, ItemReference, ItemIdentifier, ItemIdentifierType);

        if not HasPrompted then begin
            if Item."NPR Group sale" and (not UsePresetUnitPrice) then begin
                DialogContext.SetContext('promptPrice', true);
                DialogPrompt := true;
            end;

            if ItemRequiresSerialNumberOnSale(Item, UseSpecificTracking) then begin
                DialogContext.SetContext('promptSerial', true);
                DialogContext.SetContext('itemTracking_instructions', TEXTitemTracking_instructions);
                DialogContext.SetContext('useSpecificTracking', UseSpecificTracking);
                DialogPrompt := true;
            end;

            if DialogPrompt then begin
                FrontEnd.SetActionContext(ActionCode(), DialogContext);
                FrontEnd.ContinueAtStep('promptContextDialogs');
                exit;
            end;
        end;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScopeRoot();
        UseSpecificTracking := JSON.GetBoolean('useSpecificTracking');
        ValidatedSerialNumber := JSON.GetString('validatedSerialNumber');
        ValidatedVariantCode := JSON.GetString('validatedVariantCode');
        if ValidatedVariantCode <> '' then
            ItemReference."Variant Code" := CopyStr(ValidatedVariantCode, 1, MaxStrLen(ItemReference."Variant Code"));

        if UsePresetUnitPrice then begin
            UnitPrice := PresetUnitPrice;
            SetUnitPrice := true;
        end else begin
            JSON.InitializeJObjectParser(Context, FrontEnd);
            if (JSON.SetScope('$unitPrice')) then begin
                UnitPrice := JSON.GetDecimalOrFail('numpad', StrSubstNo(ReadingErr, 'Step_AddSalesLine', ActionCode()));
                SetUnitPrice := true;
            end;
        end;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        if JSON.SetScope('$itemTrackingOptional') then
            InputSerial := CopyStr(JSON.GetString('input'), 1, MaxStrLen(InputSerial));

        JSON.InitializeJObjectParser(Context, FrontEnd);
        if JSON.SetScope('$editDescription') then
            CustomDescription := JSON.GetString('input');

        AddItemLine(Item, ItemReference, ItemIdentifierType, ItemQuantity, UnitPrice, SetUnitPrice, CustomDescription, InputSerial, UseSpecificTracking, ValidatedSerialNumber, POSSession, FrontEnd);
    end;

    local procedure Step_ItemTracking(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        JSON: Codeunit "NPR POS JSON Management";
        SerialNumberInput: Text;
        UserInformationErrorWarning: Text;
        Item: Record Item;
        ItemReference: Record "Item Reference";
        POSStore: Record "NPR POS Store";
        Setup: Codeunit "NPR POS Setup";
        ItemIdentifier: Text;
        ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference;
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScope('$itemTrackingForce', StrSubstNo(SettingScopeErr, ActionCode()));
        SerialNumberInput := JSON.GetStringOrFail('input', StrSubstNo(ReadingErr, 'Step_ItemTracking', ActionCode()));
        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScopeParameters(ActionCode());
        ItemIdentifier := JSON.GetStringOrFail('itemNo', StrSubstNo(ReadingErr, 'Step_ItemTracking', ActionCode()));
        ItemIdentifierType := JSON.GetInteger('itemIdentifyerType');
        SerialSelectionFromList := JSON.GetBoolean('AllowToSelectSerialNoFromList');

        GetItem(Item, ItemReference, ItemIdentifier, ItemIdentifierType);

        if SerialSelectionFromList then begin
            while not SerialNumberCanBeUsedForItem(ItemReference, CopyStr(SerialNumberInput, 1, 20), UserInformationErrorWarning) do begin
                if SerialNumberInput <> '' then
                    Message(UserInformationErrorWarning);
                SerialNumberInput := '';
                POSSession.GetSetup(Setup);
                Setup.GetPOSStore(POSStore);
                SelectSerialNoFromList(ItemReference, POSStore."Location Code", SerialNumberInput);
                if SerialNumberInput = '' then
                    Error('');
            end;
        end else
            if not SerialNumberCanBeUsedForItem(ItemReference, CopyStr(SerialNumberInput, 1, 20), UserInformationErrorWarning) then begin
                SerialNumberInput := '';
                JSON.InitializeJObjectParser(Context, FrontEnd);
                JSON.SetScopeRoot();
                JSON.SetContext('itemTracking_instructions', UserInformationErrorWarning);
                FrontEnd.SetActionContext(ActionCode(), JSON);
                FrontEnd.ContinueAtStep('itemTrackingForce');
                exit;
            end;

        //Serial number is validated correct and should be applied to line
        //Applying is done in finalize
        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScopeRoot();
        JSON.SetContext('validatedSerialNumber', SerialNumberInput);
        JSON.SetContext('validatedVariantCode', ItemReference."Variant Code");
        JSON.InitializeJObjectParser(Context, FrontEnd);
        FrontEnd.SetActionContext(ActionCode(), JSON);
        exit;
    end;

    local procedure GetItem(var Item: Record Item; var ItemReference: Record "Item Reference"; ItemIdentifier: Text; ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference)
    var
        FirstRec: Text;
        TagId: Code[20];
    begin
        Clear(ItemReference);
        case ItemIdentifierType of
            ItemIdentifierType::ItemNo:
                Item.Get(ItemIdentifier);

            ItemIdentifierType::ItemCrossReference:
                begin
                    ItemReference.SetFilter("Reference No.", '=%1', CopyStr(ItemIdentifier, 1, MaxStrLen(ItemReference."Reference No.")));
                    ItemReference.SetFilter("Reference Type", '=%1', ItemReference."Reference Type"::"Bar Code");
                    ItemReference.FindFirst();
                    FirstRec := Format(ItemReference);
                    ItemReference.FindLast();
                    if FirstRec <> Format(ItemReference) then begin
                        if PAGE.RunModal(0, ItemReference) <> ACTION::LookupOK then
                            Error('');
                    end;
                    Item.Get(ItemReference."Item No.");
                end;

            ItemIdentifierType::ItemSearch:
                if GetItemFromItemSearch(ItemIdentifier) then
                    Item.Get(ItemIdentifier)
                else
                    Error(ERROR_ITEMSEARCH, ItemIdentifier);

            ItemIdentifierType::SerialNoItemCrossReference:
                begin

                    TagId := CopyStr(CopyStr(ItemIdentifier, 5), 1, MaxStrLen(TagId));

                    ItemReference.SetFilter("Reference No.", '=%1', CopyStr(TagId, 1, MaxStrLen(ItemReference."Reference No.")));
                    ItemReference.SetFilter("Reference Type", '=%1', ItemReference."Reference Type"::"NPR Retail Serial No.");
                    ItemReference.FindFirst();
                    FirstRec := Format(ItemReference);
                    ItemReference.FindLast();
                    if FirstRec <> Format(ItemReference) then begin
                        if PAGE.RunModal(0, ItemReference) <> ACTION::LookupOK then
                            Error('');
                    end;

                    Item.Get(ItemReference."Item No.");
                end;
        end;
        ItemReference."Item No." := Item."No.";
    end;

    procedure AddItemLine(Item: Record Item; ItemReference: Record "Item Reference"; ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference; ItemQuantity: Decimal; UnitPrice: Decimal; SetUnitPrice: Boolean; CustomDescription: Text; InputSerial: Text; UseSpecificTracking: Boolean; ValidatedSerialNumber: Text; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Line: Record "NPR POS Sale Line";
        SaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        if ItemQuantity = 0 then
            ItemQuantity := 1;

        Line.Type := Line.Type::Item;
        Line.Quantity := ItemQuantity;

        case ItemIdentifierType of
            ItemIdentifierType::ItemSearch,
            ItemIdentifierType::ItemNo:
                begin
                    Line."No." := Item."No.";
                    Line."Variant Code" := ItemReference."Variant Code";
                end;

            ItemIdentifierType::ItemCrossReference:
                begin
                    Line."No." := ItemReference."Item No.";
                    Line."Variant Code" := ItemReference."Variant Code";
                    Line."Unit of Measure Code" := ItemReference."Unit of Measure";
                    if (ItemReference."Reference Type" = ItemReference."Reference Type"::"NPR Retail Serial No.") then
                        Line."Serial No. not Created" := ItemReference."Reference No.";

                end;

            ItemIdentifierType::SerialNoItemCrossReference:
                begin

                    SaleLinePOS.Reset();
                    SaleLinePOS.SetFilter(Type, '=%1', SaleLinePOS.Type::Item);
                    SaleLinePOS.SetFilter("Serial No. not Created", '=%1', ItemReference."Reference No.");
                    if not SaleLinePOS.IsEmpty then
                        exit;

                    Line."No." := ItemReference."Item No.";
                    Line."Variant Code" := ItemReference."Variant Code";
                    Line."Unit of Measure Code" := ItemReference."Unit of Measure";
                    if (ItemReference."Reference Type" = ItemReference."Reference Type"::"NPR Retail Serial No.") then
                        Line."Serial No. not Created" := ItemReference."Reference No.";
                end;
        end;

        if (UseSpecificTracking and (ValidatedSerialNumber <> '')) then
            Line.Validate("Serial No.", ValidatedSerialNumber);
        if (not UseSpecificTracking and (InputSerial <> '')) then
            Line.Validate("Serial No.", InputSerial);

        if CustomDescription <> '' then
            Line.Description := CopyStr(CustomDescription, 1, MaxStrLen(Line.Description));

        if SetUnitPrice then begin
            Line."Unit Price" := UnitPrice;

            if (Line.Type = Line.Type::Item) then
                Line."Initial Group Sale Price" := UnitPrice;
        end;

        POSSession.GetSaleLine(SaleLine);
        SaleLine.InsertLine(Line, false);
        AddAccessories(Item, SaleLine);
        AutoExplodeBOM(Item, SaleLine);
        AddItemAddOns(FrontEnd, Item, Line."Line No.");

        POSSession.RequestRefreshData();
    end;

    local procedure AutoExplodeBOM(Item: Record Item; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        Level: Integer;
    begin
        if not Item."NPR Explode BOM auto" then
            exit;
        Item.CalcFields("Assembly BOM");
        if not Item."Assembly BOM" then
            exit;

        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLinePOS.Validate(Type, SaleLinePOS.Type::"BOM List");
        SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::"BOM List";
        SaleLinePOS."Discount Code" := SaleLinePOS."No.";
        SaleLinePOS."Unit Price" := 0;
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        SaleLinePOS.Modify(true);

        SaleLinePOS.ExplodeBOM(SaleLinePOS."No.", 0, 0, Level, 0, 0);
    end;

    local procedure AddAccessories(Item: Record Item; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        AccessorySparePart: Record "NPR Accessory/Spare Part";
    begin
        // This is an adoption of the original function UdpakTilbeh¢r in 6014418
        AccessorySparePart.SetFilter(Type, '=%1', AccessorySparePart.Type::Accessory);
        AccessorySparePart.SetFilter(Code, '=%1', Item."No.");
        AccessorySparePart.SetFilter("Add Extra Line Automatically", '=%1', true);
        if (AccessorySparePart.IsEmpty()) then begin
            // Item Group Accessory
            AccessorySparePart.SetFilter(Code, '=%1', Item."Item Category Code");
            if (not AccessorySparePart.IsEmpty()) then
                AddAccessoryForItem(Item, true, POSSaleLine);
        end else
            AddAccessoryForItem(Item, false, POSSaleLine);
    end;

    local procedure AddAccessoryForItem(Item: Record Item; GroupAccessory: Boolean; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        MainSaleLinePOS: Record "NPR POS Sale Line";
        AccessorySaleLinePOS: Record "NPR POS Sale Line";
        AccessorySparePart: Record "NPR Accessory/Spare Part";
    begin

        AccessorySparePart.SetFilter(Type, '=%1', AccessorySparePart.Type::Accessory);
        AccessorySparePart.SetFilter(Code, '=%1', Item."No.");
        if (not AccessorySparePart.FindSet()) then
            exit;

        POSSaleLine.GetCurrentSaleLine(MainSaleLinePOS);

        repeat
            POSSaleLine.GetNewSaleLine(AccessorySaleLinePOS);

            AccessorySaleLinePOS.Accessory := true;
            AccessorySaleLinePOS."Main Item No." := Item."No.";
            AccessorySaleLinePOS."Item group accessory" := GroupAccessory;
            if (GroupAccessory) then
                AccessorySaleLinePOS."Accessories Item Group No." := Item."Item Category Code";

            AccessorySaleLinePOS.Validate("No.", AccessorySparePart."Item No.");

            // This is not support unless we add a commit at this point
            if (AccessorySparePart."Quantity in Dialogue") then
                Error('The possibility to specify quantity per accessory line in a dialogue has been discontinued.');

            if (AccessorySparePart."Per unit") then
                AccessorySaleLinePOS.Validate(Quantity, AccessorySparePart.Quantity * MainSaleLinePOS.Quantity)
            else
                AccessorySaleLinePOS.Validate(Quantity, AccessorySparePart.Quantity);

            if AccessorySparePart."Use Alt. Price" and not AccessorySparePart."Show Discount" then begin
                AccessorySaleLinePOS."Manual Item Sales Price" := true;
                AccessorySaleLinePOS."Unit Price" := AccessorySparePart."Alt. Price";
            end else
                AccessorySaleLinePOS."Unit Price" := 0;  //Allow for default price retrieval routine to kick in

            POSSaleLine.InsertLine(AccessorySaleLinePOS);

            if AccessorySparePart."Use Alt. Price" and AccessorySparePart."Show Discount" then begin
                POSSaleLine.ConvertPriceToVAT(
                  Item."Price Includes VAT", Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group",
                  AccessorySaleLinePOS, AccessorySparePart."Alt. Price");
                if not AccessorySaleLinePOS."Price Includes VAT" then
                    AccessorySparePart."Alt. Price" := AccessorySparePart."Alt. Price" * (1 + (AccessorySaleLinePOS."VAT %" / 100));
                AccessorySaleLinePOS.Validate("Amount Including VAT", AccessorySparePart."Alt. Price" * AccessorySaleLinePOS.Quantity);
            end;

            AccessorySaleLinePOS."Item group accessory" := GroupAccessory;
            if (GroupAccessory) then
                AccessorySaleLinePOS."Accessories Item Group No." := Item."Item Category Code";

            AccessorySaleLinePOS.Accessory := true;
            AccessorySaleLinePOS."Main Item No." := Item."No.";
            AccessorySaleLinePOS."Main Line No." := MainSaleLinePOS."Line No.";

            AccessorySaleLinePOS.Modify();
            POSSaleLine.RefreshCurrent();
        until (AccessorySparePart.Next() = 0);

    end;

    local procedure AddItemAddOns(POSFrontEnd: Codeunit "NPR POS Front End Management"; Item: Record Item; BaseLineNo: Integer)
    var
        POSAction: Record "NPR POS Action";
    begin
        if Item."NPR Item AddOn No." = '' then
            exit;

        POSAction.Get('RUN_ITEM_ADDONS');
        POSAction.SetWorkflowInvocationContext('BaseLineNo', BaseLineNo);
        POSFrontEnd.InvokeWorkflow(POSAction);
    end;

    local procedure ItemRequiresSerialNumberOnSale(Item: Record Item; var UseSpecificTracking: Boolean): Boolean
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        //Global
        if Item."Item Tracking Code" = '' then exit(false);
        if not ItemTrackingCode.Get(Item."Item Tracking Code") then exit(false);
        ItemTrackingCode.TestField("Lot Specific Tracking", false);
        UseSpecificTracking := ItemTrackingCode."SN Specific Tracking";
        exit(ItemTrackingCode."SN Sales Outbound Tracking");
    end;

    local procedure SerialNumberCanBeUsedForItem(var ItemRef: Record "Item Reference"; SerialNumber: Code[20]; var UserInformationErrorWarning: Text) CanBeUsed: Boolean
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ItemLedgerEntry: Record "Item Ledger Entry";
        SaleLinePOS: Record "NPR POS Sale Line";
        "Sale POS": Record "NPR POS Sale";
        TextActiveSaved: Text;
    begin
        if not Item.Get(ItemRef."Item No.") then exit(false);
        if Item."Item Tracking Code" = '' then exit(false);
        if not ItemTrackingCode.Get(Item."Item Tracking Code") then exit(false);

        UserInformationErrorWarning := '';

        if not ItemTrackingCode."SN Specific Tracking" then begin
            CanBeUsed := true;
        end else begin
            ItemLedgerEntry.Reset();
            if ItemLedgerEntry.SetCurrentKey(Open, Positive, "Item No.", "Serial No.") then;
            ItemLedgerEntry.SetRange(Open, true);
            ItemLedgerEntry.SetRange(Positive, true);
            ItemLedgerEntry.SetFilter("Serial No.", '=%1', SerialNumber);
            ItemLedgerEntry.SetRange("Item No.", ItemRef."Item No.");
            if ItemRef."Variant Code" <> '' then
                ItemLedgerEntry.SetRange("Variant Code", ItemRef."Variant Code");
            if not ItemLedgerEntry.FindSet() then begin
                CanBeUsed := false;
                UserInformationErrorWarning := StrSubstNo(TEXTWrongSerialOnILE, SerialNumber, Item."No.", Item.Description);  //NPR5.55 [398263]
            end else begin
                CanBeUsed := true;
            end;

            //Check if serial number exists in saved/active pos sale line
            //TO DO: check pos saved sales?
            if CanBeUsed then begin
                SaleLinePOS.Reset();
                SaleLinePOS.SetCurrentKey("Serial No.");
                SaleLinePOS.SetFilter(Type, '=%1', SaleLinePOS.Type::Item);
                SaleLinePOS.SetRange("No.", ItemRef."Item No.");
                SaleLinePOS.SetFilter("Serial No.", '=%1', SerialNumber);
                repeat
                    SaleLinePOS.SetRange("Variant Code", ItemLedgerEntry."Variant Code");
                    CanBeUsed := SaleLinePOS.IsEmpty();
                    if CanBeUsed then
                        ItemRef."Variant Code" := ItemLedgerEntry."Variant Code";
                until (ItemLedgerEntry.Next() = 0) or CanBeUsed;

                if not CanBeUsed then begin
                    //Create user information message
                    SaleLinePOS.FindFirst();
                    "Sale POS".Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.");
                    TextActiveSaved := TEXTActive;
                    UserInformationErrorWarning := StrSubstNo(TEXTWrongSerialOnSLP, SerialNumber, Item."No.", Item.Description, TextActiveSaved, SaleLinePOS."Sales Ticket No.", SaleLinePOS."Register No.");  //NPR5.55 [398263]
                end;
            end;
            if (UserInformationErrorWarning <> '') and not SerialSelectionFromList then
                UserInformationErrorWarning := UserInformationErrorWarning + TEXTWrongSerial_Instr;
        end;

        exit(CanBeUsed);
    end;

    local procedure SelectSerialNoFromList(var ItemRef: Record "Item Reference"; LocationCode: Code[10]; var SerialNo: Text)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.Init();
        SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Sale;
        SaleLinePOS.Type := SaleLinePOS.Type::Item;
        SaleLinePOS."No." := ItemRef."Item No.";
        SaleLinePOS."Variant Code" := ItemRef."Variant Code";
        SaleLinePOS."Location Code" := LocationCode;
        SaleLinePOS.Quantity := 1;
        if SaleLinePOS.SerialNoLookup2() then begin
            SerialNo := SaleLinePOS."Serial No.";
            ItemRef."Variant Code" := SaleLinePOS."Variant Code";
        end;
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

        if Item.Get(UpperCase(EanBoxValue)) then
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

        ItemReference.SetRange("Reference No.", UpperCase(EanBoxValue));
        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
        if not ItemReference.IsEmpty() then
            InScope := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Evt Handler", 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeItemSearch(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        Item: Record Item;
    begin
        if EanBoxSetupEvent."Event Code" <> EventCodeItemSearch() then
            exit;

        SetItemSearchFilter(EanBoxValue, Item, false);
        if Item.IsEmpty() then
            exit;

        SetItemSearchFilter(EanBoxValue, Item, true);
        if not Item.IsEmpty() then
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

    local procedure GetItemFromItemSearch(var ItemIdentifierString: Text): Boolean
    var
        Item: Record Item;
        ItemList: Page "NPR Items Smart Search";
    begin
        SetItemSearchFilter(ItemIdentifierString, Item, true);
        if not Item.FindFirst() then
            exit(false);

        ItemIdentifierString := Item."No.";
        Item.FindLast();
        if ItemIdentifierString = Item."No." then
            exit(true);
        ItemList.Editable(true);
        ItemList.LookupMode(true);
        ItemList.SetTableView(Item);
        if ItemList.RunModal() = ACTION::LookupOK then begin
            ItemList.GetRecord(Item);
            ItemIdentifierString := Item."No.";
            exit(true);
        end else begin
            exit(false);
        end;
    end;

    local procedure SetItemSearchFilter(ItemIdentifierString: Text; var Item: Record Item; IncludeBlockedFilter: Boolean)
    var
        SearchFilter: Text;
        SearchString: Text;
        SearchFilterLbl: Label '=%1', Locked = true;
    begin
        Clear(Item);

        SearchString := CopyStr(ItemIdentifierString, 1, MaxStrLen(Item."Search Description"));
        SearchString := UpperCase(SearchString);
        SearchFilter := SearchString + '*';
        if ItemIdentifierString = '' then
            SearchFilter := StrSubstNo(SearchFilterLbl, '');

        Item.SetCurrentKey("Search Description");
        Item.SetFilter("Search Description", SearchFilter);
        if IncludeBlockedFilter then
            Item.SetRange(Blocked, false);
        Item.SetLoadFields("No.");
    end;
}
