codeunit 6151452 "Magento NpXml Stock Status"
{
    // MAG1.16/TS/20150507  CASE 213379 Object created - Custom Values for NpXml
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.09/MHA /20180105  CASE 301053 Removed redundant CASE 'boolean' in SetRecRefCalcFieldFilter()
    // MAG2.26/MHA /20200430  CASE 402486 Updated Stock Calculation function

    TableNo = "NpXml Custom Value Buffer";

    trigger OnRun()
    var
        NpXmlElement: Record "NpXml Element";
        MagentoItemMgt: Codeunit "Magento Item Mgt.";
        RecRef: RecordRef;
        CustomValue: Text;
        OutStr: OutStream;
    begin
        if not NpXmlElement.Get("Xml Template Code","Xml Element Line No.") then
          exit;
        Clear(RecRef);
        RecRef.Open("Table No.");
        RecRef.SetPosition("Record Position");
        //-MAG2.26 [402486]
        CustomValue := '0';
        if MagentoItemMgt.GetStockQty2(RecRef) > 0 then
          CustomValue := '1';
        //+MAG2.26 [402486]

        Value.CreateOutStream(OutStr);
        OutStr.WriteText(CustomValue);
        Modify;
    end;
}

