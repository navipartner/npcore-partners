codeunit 6150813 "NPR POS Action: Item Lookup"
{
    var
        ActionDescription: Label 'This is a built in function for handling lookup';
        Setup: Codeunit "NPR POS Setup";
        LookupType: Option Item,Customer,SKU;

    local procedure ActionCode(): Text
    begin
        exit('LOOKUP');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.4');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
          ActionCode(),
          ActionDescription,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple) then begin
            //No UI yet to support lookup, so no trancendance UI worksteps

            Sender.RegisterWorkflowStep('do_lookup', 'respond();');
            Sender.RegisterWorkflowStep('complete_lookup', 'respond();');
            Sender.RegisterWorkflow(false);
            Sender.RegisterOptionParameter('LookupType', CreateOptionString, '');
            Sender.RegisterTextParameter('View', '');
            Sender.RegisterOptionParameter('LocationFilter', 'POS Store,Cash Register,Use View', 'POS Store');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        case WorkflowStep of
            'do_lookup':
                OnLookup(POSSession, FrontEnd, Context);
            'complete_lookup':
                CompleteLookup(POSSession, FrontEnd, Context);
        end;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; Parameters: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Context: Codeunit "NPR POS JSON Management";
        JSON: Codeunit "NPR POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        //No UI yet to support lookup
        Handled := true;
    end;

    local procedure OnLookup(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Context: JsonObject)
    var
        JSON: Codeunit "NPR POS JSON Management";
    begin
        //xx FrontEnd.PauseWorkflow; //This function does a NAV page lookup and need input before next workstep

        JSON.InitializeJObjectParser(Context, FrontEnd);

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScope('parameters', true);

        LookupType := JSON.GetInteger('LookupType', true);

        case LookupType of
            LookupType::Item:
                begin
                    OnLookupItem(POSSession, FrontEnd, Context);
                end;

            LookupType::Customer:
                begin
                    //Not yet implementet
                end;

            LookupType::SKU:
                begin
                    OnLookupSKU(POSSession, FrontEnd, Context);
                end;
            else begin
                    Error('LookUp type %1 is not supported.', Format(LookupType));
                end;
        end;

        //xx FrontEnd.ResumeWorkflow;

        exit; //debug
    end;

    local procedure OnLookupItem(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Context: JsonObject)
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        Item: Record Item;
        SaleLinePOS: Record "NPR Sale Line POS";
        ItemNo: Code[20];
        ItemView: Text;
        LocationFilterOption: Integer;
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);

        JSON.SetScope('parameters', true);
        ItemView := JSON.GetString('View', false);
        if ItemView <> '' then
            Item.SetView(ItemView);

        LocationFilterOption := JSON.GetInteger('LocationFilter', false);
        case LocationFilterOption of
            -1, 0:
                Item.SetFilter("Location Filter", '=%1', GetStoreLocation(POSSession));
            1:
                Item.SetFilter("Location Filter", '=%1', GetStoreLocation(POSSession));
        end;

        Item.SetFilter(Blocked, '=%1', false);
        Item.SetFilter("NPR Blocked on Pos", '=%1', false);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        if SaleLinePOS.Type = SaleLinePOS.Type::Item then
            if Item.Get(SaleLinePOS."No.") then;

        if PAGE.RunModal(PAGE::"Item List", Item) = ACTION::LookupOK then
            ItemNo := Item."No.";

        JSON.SetContext('selected_itemno', ItemNo);
        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure CompleteLookup(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Context: JsonObject)
    var
        JSON: Codeunit "NPR POS JSON Management";
        ItemList: Page "Item List";
        Item: Record Item;
        ItemNo: Code[20];
        ItemView: Text;
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);
        ItemNo := JSON.GetString('selected_itemno', true);
        if ItemNo = '' then begin
            exit;
        end else begin
            AddItemToSale(ItemNo, POSSession, FrontEnd, Context);
        end;
    end;

    local procedure OnLookupSKU(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Context: JsonObject)
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSSetup: Codeunit "NPR POS Setup";
        StockkeepingUnitList: Page "Stockkeeping Unit List";
        StockkeepingUnit: Record "Stockkeeping Unit";
        POSStore: Record "NPR POS Store";
        ItemNo: Code[20];
        SKUView: Text;
        LocationFilterOption: Integer;
    begin

        JSON.InitializeJObjectParser(Context, FrontEnd);
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSStore(POSStore);

        JSON.SetScope('parameters', true);
        SKUView := JSON.GetString('View', false);
        if SKUView <> '' then
            StockkeepingUnit.SetView(SKUView);

        LocationFilterOption := JSON.GetInteger('LocationFilter', false);
        case LocationFilterOption of
            -1, 0:
                StockkeepingUnit.SetFilter("Location Code", '=%1', GetStoreLocation(POSSession));
            1:
                StockkeepingUnit.SetFilter("Location Code", '=%1', GetStoreLocation(POSSession));
        end;

        StockkeepingUnitList.Editable(false);
        StockkeepingUnitList.LookupMode(true);
        StockkeepingUnitList.SetTableView(StockkeepingUnit);
        if StockkeepingUnitList.RunModal = ACTION::LookupOK then begin
            StockkeepingUnitList.GetRecord(StockkeepingUnit);
            ItemNo := StockkeepingUnit."Item No.";
        end else begin
            ItemNo := '';
        end;

        JSON.SetContext('selected_itemno', ItemNo);
        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure AddItemToSale(ItemNo: Code[20]; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Context: JsonObject)
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        Setup: Codeunit "NPR POS Setup";
        NewSaleLinePOS: Record "NPR Sale Line POS";
        Register: Record "NPR Register";
        POSSetup: Record "NPR POS Setup";
        POSAction: Record "NPR POS Action";
    begin
        if ItemNo = '' then exit;

        POSSession.GetSetup(Setup);
        Setup.GetNamedActionSetup(POSSetup);

        if not POSSession.RetrieveSessionAction(POSSetup."Item Insert Action Code", POSAction) then
            POSAction.Get(POSSetup."Item Insert Action Code");

        POSAction.SetWorkflowInvocationParameter('itemNo', ItemNo, FrontEnd);
        POSAction.SetWorkflowInvocationParameter('itemQuantity', 1, FrontEnd);
        POSAction.SetWorkflowInvocationParameter('itemIdentifyerType', 0, FrontEnd); //0 = ItemNumber
        FrontEnd.InvokeWorkflow(POSAction);
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
                OptionString := CopyStr(OptionString, 1, StrLen(OptionString) - 1);
                StopRepeat := true;
            end else begin
                OptionString := OptionString + CurrentOptionString + ',';
            end;
            OptionInteger += 1;
        until (StopRepeat);
    end;

    local procedure GetStoreLocation(POSSession: Codeunit "NPR POS Session"): Code[10]
    var
        POSSetup: Codeunit "NPR POS Setup";
        POSStore: Record "NPR POS Store";
    begin
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSStore(POSStore);

        exit(POSStore."Location Code");
    end;
}

