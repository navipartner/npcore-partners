codeunit 6184843 "NPR SE CC Cash Reg. Exp. Mgt."
{
    // Journal export according to SKVFS 2021:16, validated against Skatteverket's XML schema version 2021-12-08.
    Access = Internal;

    var
        _CleanCashSetup: Record "NPR CleanCash Setup";
        _CompanyInformation: Record "Company Information";
        _ControlUnitId: Text;
        _LastJournalEventEntryNo: Integer;
        _PeriodEnd: DateTime;
        _PeriodStart: DateTime;

    #region Cash Register Journal Export Management
    internal procedure ExportCashRegisterJournalFile(StartDate: Date; EndDate: Date; POSUnitNo: Code[20])
    var
        Document: XmlDocument;
    begin
        CreateCashRegisterJournal(StartDate, EndDate, POSUnitNo, Document);
        DownloadExportFile(Document, StartDate, EndDate);
    end;

    internal procedure CreateCashRegisterJournal(StartDate: Date; EndDate: Date; POSUnitNo: Code[20]; var Document: XmlDocument)
    var
        POSUnit: Record "NPR POS Unit";
        TempJournalEvent: Record "NPR SE CC Journal Event" temporary;
        RootElement: XmlElement;
        NoRegistrationsErr: Label 'There are no registrations for %1 %2 from %3 to %4, so there is nothing to export.', Comment = '%1 = POS Unit table caption, %2 = POS Unit No., %3 = Start Date, %4 = End Date';
    begin
        Initialize(StartDate, EndDate, POSUnitNo);

        _LastJournalEventEntryNo := 0;
        CollectJournalEvents(TempJournalEvent);
        if TempJournalEvent.IsEmpty() then
            Error(NoRegistrationsErr, POSUnit.TableCaption(), POSUnitNo, StartDate, EndDate);
        _ControlUnitId := FindControlUnitId();

        Document := XmlDocument.Create();
        Document.SetDeclaration(XmlDeclaration.Create('1.0', 'UTF-8', 'yes'));
        RootElement := XmlElement.Create('ExportAvDataFranJournalminneEnligtSKVFS2021-16', InstansNamespace());
        RootElement.Add(XmlAttribute.CreateNamespaceDeclaration('utrein', InstansNamespace()));
        RootElement.Add(XmlAttribute.CreateNamespaceDeclaration('utreko', KomponentNamespace()));
        AppendHeader(RootElement);
        AppendRegistrations(RootElement, TempJournalEvent);
        Document.Add(RootElement);
    end;

    local procedure Initialize(StartDate: Date; EndDate: Date; POSUnitNo: Code[20])
    var
        EndBeforeStartErr: Label 'The end date %1 is before the start date %2.', Comment = '%1 = End Date, %2 = Start Date';
        PeriodMissingErr: Label 'You must specify both a start date and an end date.';
        SetupMissingErr: Label 'There is no %1 with %2 %3.', Comment = '%1 = CleanCash Setup table caption, %2 = Register field caption, %3 = POS Unit No.';
    begin
        if (StartDate = 0D) or (EndDate = 0D) then
            Error(PeriodMissingErr);
        if EndDate < StartDate then
            Error(EndBeforeStartErr, EndDate, StartDate);
        if not _CleanCashSetup.Get(POSUnitNo) then
            Error(SetupMissingErr, _CleanCashSetup.TableCaption(), _CleanCashSetup.FieldCaption(Register), POSUnitNo);
        _CleanCashSetup.TestField("Organization ID");
        _CleanCashSetup.TestField("CleanCash Register No.");
        _CompanyInformation.Get();
        _CompanyInformation.TestField(Name);

        _PeriodStart := CreateDateTime(StartDate, 0T);
        _PeriodEnd := CreateDateTime(EndDate, 235959.999T);
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
        FileName := StrSubstNo(FileNameFormatLbl, Format(StartDate, 0, 9), Format(EndDate, 0, 9));
        TempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
        Document.WriteTo(OStream);
        TempBlob.CreateInStream(IStream, TextEncoding::UTF8);

        DownloadFromStream(IStream, ExportFileTitleTxt, '', XmlFileFilterTxt, FileName);
    end;
    #endregion Cash Register Journal Export Management

    #region Journal Events
    local procedure CollectJournalEvents(var TempJournalEvent: Record "NPR SE CC Journal Event" temporary)
    begin
        CollectReceipts(TempJournalEvent);
        CollectWorkshiftReports(TempJournalEvent);
        CollectLogins(TempJournalEvent);
        CollectParkedArticles(TempJournalEvent);
    end;

    local procedure CollectReceipts(var TempJournalEvent: Record "NPR SE CC Journal Event" temporary)
    begin
        CollectReceiptRequests(TempJournalEvent, false);
        CollectReceiptRequests(TempJournalEvent, true);
    end;

    local procedure CollectReceiptRequests(var TempJournalEvent: Record "NPR SE CC Journal Event" temporary; ReceiptCopies: Boolean)
    var
        CleanCashTransRequest: Record "NPR CleanCash Trans. Request";
        EventType: Enum "NPR SE CC Journal Event Type";
    begin
        CleanCashTransRequest.SetLoadFields("Entry No.", "POS Entry No.", "Request Type", "Receipt Type", "Receipt DateTime", "Request Datetime");
        CleanCashTransRequest.SetRange("POS Unit No.", _CleanCashSetup.Register);
        CleanCashTransRequest.SetRange("Request Send Status", CleanCashTransRequest."Request Send Status"::COMPLETE);
        CleanCashTransRequest.SetFilter("Request Type", '%1|%2', CleanCashTransRequest."Request Type"::RegisterSalesReceipt, CleanCashTransRequest."Request Type"::RegisterReturnReceipt);
        // Receipt DateTime is the POS entry's time for every receipt type, so a copy is dated by its Request Datetime
        if ReceiptCopies then begin
            CleanCashTransRequest.SetRange("Receipt Type", CleanCashTransRequest."Receipt Type"::kopia);
            CleanCashTransRequest.SetRange("Request Datetime", _PeriodStart, _PeriodEnd);
        end else begin
            CleanCashTransRequest.SetFilter("Receipt Type", '<>%1', CleanCashTransRequest."Receipt Type"::kopia);
            CleanCashTransRequest.SetRange("Receipt DateTime", _PeriodStart, _PeriodEnd);
        end;
        if not CleanCashTransRequest.FindSet() then
            exit;

        repeat
            if TryGetReceiptEventType(CleanCashTransRequest, EventType) then
                AddJournalEvent(TempJournalEvent, EventType, GetReceiptTime(CleanCashTransRequest), CleanCashTransRequest."Entry No.", 0, GetSalespersonCode(CleanCashTransRequest."POS Entry No."));
        until CleanCashTransRequest.Next() = 0;
    end;

    local procedure TryGetReceiptEventType(CleanCashTransRequest: Record "NPR CleanCash Trans. Request"; var EventType: Enum "NPR SE CC Journal Event Type"): Boolean
    begin
        case CleanCashTransRequest."Receipt Type" of
            CleanCashTransRequest."Receipt Type"::normal:
                if CleanCashTransRequest."Request Type" = CleanCashTransRequest."Request Type"::RegisterReturnReceipt then
                    EventType := EventType::ReturnReceipt
                else
                    EventType := EventType::SalesReceipt;
            CleanCashTransRequest."Receipt Type"::kopia:
                EventType := EventType::ReceiptCopy;
            CleanCashTransRequest."Receipt Type"::ovning:
                EventType := EventType::TrainingReceipt;
            else
                exit(false);
        end;
        exit(true);
    end;

    local procedure CollectWorkshiftReports(var TempJournalEvent: Record "NPR SE CC Journal Event" temporary)
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        EventType: Enum "NPR SE CC Journal Event Type";
    begin
        POSWorkshiftCheckpoint.SetLoadFields("Entry No.", Type, "Created At", "Salesperson Code");
        POSWorkshiftCheckpoint.SetRange("POS Unit No.", _CleanCashSetup.Register);
        POSWorkshiftCheckpoint.SetFilter(Type, '%1|%2', POSWorkshiftCheckpoint.Type::XREPORT, POSWorkshiftCheckpoint.Type::ZREPORT);
        POSWorkshiftCheckpoint.SetRange("Created At", _PeriodStart, _PeriodEnd);
        // Only a confirmed balancing links the checkpoint to a POS entry. This skips cancelled End of Day
        // checkpoints and the placeholder Z report created when a POS unit is started for the first time.
        POSWorkshiftCheckpoint.SetFilter("POS Entry No.", '<>%1', 0);
        if not POSWorkshiftCheckpoint.FindSet() then
            exit;

        repeat
            if POSWorkshiftCheckpoint.Type = POSWorkshiftCheckpoint.Type::ZREPORT then
                EventType := EventType::ZReport
            else
                EventType := EventType::XReport;
            AddJournalEvent(TempJournalEvent, EventType, POSWorkshiftCheckpoint."Created At", POSWorkshiftCheckpoint."Entry No.", 0, POSWorkshiftCheckpoint."Salesperson Code");
        until POSWorkshiftCheckpoint.Next() = 0;
    end;

    local procedure CollectLogins(var TempJournalEvent: Record "NPR SE CC Journal Event" temporary)
    var
        POSAuditLog: Record "NPR POS Audit Log";
        EventType: Enum "NPR SE CC Journal Event Type";
    begin
        POSAuditLog.SetLoadFields("Entry No.", "Action Type", "Log Timestamp", "Active Salesperson Code");
        POSAuditLog.SetRange("Active POS Unit No.", _CleanCashSetup.Register);
        POSAuditLog.SetFilter("Action Type", '%1|%2', POSAuditLog."Action Type"::SIGN_IN, POSAuditLog."Action Type"::SIGN_OUT);
        POSAuditLog.SetRange("Log Timestamp", _PeriodStart, _PeriodEnd);
        if not POSAuditLog.FindSet() then
            exit;

        repeat
            if POSAuditLog."Action Type" = POSAuditLog."Action Type"::SIGN_IN then
                EventType := EventType::Login
            else
                EventType := EventType::Logout;
            AddJournalEvent(TempJournalEvent, EventType, POSAuditLog."Log Timestamp", POSAuditLog."Entry No.", 0, POSAuditLog."Active Salesperson Code");
        until POSAuditLog.Next() = 0;
    end;

    local procedure CollectParkedArticles(var TempJournalEvent: Record "NPR SE CC Journal Event" temporary)
    var
        POSSavedSaleEntry: Record "NPR POS Saved Sale Entry";
        POSSavedSaleLine: Record "NPR POS Saved Sale Line";
    begin
        // Only sales that are still parked when the journal is exported. A parked sale is deleted when it is resumed,
        // so parking events need a permanent source to be complete (see COM-1504).
        POSSavedSaleEntry.SetLoadFields("Entry No.", "Created at", "Salesperson Code");
        POSSavedSaleEntry.SetRange("Register No.", _CleanCashSetup.Register);
        POSSavedSaleEntry.SetRange("Created at", _PeriodStart, _PeriodEnd);
        if not POSSavedSaleEntry.FindSet() then
            exit;

        POSSavedSaleLine.SetLoadFields("Quote Entry No.", "Line No.");
        POSSavedSaleLine.SetRange("Line Type", POSSavedSaleLine."Line Type"::Item);
        repeat
            POSSavedSaleLine.SetRange("Quote Entry No.", POSSavedSaleEntry."Entry No.");
            if POSSavedSaleLine.FindSet() then
                repeat
                    AddJournalEvent(TempJournalEvent, Enum::"NPR SE CC Journal Event Type"::ParkArticle, POSSavedSaleEntry."Created at", POSSavedSaleLine."Quote Entry No.", POSSavedSaleLine."Line No.", POSSavedSaleEntry."Salesperson Code");
                until POSSavedSaleLine.Next() = 0;
        until POSSavedSaleEntry.Next() = 0;
    end;

    local procedure AddJournalEvent(var TempJournalEvent: Record "NPR SE CC Journal Event" temporary; EventType: Enum "NPR SE CC Journal Event Type"; RegistrationTime: DateTime; SourceEntryNo: BigInteger; SourceLineNo: Integer; UserCode: Code[50])
    begin
        _LastJournalEventEntryNo += 1;
        TempJournalEvent.Init();
        TempJournalEvent."Entry No." := _LastJournalEventEntryNo;
        TempJournalEvent."Event Type" := EventType;
        TempJournalEvent."Registration Time" := RegistrationTime;
        TempJournalEvent."Source Entry No." := SourceEntryNo;
        TempJournalEvent."Source Line No." := SourceLineNo;
        TempJournalEvent."User Code" := UserCode;
        TempJournalEvent.Insert();
    end;
    #endregion Journal Events

    #region Cash Register Journal Export XML Structure
    local procedure AppendHeader(var RootElement: XmlElement)
    var
        CashRegisterSystemElement: XmlElement;
        CashRegisterSystemListElement: XmlElement;
        CompanyElement: XmlElement;
        PeriodElement: XmlElement;
        SelectedCashRegistersElement: XmlElement;
    begin
        AddOptionalText(RootElement, 'InloggadAnvandareVidExportAvDataFranJournalminnet', UserId());
        AddText(RootElement, 'BeteckningPaDetKassaregisterSomExportAvDataFranJournalminnetSkerIfran', _CleanCashSetup.Register);
        AddDateTime(RootElement, 'TidpunktForNarExportAvDataFranJournalminnetSker', CurrentDateTime());

        PeriodElement := NewElement('ValdPeriodForExportAvDataFranJournalminne');
        AddDateTime(PeriodElement, 'ValdStarttidpunktForExportAvDataFranJournalminnet', _PeriodStart);
        AddDateTime(PeriodElement, 'ValdSluttidpunktForExportAvDataFranJournalminnet', _PeriodEnd);
        RootElement.Add(PeriodElement);

        SelectedCashRegistersElement := NewElement('BeteckningPaValdaKassaregisterForExportAvDataFranJournalminnenLISTA');
        AddText(SelectedCashRegistersElement, 'BeteckningPaValtKassaregisterForExportAvDataFranJournalminnet', _CleanCashSetup.Register);
        RootElement.Add(SelectedCashRegistersElement);

        CompanyElement := NewElement('InformationOmForetaget');
        AddText(CompanyElement, 'OrganisationsnummerEllerPersonnummer', GetOrganizationNo());
        AddText(CompanyElement, 'ForetagetsNamn', _CompanyInformation.Name);
        AddText(CompanyElement, 'DenAdressDarForsaljningSker', GetSalesAddress(GetPOSStoreCode()));
        RootElement.Add(CompanyElement);

        CashRegisterSystemElement := NewElement('Kassaregistersystemet');
        AppendCashRegisterIdentification(CashRegisterSystemElement);
        AddText(CashRegisterSystemElement, 'Kassabeteckning', _CleanCashSetup.Register);
        AddText(CashRegisterSystemElement, 'TillverkningsnummerForKontrollenheten', _ControlUnitId);
        CashRegisterSystemListElement := NewElement('KassaregistersystemLISTA');
        CashRegisterSystemListElement.Add(CashRegisterSystemElement);
        RootElement.Add(CashRegisterSystemListElement);
    end;

    local procedure AppendCashRegisterIdentification(var ParentElement: XmlElement)
    var
        ModuleInfo: ModuleInfo;
    begin
        // Serial number, model and version of the cash register, used both in Kassaregistersystemet and on Z reports
        NavApp.GetCurrentModuleInfo(ModuleInfo);
        AddText(ParentElement, 'TillverkningsnummerForKassaregistret', _CleanCashSetup."CleanCash Register No.");
        AddText(ParentElement, 'ModellbeteckningForKassaregistret', ModuleInfo.Name());
        AddText(ParentElement, 'ModellEllerProgramForKassaregistret', ModuleInfo.Name());
        AddText(ParentElement, 'VersionsnummerForKassaregistret', Format(ModuleInfo.AppVersion()));
    end;

    local procedure AppendRegistrations(var RootElement: XmlElement; var TempJournalEvent: Record "NPR SE CC Journal Event" temporary)
    var
        EventElement: XmlElement;
        RegistrationListElement: XmlElement;
    begin
        RegistrationListElement := NewElement('RegistreringLISTA');
        TempJournalEvent.SetCurrentKey("Registration Time", "Entry No.");
        TempJournalEvent.FindSet();
        repeat
            EventElement := NewElement('Handelse');
            AddOptionalText(EventElement, 'InloggadAnvandare', TempJournalEvent."User Code");
            AddText(EventElement, 'Kassabeteckning', _CleanCashSetup.Register);
            AddDateTime(EventElement, 'Registreringstidpunkt', TempJournalEvent."Registration Time");
            case TempJournalEvent."Event Type" of
                TempJournalEvent."Event Type"::SalesReceipt,
                TempJournalEvent."Event Type"::ReturnReceipt,
                TempJournalEvent."Event Type"::ReceiptCopy,
                TempJournalEvent."Event Type"::TrainingReceipt:
                    AppendReceipt(EventElement, TempJournalEvent);
                TempJournalEvent."Event Type"::XReport,
                TempJournalEvent."Event Type"::ZReport:
                    AppendWorkshiftReport(EventElement, TempJournalEvent);
                TempJournalEvent."Event Type"::Login:
                    AddText(EventElement, 'InloggningIKassaregister', 'JA');
                TempJournalEvent."Event Type"::Logout:
                    AddText(EventElement, 'UtloggningUrKassaregister', 'JA');
                TempJournalEvent."Event Type"::ParkArticle:
                    AppendParkedArticle(EventElement, TempJournalEvent);
            end;
            RegistrationListElement.Add(EventElement);
        until TempJournalEvent.Next() = 0;
        RootElement.Add(RegistrationListElement);
    end;

    local procedure AppendReceipt(var EventElement: XmlElement; JournalEvent: Record "NPR SE CC Journal Event")
    var
        CleanCashTransRequest: Record "NPR CleanCash Trans. Request";
        OriginalReceipt: Record "NPR CleanCash Trans. Request";
        POSEntry: Record "NPR POS Entry";
        VATAmount: Decimal;
        VATAmountPerRate: Dictionary of [Decimal, Decimal];
        ReceiptElement: XmlElement;
    begin
        CleanCashTransRequest.Get(JournalEvent."Source Entry No.");
        POSEntry.SetLoadFields("Entry No.", "POS Store Code");
        POSEntry.Get(CleanCashTransRequest."POS Entry No.");
        VATAmount := CalcReceiptVAT(CleanCashTransRequest, VATAmountPerRate);

        case JournalEvent."Event Type" of
            JournalEvent."Event Type"::SalesReceipt:
                ReceiptElement := NewElement('Kassakvitto');
            JournalEvent."Event Type"::ReturnReceipt:
                ReceiptElement := NewElement('Returkvitto');
            JournalEvent."Event Type"::ReceiptCopy:
                begin
                    ReceiptElement := NewElement('KopiaAvKassakvitto');
                    GetOriginalReceipt(CleanCashTransRequest, OriginalReceipt);
                end;
            JournalEvent."Event Type"::TrainingReceipt:
                ReceiptElement := NewElement('Ovningskvitto');
        end;

        AddText(ReceiptElement, 'ForetagetsNamn', _CompanyInformation.Name);
        AddText(ReceiptElement, 'OrganisationsnummerEllerPersonnummer', GetOrganizationNo());
        AddText(ReceiptElement, 'DenAdressDarForsaljningSker', GetSalesAddress(POSEntry."POS Store Code"));
        case JournalEvent."Event Type" of
            JournalEvent."Event Type"::SalesReceipt:
                begin
                    AddDateTime(ReceiptElement, 'DatumOchKlockslagNarKvittoFramstalls', CleanCashTransRequest."Receipt DateTime");
                    AddText(ReceiptElement, 'LopnummerForKassakvitto', CleanCashTransRequest."Receipt Id");
                end;
            JournalEvent."Event Type"::ReturnReceipt:
                begin
                    AddDateTime(ReceiptElement, 'DatumOchKlockslagNarReturkvittoFramstalls', CleanCashTransRequest."Receipt DateTime");
                    AddText(ReceiptElement, 'LopnummerForKassakvitto', CleanCashTransRequest."Receipt Id");
                end;
            JournalEvent."Event Type"::ReceiptCopy:
                begin
                    AddDateTime(ReceiptElement, 'DatumOchKlockslagNarKvittoFramstalls', GetReceiptTime(CleanCashTransRequest));
                    AddDateTime(ReceiptElement, 'DatumOchKlockslagNarOriginalkvittoFramstalldes', OriginalReceipt."Receipt DateTime");
                    AddText(ReceiptElement, 'LopnummerForKvittokopia', CleanCashTransRequest."Receipt Id");
                    AddText(ReceiptElement, 'LopnummerPaOriginalkvitto', OriginalReceipt."Receipt Id");
                end;
            JournalEvent."Event Type"::TrainingReceipt:
                begin
                    AddDateTime(ReceiptElement, 'DatumOchKlockslagNarKvittoFramstalls', CleanCashTransRequest."Receipt DateTime");
                    AddOptionalText(ReceiptElement, 'LopnummerForOvningskvitto', CleanCashTransRequest."Receipt Id");
                end;
        end;
        AddText(ReceiptElement, 'Kassabeteckning', _CleanCashSetup.Register);

        AppendSoldArticles(ReceiptElement, CleanCashTransRequest);
        AddDecimal(ReceiptElement, 'TotaltForsaljningsbeloppISvenskaKronor', CleanCashTransRequest."Receipt Total");
        AddDecimal(ReceiptElement, 'MervardesskattPaForsaljningsbeloppet', VATAmount);
        AppendReceiptPayments(ReceiptElement, CleanCashTransRequest);
        AppendReceiptVATTotals(ReceiptElement, VATAmountPerRate);
        if JournalEvent."Event Type" = JournalEvent."Event Type"::ReceiptCopy then
            AddOptionalText(ReceiptElement, 'KontrollkodPaKopiaAvKassakvitto', CleanCashTransRequest."CleanCash Code");
        AddText(ReceiptElement, 'LopnummerForZDagrapportPaKvitto', GetZReportNo(POSEntry."Entry No."));

        // CleanCash is a control unit (kontrollenhet), so receipts carry its serial number and control code,
        // never the control system alternatives (TillverkningsnummerForKontrollsystemet, Avstamningskod).
        AddText(ReceiptElement, 'TillverkningsnummerForKontrollenheten', GetReceiptControlUnitId(CleanCashTransRequest));
        case JournalEvent."Event Type" of
            JournalEvent."Event Type"::SalesReceipt,
            JournalEvent."Event Type"::ReturnReceipt:
                AddText(ReceiptElement, 'Kontrollkod', CleanCashTransRequest."CleanCash Code");
            JournalEvent."Event Type"::ReceiptCopy:
                AddText(ReceiptElement, 'KontrollkodForKvittotSomKopianAvser', OriginalReceipt."CleanCash Code");
        end;

        EventElement.Add(ReceiptElement);
    end;

    local procedure AppendSoldArticles(var ReceiptElement: XmlElement; CleanCashTransRequest: Record "NPR CleanCash Trans. Request")
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        ArticleElement: XmlElement;
        ArticleListElement: XmlElement;
        DiscountElement: XmlElement;
        DiscountListElement: XmlElement;
    begin
        ArticleListElement := NewElement('SaldaArtiklarLISTA');
        FilterReceiptSalesLines(POSEntrySalesLine, CleanCashTransRequest);
        POSEntrySalesLine.SetLoadFields(Type, "No.", Description, Quantity, "Unit of Measure Code", "Unit Price", "Amount Incl. VAT", "Amount Excl. VAT", "Line Discount Amount Incl. VAT", "VAT %", "POS Sale Line Created At");
        if POSEntrySalesLine.FindSet() then
            repeat
                ArticleElement := NewElement('SaldArtikel');
                AddText(ArticleElement, 'TypAvArtikel', GetSoldArticleType(POSEntrySalesLine));
                AddOptionalText(ArticleElement, 'Artikelnummer', POSEntrySalesLine."No.");
                AddText(ArticleElement, 'Artikelnamn', GetArticleName(POSEntrySalesLine.Description, POSEntrySalesLine."No."));
                AddDecimal(ArticleElement, 'AntalAvSaldArtikel', POSEntrySalesLine.Quantity);
                AddOptionalText(ArticleElement, 'EnhetForViktLangdTidEllerVolym', POSEntrySalesLine."Unit of Measure Code");
                AddDecimal(ArticleElement, 'PrisPerEnhet', POSEntrySalesLine."Unit Price");
                AddDecimal(ArticleElement, 'PrisPaSaldArtikel', POSEntrySalesLine."Amount Incl. VAT");
                if POSEntrySalesLine."Line Discount Amount Incl. VAT" <> 0 then begin
                    DiscountElement := NewElement('RabattPaSaldArtikel');
                    AddDecimal(DiscountElement, 'RabattensBelopp', POSEntrySalesLine."Line Discount Amount Incl. VAT");
                    DiscountListElement := NewElement('RabatterPaSaldArtikelLISTA');
                    DiscountListElement.Add(DiscountElement);
                    ArticleElement.Add(DiscountListElement);
                end;
                AddDecimal(ArticleElement, 'MervardesskattesatsForSaldArtikel', POSEntrySalesLine."VAT %");
                AddDecimal(ArticleElement, 'MervardesskattPaSaldArtikel', POSEntrySalesLine."Amount Incl. VAT" - POSEntrySalesLine."Amount Excl. VAT");
                if POSEntrySalesLine."POS Sale Line Created At" <> 0DT then
                    AddDateTime(ArticleElement, 'ArtikelnsRegistreringstidpunkt', POSEntrySalesLine."POS Sale Line Created At")
                else
                    AddDateTime(ArticleElement, 'ArtikelnsRegistreringstidpunkt', CleanCashTransRequest."Receipt DateTime");
                ArticleListElement.Add(ArticleElement);
            until POSEntrySalesLine.Next() = 0;
        ReceiptElement.Add(ArticleListElement);
    end;

    local procedure AppendReceiptPayments(var ReceiptElement: XmlElement; CleanCashTransRequest: Record "NPR CleanCash Trans. Request")
    var
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        PaidAmount: Decimal;
        IsExchange: Boolean;
        PaymentListElement: XmlElement;
    begin
        // An exchange is one POS entry registered with CleanCash as a sales and a return receipt. Its payment lines
        // belong to only one of them. Whatever the payments do not cover is settled against the other receipt.
        PaymentListElement := NewElement('TotalaForsaljningssummorPerBetalningsmedelLISTA');
        IsExchange := HasOppositeReceiptLines(CleanCashTransRequest);
        if (not IsExchange) or ReceiptOwnsPayments(CleanCashTransRequest) then begin
            POSEntryPaymentLine.SetLoadFields("POS Payment Method Code", "Amount (LCY)");
            POSEntryPaymentLine.SetRange("POS Entry No.", CleanCashTransRequest."POS Entry No.");
            if POSEntryPaymentLine.FindSet() then
                repeat
                    AppendPayment(PaymentListElement, POSEntryPaymentLine."POS Payment Method Code", POSEntryPaymentLine."Amount (LCY)");
                    PaidAmount += POSEntryPaymentLine."Amount (LCY)";
                until POSEntryPaymentLine.Next() = 0;
        end;

        // The schema requires at least one payment, so a receipt without payment lines is settled by offset as well
        if (IsExchange and (CleanCashTransRequest."Receipt Total" <> PaidAmount)) or (not HasChildElements(PaymentListElement)) then
            AppendPayment(PaymentListElement, OffsetPaymentMethod(), CleanCashTransRequest."Receipt Total" - PaidAmount);
        ReceiptElement.Add(PaymentListElement);
    end;

    local procedure AppendPayment(var PaymentListElement: XmlElement; PaymentMethod: Text; Amount: Decimal)
    var
        PaymentElement: XmlElement;
    begin
        PaymentElement := NewElement('TotalForsaljningssummaPerBetalningsmedel');
        AddText(PaymentElement, 'Betalningsmedel', PaymentMethod);
        AddDecimal(PaymentElement, 'ForsaljningssummaPerBetalningsmedel', Amount);
        PaymentListElement.Add(PaymentElement);
    end;

    local procedure CalcReceiptVAT(CleanCashTransRequest: Record "NPR CleanCash Trans. Request"; var VATAmountPerRate: Dictionary of [Decimal, Decimal]) VATAmount: Decimal
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        LineVATAmount: Decimal;
    begin
        // VAT of the receipt's own lines. For an exchange, the POS entry's tax is the net of both receipts.
        FilterReceiptSalesLines(POSEntrySalesLine, CleanCashTransRequest);
        POSEntrySalesLine.SetLoadFields("VAT %", "Amount Incl. VAT", "Amount Excl. VAT");
        if POSEntrySalesLine.FindSet() then
            repeat
                LineVATAmount := POSEntrySalesLine."Amount Incl. VAT" - POSEntrySalesLine."Amount Excl. VAT";
                VATAmount += LineVATAmount;
                if VATAmountPerRate.ContainsKey(POSEntrySalesLine."VAT %") then
                    VATAmountPerRate.Set(POSEntrySalesLine."VAT %", VATAmountPerRate.Get(POSEntrySalesLine."VAT %") + LineVATAmount)
                else
                    VATAmountPerRate.Add(POSEntrySalesLine."VAT %", LineVATAmount);
            until POSEntrySalesLine.Next() = 0;
    end;

    local procedure AppendReceiptVATTotals(var ReceiptElement: XmlElement; VATAmountPerRate: Dictionary of [Decimal, Decimal])
    var
        VATRate: Decimal;
        VATRateListElement: XmlElement;
    begin
        VATRateListElement := NewElement('MervardesskattPaOlikaSkattesatserLISTA');
        foreach VATRate in VATAmountPerRate.Keys() do
            AppendVATRate(VATRateListElement, VATRate, VATAmountPerRate.Get(VATRate));
        ReceiptElement.Add(VATRateListElement);
    end;

    local procedure AppendVATRate(var VATRateListElement: XmlElement; VATRate: Decimal; VATAmount: Decimal)
    var
        VATRateElement: XmlElement;
    begin
        VATRateElement := NewElement('MervardesskattPerSkattesats');
        AddDecimal(VATRateElement, 'Mervardesskattesats', VATRate);
        AddDecimal(VATRateElement, 'TotaltMervardesskattebeloppPerSkattesats', VATAmount);
        VATRateListElement.Add(VATRateElement);
    end;

    local procedure AppendWorkshiftReport(var EventElement: XmlElement; JournalEvent: Record "NPR SE CC Journal Event")
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        UnfinishedSalesAmount: Decimal;
        UnfinishedSalesCount: Integer;
        IsZReport: Boolean;
        ReportElement: XmlElement;
    begin
        POSWorkshiftCheckpoint.Get(JournalEvent."Source Entry No.");
        IsZReport := JournalEvent."Event Type" = JournalEvent."Event Type"::ZReport;
        if IsZReport then
            ReportElement := NewElement('ZDagrapport')
        else
            ReportElement := NewElement('XDagrapport');

        AddText(ReportElement, 'ForetagetsNamn', _CompanyInformation.Name);
        AddText(ReportElement, 'OrganisationsnummerEllerPersonnummer', GetOrganizationNo());
        AddDateTime(ReportElement, 'DatumOchKlockslagNarRapportFramstalls', POSWorkshiftCheckpoint."Created At");
        if IsZReport then
            // The printed Z report shows the checkpoint entry no. as its report number
            AddText(ReportElement, 'LopnummerForZDagrapport', Format(POSWorkshiftCheckpoint."Entry No.", 0, 9));
        AddText(ReportElement, 'Kassabeteckning', _CleanCashSetup.Register);
        if IsZReport then
            AppendCashRegisterIdentification(ReportElement);
        AddDecimal(ReportElement, 'TotalForsaljningssumma', POSWorkshiftCheckpoint."Direct Item Sales (LCY)" - Abs(POSWorkshiftCheckpoint."Direct Item Returns (LCY)"));
        AppendReportVATTotals(ReportElement, POSWorkshiftCheckpoint."Entry No.");
        AddDecimal(ReportElement, 'VaxelkassansBeloppISvenskaKronor', POSWorkshiftCheckpoint."Turnover (LCY)");
        AddInteger(ReportElement, 'AntalKassakvitton', POSWorkshiftCheckpoint."Receipts Count");
        AddInteger(ReportElement, 'AntalKassaladoppningar', POSWorkshiftCheckpoint."Cash Drawer Open Count");
        AddInteger(ReportElement, 'AntalKvittokopior', POSWorkshiftCheckpoint."Receipt Copies Count");
        AddDecimal(ReportElement, 'TotaltBeloppPaKvittokopior', POSWorkshiftCheckpoint."Receipt Copies Sales (LCY)");
        AddInteger(ReportElement, 'AntalKvittonSomTagitsFramIOvningslage', GetTrainingReceiptCount(POSWorkshiftCheckpoint));
        AppendReportPayments(ReportElement, POSWorkshiftCheckpoint."Entry No.");
        AddInteger(ReportElement, 'AntalReturer', POSWorkshiftCheckpoint."Direct Item Returns Line Count");
        AddDecimal(ReportElement, 'ReturernasBelopp', POSWorkshiftCheckpoint."Direct Item Returns (LCY)");
        AddDecimal(ReportElement, 'RabatternasBelopp', POSWorkshiftCheckpoint."Total Discount (LCY)");
        // NP Retail does not track other registrations that reduce the day's sales separately from returns and
        // discounts, which are reported in their own elements above.
        AddInteger(ReportElement, 'AntalOvrigaRegistreringarSomMinskatDagensForsaljningsbelopp', 0);
        AddDecimal(ReportElement, 'TotaltBeloppAvOvrigaRegistreringarSomMinskatDagensForsaljningsbelopp', 0);
        CalcUnfinishedSales(POSWorkshiftCheckpoint, UnfinishedSalesCount, UnfinishedSalesAmount);
        AddInteger(ReportElement, 'AntalOavslutadeForsaljningar', UnfinishedSalesCount);
        AddDecimal(ReportElement, 'TotaltBeloppAvOavslutadeForsaljningar', UnfinishedSalesAmount);
        AddDecimal(ReportElement, 'GrandTotalForsaljning', POSWorkshiftCheckpoint."Direct Item Sales (LCY)");
        AddDecimal(ReportElement, 'GrandTotalRetur', POSWorkshiftCheckpoint."Direct Item Returns (LCY)");
        if IsZReport then
            AddDecimal(ReportElement, 'GrandTotalNetto', POSWorkshiftCheckpoint."Direct Item Sales (LCY)" - Abs(POSWorkshiftCheckpoint."Direct Item Returns (LCY)"))
        else
            AddDecimal(ReportElement, 'GrandTotalNetto', POSWorkshiftCheckpoint."Direct Item Net Sales (LCY)");

        EventElement.Add(ReportElement);
    end;

    local procedure AppendReportVATTotals(var ReportElement: XmlElement; WorkshiftCheckpointEntryNo: Integer)
    var
        POSWorkshTaxCheckp: Record "NPR POS Worksh. Tax Checkp.";
        VATRateListElement: XmlElement;
    begin
        VATRateListElement := NewElement('MervardesskattPaOlikaSkattesatserLISTA');
        POSWorkshTaxCheckp.SetLoadFields("Tax %", "Tax Amount");
        POSWorkshTaxCheckp.SetRange("Workshift Checkpoint Entry No.", WorkshiftCheckpointEntryNo);
        if POSWorkshTaxCheckp.FindSet() then
            repeat
                AppendVATRate(VATRateListElement, POSWorkshTaxCheckp."Tax %", POSWorkshTaxCheckp."Tax Amount");
            until POSWorkshTaxCheckp.Next() = 0
        else
            // The schema requires at least one rate. A report without taxed sales has no VAT.
            AppendVATRate(VATRateListElement, 0, 0);
        ReportElement.Add(VATRateListElement);
    end;

    local procedure AppendReportPayments(var ReportElement: XmlElement; WorkshiftCheckpointEntryNo: Integer)
    var
        POSPaymentBinCheckp: Record "NPR POS Payment Bin Checkp.";
        PaymentElement: XmlElement;
        PaymentListElement: XmlElement;
    begin
        PaymentListElement := NewElement('TotalaForsaljningssummorPerBetalningsmedelLISTA');
        POSPaymentBinCheckp.SetLoadFields("Payment Method No.", "Calculated Amount Incl. Float");
        POSPaymentBinCheckp.SetRange("Workshift Checkpoint Entry No.", WorkshiftCheckpointEntryNo);
        if POSPaymentBinCheckp.FindSet() then
            repeat
                PaymentElement := NewElement('TotalForsaljningssummaPerBetalningsmedel');
                AddText(PaymentElement, 'Betalningsmedel', POSPaymentBinCheckp."Payment Method No.");
                AddDecimal(PaymentElement, 'ForsaljningssummaPerBetalningsmedel', POSPaymentBinCheckp."Calculated Amount Incl. Float");
                PaymentListElement.Add(PaymentElement);
            until POSPaymentBinCheckp.Next() = 0;
        ReportElement.Add(PaymentListElement);
    end;

    local procedure AppendParkedArticle(var EventElement: XmlElement; JournalEvent: Record "NPR SE CC Journal Event")
    var
        POSSavedSaleEntry: Record "NPR POS Saved Sale Entry";
        POSSavedSaleLine: Record "NPR POS Saved Sale Line";
        ArticleElement: XmlElement;
        DiscountElement: XmlElement;
        DiscountListElement: XmlElement;
    begin
        POSSavedSaleLine.Get(JournalEvent."Source Entry No.", JournalEvent."Source Line No.");
        POSSavedSaleEntry.SetLoadFields("Sales Ticket No.");
        POSSavedSaleEntry.Get(JournalEvent."Source Entry No.");

        ArticleElement := NewElement('ParkeraRegistreradArtikel');
        AddText(ArticleElement, 'TypAvArtikel', GetArticleType(POSSavedSaleLine."No."));
        AddOptionalText(ArticleElement, 'Artikelnummer', POSSavedSaleLine."No.");
        AddText(ArticleElement, 'Artikelnamn', GetArticleName(POSSavedSaleLine.Description, POSSavedSaleLine."No."));
        AddDecimal(ArticleElement, 'AntalAvRegistreradArtikel', POSSavedSaleLine.Quantity);
        AddOptionalText(ArticleElement, 'EnhetForViktLangdTidEllerVolym', POSSavedSaleLine."Unit of Measure Code");
        AddDecimal(ArticleElement, 'PrisPerEnhet', POSSavedSaleLine."Unit Price");
        AddDecimal(ArticleElement, 'PrisPaRegistreradArtikel', POSSavedSaleLine."Amount Including VAT");
        if POSSavedSaleLine."Discount Amount" <> 0 then begin
            DiscountElement := NewElement('RabattPaRegistreradArtikel');
            AddDecimal(DiscountElement, 'RabattensBelopp', POSSavedSaleLine."Discount Amount");
            DiscountListElement := NewElement('RabatterPaRegistreradArtikelLISTA');
            DiscountListElement.Add(DiscountElement);
            ArticleElement.Add(DiscountListElement);
        end;
        AddDecimal(ArticleElement, 'MervardesskattesatsForRegistreradArtikel', GetParkedArticleVATRate(POSSavedSaleLine));
        AddDecimal(ArticleElement, 'MervardesskattPaRegistreradArtikel', POSSavedSaleLine."Amount Including VAT" - POSSavedSaleLine.Amount);
        AddOptionalText(ArticleElement, 'IdentitetsbeteckningPaParkering', POSSavedSaleEntry."Sales Ticket No.");

        EventElement.Add(ArticleElement);
    end;
    #endregion Cash Register Journal Export XML Structure

    #region Helper procedures
    local procedure InstansNamespace(): Text
    var
        InstansNamespaceTok: Label 'http://xmls.skatteverket.se/se/skatteverket/td/instans/utredningsstod/1.0', Locked = true;
    begin
        exit(InstansNamespaceTok);
    end;

    local procedure KomponentNamespace(): Text
    var
        KomponentNamespaceTok: Label 'http://xmls.skatteverket.se/se/skatteverket/td/komponent/utredningsstod/1.0', Locked = true;
    begin
        exit(KomponentNamespaceTok);
    end;

    local procedure NewElement(Name: Text): XmlElement
    begin
        exit(XmlElement.Create(Name, KomponentNamespace()));
    end;

    local procedure AddText(var ParentElement: XmlElement; Name: Text; Value: Text)
    var
        Element: XmlElement;
    begin
        // Text elements in the schema allow at most 72 characters
        Element := NewElement(Name);
        Element.Add(XmlText.Create(CopyStr(Value, 1, 72)));
        ParentElement.Add(Element);
    end;

    local procedure AddOptionalText(var ParentElement: XmlElement; Name: Text; Value: Text)
    begin
        if Value <> '' then
            AddText(ParentElement, Name, Value);
    end;

    local procedure AddDecimal(var ParentElement: XmlElement; Name: Text; Value: Decimal)
    begin
        // xs:decimal with at most two fraction digits
        AddText(ParentElement, Name, Format(Round(Value, 0.01), 0, 9));
    end;

    local procedure AddInteger(var ParentElement: XmlElement; Name: Text; Value: Integer)
    begin
        AddText(ParentElement, Name, Format(Value, 0, 9));
    end;

    local procedure AddDateTime(var ParentElement: XmlElement; Name: Text; Value: DateTime)
    begin
        // xs:dateTime restricted to exactly yyyy-MM-ddTHH:mm:ss, so no fractions or time zone
        AddText(ParentElement, Name, Format(Value, 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2><Filler Character,0>:<Minutes,2>:<Seconds,2>'));
    end;

    local procedure FilterReceiptSalesLines(var POSEntrySalesLine: Record "NPR POS Entry Sales Line"; CleanCashTransRequest: Record "NPR CleanCash Trans. Request")
    begin
        FilterReceiptSalesLines(POSEntrySalesLine, CleanCashTransRequest."POS Entry No.", IsReturnReceipt(CleanCashTransRequest));
    end;

    local procedure FilterReceiptSalesLines(var POSEntrySalesLine: Record "NPR POS Entry Sales Line"; POSEntryNo: Integer; ReturnLines: Boolean)
    begin
        // The line types CleanCash registers a receipt from, see "NPR CleanCash Receipt Msg."
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntryNo);
        POSEntrySalesLine.SetFilter(Type, '%1|%2|%3|%4', POSEntrySalesLine.Type::"G/L Account", POSEntrySalesLine.Type::Item, POSEntrySalesLine.Type::Rounding, POSEntrySalesLine.Type::Voucher);
        if ReturnLines then
            POSEntrySalesLine.SetFilter(Quantity, '<0')
        else
            POSEntrySalesLine.SetFilter(Quantity, '>0');
    end;

    local procedure IsReturnReceipt(CleanCashTransRequest: Record "NPR CleanCash Trans. Request"): Boolean
    begin
        exit(CleanCashTransRequest."Request Type" = CleanCashTransRequest."Request Type"::RegisterReturnReceipt);
    end;

    local procedure HasOppositeReceiptLines(CleanCashTransRequest: Record "NPR CleanCash Trans. Request"): Boolean
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        FilterReceiptSalesLines(POSEntrySalesLine, CleanCashTransRequest."POS Entry No.", not IsReturnReceipt(CleanCashTransRequest));
        exit(not POSEntrySalesLine.IsEmpty());
    end;

    local procedure ReceiptOwnsPayments(CleanCashTransRequest: Record "NPR CleanCash Trans. Request"): Boolean
    var
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
    begin
        // The payments belong to the receipt whose sign matches what the customer paid or got back in total
        POSEntryPaymentLine.SetRange("POS Entry No.", CleanCashTransRequest."POS Entry No.");
        POSEntryPaymentLine.CalcSums("Amount (LCY)");
        if POSEntryPaymentLine."Amount (LCY)" < 0 then
            exit(IsReturnReceipt(CleanCashTransRequest));
        exit(not IsReturnReceipt(CleanCashTransRequest));
    end;

    local procedure OffsetPaymentMethod(): Text
    var
        OffsetPaymentMethodTok: Label 'Kvittning', Locked = true, Comment = 'Swedish term used in the journal for an amount settled against the other receipt of an exchange';
    begin
        exit(OffsetPaymentMethodTok);
    end;

    local procedure HasChildElements(Element: XmlElement): Boolean
    begin
        exit(Element.GetChildElements().Count() > 0);
    end;

    local procedure GetReceiptTime(CleanCashTransRequest: Record "NPR CleanCash Trans. Request"): DateTime
    begin
        // CleanCash stores the POS entry's time as Receipt DateTime for every receipt type. A copy is made later.
        if (CleanCashTransRequest."Receipt Type" = CleanCashTransRequest."Receipt Type"::kopia) and (CleanCashTransRequest."Request Datetime" <> 0DT) then
            exit(CleanCashTransRequest."Request Datetime");
        exit(CleanCashTransRequest."Receipt DateTime");
    end;

    local procedure GetOriginalReceipt(CopyReceipt: Record "NPR CleanCash Trans. Request"; var OriginalReceipt: Record "NPR CleanCash Trans. Request")
    var
        OriginalMissingErr: Label 'The original receipt for receipt copy %1 was not found, so the copy cannot be exported.', Comment = '%1 = Receipt Id of the copy';
    begin
        OriginalReceipt.SetRange("POS Entry No.", CopyReceipt."POS Entry No.");
        OriginalReceipt.SetRange("Request Type", CopyReceipt."Request Type");
        OriginalReceipt.SetRange("Request Send Status", OriginalReceipt."Request Send Status"::COMPLETE);
        OriginalReceipt.SetRange("Receipt Type", OriginalReceipt."Receipt Type"::normal);
        if not OriginalReceipt.FindFirst() then
            Error(OriginalMissingErr, CopyReceipt."Receipt Id");
    end;

    local procedure GetZReportNo(POSEntryNo: Integer): Text
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
    begin
        // The Z report that closes the receipt's period is the first one registered after the receipt's POS entry
        POSWorkshiftCheckpoint.SetLoadFields("Entry No.");
        POSWorkshiftCheckpoint.SetRange("POS Unit No.", _CleanCashSetup.Register);
        POSWorkshiftCheckpoint.SetRange(Type, POSWorkshiftCheckpoint.Type::ZREPORT);
        POSWorkshiftCheckpoint.SetFilter("POS Entry No.", '>%1', POSEntryNo);
        if POSWorkshiftCheckpoint.FindFirst() then
            exit(Format(POSWorkshiftCheckpoint."Entry No.", 0, 9));
        // The period has not been closed with a Z report yet, so no Z report number exists
        exit('0');
    end;

    local procedure FindControlUnitId(): Text
    var
        CleanCashTransRequest: Record "NPR CleanCash Trans. Request";
        CleanCashTransResponse: Record "NPR CleanCash Trans. Response";
        POSUnit: Record "NPR POS Unit";
        NoControlUnitErr: Label 'No CleanCash control unit has answered a request from %1 %2, so the control unit serial number required in the journal is unknown.', Comment = '%1 = POS Unit table caption, %2 = POS Unit No.';
    begin
        // Receipts copy the unit id from their response. Identity and status requests keep it on the response only.
        CleanCashTransRequest.SetLoadFields("CleanCash Unit Id");
        CleanCashTransRequest.SetRange("POS Unit No.", _CleanCashSetup.Register);
        CleanCashTransRequest.SetRange("Request Send Status", CleanCashTransRequest."Request Send Status"::COMPLETE);
        CleanCashTransRequest.SetFilter("CleanCash Unit Id", '<>%1', '');
        if CleanCashTransRequest.FindLast() then
            exit(CleanCashTransRequest."CleanCash Unit Id");

        CleanCashTransRequest.SetRange("CleanCash Unit Id");
        CleanCashTransRequest.SetFilter("Request Type", '%1|%2', CleanCashTransRequest."Request Type"::IdentityRequest, CleanCashTransRequest."Request Type"::StatusRequest);
        CleanCashTransResponse.SetLoadFields("CleanCash Unit Id");
        CleanCashTransResponse.SetFilter("CleanCash Unit Id", '<>%1', '');
        CleanCashTransRequest.Ascending(false);
        if CleanCashTransRequest.FindSet() then
            repeat
                CleanCashTransResponse.SetRange("Request Entry No.", CleanCashTransRequest."Entry No.");
                if CleanCashTransResponse.FindLast() then
                    exit(CleanCashTransResponse."CleanCash Unit Id");
            until CleanCashTransRequest.Next() = 0;

        Error(NoControlUnitErr, POSUnit.TableCaption(), _CleanCashSetup.Register);
    end;

    local procedure GetReceiptControlUnitId(CleanCashTransRequest: Record "NPR CleanCash Trans. Request"): Text
    begin
        if CleanCashTransRequest."CleanCash Unit Id" <> '' then
            exit(CleanCashTransRequest."CleanCash Unit Id");
        exit(_ControlUnitId);
    end;

    local procedure GetOrganizationNo(): Text
    begin
        exit(DelChr(_CleanCashSetup."Organization ID", '=', '- '));
    end;

    local procedure GetPOSStoreCode(): Code[10]
    var
        POSUnit: Record "NPR POS Unit";
    begin
        POSUnit.SetLoadFields("POS Store Code");
        if POSUnit.Get(_CleanCashSetup.Register) then
            exit(POSUnit."POS Store Code");
    end;

    local procedure GetSalesAddress(POSStoreCode: Code[10]): Text
    var
        POSStore: Record "NPR POS Store";
    begin
        POSStore.SetLoadFields(Address);
        if POSStore.Get(POSStoreCode) then
            if POSStore.Address <> '' then
                exit(POSStore.Address);
        _CompanyInformation.TestField(Address);
        exit(_CompanyInformation.Address);
    end;

    local procedure GetSalespersonCode(POSEntryNo: Integer): Code[20]
    var
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.SetLoadFields("Salesperson Code");
        if POSEntry.Get(POSEntryNo) then
            exit(POSEntry."Salesperson Code");
    end;

    local procedure GetArticleType(ItemNo: Code[20]): Text
    var
        Item: Record Item;
    begin
        Item.SetLoadFields(Type);
        if Item.Get(ItemNo) then
            if Item.Type = Item.Type::Service then
                exit('TJANST');
        exit('VARA');
    end;

    local procedure GetSoldArticleType(POSEntrySalesLine: Record "NPR POS Entry Sales Line"): Text
    begin
        if POSEntrySalesLine.Type = POSEntrySalesLine.Type::Item then
            exit(GetArticleType(POSEntrySalesLine."No."));
        // G/L account, voucher and rounding lines are not goods. The schema only knows goods (VARA) and services (TJANST).
        exit('TJANST');
    end;

    local procedure GetArticleName(Description: Text; ItemNo: Code[20]): Text
    begin
        if Description <> '' then
            exit(Description);
        exit(ItemNo);
    end;

    local procedure GetParkedArticleVATRate(POSSavedSaleLine: Record "NPR POS Saved Sale Line"): Decimal
    var
        Item: Record Item;
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSStore: Record "NPR POS Store";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        Item.SetLoadFields("VAT Prod. Posting Group");
        if Item.Get(POSSavedSaleLine."No.") then
            if POSStore.Get(GetPOSStoreCode()) then
                if POSPostingProfile.Get(POSStore."POS Posting Profile") then
                    if VATPostingSetup.Get(POSPostingProfile."VAT Bus. Posting Group", Item."VAT Prod. Posting Group") then
                        exit(VATPostingSetup."VAT %");

        // Without a VAT posting setup the rate is derived from the parked line's amounts
        if POSSavedSaleLine.Amount = 0 then
            exit(0);
        exit(Round((POSSavedSaleLine."Amount Including VAT" - POSSavedSaleLine.Amount) / POSSavedSaleLine.Amount * 100, 0.01));
    end;

    local procedure GetTrainingReceiptCount(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"): Integer
    var
        CleanCashTransRequest: Record "NPR CleanCash Trans. Request";
    begin
        CleanCashTransRequest.SetRange("POS Unit No.", _CleanCashSetup.Register);
        CleanCashTransRequest.SetRange("Request Send Status", CleanCashTransRequest."Request Send Status"::COMPLETE);
        CleanCashTransRequest.SetRange("Receipt Type", CleanCashTransRequest."Receipt Type"::ovning);
        CleanCashTransRequest.SetFilter("Request Type", '%1|%2', CleanCashTransRequest."Request Type"::RegisterSalesReceipt, CleanCashTransRequest."Request Type"::RegisterReturnReceipt);
        CleanCashTransRequest.SetRange("Receipt DateTime", GetReportPeriodStart(POSWorkshiftCheckpoint), POSWorkshiftCheckpoint."Created At");
        exit(CleanCashTransRequest.Count());
    end;

    local procedure CalcUnfinishedSales(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; var UnfinishedSalesCount: Integer; var UnfinishedSalesAmount: Decimal)
    var
        POSSavedSaleEntry: Record "NPR POS Saved Sale Entry";
    begin
        // Parked sales in the report's period that are still parked when the journal is exported. A parked sale is
        // deleted when it is resumed, so these figures can change after the report was printed (see COM-1504).
        POSSavedSaleEntry.SetRange("Register No.", POSWorkshiftCheckpoint."POS Unit No.");
        POSSavedSaleEntry.SetRange("Created at", GetReportPeriodStart(POSWorkshiftCheckpoint), POSWorkshiftCheckpoint."Created At");
        UnfinishedSalesCount := POSSavedSaleEntry.Count();
        UnfinishedSalesAmount := 0;
        POSSavedSaleEntry.SetAutoCalcFields("Amount Including VAT");
        if POSSavedSaleEntry.FindSet() then
            repeat
                // The schema requires a non-negative total. A parked return counts with the amount it is parked for.
                UnfinishedSalesAmount += Abs(POSSavedSaleEntry."Amount Including VAT");
            until POSSavedSaleEntry.Next() = 0;
    end;

    local procedure GetReportPeriodStart(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"): DateTime
    var
        PreviousZReport: Record "NPR POS Workshift Checkpoint";
        SECCReportStatMgt: Codeunit "NPR SE CC Report Stat. Mgt.";
    begin
        // An X or Z report covers the time since the previous Z report, as on the printed report
        if SECCReportStatMgt.FindPreviousZReport(PreviousZReport, POSWorkshiftCheckpoint."POS Unit No.", POSWorkshiftCheckpoint."Entry No.") then
            exit(PreviousZReport."Created At");
        exit(0DT);
    end;
    #endregion Helper procedures
}
