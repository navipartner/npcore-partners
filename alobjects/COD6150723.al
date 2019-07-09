codeunit 6150723 "POS Action - Insert Item"
{
    // Refactoring - ANEN
    // NPR5.32/NPKNAV/20170526  CASE 268251 Transport NPR5.32 - 26 May 2017
    // NPR5.32.11/ANEN/20170615 Adding support for Quantity - up version to 1.1
    // NPR5.34/TSA /20170724  CASE 284798 Corrected Spelling for subscriber function IdentifyThisCodePublisher
    // NPR5.36/TSA /20170908  CASE 289184 Added Accessories for Item
    // NPR5.37/ANEN/20171007  CASE 292011 Adding search func to AdvancedItemSubscriber
    // NPR5.37/BR  /20171024  CASE 294219 Check Lot No specific tracking is not activated
    // NPR5.38/ANEN/20171031  CASE 275242 Option to set description
    // NPR5.38/ANEN/20171201  CASE 294159 Option to set price on item insert
    // NPR5.38/ANEN/20171172  CASE 299854 Fixing issue with reasking on wrong seralno.
    // NPR5.40/MMV /20180213  CASE 294655 Refactored the workflow steps for readability and performance.
    //                                    Disabled OnBeforeWorkflow for better performance in best-case (no prompts on item insert) -> 1 server roundtrip instead of 2.
    //                                    Removed old version comments.
    // NPR5.40/TSA /20180214  CASE 305045 AddAccessories fix, added "Main Line No." reference for handling qty update / delete / etc
    // NPR5.40/TSA /20180329  CASE 308522 Changing the Item Variant page to a custom page with inventory
    // NPR5.45/MHA /20180817  CASE 319706 Reworked Identifier Dissociation to Ean Box Event Handler
    // NPR5.45/MHA /20180821  CASE 324395 Added function AutoExplodeBOM()
    // NPR5.48/JDH /20181210 CASE 335967  Description taken from Barcode as well
    // NPR5.48/MHA /20181102  CASE 334329 Run page for selection in case more than 1 Item Cross Ref. is found
    // NPR5.48/MHA /20190213  CASE 345847 Return value should be TRUE when only 1 item is found in GetItemFromItemSearch()
    // NPR5.49/MHA /20190220  CASE 344084 Fixed check on Ean Box Barcode length in SetEanBoxEventInScopeItemCrossRef()
    // NPR5.49/MHA /20190328  CASE 350374 Added MaxStrLen to EanBox.Description in DiscoverEanBoxEvents()
    // NPR5.49/MHA /20190402  CASE 350410 Removed Description taken from Barcode [335967]


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built-in action for inserting an item line into the current transaction';
        TEXTitemTracking_title: Label 'Enter Serial Number';
        TEXTitemTracking_lead: Label 'This item requires serial number, enter serial number.';
        Setup: Codeunit "POS Setup";
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

    local procedure ActionCode(): Text
    begin
        exit ('ITEM');
    end;

    local procedure ActionVersion(): Text
    begin
        //-NPR5.40 [294655]
        //EXIT ('1.5');
        exit ('1.7');
        //+NPR5.40 [294655]
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
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

          //-NPR5.40 [294655]
          Sender.RegisterWorkflowStep('editDescription', 'param.descriptionEdit && input({title: labels.editDesc_title, caption: labels.editDesc_lead, value: context.defaultDescription}).cancel(abort);');
          Sender.RegisterWorkflowStep('skipContextDialogs', 'goto("addSalesLine")');

          Sender.RegisterWorkflowStep('promptContextDialogs', '');
          Sender.RegisterWorkflowStep('unitPrice', 'context.promptPrice && numpad({title: labels.UnitpriceTitle, caption: labels.UnitPriceCaption}).cancel(abort);');
          Sender.RegisterWorkflowStep('itemTrackingForce', 'context.promptSerial && context.useSpecificTracking && input(labels.itemTracking_title, labels.itemTracking_lead, context.itemTracking_instructions, "", true).respond().cancel(abort);');
          Sender.RegisterWorkflowStep('itemTrackingOptional', 'context.promptSerial && !context.useSpecificTracking && input(labels.itemTracking_title, labels.itemTracking_lead, context.itemTracking_instructions, "", true);');

          Sender.RegisterWorkflowStep('addSalesLine', 'respond();');

          Sender.RegisterWorkflow(false);

        //  itemTrackingCode := 'context.reask; reask = false; context.validatedSerialNumber; context.useSpecificTracking; ';
        //  itemTrackingCode := itemTrackingCode + 'context.prompt_itemTracking && input(labels.itemTracking_title, labels.itemTracking_lead, context.itemTracking_instructions, context.inputSerialDefault, true).cancel()';
        //  itemTrackingCode := itemTrackingCode + '.goto("doneItemTracking"); if (context.useSpecificTracking == true) {respond() }';
        //
        //  Sender.RegisterWorkflowStep('itemTracking', itemTrackingCode);
        //  Sender.RegisterWorkflowStep('reaskStep','if (context.reask == true) { goto("itemTracking"); }');
        //  Sender.RegisterWorkflowStep('doneItemTracking', '');
        //
        //  Sender.RegisterWorkflowStep('doneItemTracking', '');
        //  Sender.RegisterWorkflowStep ('EditDesc', 'if (param.descriptionEdit == true) {input({title: labels.editDesc_title, caption: labels.editDesc_lead, value: context.defaultDescription}).respond();} ');
        //
        //  Sender.RegisterWorkflowStep ('itemSearch','context.itemSearchItemNo;');
        //  Sender.RegisterWorkflowStep ('unitprice', 'context.isMiscItem && numpad ({title: labels.UnitpriceTitle, caption: labels.UnitPriceCaption}).cancel(abort).ok(respond);');
        //
        //  Sender.RegisterWorkflowStep('addSalesLine','respond()');
        //
        //  Sender.RegisterWorkflow(TRUE);
          //+NPR5.40 [294655]

          Sender.RegisterOptionParameter('itemIdentifyerType','ItemNo,ItemCrossReference,ItemSearch','ItemNo');
          Sender.RegisterTextParameter('itemNo', '');
          Sender.RegisterDecimalParameter('itemQuantity', 1);
          Sender.RegisterBooleanParameter('descriptionEdit', false);
          Sender.RegisterBooleanParameter('usePreSetUnitPrice', false);
          Sender.RegisterDecimalParameter('preSetUnitPrice', 0);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    var
        UI: Codeunit "POS UI Management";
    begin
        Captions.AddActionCaption (ActionCode, 'itemTracking_title', TEXTitemTracking_title);
        Captions.AddActionCaption (ActionCode, 'itemTracking_lead', TEXTitemTracking_lead);
        Captions.AddActionCaption (ActionCode, 'UnitpriceTitle', UnitPriceTitle);
        Captions.AddActionCaption (ActionCode, 'UnitpriceCaption', UnitPriceCaption);
        Captions.AddActionCaption (ActionCode, 'editDesc_title', TEXTeditDesc_title);
        Captions.AddActionCaption (ActionCode, 'editDesc_lead', TEXTeditDesc_title);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        ControlId: Text;
        Value: Text;
        DoNotClearTextBox: Boolean;
    begin

        if not Action.IsThisAction(ActionCode) then
          exit;

        case WorkflowStep of
          'itemTrackingForce': Step_ItemTracking(Context,POSSession,FrontEnd);
          'addSalesLine': Step_AddSalesLine(Context,POSSession,FrontEnd);
        end;

        //-NPR5.40 [294655]
        //JSON.InitializeJObjectParser(Context,FrontEnd);
        //+NPR5.40 [294655]

        Handled := true;
    end;

    local procedure Step_AddSalesLine(Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        JSON: Codeunit "POS JSON Management";
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
        DialogContext: Codeunit "POS JSON Management";
        DialogPrompt: Boolean;
    begin
        //-NPR5.40 [294655]
        JSON.InitializeJObjectParser(Context,FrontEnd);
        HasPrompted := JSON.GetBoolean('promptPrice', false) or JSON.GetBoolean('promptSerial', false);
        JSON.SetScope('parameters',true);
        ItemIdentifier := JSON.GetString('itemNo',true);
        ItemIdentifierType := JSON.GetInteger('itemIdentifyerType',false);
        ItemQuantity := JSON.GetDecimal('itemQuantity',false);
        UsePresetUnitPrice := JSON.GetBoolean('usePreSetUnitPrice', false);
        PresetUnitPrice := JSON.GetDecimal('preSetUnitPrice', false);

        if ItemIdentifierType < 0 then
          ItemIdentifierType := 0;

        GetItem(Item, ItemCrossReference, ItemIdentifier, ItemIdentifierType);

        if not HasPrompted then begin
          if Item."Group sale" and (not UsePresetUnitPrice)then begin
            DialogContext.SetContext('promptPrice', true);
            DialogPrompt := true;
          end;

          if ItemRequiresSerialNumberOnSale(Item, UseSpecificTracking) then begin
            DialogContext.SetContext('promptSerial', true);
            DialogContext.SetContext('itemTracking_instructions',TEXTitemTracking_instructions);
            DialogContext.SetContext('useSpecificTracking', UseSpecificTracking);
            DialogPrompt := true;
          end;

          if DialogPrompt then begin
            FrontEnd.SetActionContext(ActionCode, DialogContext);
            FrontEnd.ContinueAtStep('promptContextDialogs');
            exit;
          end;
        end;

        AddItemLine(Item, ItemCrossReference, ItemIdentifierType, ItemQuantity, UsePresetUnitPrice, PresetUnitPrice, Context, POSSession, FrontEnd);
        //+NPR5.40 [294655]
    end;

    local procedure Step_ItemTracking(Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        JSON: Codeunit "POS JSON Management";
        SerialNumberInput: Text;
        SpecificTracking: Boolean;
        ItemNo: Code[20];
        OKInput: Boolean;
        SerialNoUsedOnPOSSaleLine: Boolean;
        UserInformationErrorWarning: Text;
    begin
        //Called on OK when serial number is filled on item witch requires specific tracking on serial number.

        //Get input and check if valid
        JSON.InitializeJObjectParser(Context,FrontEnd);
        JSON.SetScope('$itemTrackingForce',true);
        SerialNumberInput := JSON.GetString('input',true);
        JSON.InitializeJObjectParser(Context,FrontEnd);
        JSON.SetScope('parameters',true);
        ItemNo := JSON.GetString('itemNo',true);

        //Some number is inputed, now check if valid for item
        if not SerialNumberCanBeUsedForItem(ItemNo, SerialNumberInput, UserInformationErrorWarning) then begin
          SerialNumberInput := '';
          //Serial number is not valid, lets reask
          JSON.InitializeJObjectParser(Context,FrontEnd);
          JSON.SetScope ('/', true);
          JSON.SetContext('itemTracking_instructions',UserInformationErrorWarning);
          //-NPR5.40 [294655]
          FrontEnd.SetActionContext (ActionCode, JSON);
          FrontEnd.ContinueAtStep('itemTrackingForce');
        //  JSON.SetContext('reask',TRUE);
        //  FrontEnd.SetActionContext (ActionCode, JSON);
          //+NPR5.40 [294655]
          exit;
        end;

        //Serial number is validated correct and should be applied to line
        //Applying is done in finalize
        JSON.InitializeJObjectParser(Context,FrontEnd);
        JSON.SetScope ('/', true);
        JSON.SetContext('validatedSerialNumber', SerialNumberInput);
        JSON.InitializeJObjectParser(Context,FrontEnd);
        FrontEnd.SetActionContext (ActionCode, JSON);
        exit;

        POSSession.RequestRefreshData();
    end;

    local procedure "-- Various support functions"()
    begin
    end;

    local procedure GetItem(var Item: Record Item;var ItemCrossReference: Record "Item Cross Reference";ItemIdentifier: Text;ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch)
    var
        FirstRec: Text;
    begin
        //-NPR5.40 [294655]
        case ItemIdentifierType of
          ItemIdentifierType::ItemNo :
            Item.Get(ItemIdentifier);

          ItemIdentifierType::ItemCrossReference :
            begin
              ItemCrossReference.SetFilter ("Cross-Reference No.", '=%1', CopyStr (ItemIdentifier, 1, MaxStrLen (ItemCrossReference."Cross-Reference No.")));
              ItemCrossReference.SetFilter ("Cross-Reference Type", '=%1', ItemCrossReference."Cross-Reference Type"::"Bar Code");
              ItemCrossReference.SetFilter ("Discontinue Bar Code", '=%1', false);
              ItemCrossReference.FindFirst;
              //-NPR5.48 [334329]
              FirstRec := Format(ItemCrossReference);
              ItemCrossReference.FindLast;
              if FirstRec <> Format(ItemCrossReference) then begin
                if PAGE.RunModal(0,ItemCrossReference) <> ACTION::LookupOK then
                  Error('');
              end;
              //+NPR5.48 [334329]
              Item.Get(ItemCrossReference."Item No.");
            end;

          ItemIdentifierType::ItemSearch :
            if GetItemFromItemSearch(ItemIdentifier) then
              Item.Get(ItemIdentifier)
            else
              Error(ERROR_ITEMSEARCH, ItemIdentifier);
        end;
        //+NPR5.40 [294655]
    end;

    local procedure AddItemLine(Item: Record Item;ItemCrossReference: Record "Item Cross Reference";ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch;ItemQuantity: Decimal;UsePresetUnitPrice: Boolean;PresetUnitPrice: Decimal;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        Line: Record "Sale Line POS";
        JSON: Codeunit "POS JSON Management";
        SaleLine: Codeunit "POS Sale Line";
        ValidatedSerialNumber: Code[20];
        UseSpecificTracking: Boolean;
        InputSerial: Code[20];
        UnitPrice: Decimal;
        CustomDescription: Text;
        SetUnitPrice: Boolean;
    begin
        //-NPR5.40 [294655]
        JSON.InitializeJObjectParser(Context,FrontEnd);
        JSON.SetScope ('/', true);
        UseSpecificTracking := JSON.GetBoolean('useSpecificTracking', false);
        ValidatedSerialNumber := JSON.GetString('validatedSerialNumber', false);

        if UsePresetUnitPrice then begin
          UnitPrice := PresetUnitPrice;
          SetUnitPrice := true;
        end else begin
          JSON.InitializeJObjectParser(Context,FrontEnd);
          if (JSON.SetScope('$unitPrice',false)) then begin
            UnitPrice := JSON.GetDecimal('numpad',true);
            SetUnitPrice := true;
          end;
        end;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        if JSON.SetScope('$itemTrackingOptional',false) then
          InputSerial := JSON.GetString('input',false);

        JSON.InitializeJObjectParser(Context,FrontEnd);
        if JSON.SetScope('$editDescription',false) then
          CustomDescription := JSON.GetString('input',false);

        if ItemQuantity = 0 then
          ItemQuantity := 1;

        with Line do begin
          Type := Type::Item;
          Quantity := ItemQuantity;

          case ItemIdentifierType of
            ItemIdentifierType::ItemSearch,
            ItemIdentifierType::ItemNo :
              begin
                "No." := Item."No.";
              end;

            ItemIdentifierType::ItemCrossReference :
              begin
                "No." := ItemCrossReference."Item No.";
                "Variant Code" := ItemCrossReference."Variant Code";
                "Unit of Measure Code" := ItemCrossReference."Unit of Measure";
                //-NPR5.49 [350410]
                // //-NPR5.48 [335967]
                // Description := ItemCrossReference.Description;
                // //+NPR5.48 [335967]
                //+NPR5.49 [350410]

              end;
          end;

          if ( UseSpecificTracking and (ValidatedSerialNumber <> '') ) then
            Validate("Serial No.", ValidatedSerialNumber);
          if ( not UseSpecificTracking and (InputSerial <> '') ) then
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
        AddAccessories (Item, SaleLine);
        //-NPR5.45 [324395]
        AutoExplodeBOM(Item,SaleLine);
        //+NPR5.45 [324395]

        POSSession.RequestRefreshData();
        //+NPR5.40 [294655]
    end;

    local procedure AutoExplodeBOM(Item: Record Item;POSSaleLine: Codeunit "POS Sale Line")
    var
        BOMComponent: Record "BOM Component";
        SaleLinePOS: Record "Sale Line POS";
        Level: Integer;
    begin
        //-NPR5.45 [324395]
        if not Item."Explode BOM auto" then
          exit;
        Item.CalcFields("Assembly BOM");
        if not Item."Assembly BOM" then
          exit;

        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLinePOS.Validate(Type,SaleLinePOS.Type::"BOM List");
        SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::"BOM List";
        SaleLinePOS."Discount Code" := SaleLinePOS."No.";
        SaleLinePOS."Unit Price" := 0;
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        SaleLinePOS.Modify(true);

        SaleLinePOS.ExplodeBOM(SaleLinePOS."No.",0,0,Level,0,0);
        //+NPR5.45 [324395]
    end;

    local procedure AddAccessories(Item: Record Item;POSSaleLine: Codeunit "POS Sale Line")
    var
        AccessorySparePart: Record "Accessory/Spare Part";
    begin
        // This is an adoption of the original function UdpakTilbeh�r in 6014418

        //-NPR5.40 [294655]
        AccessorySparePart.SetFilter (Type, '=%1', AccessorySparePart.Type::Accessory);
        AccessorySparePart.SetFilter (Code, '=%1', Item."No.");
        AccessorySparePart.SetFilter ("Add Extra Line Automatically", '=%1', true);
        if (AccessorySparePart.IsEmpty ()) then begin
          // Item Group Accessory
          AccessorySparePart.SetFilter (Code, '=%1', Item."Item Group");
          if (not AccessorySparePart.IsEmpty ()) then
            AddAccessoryForItem (Item, true, POSSaleLine);
        end else
          AddAccessoryForItem (Item, false, POSSaleLine);

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

    local procedure AddAccessoryForItem(Item: Record Item;GroupAccessory: Boolean;POSSaleLine: Codeunit "POS Sale Line")
    var
        MainSaleLinePOS: Record "Sale Line POS";
        AccessorySaleLinePOS: Record "Sale Line POS";
        AccessorySparePart: Record "Accessory/Spare Part";
    begin

        AccessorySparePart.SetFilter (Type, '=%1', AccessorySparePart.Type::Accessory );
        //-NPR5.40 [294655]
        AccessorySparePart.SetFilter (Code, '=%1', Item."No.");
        //AccessorySparePart.SETFILTER (Code, '=%1', ItemNo);
        //+NPR5.40 [294655]
        if (not AccessorySparePart.FindSet ()) then
          exit;

        //-NPR5.40 [294655]
        //Item.GET (ItemNo);
        //+NPR5.40 [294655]
        POSSaleLine.GetCurrentSaleLine (MainSaleLinePOS);

        repeat
          POSSaleLine.GetNewSaleLine (AccessorySaleLinePOS);

          AccessorySaleLinePOS.Accessory := true;
        //-NPR5.40 [294655]
        //  AccessorySaleLinePOS."Main Item No." := ItemNo;
          AccessorySaleLinePOS."Main Item No." := Item."No.";
        //+NPR5.40 [294655]

          AccessorySaleLinePOS."Item group accessory" := GroupAccessory;
          if (GroupAccessory) then
            AccessorySaleLinePOS."Accessories Item Group No." := Item."Item Group";

          AccessorySaleLinePOS.Validate ("No.", AccessorySparePart."Item No." );

          // This is not support unless we add a commit at this point
          if (AccessorySparePart."Quantity in Dialogue") then
            Error ('The possibility to specify quantity per accessory line in a dialogue has been discontinued.');

          if (AccessorySparePart."Per unit") then
            AccessorySaleLinePOS.Validate (Quantity, AccessorySparePart.Quantity * MainSaleLinePOS.Quantity)
          else
            AccessorySaleLinePOS.Validate (Quantity, AccessorySparePart.Quantity);

          POSSaleLine.InsertLine (AccessorySaleLinePOS);

          // Price
          if (AccessorySparePart."Use Alt. Price") then begin
            if (AccessorySparePart."Show Discount") then begin
              AccessorySaleLinePOS.Validate ("Amount Including VAT", AccessorySparePart."Alt. Price" );

            end else begin
              if (AccessorySaleLinePOS."Price Includes VAT") then
                AccessorySaleLinePOS.Validate ("Unit Price", AccessorySparePart."Alt. Price" )
              else
                AccessorySaleLinePOS.Validate ("Unit Price", AccessorySaleLinePOS."Unit Price" / ((100 + AccessorySaleLinePOS."VAT %") / 100 ));
            end;

          //-NPR5.40 [305045]
          end;

          AccessorySaleLinePOS."Item group accessory" := GroupAccessory;
          if (GroupAccessory) then
            AccessorySaleLinePOS."Accessories Item Group No." := Item."Item Group";

          AccessorySaleLinePOS.Accessory := true;
          AccessorySaleLinePOS."Main Item No." := Item."No.";
          AccessorySaleLinePOS."Main Line No." := MainSaleLinePOS."Line No.";

          AccessorySaleLinePOS.Modify ();
          POSSaleLine.RefreshCurrent ();

          //   AccessorySaleLinePOS.MODIFY ();
          //   POSSaleLine.RefreshCurrent ();
          // END;
          //+NPR5.40 [305045]

        until (AccessorySparePart.Next () = 0);
    end;

    local procedure "-- Serial number support functions"()
    begin
    end;

    local procedure ItemRequiresSerialNumberOnSale(Item: Record Item;var UseSpecificTracking: Boolean) SerialNoRequired: Boolean
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
        ItemTrackingCode.TestField("Lot Specific Tracking",false);
        UseSpecificTracking := ItemTrackingCode."SN Specific Tracking";
        exit(ItemTrackingCode."SN Sales Outbound Tracking");
    end;

    local procedure SerialNumberCanBeUsedForItem(ItemNo: Code[20];SerialNumber: Code[20];var UserInformationErrorWarning: Text) CanBeUsed: Boolean
    var
        Register: Record Register;
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ItemLedgerEntry: Record "Item Ledger Entry";
        SaleLinePOS: Record "Sale Line POS";
        "Sale POS": Record "Sale POS";
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
          if ItemLedgerEntry.SetCurrentKey(Open, Positive, "Item No.", "Serial No." ) then;
          ItemLedgerEntry.SetRange(Open,true);
          ItemLedgerEntry.SetRange(Positive,true);
          ItemLedgerEntry.SetFilter("Serial No.",'=%1', SerialNumber);
          ItemLedgerEntry.SetRange("Item No.", ItemNo);
          if ItemLedgerEntry.IsEmpty then begin
            CanBeUsed := false;
            //Create user information message
            UserInformationErrorWarning := StrSubstNo(TEXTWrongSerialOnILE, SerialNumber, ItemNo, Item.Description,TEXTitemTracking_instructions);
          end else begin
            CanBeUsed := true;
          end;
        end;


        //Check if serial number exists in saved/active pos sale line
        if ItemTrackingCode."SN Specific Tracking" then begin
          SaleLinePOS.Reset;
          SaleLinePOS.SetCurrentKey("Serial No.");
          SaleLinePOS.SetFilter(Type, '=%1',SaleLinePOS.Type::Item);
          SaleLinePOS.SetFilter("No.", '=%1' ,ItemNo);
          SaleLinePOS.SetFilter("Serial No.", '=%1' , SerialNumber);
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
            UserInformationErrorWarning := StrSubstNo(TEXTWrongSerialOnSLP, SerialNumber, ItemNo, Item.Description, TextActiveSaved, SaleLinePOS."Sales Ticket No.", SaleLinePOS."Register No.",TEXTitemTracking_instructions);

          end;
        end;

        exit(CanBeUsed);
    end;

    local procedure "--- Ean Box Event Handling"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "Ean Box Event")
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
          EanBoxEvent.Description := CopyStr(ItemCrossReference.FieldCaption("Item No."),1,MaxStrLen(EanBoxEvent.Description));
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
          EanBoxEvent.Description := CopyStr(ItemCrossReference.TableCaption,1,MaxStrLen(EanBoxEvent.Description));
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
          EanBoxEvent.Description := CopyStr(Item.FieldCaption("Search Description"),1,MaxStrLen(EanBoxEvent.Description));
          //+NPR5.49 [350374]
          EanBoxEvent."Action Code" := ActionCode();
          EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
          EanBoxEvent."Event Codeunit" := CurrCodeunitId();
          EanBoxEvent.Insert(true);
        end;
        //+NPR5.45 [319706]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "Ean Box Setup Mgt.";EanBoxEvent: Record "Ean Box Event")
    begin
        //-NPR5.45 [319706]
        case EanBoxEvent.Code of
          EventCodeItemNo():
            begin
              Sender.SetNonEditableParameterValues(EanBoxEvent,'itemNo',true,'');
              Sender.SetNonEditableParameterValues(EanBoxEvent,'itemIdentifyerType',false,'ItemNo');
            end;
          EventCodeItemCrossRef():
            begin
              Sender.SetNonEditableParameterValues(EanBoxEvent,'itemNo',true,'');
              Sender.SetNonEditableParameterValues(EanBoxEvent,'itemIdentifyerType',false,'ItemCrossReference');
            end;
          EventCodeItemSearch():
            begin
              Sender.SetNonEditableParameterValues(EanBoxEvent,'itemNo',true,'');
              Sender.SetNonEditableParameterValues(EanBoxEvent,'itemIdentifyerType',false,'ItemSearch');
            end;
        end;
        //+NPR5.45 [319706]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060107, 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeItemNo(EanBoxSetupEvent: Record "Ean Box Setup Event";EanBoxValue: Text;var InScope: Boolean)
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
    local procedure SetEanBoxEventInScopeItemCrossRef(EanBoxSetupEvent: Record "Ean Box Setup Event";EanBoxValue: Text;var InScope: Boolean)
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

        ItemCrossReference.SetRange("Cross-Reference No.",UpperCase(EanBoxValue));
        ItemCrossReference.SetRange("Cross-Reference Type",ItemCrossReference."Cross-Reference Type"::"Bar Code");
        ItemCrossReference.SetRange("Discontinue Bar Code",false);
        if ItemCrossReference.FindFirst then
          InScope := true;
        //+NPR5.45 [319706]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060107, 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeItemSearch(EanBoxSetupEvent: Record "Ean Box Setup Event";EanBoxValue: Text;var InScope: Boolean)
    var
        Item: Record Item;
    begin
        //-NPR5.45 [319706]
        if EanBoxSetupEvent."Event Code" <> EventCodeItemSearch() then
          exit;

        SetItemSearchFilter(EanBoxValue,Item);
        if Item.FindFirst then
          InScope := true;
        //+NPR5.45 [319706]
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        //-NPR5.45 [319706]
        exit(CODEUNIT::"POS Action - Insert Item");
        //+NPR5.45 [319706]
    end;

    local procedure EventCodeItemNo(): Code[20]
    begin
        //-NPR5.45 [319706]
        exit('ITEMNO');
        //+NPR5.45 [319706]
    end;

    local procedure EventCodeItemCrossRef(): Code[20]
    begin
        //-NPR5.45 [319706]
        exit('ITEMCROSSREFERENCENO');
        //+NPR5.45 [319706]
    end;

    local procedure EventCodeItemSearch(): Code[20]
    begin
        //-NPR5.45 [319706]
        exit('ITEMSEARCH');
        //+NPR5.45 [319706]
    end;

    local procedure "--- Item Search"()
    begin
    end;

    local procedure GetItemFromItemSearch(var ItemIdentifierString: Text) ItemFound: Boolean
    var
        Item: Record Item;
        ItemList: Page "Retail Item List";
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
        SetItemSearchFilter(ItemIdentifierString,Item);
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

    local procedure SetItemSearchFilter(ItemIdentifierString: Text;var Item: Record Item)
    var
        SearchFilter: Text;
        SearchString: Text;
    begin
        //-NPR5.45 [319706]
        Clear(Item);

        SearchString := CopyStr (ItemIdentifierString, 1, MaxStrLen (Item."Search Description"));
        SearchString := UpperCase(SearchString);
        SearchFilter := '*' + SearchString + '*';
        if ItemIdentifierString = '' then
          SearchFilter := StrSubstNo('=%1','');

        Item.SetCurrentKey("Search Description");
        Item.SetFilter("Search Description",SearchFilter);
        Item.SetRange(Blocked,false);
        Item.SetRange("Blocked on Pos",false);
        //+NPR5.45 [319706]
    end;
}

