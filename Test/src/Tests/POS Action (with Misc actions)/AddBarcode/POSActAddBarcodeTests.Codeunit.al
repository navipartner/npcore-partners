codeunit 85048 "NPR POS Act. Add Barcode Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        ItemReference: Record "Item Reference";
        ItemNo: Code[20];
        BarCode: Code[50];

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ClickOnOKMsg')]
    procedure CreateItemReference()
    var
        LibraryRandom: Codeunit "Library - Random";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        Item: Record Item;
        ItemUOM: Code[10];
        ItemVariantCode: Code[10];
        POSActionBusinessLogic: Codeunit "NPR POS Action: Add Barcode B";
        ItemVariant: Record "Item Variant";

    begin
        //[Scenario] Check that barcode 50 is inserted

        LibraryECommerce.CreateItem(ItemNo);
        Item.Get(ItemNo);
        ItemUOM := Item."Base Unit of Measure";
        BarCode := LibraryRandom.RandText(50);

        ItemVariant.SetRange("Item No.", ItemNo);
        If ItemVariant.FindFirst() then
            ItemVariantCode := ItemVariant.Code;

        POSActionBusinessLogic.InputBarcode(BarCode, ItemNo, ItemVariantCode, ItemUOM);

        ItemReference.SetRange("Item No.", ItemNo);
        ItemReference.SetRange("Variant Code", ItemVariantCode);
        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
        ItemReference.SetRange("Unit of Measure", ItemUOM);
        Assert.IsTrue(ItemReference.FindFirst(), 'Barcode is created');
    end;

    [MessageHandler]
    procedure ClickOnOKMsg(Msg: Text[1024])
    var
        BarcodeAddedMsg: Label 'Added bar code %1 to item no. %2.';
    begin
        Assert.IsTrue(Msg = StrSubstNo(BarcodeAddedMsg, BarCode, ItemNo), Msg);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ClickOnOKErr')]
    procedure TryCreateItemReference()
    var
        LibraryRandom: Codeunit "Library - Random";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";

        Item: Record Item;
        ItemUOM: Code[10];
        ItemVariantCode: Code[10];
        POSActionBusinessLogic: Codeunit "NPR POS Action: Add Barcode B";
        ItemVariant: Record "Item Variant";

    begin
        //[Scenario] Check that barcode already exists

        LibraryECommerce.CreateItem(ItemNo);
        Item.Get(ItemNo);
        ItemUOM := Item."Base Unit of Measure";
        BarCode := LibraryRandom.RandText(50);

        ItemVariant.SetRange("Item No.", ItemNo);
        If ItemVariant.FindFirst() then
            ItemVariantCode := ItemVariant.Code;

        ItemReference.Init();
        ItemReference."Reference Type" := ItemReference."Reference Type"::"Bar Code";
        ItemReference."Reference No." := BarCode;
        ItemReference."Item No." := Item."No.";
        ItemReference.Description := Item.Description;
        if ItemVariantCode <> '' then begin
            ItemVariant.Get(ItemNo, ItemVariantCode);
            ItemReference."Variant Code" := ItemVariantCode;
            if ItemVariant.Description <> '' then
                ItemReference.Description := ItemVariant.Description;
        end;
        ItemReference."Unit of Measure" := ItemUOM;
        if ItemReference.Insert(true) then
            POSActionBusinessLogic.InputBarcode(BarCode, ItemNo, ItemVariantCode, ItemUOM);
    end;

    [MessageHandler]
    procedure ClickOnOKErr(Msg: Text[1024])
    var
        RecordErr: Label 'Record %1 already exists';
    begin
        Assert.IsTrue(Msg = StrSubstNo(RecordErr, ItemReference.RecordId), Msg);
    end;



}