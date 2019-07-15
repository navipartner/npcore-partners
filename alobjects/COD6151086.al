codeunit 6151086 "POS Action - Retail Inventory"
{
    // NPR5.40/MHA /20180320  CASE 307025 Object created - Retail Inventory Set
    // NPR5.46/MHA /20180910  CASE 326622 Changed from PAGE.RUN to PAGE.RUNMODAL to fix issue with focus


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'This is a built-in action for Inventory Lookup using Retail Inventory Set';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
          if Sender.DiscoverAction(
            ActionCode(),
            Text000,
            ActionVersion,
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Single)
          then begin
            RegisterWorkflowStep('ProcessInventorySet','respond();');

            RegisterTextParameter('FixedInventorySetCode','');
            RegisterWorkflow(false);
            RegisterDataBinding();
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        JSON.InitializeJObjectParser(Context,FrontEnd);

        case WorkflowStep of
          'ProcessInventorySet':
            begin
              Handled := true;

              OnActionProcessInventorySet(POSSession,JSON);
            end;
          else
            exit;
        end;
    end;

    local procedure OnActionProcessInventorySet(POSSession: Codeunit "POS Session";JSON: Codeunit "POS JSON Management")
    var
        RetailInventoryBuffer: Record "RIS Retail Inventory Buffer" temporary;
        RetailInventorySet: Record "RIS Retail Inventory Set";
        SaleLinePOS: Record "Sale Line POS";
        POSSaleLine: Codeunit "POS Sale Line";
        RetailInventorySetMgt: Codeunit "RIS Retail Inventory Set Mgt.";
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLinePOS.TestField(Type,SaleLinePOS.Type::Item);
        SaleLinePOS.TestField("No.");

        if not SelectRetailInventorySetCode(JSON,RetailInventorySet) then
          exit;

        RetailInventorySetMgt.ProcessInventorySet(RetailInventorySet,SaleLinePOS."No.",SaleLinePOS."Variant Code",RetailInventoryBuffer);
        //-NPR5.46 [326622]
        //PAGE.RUN(0,RetailInventoryBuffer);
        PAGE.RunModal(0,RetailInventoryBuffer);
        //+NPR5.46 [326622]
    end;

    local procedure SelectRetailInventorySetCode(JSON: Codeunit "POS JSON Management";var RetailInventorySet: Record "RIS Retail Inventory Set") EntrySetSelected: Boolean
    var
        FixedInventorySetCode: Text;
    begin
        FixedInventorySetCode := CopyStr(UpperCase(JSON.GetStringParameter('FixedInventorySetCode',false)),1,MaxStrLen(RetailInventorySet.Code));
        if (FixedInventorySetCode <> '') and RetailInventorySet.Get(FixedInventorySetCode) then
          exit(true);

        RetailInventorySet.FindLast;
        FixedInventorySetCode := RetailInventorySet.Code;
        RetailInventorySet.FindFirst;
        if FixedInventorySetCode = RetailInventorySet.Code then
          exit(true);

        EntrySetSelected := PAGE.RunModal(0,RetailInventorySet) = ACTION::LookupOK;
        exit(EntrySetSelected);
    end;

    local procedure ActionCode(): Text
    begin
        exit('RETAIL_INVENTORY');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.0');
    end;
}

