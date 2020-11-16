codeunit 6151289 "NPR SS Action: Insert Item"
{
    // NPR5.54/TSA /20200220 CASE 387912 Initial Version of SS-ITEM for Self Service. Starts out as a copy if ITEM
    // NPR5.55/TSA /20200420 CASE 364420 Added implementation for +/- button
    // NPR5.55/MMV /20200420 CASE 386254 Set blocking UI to false.
    // NPR5.55/TSA /20200508 CASE 403784 Added feature to specify quantity in dialog after threshold has been reached
    // NPR5.55/TSA /20200520 CASE 405186 Added/reworked localization


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built-in action for self-service, inserting an item line into the current transaction';
        TEXTitemTracking_title: Label 'Enter Serial Number';
        TEXTitemTracking_lead: Label 'This item requires serial number, enter serial number.';
        Setup: Codeunit "NPR POS Setup";
        TEXTitemTracking_instructions: Label 'Enter serial number now and press OK. Press Cancel to enter serial number later.';
        TEXTActive: Label 'active';
        TEXTSaved: Label 'saved';
        TEXTWrongSerialOnILE: Label 'Serial number %1 for item %2 - %3 can not be used since it can not be found as received. \Press OK to re-enter serial number now. \Press Cancel to enter serial number later.\';
        TEXTWrongSerialOnSLP: Label 'Serial number %1 for item %2 - %3 can not be used since it is already on %4 sale %5 on register %6. \Press OK to re-enter serial number now. \Press Cancel to enter serial number later.\''';
        UnitPriceCaption: Label 'This is item is an item group. Specify the unit price for item.';
        UnitPriceTitle: Label 'Unit price is required';
        TEXTeditDesc_lead: Label 'Line description';
        TEXTeditDesc_title: Label 'Add or change description.';
        ERROR_ITEMSEARCH: Label 'Could not find a matching item for input %1';
        EnterQuantityCaption: Label 'Enter Quantity';
        ValidRangeText: Label 'The valid range is %1 to %2.';

    local procedure ActionCode(): Text
    begin
        exit('SS-ITEM');
    end;

    local procedure ActionVersion(): Text
    begin

        exit('2.5');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    var
        itemTrackingCode: Text;
    begin

        with Sender do
            if DiscoverAction20(
              ActionCode,
              ActionDescription,
              ActionVersion())
            then begin

                RegisterWorkflow20(
                  'let workflowstep = "AddSalesLine";' +
                  'let qtyDialogThreshold = 9;' +
                  'let qtyMax = 100;' +
                  'let qtyMin = 1;' +

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
                  // 'await (workflowList = workflow.respond("getExtraItemWorkflows"));'
                  );

                RegisterOptionParameter('itemIdentifyerType', 'ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference', 'ItemNo');
                RegisterTextParameter('itemNo', '');
                RegisterDecimalParameter('itemQuantity', 1);
                RegisterBooleanParameter('descriptionEdit', false);
                RegisterBooleanParameter('usePreSetUnitPrice', false);
                RegisterDecimalParameter('preSetUnitPrice', 0);
                //-NPR5.55 [386254]
                RegisterBlockingUI(false);
                //+NPR5.55 [386254]
                SetWorkflowTypeUnattended();
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150733, 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;

        case WorkflowStep of
            'itemTrackingForce':
                Step_ItemTracking(Context, POSSession, FrontEnd);
            'AddSalesLine':
                Step_AddSalesLine(Context, POSSession, FrontEnd);
            'IncreaseQuantity':
                Step_IncreaseQuantity(Context, POSSession, FrontEnd); //-+NPR5.55 [364420]
            'DecreaseQuantity':
                Step_DecreaseQuantity(Context, POSSession, FrontEnd); //-+NPR5.55 [364420]
            'SetSpecificQuantity':
                Step_SetQuantity(Context, POSSession, FrontEnd); //-+NPR5.55 [403784]
                                                                 //'getExtraItemWorkflows': Step_GetWorkflowList (Contex, POSSession, FrontEnd);
        end;


        POSSession.RequestRefreshData();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    var
        UI: Codeunit "NPR POS UI Management";
    begin
        //-NPR5.55 [405186]
        // Captions.AddActionCaption (ActionCode, 'itemTracking_title', TEXTitemTracking_title);
        // Captions.AddActionCaption (ActionCode, 'itemTracking_lead', TEXTitemTracking_lead);
        // Captions.AddActionCaption (ActionCode, 'UnitpriceTitle', UnitPriceTitle);
        // Captions.AddActionCaption (ActionCode, 'UnitpriceCaption', UnitPriceCaption);
        // Captions.AddActionCaption (ActionCode, 'editDesc_title', TEXTeditDesc_title);
        // Captions.AddActionCaption (ActionCode, 'editDesc_lead', TEXTeditDesc_title);

        Captions.AddActionCaption(ActionCode, 'EnterQuantityCaption', EnterQuantityCaption);
        Captions.AddActionCaption(ActionCode, 'ValidRangeText', ValidRangeText);
        //+NPR5.55 [405186]
    end;

    local procedure Step_AddSalesLine(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        UseSpecificTracking: Boolean;
        InputSerial: Code[20];
        UnitPrice: Decimal;
        ItemIdentifier: Text;
        ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch;
        Item: Record Item;
        ItemCrossReference: Record "Item Cross Reference";
        ItemQuantity: Decimal;
        HasPrompted: Boolean;
        UsePresetUnitPrice: Boolean;
        PresetUnitPrice: Decimal;
        DialogContext: Codeunit "NPR POS JSON Management";
        DialogPrompt: Boolean;
    begin
        //-NPR5.40 [294655]


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

        //-NPR5.55 [364420]
        // IF NOT HasPrompted THEN BEGIN
        //  IF Item."Group sale" AND (NOT UsePresetUnitPrice)THEN BEGIN
        //    DialogContext.SetContext('promptPrice', TRUE);
        //    DialogPrompt := TRUE;
        //  END;
        //
        //  IF ItemRequiresSerialNumberOnSale(Item, UseSpecificTracking) THEN BEGIN
        //    DialogContext.SetContext('promptSerial', TRUE);
        //    DialogContext.SetContext('itemTracking_instructions',TEXTitemTracking_instructions);
        //    DialogContext.SetContext('useSpecificTracking', UseSpecificTracking);
        //    DialogPrompt := TRUE;
        //  END;
        //
        //  IF DialogPrompt THEN BEGIN
        //    FrontEnd.SetActionContext(ActionCode, DialogContext);
        //    FrontEnd.ContinueAtStep('promptContextDialogs');
        //    EXIT;
        //  END;
        // END;
        //+NPR5.55 [364420]

        AddItemLine(Item, ItemCrossReference, ItemIdentifierType, ItemQuantity, UsePresetUnitPrice, PresetUnitPrice, JSON, POSSession, FrontEnd);
        //+NPR5.40 [294655]
    end;

    local procedure Step_ItemTracking(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        SerialNumberInput: Text;
        SpecificTracking: Boolean;
        ItemNo: Code[20];
        OKInput: Boolean;
        SerialNoUsedOnPOSSaleLine: Boolean;
        UserInformationErrorWarning: Text;
    begin
        //Called on OK when serial number is filled on item witch requires specific tracking on serial number.

        JSON.SetScope('$itemTrackingForce', true);
        SerialNumberInput := JSON.GetString('input', true);

        JSON.SetScopeRoot(true);
        JSON.SetScope('parameters', true);
        ItemNo := JSON.GetString('itemNo', true);

        //Some number is inputed, now check if valid for item
        if not SerialNumberCanBeUsedForItem(ItemNo, SerialNumberInput, UserInformationErrorWarning) then begin
            SerialNumberInput := '';
            //Serial number is not valid, lets reask
            JSON.SetScope('/', true);
            JSON.SetContext('itemTracking_instructions', UserInformationErrorWarning);
            //-NPR5.40 [294655]
            FrontEnd.SetActionContext(ActionCode, JSON);
            FrontEnd.ContinueAtStep('itemTrackingForce');
            //  JSON.SetContext('reask',TRUE);
            //  FrontEnd.SetActionContext (ActionCode, JSON);
            //+NPR5.40 [294655]
            exit;
        end;

        //Serial number is validated correct and should be applied to line
        //Applying is done in finalize
        JSON.SetScope('/', true);
        JSON.SetContext('validatedSerialNumber', SerialNumberInput);

        FrontEnd.SetActionContext(ActionCode, JSON);
        exit;

        POSSession.RequestRefreshData();
    end;

    local procedure Step_DecreaseQuantity(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Item: Record Item;
        ItemCrossReference: Record "Item Cross Reference";
        ItemIdentifier: Text;
        ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch;
        ItemQuantity: Decimal;
    begin
        //-NPR5.55 [364420]õ
        JSON.SetScope('parameters', true);
        ItemIdentifier := JSON.GetString('itemNo', true);
        ItemIdentifierType := JSON.GetInteger('itemIdentifyerType', false);
        ItemQuantity := JSON.GetDecimal('itemQuantity', false);

        if ItemIdentifierType < 0 then
            ItemIdentifierType := 0;

        GetItem(Item, ItemCrossReference, ItemIdentifier, ItemIdentifierType);
        RemoveQuantityFromItemLine(Item, ItemCrossReference, ItemIdentifierType, ItemQuantity, JSON, POSSession, FrontEnd);

        //+NPR5.55 [364420]
    end;

    local procedure Step_IncreaseQuantity(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Item: Record Item;
        ItemCrossReference: Record "Item Cross Reference";
        ItemIdentifier: Text;
        ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch;
        ItemQuantity: Decimal;
    begin

        //-NPR5.55 [364420]õ
        JSON.SetScope('parameters', true);
        ItemIdentifier := JSON.GetString('itemNo', true);
        ItemIdentifierType := JSON.GetInteger('itemIdentifyerType', false);
        ItemQuantity := JSON.GetDecimal('itemQuantity', false);
        JSON.SetScopeRoot(false);

        if ItemIdentifierType < 0 then
            ItemIdentifierType := 0;

        GetItem(Item, ItemCrossReference, ItemIdentifier, ItemIdentifierType);
        if (not AddQuantityToItemLine(Item, ItemCrossReference, ItemIdentifierType, ItemQuantity, JSON, POSSession, FrontEnd)) then
            Step_AddSalesLine(JSON, POSSession, FrontEnd);

        //+NPR5.55 [364420]
    end;

    local procedure Step_SetQuantity(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Item: Record Item;
        ItemCrossReference: Record "Item Cross Reference";
        ItemIdentifier: Text;
        ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch;
        ItemQuantity: Decimal;
    begin

        //-NPR5.55 [403784]
        JSON.SetScope('parameters', true);
        ItemIdentifier := JSON.GetString('itemNo', true);
        ItemIdentifierType := JSON.GetInteger('itemIdentifyerType', false);
        JSON.SetScopeRoot(false);
        ItemQuantity := JSON.GetDecimal('specificQuantity', false);

        if ItemIdentifierType < 0 then
            ItemIdentifierType := 0;

        GetItem(Item, ItemCrossReference, ItemIdentifier, ItemIdentifierType);
        if (not SetQuantityToItemLine(Item, ItemCrossReference, ItemIdentifierType, ItemQuantity, JSON, POSSession, FrontEnd)) then
            Step_AddSalesLine(JSON, POSSession, FrontEnd);

        //+NPR5.55 [403784]
    end;

    local procedure "-- Various support functions"()
    begin
    end;

    local procedure GetItem(var Item: Record Item; var ItemCrossReference: Record "Item Cross Reference"; ItemIdentifier: Text; ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference)
    var
        FirstRec: Text;
        TagId: Code[20];
    begin
        //-NPR5.40 [294655]
        case ItemIdentifierType of
            ItemIdentifierType::ItemNo:
                Item.Get(ItemIdentifier);

            ItemIdentifierType::ItemCrossReference:
                begin
                    ItemCrossReference.SetFilter("Cross-Reference No.", '=%1', CopyStr(ItemIdentifier, 1, MaxStrLen(ItemCrossReference."Cross-Reference No.")));
                    ItemCrossReference.SetFilter("Cross-Reference Type", '=%1', ItemCrossReference."Cross-Reference Type"::"Bar Code");
                    ItemCrossReference.SetFilter("Discontinue Bar Code", '=%1', false);
                    ItemCrossReference.FindFirst;
                    //-NPR5.48 [334329]
                    FirstRec := Format(ItemCrossReference);
                    ItemCrossReference.FindLast;
                    if FirstRec <> Format(ItemCrossReference) then begin
                        if PAGE.RunModal(0, ItemCrossReference) <> ACTION::LookupOK then
                            Error('');
                    end;
                    //+NPR5.48 [334329]
                    Item.Get(ItemCrossReference."Item No.");
                end;

            ItemIdentifierType::ItemSearch:
                if GetItemFromItemSearch(ItemIdentifier) then
                    Item.Get(ItemIdentifier)
                else
                    Error(ERROR_ITEMSEARCH, ItemIdentifier);

            //-NPR5.52 [369231]
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
        //+NPR5.52 [369231]
        end;
        //+NPR5.40 [294655]
    end;

    local procedure AddItemLine(Item: Record Item; ItemCrossReference: Record "Item Cross Reference"; ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference; ItemQuantity: Decimal; UsePresetUnitPrice: Boolean; PresetUnitPrice: Decimal; JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Line: Record "NPR Sale Line POS";
        SaleLine: Codeunit "NPR POS Sale Line";
        ValidatedSerialNumber: Code[20];
        UseSpecificTracking: Boolean;
        InputSerial: Code[20];
        UnitPrice: Decimal;
        CustomDescription: Text;
        SetUnitPrice: Boolean;
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        //-NPR5.40 [294655]

        JSON.SetScope('/', true);
        UseSpecificTracking := JSON.GetBoolean('useSpecificTracking', false);
        ValidatedSerialNumber := JSON.GetString('validatedSerialNumber', false);

        if UsePresetUnitPrice then begin
            UnitPrice := PresetUnitPrice;
            SetUnitPrice := true;
        end else begin
            JSON.SetScopeRoot(true);
            if (JSON.SetScope('$unitPrice', false)) then begin
                UnitPrice := JSON.GetDecimal('numpad', true);
                SetUnitPrice := true;
            end;
        end;

        JSON.SetScopeRoot(true);
        if JSON.SetScope('$itemTrackingOptional', false) then
            InputSerial := JSON.GetString('input', false);

        JSON.SetScopeRoot(true);
        if JSON.SetScope('$editDescription', false) then
            CustomDescription := JSON.GetString('input', false);

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
                    end;

                ItemIdentifierType::ItemCrossReference:
                    begin
                        "No." := ItemCrossReference."Item No.";
                        "Variant Code" := ItemCrossReference."Variant Code";
                        "Unit of Measure Code" := ItemCrossReference."Unit of Measure";
                        //-NPR5.52 [369231]
                        if (ItemCrossReference."NPR Is Retail Serial No.") then
                            "Serial No. not Created" := ItemCrossReference."Cross-Reference No.";
                        //+NPR5.52 [369231]

                        //-NPR5.49 [350410]
                        // //-NPR5.48 [335967]
                        // Description := ItemCrossReference.Description;
                        // //+NPR5.48 [335967]
                        //+NPR5.49 [350410]

                    end;
                //-NPR5.52 [369231]
                ItemIdentifierType::SerialNoItemCrossReference:
                    begin

                        SaleLinePOS.Reset;
                        //SaleLinePOS.SETCURRENTKEY("Serial No.");
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
            //+NPR5.52 [369231]
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
        //-NPR5.45 [324395]
        AutoExplodeBOM(Item, SaleLine);
        //+NPR5.45 [324395]
        AddItemAddOns(FrontEnd, Item, Line."Line No.");  //NPR5.54 [388951]

        POSSession.RequestRefreshData();
        //+NPR5.40 [294655]
    end;

    procedure AddQuantityToItemLine(Item: Record Item; ItemCrossReference: Record "Item Cross Reference"; ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference; ItemQuantity: Decimal; JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"): Boolean
    var
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SSActionQtyIncrease: Codeunit "NPR SS Action - Qty Increase";
    begin

        //-NPR5.55 [364420]
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SaleLinePOS.SetFilter("Orig. POS Sale ID", '=%1', SalePOS."POS Sale ID");
        SaleLinePOS.SetFilter("No.", '=%1', Item."No.");
        SaleLinePOS.SetFilter(Quantity, '>=%1', ItemQuantity);
        if (not SaleLinePOS.FindFirst()) then
            exit(false);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetPosition(SaleLinePOS.GetPosition());

        SSActionQtyIncrease.IncreaseSalelineQuantity(POSSession, ItemQuantity);

        POSSession.RequestRefreshData();
        exit(true);

        //+NPR5.55 [364420]
    end;

    procedure RemoveQuantityFromItemLine(Item: Record Item; ItemCrossReference: Record "Item Cross Reference"; ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference; ItemQuantity: Decimal; JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SSActionQtyDecrease: Codeunit "NPR SS Action - Qty Decrease";
        SSActionDeletePOSLine: Codeunit "NPR SS Action: Delete POS Line";
    begin

        //-NPR5.55 [364420]
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SaleLinePOS.SetFilter("Orig. POS Sale ID", '=%1', SalePOS."POS Sale ID");
        SaleLinePOS.SetFilter("No.", '=%1', Item."No.");
        SaleLinePOS.SetFilter(Quantity, '>=%1', ItemQuantity);
        if (not SaleLinePOS.FindFirst()) then
            exit;

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetPosition(SaleLinePOS.GetPosition());

        if (SaleLinePOS.Quantity = ItemQuantity) then begin
            SSActionDeletePOSLine.DeletePosLine(POSSession);
        end else begin
            SSActionQtyDecrease.DecreaseSalelineQuantity(POSSession, Abs(ItemQuantity));
        end;

        POSSession.RequestRefreshData();
        //+NPR5.55 [364420]
    end;

    procedure SetQuantityToItemLine(Item: Record Item; ItemCrossReference: Record "Item Cross Reference"; ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference; ItemQuantity: Decimal; JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"): Boolean
    var
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SSActionQtyIncrease: Codeunit "NPR SS Action - Qty Increase";
    begin

        //-NPR5.55 [403784]
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SaleLinePOS.SetFilter("Orig. POS Sale ID", '=%1', SalePOS."POS Sale ID");
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

        //+NPR5.55 [403784]
    end;

    local procedure AutoExplodeBOM(Item: Record Item; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        BOMComponent: Record "BOM Component";
        SaleLinePOS: Record "NPR Sale Line POS";
        Level: Integer;
    begin
        //-NPR5.45 [324395]
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
        //+NPR5.45 [324395]
    end;

    local procedure AddAccessories(Item: Record Item; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        AccessorySparePart: Record "NPR Accessory/Spare Part";
    begin
        // This is an adoption of the original function UdpakTilbeh¢r in 6014418

        //-NPR5.40 [294655]
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

        // IF (NOT Item.GET (AccessoryToItem)) THEN
        //  EXIT;
        //
        // AccessorySparePart.SETFILTER (Type, '=%1', AccessorySparePart.Type::Accessory);
        // AccessorySparePart.SETFILTER (Code, '=%1', AccessoryToItem);
        // AccessorySparePart.SETFILTER ("Add Extra Line Automatically", '=%1', TRUE);
        // IF (AccessorySparePart.ISEMPTY ()) THEN BEGIN
        //  // Item Group Accessory
        //  AccessorySparePart.SETFILTER (Code, '=%1', Item."Item Group");
        //  IF (NOT AccessorySparePart.ISEMPTY ()) THEN
        //    AddAccessoryForItem (AccessoryToItem, TRUE, POSSaleLine);
        //
        // END ELSE BEGIN
        //  AddAccessoryForItem (AccessoryToItem, FALSE, POSSaleLine);
        //
        // END;
        //+NPR5.40 [294655]
    end;

    local procedure AddAccessoryForItem(Item: Record Item; GroupAccessory: Boolean; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        MainSaleLinePOS: Record "NPR Sale Line POS";
        AccessorySaleLinePOS: Record "NPR Sale Line POS";
        AccessorySparePart: Record "NPR Accessory/Spare Part";
    begin

        AccessorySparePart.SetFilter(Type, '=%1', AccessorySparePart.Type::Accessory);
        //-NPR5.40 [294655]
        AccessorySparePart.SetFilter(Code, '=%1', Item."No.");
        //AccessorySparePart.SETFILTER (Code, '=%1', ItemNo);
        //+NPR5.40 [294655]
        if (not AccessorySparePart.FindSet()) then
            exit;

        //-NPR5.40 [294655]
        //Item.GET (ItemNo);
        //+NPR5.40 [294655]
        POSSaleLine.GetCurrentSaleLine(MainSaleLinePOS);

        repeat
            POSSaleLine.GetNewSaleLine(AccessorySaleLinePOS);

            AccessorySaleLinePOS.Accessory := true;
            //-NPR5.40 [294655]
            //  AccessorySaleLinePOS."Main Item No." := ItemNo;
            AccessorySaleLinePOS."Main Item No." := Item."No.";
            //+NPR5.40 [294655]

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

            POSSaleLine.InsertLine(AccessorySaleLinePOS);

            //-NPR5.52 [370961]
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
            //+NPR5.52 [370961]

            //-NPR5.40 [305045]
            AccessorySaleLinePOS."Item group accessory" := GroupAccessory;
            if (GroupAccessory) then
                AccessorySaleLinePOS."Accessories Item Group No." := Item."NPR Item Group";

            AccessorySaleLinePOS.Accessory := true;
            AccessorySaleLinePOS."Main Item No." := Item."No.";
            AccessorySaleLinePOS."Main Line No." := MainSaleLinePOS."Line No.";

            AccessorySaleLinePOS.Modify();
            POSSaleLine.RefreshCurrent();

        //   AccessorySaleLinePOS.MODIFY ();
        //   POSSaleLine.RefreshCurrent ();
        // END;
        //+NPR5.40 [305045]

        until (AccessorySparePart.Next() = 0);
    end;

    local procedure AddItemAddOns(POSFrontEnd: Codeunit "NPR POS Front End Management"; Item: Record Item; BaseLineNo: Integer)
    var
        POSAction: Record "NPR POS Action";
    begin
        //-NPR5.54 [388951]
        if Item."NPR Item AddOn No." = '' then
            exit;

        POSAction.Get('SS-ITEM-ADDON');

        //POSAction.SetWorkflowInvocationParameter('BaseLineNo',BaseLineNo,POSFrontEnd);
        POSFrontEnd.InvokeWorkflow(POSAction);
        //+NPR5.54 [388951]
    end;

    local procedure "-- Serial number support functions"()
    begin
    end;

    local procedure ItemRequiresSerialNumberOnSale(Item: Record Item; var UseSpecificTracking: Boolean) SerialNoRequired: Boolean
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        //Global
        //-NPR5.40 [294655]
        // IF ItemNo = '' THEN EXIT(FALSE);
        // IF NOT Item.GET(ItemNo) THEN EXIT(FALSE);
        //+NPR5.40 [294655]
        if Item."Item Tracking Code" = '' then exit(false);
        if not ItemTrackingCode.Get(Item."Item Tracking Code") then exit(false);
        ItemTrackingCode.TestField("Lot Specific Tracking", false);
        UseSpecificTracking := ItemTrackingCode."SN Specific Tracking";
        exit(ItemTrackingCode."SN Sales Outbound Tracking");
    end;

    local procedure SerialNumberCanBeUsedForItem(ItemNo: Code[20]; SerialNumber: Code[20]; var UserInformationErrorWarning: Text) CanBeUsed: Boolean
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
        if not Item.Get(ItemNo) then exit(false);
        if Item."Item Tracking Code" = '' then exit(false);
        if not ItemTrackingCode.Get(Item."Item Tracking Code") then exit(false);

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
            ItemLedgerEntry.SetRange("Item No.", ItemNo);
            if ItemLedgerEntry.IsEmpty then begin
                CanBeUsed := false;
                //Create user information message
                UserInformationErrorWarning := StrSubstNo(TEXTWrongSerialOnILE, SerialNumber, ItemNo, Item.Description, TEXTitemTracking_instructions);
            end else begin
                CanBeUsed := true;
            end;
        end;


        //Check if serial number exists in saved/active pos sale line
        if ItemTrackingCode."SN Specific Tracking" then begin
            SaleLinePOS.Reset;
            SaleLinePOS.SetCurrentKey("Serial No.");
            SaleLinePOS.SetFilter(Type, '=%1', SaleLinePOS.Type::Item);
            SaleLinePOS.SetFilter("No.", '=%1', ItemNo);
            SaleLinePOS.SetFilter("Serial No.", '=%1', SerialNumber);
            if not SaleLinePOS.IsEmpty then begin
                CanBeUsed := false;
                //Create user information message
                SaleLinePOS.FindFirst;
                "Sale POS".Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.");
                if "Sale POS"."Saved Sale" then begin
                    TextActiveSaved := TEXTSaved;
                end else begin
                    TextActiveSaved := TEXTActive;
                end;
                UserInformationErrorWarning := StrSubstNo(TEXTWrongSerialOnSLP, SerialNumber, ItemNo, Item.Description, TextActiveSaved, SaleLinePOS."Sales Ticket No.", SaleLinePOS."Register No.", TEXTitemTracking_instructions);

            end;
        end;

        exit(CanBeUsed);
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
        //-NPR5.45 [319706]
        if not EanBoxEvent.Get(EventCodeItemNo()) then begin
            EanBoxEvent.Init;
            EanBoxEvent.Code := EventCodeItemNo();
            EanBoxEvent."Module Name" := Item.TableCaption;
            //-NPR5.49 [350374]
            //EanBoxEvent.Description := ItemCrossReference.FIELDCAPTION("Item No.");
            EanBoxEvent.Description := CopyStr(ItemCrossReference.FieldCaption("Item No."), 1, MaxStrLen(EanBoxEvent.Description));
            //+NPR5.49 [350374]
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;

        if not EanBoxEvent.Get(EventCodeItemCrossRef()) then begin
            EanBoxEvent.Init;
            EanBoxEvent.Code := EventCodeItemCrossRef();
            EanBoxEvent."Module Name" := Item.TableCaption;
            //-NPR5.49 [350374]
            //EanBoxEvent.Description := ItemCrossReference.TABLECAPTION;
            EanBoxEvent.Description := CopyStr(ItemCrossReference.TableCaption, 1, MaxStrLen(EanBoxEvent.Description));
            //+NPR5.49 [350374]
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;

        if not EanBoxEvent.Get(EventCodeItemSearch()) then begin
            EanBoxEvent.Init;
            EanBoxEvent.Code := EventCodeItemSearch();
            EanBoxEvent."Module Name" := Item.TableCaption;
            //-NPR5.49 [350374]
            //EanBoxEvent.Description := Item.FIELDCAPTION("Search Description");
            EanBoxEvent.Description := CopyStr(Item.FieldCaption("Search Description"), 1, MaxStrLen(EanBoxEvent.Description));
            //+NPR5.49 [350374]
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;
        //+NPR5.45 [319706]

        //-NPR5.52 [369231]
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
        //+NPR5.52 [369231]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "NPR Ean Box Setup Mgt."; EanBoxEvent: Record "NPR Ean Box Event")
    begin
        //-NPR5.45 [319706]
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
            //-NPR5.52 [369231]
            EventCodeSerialNoItemCrossRef():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'itemNo', true, '');
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'itemIdentifyerType', false, 'SerialNoItemCrossReference');
                end;
        //+NPR5.52 [369231]
        end;
        //+NPR5.45 [319706]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060107, 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeItemNo(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        Item: Record Item;
    begin
        //-NPR5.45 [319706]
        if EanBoxSetupEvent."Event Code" <> EventCodeItemNo() then
            exit;
        if StrLen(EanBoxValue) > MaxStrLen(Item."No.") then
            exit;

        if Item.Get(UpperCase(EanBoxValue)) then
            InScope := true;
        //+NPR5.45 [319706]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060107, 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeItemCrossRef(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        ItemCrossReference: Record "Item Cross Reference";
    begin
        //-NPR5.45 [319706]
        if EanBoxSetupEvent."Event Code" <> EventCodeItemCrossRef() then
            exit;
        //-NPR5.49 [344084]
        // IF STRLEN(ItemCrossReference."Cross-Reference No.") > MAXSTRLEN(ItemCrossReference."Cross-Reference No.") THEN
        //  EXIT;
        if StrLen(EanBoxValue) > MaxStrLen(ItemCrossReference."Cross-Reference No.") then
            exit;
        //+NPR5.49 [344084]

        ItemCrossReference.SetRange("Cross-Reference No.", UpperCase(EanBoxValue));
        ItemCrossReference.SetRange("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::"Bar Code");
        ItemCrossReference.SetRange("Discontinue Bar Code", false);
        if ItemCrossReference.FindFirst then
            InScope := true;
        //+NPR5.45 [319706]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060107, 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeItemSearch(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        Item: Record Item;
    begin
        //-NPR5.45 [319706]
        if EanBoxSetupEvent."Event Code" <> EventCodeItemSearch() then
            exit;

        SetItemSearchFilter(EanBoxValue, Item);
        if Item.FindFirst then
            InScope := true;
        //+NPR5.45 [319706]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060107, 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeSerialNoItemCrossRef(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        ItemCrossReference: Record "Item Cross Reference";
        CSRfidTagModels: Record "NPR CS Rfid Tag Models";
        CSRfidData: Record "NPR CS Rfid Data";
        TagFamily: Code[10];
        TagModel: Code[10];
        TagId: Code[20];
    begin
        //-NPR5.52 [369231]
        if EanBoxSetupEvent."Event Code" <> EventCodeSerialNoItemCrossRef() then
            exit;

        if not CSRfidTagModels.FindFirst then
            exit;

        if (StrLen(EanBoxValue) > MaxStrLen(CSRfidData.Key)) or (StrLen(EanBoxValue) < MaxStrLen(CSRfidTagModels.Family)) then
            exit;

        TagFamily := CopyStr(EanBoxValue, 1, 4);
        TagModel := CopyStr(EanBoxValue, 5, 4);
        TagId := CopyStr(EanBoxValue, 5);

        if not CSRfidTagModels.Get(TagFamily, TagModel) then
            exit;

        if (StrLen(TagId) > MaxStrLen(ItemCrossReference."Cross-Reference No.")) then
            exit;

        ItemCrossReference.SetRange("Cross-Reference No.", UpperCase(TagId));
        ItemCrossReference.SetRange("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::"Bar Code");
        ItemCrossReference.SetRange("NPR Is Retail Serial No.", true);
        ItemCrossReference.SetRange("Discontinue Bar Code", false);
        if ItemCrossReference.FindFirst then
            InScope := true;
        //+NPR5.52 [369231]
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        //-NPR5.45 [319706]
        exit(CODEUNIT::"NPR POS Action: Insert Item");
        //+NPR5.45 [319706]
    end;

    local procedure EventCodeItemNo(): Code[20]
    begin
        //-NPR5.45 [319706]
        exit('SS_ITEMNO');
        //+NPR5.45 [319706]
    end;

    local procedure EventCodeItemCrossRef(): Code[20]
    begin
        //-NPR5.45 [319706]
        exit('SS_ITEM_X_REF_NO');
        //+NPR5.45 [319706]
    end;

    local procedure EventCodeItemSearch(): Code[20]
    begin
        //-NPR5.45 [319706]
        exit('SS_ITEM_SEARCH');
        //+NPR5.45 [319706]
    end;

    local procedure EventCodeSerialNoItemCrossRef(): Code[20]
    begin
        //-NPR5.52 [369231]
        exit('SS_SERIALNO_X_REF');
        //+NPR5.52 [369231]
    end;

    local procedure "--- Item Search"()
    begin
    end;

    local procedure GetItemFromItemSearch(var ItemIdentifierString: Text) ItemFound: Boolean
    var
        Item: Record Item;
        ItemList: Page "NPR Retail Item List";
        ItemNo: Code[20];
    begin
        //-NPR5.45 [319706]
        // SearchString := COPYSTR (ItemIdentifierString, 1, MAXSTRLEN (Item."Search Description"));
        // SearchString := UPPERCASE(SearchString);
        // SearchFilter := '*'+SearchString+'*';
        //
        // Item.SETCURRENTKEY("Search Description");
        // Item.SETFILTER("Search Description", SearchFilter);
        // Item.SETFILTER(Blocked, '=%1', FALSE);
        // Item.SETFILTER("Blocked on Pos", '=%1', FALSE);
        // IF NOT Item.FIND('-') THEN
        //  EXIT(FALSE);
        //
        // ItemIdentifierString := Item."No.";
        // IF Item.NEXT = 0 THEN
        //  EXIT(TRUE);
        SetItemSearchFilter(ItemIdentifierString, Item);
        if not Item.FindFirst then
            exit(false);

        ItemIdentifierString := Item."No.";
        Item.FindLast;
        if ItemIdentifierString = Item."No." then
            //-NPR5.48 [345847]
            //EXIT;
            exit(true);
        //+NPR5.48 [345847]
        //+NPR5.45 [319706]
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
        //-NPR5.45 [319706]
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
        //+NPR5.45 [319706]
    end;
}

