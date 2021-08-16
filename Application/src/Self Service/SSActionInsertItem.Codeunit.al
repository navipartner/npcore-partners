codeunit 6151289 "NPR SS Action: Insert Item"
{
    var
        TEXTActive: Label 'active';
        ERROR_ITEMSEARCH: Label 'Could not find a matching item for input %1';
        EnterQuantityCaption: Label 'Enter Quantity';
        TEXTWrongSerialOnILE: Label 'Serial number %1 for item %2 - %3 can not be used since it can not be found as received. \Press OK to re-enter serial number now. \Press Cancel to enter serial number later.\';
        TEXTWrongSerialOnSLP: Label 'Serial number %1 for item %2 - %3 can not be used since it is already on %4 sale %5 on register %6. \Press OK to re-enter serial number now. \Press Cancel to enter serial number later.\''';
        ValidRangeText: Label 'The valid range is %1 to %2.';
        ActionDescription: Label 'This is a built-in action for self-service, inserting an item line into the current transaction';
        ReadingErr: Label 'reading in %1 of %2';
        SettingScopeErr: Label 'setting scope in %1';

    local procedure ActionCode(): Text[20]
    begin
        exit('SS-ITEM');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('2.6');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin

        if Sender.DiscoverAction20(
          ActionCode(),
          ActionDescription,
          ActionVersion())
        then begin

            Sender.RegisterWorkflow20(
              'let workflowstep = "AddSalesLine";' +
              'let qtyDialogThreshold = 9;' +
              'let qtyMax = 100;' +
              'let qtyMin = $parameters.minimumAllowedQuantity || 1;' +

              'if ($context.hasOwnProperty ("_additionalContext")) {' +
              '  if ($context._additionalContext.hasOwnProperty("plusMinus"))' +
              '    workflowstep = ($context._additionalContext.quantity > 0) ? "IncreaseQuantity" : "DecreaseQuantity";' +

              '  const salesline = runtime.getData("BUILTIN_SALELINE");' +
              '  let row = salesline.find(r => r[6] === $parameters.itemNo) || null;' +
              '  console.log ("Searching for item: " +$parameters.itemNo+" found row: "+ JSON.stringify (row));' +
              '  if ((row != null) &&' +
              '      ((row[12] >= qtyDialogThreshold) && ($context._additionalContext.quantity > 0) ||' +
              '       (row[12] >  qtyDialogThreshold) && ($context._additionalContext.quantity < 0))' +
              '     ) {' +
              '     let quantity = ($context._additionalContext.quantity > 0) ? row[12] + 1 : row[12] - 1;' +
              '     $context.specificQuantity = await popup.intpad ({title: $captions.EnterQuantityCaption, caption: $captions.EnterQuantityCaption, value: quantity});' +
              '     if ($context.specificQuantity === null) {return;} ' +
              '     if (parseInt ($context.specificQuantity) > qtyMax || parseInt ($context.specificQuantity) < qtyMin) {' +
              '       await popup.message ({title: $captions.EnterQuantityCaption, caption: $captions.ValidRangeText.substitute (qtyMin, qtyMax)});' +
              '       return;' +
              '     } ' +
              '     workflowstep = "SetSpecificQuantity";' +
              '  }' +

              '}' +

              'await (workflow.respond (workflowstep));'
              );

            Sender.RegisterOptionParameter('itemIdentifyerType', 'ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference', 'ItemNo');
            Sender.RegisterTextParameter('itemNo', '');
            Sender.RegisterDecimalParameter('itemQuantity', 1);
            Sender.RegisterBooleanParameter('descriptionEdit', false);
            Sender.RegisterBooleanParameter('usePreSetUnitPrice', false);
            Sender.RegisterDecimalParameter('preSetUnitPrice', 0);
            Sender.RegisterDecimalParameter('minimumAllowedQuantity', 1);
            Sender.RegisterBlockingUI(false);
            Sender.SetWorkflowTypeUnattended();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        case WorkflowStep of
            'itemTrackingForce':
                Step_ItemTracking(Context, FrontEnd);
            'AddSalesLine':
                Step_AddSalesLine(Context, POSSession, FrontEnd);
            'IncreaseQuantity':
                Step_IncreaseQuantity(Context, POSSession, FrontEnd);
            'DecreaseQuantity':
                Step_DecreaseQuantity(Context, POSSession);
            'SetSpecificQuantity':
                Step_SetQuantity(Context, POSSession, FrontEnd);
        end;


        POSSession.RequestRefreshData();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'EnterQuantityCaption', EnterQuantityCaption);
        Captions.AddActionCaption(ActionCode(), 'ValidRangeText', ValidRangeText);
    end;

    local procedure Step_AddSalesLine(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        UsePresetUnitPrice: Boolean;
        ItemQuantity: Decimal;
        ItemMinQuantity: Decimal;
        PresetUnitPrice: Decimal;
        ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch;
        ItemIdentifier: Text;
    begin
        JSON.GetBoolean('promptPrice');
        JSON.GetBoolean('promptSerial');

        JSON.SetScopeParameters(ActionCode());
        ItemIdentifier := JSON.GetStringOrFail('itemNo', StrSubstNo(ReadingErr, 'Step_AddSalesLine', ActionCode()));
        ItemIdentifierType := JSON.GetInteger('itemIdentifyerType');
        ItemQuantity := JSON.GetDecimal('itemQuantity');
        ItemMinQuantity := JSON.GetDecimal('minimumAllowedQuantity');
        UsePresetUnitPrice := JSON.GetBoolean('usePreSetUnitPrice');
        PresetUnitPrice := JSON.GetDecimal('preSetUnitPrice');

        if ItemIdentifierType < 0 then
            ItemIdentifierType := 0;

        GetItem(Item, ItemReference, ItemIdentifier, ItemIdentifierType);

        if (ItemMinQuantity > 0) and (ItemQuantity < ItemMinQuantity) then
            ItemQuantity := ItemMinQuantity;

        AddItemLine(Item, ItemReference, ItemIdentifierType, ItemQuantity, UsePresetUnitPrice, PresetUnitPrice, JSON, POSSession, FrontEnd);
    end;

    local procedure Step_ItemTracking(JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        SerialNumberInput: Text[20];
        ItemNo: Code[20];
        UserInformationErrorWarning: Text;
    begin
        JSON.SetScope('$itemTrackingForce', StrSubstNo(SettingScopeErr, ActionCode()));
        SerialNumberInput := CopyStr(JSON.GetStringOrFail('input', StrSubstNo(ReadingErr, 'Step_AddItemTracking', ActionCode())), 1, MaxStrLen(SerialNumberInput));

        JSON.SetScopeRoot();
        JSON.SetScopeParameters(ActionCode());
        ItemNo := CopyStr(JSON.GetStringOrFail('itemNo', StrSubstNo(ReadingErr, 'Step_ItemTracking', ActionCode())), 1, MaxStrLen(ItemNo));

        if not SerialNumberCanBeUsedForItem(ItemNo, SerialNumberInput, UserInformationErrorWarning) then begin
            SerialNumberInput := '';

            JSON.SetScopeRoot();
            JSON.SetContext('itemTracking_instructions', UserInformationErrorWarning);
            FrontEnd.SetActionContext(ActionCode(), JSON);
            FrontEnd.ContinueAtStep('itemTrackingForce');
            exit;
        end;

        JSON.SetScopeRoot();
        JSON.SetContext('validatedSerialNumber', SerialNumberInput);

        FrontEnd.SetActionContext(ActionCode(), JSON);
        exit;
    end;

    local procedure Step_DecreaseQuantity(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        ItemIdentifier: Text;
        ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch;
        ItemQuantity: Decimal;
        ItemMinQuantity: Decimal;
    begin
        JSON.SetScopeParameters(ActionCode());
        ItemIdentifier := JSON.GetStringOrFail('itemNo', StrSubstNo(ReadingErr, 'Step_DecreaseQuantity', ActionCode()));
        ItemIdentifierType := JSON.GetInteger('itemIdentifyerType');
        ItemQuantity := JSON.GetDecimal('itemQuantity');
        ItemMinQuantity := JSON.GetDecimal('minimumAllowedQuantity');

        if ItemIdentifierType < 0 then
            ItemIdentifierType := 0;

        GetItem(Item, ItemReference, ItemIdentifier, ItemIdentifierType);
        RemoveQuantityFromItemLine(Item, ItemQuantity, ItemMinQuantity, POSSession);
    end;

    local procedure Step_IncreaseQuantity(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        ItemQuantity: Decimal;
        ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch;
        ItemIdentifier: Text;
    begin
        JSON.SetScopeParameters(ActionCode());
        ItemIdentifier := JSON.GetStringOrFail('itemNo', StrSubstNo(ReadingErr, 'Step_IncreaseQuantity', ActionCode()));
        ItemIdentifierType := JSON.GetInteger('itemIdentifyerType');
        ItemQuantity := JSON.GetDecimal('itemQuantity');
        JSON.GetDecimal('minimumAllowedQuantity');
        JSON.SetScopeRoot();

        if ItemIdentifierType < 0 then
            ItemIdentifierType := 0;

        GetItem(Item, ItemReference, ItemIdentifier, ItemIdentifierType);
        if (not AddQuantityToItemLine(Item, ItemQuantity, POSSession)) then
            Step_AddSalesLine(JSON, POSSession, FrontEnd);

    end;

    local procedure Step_SetQuantity(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        ItemIdentifier: Text;
        ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch;
        ItemQuantity: Decimal;
    begin
        JSON.SetScopeParameters(ActionCode());
        ItemIdentifier := JSON.GetStringOrFail('itemNo', StrSubstNo(ReadingErr, 'Step_SetQuantity', ActionCode()));
        ItemIdentifierType := JSON.GetInteger('itemIdentifyerType');
        JSON.SetScopeRoot();
        ItemQuantity := JSON.GetDecimal('specificQuantity');

        if ItemIdentifierType < 0 then
            ItemIdentifierType := 0;

        GetItem(Item, ItemReference, ItemIdentifier, ItemIdentifierType);
        if (not SetQuantityToItemLine(Item, ItemReference, ItemIdentifierType, ItemQuantity, JSON, POSSession, FrontEnd)) then
            Step_AddSalesLine(JSON, POSSession, FrontEnd);

    end;

    #region Various support functions

    local procedure GetItem(var Item: Record Item; var ItemReference: Record "Item Reference"; ItemIdentifier: Text; ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference)
    var
        FirstRec: Text;
        TagId: Text;
    begin
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

                    TagId := CopyStr(ItemIdentifier, 5);

                    ItemReference.SetFilter("Reference No.", '=%1', CopyStr(TagId, 1, MaxStrLen(ItemReference."Reference No.")));
                    ItemReference.SetFilter("Reference Type", '=%1', ItemReference."Reference Type"::"Retail Serial No.");
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
    end;

    local procedure AddItemLine(Item: Record Item; ItemReference: Record "Item Reference"; ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference; ItemQuantity: Decimal; UsePresetUnitPrice: Boolean; PresetUnitPrice: Decimal; JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Line: Record "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLine: Codeunit "NPR POS Sale Line";
        SetUnitPrice: Boolean;
        UseSpecificTracking: Boolean;
        InputSerial: Text;
        ValidatedSerialNumber: Text;
        UnitPrice: Decimal;
        CustomDescription: Text;
    begin
        JSON.SetScopeRoot();
        UseSpecificTracking := JSON.GetBoolean('useSpecificTracking');
        ValidatedSerialNumber := JSON.GetString('validatedSerialNumber');

        if UsePresetUnitPrice then begin
            UnitPrice := PresetUnitPrice;
            SetUnitPrice := true;
        end else begin
            JSON.SetScopeRoot();
            if (JSON.SetScope('$unitPrice')) then begin
                UnitPrice := JSON.GetDecimalOrFail('numpad', StrSubstNo(ReadingErr, 'AddItemLine', ActionCode()));
                SetUnitPrice := true;
            end;
        end;

        JSON.SetScopeRoot();
        if JSON.SetScope('$itemTrackingOptional') then
            InputSerial := JSON.GetString('input');

        JSON.SetScopeRoot();
        if JSON.SetScope('$editDescription') then
            CustomDescription := JSON.GetString('input');

        if ItemQuantity = 0 then
            ItemQuantity := 1;

        Line.Type := Line.Type::Item;
        Line.Quantity := ItemQuantity;

        case ItemIdentifierType of
            ItemIdentifierType::ItemSearch,
            ItemIdentifierType::ItemNo:
                begin
                    Line."No." := Item."No.";
                end;

            ItemIdentifierType::ItemCrossReference:
                begin
                    Line."No." := ItemReference."Item No.";
                    Line."Variant Code" := ItemReference."Variant Code";
                    Line."Unit of Measure Code" := ItemReference."Unit of Measure";
                    if (ItemReference."Reference Type" = ItemReference."Reference Type"::"Retail Serial No.") then
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
                    if (ItemReference."Reference Type" = ItemReference."Reference Type"::"Retail Serial No.") then
                        Line."Serial No. not Created" := ItemReference."Reference No.";
                end;
        end;

        if (UseSpecificTracking and (ValidatedSerialNumber <> '')) then
            Line.Validate("Serial No.", CopyStr(ValidatedSerialNumber, 1, MaxStrLen(Line."Serial No.")));
        if (not UseSpecificTracking and (InputSerial <> '')) then
            Line.Validate("Serial No.", CopyStr(InputSerial, 1, MaxStrLen(Line."Serial No.")));

        if CustomDescription <> '' then
            Line.Description := CopyStr(CustomDescription, 1, MaxStrLen(Line.Description));

        if SetUnitPrice then begin
            Line."Unit Price" := UnitPrice;

            if (Line.Type = Line.Type::Item) then
                Line."Initial Group Sale Price" := UnitPrice;
        end;

        POSSession.GetSaleLine(SaleLine);
        SaleLine.InsertLine(Line);
        AddAccessories(Item, SaleLine);
        AutoExplodeBOM(Item, SaleLine);
        AddItemAddOns(FrontEnd, Item);

        POSSession.RequestRefreshData();
    end;

    local procedure AddQuantityToItemLine(Item: Record Item; ItemQuantity: Decimal; POSSession: Codeunit "NPR POS Session"): Boolean
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SSActionQtyIncrease: Codeunit "NPR SS Action - Qty Increase";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetFilter("No.", '=%1', Item."No.");
        SaleLinePOS.SetFilter(Quantity, '>=%1', ItemQuantity);
        if (not SaleLinePOS.FindFirst()) then
            exit(false);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetPosition(SaleLinePOS.GetPosition());

        SSActionQtyIncrease.IncreaseSalelineQuantity(POSSession, ItemQuantity);

        POSSession.RequestRefreshData();
        exit(true);
    end;

    local procedure RemoveQuantityFromItemLine(Item: Record Item; ItemQuantity: Decimal; ItemMinQuantity: Decimal; POSSession: Codeunit "NPR POS Session")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SSActionDeletePOSLine: Codeunit "NPR SS Action: Delete POS Line";
        SSActionQtyDecrease: Codeunit "NPR SS Action - Qty Decrease";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetFilter("No.", '=%1', Item."No.");
        SaleLinePOS.SetFilter(Quantity, '>=%1', ItemQuantity);
        if (not SaleLinePOS.FindFirst()) then
            exit;

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetPosition(SaleLinePOS.GetPosition());

        if SaleLinePOS.Quantity - Abs(ItemQuantity) < ItemMinQuantity then begin
            SSActionDeletePOSLine.DeletePosLine(POSSession);
        end else begin
            SSActionQtyDecrease.DecreaseSalelineQuantity(POSSession, Abs(ItemQuantity));
        end;

        POSSession.RequestRefreshData();
    end;

    procedure SetQuantityToItemLine(Item: Record Item; ItemReference: Record "Item Reference"; ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference; ItemQuantity: Decimal; JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"): Boolean
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetFilter("No.", '=%1', Item."No.");
        SaleLinePOS.SetFilter(Quantity, '>=%1', 1);
        if (not SaleLinePOS.FindFirst()) then
            exit(false);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetPosition(SaleLinePOS.GetPosition());

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        POSSaleLine.SetQuantity(ItemQuantity);

        POSSession.RequestRefreshData();
        exit(true);
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

            POSSaleLine.InsertLine(AccessorySaleLinePOS);

            if AccessorySparePart."Use Alt. Price" then begin
                if (AccessorySaleLinePOS."Price Includes VAT") and (not Item."Price Includes VAT") then
                    AccessorySparePart."Alt. Price" := AccessorySparePart."Alt. Price" * (1 + (AccessorySaleLinePOS."VAT %" / 100))
                else
                    if (not AccessorySaleLinePOS."Price Includes VAT") and (Item."Price Includes VAT") then
                        AccessorySparePart."Alt. Price" := AccessorySparePart."Alt. Price" / (1 + (AccessorySaleLinePOS."VAT %" / 100));

                if AccessorySparePart."Show Discount" then
                    AccessorySaleLinePOS.Validate("Amount Including VAT", AccessorySparePart."Alt. Price")
                else
                    AccessorySaleLinePOS.Validate("Unit Price", AccessorySparePart."Alt. Price");
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

    local procedure AddItemAddOns(POSFrontEnd: Codeunit "NPR POS Front End Management"; Item: Record Item)
    var
        POSAction: Record "NPR POS Action";
    begin
        if Item."NPR Item AddOn No." = '' then
            exit;

        POSAction.Get('SS-ITEM-ADDON');
        POSFrontEnd.InvokeWorkflow(POSAction);
    end;
    #endregion
    #region Serial number support functions

    local procedure SerialNumberCanBeUsedForItem(ItemNo: Code[20]; SerialNumber: Code[20]; var UserInformationErrorWarning: Text) CanBeUsed: Boolean
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ItemLedgerEntry: Record "Item Ledger Entry";
        SaleLinePOS: Record "NPR POS Sale Line";
        "Sale POS": Record "NPR POS Sale";
        TextActiveSaved: Text;
    begin
        //Global
        if not Item.Get(ItemNo) then exit(false);
        if Item."Item Tracking Code" = '' then exit(false);
        if not ItemTrackingCode.Get(Item."Item Tracking Code") then exit(false);

        if not ItemTrackingCode."SN Specific Tracking" then begin
            //No constraint on to what number to use
            CanBeUsed := true;
        end else begin
            //SN Specific Tracking, check for existing not used
            //Check Item Legder Entry
            ItemLedgerEntry.Reset();
            if ItemLedgerEntry.SetCurrentKey(Open, Positive, "Item No.", "Serial No.") then;
            ItemLedgerEntry.SetRange(Open, true);
            ItemLedgerEntry.SetRange(Positive, true);
            ItemLedgerEntry.SetFilter("Serial No.", '=%1', SerialNumber);
            ItemLedgerEntry.SetRange("Item No.", ItemNo);
            if ItemLedgerEntry.IsEmpty then begin
                CanBeUsed := false;
                //Create user information message
                UserInformationErrorWarning := StrSubstNo(TEXTWrongSerialOnILE, SerialNumber, ItemNo, Item.Description);
            end else begin
                CanBeUsed := true;
            end;
        end;


        //Check if serial number exists in saved/active pos sale line
        if ItemTrackingCode."SN Specific Tracking" then begin
            SaleLinePOS.Reset();
            SaleLinePOS.SetCurrentKey("Serial No.");
            SaleLinePOS.SetFilter(Type, '=%1', SaleLinePOS.Type::Item);
            SaleLinePOS.SetFilter("No.", '=%1', ItemNo);
            SaleLinePOS.SetFilter("Serial No.", '=%1', SerialNumber);
            if not SaleLinePOS.IsEmpty then begin
                CanBeUsed := false;
                //Create user information message
                SaleLinePOS.FindFirst();
                "Sale POS".Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.");
                TextActiveSaved := TEXTActive;
                UserInformationErrorWarning := StrSubstNo(TEXTWrongSerialOnSLP, SerialNumber, ItemNo, Item.Description, TextActiveSaved, SaleLinePOS."Sales Ticket No.", SaleLinePOS."Register No.");

            end;
        end;

        exit(CanBeUsed);
    end;
    #endregion
    #region Ean Box Event Handling
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
        if ItemReference.FindFirst() then
            InScope := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Evt Handler", 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeItemSearch(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        Item: Record Item;
    begin
        if EanBoxSetupEvent."Event Code" <> EventCodeItemSearch() then
            exit;

        SetItemSearchFilter(EanBoxValue, Item);
        if Item.FindFirst() then
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
    #endregion

    #region Item Search
    local procedure GetItemFromItemSearch(var ItemIdentifierString: Text): Boolean
    var
        Item: Record Item;
        ItemList: Page "Item List";
    begin
        SetItemSearchFilter(ItemIdentifierString, Item);
        if not Item.FindFirst() then
            exit(false);

        ItemIdentifierString := Item."No.";
        Item.FindLast();
        if ItemIdentifierString = Item."No." then
            exit(true);
        ItemList.Editable(false);
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

    local procedure SetItemSearchFilter(ItemIdentifierString: Text; var Item: Record Item)
    var
        SearchFilter: Text;
        SearchString: Text;
        SearchFilterLbl: Label '=%1', Locked = true;
    begin
        Clear(Item);

        SearchString := CopyStr(ItemIdentifierString, 1, MaxStrLen(Item."Search Description"));
        SearchString := UpperCase(SearchString);
        SearchFilter := '*' + SearchString + '*';
        if ItemIdentifierString = '' then
            SearchFilter := StrSubstNo(SearchFilterLbl, '');

        Item.SetCurrentKey("Search Description");
        Item.SetFilter("Search Description", SearchFilter);
        Item.SetRange(Blocked, false);
    end;
    #endregion
}
