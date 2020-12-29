codeunit 6151166 "NPR NpGp POS Sales WS"
{
    procedure InsertPosSalesEntries(var sales_entries: XMLport "NPR NpGp POS Entries")
    var
        TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary;
        TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary;
        TempNpGpPOSInfoPOSEntry: Record "NPR NpGp POS Info POS Entry" temporary;
        NpGpPOSSalesInitMgt: Codeunit "NPR NpGp POS Sales Init Mgt.";
    begin
        sales_entries.Import;
        sales_entries.GetSourceTables(TempNpGpPOSSalesEntry, TempNpGpPOSSalesLine, TempNpGpPOSInfoPOSEntry);

        NpGpPOSSalesInitMgt.InsertPosSalesEntries(TempNpGpPOSSalesEntry, TempNpGpPOSSalesLine, TempNpGpPOSInfoPOSEntry);
    end;

    procedure GetGlobalSale(referenceNumber: Text; fullSale: Boolean; var npGpPOSEntries: XMLport "NPR NpGp POS Entries")
    var
        TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary;
        TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary;
        NpGpPOSSalesLineReturn: Record "NPR NpGp POS Sales Line";
        TempNpGpPOSInfoPOSEntry: Record "NPR NpGp POS Info POS Entry" temporary;
        NpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry";
        NpGpPOSSalesLine: Record "NPR NpGp POS Sales Line";
        NpGpPOSInfoPOSEntry: Record "NPR NpGp POS Info POS Entry";
    begin
        NpGpPOSSalesLine.SetRange("Global Reference", referenceNumber);
        NpGpPOSSalesLine.SetFilter(Quantity, '>0');
        if not NpGpPOSSalesLine.FindFirst then
            exit;

        NpGpPOSSalesLine.SetRange(Quantity);

        NpGpPOSSalesEntry.SetRange("POS Store Code", NpGpPOSSalesLine."POS Store Code");
        NpGpPOSSalesEntry.SetRange("POS Unit No.", NpGpPOSSalesLine."POS Unit No.");
        NpGpPOSSalesEntry.SetRange("Document No.", NpGpPOSSalesLine."Document No.");
        if NpGpPOSSalesEntry.FindFirst then begin
            TempNpGpPOSSalesEntry := NpGpPOSSalesEntry;
            TempNpGpPOSSalesEntry.Insert;

            if fullSale then
                NpGpPOSSalesLine.SetRange("Global Reference");
            NpGpPOSSalesLine.SetRange("POS Entry No.", NpGpPOSSalesEntry."Entry No.");
            NpGpPOSSalesLine.SetRange(Type, NpGpPOSSalesLine.Type::Item);
            NpGpPOSSalesLine.FindSet;
            repeat
                TempNpGpPOSSalesLine := NpGpPOSSalesLine;
                TempNpGpPOSSalesLine.Insert;

                Clear(NpGpPOSSalesLineReturn);
                NpGpPOSSalesLineReturn.SetRange("Global Reference", NpGpPOSSalesLine."Global Reference");
                NpGpPOSSalesLineReturn.SetFilter(Quantity, '<0');
                if NpGpPOSSalesLineReturn.FindSet then
                    repeat
                        TempNpGpPOSSalesLine.Quantity += NpGpPOSSalesLineReturn.Quantity;
                    until NpGpPOSSalesLineReturn.Next = 0;

                TempNpGpPOSSalesLine.Modify;
            until NpGpPOSSalesLine.Next = 0;

            NpGpPOSInfoPOSEntry.SetRange("POS Entry No.", NpGpPOSSalesEntry."Entry No.");
            if NpGpPOSInfoPOSEntry.FindSet then
                repeat
                    TempNpGpPOSInfoPOSEntry := NpGpPOSInfoPOSEntry;
                    TempNpGpPOSInfoPOSEntry.Insert;
                until NpGpPOSInfoPOSEntry.Next = 0;
        end;

        npGpPOSEntries.SetSourceTables(TempNpGpPOSSalesEntry, TempNpGpPOSSalesLine, TempNpGpPOSInfoPOSEntry);
    end;
}

