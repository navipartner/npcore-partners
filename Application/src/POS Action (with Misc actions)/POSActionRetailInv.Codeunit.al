codeunit 6151086 "NPR POS Action - Retail Inv."
{
    // NPR5.40/MHA /20180320  CASE 307025 Object created - Retail Inventory Set
    // NPR5.46/MHA /20180910  CASE 326622 Changed from PAGE.RUN to PAGE.RunModal() to fix issue with focus


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'This is a built-in action for Inventory Lookup using Retail Inventory Set';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
  ActionCode(),
  Text000,
  ActionVersion(),
  Sender.Type::Generic,
  Sender."Subscriber Instances Allowed"::Single)
then begin
            Sender.RegisterWorkflowStep('ProcessInventorySet', 'respond();');

            Sender.RegisterTextParameter('FixedInventorySetCode', '');
            Sender.RegisterWorkflow(false);
            Sender.RegisterDataBinding();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);

        case WorkflowStep of
            'ProcessInventorySet':
                begin
                    Handled := true;

                    OnActionProcessInventorySet(POSSession, JSON);
                end;
            else
                exit;
        end;
    end;

    local procedure OnActionProcessInventorySet(POSSession: Codeunit "NPR POS Session"; JSON: Codeunit "NPR POS JSON Management")
    var
        RetailInventoryBuffer: Record "NPR RIS Retail Inv. Buffer" temporary;
        RetailInventorySet: Record "NPR RIS Retail Inv. Set";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        RetailInventorySetMgt: Codeunit "NPR RIS Retail Inv. Set Mgt.";
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLinePOS.TestField(Type, SaleLinePOS.Type::Item);
        SaleLinePOS.TestField("No.");

        if not SelectRetailInventorySetCode(JSON, RetailInventorySet) then
            exit;

        RetailInventorySetMgt.ProcessInventorySet(RetailInventorySet, SaleLinePOS."No.", SaleLinePOS."Variant Code", RetailInventoryBuffer);
        //-NPR5.46 [326622]
        //PAGE.RUN(0,RetailInventoryBuffer);
        PAGE.RunModal(0, RetailInventoryBuffer);
        //+NPR5.46 [326622]
    end;

    local procedure SelectRetailInventorySetCode(JSON: Codeunit "NPR POS JSON Management"; var RetailInventorySet: Record "NPR RIS Retail Inv. Set") EntrySetSelected: Boolean
    var
        FixedInventorySetCode: Text;
    begin
        FixedInventorySetCode := CopyStr(UpperCase(JSON.GetStringParameter('FixedInventorySetCode')), 1, MaxStrLen(RetailInventorySet.Code));
        if (FixedInventorySetCode <> '') and RetailInventorySet.Get(FixedInventorySetCode) then
            exit(true);

        RetailInventorySet.FindLast();
        FixedInventorySetCode := RetailInventorySet.Code;
        RetailInventorySet.FindFirst();
        if FixedInventorySetCode = RetailInventorySet.Code then
            exit(true);

        EntrySetSelected := PAGE.RunModal(0, RetailInventorySet) = ACTION::LookupOK;
        exit(EntrySetSelected);
    end;

    local procedure ActionCode(): Text
    begin
        exit('RETAIL_INVENTORY');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;
}

