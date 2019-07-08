codeunit 6150813 "POS Action - Item Lookup"
{
    // NPR5.34/BR  /20170710  CASE 283668 Added option to Lookup SKU's
    // NPR5.34/BR  /20170724  CASE 284814  Added possibility to set a tableview
    // NPR5.36/TSA /20171003  CASE 292281 Trans. Issue with Variuos Item Sales Price
    // NPR5.40/VB  /20180306  CASE 306347 Refactored InvokeWorkflow call.
    // NPR5.41/TSA /20180411  CASE 308522 Added Action option to filter item and SKU on location code from POS Store or Cash Register
    // NPR5.41/TSA /20180412  CASE 311104 Refactoring runmodal and invoke workflow as 2 step rather than one, since the workflow order gets out of sequence.
    // NPR5.46/MHA /20180925  CASE 329616 Position should be set based on current Sales Line in OnLookupItem()


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built in function for handling lookup';
        Setup: Codeunit "POS Setup";
        LookupType: Option Item,Customer,SKU;

    local procedure ActionCode(): Text
    begin
        exit ('LOOKUP');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.3');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do begin
          if DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple) then
          begin
            //No UI yet to support lookup, so no trancendance UI worksteps

            RegisterWorkflowStep('do_lookup','respond();');
            //-NPR5.41 [311104]
            RegisterWorkflowStep('complete_lookup','respond();');
            //+NPR5.41 [311104]

            RegisterWorkflow(false);
            RegisterOptionParameter('LookupType',CreateOptionString,'');
            RegisterTextParameter('View','');

            //-NPR5.41 [308522]
            RegisterOptionParameter('LocationFilter', 'POS Store,Cash Register,Use View', 'POS Store');
            //+NPR5.41 [308522]

          end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;


        case WorkflowStep of
          'do_lookup': OnLookup(POSSession,FrontEnd,Context);
          //-NPR5.41 [311104]
          'complete_lookup': CompleteLookup(POSSession,FrontEnd,Context);
          //+NPR5.41 [311104]
        end;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "POS Action";Parameters: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        Context: Codeunit "POS JSON Management";
        JSON: Codeunit "POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        //No UI yet to support lookup
        Handled := true;
    end;

    local procedure "--"()
    begin
    end;

    local procedure OnLookup(POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";Context: DotNet npNetJObject)
    var
        JSON: Codeunit "POS JSON Management";
    begin
        //xx FrontEnd.PauseWorkflow; //This function does a NAV page lookup and need input before next workstep

        JSON.InitializeJObjectParser(Context,FrontEnd);

        JSON.InitializeJObjectParser(Context,FrontEnd);
        JSON.SetScope('parameters',true);

        LookupType := JSON.GetInteger('LookupType',true);

        case LookupType of
          LookupType::Item :
            begin
              OnLookupItem(POSSession, FrontEnd, Context);
            end;

          LookupType::Customer :
            begin
              //Not yet implementet
            end;

          //-NPR5.34 [283668]
          LookupType::SKU :
            begin
              OnLookupSKU(POSSession, FrontEnd, Context);
            end;
          //+NPR5.34 [283668]

        else
          begin
            Error('LookUp type %1 is not supported.', Format(LookupType));
          end;
        end;

        //xx FrontEnd.ResumeWorkflow;

        exit; //debug
    end;

    local procedure OnLookupItem(POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";Context: DotNet npNetJObject)
    var
        JSON: Codeunit "POS JSON Management";
        POSSaleLine: Codeunit "POS Sale Line";
        Item: Record Item;
        SaleLinePOS: Record "Sale Line POS";
        ItemNo: Code[20];
        ItemView: Text;
        LocationFilterOption: Integer;
    begin
        JSON.InitializeJObjectParser(Context,FrontEnd);

        JSON.SetScope('parameters',true);
        ItemView := JSON.GetString('View',false);
        if ItemView <> '' then
          Item.SetView(ItemView);

        //-NPR5.41 [308522]
        LocationFilterOption := JSON.GetInteger ('LocationFilter', false);
        case LocationFilterOption of
          -1, 0 : Item.SetFilter ("Location Filter", '=%1', GetStoreLocation (POSSession));
          1 : Item.SetFilter ("Location Filter", '=%1', GetRegisterLocation (POSSession));
        end;
        //+NPR5.41 [308522]

        Item.SetFilter(Blocked, '=%1', false);
        Item.SetFilter("Blocked on Pos", '=%1', false);

        //-NPR5.46 [329616]
        // ItemList.EDITABLE(FALSE);
        // ItemList.LOOKUPMODE(TRUE);
        // ItemList.SETTABLEVIEW(Item);
        // IF ItemList.RUNMODAL = ACTION::LookupOK THEN BEGIN
        //  ItemList.GETRECORD(Item);
        //  ItemNo := Item."No.";
        // END ELSE BEGIN
        //  ItemNo := '';
        // END;
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        if SaleLinePOS.Type = SaleLinePOS.Type::Item then
          if Item.Get(SaleLinePOS."No.") then;

        if PAGE.RunModal(PAGE::"Retail Item List",Item) = ACTION::LookupOK then
          ItemNo := Item."No.";
        //+NPR5.46 [329616]

        //-NPR5.41 [311104]
        JSON.SetContext ('selected_itemno', ItemNo);
        FrontEnd.SetActionContext (ActionCode(), JSON);
        // IF ItemNo = '' THEN BEGIN
        //  EXIT;
        // END ELSE BEGIN
        //   AddItemToSale(ItemNo, POSSession, FrontEnd, Context);
        // END;
        //+NPR5.41 [311104]
    end;

    local procedure CompleteLookup(POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";Context: DotNet npNetJObject)
    var
        JSON: Codeunit "POS JSON Management";
        ItemList: Page "Retail Item List";
        Item: Record Item;
        ItemNo: Code[20];
        ItemView: Text;
    begin

        //-NPR5.41 [311104]
        JSON.InitializeJObjectParser(Context,FrontEnd);
        ItemNo := JSON.GetString ('selected_itemno', true);
        if ItemNo = '' then begin
          exit;
        end else begin
          AddItemToSale(ItemNo, POSSession, FrontEnd, Context);
        end;
        //+NPR5.41 [311104]
    end;

    local procedure OnLookupSKU(POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";Context: DotNet npNetJObject)
    var
        JSON: Codeunit "POS JSON Management";
        POSSetup: Codeunit "POS Setup";
        StockkeepingUnitList: Page "Stockkeeping Unit List";
        StockkeepingUnit: Record "Stockkeeping Unit";
        POSStore: Record "POS Store";
        ItemNo: Code[20];
        SKUView: Text;
        LocationFilterOption: Integer;
    begin

        JSON.InitializeJObjectParser(Context,FrontEnd);
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSStore(POSStore);

        JSON.SetScope('parameters',true);
        SKUView := JSON.GetString('View',false);
        if SKUView <> '' then
          StockkeepingUnit.SetView(SKUView);

        //-NPR5.41 [308522]
        LocationFilterOption := JSON.GetInteger ('LocationFilter', false);
        case LocationFilterOption of
          -1, 0 : StockkeepingUnit.SetFilter ("Location Code", '=%1', GetStoreLocation (POSSession));
          1 : StockkeepingUnit.SetFilter ("Location Code", '=%1', GetRegisterLocation (POSSession));
        end;
        //StockkeepingUnit.SETFILTER("Location Code", '=%1',POSStore."Location Code");
        //+NPR5.41 [308522]

        StockkeepingUnitList.Editable(false);
        StockkeepingUnitList.LookupMode(true);
        StockkeepingUnitList.SetTableView(StockkeepingUnit);
        if StockkeepingUnitList.RunModal = ACTION::LookupOK then begin
          StockkeepingUnitList.GetRecord(StockkeepingUnit);
          ItemNo := StockkeepingUnit."Item No.";
        end else begin
          ItemNo := '';
        end;

        //-NPR5.41 [311104]
        JSON.SetContext ('selected_itemno', ItemNo);
        FrontEnd.SetActionContext (ActionCode(), JSON);
        // IF ItemNo = '' THEN BEGIN
        //  EXIT;
        // END ELSE BEGIN
        //   AddItemToSale(ItemNo, POSSession, FrontEnd, Context);
        // END;
        //+NPR5.41 [311104]
    end;

    local procedure AddItemToSale(ItemNo: Code[20];POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";Context: DotNet npNetJObject)
    var
        POSSaleLine: Codeunit "POS Sale Line";
        NewSaleLinePOS: Record "Sale Line POS";
        Register: Record Register;
        POSSetup: Record "POS Setup";
        POSAction: Record "POS Action";
    begin
        if ItemNo = '' then exit;

        //-NPR5.36 [292281]
        POSSetup.Get ();
        //-NPR5.40 [306347]
        //POSAction.GET (POSSetup."Item Insert Action Code");
        if not POSSession.RetrieveSessionAction(POSSetup."Item Insert Action Code",POSAction) then
          POSAction.Get (POSSetup."Item Insert Action Code");
        //+NPR5.40 [306347]
        POSAction.SetWorkflowInvocationParameter ('itemNo', ItemNo, FrontEnd);
        POSAction.SetWorkflowInvocationParameter ('itemQuantity', 1, FrontEnd);
        POSAction.SetWorkflowInvocationParameter ('itemIdentifyerType', 0, FrontEnd); //0 = ItemNumber
        FrontEnd.InvokeWorkflow (POSAction);

        // POSSession.GetSaleLine(POSSaleLine);
        // POSSaleLine.GetNewSaleLine(NewSaleLinePOS);
        //
        //
        // WITH NewSaleLinePOS DO BEGIN
        //  Type := NewSaleLinePOS.Type::Item;
        //  "Sale Type" := "Sale Type"::Sale;
        //  "No." := ItemNo;
        //  Quantity := 1;
        //  POSSaleLine.InsertLine(NewSaleLinePOS);
        // END;
        //
        // POSSession.RequestRefreshData();
        //+NPR5.36 [292281]
    end;

    local procedure CreateOptionString() OptionString: Text
    var
        OptionInteger: Integer;
        StopRepeat: Boolean;
        CurrentOptionString: Text;
    begin

        OptionInteger := 0;
        repeat
          LookupType := OptionInteger;
          CurrentOptionString := Format(LookupType);
          if Format(OptionInteger) = CurrentOptionString then begin
             OptionString := CopyStr(OptionString, 1, StrLen(OptionString)-1);
             StopRepeat := true;
          end else begin
            OptionString := OptionString + CurrentOptionString + ',';
          end;
          OptionInteger += 1;
        until (StopRepeat);
    end;

    local procedure GetStoreLocation(POSSession: Codeunit "POS Session"): Code[10]
    var
        POSSetup: Codeunit "POS Setup";
        POSStore: Record "POS Store";
    begin

        //-NPR5.41 [308522]
        POSSession.GetSetup (POSSetup);
        POSSetup.GetPOSStore (POSStore);

        exit (POSStore."Location Code");
        //+NPR5.41 [308522]
    end;

    local procedure GetRegisterLocation(POSSession: Codeunit "POS Session"): Code[10]
    var
        POSSetup: Codeunit "POS Setup";
        Register: Record Register;
    begin

        //-NPR5.41 [308522]
        POSSession.GetSetup (POSSetup);
        POSSetup.GetRegisterRecord (Register);

        exit (Register."Location Code");
        //+NPR5.41 [308522]
    end;
}

