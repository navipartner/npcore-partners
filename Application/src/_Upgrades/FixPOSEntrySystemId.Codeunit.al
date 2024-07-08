codeunit 6059776 "NPR Fix POS Entry SystemId"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Fix POS Entry SystemId', 'OnUpgradePerCompany');

        if not UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Fix POS Entry SystemId")) then begin
            ProcessUnfinishedPOSSales();
            ProcessParkedSales();
            UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Fix POS Entry SystemId"));
        end;

        LogMessageStopwatch.LogFinish();
    end;

    local procedure ProcessUnfinishedPOSSales()
    var
        SalePOS: Record "NPR POS Sale";
    begin
        if SalePOS.FindSet() then
            repeat
                EnsureSystemIdIsUnique(SalePOS);
            until SalePOS.Next() = 0;
    end;

    local procedure ProcessParkedSales()
    var
        POSQuoteEntry: Record "NPR POS Saved Sale Entry";
        SalePOS: Record "NPR POS Sale";
        POSQuoteMgt: Codeunit "NPR POS Saved Sale Mgt.";
        XmlDoc: XmlDocument;
    begin
        if POSQuoteEntry.FindSet() then
            repeat
                Clear(XmlDoc);
                Clear(SalePOS);
                if POSQuoteMgt.LoadPOSSaleData(POSQuoteEntry, XmlDoc) then
                    if Xml2POSSale(XmlDoc, SalePOS) then
                        EnsureSystemIdIsUnique(SalePOS);
            until POSQuoteEntry.Next() = 0;
    end;

    local procedure Xml2POSSale(var XmlDoc: XmlDocument; var SalePOS: Record "NPR POS Sale"): Boolean
    var
        TempSalePOSFieldBuffer: Record "Field" temporary;
        POSQuoteMgt: Codeunit "NPR POS Saved Sale Mgt.";
        RecRef: RecordRef;
        Root: XmlElement;
    begin
        if not XmlDoc.GetRoot(Root) then
            exit(false);
        if Root.Name <> 'pos_sale' then
            exit(false);

        RecRef.GetTable(SalePOS);
        POSQuoteMgt.FindFields(RecRef, true, TempSalePOSFieldBuffer, true);
        if TempSalePOSFieldBuffer.IsEmpty then
            exit(false);

        POSQuoteMgt.Xml2RecRef(Root, TempSalePOSFieldBuffer, RecRef);
        RecRef.SetTable(SalePOS);
        exit(true);
    end;

    local procedure EnsureSystemIdIsUnique(SalePOS: Record "NPR POS Sale")
    var
        POSEntry: Record "NPR POS Entry";
        POSEntry2: Record "NPR POS Entry";
    begin
        //This is to fix the issue we had with POS entries for cancelled sale transactions having the same System Id as the sale being loaded.
        //The System Id clash could occur because of the way we used to park POS sales: due to traceability reasons system would create a POS entry
        //with type "Cancelled Sale" for the sale while parking it, and the POS entry in that case had the same System Id as the sale.

        if IsNullGuid(SalePOS.SystemId) then
            exit;
        if not POSEntry.GetBySystemId(SalePOS.SystemId) then
            exit;
        if POSEntry."Entry Type" = POSEntry."Entry Type"::"Cancelled Sale" then begin
            POSEntry2 := POSEntry;
            POSEntry.Delete();
            POSEntry2.Insert();
        end;
    end;
}