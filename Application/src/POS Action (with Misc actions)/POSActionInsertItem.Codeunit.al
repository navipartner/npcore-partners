codeunit 6150723 "NPR POS Action: Insert Item"
{
    var
        ActionDescription: Label 'This is a built-in action for inserting an item line into the current transaction';
        TEXTitemTracking_title: Label 'Enter Serial Number';
        TEXTitemTracking_lead: Label 'This item requires serial number, enter serial number.';
        TEXTitemTracking_instructions: Label 'Enter serial number now and press OK. Press Cancel to enter serial number later.';
        TEXTActive: Label 'active';
        TEXTSaved: Label 'saved';
        TEXTWrongSerialOnILE: Label 'Serial number %1 for item %2 - %3 can not be used since it can not be found as received.';
        TEXTWrongSerialOnSLP: Label 'Serial number %1 for item %2 - %3 can not be used since it is already on %4 sale %5 on register %6.';
        TEXTWrongSerial_Instr: Label ' \Press OK to re-enter serial number now. \Press Cancel to enter serial number later.\';
        UnitPriceCaption: Label 'This is item is an item group. Specify the unit price for item.';
        UnitPriceTitle: Label 'Unit price is required';
        TEXTeditDesc_lead: Label 'Line description';
        TEXTeditDesc_title: Label 'Add or change description.';
        ERROR_ITEMSEARCH: Label 'Could not find a matching item for input %1';
        COMMENT_UNKNOWN_TAG: Label 'Unknown RFID Tag %1';
        SerialSelectionFromList: Boolean;

    procedure ActionCode(): Text
    begin
        exit('ITEM');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.8');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    var
        itemTrackingCode: Text;
    begin
        if Sender.DiscoverAction(
          ActionCode,
          ActionDescription,
          ActionVersion,
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

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    var
        UI: Codeunit "NPR POS UI Management";
    begin
        Captions.AddActionCaption(ActionCode, 'itemTracking_title', TEXTitemTracking_title);
        Captions.AddActionCaption(ActionCode, 'itemTracking_lead', TEXTitemTracking_lead);
        Captions.AddActionCaption(ActionCode, 'UnitpriceTitle', UnitPriceTitle);
        Captions.AddActionCaption(ActionCode, 'UnitpriceCaption', UnitPriceCaption);
        Captions.AddActionCaption(ActionCode, 'editDesc_title', TEXTeditDesc_title);
        Captions.AddActionCaption(ActionCode, 'editDesc_lead', TEXTeditDesc_title);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        ControlId: Text;
        Value: Text;
        DoNotClearTextBox: Boolean;
    begin

        if not Action.IsThisAction(ActionCode) then
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
        ItemCrossReference: Record "Item Cross Reference";
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
        HasPrompted := JSON.GetBoolean('promptPrice', false) or JSON.GetBoolean('promptSerial', false);
        JSON.SetScope('parameters', true);
        ItemIdentifier := JSON.GetString('itemNo', true);
        ItemIdentifierType := JSON.GetInteger('itemIdentifyerType', false);
        ItemQuantity := JSON.GetDecimal('itemQuantity', false);
        UsePresetUnitPrice := JSON.GetBoolean('usePreSetUnitPrice', false);
        PresetUnitPrice := JSON.GetDecimal('preSetUnitPrice', false);

        if ItemIdentifierType < 0 then
            ItemIdentifierType := 0;

        GetItem(Item, ItemCrossReference, ItemIdentifier, ItemIdentifierType);

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
                FrontEnd.SetActionContext(ActionCode, DialogContext);
                FrontEnd.ContinueAtStep('promptContextDialogs');
                exit;
            end;
        end;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScope('/', true);
        UseSpecificTracking := JSON.GetBoolean('useSpecificTracking', false);
        ValidatedSerialNumber := JSON.GetString('validatedSerialNumber', false);
        ValidatedVariantCode := JSON.GetString('validatedVariantCode', false);
        if ValidatedVariantCode <> '' then
            ItemCrossReference."Variant Code" := CopyStr(ValidatedVariantCode, 1, MaxStrLen(ItemCrossReference."Variant Code"));

        if UsePresetUnitPrice then begin
            UnitPrice := PresetUnitPrice;
            SetUnitPrice := true;
        end else begin
            JSON.InitializeJObjectParser(Context, FrontEnd);
            if (JSON.SetScope('$unitPrice', false)) then begin
                UnitPrice := JSON.GetDecimal('numpad', true);
                SetUnitPrice := true;
            end;
        end;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        if JSON.SetScope('$itemTrackingOptional', false) then
            InputSerial := JSON.GetString('input', false);

        JSON.InitializeJObjectParser(Context, FrontEnd);
        if JSON.SetScope('$editDescription', false) then
            CustomDescription := JSON.GetString('input', false);

        AddItemLine(Item, ItemCrossReference, ItemIdentifierType, ItemQuantity, UnitPrice, SetUnitPrice, CustomDescription, InputSerial, UseSpecificTracking, ValidatedSerialNumber, POSSession, FrontEnd);
    end;

    local procedure Step_ItemTracking(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        JSON: Codeunit "NPR POS JSON Management";
        SerialNumberInput: Text;
        SpecificTracking: Boolean;
        OKInput: Boolean;
        SerialNoUsedOnPOSSaleLine: Boolean;
        UserInformationErrorWarning: Text;
        Item: Record Item;
        ItemCrossReference: Record "Item Cross Reference";
        Register: Record "NPR Register";
        Setup: Codeunit "NPR POS Setup";
        ItemIdentifier: Text;
        ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference;
    begin
        //Called on OK when serial number is filled on item witch requires specific tracking on serial number.

        //Get input and check if valid
        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScope('$itemTrackingForce', true);
        SerialNumberInput := JSON.GetString('input', true);
        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScope('parameters', true);
        ItemIdentifier := JSON.GetString('itemNo', true);
        ItemIdentifierType := JSON.GetInteger('itemIdentifyerType', false);
        SerialSelectionFromList := JSON.GetBoolean('AllowToSelectSerialNoFromList', false);

        GetItem(Item, ItemCrossReference, ItemIdentifier, ItemIdentifierType);

        //Some number is inputed, now check if valid for item
        if SerialSelectionFromList then begin
            while not SerialNumberCanBeUsedForItem(ItemCrossReference, SerialNumberInput, UserInformationErrorWarning) do begin
                if SerialNumberInput <> '' then
                    Message(UserInformationErrorWarning);
                SerialNumberInput := '';
                POSSession.GetSetup(Setup);
                Register.Get(Setup.Register());
                SelectSerialNoFromList(ItemCrossReference, Register."Location Code", 1, false, SerialNumberInput);
                if SerialNumberInput = '' then
                    Error('');
            end;
        end else
            if not SerialNumberCanBeUsedForItem(ItemCrossReference, SerialNumberInput, UserInformationErrorWarning) then begin
                SerialNumberInput := '';
                //Serial number is not valid, lets reask
                JSON.InitializeJObjectParser(Context, FrontEnd);
                JSON.SetScope('/', true);
                JSON.SetContext('itemTracking_instructions', UserInformationErrorWarning);
                FrontEnd.SetActionContext(ActionCode, JSON);
                FrontEnd.ContinueAtStep('itemTrackingForce');
                exit;
            end;

        //Serial number is validated correct and should be applied to line
        //Applying is done in finalize
        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScope('/', true);
        JSON.SetContext('validatedSerialNumber', SerialNumberInput);
        JSON.SetContext('validatedVariantCode', ItemCrossReference."Variant Code");
        JSON.InitializeJObjectParser(Context, FrontEnd);
        FrontEnd.SetActionContext(ActionCode, JSON);
        exit;

        POSSession.RequestRefreshData();
    end;

    local procedure "-- Various support functions"()
    begin
    end;

    local procedure GetItem(var Item: Record Item; var ItemCrossReference: Record "Item Cross Reference"; ItemIdentifier: Text; ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference)
    var
        FirstRec: Text;
        TagId: Code[20];
    begin
        Clear(ItemCrossReference);
        case ItemIdentifierType of
            ItemIdentifierType::ItemNo:
                Item.Get(ItemIdentifier);

            ItemIdentifierType::ItemCrossReference:
                begin
                    ItemCrossReference.SetFilter("Cross-Reference No.", '=%1', CopyStr(ItemIdentifier, 1, MaxStrLen(ItemCrossReference."Cross-Reference No.")));
                    ItemCrossReference.SetFilter("Cross-Reference Type", '=%1', ItemCrossReference."Cross-Reference Type"::"Bar Code");
                    ItemCrossReference.SetFilter("Discontinue Bar Code", '=%1', false);
                    ItemCrossReference.FindFirst;
                    FirstRec := Format(ItemCrossReference);
                    ItemCrossReference.FindLast;
                    if FirstRec <> Format(ItemCrossReference) then begin
                        if PAGE.RunModal(0, ItemCrossReference) <> ACTION::LookupOK then
                            Error('');
                    end;
                    Item.Get(ItemCrossReference."Item No.");
                end;

            ItemIdentifierType::ItemSearch:
                if GetItemFromItemSearch(ItemIdentifier) then
                    Item.Get(ItemIdentifier)
                else
                    Error(ERROR_ITEMSEARCH, ItemIdentifier);

            ItemIdentifierType::SerialNoItemCrossReference:
                begin

                    TagId := CopyStr(ItemIdentifier, 5);

                    ItemCrossReference.SetFilter("Cross-Reference No.", '=%1', CopyStr(TagId, 1, MaxStrLen(ItemCrossReference."Cross-Reference No.")));
                    ItemCrossReference.SetFilter("Cross-Reference Type", '=%1', ItemCrossReference."Cross-Reference Type"::"Bar Code");
                    ItemCrossReference.SetFilter("Discontinue Bar Code", '=%1', false);
                    ItemCrossReference.SetFilter("NPR Is Retail Serial No.", '=%1', true);
                    ItemCrossReference.FindFirst;
                    FirstRec := Format(ItemCrossReference);
                    ItemCrossReference.FindLast;
                    if FirstRec <> Format(ItemCrossReference) then begin
                        if PAGE.RunModal(0, ItemCrossReference) <> ACTION::LookupOK then
                            Error('');
                    end;

                    Item.Get(ItemCrossReference."Item No.");
                end;
        end;
        ItemCrossReference."Item No." := Item."No.";
    end;

    procedure AddItemLine(Item: Record Item; ItemCrossReference: Record "Item Cross Reference"; ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference; ItemQuantity: Decimal; UnitPrice: Decimal; SetUnitPrice: Boolean; CustomDescription: Text; InputSerial: Text; UseSpecificTracking: Boolean; ValidatedSerialNumber: Text; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Line: Record "NPR Sale Line POS";
        JSON: Codeunit "NPR POS JSON Management";
        SaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        if ItemQuantity = 0 then
            ItemQuantity := 1;

        with Line do begin
            Type := Type::Item;
            Quantity := ItemQuantity;

            case ItemIdentifierType of
                ItemIdentifierType::ItemSearch,
                ItemIdentifierType::ItemNo:
                    begin
                        "No." := Item."No.";
                        "Variant Code" := ItemCrossReference."Variant Code";
                    end;

                ItemIdentifierType::ItemCrossReference:
                    begin
                        "No." := ItemCrossReference."Item No.";
                        "Variant Code" := ItemCrossReference."Variant Code";
                        "Unit of Measure Code" := ItemCrossReference."Unit of Measure";
                        if (ItemCrossReference."NPR Is Retail Serial No.") then
                            "Serial No. not Created" := ItemCrossReference."Cross-Reference No.";

                    end;

                ItemIdentifierType::SerialNoItemCrossReference:
                    begin

                        SaleLinePOS.Reset;
                        SaleLinePOS.SetFilter(Type, '=%1', SaleLinePOS.Type::Item);
                        SaleLinePOS.SetFilter("Serial No. not Created", '=%1', ItemCrossReference."Cross-Reference No.");
                        if not SaleLinePOS.IsEmpty then
                            exit;

                        "No." := ItemCrossReference."Item No.";
                        "Variant Code" := ItemCrossReference."Variant Code";
                        "Unit of Measure Code" := ItemCrossReference."Unit of Measure";
                        if (ItemCrossReference."NPR Is Retail Serial No.") then
                            "Serial No. not Created" := ItemCrossReference."Cross-Reference No.";
                    end;
            end;

            if (UseSpecificTracking and (ValidatedSerialNumber <> '')) then
                Validate("Serial No.", ValidatedSerialNumber);
            if (not UseSpecificTracking and (InputSerial <> '')) then
                Validate("Serial No.", InputSerial);

            if CustomDescription <> '' then
                Description := CustomDescription;

            if SetUnitPrice then begin
                "Unit Price" := UnitPrice;

                if (Type = Type::Item) then
                    "Initial Group Sale Price" := UnitPrice;
            end;
        end;

        POSSession.GetSaleLine(SaleLine);
        SaleLine.InsertLine(Line);
        AddAccessories(Item, SaleLine);
        AutoExplodeBOM(Item, SaleLine);
        AddItemAddOns(FrontEnd, Item, Line."Line No.");

        POSSession.RequestRefreshData();
    end;

    local procedure AutoExplodeBOM(Item: Record Item; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        BOMComponent: Record "BOM Component";
        SaleLinePOS: Record "NPR Sale Line POS";
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
            AccessorySparePart.SetFilter(Code, '=%1', Item."NPR Item Group");
            if (not AccessorySparePart.IsEmpty()) then
                AddAccessoryForItem(Item, true, POSSaleLine);
        end else
            AddAccessoryForItem(Item, false, POSSaleLine);
    end;

    local procedure AddAccessoryForItem(Item: Record Item; GroupAccessory: Boolean; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        MainSaleLinePOS: Record "NPR Sale Line POS";
        AccessorySaleLinePOS: Record "NPR Sale Line POS";
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
                AccessorySaleLinePOS."Accessories Item Group No." := Item."NPR Item Group";

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
                AccessorySaleLinePOS."Accessories Item Group No." := Item."NPR Item Group";

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
        POSAction.SetWorkflowInvocationParameter('BaseLineNo', BaseLineNo, POSFrontEnd);
        POSFrontEnd.InvokeWorkflow(POSAction);
    end;

    local procedure "-- Serial number support functions"()
    begin
    end;

    local procedure ItemRequiresSerialNumberOnSale(Item: Record Item; var UseSpecificTracking: Boolean) SerialNoRequired: Boolean
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

    local procedure SerialNumberCanBeUsedForItem(var ItemCrossRef: Record "Item Cross Reference"; SerialNumber: Code[20]; var UserInformationErrorWarning: Text) CanBeUsed: Boolean
    var
        Register: Record "NPR Register";
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ItemLedgerEntry: Record "Item Ledger Entry";
        SaleLinePOS: Record "NPR Sale Line POS";
        "Sale POS": Record "NPR Sale POS";
        TextActiveSaved: Text;
    begin
        //Global
        if not Item.Get(ItemCrossRef."Item No.") then exit(false);
        if Item."Item Tracking Code" = '' then exit(false);
        if not ItemTrackingCode.Get(Item."Item Tracking Code") then exit(false);

        UserInformationErrorWarning := '';  //NPR5.55 [398263]

        if not ItemTrackingCode."SN Specific Tracking" then begin
            //No constraint on to what number to use
            CanBeUsed := true;
        end else begin
            //SN Specific Tracking, check for existing not used
            //Check Item Legder Entry
            ItemLedgerEntry.Reset;
            if ItemLedgerEntry.SetCurrentKey(Open, Positive, "Item No.", "Serial No.") then;
            ItemLedgerEntry.SetRange(Open, true);
            ItemLedgerEntry.SetRange(Positive, true);
            ItemLedgerEntry.SetFilter("Serial No.", '=%1', SerialNumber);
            ItemLedgerEntry.SetRange("Item No.", ItemCrossRef."Item No.");
            if ItemCrossRef."Variant Code" <> '' then
                ItemLedgerEntry.SetRange("Variant Code", ItemCrossRef."Variant Code");
            if not ItemLedgerEntry.FindSet then begin
                CanBeUsed := false;
                //Create user information message
                UserInformationErrorWarning := StrSubstNo(TEXTWrongSerialOnILE, SerialNumber, Item."No.", Item.Description, TEXTitemTracking_instructions);  //NPR5.55 [398263]
            end else begin
                CanBeUsed := true;
            end;

            //Check if serial number exists in saved/active pos sale line
            //TO DO: check pos quotes?
            if CanBeUsed then begin
                SaleLinePOS.Reset;
                SaleLinePOS.SetCurrentKey("Serial No.");
                SaleLinePOS.SetFilter(Type, '=%1', SaleLinePOS.Type::Item);
                SaleLinePOS.SetRange("No.", ItemCrossRef."Item No.");
                SaleLinePOS.SetFilter("Serial No.", '=%1', SerialNumber);
                repeat
                    SaleLinePOS.SetRange("Variant Code", ItemLedgerEntry."Variant Code");
                    CanBeUsed := SaleLinePOS.IsEmpty;
                    if CanBeUsed then
                        ItemCrossRef."Variant Code" := ItemLedgerEntry."Variant Code";
                until (ItemLedgerEntry.Next = 0) or CanBeUsed;

                if not CanBeUsed then begin
                    //Create user information message
                    SaleLinePOS.FindFirst;
                    "Sale POS".Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.");
                    if "Sale POS"."Saved Sale" then begin
                        TextActiveSaved := TEXTSaved;
                    end else begin
                        TextActiveSaved := TEXTActive;
                    end;
                    UserInformationErrorWarning := StrSubstNo(TEXTWrongSerialOnSLP, SerialNumber, Item."No.", Item.Description, TextActiveSaved, SaleLinePOS."Sales Ticket No.", SaleLinePOS."Register No.", TEXTitemTracking_instructions);  //NPR5.55 [398263]
                end;
            end;
            if (UserInformationErrorWarning <> '') and not SerialSelectionFromList then
                UserInformationErrorWarning := UserInformationErrorWarning + TEXTWrongSerial_Instr;
        end;

        exit(CanBeUsed);
    end;

    local procedure SelectSerialNoFromList(var ItemCrossRef: Record "Item Cross Reference"; LocationCode: Code[10]; Qty: Decimal; InsertIsBlocked: Boolean; var SerialNo: Text)
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        TrackingSpecification: Record "Tracking Specification" temporary;
        ItemTrackingDataCollection: Codeunit "Item Tracking Data Collection";
    begin
        SaleLinePOS.Init;
        SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Sale;
        SaleLinePOS.Type := SaleLinePOS.Type::Item;
        SaleLinePOS."No." := ItemCrossRef."Item No.";
        SaleLinePOS."Variant Code" := ItemCrossRef."Variant Code";
        SaleLinePOS."Location Code" := LocationCode;
        SaleLinePOS.Quantity := 1;
        if SaleLinePOS.SerialNoLookup2() then begin
            SerialNo := SaleLinePOS."Serial No.";
            ItemCrossRef."Variant Code" := SaleLinePOS."Variant Code";
        end;
    end;

    local procedure "--- Ean Box Event Handling"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    var
        Item: Record Item;
        ItemCrossReference: Record "Item Cross Reference";
    begin
        if not EanBoxEvent.Get(EventCodeItemNo()) then begin
            EanBoxEvent.Init;
            EanBoxEvent.Code := EventCodeItemNo();
            EanBoxEvent."Module Name" := Item.TableCaption;
            EanBoxEvent.Description := CopyStr(ItemCrossReference.FieldCaption("Item No."), 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;

        if not EanBoxEvent.Get(EventCodeItemCrossRef()) then begin
            EanBoxEvent.Init;
            EanBoxEvent.Code := EventCodeItemCrossRef();
            EanBoxEvent."Module Name" := Item.TableCaption;
            EanBoxEvent.Description := CopyStr(ItemCrossReference.TableCaption, 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;

        if not EanBoxEvent.Get(EventCodeItemSearch()) then begin
            EanBoxEvent.Init;
            EanBoxEvent.Code := EventCodeItemSearch();
            EanBoxEvent."Module Name" := Item.TableCaption;
            EanBoxEvent.Description := CopyStr(Item.FieldCaption("Search Description"), 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;

        if not EanBoxEvent.Get(EventCodeSerialNoItemCrossRef()) then begin
            EanBoxEvent.Init;
            EanBoxEvent.Code := EventCodeSerialNoItemCrossRef();
            EanBoxEvent."Module Name" := Item.TableCaption;
            EanBoxEvent.Description := CopyStr(ItemCrossReference.TableCaption, 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "NPR POS Input Box Setup Mgt."; EanBoxEvent: Record "NPR Ean Box Event")
    begin
        case EanBoxEvent.Code of
            EventCodeItemNo():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'itemNo', true, '');
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'itemIdentifyerType', false, 'ItemNo');
                end;
            EventCodeItemCrossRef():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'itemNo', true, '');
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'itemIdentifyerType', false, 'ItemCrossReference');
                end;
            EventCodeItemSearch():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'itemNo', true, '');
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'itemIdentifyerType', false, 'ItemSearch');
                end;
            EventCodeSerialNoItemCrossRef():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'itemNo', true, '');
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'itemIdentifyerType', false, 'SerialNoItemCrossReference');
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060107, 'SetEanBoxEventInScope', '', true, true)]
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

    [EventSubscriber(ObjectType::Codeunit, 6060107, 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeItemCrossRef(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        ItemCrossReference: Record "Item Cross Reference";
    begin
        if EanBoxSetupEvent."Event Code" <> EventCodeItemCrossRef() then
            exit;

        if StrLen(EanBoxValue) > MaxStrLen(ItemCrossReference."Cross-Reference No.") then
            exit;

        ItemCrossReference.SetRange("Cross-Reference No.", UpperCase(EanBoxValue));
        ItemCrossReference.SetRange("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::"Bar Code");
        ItemCrossReference.SetRange("Discontinue Bar Code", false);
        if ItemCrossReference.FindFirst then
            InScope := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060107, 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeItemSearch(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        Item: Record Item;
    begin
        if EanBoxSetupEvent."Event Code" <> EventCodeItemSearch() then
            exit;

        SetItemSearchFilter(EanBoxValue, Item);
        if Item.FindFirst then
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

    local procedure EventCodeItemCrossRef(): Code[20]
    begin
        exit('ITEMCROSSREFERENCENO');
    end;

    local procedure EventCodeItemSearch(): Code[20]
    begin
        exit('ITEMSEARCH');
    end;

    local procedure EventCodeSerialNoItemCrossRef(): Code[20]
    begin
        exit('SERIALNOITEMCROSSREF');
    end;

    local procedure "--- Item Search"()
    begin
    end;

    local procedure GetItemFromItemSearch(var ItemIdentifierString: Text) ItemFound: Boolean
    var
        Item: Record Item;
        ItemList: Page "Item List";
        ItemNo: Code[20];
    begin
        SetItemSearchFilter(ItemIdentifierString, Item);
        if not Item.FindFirst then
            exit(false);

        ItemIdentifierString := Item."No.";
        Item.FindLast;
        if ItemIdentifierString = Item."No." then
            exit(true);
        ItemList.Editable(false);
        ItemList.LookupMode(true);
        ItemList.SetTableView(Item);
        if ItemList.RunModal = ACTION::LookupOK then begin
            ItemList.GetRecord(Item);
            ItemIdentifierString := Item."No.";
            exit(true);
        end else begin
            exit(false);
        end;
    end;

    local procedure SetItemSearchFilter(ItemIdentifierString: Text; var Item: Record Item)
    var
        SearchFilter: Text;
        SearchString: Text;
    begin
        Clear(Item);

        SearchString := CopyStr(ItemIdentifierString, 1, MaxStrLen(Item."Search Description"));
        SearchString := UpperCase(SearchString);
        SearchFilter := '*' + SearchString + '*';
        if ItemIdentifierString = '' then
            SearchFilter := StrSubstNo('=%1', '');

        Item.SetCurrentKey("Search Description");
        Item.SetFilter("Search Description", SearchFilter);
        Item.SetRange(Blocked, false);
        Item.SetRange("NPR Blocked on Pos", false);
    end;
}