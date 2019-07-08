codeunit 6150848 "POS Action - Adjust Inventory"
{
    // NPR5.39/MHA /20180206  CASE 299736 Object created - Inventory Adjustment from POS
    // NPR5.45/MHA /20180806  CASE 323812 Added Return Reason functionality


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Post Inventory Adjustment directly from POS';
        Text001: Label 'Adjust Inventory Quantity:';
        Text002: Label 'Inventory Adjustment:\- Item: %1 %2 %3\- Current Inventory: %4\- Adjust Quantity: %5\- New Inventory: %6\\Perform Inventory Adjustment?';
        Text003: Label 'Kindly select the Item to Adjust';
        Text004: Label 'Inventory: %1 || %2 %3 %4';
        Text005: Label 'Adjust Quantity %1 performed';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
          if DiscoverAction(
            ActionCode(),
            Text000,
            ActionVersion(),
            Type::Generic,
            "Subscriber Instances Allowed"::Multiple)
          then begin
            RegisterWorkflowStep('PromptQuantity','numpad({title: context.adjust_description, caption: labels.QtyCaption, value: context.quantity}).cancel(abort);');
            //-NPR5.45 [323812]
            RegisterWorkflowStep('FixedReturnReason','if (param.FixedReturnReason != "")  {respond()}');
            RegisterWorkflowStep('LookupReturnReason','if (param.LookupReturnReason)  {respond()}');
            //+NPR5.45 [323812]
            RegisterWorkflowStep('AdjustInventory','respond();');

            //-NPR5.45 [323812]
            RegisterTextParameter('FixedReturnReason','');
            RegisterBooleanParameter('LookupReturnReason',false);
            //+NPR5.45 [323812]
            RegisterWorkflow(true);

          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    var
        UI: Codeunit "POS UI Management";
    begin
        Captions.AddActionCaption(ActionCode,'QtyCaption',Text001);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "POS Action";Parameters: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SaleLinePOS: Record "Sale Line POS";
        JSON: Codeunit "POS JSON Management";
        POSSaleLine: Codeunit "POS Sale Line";
    begin
        if not Action.IsThisAction(ActionCode()) then
          exit;

        Handled := true;
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        if (SaleLinePOS.Type <> SaleLinePOS.Type::Item) or (SaleLinePOS."No." = '') then
          Error(Text003);

        if SaleLinePOS."Variant Code" <> '' then
          ItemVariant.Get(SaleLinePOS."No.",SaleLinePOS."Variant Code");

        Item.Get(SaleLinePOS."No.");
        Item.SetFilter("Variant Filter",SaleLinePOS."Variant Code");
        Item.SetFilter("Location Filter",SaleLinePOS."Location Code");
        Item.CalcFields(Inventory);

        JSON.SetContext('adjust_description',StrSubstNo(Text004,Item.Inventory,Item."No.",Item.Description,ItemVariant.Description));
        FrontEnd.SetActionContext(ActionCode(),JSON);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', true, true)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode()) then
          exit;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        case WorkflowStep of
          //-NPR5.45 [323815]
          'FixedReturnReason':
            begin
              Handled := true;
              OnActionFixedReturnReason(JSON,POSSession);
              FrontEnd.SetActionContext(ActionCode(),JSON);
              exit;
            end;
          'LookupReturnReason':
            begin
              Handled := true;
              OnActionLookupReturnReason(JSON,POSSession);
              FrontEnd.SetActionContext(ActionCode(),JSON);
              exit;
            end;
          //+NPR5.45 [323815]
          'AdjustInventory':
            begin
              Handled := true;
              OnActionAdjustInventory(JSON,POSSession);
              exit;
            end;
        end;
    end;

    local procedure OnActionAdjustInventory(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session")
    var
        Quantity: Decimal;
        ReturnReasonCode: Code[10];
        Test: Text;
    begin
        JSON.SetScope('$PromptQuantity',true);
        Quantity := JSON.GetDecimal('numpad',true);
        if Quantity = 0 then
          exit;

        //-NPR5.45 [323812]
        //PerformAdjustInventory(POSSession,Quantity);
        JSON.SetScope('/',true);
        ReturnReasonCode := JSON.GetString('ReturnReason',false);
        PerformAdjustInventory(POSSession,Quantity,ReturnReasonCode);
        //+NPR5.45 [323812]
    end;

    local procedure OnActionFixedReturnReason(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session")
    var
        ReturnReasonCode: Code[10];
        DiscountType: Integer;
    begin
        //-NPR5.45 [323812]
        JSON.SetScope('parameters',true);
        ReturnReasonCode := JSON.GetString('FixedReturnReason',true);
        if ReturnReasonCode = '' then
          exit;

        JSON.SetContext('ReturnReason',ReturnReasonCode);
        //+NPR5.45 [323812]
    end;

    local procedure OnActionLookupReturnReason(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session")
    var
        ReturnReasonCode: Code[10];
        ReturnReason: Record "Return Reason";
        DiscountType: Integer;
    begin
        //-NPR5.45 [323812]
        JSON.SetScope('parameters',true);
        ReturnReasonCode := JSON.GetString('FixedReturnReason',false);
        if ReturnReason.Get(ReturnReasonCode) then;
        if PAGE.RunModal(0,ReturnReason) <> ACTION::LookupOK then
          exit;

        JSON.SetContext('ReturnReason',ReturnReason.Code);
        //+NPR5.45 [323812]
    end;

    local procedure "-- Locals --"()
    begin
    end;

    local procedure PerformAdjustInventory(POSSession: Codeunit "POS Session";Quantity: Decimal;ReturnReasonCode: Code[10])
    var
        TempItemJnlLine: Record "Item Journal Line" temporary;
        SalePOS: Record "Sale POS";
        SaleLinePOS: Record "Sale Line POS";
        POSSale: Codeunit "POS Sale";
        POSSaleLine: Codeunit "POS Sale Line";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not ConfirmAdjustInventory(SaleLinePOS,Quantity) then
          exit;

        //-NPR5.45 [323812]
        //CreateItemJnlLine(SalePOS,SaleLinePOS,Quantity,TempItemJnlLine);
        CreateItemJnlLine(SalePOS,SaleLinePOS,Quantity,ReturnReasonCode,TempItemJnlLine);
        //+NPR5.45 [323812]
        PostItemJnlLine(TempItemJnlLine);

        Message(Text005,Quantity);
    end;

    local procedure ConfirmAdjustInventory(SaleLinePOS: Record "Sale Line POS";Quantity: Decimal) PerformAdjustInventory: Boolean
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
    begin
        if SaleLinePOS."Variant Code" <> '' then
          ItemVariant.Get(SaleLinePOS."No.",SaleLinePOS."Variant Code");

        Item.Get(SaleLinePOS."No.");
        Item.SetFilter("Variant Filter",SaleLinePOS."Variant Code");
        Item.SetFilter("Location Filter",SaleLinePOS."Location Code");
        Item.CalcFields(Inventory);

        PerformAdjustInventory := Confirm(Text002,true,Item."No.",Item.Description,ItemVariant.Description,Item.Inventory,Quantity,Item.Inventory + Quantity);
        exit(PerformAdjustInventory);
    end;

    local procedure CreateItemJnlLine(SalePOS: Record "Sale POS";SaleLinePOS: Record "Sale Line POS";Quantity: Decimal;ReturnReasonCode: Code[10];var TempItemJnlLine: Record "Item Journal Line" temporary)
    begin
        TempItemJnlLine.Init;
        TempItemJnlLine.Validate("Item No.",SaleLinePOS."No.");
        TempItemJnlLine.Validate("Posting Date",Today);
        TempItemJnlLine."Document No." := SaleLinePOS."Sales Ticket No.";
        TempItemJnlLine."Register Number" := SaleLinePOS."Register No.";
        TempItemJnlLine."Document Time" := Time;
        if SaleLinePOS."Variant Code" <> '' then
          TempItemJnlLine.Validate("Variant Code",SaleLinePOS."Variant Code");
        TempItemJnlLine.Validate("Entry Type",TempItemJnlLine."Entry Type"::"Positive Adjmt.");
        if Quantity < 0 then
          TempItemJnlLine.Validate("Entry Type",TempItemJnlLine."Entry Type"::"Negative Adjmt.");
        TempItemJnlLine.Validate(Quantity,Abs(Quantity));
        //-NPR5.45 [323812]
        if ReturnReasonCode <> '' then
          TempItemJnlLine.Validate("Return Reason Code",ReturnReasonCode);
        //+NPR5.45 [323812]
        TempItemJnlLine.Validate("Location Code",SaleLinePOS."Location Code");
        TempItemJnlLine.Validate("Shortcut Dimension 1 Code",SaleLinePOS."Shortcut Dimension 1 Code");
        TempItemJnlLine.Validate("Shortcut Dimension 2 Code",SaleLinePOS."Shortcut Dimension 2 Code");
        TempItemJnlLine.Validate("Salespers./Purch. Code",SalePOS."Salesperson Code");
        TempItemJnlLine.Insert;
    end;

    local procedure PostItemJnlLine(var TempItemJnlLine: Record "Item Journal Line" temporary)
    var
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin
        ItemJnlPostLine.Run(TempItemJnlLine);
    end;

    local procedure ActionCode(): Text
    begin
        exit ('ADJUST_INVENTORY');
    end;

    local procedure ActionVersion(): Text
    begin
        //-NPR5.45 [323812]
        exit('1.1');
        //+NPR5.45 [323812]
        exit ('1.0');
    end;
}

