codeunit 6014576 "NPR POS Action Add Barcode"
{
    local procedure ActionCode(): Code[20]
    begin
        exit('ADD_BARCODE');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.1');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction20(
          ActionCode(),
          ActionDescription,
          ActionVersion()) then begin
            Sender.RegisterWorkflow20(
              'let result = await popup.input({title: $captions.title, caption: $captions.barcodeprompt});' +
              'if (result === null) {' +
              '    return;' +
              '}' +
              'await workflow.respond("", { BarCode: result });'
            );
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'title', Title);
        Captions.AddActionCaption(ActionCode(), 'barcodeprompt', BarcodePrompt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        ConfirmQst: Label 'Bar Code %1 already exists for item %2. Do you want to continue?';
        MultipleItemQst: Label 'Bar Code %1 already exists for multiple items. Do you want to continue?';
        TooLongErr: Label 'Bar Code cannot have more than 50 characters.';
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;
        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
        BarCodeAll := Context.GetString('BarCode');
        if StrLen(BarCodeAll) > 50 then
            Error(TooLongErr);

        BarCode := CopyStr(BarCodeAll, 1, 50);

        ItemReference.SetRange("Reference No.", BarCode);
        if ItemReference.FindFirst() then
            if ItemReference.Count > 1 then begin
                if not Confirm(MultipleItemQst, false, BarCode, ItemReference."Item No.") then
                    exit;
            end else
                if not Confirm(ConfirmQst, false, BarCode, ItemReference."Item No.") then
                    exit;
        InputBarcode(BarCode);

    end;

    local procedure InputBarcode(ReferenceNo: Code[50])
    var
        ItemVariant: Record "Item Variant";
        InputItem: Page "NPR Input Item";
        ItemNo: Code[20];
        ItemUOM: Code[10];
        VariantCode: Code[10];
        RecordErr: Label 'Record %1 already exists';
    begin

        InputItem.LookupMode(true);
        if InputItem.RunModal() <> Action::LookupOk then
            Error('');
        InputItem.GetValues(ItemNo, VariantCode, ItemUOM);

        Item.Get(ItemNo);
        ItemReference.Init();
        ItemReference."Reference Type" := ItemReference."Reference Type"::"Bar Code";
        ItemReference."Reference No." := ReferenceNo;
        ItemReference."Item No." := Item."No.";
        ItemReference.Description := Item.Description;
        if VariantCode <> '' then begin
            ItemVariant.Get(ItemNo, VariantCode);
            ItemReference."Variant Code" := VariantCode;
            if ItemVariant.Description <> '' then
                ItemReference.Description := ItemVariant.Description;
        end;
        ItemReference."Unit of Measure" := ItemUOM;
        if ItemReference.Insert(true) then
            Message(BarcodeAddedMsg, ReferenceNo, ItemNo)
        else
            Message(RecordErr, ItemReference.RecordId);
    end;

    var
        BarcodeAddedMsg: Label 'Added bar code %1 to item no. %2.';
        ActionDescription: Label 'This is a function for adding barcode to item.';
        Title: Label 'Add Barcode to Item';
        BarcodePrompt: Label 'Barcode Number';
        Item: Record Item;
        BarCodeAll: Text;
        BarCode: Code[50];
        ItemReference: Record "Item Reference";
}
