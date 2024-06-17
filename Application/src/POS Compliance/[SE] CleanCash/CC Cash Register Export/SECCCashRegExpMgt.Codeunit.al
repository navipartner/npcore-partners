codeunit 6184843 "NPR SE CC Cash Reg. Exp. Mgt."
{
    Access = Internal;

    var
        StartEndDateFilterLbl: Label '%1..%2', Comment = '%1 = Start Date, %2 = End Date', Locked = true;

    #region Cash Register Journal Export Management
    internal procedure ExportCashRegisterJournalFile(StartDate: Date; EndDate: Date; POSUnitNo: Code[20])
    var
        Document: XmlDocument;
    begin
        CreateXMLBaseDocument(Document);
        CreateCashRegisterExportXml(Document, StartDate, EndDate, POSUnitNo);
        DownloadExportFile(Document, StartDate, EndDate);
    end;

    local procedure DownloadExportFile(Document: XmlDocument; StartDate: Date; EndDate: Date)
    var
        TempBlob: Codeunit "Temp Blob";
        IStream: InStream;
        ExportFileTitleTxt: Label 'Export Cash Register Journal File';
        FileNameFormatLbl: Label 'ExportAvDataFranJournalminneEnligtSKVFS2021-16_%1-%2.xml', Comment = '%1 - Start Date, %2 - End Date', Locked = true;
        XmlFileFilterTxt: Label 'Xml File (*.xml)|*.xml', Locked = true;
        OStream: OutStream;
        FileName: Text;
    begin
        FileName := StrSubstNo(FileNameFormatLbl, StartDate, EndDate);
        TempBlob.CreateOutStream(OStream);
        Document.WriteTo(OStream);
        TempBlob.CreateInStream(IStream);

        DownloadFromStream(IStream, ExportFileTitleTxt, '', XmlFileFilterTxt, FileName);
    end;
    #endregion Cash Register Journal Export Management

    #region Cash Register Journal Export XML Structure
    local procedure CreateXMLBaseDocument(var Document: XmlDocument)
    begin
        Document := XmlDocument.Create();
    end;

    local procedure CreateCashRegisterExportXml(var Document: XmlDocument; StartDate: Date; EndDate: Date; POSUnitNo: Code[20])
    var
        CompanyInfo: Record "Company Information";
        DocExportElement: XmlElement;
        PeriodForExportElement: XmlElement;
    begin
        CompanyInfo.Get();

        DocExportElement := CreateXmlElement('ExportAvDataFranJournalminneEnligtSKVFS2021-16', '');
        DocExportElement.Add(CreateXmlElement('InloggadAnvandareVidExportAvDataFranJournalminnet', UserId()));

        DocExportElement.Add(CreateXmlElement('BeteckningPaDetKassaregisterSomExportAvDataFranJournalminnetSkerIfran', POSUnitNo));
        DocExportElement.Add(CreateXmlElement('TidpunktForNarExportAvDataFranJournalminnetSker', Format(WorkDate())));

        PeriodForExportElement := CreateXmlElement('ValdPeriodForExportAvDataFranJournalminne', '');
        PeriodForExportElement.Add(CreateXmlElement('ValdStarttidpunktForExportAvDataFranJournalminnet', Format(StartDate)));
        PeriodForExportElement.Add(CreateXmlElement('ValdSluttidpunktForExportAvDataFranJournalminnet', Format(EndDate)));
        DocExportElement.Add(PeriodForExportElement);

        AppendDesignatedCashRegWCompanyInfoSection(DocExportElement, CompanyInfo, POSUnitNo);

        AppendCashRegistersSection(DocExportElement, StartDate, EndDate, CompanyInfo, POSUnitNo);

        Document.Add(DocExportElement);
    end;

    local procedure AppendDesignatedCashRegWCompanyInfoSection(var DocExportElement: XmlElement; CompanyInfo: Record "Company Information"; POSUnitNo: Code[20])
    var
        CleanCashSetup: Record "NPR CleanCash Setup";
        CompanyInfoElement: XmlElement;
        DesignatedCashRegElement: XmlElement;
    begin
        if not CleanCashSetup.Get(POSUnitNo) then
            exit;

        DesignatedCashRegElement := CreateXmlElement('BeteckningPaValdaKassaregisterForExportAvDataFranJournalminnenLISTA', '');
        DesignatedCashRegElement.Add(CreateXmlElement('BeteckningPaValtKassaregisterForExportAvDataFranJournalminnet', CleanCashSetup.Register));
        DocExportElement.Add(DesignatedCashRegElement);

        CompanyInfoElement := CreateXmlElement('InformationOmForetaget', '');
        CompanyInfoElement.Add(CreateXmlElement('OrganisationsnummerEllerPersonnummer', CleanCashSetup."Organization ID"));
        CompanyInfoElement.Add(CreateXmlElement('ForetagetsNamn', CompanyInfo.Name));
        CompanyInfoElement.Add(CreateXmlElement('NamnPaVerksamheten', CompanyInfo.Address));
        DocExportElement.Add(CompanyInfoElement);
    end;

    local procedure AppendCashRegistersSection(var DocExportElement: XmlElement; StartDate: Date; EndDate: Date; CompanyInfo: Record "Company Information"; POSUnitNo: Code[20])
    var
        CleanCashSetup: Record "NPR CleanCash Setup";
        CashRegListElement: XmlElement;
        CashRegSystemElement: XmlElement;
    begin
        CashRegListElement := CreateXmlElement('KassaregistersystemLISTA', '');
        if not CleanCashSetup.Get(POSUnitNo) then
            exit;

        CashRegSystemElement := CreateXmlElement('Kassaregistersystemet', '');
        CashRegSystemElement.Add(CreateXmlElement('TillverkningsnummerForKassaregistret', CleanCashSetup."CleanCash Register No."));

        AppendGeneralInfoSection(CashRegSystemElement, CleanCashSetup);
        AppendRegisteredItemsSection(CashRegSystemElement, CleanCashSetup, StartDate, EndDate);
        AppendDeletedItemsSection(CashRegSystemElement, StartDate, EndDate);
        AppendIssuedReceiptsSection(CashRegSystemElement, StartDate, EndDate, CleanCashSetup, CompanyInfo);
        AppendIssuedReturnReceiptsSection(CashRegSystemElement, StartDate, EndDate, CleanCashSetup, CompanyInfo);
        AppendIssuedReceiptCopiesSection(CashRegSystemElement, StartDate, EndDate, CleanCashSetup, CompanyInfo);
        AppendXReportSection(CashRegSystemElement, StartDate, EndDate, CleanCashSetup, CompanyInfo);
        AppendZReportSection(CashRegSystemElement, StartDate, EndDate, CleanCashSetup, CompanyInfo);
        AppendCashRegisterLoginInfo(CashRegSystemElement, StartDate, EndDate, CleanCashSetup);
        AppendTrainingReceipt(CashRegSystemElement, CompanyInfo, CleanCashSetup, StartDate, EndDate);
        AppendParkRegisteredItem(CashRegSystemElement, CleanCashSetup, StartDate, EndDate);
        AppendVerificationData(CashRegSystemElement, CleanCashSetup, StartDate, EndDate);

        CashRegListElement.Add(CashRegSystemElement);
        DocExportElement.Add(CashRegListElement);
    end;

    local procedure AppendGeneralInfoSection(var CashRegisterElement: XmlElement; CleanCashSetup: Record "NPR CleanCash Setup")
    begin
        CashRegisterElement.Add(CreateXmlElement('Kassabeteckning', CleanCashSetup.Register));

        if CleanCashSetup.SystemCreatedAt <> 0DT then
            CashRegisterElement.Add(CreateXmlElement('Registreringstidpunkt', Format(DT2Date(CleanCashSetup.SystemCreatedAt))))
        else
            if CleanCashSetup.SystemModifiedAt <> 0DT then
                CashRegisterElement.Add(CreateXmlElement('Registreringstidpunkt', Format(DT2Date(CleanCashSetup.SystemModifiedAt))));
    end;

    local procedure AppendRegisteredItemsSection(var CashRegisterList: XmlElement; CleanCashSetup: Record "NPR CleanCash Setup"; StartDate: Date; EndDate: Date)
    var
        Item: Record Item;
        RegisteredItemElement: XmlElement;
    begin
        Item.SetLoadFields("No.", Description, Inventory, "Base Unit of Measure", "VAT Prod. Posting Group");
        Item.SetAutoCalcFields(Inventory);
        Item.SetFilter(SystemCreatedAt, StartEndDateFilterLbl, CreateDateTime(StartDate, 0T), CreateDateTime(EndDate, 0T));
        if not Item.FindSet() then
            exit;

        repeat
            RegisteredItemElement := CreateXmlElement('RegistreraArtikel', '');
            RegisteredItemElement.Add(CreateXmlElement('Artikelnummer', Item."No."));
            RegisteredItemElement.Add(CreateXmlElement('Artikelnamn', Item.Description));
            RegisteredItemElement.Add(CreateXmlElement('AntalAvRegistreradArtikel', Format(Item.Inventory)));
            RegisteredItemElement.Add(CreateXmlElement('EnhetForViktLangdTidEllerVolym', Item."Base Unit of Measure"));

            AppendSalesPricesForItemSection(RegisteredItemElement, Item, StartDate, EndDate);

            RegisteredItemElement.Add(CreateXmlElement('MervardesskattesatsForRegistreradArtikel', GetVATPercentageFromSetup(CleanCashSetup, Item)));
            RegisteredItemElement.Add(CreateXmlElement('MervardesskattPaRegistreradArtikel', GetTotalVATAmountPerItem(Item)));
            CashRegisterList.Add(RegisteredItemElement);
        until Item.Next() = 0;
    end;

    local procedure AppendSalesPricesForItemSection(var RegisteredItemElement: XmlElement; Item: Record Item; StartDate: Date; EndDate: Date)
    var
        PriceListLine: Record "Price List Line";
        EndingDateFilter: Label '>=%1|''''', Comment = '%1 = Ending Date', Locked = true;
        StartingDateFilter: Label '<=%1', Comment = '%1 = Starting Date', Locked = true;
    begin
        PriceListLine.SetLoadFields("Unit Price");
        PriceListLine.SetRange("Asset No.", Item."No.");
        PriceListLine.SetRange(Status, PriceListLine.Status::Active);
        PriceListLine.SetFilter("Starting Date", StrSubstNo(StartingDateFilter, StartDate));
        PriceListLine.SetFilter("Ending Date", StrSubstNo(EndingDateFilter, EndDate));
        if not PriceListLine.FindSet() then
            exit;

        repeat
            RegisteredItemElement.Add(CreateXmlElement('PrisPerEnhet', Format(PriceListLine."Unit Price")));
        until PriceListLine.Next() = 0;
    end;

    local procedure AppendDeletedItemsSection(var CashRegSystemElement: XmlElement; StartDate: Date; EndDate: Date)
    var
        SECCCashRegAuditLog: Record "NPR SE CC Cash Reg. Audit Log";
        DeletedItemValues: List of [Text];
        DeletedItemElement: XmlElement;
    begin
        SECCCashRegAuditLog.SetRange("Entry Type", SECCCashRegAuditLog."Entry Type"::DELETE_ITEM);
        SECCCashRegAuditLog.SetFilter("Entry Date", StartEndDateFilterLbl, StartDate, EndDate);
        if not SECCCashRegAuditLog.FindSet() then
            exit;

        repeat
            Clear(DeletedItemValues);
            DeletedItemValues := SECCCashRegAuditLog."Additional Information".Split(':');
            DeletedItemElement := CreateXmlElement('RaderaRegistreradArtikel', '');
            DeletedItemElement.Add(CreateXmlElement('Artikelnummer', DeletedItemValues.Get(1)));
            DeletedItemElement.Add(CreateXmlElement('Artikelnamn', DeletedItemValues.Get(2)));
            DeletedItemElement.Add(CreateXmlElement('AntalAvRegistreradArtikel', DeletedItemValues.Get(3)));
            DeletedItemElement.Add(CreateXmlElement('EnhetForViktLangdTidEllerVolym', DeletedItemValues.Get(4)));
            DeletedItemElement.Add(CreateXmlElement('PrisPerEnhet', DeletedItemValues.Get(5)));
            DeletedItemElement.Add(CreateXmlElement('MervardesskattesatsForRegistreradArtikel', DeletedItemValues.Get(7)));
            case DeletedItemValues.Get(6) of
                'true':
                    DeletedItemElement.Add(CreateXmlElement('MervardesskattPaRegistreradArtikel', DeletedItemValues.Get(5)));
                'false':
                    DeletedItemElement.Add(CreateXmlElement('MervardesskattPaRegistreradArtikel', Format(CalculateUnitPriceExclVAT(DeletedItemValues.Get(5), DeletedItemValues.Get(7)))));
            end;
            DeletedItemElement.Add(CreateXmlElement('UrsprungligRegistreringstidpunkt', DeletedItemValues.Get(8)));
            CashRegSystemElement.Add(DeletedItemElement);
        until SECCCashRegAuditLog.Next() = 0;
    end;

    local procedure AppendIssuedReceiptsSection(var CashRegSystemElement: XmlElement; StartDate: Date; EndDate: Date; CleanCashSetup: Record "NPR CleanCash Setup"; CompanyInfo: Record "Company Information")
    var
        Item: Record Item;
        CleanCashTransaction: Record "NPR CleanCash Trans. Request";
        POSEntry: Record "NPR POS Entry";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSStore: Record "NPR POS Store";
        IssuedReceiptElement: XmlElement;
        ItemSoldElement: XmlElement;
        ItemsSoldListElement: XmlElement;
        LineDiscountElement: XmlElement;
        LineDiscountListElement: XmlElement;
        PaymentMethodElement: XmlElement;
        PaymentMethodsListElement: XmlElement;
    begin
        CleanCashTransaction.SetLoadFields("POS Entry No.", "Pos Id", "Receipt Id", "Receipt DateTime", "Receipt Total", "Organisation No.", "CleanCash Unit Id", "CleanCash Code");
        CleanCashTransaction.SetRange("POS Unit No.", CleanCashSetup.Register);
        CleanCashTransaction.SetRange("Request Send Status", CleanCashTransaction."Request Send Status"::COMPLETE);
        CleanCashTransaction.SetRange("Request Type", CleanCashTransaction."Request Type"::RegisterSalesReceipt);
        CleanCashTransaction.SetRange("Receipt Type", CleanCashTransaction."Receipt Type"::normal);
        CleanCashTransaction.SetFilter("Receipt DateTime", StartEndDateFilterLbl, CreateDateTime(StartDate, 0T), CreateDateTime(EndDate, 0T));

        if not CleanCashTransaction.FindSet() then
            exit;
        repeat
            IssuedReceiptElement := CreateXmlElement('Kassakvitto', '');
            IssuedReceiptElement.Add(CreateXmlElement('ForetagetsNamn', CompanyInfo.Name));
            IssuedReceiptElement.Add(CreateXmlElement('OrganisationsnummerEllerPersonnummer', CleanCashSetup."Organization ID"));

            POSEntry.SetLoadFields("Entry No.", "POS Store Code", "Tax Amount");
            POSEntry.Get(CleanCashTransaction."POS Entry No.");
            POSStore.Get(POSEntry."POS Store Code");
            IssuedReceiptElement.Add(CreateXmlElement('DenAdressDarForsaljningSker', POSStore.Address));
            IssuedReceiptElement.Add(CreateXmlElement('DatumOchKlockslagNarKvittoFramstalls', Format(CleanCashTransaction."Receipt DateTime")));
            IssuedReceiptElement.Add(CreateXmlElement('LopnummerForKassakvitto', Format(CleanCashTransaction."Receipt Id")));
            IssuedReceiptElement.Add(CreateXmlElement('Kassabeteckning', CleanCashSetup.Register));

            ItemsSoldListElement := CreateXmlElement('SaldaArtiklarLISTA', '');

            POSEntrySalesLine.SetLoadFields("No.", Description, Quantity, "Unit of Measure Code", "Unit Price", "Amount Incl. VAT", "Amount Excl. VAT", "Line Discount Amount Incl. VAT", "Line Discount %");
            POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
            POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Item);
            POSEntrySalesLine.SetFilter(Quantity, '>0');

            if POSEntrySalesLine.FindSet() then
                repeat
                    Item.SetLoadFields(SystemCreatedAt);
                    Item.Get(POSEntrySalesLine."No.");
                    ItemSoldElement := CreateXmlElement('SaldaArtikel', '');
                    ItemSoldElement.Add(CreateXmlElement('Artikelnummer', POSEntrySalesLine."No."));
                    ItemSoldElement.Add(CreateXmlElement('Artikelnamn', POSEntrySalesLine.Description));
                    ItemSoldElement.Add(CreateXmlElement('AntalAvSaldArtikel', Format(POSEntrySalesLine.Quantity)));
                    ItemSoldElement.Add(CreateXmlElement('EnhetForViktLangdTidEllerVolym', POSEntrySalesLine."Unit of Measure Code"));
                    ItemSoldElement.Add(CreateXmlElement('PrisPerEnhet', Format(POSEntrySalesLine."Unit Price")));
                    ItemSoldElement.Add(CreateXmlElement('PrisPaSaldArtikel', Format(POSEntrySalesLine."Amount Incl. VAT")));

                    if POSEntrySalesLine."Line Discount %" <> 0 then begin
                        LineDiscountListElement := CreateXmlElement('RabatterPaSaldArtikelLISTA', '');
                        LineDiscountElement := CreateXmlElement('RabattPaSaldArtikel', '');
                        LineDiscountElement.Add(CreateXmlElement('RabattensBelopp', Format(POSEntrySalesLine."Line Discount Amount Incl. VAT")));
                        LineDiscountListElement.Add(LineDiscountElement);
                        ItemSoldElement.Add(LineDiscountListElement);
                    end;

                    ItemSoldElement.Add(CreateXmlElement('RabattensBelopp', Format(POSEntrySalesLine."Line Discount %")));
                    ItemSoldElement.Add(CreateXmlElement('MervardesskattPaSaldArtikel', Format(POSEntrySalesLine."Amount Incl. VAT" - POSEntrySalesLine."Amount Excl. VAT")));
                    ItemSoldElement.Add(CreateXmlElement('ArtikelnsRegistreringstidpunkt', Format(Item.SystemCreatedAt)));

                    ItemsSoldListElement.Add(ItemSoldElement);
                until POSEntrySalesLine.Next() = 0;

            IssuedReceiptElement.Add(ItemsSoldListElement);

            IssuedReceiptElement.Add(CreateXmlElement('TotaltForsaljningsbeloppISvenskaKronor', Format(CleanCashTransaction."Receipt Total")));
            IssuedReceiptElement.Add(CreateXmlElement('MervardesskattPaForsaljningsbeloppet', Format(POSEntry."Tax Amount")));

            PaymentMethodsListElement := CreateXmlElement('TotalaForsaljningssummorPerBetalningsmedelLISTA', '');

            POSEntryPaymentLine.SetLoadFields("POS Payment Method Code", "Amount (LCY)");
            POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
            if POSEntryPaymentLine.FindSet() then
                repeat
                    PaymentMethodElement := CreateXmlElement('TotalForsaljningssummaPerBetalningsmedel', '');
                    PaymentMethodElement.Add(CreateXmlElement('Betalningsmedel', POSEntryPaymentLine."POS Payment Method Code"));
                    PaymentMethodElement.Add(CreateXmlElement('ForsaljningssummaPerBetalningsmede', Format(POSEntryPaymentLine."Amount (LCY)")));
                    PaymentMethodsListElement.Add(PaymentMethodElement);
                until POSEntryPaymentLine.Next() = 0;

            IssuedReceiptElement.Add(PaymentMethodsListElement);

            AppendVATTotalsSection(IssuedReceiptElement, POSEntry, false);

            IssuedReceiptElement.Add(CreateXmlElement('LopnummerForZdagrapportPaKvitto', GetWorkshiftZReportNo(POSEntry)));

            IssuedReceiptElement.Add(CreateXmlElement('TillverkningsnummerForKontrollenheten', CleanCashTransaction."Pos Id"));
            IssuedReceiptElement.Add(CreateXmlElement('TillverkningsnummerForKontrollsystemet', CleanCashTransaction."Organisation No."));

            IssuedReceiptElement.Add(CreateXmlElement('Kontrollkod', CleanCashTransaction."CleanCash Unit Id"));
            IssuedReceiptElement.Add(CreateXmlElement('Avstamningskod', CleanCashTransaction."CleanCash Code"));

            CashRegSystemElement.Add(IssuedReceiptElement);
        until CleanCashTransaction.Next() = 0;
    end;

    local procedure AppendIssuedReturnReceiptsSection(var CashRegSystemElement: XmlElement; StartDate: Date; EndDate: Date; CleanCashSetup: Record "NPR CleanCash Setup"; CompanyInfo: Record "Company Information")
    var
        Item: Record Item;
        CleanCashTransaction: Record "NPR CleanCash Trans. Request";
        POSEntry: Record "NPR POS Entry";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSStore: Record "NPR POS Store";
        IssuedReturnReceiptElement: XmlElement;
        ItemSoldElement: XmlElement;
        ItemsSoldListElement: XmlElement;
        LineDiscountElement: XmlElement;
        LineDiscountListElement: XmlElement;
        PaymentMethodElement: XmlElement;
        PaymentMethodsListElement: XmlElement;
    begin
        CleanCashTransaction.SetLoadFields("POS Entry No.", "Pos Id", "Receipt Id", "Receipt DateTime", "Receipt Total", "Organisation No.", "CleanCash Unit Id", "CleanCash Code");
        CleanCashTransaction.SetRange("POS Unit No.", CleanCashSetup.Register);
        CleanCashTransaction.SetRange("Request Send Status", CleanCashTransaction."Request Send Status"::COMPLETE);
        CleanCashTransaction.SetRange("Request Type", CleanCashTransaction."Request Type"::RegisterReturnReceipt);
        CleanCashTransaction.SetRange("Receipt Type", CleanCashTransaction."Receipt Type"::normal);
        CleanCashTransaction.SetFilter("Receipt DateTime", StartEndDateFilterLbl, CreateDateTime(StartDate, 0T), CreateDateTime(EndDate, 0T));

        if not CleanCashTransaction.FindSet() then
            exit;
        repeat
            IssuedReturnReceiptElement := CreateXmlElement('Returkvitto', '');
            IssuedReturnReceiptElement.Add(CreateXmlElement('ForetagetsNamn', CompanyInfo.Name));
            IssuedReturnReceiptElement.Add(CreateXmlElement('OrganisationsnummerEllerPersonnummer', CleanCashSetup."Organization ID"));

            POSEntry.SetLoadFields("Entry No.", "POS Store Code", "Tax Amount");
            POSEntry.Get(CleanCashTransaction."POS Entry No.");
            POSStore.Get(POSEntry."POS Store Code");
            IssuedReturnReceiptElement.Add(CreateXmlElement('DenAdressDarForsaljningSker', POSStore.Address));
            IssuedReturnReceiptElement.Add(CreateXmlElement('DatumOchKlockslagNarKvittoFramstalls', Format(CleanCashTransaction."Receipt DateTime")));
            IssuedReturnReceiptElement.Add(CreateXmlElement('LopnummerForKassakvitto', Format(CleanCashTransaction."Receipt Id")));
            IssuedReturnReceiptElement.Add(CreateXmlElement('Kassabeteckning', CleanCashSetup.Register));

            ItemsSoldListElement := CreateXmlElement('SaldaArtiklarLISTA', '');

            POSEntrySalesLine.SetLoadFields("No.", Description, Quantity, "Unit of Measure Code", "Unit Price", "Amount Incl. VAT", "Amount Excl. VAT", "Line Discount Amount Incl. VAT", "Line Discount %");
            POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
            POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Item);
            POSEntrySalesLine.SetFilter(Quantity, '<0');

            if POSEntrySalesLine.FindSet() then
                repeat
                    Item.SetLoadFields(SystemCreatedAt);
                    Item.Get(POSEntrySalesLine."No.");
                    ItemSoldElement := CreateXmlElement('SaldaArtikel', '');
                    ItemSoldElement.Add(CreateXmlElement('Artikelnummer', POSEntrySalesLine."No."));
                    ItemSoldElement.Add(CreateXmlElement('Artikelnamn', POSEntrySalesLine.Description));
                    ItemSoldElement.Add(CreateXmlElement('AntalAvSaldArtikel', Format(POSEntrySalesLine.Quantity)));
                    ItemSoldElement.Add(CreateXmlElement('EnhetForViktLangdTidEllerVolym', POSEntrySalesLine."Unit of Measure Code"));
                    ItemSoldElement.Add(CreateXmlElement('PrisPerEnhet', Format(POSEntrySalesLine."Unit Price")));
                    ItemSoldElement.Add(CreateXmlElement('PrisPaSaldArtikel', Format(POSEntrySalesLine."Amount Incl. VAT")));

                    if POSEntrySalesLine."Line Discount %" <> 0 then begin
                        LineDiscountListElement := CreateXmlElement('RabatterPaSaldArtikelLISTA', '');
                        LineDiscountElement := CreateXmlElement('RabattPaSaldArtikel', '');
                        LineDiscountElement.Add(CreateXmlElement('RabattensBelopp', Format(POSEntrySalesLine."Line Discount Amount Incl. VAT")));
                        LineDiscountListElement.Add(LineDiscountElement);
                        ItemSoldElement.Add(LineDiscountListElement);
                    end;

                    ItemSoldElement.Add(CreateXmlElement('RabattensBelopp', Format(POSEntrySalesLine."Line Discount %")));
                    ItemSoldElement.Add(CreateXmlElement('MervardesskattPaSaldArtikel', Format(POSEntrySalesLine."Amount Incl. VAT" - POSEntrySalesLine."Amount Excl. VAT")));
                    ItemSoldElement.Add(CreateXmlElement('ArtikelnsRegistreringstidpunkt', Format(Item.SystemCreatedAt)));

                    ItemsSoldListElement.Add(ItemSoldElement);
                until POSEntrySalesLine.Next() = 0;

            IssuedReturnReceiptElement.Add(ItemsSoldListElement);

            IssuedReturnReceiptElement.Add(CreateXmlElement('TotaltForsaljningsbeloppISvenskaKronor', Format(CleanCashTransaction."Receipt Total")));
            IssuedReturnReceiptElement.Add(CreateXmlElement('MervardesskattPaForsaljningsbeloppet', Format(POSEntry."Tax Amount")));

            PaymentMethodsListElement := CreateXmlElement('TotalaForsaljningssummorPerBetalningsmedelLISTA', '');

            POSEntryPaymentLine.SetLoadFields("POS Payment Method Code", "Amount (LCY)");
            POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
            if POSEntryPaymentLine.FindSet() then
                repeat
                    PaymentMethodElement := CreateXmlElement('TotalForsaljningssummaPerBetalningsmedel', '');
                    PaymentMethodElement.Add(CreateXmlElement('Betalningsmedel', POSEntryPaymentLine."POS Payment Method Code"));
                    PaymentMethodElement.Add(CreateXmlElement('ForsaljningssummaPerBetalningsmede', Format(POSEntryPaymentLine."Amount (LCY)")));

                    PaymentMethodsListElement.Add(PaymentMethodElement);
                until POSEntryPaymentLine.Next() = 0;

            IssuedReturnReceiptElement.Add(PaymentMethodsListElement);

            AppendVATTotalsSection(IssuedReturnReceiptElement, POSEntry, true);

            IssuedReturnReceiptElement.Add(CreateXmlElement('LopnummerForZdagrapportPaKvitto', GetWorkshiftZReportNo(POSEntry)));

            IssuedReturnReceiptElement.Add(CreateXmlElement('TillverkningsnummerForKontrollenheten', CleanCashTransaction."Pos Id"));
            IssuedReturnReceiptElement.Add(CreateXmlElement('TillverkningsnummerForKontrollsystemet', CleanCashTransaction."Organisation No."));

            IssuedReturnReceiptElement.Add(CreateXmlElement('Kontrollkod', CleanCashTransaction."CleanCash Unit Id"));
            IssuedReturnReceiptElement.Add(CreateXmlElement('Avstamningskod', CleanCashTransaction."CleanCash Code"));

            CashRegSystemElement.Add(IssuedReturnReceiptElement);
        until CleanCashTransaction.Next() = 0;
    end;

    local procedure AppendIssuedReceiptCopiesSection(var CashRegSystemElement: XmlElement; StartDate: Date; EndDate: Date; CleanCashSetup: Record "NPR CleanCash Setup"; CompanyInfo: Record "Company Information")
    var
        Item: Record Item;
        CleanCashTransaction: Record "NPR CleanCash Trans. Request";
        POSEntry: Record "NPR POS Entry";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSStore: Record "NPR POS Store";
        IssuedReceiptCopyElement: XmlElement;
        ItemSoldElement: XmlElement;
        ItemsSoldListElement: XmlElement;
        LineDiscountElement: XmlElement;
        LineDiscountListElement: XmlElement;
        PaymentMethodElement: XmlElement;
        PaymentMethodsListElement: XmlElement;
    begin
        CleanCashTransaction.SetLoadFields("POS Entry No.", "Pos Id", "Receipt Id", "Receipt DateTime", "Receipt Total", "Organisation No.", "CleanCash Unit Id", "CleanCash Code");
        CleanCashTransaction.SetRange("POS Unit No.", CleanCashSetup.Register);
        CleanCashTransaction.SetRange("Request Send Status", CleanCashTransaction."Request Send Status"::COMPLETE);
        CleanCashTransaction.SetRange("Request Type", CleanCashTransaction."Request Type"::RegisterSalesReceipt);
        CleanCashTransaction.SetRange("Receipt Type", CleanCashTransaction."Receipt Type"::kopia);
        CleanCashTransaction.SetFilter("Receipt DateTime", StartEndDateFilterLbl, CreateDateTime(StartDate, 0T), CreateDateTime(EndDate, 0T));

        if not CleanCashTransaction.FindSet() then
            exit;
        repeat
            IssuedReceiptCopyElement := CreateXmlElement('KopiaAvKassakvitto', '');
            IssuedReceiptCopyElement.Add(CreateXmlElement('ForetagetsNamn', CompanyInfo.Name));
            IssuedReceiptCopyElement.Add(CreateXmlElement('OrganisationsnummerEllerPersonnummer', CleanCashSetup."Organization ID"));

            POSEntry.SetLoadFields("Entry No.", "POS Store Code", "Tax Amount");
            POSEntry.Get(CleanCashTransaction."POS Entry No.");
            POSStore.Get(POSEntry."POS Store Code");
            IssuedReceiptCopyElement.Add(CreateXmlElement('DenAdressDarForsaljningSker', POSStore.Address));
            IssuedReceiptCopyElement.Add(CreateXmlElement('DatumOchKlockslagNarKvittoFramstalls', Format(CleanCashTransaction."Receipt DateTime")));
            IssuedReceiptCopyElement.Add(CreateXmlElement('LopnummerForKvittokopia', Format(CleanCashTransaction."Receipt Id")));
            IssuedReceiptCopyElement.Add(CreateXmlElement('LopnummerPaOriginalkvitto', GetOriginalReceiptIdFromCopy(CleanCashTransaction)));
            IssuedReceiptCopyElement.Add(CreateXmlElement('Kassabeteckning', CleanCashSetup.Register));

            ItemsSoldListElement := CreateXmlElement('SaldaArtiklarLISTA', '');

            POSEntrySalesLine.SetLoadFields("No.", Description, Quantity, "Unit of Measure Code", "Unit Price", "Amount Incl. VAT", "Amount Excl. VAT", "Line Discount Amount Incl. VAT", "Line Discount %");
            POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
            POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Item);

            if POSEntrySalesLine.FindSet() then
                repeat
                    Item.SetLoadFields(SystemCreatedAt);
                    Item.Get(POSEntrySalesLine."No.");
                    ItemSoldElement := CreateXmlElement('SaldaArtikel', '');
                    ItemSoldElement.Add(CreateXmlElement('Artikelnummer', POSEntrySalesLine."No."));
                    ItemSoldElement.Add(CreateXmlElement('Artikelnamn', POSEntrySalesLine.Description));
                    ItemSoldElement.Add(CreateXmlElement('AntalAvSaldArtikel', Format(POSEntrySalesLine.Quantity)));
                    ItemSoldElement.Add(CreateXmlElement('EnhetForViktLangdTidEllerVolym', POSEntrySalesLine."Unit of Measure Code"));
                    ItemSoldElement.Add(CreateXmlElement('PrisPerEnhet', Format(POSEntrySalesLine."Unit Price")));
                    ItemSoldElement.Add(CreateXmlElement('PrisPaSaldArtikel', Format(POSEntrySalesLine."Amount Incl. VAT")));

                    if POSEntrySalesLine."Line Discount %" <> 0 then begin
                        LineDiscountListElement := CreateXmlElement('RabatterPaSaldArtikelLISTA', '');
                        LineDiscountElement := CreateXmlElement('RabattPaSaldArtikel', '');
                        LineDiscountElement.Add(CreateXmlElement('RabattensBelopp', Format(POSEntrySalesLine."Line Discount Amount Incl. VAT")));
                        LineDiscountListElement.Add(LineDiscountElement);
                        ItemSoldElement.Add(LineDiscountListElement);
                    end;

                    ItemSoldElement.Add(CreateXmlElement('RabattensBelopp', Format(POSEntrySalesLine."Line Discount %")));
                    ItemSoldElement.Add(CreateXmlElement('MervardesskattPaSaldArtikel', Format(POSEntrySalesLine."Amount Incl. VAT" - POSEntrySalesLine."Amount Excl. VAT")));
                    ItemSoldElement.Add(CreateXmlElement('ArtikelnsRegistreringstidpunkt', Format(Item.SystemCreatedAt)));

                    ItemsSoldListElement.Add(ItemSoldElement);
                until POSEntrySalesLine.Next() = 0;

            IssuedReceiptCopyElement.Add(ItemsSoldListElement);

            IssuedReceiptCopyElement.Add(CreateXmlElement('TotaltForsaljningsbeloppISvenskaKronor', Format(CleanCashTransaction."Receipt Total")));
            IssuedReceiptCopyElement.Add(CreateXmlElement('MervardesskattPaForsaljningsbeloppet', Format(POSEntry."Tax Amount")));

            PaymentMethodsListElement := CreateXmlElement('TotalaForsaljningssummorPerBetalningsmedelLISTA', '');

            POSEntryPaymentLine.SetLoadFields("POS Payment Method Code", "Amount (LCY)");
            POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
            if POSEntryPaymentLine.FindSet() then
                repeat
                    PaymentMethodElement := CreateXmlElement('TotalForsaljningssummaPerBetalningsmedel', '');
                    PaymentMethodElement.Add(CreateXmlElement('Betalningsmedel', POSEntryPaymentLine."POS Payment Method Code"));
                    PaymentMethodElement.Add(CreateXmlElement('ForsaljningssummaPerBetalningsmede', Format(POSEntryPaymentLine."Amount (LCY)")));

                    PaymentMethodsListElement.Add(PaymentMethodElement);
                until POSEntryPaymentLine.Next() = 0;

            IssuedReceiptCopyElement.Add(PaymentMethodsListElement);

            AppendVATTotalsSection(IssuedReceiptCopyElement, POSEntry, false);

            IssuedReceiptCopyElement.Add(CreateXmlElement('LopnummerForZdagrapportPaKvitto', GetWorkshiftZReportNo(POSEntry)));

            IssuedReceiptCopyElement.Add(CreateXmlElement('TillverkningsnummerForKontrollenheten', CleanCashTransaction."Pos Id"));
            IssuedReceiptCopyElement.Add(CreateXmlElement('TillverkningsnummerForKontrollsystemet', CleanCashTransaction."Organisation No."));

            IssuedReceiptCopyElement.Add(CreateXmlElement('Kontrollkod', CleanCashTransaction."CleanCash Unit Id"));
            IssuedReceiptCopyElement.Add(CreateXmlElement('Avstamningskod', CleanCashTransaction."CleanCash Code"));

            CashRegSystemElement.Add(IssuedReceiptCopyElement);
        until CleanCashTransaction.Next() = 0;
    end;

    local procedure AppendVATTotalsSection(var IssuedReceiptElement: XmlElement; POSEntry: Record "NPR POS Entry"; Return: Boolean)
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        VATRate: Decimal;
        TotalsPerVATRate: Dictionary of [Decimal, Decimal];
        VATRateElement: XmlElement;
        VATRateListElement: XmlElement;
    begin
        POSEntrySalesLine.SetLoadFields(Quantity, "VAT %", "Amount Incl. VAT", "Amount Excl. VAT");
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Item);
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");

        case Return of
            true:
                POSEntrySalesLine.SetFilter(Quantity, '<0');
            false:
                POSEntrySalesLine.SetFilter(Quantity, '>0');
        end;

        if not POSEntrySalesLine.FindSet() then
            exit;

        VATRateListElement := CreateXmlElement('MervardesskattPaOlikaSkattesatserLISTA', '');

        repeat
            if not TotalsPerVATRate.ContainsKey(POSEntrySalesLine."VAT %") then
                TotalsPerVATRate.Add(POSEntrySalesLine."VAT %", POSEntrySalesLine."Amount Incl. VAT" - POSEntrySalesLine."Amount Excl. VAT")
            else
                TotalsPerVATRate.Set(POSEntrySalesLine."VAT %", TotalsPerVATRate.Get(POSEntrySalesLine."VAT %") + POSEntrySalesLine."Amount Incl. VAT" - POSEntrySalesLine."Amount Excl. VAT")
        until POSEntrySalesLine.Next() = 0;

        foreach VATRate in TotalsPerVATRate.Keys() do begin
            VATRateElement := CreateXmlElement('MervardesskattPerSkattesats', '');
            VATRateElement.Add(CreateXmlElement('Mervardesskattesats', Format(VATRate)));
            VATRateElement.Add(CreateXmlElement('TotaltMervardesskattebeloppPerSkattesats', Format(TotalsPerVATRate.Get(VATRate))));
            VATRateListElement.Add(VATRateElement);
        end;

        IssuedReceiptElement.Add(VATRateListElement);
    end;

    local procedure AppendXReportSection(var CashRegSystemElement: XmlElement; StartDate: Date; EndDate: Date; CleanCashSetup: Record "NPR CleanCash Setup"; CompanyInfo: Record "Company Information")
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        XReportElement: XmlElement;
    begin
        POSWorkshiftCheckpoint.SetLoadFields("Created At", "Direct Item Sales (LCY)", "Direct Item Returns (LCY)", "Direct Item Net Sales (LCY)", "Turnover (LCY)", "Direct Item Quantity Sum", "Cash Drawer Open Count", "Direct Item Returns Line Count", "Total Discount (LCY)");
        POSWorkshiftCheckpoint.SetRange("POS Unit No.", CleanCashSetup.Register);
        POSWorkshiftCheckpoint.SetRange(Type, POSWorkshiftCheckpoint.Type::XREPORT);
        POSWorkshiftCheckpoint.SetFilter("Created At", StartEndDateFilterLbl, CreateDateTime(StartDate, 0T), CreateDateTime(EndDate, 0T));
        if not POSWorkshiftCheckpoint.FindSet() then
            exit;
        repeat
            XReportElement := CreateXmlElement('Xdagrapport', '');
            XReportElement.Add(CreateXmlElement('ForetagetsNamn', CompanyInfo.Name));
            XReportElement.Add(CreateXmlElement('OrganisationsnummerEllerPersonnummer', CleanCashSetup."Organization ID"));
            XReportElement.Add(CreateXmlElement('DatumOchKlockslagNarRapportFramstalls', Format(POSWorkshiftCheckpoint."Created At")));
            XReportElement.Add(CreateXmlElement('Kassabeteckning', CleanCashSetup.Register));
            XReportElement.Add(CreateXmlElement('TotalForsaljningssumma', Format(POSWorkshiftCheckpoint."Direct Item Sales (LCY)" - Abs(POSWorkshiftCheckpoint."Direct Item Returns (LCY)"))));

            AppendTotalSalesAmountsSection(XReportElement, POSWorkshiftCheckpoint);
            AppendTaxWorshiftSummarySection(XReportElement, POSWorkshiftCheckpoint);

            XReportElement.Add(CreateXmlElement('VaxelkassansBeloppISvenskaKronor', Format(POSWorkshiftCheckpoint."Turnover (LCY)")));
            XReportElement.Add(CreateXmlElement('AntalKassakvitton', Format(POSWorkshiftCheckpoint."Direct Item Quantity Sum")));
            XReportElement.Add(CreateXmlElement('AntalKassaladoppningar', Format(POSWorkshiftCheckpoint."Cash Drawer Open Count")));
            XReportElement.Add(CreateXmlElement('AntalKvittokopior', GetCCTransactionsCopiesCount(CleanCashSetup, StartDate, EndDate)));
            XReportElement.Add(CreateXmlElement('AntalKvittonSomTagitsFramIOvningslage', GetCCTransactionsTrainingCount(CleanCashSetup, StartDate, EndDate)));

            AppendPaymentMethodsSection(XReportElement, POSWorkshiftCheckpoint);

            XReportElement.Add(CreateXmlElement('AntalReturer', Format(POSWorkshiftCheckpoint."Direct Item Returns Line Count")));
            XReportElement.Add(CreateXmlElement('ReturernasBelopp', Format(POSWorkshiftCheckpoint."Direct Item Returns (LCY)")));
            XReportElement.Add(CreateXmlElement('RabatternasBelopp', Format(POSWorkshiftCheckpoint."Total Discount (LCY)")));
            XReportElement.Add(CreateXmlElement('GrandTotalForsaljning', Format(POSWorkshiftCheckpoint."Direct Item Sales (LCY)")));
            XReportElement.Add(CreateXmlElement('GrandTotalRetur', Format(POSWorkshiftCheckpoint."Direct Item Returns (LCY)")));
            XReportElement.Add(CreateXmlElement('GrandTotalNetto', Format(POSWorkshiftCheckpoint."Direct Item Net Sales (LCY)")));

            CashRegSystemElement.Add(XReportElement);
        until POSWorkshiftCheckpoint.Next() = 0;
    end;

    local procedure AppendTotalSalesAmountsSection(var ReportElement: XmlElement; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        TotalSalesElement: XmlElement;
        TotalSalesListElement: XmlElement;
    begin
        TotalSalesListElement := CreateXmlElement('TotalaForsaljningssummorForOlikaHuvudgrupperLISTA', '');
        TotalSalesElement := CreateXmlElement('TotalForsaljningssummaForOlikaHuvudgrupper', '');
        TotalSalesElement.Add(CreateXmlElement('TotalForsaljningssummaForOlikaHuvudgrupper', Format(POSWorkshiftCheckpoint."Direct Item Sales (LCY)")));
        TotalSalesListElement.Add(TotalSalesElement);
        TotalSalesElement.RemoveNodes();
        TotalSalesElement.Add(CreateXmlElement('TotalForsaljningssummaForOlikaHuvudgrupper', Format(POSWorkshiftCheckpoint."Direct Item Returns (LCY)")));
        TotalSalesListElement.Add(TotalSalesElement);

        ReportElement.Add(TotalSalesListElement);
    end;

    local procedure AppendZReportSection(CashRegSystemElement: XmlElement; StartDate: Date; EndDate: Date; CleanCashSetup: Record "NPR CleanCash Setup"; CompanyInfo: Record "Company Information")
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        ZReportElement: XmlElement;
    begin
        POSWorkshiftCheckpoint.SetLoadFields("Created At", "Direct Item Sales (LCY)", "Direct Item Returns (LCY)", "Turnover (LCY)", "Direct Item Quantity Sum", "Cash Drawer Open Count", "Direct Item Returns Line Count", "Total Discount (LCY)");
        POSWorkshiftCheckpoint.SetRange("POS Unit No.", CleanCashSetup.Register);
        POSWorkshiftCheckpoint.SetRange(Type, POSWorkshiftCheckpoint.Type::ZREPORT);
        POSWorkshiftCheckpoint.SetFilter("Created At", StartEndDateFilterLbl, CreateDateTime(StartDate, 0T), CreateDateTime(EndDate, 0T));
        if not POSWorkshiftCheckpoint.FindSet() then
            exit;
        repeat
            ZReportElement := CreateXmlElement('Zdagrapport', '');
            ZReportElement.Add(CreateXmlElement('ForetagetsNamn', CompanyInfo.Name));
            ZReportElement.Add(CreateXmlElement('OrganisationsnummerEllerPersonnummer', CleanCashSetup."Organization ID"));
            ZReportElement.Add(CreateXmlElement('DatumOchKlockslagNarRapportFramstalls', Format(POSWorkshiftCheckpoint."Created At")));
            ZReportElement.Add(CreateXmlElement('Kassabeteckning', CleanCashSetup.Register));
            ZReportElement.Add(CreateXmlElement('TillverkningsnummerForKassaregistret', CleanCashSetup."CleanCash Register No."));
            ZReportElement.Add(CreateXmlElement('TotalForsaljningssumma', Format(POSWorkshiftCheckpoint."Direct Item Sales (LCY)" - Abs(POSWorkshiftCheckpoint."Direct Item Returns (LCY)"))));

            AppendTotalSalesAmountsSection(ZReportElement, POSWorkshiftCheckpoint);
            AppendTaxWorshiftSummarySection(ZReportElement, POSWorkshiftCheckpoint);

            ZReportElement.Add(CreateXmlElement('VaxelkassansBeloppISvenskaKronor', Format(POSWorkshiftCheckpoint."Turnover (LCY)")));
            ZReportElement.Add(CreateXmlElement('AntalKassakvitton', Format(POSWorkshiftCheckpoint."Direct Item Quantity Sum")));
            ZReportElement.Add(CreateXmlElement('AntalKassaladoppningar', Format(POSWorkshiftCheckpoint."Cash Drawer Open Count")));
            ZReportElement.Add(CreateXmlElement('AntalKvittokopior', GetCCTransactionsCopiesCount(CleanCashSetup, StartDate, EndDate)));
            ZReportElement.Add(CreateXmlElement('AntalKvittonSomTagitsFramIOvningslage', GetCCTransactionsTrainingCount(CleanCashSetup, StartDate, EndDate)));

            AppendPaymentMethodsSection(ZReportElement, POSWorkshiftCheckpoint);

            ZReportElement.Add(CreateXmlElement('AntalReturer', Format(POSWorkshiftCheckpoint."Direct Item Returns Line Count")));
            ZReportElement.Add(CreateXmlElement('ReturernasBelopp', Format(POSWorkshiftCheckpoint."Direct Item Returns (LCY)")));
            ZReportElement.Add(CreateXmlElement('RabatternasBelopp', Format(POSWorkshiftCheckpoint."Total Discount (LCY)")));
            ZReportElement.Add(CreateXmlElement('GrandTotalForsaljning', Format(POSWorkshiftCheckpoint."Direct Item Sales (LCY)")));
            ZReportElement.Add(CreateXmlElement('GrandTotalRetur', Format(POSWorkshiftCheckpoint."Direct Item Returns (LCY)")));
            ZReportElement.Add(CreateXmlElement('GrandTotalNetto', Format(POSWorkshiftCheckpoint."Direct Item Sales (LCY)" - Abs(POSWorkshiftCheckpoint."Direct Item Returns (LCY)"))));

            CashRegSystemElement.Add(ZReportElement);
        until POSWorkshiftCheckpoint.Next() = 0;
    end;

    local procedure AppendTaxWorshiftSummarySection(var ReportElement: XmlElement; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        POSWorkshiftTaxCheckpoint: Record "NPR POS Worksh. Tax Checkp.";
        TaxSummaryElement: XmlElement;
        TaxSummaryListElement: XmlElement;
    begin
        POSWorkshiftTaxCheckpoint.SetLoadFields("Tax %", "Tax Amount");
        POSWorkshiftTaxCheckpoint.SetRange("Workshift Checkpoint Entry No.", POSWorkshiftCheckpoint."Entry No.");
        if not POSWorkshiftTaxCheckpoint.FindSet() then
            exit;
        TaxSummaryListElement := CreateXmlElement('MervardesskattPaOlikaSkattesatserLISTA', '');
        repeat
            TaxSummaryElement := CreateXmlElement('MervardesskattPerSkattesats', '');
            TaxSummaryElement.Add(CreateXmlElement('Mervardesskattesats', Format(POSWorkshiftTaxCheckpoint."Tax %")));
            TaxSummaryElement.Add(CreateXmlElement('TotaltMervardesskattebeloppPerSkattesats', Format(POSWorkshiftTaxCheckpoint."Tax Amount")));
            TaxSummaryListElement.Add(TaxSummaryElement);
        until POSWorkshiftTaxCheckpoint.Next() = 0;
        ReportElement.Add(TaxSummaryListElement);
    end;

    local procedure AppendPaymentMethodsSection(var ReportElement: XmlElement; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        POSPaymentBinCheckp: Record "NPR POS Payment Bin Checkp.";
        TotalPaymentMethodElement: XmlElement;
        TotalPaymentMethodsListElement: XmlElement;
    begin
        POSPaymentBinCheckp.SetLoadFields("Payment Method No.", "Calculated Amount Incl. Float");
        POSPaymentBinCheckp.SetRange("Workshift Checkpoint Entry No.", POSWorkshiftCheckpoint."Entry No.");
        if not POSPaymentBinCheckp.FindSet() then
            exit;
        TotalPaymentMethodsListElement := CreateXmlElement('TotalaForsaljningssummorPerBetalningsmedelLISTA', '');
        repeat
            TotalPaymentMethodElement := CreateXmlElement('TotalForsaljningssummaPerBetalningsmedel', '');
            TotalPaymentMethodElement.Add(CreateXmlElement('Betalningsmedel', POSPaymentBinCheckp."Payment Method No."));
            TotalPaymentMethodElement.Add(CreateXmlElement('ForsaljningssummaPerBetalningsmedel', Format(POSPaymentBinCheckp."Calculated Amount Incl. Float")));
            TotalPaymentMethodsListElement.Add(TotalPaymentMethodElement);
        until POSPaymentBinCheckp.Next() = 0;
        ReportElement.Add(TotalPaymentMethodsListElement);
    end;

    local procedure AppendCashRegisterLoginInfo(var CashRegSystemElement: XmlElement; StartDate: Date; EndDate: Date; CleanCashSetup: Record "NPR CleanCash Setup")
    var
        POSAuditLog: Record "NPR POS Audit Log";
        LogInPOSUnit, LogOutPOSUnit : DateTime;
    begin
        POSAuditLog.SetCurrentKey("Acted on POS Unit No.", "Action Type");
        POSAuditLog.SetLoadFields(SystemCreatedAt);
        POSAuditLog.SetRange("Active POS Unit No.", CleanCashSetup.Register);
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::SIGN_IN);
        POSAuditLog.SetFilter(SystemCreatedAt, StartEndDateFilterLbl, CreateDateTime(StartDate, 0T), CreateDateTime(EndDate, 0T));
        if not POSAuditLog.FindLast() then
            exit;
        LogInPOSUnit := POSAuditLog.SystemCreatedAt;
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::SIGN_OUT);
        if not POSAuditLog.FindLast() then
            exit;
        LogOutPOSUnit := POSAuditLog.SystemCreatedAt;

        CashRegSystemElement.Add(CreateXmlElement('StartAvKassaregister', Format(LogInPOSUnit)));
        CashRegSystemElement.Add(CreateXmlElement('StoppAvKassaregister', Format(LogOutPOSUnit)));
        CashRegSystemElement.Add(CreateXmlElement('InloggningIKassaregister', Format(LogInPOSUnit)));
        CashRegSystemElement.Add(CreateXmlElement('UtloggningUrKassaregister', Format(LogOutPOSUnit)));
    end;

    local procedure AppendTrainingReceipt(var CashRegSystemElement: XmlElement; CompanyInfo: Record "Company Information"; CleanCashSetup: Record "NPR CleanCash Setup"; StartDate: Date; EndDate: Date)
    var
        Item: Record Item;
        CleanCashTransaction: Record "NPR CleanCash Trans. Request";
        POSEntry: Record "NPR POS Entry";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSStore: Record "NPR POS Store";
        ItemSoldElement: XmlElement;
        ItemsSoldListElement: XmlElement;
        LineDiscountElement: XmlElement;
        LineDiscountListElement: XmlElement;
        OvningskvittoElment: XmlElement;
        PaymentMethodElement: XmlElement;
        PaymentMethodsListElement: XmlElement;
    begin
        CleanCashTransaction.SetLoadFields("POS Entry No.", "Receipt Id", "Receipt DateTime", "Receipt Total", "CleanCash Unit Id", "CleanCash Code");
        CleanCashTransaction.SetRange("POS Unit No.", CleanCashSetup.Register);
        CleanCashTransaction.SetRange("Request Send Status", CleanCashTransaction."Request Send Status"::COMPLETE);
        CleanCashTransaction.SetRange("Receipt Type", CleanCashTransaction."Receipt Type"::ovning);
        CleanCashTransaction.SetFilter("Receipt DateTime", StartEndDateFilterLbl, CreateDateTime(StartDate, 0T), CreateDateTime(EndDate, 0T));
        CleanCashTransaction.SetFilter("Request Type", '%1|%2', CleanCashTransaction."Request Type"::RegisterSalesReceipt, CleanCashTransaction."Request Type"::RegisterReturnReceipt);
        if CleanCashTransaction.IsEmpty() then
            exit;
        CleanCashTransaction.FindSet();
        repeat
            OvningskvittoElment := CreateXmlElement('OvningskvittoElment', '');
            OvningskvittoElment.Add(CreateXmlElement('ForetagetsNamn', CompanyInfo.Name));
            OvningskvittoElment.Add(CreateXmlElement('OrganisationsnummerEllerPersonnummer', CleanCashSetup."Organization ID"));
            POSEntry.SetLoadFields("POS Store Code", "Tax Amount");
            POSEntry.Get(CleanCashTransaction."POS Entry No.");
            POSStore.SetLoadFields(Address);
            POSStore.Get(POSEntry."POS Store Code");
            OvningskvittoElment.Add(CreateXmlElement('DenAdressDarForsaljningSker', POSStore.Address));
            OvningskvittoElment.Add(CreateXmlElement('DatumOchKlockslagNarKvittoFramstalls', Format(CleanCashTransaction."Receipt DateTime")));
            OvningskvittoElment.Add(CreateXmlElement('LopnummerForOvningskvitto', CleanCashTransaction."Receipt Id"));
            OvningskvittoElment.Add(CreateXmlElement('Kassabeteckning', CleanCashSetup.Register));

            ItemsSoldListElement := CreateXmlElement('SaldaArtiklarLISTA', '');
            POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
            POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Item);
            POSEntrySalesLine.SetFilter(Quantity, '>0');
            if POSEntrySalesLine.FindSet() then
                repeat
                    Item.Get(POSEntrySalesLine."No.");
                    ItemSoldElement := CreateXmlElement('SaldArtikel', '');
                    ItemSoldElement.Add(CreateXmlElement('Artikelnummer', POSEntrySalesLine."No."));
                    ItemSoldElement.Add(CreateXmlElement('Artikelnamn', POSEntrySalesLine.Description));
                    ItemSoldElement.Add(CreateXmlElement('AntalAvSaldArtikel', Format(POSEntrySalesLine.Quantity)));
                    ItemSoldElement.Add(CreateXmlElement('EnhetForViktLangdTidEllerVolym', POSEntrySalesLine."Unit of Measure Code"));
                    ItemSoldElement.Add(CreateXmlElement('PrisPerEnhet', Format(POSEntrySalesLine."Unit Price")));
                    ItemSoldElement.Add(CreateXmlElement('PrisPaSaldArtikel', Format(POSEntrySalesLine."Amount Incl. VAT")));

                    if POSEntrySalesLine."Line Discount %" <> 0 then begin
                        LineDiscountListElement := CreateXmlElement('RabatterPaSaldArtikelLISTA', '');
                        LineDiscountElement := CreateXmlElement('RabattPaSaldArtikel', '');
                        LineDiscountElement := CreateXmlElement('RabattensBelopp', Format(POSEntrySalesLine."Line Discount Amount Incl. VAT"));
                        LineDiscountListElement.Add(LineDiscountElement);
                        ItemSoldElement.Add(LineDiscountListElement);
                    end;
                    ItemSoldElement.Add(CreateXmlElement('MervardesskattesatsForSaldArtikel', Format(POSEntrySalesLine."Amount Incl. VAT" - POSEntrySalesLine."Amount Excl. VAT")));
                    ItemSoldElement.Add(CreateXmlElement('ArtikelnsRegistreringstidpunkt', Format(Item.SystemCreatedAt)));
                    ItemsSoldListElement.Add(ItemSoldElement);
                until POSEntrySalesLine.Next() = 0;
            OvningskvittoElment.Add(ItemsSoldListElement);

            OvningskvittoElment.Add(CreateXmlElement('TotaltForsaljningsbeloppISvenskaKronor', Format(CleanCashTransaction."Receipt Total")));
            OvningskvittoElment.Add(CreateXmlElement('MervardesskattPaForsaljningsbeloppet', Format(POSEntry."Tax Amount")));

            PaymentMethodsListElement := CreateXmlElement('TotalaForsaljningssummorPerBetalningsmedelLISTA', '');

            POSEntryPaymentLine.SetLoadFields("POS Payment Method Code", "Amount (LCY)");
            POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
            if POSEntryPaymentLine.FindSet() then
                repeat
                    PaymentMethodElement := CreateXmlElement('TotalForsaljningssummaPerBetalningsmedel', '');
                    PaymentMethodElement.Add(CreateXmlElement('Betalningsmedel', POSEntryPaymentLine."POS Payment Method Code"));
                    PaymentMethodElement.Add(CreateXmlElement('ForsaljningssummaPerBetalningsmedel', Format(POSEntryPaymentLine."Amount (LCY)")));
                    PaymentMethodsListElement.Add(PaymentMethodElement);
                until POSEntryPaymentLine.Next() = 0;

            OvningskvittoElment.Add(PaymentMethodsListElement);
            AppendVATTotalsSection(OvningskvittoElment, POSEntry, false);
            CashRegSystemElement.Add(OvningskvittoElment);

            OvningskvittoElment.Add(CreateXmlElement('LopnummerForZdagrapportPaKvitto', GetWorkshiftZReportNo(POSEntry)));
            OvningskvittoElment.Add(CreateXmlElement('Kontrollkod', CleanCashTransaction."CleanCash Unit Id"));
            OvningskvittoElment.Add(CreateXmlElement('Avstamningskod', CleanCashTransaction."CleanCash Code"));
        until CleanCashTransaction.Next() = 0;
    end;

    local procedure AppendParkRegisteredItem(var CashRegSystemElement: XmlElement; CleanCashSetup: Record "NPR CleanCash Setup"; StartDate: Date; EndDate: Date)
    var
        Item: Record Item;
        POSSavedSales: Record "NPR POS Saved Sale Entry";
        POSSavedSalesLine: Record "NPR POS Saved Sale Line";
        DiscountElement: XmlElement;
        DiscountListElement: XmlElement;
        ParkeraRegisteredArtikel: XmlElement;
    begin
        POSSavedSales.SetRange("Register No.", CleanCashSetup.Register);
        POSSavedSales.SetFilter("Created at", StartEndDateFilterLbl, CreateDateTime(StartDate, 0T), CreateDateTime(EndDate, 0T));

        if POSSavedSales.IsEmpty() then
            exit;
        POSSavedSales.FindSet();
        repeat
            POSSavedSalesLine.SetRange("Quote Entry No.", POSSavedSales."Entry No.");
            POSSavedSalesLine.SetLoadFields("No.", Description, Quantity, "Unit Price", "Unit of Measure Code", "Amount Including VAT", "Discount %", "Discount Amount", Amount);
            if POSSavedSalesLine.FindSet() then
                repeat
                    Item.Get(POSSavedSalesLine."No.");
                    ParkeraRegisteredArtikel := CreateXmlElement('ParkeraRegistreradArtikel', '');
                    ParkeraRegisteredArtikel.Add(CreateXmlElement('Artikelnummer', POSSavedSalesLine."No."));
                    ParkeraRegisteredArtikel.Add(CreateXmlElement('Artikelnamn', POSSavedSalesLine.Description));
                    ParkeraRegisteredArtikel.Add(CreateXmlElement('AntalAvRegistreradArtikel', Format(POSSavedSalesLine.Quantity)));
                    ParkeraRegisteredArtikel.Add(CreateXmlElement('PrisPerEnhet', Format(POSSavedSalesLine."Unit Price")));
                    ParkeraRegisteredArtikel.Add(CreateXmlElement('EnhetForViktLangdTidEllerVolym', Format(POSSavedSalesLine."Unit of Measure Code")));
                    ParkeraRegisteredArtikel.Add(CreateXmlElement('PrisPaRegistreradArtikel', Format(POSSavedSalesLine."Amount Including VAT")));
                    ParkeraRegisteredArtikel.Add(CreateXmlElement('MervardesskattesatsForRegistreradArtikel', GetVATPercentageFromSetup(CleanCashSetup, Item)));

                    if POSSavedSalesLine."Discount %" <> 0 then begin
                        DiscountListElement := CreateXmlElement('RabatterPaRegistreradArtikelLISTA', '');
                        DiscountElement := CreateXmlElement('RabattPaRegistreradArtikel', '');
                        DiscountElement := CreateXmlElement('RabattensBelopp', Format(POSSavedSalesLine."Discount Amount"));
                        DiscountListElement.Add(DiscountElement);
                        ParkeraRegisteredArtikel.Add(DiscountListElement);
                    end;

                    ParkeraRegisteredArtikel.Add(CreateXmlElement('MervardesskattesatsForRegistreradArtikel', Format(POSSavedSalesLine."Amount Including VAT" - POSSavedSalesLine.Amount)));
                    CashRegSystemElement.Add(ParkeraRegisteredArtikel);
                until POSSavedSalesLine.Next() = 0;
        until POSSavedSales.Next() = 0;
    end;

    local procedure AppendVerificationData(var CashRegSystemElement: XmlElement; CleanCashSetup: Record "NPR CleanCash Setup"; StartDate: Date; EndDate: Date)
    var
        CleanCashTransaction: Record "NPR CleanCash Trans. Request";
        KontrollprogramOchKontrollserverElement: XmlElement;
    begin
        CleanCashTransaction.SetLoadFields("Receipt Id", "CleanCash Code", "CleanCash Main Status", "POS Document No.");
        CleanCashTransaction.SetRange("POS Unit No.", CleanCashSetup.Register);
        CleanCashTransaction.SetRange("Request Send Status", CleanCashTransaction."Request Send Status"::COMPLETE);
        CleanCashTransaction.SetFilter("Receipt DateTime", StartEndDateFilterLbl, CreateDateTime(StartDate, 0T), CreateDateTime(EndDate, 0T));
        if CleanCashTransaction.IsEmpty() then
            exit;
        CleanCashTransaction.FindSet();
        repeat
            KontrollprogramOchKontrollserverElement := CreateXmlElement('VerifieringAvKvittodataMellanKontrollprogramOchKontrollserver', '');
            KontrollprogramOchKontrollserverElement.Add(CreateXmlElement('StatuskodFranKontrollprogrammet', Format(CleanCashTransaction."CleanCash Main Status")));
            KontrollprogramOchKontrollserverElement.Add(CreateXmlElement('VerifieringAvKvittodataMellanKontrollprogramOchKontrollserver', CleanCashTransaction."CleanCash Code"));
            KontrollprogramOchKontrollserverElement.Add(CreateXmlElement('LopnummerForKassakvitto', CleanCashTransaction."Receipt Id"));
            KontrollprogramOchKontrollserverElement.Add(CreateXmlElement('AntalDokument', CleanCashTransaction."POS Document No."));
            CashRegSystemElement.Add(KontrollprogramOchKontrollserverElement);
        until CleanCashTransaction.Next() = 0;
    end;

    local procedure CalculateUnitPriceExclVAT(UnitPrice: Text; VATPerc: Text): Decimal
    var
        UnitP, VATP : Decimal;
    begin
        Evaluate(UnitP, UnitPrice);
        Evaluate(VATP, VATPerc);
        exit(UnitP - (UnitP * VATP))
    end;

    #endregion Cash Register Journal Export XML Structure

    #region Helper procedures
    local procedure CreateXmlElement(Name: Text; Content: Text) Element: XmlElement
    begin
        Element := XmlElement.Create(Name);
        Element.Add(XmlText.Create(Content));
    end;

    local procedure GetWorkshiftZReportNo(POSEntry: Record "NPR POS Entry"): Text
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
    begin
        POSWorkshiftCheckpoint.SetLoadFields("Entry No.");
        POSWorkshiftCheckpoint.SetRange("POS Unit No.", POSEntry."POS Unit No.");
        POSWorkshiftCheckpoint.SetRange(Type, POSWorkshiftCheckpoint.Type::ZREPORT);
        POSWorkshiftCheckpoint.SetFilter("Created At", StartEndDateFilterLbl, CreateDateTime(POSEntry."Entry Date", 0T), CreateDateTime(POSEntry."Entry Date", 0T));
        if not POSWorkshiftCheckpoint.FindFirst() then
            exit;
        exit(Format(POSWorkshiftCheckpoint."Entry No."))
    end;

    local procedure GetOriginalReceiptIdFromCopy(CleanCashTransactionCopy: Record "NPR CleanCash Trans. Request"): Text
    var
        CleanCashTransaction: Record "NPR CleanCash Trans. Request";
    begin
        CleanCashTransaction.SetLoadFields("Receipt Id");
        CleanCashTransaction.SetFilter("POS Entry No.", '=%1', CleanCashTransactionCopy."POS Entry No.");
        CleanCashTransaction.SetFilter("Request Send Status", '=%1', CleanCashTransaction."Request Send Status"::COMPLETE);
        CleanCashTransaction.SetFilter("Receipt Type", '<>%1', CleanCashTransaction."Receipt Type"::kopia);
        if not CleanCashTransaction.FindFirst() then
            exit;
        exit(CleanCashTransaction."Receipt Id")
    end;

    local procedure GetCCTransactionsCopiesCount(CleanCashSetup: Record "NPR CleanCash Setup"; StartDate: Date; EndDate: Date): Text
    var
        CleanCashTransaction: Record "NPR CleanCash Trans. Request";
    begin
        CleanCashTransaction.SetRange("POS Unit No.", CleanCashSetup.Register);
        CleanCashTransaction.SetRange("Request Send Status", CleanCashTransaction."Request Send Status"::COMPLETE);
        CleanCashTransaction.SetRange("Receipt Type", CleanCashTransaction."Receipt Type"::kopia);
        CleanCashTransaction.SetFilter("Receipt DateTime", StartEndDateFilterLbl, CreateDateTime(StartDate, 0T), CreateDateTime(EndDate, 0T));
        CleanCashTransaction.SetFilter("Request Type", '%1|%2', CleanCashTransaction."Request Type"::RegisterSalesReceipt, CleanCashTransaction."Request Type"::RegisterReturnReceipt);

        exit(Format(CleanCashTransaction.Count()));
    end;

    local procedure GetCCTransactionsTrainingCount(CleanCashSetup: Record "NPR CleanCash Setup"; StartDate: Date; EndDate: Date): Text
    var
        CleanCashTransaction: Record "NPR CleanCash Trans. Request";
    begin
        CleanCashTransaction.SetRange("POS Unit No.", CleanCashSetup.Register);
        CleanCashTransaction.SetRange("Request Send Status", CleanCashTransaction."Request Send Status"::COMPLETE);
        CleanCashTransaction.SetRange("Receipt Type", CleanCashTransaction."Receipt Type"::ovning);
        CleanCashTransaction.SetFilter("Receipt DateTime", StartEndDateFilterLbl, CreateDateTime(StartDate, 0T), CreateDateTime(EndDate, 0T));
        CleanCashTransaction.SetFilter("Request Type", '%1|%2', CleanCashTransaction."Request Type"::RegisterSalesReceipt, CleanCashTransaction."Request Type"::RegisterReturnReceipt);

        exit(Format(CleanCashTransaction.Count()));
    end;

    local procedure GetVATPercentageFromSetup(CleanCashSetup: Record "NPR CleanCash Setup"; Item: Record Item): Text
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if not POSUnit.Get(CleanCashSetup.Register) then
            exit;
        if not POSStore.Get(POSUnit."POS Store Code") then
            exit;
        if not POSPostingProfile.Get(POSStore."POS Posting Profile") then
            exit;
        case VATPostingSetup.Get(POSPostingProfile."VAT Bus. Posting Group", Item."VAT Prod. Posting Group") of
            true:
                exit(Format(VATPostingSetup."VAT %"));
            false:
                exit;
        end;
    end;

    local procedure GetTotalVATAmountPerItem(Item: Record Item): Text
    var
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        PurchInvLine.SetCurrentKey("Document No.", "Location Code");
        PurchInvLine.SetLoadFields(Amount, "Amount Including VAT");
        PurchInvLine.SetRange(Type, PurchInvLine.Type::Item);
        PurchInvLine.SetRange("No.", Item."No.");
        PurchInvLine.CalcSums(Amount, "Amount Including VAT");
        exit(Format(PurchInvLine."Amount Including VAT" - PurchInvLine.Amount));
    end;

    #endregion Helper procedures
}