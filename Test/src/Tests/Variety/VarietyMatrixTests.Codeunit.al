codeunit 85097 "NPR Variety Matrix Tests"
{
    Subtype = Test;

    var
        VarietySetup: Record "NPR Variety Setup";
        TempBuffer: Record "NPR TEMP Buffer" temporary;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VarietyMatrixPopupTransferOrder_NoVarietySetup()
    var
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        TransferOrder: TestPage "Transfer Order";
    begin
        // [SCENARIO] Item with variants is set on the transfer order but no variety setup is present
        // [GIVEN] No variety setup, random locations, transfer header, item with variants
        InitializeData();
        VarietySetup.Delete(true);
        InitTransferOrderWithItem(0, TransferHeader, Item);
        InitItemVariant(Item, ItemVariant);
        // [WHEN] Item is added to the transfer order
        EditTransferOrderAndAddItem(TransferHeader, Item, TransferOrder);
        // [THEN] Line is created without variant code
        GetFirstTransferLine(TransferHeader, TransferLine);
        CheckLine(Item, TransferLine, '', 0);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VarietyMatrixPopupTransferOrder_VarietySetupNotEnabled()
    var
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        TransferOrder: TestPage "Transfer Order";
    begin
        // [SCENARIO] Item with variants is set on the transfer order but variety setup is not enabled
        // [GIVEN] Variety setup not enabled, random locations, transfer header, item with variants
        InitializeData();
        VarietySetup.Validate("Variety Enabled", false);
        VarietySetup.Modify(true);
        InitTransferOrderWithItem(0, TransferHeader, Item);
        InitItemVariant(Item, ItemVariant);
        // [WHEN] Item is added to the transfer order
        EditTransferOrderAndAddItem(TransferHeader, Item, TransferOrder);
        // [THEN] Line is created without variant code
        GetFirstTransferLine(TransferHeader, TransferLine);
        CheckLine(Item, TransferLine, '', 0);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VarietyMatrixPopupTransferOrder_NoPopupVarietySetup()
    var
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        TransferOrder: TestPage "Transfer Order";
    begin
        // [SCENARIO] Item with variants is set on the transfer order with variety setup but popup matrix is disabled           
        // [GIVEN] Variety setup, random locations, transfer header, item with variants
        InitializeData();
        VarietySetup.Validate("Pop up Variety Matrix", false);
        VarietySetup.Modify(true);
        InitTransferOrderWithItem(0, TransferHeader, Item);
        InitItemVariant(Item, ItemVariant);
        // [WHEN] Item is added to the transfer order
        EditTransferOrderAndAddItem(TransferHeader, Item, TransferOrder);
        // [THEN] Line is created without variant code
        GetFirstTransferLine(TransferHeader, TransferLine);
        CheckLine(Item, TransferLine, '', 0);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VarietyMatrixPopupTransferOrder_NoPopupForTransferOrder()
    var
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        TransferOrder: TestPage "Transfer Order";
    begin
        // [SCENARIO] Item with variants is set on the transfer order with variety setup but popup on transfer order is disabled           
        // [GIVEN] Variety setup, random locations, transfer header, item with variants
        InitializeData();
        VarietySetup.Validate("Pop up on Transfer Order", false);
        VarietySetup.Modify(true);
        InitTransferOrderWithItem(0, TransferHeader, Item);
        InitItemVariant(Item, ItemVariant);
        // [WHEN] Item is added to the transfer order
        EditTransferOrderAndAddItem(TransferHeader, Item, TransferOrder);
        // [THEN] Line is created without variant code
        GetFirstTransferLine(TransferHeader, TransferLine);
        CheckLine(Item, TransferLine, '', 0);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VarietyMatrixPopupTransferOrder_ItemHasNoVariants()
    var
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        Item: Record Item;
        TransferOrder: TestPage "Transfer Order";
    begin
        // [SCENARIO] Item without variants is set on the transfer order with variety setup
        // [GIVEN] Variety setup, random locations, transfer header, item with variants
        InitializeData();
        InitTransferOrderWithItem(0, TransferHeader, Item);
        // [WHEN] Item is added to the transfer order
        EditTransferOrderAndAddItem(TransferHeader, Item, TransferOrder);
        // [THEN] Line is created without variant code
        GetFirstTransferLine(TransferHeader, TransferLine);
        CheckLine(Item, TransferLine, '', 0);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SetQtyToFirstVariant1Value')]
    procedure VarietyMatrixPopupTransferOrder_SingleVariantAdded()
    var
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        TransferOrder: TestPage "Transfer Order";
    begin
        // [SCENARIO] Item with variants is set on the transfer order with variety setup and popup matrix enabled
        // [GIVEN] Variety setup, random locations, transfer header, item with variants
        InitializeData();
        InitTransferOrderWithItem(0, TransferHeader, Item);
        InitItemVariant(Item, ItemVariant);
        // [WHEN] Item is added to the transfer order
        EditTransferOrderAndAddItem(TransferHeader, Item, TransferOrder);
        // [THEN] Line is created with correct variant and quantity
        GetFirstTransferLine(TransferHeader, TransferLine);
        CheckLine(Item, TransferLine, ItemVariant.Code, TempBuffer."Decimal 1");
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SetQtyToTwoVariant1Values')]
    procedure VarietyMatrixPopupTransferOrder_TwoVariantsAdded()
    var
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        Item: Record Item;
        ItemVariant1: Record "Item Variant";
        ItemVariant2: Record "Item Variant";
        TransferOrder: TestPage "Transfer Order";
    begin
        // [SCENARIO] Item with 2 variants is set on the transfer order with variety setup and popup matrix enabled
        // [GIVEN] Variety setup, random locations, transfer header, item with variants
        InitializeData();
        InitTransferOrderWithItem(2, TransferHeader, Item);
        InitItemVariant(Item, ItemVariant1);
        InitItemVariant(Item, ItemVariant2);
        // [WHEN] Item is added to the transfer order
        EditTransferOrderAndAddItem(TransferHeader, Item, TransferOrder);
        // [THEN] Line is created with correct variant and quantity
        GetFirstTransferLine(TransferHeader, TransferLine);
        TempBuffer.FindFirst();
        CheckLine(Item, TransferLine, ItemVariant1.Code, TempBuffer."Decimal 1");
        TransferLine.Next();
        TempBuffer.Next();
        CheckLine(Item, TransferLine, ItemVariant2.Code, TempBuffer."Decimal 1");
    end;

    procedure InitializeData()
    begin
        ClearData();
        InitVarietySetup();
        InitiVarietyFieldSetupForTransferLineQty();
    end;

    procedure ClearData()
    var
        Variety: Record "NPR Variety";
        VarietySetup: Record "NPR Variety Setup";
        VarietyFieldSetup: Record "NPR Variety Field Setup";
    begin
        if not Variety.IsEmpty then
            Variety.DeleteAll(true);
        if VarietySetup.Get() then
            VarietySetup.Delete(true);
        if not VarietyFieldSetup.IsEmpty then
            VarietyFieldSetup.DeleteAll(true);
        TempBuffer.DeleteAll();
    end;

    local procedure InitVarietySetup()
    begin
        VarietySetup.Init();
        VarietySetup.Validate("Variety Enabled", true);
        VarietySetup.Validate("Pop up Variety Matrix", true);
        VarietySetup.Insert(true);
    end;

    procedure InitiVarietyFieldSetupForTransferLineQty()
    var
        VarietyFieldSetup: Record "NPR Variety Field Setup";
        TransferLine: Record "Transfer Line";
    begin
        VarietyFieldSetup.Init();
        VarietyFieldSetup.Validate(Type, VarietyFieldSetup.Type::Field);
        VarietyFieldSetup.Validate("Table No.", Database::"Transfer Line");
        VarietyFieldSetup.Validate("Field No.", TransferLine.FieldNo(Quantity));
        VarietyFieldSetup.Validate("Validate Field", true);
        VarietyFieldSetup.Validate("Editable Field", true);
        VarietyFieldSetup.Validate("Is Table Default", true);
        VarietyFieldSetup.Insert(true);
    end;

    local procedure InitTransferOrderWithItem(VarietySets: Integer; var TransferHeader: Record "Transfer Header"; var Item: Record Item)
    var
        FromLocation: Record Location;
        ToLocation: Record Location;
        InTransitLocation: Record Location;
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryVariety: Codeunit "NPR Library - Variety";
    begin
        LibraryWarehouse.CreateTransferLocations(FromLocation, ToLocation, InTransitLocation);
        LibraryWarehouse.CreateTransferHeader(TransferHeader, FromLocation.Code, ToLocation.Code, InTransitLocation.Code);
        LibraryInventory.CreateItem(Item);
        LibraryVariety.CreateVarietySetsAndAddToItem(VarietySets, Item);
    end;

    local procedure InitItemVariant(Item: Record Item; var ItemVariant: Record "Item Variant")
    var
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryVariety: Codeunit "NPR Library - Variety";
    begin
        LibraryInventory.CreateItemVariant(ItemVariant, Item."No.");
        LibraryVariety.CreateVarietyValuesAndAddToItemVariant(ItemVariant);
    end;

    local procedure EditTransferOrderAndAddItem(TransferHeader: Record "Transfer Header"; var Item: Record Item; var TransferOrder: TestPage "Transfer Order")
    begin
        TransferOrder.OpenEdit();
        TransferOrder.GoToRecord(TransferHeader);
        TransferOrder.TransferLines.New();
        TransferOrder.TransferLines."Item No.".SetValue(Item."No.");
        TransferOrder.TransferLines.New(); //will trigger insert and create a new line before        
    end;

    local procedure CheckLine(Item: Record Item; TransferLine: Record "Transfer Line"; VariantCode: Text; Quantity: Decimal)
    var
        Assert: Codeunit Assert;
        FieldValueDifferentLbl: Label '%1 is not the same', Comment = '%1 = field caption';
    begin
        Assert.AreEqual(Item."No.", TransferLine."Item No.", StrSubstNo(FieldValueDifferentLbl, TransferLine.FieldCaption("Item No.")));
        Assert.AreEqual(VariantCode, TransferLine."Variant Code", StrSubstNo(FieldValueDifferentLbl, TransferLine.FieldCaption("Variant Code")));
        Assert.AreEqual(Quantity, TransferLine.Quantity, StrSubstNo(FieldValueDifferentLbl, TransferLine.FieldCaption(Quantity)));
    end;

    local procedure AddQtyToBuffer(Quantity: Decimal)
    var
        LineNo: Integer;
    begin
        if TempBuffer.FindLast() then
            LineNo := TempBuffer."Line No." + 1;
        TempBuffer.Init();
        TempBuffer."Line No." := LineNo;
        TempBuffer."Decimal 1" := Quantity;
        TempBuffer.Insert();
    end;

    local procedure GetFirstTransferLine(TransferHeader: Record "Transfer Header"; var TransferLine: Record "Transfer Line")
    begin
        TransferLine.SetRange("Document No.", TransferHeader."No.");
        TransferLine.FindFirst(); //blank line
        TransferLine.Next(); //actual first line with data;
    end;

    [ModalPageHandler]
    procedure SetQtyToFirstVariant1Value(var VRTMatrix: TestPage "NPR Variety Matrix")
    var
        LibraryRandom: Codeunit "Library - Random";
    begin
        AddQtyToBuffer(LibraryRandom.RandDec(10, 2));
        VRTMatrix.First();
        VRTMatrix.Field1.SetValue(TempBuffer."Decimal 1");
    end;

    [ModalPageHandler]
    procedure SetQtyToTwoVariant1Values(var VRTMatrix: TestPage "NPR Variety Matrix")
    var
        LibraryRandom: Codeunit "Library - Random";
    begin
        AddQtyToBuffer(LibraryRandom.RandDec(10, 2));
        VRTMatrix.First();
        VRTMatrix.Field1.SetValue(TempBuffer."Decimal 1");
        AddQtyToBuffer(LibraryRandom.RandDec(10, 2));
        VRTMatrix.Next(); //only top-right diagonal variety combinations are legal
        VRTMatrix.Field2.SetValue(TempBuffer."Decimal 1");
    end;

}