codeunit 6151166 "NpGp POS Sales Webservice"
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created - [NpGp] NaviPartner Global POS Sales
    // NPR5.51/ALST/20190711  CASE 337539 added GetGlobalSale


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

    [Scope('Personalization')]
    procedure GetGlobalSale(referenceNumber: Text;fullSale: Boolean;var npGpPOSEntries: XMLport "NpGp POS Entries")
    var
        TempNpGpPOSSalesEntry: Record "NpGp POS Sales Entry" temporary;
        TempNpGpPOSSalesLine: Record "NpGp POS Sales Line" temporary;
        NpGpPOSSalesLineReturn: Record "NpGp POS Sales Line";
        TempNpGpPOSInfoPOSEntry: Record "NpGp POS Info POS Entry" temporary;
        NpGpPOSSalesEntry: Record "NpGp POS Sales Entry";
        NpGpPOSSalesLine: Record "NpGp POS Sales Line";
        NpGpPOSInfoPOSEntry: Record "NpGp POS Info POS Entry";
    begin
        //-NPR5.51
        NpGpPOSSalesLine.SetRange("Global Reference",referenceNumber);
        NpGpPOSSalesLine.SetFilter(Quantity,'>0');
        if not NpGpPOSSalesLine.FindFirst then
          exit;

        NpGpPOSSalesLine.SetRange(Quantity);

        NpGpPOSSalesEntry.SetRange("POS Store Code",NpGpPOSSalesLine."POS Store Code");
        NpGpPOSSalesEntry.SetRange("POS Unit No.",NpGpPOSSalesLine."POS Unit No.");
        NpGpPOSSalesEntry.SetRange("Document No.",NpGpPOSSalesLine."Document No.");
        if NpGpPOSSalesEntry.FindFirst then begin
          TempNpGpPOSSalesEntry := NpGpPOSSalesEntry;
          TempNpGpPOSSalesEntry.Insert;

          if fullSale then
            NpGpPOSSalesLine.SetRange("Global Reference");
          NpGpPOSSalesLine.SetRange("POS Entry No.",NpGpPOSSalesEntry."Entry No.");
          NpGpPOSSalesLine.SetRange(Type,NpGpPOSSalesLine.Type::Item);
          NpGpPOSSalesLine.FindSet;
          repeat
            TempNpGpPOSSalesLine := NpGpPOSSalesLine;
            TempNpGpPOSSalesLine.Insert;

            Clear(NpGpPOSSalesLineReturn);
            NpGpPOSSalesLineReturn.SetRange("Global Reference",NpGpPOSSalesLine."Global Reference");
            NpGpPOSSalesLineReturn.SetFilter(Quantity,'<0');
            if NpGpPOSSalesLineReturn.FindSet then repeat
              TempNpGpPOSSalesLine.Quantity += NpGpPOSSalesLineReturn.Quantity;
            until NpGpPOSSalesLineReturn.Next = 0;

            TempNpGpPOSSalesLine.Modify;
          until NpGpPOSSalesLine.Next = 0;

          NpGpPOSInfoPOSEntry.SetRange("POS Entry No.",NpGpPOSSalesEntry."Entry No.");
          if NpGpPOSInfoPOSEntry.FindSet then
            repeat
              TempNpGpPOSInfoPOSEntry := NpGpPOSInfoPOSEntry;
              TempNpGpPOSInfoPOSEntry.Insert;
            until NpGpPOSInfoPOSEntry.Next = 0;
        end;

        npGpPOSEntries.SetSourceTables(TempNpGpPOSSalesEntry,TempNpGpPOSSalesLine,TempNpGpPOSInfoPOSEntry);
        //+NPR5.51
    end;
}

