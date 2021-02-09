codeunit 6151459 "NPR Magento NpXml Qty. Incr."
{
    TableNo = "NPR NpXml Custom Val. Buffer";

    trigger OnRun()
    var
        NpXmlElement: Record "NPR NpXml Element";
        RecRef: RecordRef;
        OutStr: OutStream;
        CustomValue: Text;
        ItemNo: Code[20];
    begin
        if not NpXmlElement.Get(Rec."Xml Template Code", Rec."Xml Element Line No.") then
            exit;
        Clear(RecRef);
        RecRef.Open(Rec."Table No.");
        RecRef.SetPosition(Rec."Record Position");

        if not RecRef.Find then
            exit;

        SetRecInfo(RecRef, ItemNo);
        RecRef.Close;
        Clear(RecRef);

        CustomValue := Format(CalcQtyIncrement(ItemNo), 0, 9);

        Rec.Value.CreateOutStream(OutStr);
        OutStr.WriteText(CustomValue);
        Rec.Modify;
    end;

    local procedure CalcQtyIncrement(ItemNo: Code[20]) QtyIncrement: Decimal
    var
        MagentoSetup: Record "NPR Magento Setup";
        ItemUOM: Record "Item Unit of Measure";
        Item: Record Item;
        SalesUOMQty: Decimal;
        BaseUOMQty: Decimal;
    begin
        if not (MagentoSetup.Get and MagentoSetup."Magento Enabled") then
            exit(0);

        if not Item.Get(ItemNo) then
            exit(0);

        if not ItemUOM.Get(ItemNo, Item."Sales Unit of Measure") then
            exit(0);

        SalesUOMQty := ItemUOM."Qty. per Unit of Measure";

        if not ItemUOM.Get(ItemNo, Item."Base Unit of Measure") then
            exit(0);

        BaseUOMQty := ItemUOM."Qty. per Unit of Measure";
        if BaseUOMQty = 0 then
            exit(0);

        exit(SalesUOMQty / BaseUOMQty)
    end;

    local procedure SetRecInfo(var RecRef: RecordRef; var ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        case RecRef.Number of
            DATABASE::Item:
                begin
                    RecRef.SetTable(Item);
                    ItemNo := Item."No.";
                    exit(true);
                end;
        end;

        exit(false);
    end;
}