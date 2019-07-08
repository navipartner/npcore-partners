codeunit 6151166 "NpGp POS Sales Webservice"
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created - [NpGp] NaviPartner Global POS Sales


    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure InsertPosSalesEntries(var sales_entries: XMLport "NpGp POS Entries")
    var
        TempNpGpPOSSalesEntry: Record "NpGp POS Sales Entry" temporary;
        TempNpGpPOSSalesLine: Record "NpGp POS Sales Line" temporary;
        TempNpGpPOSInfoPOSEntry: Record "NpGp POS Info POS Entry" temporary;
        NpGpPOSSalesInitMgt: Codeunit "NpGp POS Sales Init Mgt.";
    begin
        sales_entries.Import;
        sales_entries.GetSourceTables(TempNpGpPOSSalesEntry,TempNpGpPOSSalesLine,TempNpGpPOSInfoPOSEntry);

        NpGpPOSSalesInitMgt.InsertPosSalesEntries(TempNpGpPOSSalesEntry,TempNpGpPOSSalesLine,TempNpGpPOSInfoPOSEntry);
    end;
}

