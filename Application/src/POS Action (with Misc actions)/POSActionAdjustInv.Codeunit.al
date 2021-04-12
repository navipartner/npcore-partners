codeunit 6150848 "NPR POS Action: Adjust Inv."
{
    var
        Text000: Label 'Post Inventory Adjustment directly from POS';
        Text001: Label 'Adjust Inventory Quantity';
        Text002: Label 'Inventory Adjustment:\- Item: %1 %2 %3\- Current Inventory: %4\- Adjust Quantity: %5\- New Inventory: %6\\Perform Inventory Adjustment?';
        Text003: Label 'Kindly select the Item to Adjust';
        Text004: Label 'Inventory: %1 || %2 %3 %4';
        Text005: Label 'Adjust Quantity %1 performed';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
  ActionCode(),
  Text000,
  ActionVersion(),
  Sender.Type::Generic,
  Sender."Subscriber Instances Allowed"::Multiple)
then begin
            Sender.RegisterWorkflowStep('PromptQuantity', 'numpad({title: context.adjust_description, caption: labels.QtyCaption, value: context.quantity}).cancel(abort);');
            Sender.RegisterWorkflowStep('FixedReturnReason', 'if (param.FixedReturnReason != "")  {respond()}');
            Sender.RegisterWorkflowStep('LookupReturnReason', 'if (param.LookupReturnReason)  {respond()}');
            Sender.RegisterWorkflowStep('AdjustInventory', 'respond();');

            Sender.RegisterTextParameter('FixedReturnReason', '');
            Sender.RegisterBooleanParameter('LookupReturnReason', false);
            Sender.RegisterOptionParameter('InputAdjustment', 'perform only Negative Adjustment,perform only Positive Adjustment,perform both Negative and Positive Adjustment', 'perform both Negative and Positive Adjustment');
            Sender.RegisterWorkflow(true);

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'QtyCaption', Text001);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; Parameters: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SaleLinePOS: Record "NPR POS Sale Line";
        JSON: Codeunit "NPR POS JSON Management";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        if (SaleLinePOS.Type <> SaleLinePOS.Type::Item) or (SaleLinePOS."No." = '') then
            Error(Text003);

        if SaleLinePOS."Variant Code" <> '' then
            ItemVariant.Get(SaleLinePOS."No.", SaleLinePOS."Variant Code");

        Item.Get(SaleLinePOS."No.");
        Item.SetFilter("Variant Filter", SaleLinePOS."Variant Code");
        Item.SetFilter("Location Filter", SaleLinePOS."Location Code");
        Item.CalcFields(Inventory);

        JSON.SetContext('adjust_description', StrSubstNo(Text004, Item.Inventory, Item."No.", Item.Description, ItemVariant.Description));
        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', true, true)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        case WorkflowStep of
            'FixedReturnReason':
                begin
                    Handled := true;
                    OnActionFixedReturnReason(JSON, POSSession);
                    FrontEnd.SetActionContext(ActionCode(), JSON);
                    exit;
                end;
            'LookupReturnReason':
                begin
                    Handled := true;
                    OnActionLookupReturnReason(JSON, POSSession);
                    FrontEnd.SetActionContext(ActionCode(), JSON);
                    exit;
                end;
            'AdjustInventory':
                begin
                    Handled := true;
                    OnActionAdjustInventory(JSON, POSSession);
                    exit;
                end;
        end;
    end;

    local procedure OnActionAdjustInventory(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        Quantity: Decimal;
        ReturnReasonCode: Code[10];
        SettingScopeErr: Label 'setting scope in OnActionAdjustInventory';
        ReadingErr: Label 'reading in OnActionAdjustInventory';
    begin
        JSON.SetScope('$PromptQuantity', SettingScopeErr);
        Quantity := JSON.GetDecimalOrFail('numpad', ReadingErr);
        if Quantity = 0 then
            exit;

        JSON.SetScopeRoot();
        ReturnReasonCode := JSON.GetString('ReturnReason');

        JSON.SetScopeParameters(ActionCode());
        case JSON.GetIntegerOrFail('InputAdjustment', ReadingErr) of
            0:
                Quantity := -Abs(Quantity);
            1:
                Quantity := Abs(Quantity);
        end;

        PerformAdjustInventory(POSSession, Quantity, ReturnReasonCode);
    end;

    local procedure OnActionFixedReturnReason(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        ReturnReasonCode: Code[10];
        ReadingErr: Label 'reading in OnActionFixedReturnReason';
    begin
        JSON.SetScopeParameters(ActionCode());
        ReturnReasonCode := JSON.GetStringOrFail('FixedReturnReason', ReadingErr);
        if ReturnReasonCode = '' then
            exit;

        JSON.SetContext('ReturnReason', ReturnReasonCode);
    end;

    local procedure OnActionLookupReturnReason(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        ReturnReasonCode: Code[10];
        ReturnReason: Record "Return Reason";
    begin
        JSON.SetScopeParameters(ActionCode());
        ReturnReasonCode := JSON.GetString('FixedReturnReason');
        if ReturnReason.Get(ReturnReasonCode) then;
        if PAGE.RunModal(0, ReturnReason) <> ACTION::LookupOK then
            exit;

        JSON.SetContext('ReturnReason', ReturnReason.Code);
    end;

    local procedure "-- Locals --"()
    begin
    end;

    local procedure PerformAdjustInventory(POSSession: Codeunit "NPR POS Session"; Quantity: Decimal; ReturnReasonCode: Code[10])
    var
        TempItemJnlLine: Record "Item Journal Line" temporary;
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not ConfirmAdjustInventory(SaleLinePOS, Quantity) then
            exit;

        CreateItemJnlLine(SalePOS, SaleLinePOS, Quantity, ReturnReasonCode, TempItemJnlLine);
        PostItemJnlLine(TempItemJnlLine);

        Message(Text005, Quantity);
    end;

    local procedure ConfirmAdjustInventory(SaleLinePOS: Record "NPR POS Sale Line"; Quantity: Decimal) PerformAdjustInventory: Boolean
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
    begin
        if SaleLinePOS."Variant Code" <> '' then
            ItemVariant.Get(SaleLinePOS."No.", SaleLinePOS."Variant Code");

        Item.Get(SaleLinePOS."No.");
        Item.SetFilter("Variant Filter", SaleLinePOS."Variant Code");
        Item.SetFilter("Location Filter", SaleLinePOS."Location Code");
        Item.CalcFields(Inventory);

        PerformAdjustInventory := Confirm(Text002, true, Item."No.", Item.Description, ItemVariant.Description, Item.Inventory, Quantity, Item.Inventory + Quantity);
        exit(PerformAdjustInventory);
    end;

    local procedure CreateItemJnlLine(SalePOS: Record "NPR POS Sale"; SaleLinePOS: Record "NPR POS Sale Line"; Quantity: Decimal; ReturnReasonCode: Code[10]; var TempItemJnlLine: Record "Item Journal Line" temporary)
    begin
        TempItemJnlLine.Init();
        TempItemJnlLine.Validate("Item No.", SaleLinePOS."No.");
        TempItemJnlLine.Validate("Posting Date", Today);
        TempItemJnlLine."Document No." := SaleLinePOS."Sales Ticket No.";
        TempItemJnlLine."NPR Register Number" := SaleLinePOS."Register No.";
        TempItemJnlLine."NPR Document Time" := Time;
        if SaleLinePOS."Variant Code" <> '' then
            TempItemJnlLine.Validate("Variant Code", SaleLinePOS."Variant Code");
        TempItemJnlLine.Validate("Entry Type", TempItemJnlLine."Entry Type"::"Positive Adjmt.");
        if Quantity < 0 then
            TempItemJnlLine.Validate("Entry Type", TempItemJnlLine."Entry Type"::"Negative Adjmt.");
        TempItemJnlLine.Validate(Quantity, Abs(Quantity));
        if ReturnReasonCode <> '' then
            TempItemJnlLine.Validate("Return Reason Code", ReturnReasonCode);
        TempItemJnlLine.Validate("Location Code", SaleLinePOS."Location Code");
        TempItemJnlLine.Validate("Shortcut Dimension 1 Code", SaleLinePOS."Shortcut Dimension 1 Code");
        TempItemJnlLine.Validate("Shortcut Dimension 2 Code", SaleLinePOS."Shortcut Dimension 2 Code");
        TempItemJnlLine.Validate("Salespers./Purch. Code", SalePOS."Salesperson Code");
        TempItemJnlLine.Insert();
    end;

    local procedure PostItemJnlLine(var TempItemJnlLine: Record "Item Journal Line" temporary)
    var
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin
        ItemJnlPostLine.Run(TempItemJnlLine);
    end;

    local procedure ActionCode(): Text
    begin
        exit('ADJUST_INVENTORY');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.4');
    end;
}
