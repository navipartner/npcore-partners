codeunit 6151166 "NPR NpGp POS Sales WS"
{
    procedure InsertPosSalesEntries(var sales_entries: XmlPort "NPR NpGp POS Entries")
    var
        TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary;
        TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary;
        TempNpGpPOSInfoPOSEntry: Record "NPR NpGp POS Info POS Entry" temporary;
        TempNpGpPOSPaymentLine: Record "NPR NpGp POS Payment Line" temporary;
        NpGpPOSSalesInitMgt: Codeunit "NPR NpGp POS Sales Init Mgt.";
    begin
        sales_entries.Import();
        sales_entries.GetSourceTables(TempNpGpPOSSalesEntry, TempNpGpPOSSalesLine, TempNpGpPOSInfoPOSEntry, TempNpGpPOSPaymentLine);

        NpGpPOSSalesInitMgt.InsertPOSSalesEntries(TempNpGpPOSSalesEntry, TempNpGpPOSSalesLine, TempNpGpPOSInfoPOSEntry, TempNpGpPOSPaymentLine);
    end;

    procedure GetGlobalSale(referenceNumber: Text; fullSale: Boolean; var npGpPOSEntries: XmlPort "NPR NpGp POS Entries")
    var
        TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary;
        TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary;
        NpGpPOSSalesLineReturn: Record "NPR NpGp POS Sales Line";
        TempNpGpPOSInfoPOSEntry: Record "NPR NpGp POS Info POS Entry" temporary;
        TempNpGpPOSPaymentLine: Record "NPR NpGp POS Payment Line" temporary;
        NpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry";
        NpGpPOSSalesLine: Record "NPR NpGp POS Sales Line";
        NpGpPOSInfoPOSEntry: Record "NPR NpGp POS Info POS Entry";
        NpGpPOSPaymentLine: Record "NPR NpGp POS Payment Line";
    begin
        NpGpPOSSalesLine.SetRange("Global Reference", referenceNumber);
        NpGpPOSSalesLine.SetFilter(Quantity, '>0');
        if not NpGpPOSSalesLine.FindFirst() then
            exit;

        NpGpPOSSalesEntry.SetRange("POS Store Code", NpGpPOSSalesLine."POS Store Code");
        NpGpPOSSalesEntry.SetRange("POS Unit No.", NpGpPOSSalesLine."POS Unit No.");
        NpGpPOSSalesEntry.SetRange("Document No.", NpGpPOSSalesLine."Document No.");
        if NpGpPOSSalesEntry.FindFirst() then begin
            TempNpGpPOSSalesEntry := NpGpPOSSalesEntry;
            TempNpGpPOSSalesEntry.Insert();

            if fullSale then
                NpGpPOSSalesLine.SetRange("Global Reference");
            NpGpPOSSalesLine.SetRange("POS Entry No.", NpGpPOSSalesEntry."Entry No.");
            NpGpPOSSalesLine.SetRange(Type, NpGpPOSSalesLine.Type::Item);
            NpGpPOSSalesLine.FindSet();
            repeat
                TempNpGpPOSSalesLine := NpGpPOSSalesLine;

                Clear(NpGpPOSSalesLineReturn);
                if NpGpPOSSalesLine."Global Reference" <> '' then begin
                    NpGpPOSSalesLineReturn.SetRange("Global Reference", NpGpPOSSalesLine."Global Reference");
                    NpGpPOSSalesLineReturn.SetFilter(Quantity, '<0');
                    NpGpPOSSalesLineReturn.SetFilter("No.", NpGpPOSSalesLine."No.");
                    NpGpPOSSalesLineReturn.SetFilter("Variant Code", NpGpPOSSalesLine."Variant Code");
                    if NpGpPOSSalesLineReturn.FindSet() then
                        repeat
                            TempNpGpPOSSalesLine.Quantity += NpGpPOSSalesLineReturn.Quantity;
                        until NpGpPOSSalesLineReturn.Next() = 0;
                end;
                if TempNpGpPOSSalesLine.Quantity >= 0 then
                    TempNpGpPOSSalesLine.Insert();
            until NpGpPOSSalesLine.Next() = 0;

            NpGpPOSInfoPOSEntry.SetRange("POS Entry No.", NpGpPOSSalesEntry."Entry No.");
            if NpGpPOSInfoPOSEntry.FindSet() then
                repeat
                    TempNpGpPOSInfoPOSEntry := NpGpPOSInfoPOSEntry;
                    TempNpGpPOSInfoPOSEntry.Insert();
                until NpGpPOSInfoPOSEntry.Next() = 0;

            NpGpPOSPaymentLine.SetRange("POS Entry No.", NpGpPOSSalesEntry."Entry No.");
            if NpGpPOSPaymentLine.FindSet() then
                repeat
                    TempNpGpPOSPaymentLine := NpGpPOSPaymentLine;
                    TempNpGpPOSPaymentLine.Insert();
                until NpGpPOSPaymentLine.Next() = 0;
        end;

        npGpPOSEntries.SetSourceTables(TempNpGpPOSSalesEntry, TempNpGpPOSSalesLine, TempNpGpPOSInfoPOSEntry, TempNpGpPOSPaymentLine);
    end;

    procedure GetGlobalSaleByDocumentNo(documentNumber: Text; posUnitFilter: Text; posStoreFilter: Text; var npGpPOSEntries: XMLport "NPR NpGp POS Entries")
    var
        NpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry";
        NpGpPOSSalesLine: Record "NPR NpGp POS Sales Line";
        NpGpPOSInfoPOSEntry: Record "NPR NpGp POS Info POS Entry";
        NpGpPOSPaymentLine: Record "NPR NpGp POS Payment Line";
        NpGpPOSSalesLineReturn: Record "NPR NpGp POS Sales Line";
        TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary;
        TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary;
        TempNpGpPOSInfoPOSEntry: Record "NPR NpGp POS Info POS Entry" temporary;
        TempNpGpPOSPaymentLine: Record "NPR NpGp POS Payment Line" temporary;
        MissingDocumentNoErr: Label 'parameter DocumentNumber must have a value';
    begin
        if documentNumber = '' then
            Error(MissingDocumentNoErr);
        if posStoreFilter <> '' then
            NpGpPOSSalesEntry.SetFilter("POS Store Code", posStoreFilter);
        if posUnitFilter <> '' then
            NpGpPOSSalesEntry.SetFilter("POS Unit No.", posUnitFilter);
        NpGpPOSSalesEntry.SetRange("Document No.", documentNumber);

        if NpGpPOSSalesEntry.FindSet() then
            repeat
                TempNpGpPOSSalesEntry := NpGpPOSSalesEntry;
                TempNpGpPOSSalesEntry.Insert();

                NpGpPOSSalesLine.SetRange("POS Entry No.", NpGpPOSSalesEntry."Entry No.");
                NpGpPOSSalesLine.SetRange(Type, NpGpPOSSalesLine.Type::Item);
                NpGpPOSSalesLine.SetFilter(Quantity, '>0');
                if NpGpPOSSalesLine.FindSet() then
                    repeat
                        TempNpGpPOSSalesLine := NpGpPOSSalesLine;
                        TempNpGpPOSSalesLine.Insert();

                        Clear(NpGpPOSSalesLineReturn);
                        if NpGpPOSSalesLine."Global Reference" <> '' then begin
                            NpGpPOSSalesLineReturn.SetRange("Global Reference", NpGpPOSSalesLine."Global Reference");
                            NpGpPOSSalesLineReturn.SetFilter("No.", NpGpPOSSalesLine."No.");
                            NpGpPOSSalesLineReturn.SetFilter("Variant Code", NpGpPOSSalesLine."Variant Code");
                            NpGpPOSSalesLineReturn.SetFilter(Quantity, '<0');
                            if NpGpPOSSalesLineReturn.FindSet() then
                                repeat
                                    TempNpGpPOSSalesLine.Quantity += NpGpPOSSalesLineReturn.Quantity;
                                until NpGpPOSSalesLineReturn.Next() = 0;
                        end;
                        TempNpGpPOSSalesLine.Modify();
                    until NpGpPOSSalesLine.Next() = 0;

                NpGpPOSInfoPOSEntry.SetRange("POS Entry No.", NpGpPOSSalesEntry."Entry No.");
                if NpGpPOSInfoPOSEntry.FindSet() then
                    repeat
                        TempNpGpPOSInfoPOSEntry := NpGpPOSInfoPOSEntry;
                        TempNpGpPOSInfoPOSEntry.Insert();
                    until NpGpPOSInfoPOSEntry.Next() = 0;

                NpGpPOSPaymentLine.SetRange("POS Entry No.", NpGpPOSSalesEntry."Entry No.");
                if NpGpPOSPaymentLine.FindSet() then
                    repeat
                        TempNpGpPOSPaymentLine := NpGpPOSPaymentLine;
                        TempNpGpPOSPaymentLine.Insert();
                    until NpGpPOSPaymentLine.Next() = 0;
            until NpGpPOSSalesEntry.Next() = 0;

        npGpPOSEntries.SetSourceTables(TempNpGpPOSSalesEntry, TempNpGpPOSSalesLine, TempNpGpPOSInfoPOSEntry, TempNpGpPOSPaymentLine);
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnInitRequestBody(POSEntry: Record "NPR POS Entry"; var Xml: Text)
    begin
    end;
}

