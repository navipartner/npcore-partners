codeunit 6151459 "Magento NpXml Qty. Increment"
{
    // MAG2.19/ZESO/20190214 CASE 345371 Object Created
    // MAG2.22/BHR /20190610 CASE 349129 Correct bug

    TableNo = "NpXml Custom Value Buffer";

    trigger OnRun()
    var
        NpXmlElement: Record "NpXml Element";
        RecRef: RecordRef;
        OutStr: OutStream;
        CustomValue: Text;
        ItemNo: Code[20];
        VariantCode: Code[10];
    begin
        if not NpXmlElement.Get("Xml Template Code","Xml Element Line No.") then
          exit;
        Clear(RecRef);
        RecRef.Open("Table No.");
        RecRef.SetPosition("Record Position");

        if not  RecRef.Find then
          exit;

        SetRecInfo(RecRef,ItemNo);
        RecRef.Close;
        Clear(RecRef);

        CustomValue := Format(CalcQtyIncrement(ItemNo),0,9);

        Value.CreateOutStream(OutStr);
        OutStr.WriteText(CustomValue);
        Modify;
    end;

    var
        Text000: Label 'Magento Intercompany Inventory NpXml Error:\%1';

    local procedure CalcQtyIncrement(ItemNo: Code[20]) QtyIncrement: Decimal
    var
        MagentoSetup: Record "Magento Setup";
        ItemUOM: Record "Item Unit of Measure";
        Item: Record Item;
        SalesUOMQty: Decimal;
        BaseUOMQty: Decimal;
    begin
        if not (MagentoSetup.Get and MagentoSetup."Magento Enabled") then
          exit(0);

        if not Item.Get(ItemNo) then
          exit(0);

        //-MAG2.22 [349129]
        //IF NOT ItemUOM.GET(Item."Sales Unit of Measure",ItemNo) THEN
        if not ItemUOM.Get(ItemNo,Item."Sales Unit of Measure") then
        //+MAG2.22 [349129]
          exit(0);

        SalesUOMQty := ItemUOM."Qty. per Unit of Measure";

        //-MAG2.22 [349129]
        //IF NOT ItemUOM.GET(Item."Base Unit of Measure",ItemNo) THEN
        if not ItemUOM.Get(ItemNo,Item."Base Unit of Measure") then
        //+MAG2.22 [349129]
          exit(0);

        BaseUOMQty := ItemUOM."Qty. per Unit of Measure";
        if BaseUOMQty = 0 then
          exit(0);

        exit(SalesUOMQty/BaseUOMQty)
    end;

    local procedure SetRecInfo(var RecRef: RecordRef;var ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        case RecRef.Number of
          DATABASE::Item :
            begin
              RecRef.SetTable(Item);
              ItemNo := Item."No.";
              exit(true);
            end;
        end;

        exit(false);
    end;
}

