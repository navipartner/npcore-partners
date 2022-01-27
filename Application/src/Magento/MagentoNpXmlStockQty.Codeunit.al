codeunit 6151451 "NPR Magento NpXml Stock Qty"
{
    Access = Internal;
    TableNo = "NPR NpXml Custom Val. Buffer";

    trigger OnRun()
    var
        NpXmlElement: Record "NPR NpXml Element";
        MagentoItemMgt: Codeunit "NPR Magento Item Mgt.";
        RecRef: RecordRef;
        OutStr: OutStream;
        CustomValue: Text;
    begin
        if not NpXmlElement.Get(Rec."Xml Template Code", Rec."Xml Element Line No.") then
            exit;
        Clear(RecRef);
        RecRef.Open(Rec."Table No.");
        RecRef.SetPosition(Rec."Record Position");

        CustomValue := Format(MagentoItemMgt.GetStockQty2(RecRef), 0, 9);

        Rec.Value.CreateOutStream(OutStr);
        OutStr.WriteText(CustomValue);
        Rec.Modify();
    end;
}
