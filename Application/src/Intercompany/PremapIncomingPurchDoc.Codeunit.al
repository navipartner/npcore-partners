codeunit 6060075 "NPR Pre-map Incoming Purch Doc"
{
    Access = Internal;
    TableNo = "Data Exch.";

    trigger OnRun()
    var
        BuyFromVendorNo: Code[20];
        PayToVendorNo: Code[20];
        ParentRecNo: Integer;
        CurrRecNo: Integer;
    begin
        ParentRecNo := 0;
        FindDistinctRecordNos(TempIntegerHeaderRecords, Rec."Entry No.", DATABASE::"Purchase Header", ParentRecNo);
        if not TempIntegerHeaderRecords.FindSet() then
            exit;

        repeat
            CurrRecNo := TempIntegerHeaderRecords.Number;

            ValidateCompanyInfo(Rec."Entry No.", CurrRecNo);
            ValidateCurrency(Rec."Entry No.", CurrRecNo);
            SetDocumentType(Rec."Entry No.", ParentRecNo, CurrRecNo);

            CorrectHeaderData(Rec."Entry No.", CurrRecNo);
            BuyFromVendorNo := FindBuyFromVendor(Rec."Entry No.", CurrRecNo);
            PayToVendorNo := FindPayToVendor(Rec."Entry No.", CurrRecNo);
            FindInvoiceToApplyTo(Rec."Entry No.", CurrRecNo);

            PersistHeaderData(Rec."Entry No.", CurrRecNo, BuyFromVendorNo, PayToVendorNo);

            ProcessLines(Rec."Entry No.", CurrRecNo, BuyFromVendorNo);
        until TempIntegerHeaderRecords.Next() = 0;
    end;

    var
        TempIntegerHeaderRecords: Record "Integer" temporary;
        TempIntegerLineRecords: Record "Integer" temporary;
        InvalidCompanyInfoGLNErr: Label 'The customer''s GLN %1 on the incoming document does not match the GLN in the Company Information window.', Comment = '%1 = GLN (13 digit number)';
        InvalidCompanyInfoVATRegNoErr: Label 'The customer''s VAT registration number %1 on the incoming document does not match the VAT Registration No. in the Company Information window.', Comment = '%1 VAT Registration Number (format could be AB###### or ###### or AB##-##-###)';
        CurrencyCodeMissingErr: Label 'The currency code is missing on the incoming document.';
        CurrencyCodeDifferentErr: Label 'Currency code %1 must not be different from currency code %2 on the incoming document.', Comment = '%1 currency code (e.g. GBP), %2 the document currency code (e.g. DKK)';
        ItemCurrencyCodeDifferentErr: Label 'Currency code %1 on invoice line %2 must not be different from currency code %3 on the incoming document.', Comment = '%1 Invoice line currency code (e.g. GBP), %2 invoice line no. (e.g. 2), %3 document currency code (e.g. DKK)';
        BuyFromVendorNotFoundErr: Label 'Cannot find buy-from vendor ''%1'' based on the vendor''s GLN %2 or VAT registration number %3 on the incoming document. Make sure that a card for the vendor exists with the corresponding GLN or VAT Registration No.', Comment = '%1 Vendor name (e.g. London Postmaster), %2 Vendor''s GLN (13 digit number), %3 Vendor''s VAT Registration Number';
        PayToVendorNotFoundErr: Label 'Cannot find pay-to vendor ''%1'' based on the vendor''s GLN %2 or VAT registration number %3 on the incoming document. Make sure that a card for the vendor exists with the corresponding GLN or VAT Registration No.', Comment = '%1 Vendor name (e.g. London Postmaster), %2 Vendor''s GLN (13 digit number), %3 Vendor''s VAT Registration Number';
        ItemNotFoundErr: Label 'Cannot find item ''%1'' based on the vendor %2 item number %3 or GTIN %4 on the incoming document. Make sure that a card for the item exists with the corresponding item reference or GTIN.', Comment = '%1 Vendor item name (e.g. Bicycle - may be another language),%2 Vendor''''s number,%3 Vendor''''s item number, %4 item bar code (GTIN)';
        ItemNotFoundByGTINErr: Label 'Cannot find item ''%1'' based on GTIN %2 on the incoming document. Make sure that a card for the item exists with the corresponding GTIN.', Comment = '%1 Vendor item name (e.g. Bicycle - may be another language),%2 item bar code (GTIN)';
        ItemNotFoundByVendorItemNoErr: Label 'Cannot find item ''%1'' based on the vendor %2 item number %3 on the incoming document. Make sure that a card for the item exists with the corresponding item reference.', Comment = '%1 Vendor item name (e.g. Bicycle - may be another language),%2 Vendor''''s number,%3 Vendor''''s item number';
        UOMNotFoundErr: Label 'Cannot find a unit of measure with International Standard Code %1. Make sure that a unit of measure code exists with International Standard Code %1.', Comment = '%1 International Standard Code for Unit of Measure (e.g. H12)';
        UOMMissingErr: Label 'Cannot find a unit of measure code on the incoming document line %1.', Comment = '%1 document line number (e.g. 2)';
        MissingCompanyInfoSetupErr: Label 'You must fill either GLN or VAT Registration No. in the Company Information window.';
        VendorNotFoundByNameAndAddressErr: Label 'Cannot find vendor based on the vendor''s name ''%1'' and street name ''%2'' on the incoming document. Make sure that a card for the vendor exists with the corresponding name.';
        InvalidCompanyInfoNameErr: Label 'The customer''s name ''%1'' on the incoming document does not match the Name in the Company Information window.', Comment = '%1 = customer name';
        InvalidCompanyInfoAddressErr: Label 'The customer''s address ''%1'' on the incoming document does not match the Address in the Company Information window.', Comment = '%1 = customer address, street name';
        FieldMustHaveAValueErr: Label 'You must specify a value for field ''%1''.', Comment = '%1 - field caption';
        DocumentTypeUnknownErr: Label 'You must make a new entry in the %1 of the %2 window, and enter ''%3'' or ''%4'' in the %5 field. Then, you must map it to the %6 field in the %7 table.', Comment = '%1 - Column Definitions (page caption),%2 - Data Exchange Definition (page caption),%3 - invoice (option caption),%4 - credit memo (option caption),%5 - Constant (field name),%6 - Document Type (field caption),%7 - Purchase Header (table caption)';
        YouMustFirstPostTheRelatedInvoiceErr: Label 'The incoming document references invoice %1 from the vendor. You must post related purchase invoice %2 before you create a new purchase document from this incoming document.', Comment = '%1 - vendor invoice no.,%2 posted purchase invoice no.';
        UnableToFindRelatedInvoiceErr: Label 'The incoming document references invoice %1 from the vendor, but no purchase invoice exists for %1.', Comment = '%1 - vendor invoice no.';
        UnableToFindTotalAmountErr: Label 'The incoming document has no total amount excluding VAT.';
        UnableToFindAppropriateAccountErr: Label 'Cannot find an appropriate G/L account for the line with description ''%1''. Choose the Map Text to Account button, and then map the core part of ''%1'' to the relevant G/L account.', Comment = '%1 - arbitrary text';

    local procedure ValidateCompanyInfo(EntryNo: Integer; RecordNo: Integer)
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        CompanyInformation: Record "Company Information";
        DataExch: Record "Data Exch.";
        IncomingDocument: Record "Incoming Document";
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        GLN: Text;
        VatRegNo: Text;
        PlaceHolder1Lbl: Label '<>%1', Locked = true;
        PlaceHolder2Lbl: Label '<>%1&<>%2', Locked = true;
    begin
        DataExch.Get(EntryNo);
        IncomingDocument.Get(DataExch."Incoming Entry No.");
        if IncomingDocument.GetGeneratedFromOCRAttachment(IncomingDocumentAttachment) then
            exit;

        CompanyInformation.Get();
        if IntermediateDataImport.FindEntry(EntryNo, DATABASE::"Company Information", CompanyInformation.FieldNo("VAT Registration No."), 0, RecordNo) then
            VatRegNo := IntermediateDataImport.Value;

        IntermediateDataImport.SetRange("Field ID", CompanyInformation.FieldNo(GLN));
        if IntermediateDataImport.FindFirst() then
            GLN := IntermediateDataImport.Value;

        if (GLN = '') and (VatRegNo = '') then begin
            ValidateCompanyInfoByNameAndAddress(EntryNo, RecordNo);
            exit;
        end;

        if (CompanyInformation.GLN = '') and (CompanyInformation."VAT Registration No." = '') then
            LogErrorMessage(EntryNo, CompanyInformation, CompanyInformation.FieldNo(GLN), MissingCompanyInfoSetupErr);

        if CompanyInformation.GLN <> '' then begin
            IntermediateDataImport.SetFilter(Value, StrSubstNo(PlaceHolder2Lbl, CompanyInformation.GLN, ''''''));
            if IntermediateDataImport.FindLast() then
                LogErrorMessage(EntryNo, CompanyInformation, CompanyInformation.FieldNo(GLN),
                  StrSubstNo(InvalidCompanyInfoGLNErr, GLN));
        end;

        if CompanyInformation."VAT Registration No." <> '' then begin
            IntermediateDataImport.SetRange("Field ID", CompanyInformation.FieldNo("VAT Registration No."));
            IntermediateDataImport.SetFilter(Value, StrSubstNo(PlaceHolder1Lbl, ''''''));

            if IntermediateDataImport.FindLast() then
                if (ExtractVatRegNo(IntermediateDataImport.Value, '') <> ExtractVatRegNo(CompanyInformation."VAT Registration No.", ''))
                then
                    LogErrorMessage(EntryNo, CompanyInformation, CompanyInformation.FieldNo("VAT Registration No."),
                      StrSubstNo(InvalidCompanyInfoVATRegNoErr, VatRegNo));
        end;
    end;

    local procedure ValidateCompanyInfoByNameAndAddress(EntryNo: Integer; RecordNo: Integer)
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        CompanyInfo: Record "Company Information";
        RecordMatchMgt: Codeunit "Record Match Mgt.";
        ImportedAddress: Text;
        ImportedName: Text;
        CompanyName: Text;
        CompanyAddr: Text;
        NameNearness: Integer;
        AddressNearness: Integer;
    begin
        CompanyInfo.Get();
        CompanyName := CompanyInfo.Name;
        CompanyAddr := CompanyInfo.Address;
        if IntermediateDataImport.FindEntry(EntryNo, DATABASE::"Company Information", CompanyInfo.FieldNo(Name), 0, RecordNo) then
            ImportedName := IntermediateDataImport.Value;

        NameNearness := RecordMatchMgt.CalculateStringNearness(CompanyName, ImportedName, MatchThreshold(), NormalizingFactor());

        IntermediateDataImport.SetRange("Field ID", CompanyInfo.FieldNo(Address));
        if IntermediateDataImport.FindFirst() then
            ImportedAddress := IntermediateDataImport.Value;

        AddressNearness := RecordMatchMgt.CalculateStringNearness(CompanyAddr, ImportedAddress, MatchThreshold(), NormalizingFactor());

        if (ImportedName <> '') and (NameNearness < RequiredNearness()) then
            LogErrorMessage(EntryNo, CompanyInfo, CompanyInfo.FieldNo(Name), StrSubstNo(InvalidCompanyInfoNameErr, ImportedName));

        if (ImportedAddress <> '') and (AddressNearness < RequiredNearness()) then
            LogErrorMessage(EntryNo, CompanyInfo, CompanyInfo.FieldNo(Address), StrSubstNo(InvalidCompanyInfoAddressErr, ImportedAddress));
    end;

    local procedure ValidateCurrency(EntryNo: Integer; RecordNo: Integer)
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GLSetup: Record "General Ledger Setup";
        DocumentCurrency: Text;
        IsLCY: Boolean;
    begin
        GLSetup.Get();
        if GLSetup."LCY Code" = '' then
            LogErrorMessage(EntryNo, GLSetup, GLSetup.FieldNo("LCY Code"),
              StrSubstNo(FieldMustHaveAValueErr, GLSetup.FieldCaption("LCY Code")));

        DocumentCurrency := IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::"Purchase Header", PurchaseHeader.FieldNo("Currency Code"), 0, RecordNo);
        if DocumentCurrency = '' then begin
            LogSimpleErrorMessage(EntryNo, CurrencyCodeMissingErr);
            exit;
        end;

        IsLCY := DocumentCurrency = GLSetup."LCY Code";
        if IsLCY then begin
            IntermediateDataImport.Value := '';
            IntermediateDataImport.Modify();
        end;

        IntermediateDataImport.SetRange("Field ID", PurchaseHeader.FieldNo("Tax Area Code"));
        IntermediateDataImport.SetFilter(Value, '<>%1', DocumentCurrency);
        if IntermediateDataImport.FindFirst() then
            LogSimpleErrorMessage(EntryNo, StrSubstNo(CurrencyCodeDifferentErr, IntermediateDataImport.Value, DocumentCurrency));

        IntermediateDataImport.SetRange(Value);
        IntermediateDataImport.DeleteAll();

        IntermediateDataImport.SetRange("Table ID", DATABASE::"Purchase Line");
        IntermediateDataImport.SetRange("Field ID", PurchaseLine.FieldNo("Currency Code"));
        IntermediateDataImport.SetRange("Record No.");
        IntermediateDataImport.SetRange("Parent Record No.", RecordNo);
        IntermediateDataImport.SetFilter(Value, '<>%1', DocumentCurrency);
        if IntermediateDataImport.FindFirst() then
            LogSimpleErrorMessage(EntryNo, StrSubstNo(ItemCurrencyCodeDifferentErr, IntermediateDataImport.Value, IntermediateDataImport."Record No.", DocumentCurrency));

        IntermediateDataImport.SetRange(Value);
        IntermediateDataImport.DeleteAll();
    end;

    local procedure ProcessLines(EntryNo: Integer; HeaderRecordNo: Integer; VendorNo: Code[20])
    var
        DataExch: Record "Data Exch.";
        IncomingDocument: Record "Incoming Document";
    begin
        DataExch.Get(EntryNo);
        IncomingDocument.Get(DataExch."Incoming Entry No.");
        if IncomingDocument."Document Type" = IncomingDocument."Document Type"::Journal then
            exit;

        FindDistinctRecordNos(TempIntegerLineRecords, EntryNo, DATABASE::"Purchase Line", HeaderRecordNo);
        if not TempIntegerLineRecords.FindSet() then begin
            InsertLineForTotalDocumentAmount(EntryNo, HeaderRecordNo, 1, VendorNo);
            exit;
        end;

        repeat
            ProcessLine(EntryNo, HeaderRecordNo, TempIntegerLineRecords.Number, VendorNo);
        until TempIntegerLineRecords.Next() = 0;
    end;

    local procedure CorrectHeaderData(EntryNo: Integer; RecordNo: Integer)
    var
        Vendor: Record Vendor;
        VendorBankAccount: Record "Vendor Bank Account";
        IncomingDocument: Record "Incoming Document";
        DataExch: Record "Data Exch.";
        PurchaseHeader: Record "Purchase Header";
        GLEntry: Record "G/L Entry";
    begin
        DataExch.Get(EntryNo);
        IncomingDocument.Get(DataExch."Incoming Entry No.");
        if IncomingDocument."OCR Data Corrected" then begin
            CorrectHeaderField(EntryNo, DATABASE::"Purchase Header", PurchaseHeader.FieldNo("Buy-from Vendor Name"), RecordNo,
              IncomingDocument."Vendor Name");
            CorrectHeaderField(EntryNo, DATABASE::Vendor, Vendor.FieldNo("VAT Registration No."), RecordNo,
              IncomingDocument."Vendor VAT Registration No.");
            CorrectHeaderField(EntryNo, DATABASE::"Vendor Bank Account", VendorBankAccount.FieldNo(IBAN), RecordNo,
              IncomingDocument."Vendor IBAN");
            CorrectHeaderField(EntryNo, DATABASE::"Vendor Bank Account", VendorBankAccount.FieldNo("Bank Account No."), RecordNo,
              IncomingDocument."Vendor Bank Account No.");
            CorrectHeaderField(EntryNo, DATABASE::"Vendor Bank Account", VendorBankAccount.FieldNo("Bank Branch No."), RecordNo,
              IncomingDocument."Vendor Bank Branch No.");
            CorrectHeaderField(EntryNo, DATABASE::Vendor, Vendor.FieldNo("Phone No."), RecordNo,
              IncomingDocument."Vendor Phone No.");
            CorrectHeaderField(EntryNo, DATABASE::"Purchase Header", PurchaseHeader.FieldNo("Vendor Invoice No."), RecordNo,
              IncomingDocument."Vendor Invoice No.");
            CorrectHeaderField(EntryNo, DATABASE::"Purchase Header", PurchaseHeader.FieldNo("Document Date"), RecordNo,
              IncomingDocument."Document Date");
            CorrectHeaderField(EntryNo, DATABASE::"Purchase Header", PurchaseHeader.FieldNo("Due Date"), RecordNo,
              IncomingDocument."Due Date");
            CorrectCurrencyCode(EntryNo, DATABASE::"Purchase Header", PurchaseHeader.FieldNo("Currency Code"), RecordNo,
              IncomingDocument."Currency Code");
            CorrectHeaderField(EntryNo, DATABASE::"Purchase Header", PurchaseHeader.FieldNo(Amount), RecordNo,
              IncomingDocument."Amount Excl. VAT");
            CorrectHeaderField(EntryNo, DATABASE::"Purchase Header", PurchaseHeader.FieldNo("Amount Including VAT"), RecordNo,
              IncomingDocument."Amount Incl. VAT");
            CorrectHeaderField(EntryNo, DATABASE::"G/L Entry", GLEntry.FieldNo("VAT Amount"), RecordNo,
              IncomingDocument."VAT Amount");
            CorrectHeaderField(EntryNo, DATABASE::"Purchase Header", PurchaseHeader.FieldNo("Vendor Order No."), RecordNo,
              IncomingDocument."Order No.");
        end;
    end;

    local procedure CorrectHeaderField(EntryNo: Integer; TableID: Integer; FieldID: Integer; RecordNo: Integer; IncomingDocumentValue: Variant)
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        ExistingValue: Text;
        CorrectedValue: Text[250];
    begin
        ExistingValue := IntermediateDataImport.GetEntryValue(EntryNo, TableID, FieldID, 0, RecordNo);
        CorrectedValue := CopyStr(Format(IncomingDocumentValue, 0, 9), 1, MaxStrLen(CorrectedValue));
        if CorrectedValue <> ExistingValue then
            IntermediateDataImport.InsertOrUpdateEntry(EntryNo, TableID, FieldID, 0, RecordNo, CorrectedValue);
    end;

    local procedure CorrectCurrencyCode(EntryNo: Integer; TableID: Integer; FieldID: Integer; RecordNo: Integer; IncomingDocumentValue: Variant)
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        GeneralLedgerSetup: Record "General Ledger Setup";
        ExistingValue: Text;
        CorrectedValue: Text[250];
    begin
        ExistingValue := IntermediateDataImport.GetEntryValue(EntryNo, TableID, FieldID, 0, RecordNo);
        CorrectedValue := CopyStr(Format(IncomingDocumentValue, 0, 9), 1, MaxStrLen(CorrectedValue));
        GeneralLedgerSetup.Get();
        if (CorrectedValue <> ExistingValue) and ((CorrectedValue <> GeneralLedgerSetup."LCY Code") or (ExistingValue <> '')) then
            IntermediateDataImport.InsertOrUpdateEntry(EntryNo, TableID, FieldID, 0, RecordNo, CorrectedValue);
    end;

    local procedure PersistHeaderData(EntryNo: Integer; RecordNo: Integer; BuyFromVendorNo: Code[20]; PayToVendorNo: Code[20])
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        DataExch: Record "Data Exch.";
        IncomingDocument: Record "Incoming Document";
        PurchaseHeader: Record "Purchase Header";
        VendorBankAccount: Record "Vendor Bank Account";
        Vendor: Record Vendor;
        GLEntry: Record "G/L Entry";
        GeneralLedgerSetup: Record "General Ledger Setup";
        AmountInclVAT: Decimal;
        AmountExclVAT: Decimal;
        VATAmount: Decimal;
        TextValue: Text[250];
        Date: Date;
    begin
        DataExch.Get(EntryNo);
        IncomingDocument.Get(DataExch."Incoming Entry No.");

        if PayToVendorNo <> '' then
            IncomingDocument.Validate("Vendor No.", PayToVendorNo)
        else
            IncomingDocument.Validate("Vendor No.", BuyFromVendorNo);

        Evaluate(
          TextValue, IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::"Purchase Header", PurchaseHeader.FieldNo("Buy-from Vendor Name"), 0, RecordNo));
        IncomingDocument.Validate("Vendor Name", CopyStr(TextValue, 1, MaxStrLen(IncomingDocument."Vendor Name")));

        TextValue := IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::"Purchase Header", PurchaseHeader.FieldNo("Amount Including VAT"), 0, RecordNo);
        if TextValue <> '' then
            Evaluate(AmountInclVAT, TextValue, 9);
        IncomingDocument.Validate("Amount Incl. VAT", AmountInclVAT);

        TextValue := IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::"Purchase Header", PurchaseHeader.FieldNo(Amount), 0, RecordNo);
        if TextValue <> '' then
            Evaluate(AmountExclVAT, TextValue, 9);
        IncomingDocument.Validate("Amount Excl. VAT", AmountExclVAT);

        TextValue := IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::"G/L Entry", GLEntry.FieldNo("VAT Amount"), 0, RecordNo);
        if TextValue <> '' then
            Evaluate(VATAmount, TextValue, 9);
        IncomingDocument.Validate("VAT Amount", VATAmount);

        if IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::"Purchase Header", PurchaseHeader.FieldNo("Document Type"), 0, RecordNo) =
           Format(PurchaseHeader."Document Type"::Invoice, 0, 9)
        then
            Evaluate(TextValue, IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::"Purchase Header", PurchaseHeader.FieldNo("Vendor Invoice No."), 0, RecordNo))
        else
            Evaluate(
              TextValue, IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::"Purchase Header", PurchaseHeader.FieldNo("Vendor Cr. Memo No."), 0, RecordNo));

        IncomingDocument.Validate("Vendor Invoice No.", CopyStr(TextValue, 1, MaxStrLen(IncomingDocument."Vendor Invoice No.")));

        Evaluate(TextValue, IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::"Purchase Header", PurchaseHeader.FieldNo("Vendor Order No."), 0, RecordNo));
        IncomingDocument.Validate("Order No.", CopyStr(TextValue, 1, MaxStrLen(IncomingDocument."Order No.")));

        Evaluate(Date, IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::"Purchase Header", PurchaseHeader.FieldNo("Document Date"), 0, RecordNo), 9);
        IncomingDocument.Validate("Document Date", Date);

        Evaluate(Date, IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::"Purchase Header", PurchaseHeader.FieldNo("Due Date"), 0, RecordNo), 9);
        IncomingDocument.Validate("Due Date", Date);

        Evaluate(TextValue, IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::"Purchase Header", PurchaseHeader.FieldNo("Currency Code"), 0, RecordNo));
        GeneralLedgerSetup.Get();
        if (TextValue <> '') or (IncomingDocument."Currency Code" <> GeneralLedgerSetup."LCY Code") then
            IncomingDocument."Currency Code" := CopyStr(TextValue, 1, MaxStrLen(IncomingDocument."Currency Code"));

        Evaluate(TextValue, IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::Vendor, Vendor.FieldNo("VAT Registration No."), 0, RecordNo));
        IncomingDocument.Validate("Vendor VAT Registration No.",
          CopyStr(TextValue, 1, MaxStrLen(IncomingDocument."Vendor VAT Registration No.")));

        Evaluate(TextValue, IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::"Vendor Bank Account", VendorBankAccount.FieldNo(IBAN), 0, RecordNo));
        IncomingDocument.Validate("Vendor IBAN", CopyStr(TextValue, 1, MaxStrLen(IncomingDocument."Vendor IBAN")));

        Evaluate(
          TextValue, IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::"Vendor Bank Account", VendorBankAccount.FieldNo("Bank Branch No."), 0, RecordNo));
        IncomingDocument.Validate("Vendor Bank Branch No.", CopyStr(TextValue, 1, MaxStrLen(IncomingDocument."Vendor Bank Branch No.")));

        Evaluate(
          TextValue, IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::Vendor, Vendor.FieldNo("Phone No."), 0, RecordNo));
        IncomingDocument.Validate("Vendor Phone No.", CopyStr(TextValue, 1, MaxStrLen(IncomingDocument."Vendor Phone No.")));

        Evaluate(
          TextValue, IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::"Vendor Bank Account", VendorBankAccount.FieldNo("Bank Account No."), 0, RecordNo));
        IncomingDocument.Validate("Vendor Bank Account No.",
          CopyStr(TextValue, 1, MaxStrLen(IncomingDocument."Vendor Bank Account No.")));

        IncomingDocument.Modify();
    end;

    local procedure FindBuyFromVendor(EntryNo: Integer; RecordNo: Integer): Code[20]
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        PurchaseHeader: Record "Purchase Header";
        Vendor: Record Vendor;
        EmptyVendor: Record Vendor;
        IncomingDocument: Record "Incoming Document";
        DataExch: Record "Data Exch.";
        GLN: Text;
        BuyFromName: Text;
        BuyFromAddress: Text;
        BuyFromPhoneNo: Text;
        VatRegNo: Text;
        VendorNo: Code[20];
        PlaceHolder1Lbl: Label '*%1', Locked = true;
    begin
        BuyFromPhoneNo := IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::Vendor, Vendor.FieldNo("Phone No."), 0, RecordNo);

        if IntermediateDataImport.FindEntry(EntryNo, DATABASE::"Purchase Header", PurchaseHeader.FieldNo("Buy-from Vendor Name"), 0, RecordNo) then
            BuyFromName := IntermediateDataImport.Value;

        IntermediateDataImport.SetRange("Field ID", PurchaseHeader.FieldNo("Buy-from Address"));
        if IntermediateDataImport.FindFirst() then
            BuyFromAddress := IntermediateDataImport.Value;

        IntermediateDataImport.SetRange("Field ID", PurchaseHeader.FieldNo("Buy-from Vendor No."));
        if IntermediateDataImport.FindFirst() then
            if IntermediateDataImport.Value <> '' then begin
                GLN := IntermediateDataImport.Value;
                Vendor.SetRange(GLN, IntermediateDataImport.Value);
                if Vendor.FindFirst() then begin
                    IntermediateDataImport.InsertOrUpdateEntry(EntryNo, DATABASE::"Purchase Header",
                      PurchaseHeader.FieldNo("Buy-from Vendor No."), 0, RecordNo, Vendor."No.");
                    exit(Vendor."No.");
                end;
            end;

        Vendor.Reset();
        VatRegNo := '';

        IntermediateDataImport.SetRange("Table ID", DATABASE::Vendor);
        IntermediateDataImport.SetRange("Field ID", Vendor.FieldNo("VAT Registration No."));

        if IntermediateDataImport.FindFirst() then begin
            if (IntermediateDataImport.Value = '') and (GLN = '') then begin
                VendorNo := FindVendorByBankAccount(EntryNo, RecordNo, PurchaseHeader.FieldNo("Buy-from Vendor No."));
                if VendorNo <> '' then
                    exit(VendorNo);
                VendorNo := FindVendorByPhoneNo(EntryNo, RecordNo, PurchaseHeader.FieldNo("Buy-from Vendor No."), BuyFromPhoneNo);
                if VendorNo <> '' then
                    exit(VendorNo);
                exit(FindVendorByNameAndAddress(EntryNo, RecordNo, BuyFromName, BuyFromAddress,
                    PurchaseHeader.FieldNo("Buy-from Vendor No.")));
            end;
            VatRegNo := IntermediateDataImport.Value;
            if IntermediateDataImport.Value <> '' then begin
                Vendor.SetFilter("VAT Registration No.",
                  StrSubstNo(PlaceHolder1Lbl, CopyStr(IntermediateDataImport.Value, StrLen(IntermediateDataImport.Value))));
                if Vendor.FindSet() then
                    repeat
                        if ExtractVatRegNo(Vendor."VAT Registration No.", Vendor."Country/Region Code") =
                           ExtractVatRegNo(IntermediateDataImport.Value, Vendor."Country/Region Code")
                        then begin
                            IntermediateDataImport.InsertOrUpdateEntry(EntryNo, DATABASE::"Purchase Header",
                              PurchaseHeader.FieldNo("Buy-from Vendor No."), 0, RecordNo, Vendor."No.");

                            exit(Vendor."No.");
                        end;
                    until Vendor.Next() = 0;
            end;
        end;

        if (VatRegNo = '') and (GLN = '') then begin
            VendorNo := FindVendorByBankAccount(EntryNo, RecordNo, PurchaseHeader.FieldNo("Buy-from Vendor No."));
            if VendorNo <> '' then
                exit(VendorNo);
            VendorNo := FindVendorByPhoneNo(EntryNo, RecordNo, PurchaseHeader.FieldNo("Buy-from Vendor No."), BuyFromPhoneNo);
            if VendorNo <> '' then
                exit(VendorNo);
            exit(FindVendorByNameAndAddress(EntryNo, RecordNo, BuyFromName, BuyFromAddress,
                PurchaseHeader.FieldNo("Buy-from Vendor No.")));
        end;

        DataExch.Get(EntryNo);
        IncomingDocument.Get(DataExch."Incoming Entry No.");
        if IncomingDocument."Document Type" <> IncomingDocument."Document Type"::Journal then
            LogErrorMessage(EntryNo, EmptyVendor, EmptyVendor.FieldNo(Name),
              StrSubstNo(BuyFromVendorNotFoundErr, BuyFromName, GLN, VatRegNo));
        exit('');
    end;

    local procedure FindPayToVendor(EntryNo: Integer; RecordNo: Integer): Code[20]
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        PurchaseHeader: Record "Purchase Header";
        Vendor: Record Vendor;
        EmptyVendor: Record Vendor;
        IncomingDocument: Record "Incoming Document";
        DataExch: Record "Data Exch.";
        GLN: Text;
        VatRegNo: Text;
        PayToName: Text;
        PayToAddress: Text;
        PlaceHolder1Lbl: Label '*%1', Locked = true;
    begin
        if IntermediateDataImport.FindEntry(EntryNo, DATABASE::"Purchase Header", PurchaseHeader.FieldNo("Pay-to Name"), 0, RecordNo) then
            PayToName := IntermediateDataImport.Value;

        IntermediateDataImport.SetRange("Field ID", PurchaseHeader.FieldNo("Pay-to Address"));
        if IntermediateDataImport.FindFirst() then
            PayToAddress := IntermediateDataImport.Value;

        IntermediateDataImport.SetRange("Field ID", PurchaseHeader.FieldNo("VAT Registration No."));
        if IntermediateDataImport.FindFirst() then
            VatRegNo := IntermediateDataImport.Value;

        IntermediateDataImport.SetRange("Field ID", PurchaseHeader.FieldNo("Pay-to Vendor No."));
        if IntermediateDataImport.FindFirst() then
            GLN := IntermediateDataImport.Value;

        if (VatRegNo = '') and (GLN = '') then begin
            if PayToName <> '' then
                exit(FindVendorByNameAndAddress(EntryNo, RecordNo, PayToName, PayToAddress, PurchaseHeader.FieldNo("Pay-to Vendor No.")));
            exit;
        end;

        if GLN <> '' then begin
            Vendor.SetRange(GLN, GLN);
            if Vendor.FindFirst() then begin
                IntermediateDataImport.InsertOrUpdateEntry(EntryNo, DATABASE::"Purchase Header",
                  PurchaseHeader.FieldNo("Pay-to Vendor No."), 0, RecordNo, Vendor."No.");

                exit(Vendor."No.");
            end;
        end;

        Vendor.Reset();

        Vendor.SetFilter("VAT Registration No.", StrSubstNo(PlaceHolder1Lbl, CopyStr(VatRegNo, StrLen(VatRegNo))));
        if Vendor.FindSet() then
            repeat
                if ExtractVatRegNo(Vendor."VAT Registration No.", Vendor."Country/Region Code") =
                   ExtractVatRegNo(VatRegNo, Vendor."Country/Region Code")
                then begin
                    IntermediateDataImport.InsertOrUpdateEntry(EntryNo, DATABASE::"Purchase Header",
                      PurchaseHeader.FieldNo("Pay-to Vendor No."), 0, RecordNo, Vendor."No.");

                    exit(Vendor."No.");
                end;
            until Vendor.Next() = 0;

        DataExch.Get(EntryNo);
        IncomingDocument.Get(DataExch."Incoming Entry No.");
        if IncomingDocument."Document Type" <> IncomingDocument."Document Type"::Journal then
            LogErrorMessage(EntryNo, EmptyVendor, EmptyVendor.FieldNo(Name),
              StrSubstNo(PayToVendorNotFoundErr, PayToName, GLN, VatRegNo));
        exit('');
    end;

    local procedure FindVendorByNameAndAddress(EntryNo: Integer; RecordNo: Integer; VendorName: Text; VendorAddress: Text; FieldID: Integer): Code[20]
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        Vendor: Record Vendor;
        EmptyVendor: Record Vendor;
        IncomingDocument: Record "Incoming Document";
        DataExch: Record "Data Exch.";
        RecordMatchMgt: Codeunit "Record Match Mgt.";
        NameNearness: Integer;
        AddressNearness: Integer;
    begin
        if Vendor.FindSet() then
            repeat
                NameNearness := RecordMatchMgt.CalculateStringNearness(VendorName, Vendor.Name, MatchThreshold(), NormalizingFactor());
                if VendorAddress = '' then
                    AddressNearness := RequiredNearness()
                else
                    AddressNearness := RecordMatchMgt.CalculateStringNearness(VendorAddress, Vendor.Address, MatchThreshold(), NormalizingFactor());
                if (NameNearness >= RequiredNearness()) and (AddressNearness >= RequiredNearness()) then begin
                    IntermediateDataImport.InsertOrUpdateEntry(EntryNo, DATABASE::"Purchase Header", FieldID, 0, RecordNo, Vendor."No.");
                    exit(Vendor."No.");
                end;
            until Vendor.Next() = 0;

        DataExch.Get(EntryNo);
        IncomingDocument.Get(DataExch."Incoming Entry No.");
        if IncomingDocument."Document Type" <> IncomingDocument."Document Type"::Journal then
            LogErrorMessage(EntryNo, EmptyVendor, EmptyVendor.FieldNo(Name),
              StrSubstNo(VendorNotFoundByNameAndAddressErr, VendorName, VendorAddress));
        exit('');
    end;

    local procedure FindVendorByBankAccount(EntryNo: Integer; RecordNo: Integer; FieldID: Integer): Code[20]
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        VendorBankAccount: Record "Vendor Bank Account";
        VendorNo: Code[20];
        VendorIBAN: Code[50];
        VendorBankBranchNo: Text[20];
        VendorBankAccountNo: Text[30];
    begin
        if IntermediateDataImport.FindEntry(EntryNo, DATABASE::"Vendor Bank Account", VendorBankAccount.FieldNo(IBAN), 0, RecordNo) then
            VendorIBAN := CopyStr(IntermediateDataImport.Value, 1, MaxStrLen(VendorIBAN));

        IntermediateDataImport.SetRange("Field ID", VendorBankAccount.FieldNo("Bank Branch No."));
        if IntermediateDataImport.FindFirst() then
            VendorBankBranchNo := CopyStr(IntermediateDataImport.Value, 1, MaxStrLen(VendorBankBranchNo));

        IntermediateDataImport.SetRange("Field ID", VendorBankAccount.FieldNo("Bank Account No."));
        if IntermediateDataImport.FindFirst() then
            VendorBankAccountNo := CopyStr(IntermediateDataImport.Value, 1, MaxStrLen(VendorBankAccountNo));

        if VendorIBAN <> '' then begin
            VendorBankAccount.SetRange(IBAN, VendorIBAN);
            if VendorBankAccount.FindFirst() then
                VendorNo := VendorBankAccount."Vendor No.";
        end;

        if (VendorNo = '') and (VendorBankBranchNo <> '') and (VendorBankAccountNo <> '') then begin
            VendorBankAccount.Reset();
            VendorBankAccount.SetRange("Bank Branch No.", VendorBankBranchNo);
            VendorBankAccount.SetRange("Bank Account No.", VendorBankAccountNo);
            if VendorBankAccount.FindFirst() then
                VendorNo := VendorBankAccount."Vendor No.";
        end;

        if VendorNo <> '' then begin
            IntermediateDataImport.InsertOrUpdateEntry(EntryNo, DATABASE::"Purchase Header", FieldID, 0, RecordNo, VendorNo);
            exit(VendorNo);
        end;

        exit('');
    end;

    local procedure FindVendorByPhoneNo(EntryNo: Integer; RecordNo: Integer; FieldID: Integer; PhoneNo: Text): Code[20]
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        Vendor: Record Vendor;
        RecordMatchMgt: Codeunit "Record Match Mgt.";
        PhoneNoNearness: Integer;
    begin
        if PhoneNo = '' then
            exit('');

        if Vendor.FindSet() then
            repeat
                PhoneNoNearness := RecordMatchMgt.CalculateStringNearness(PhoneNo, Vendor."Phone No.", MatchThreshold(), NormalizingFactor());
                if PhoneNoNearness >= RequiredNearness() then begin
                    IntermediateDataImport.InsertOrUpdateEntry(EntryNo, DATABASE::"Purchase Header", FieldID, 0, RecordNo, Vendor."No.");
                    exit(Vendor."No.");
                end;
            until Vendor.Next() = 0;

        exit('');
    end;

    local procedure FindInvoiceToApplyTo(EntryNo: Integer; RecordNo: Integer)
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        PurchaseHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        VendorInvoiceNo: Text;
        AppliesToDocTypeAsInteger: Integer;
    begin
        VendorInvoiceNo := IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::"Purchase Header", PurchaseHeader.FieldNo("Applies-to Doc. No."), 0, RecordNo);
        if VendorInvoiceNo = '' then
            exit;

        PurchInvHeader.SetRange("Vendor Invoice No.", VendorInvoiceNo);
        if PurchInvHeader.FindFirst() then begin
            AppliesToDocTypeAsInteger := PurchaseHeader."Applies-to Doc. Type"::Invoice.AsInteger();
            IntermediateDataImport.InsertOrUpdateEntry(EntryNo, DATABASE::"Purchase Header",
              PurchaseHeader.FieldNo("Applies-to Doc. Type"), 0, RecordNo, Format(AppliesToDocTypeAsInteger));
            IntermediateDataImport.InsertOrUpdateEntry(EntryNo, DATABASE::"Purchase Header",
              PurchaseHeader.FieldNo("Applies-to Doc. No."), 0, RecordNo, PurchInvHeader."No.");
            exit;
        end;

        PurchaseHeader.SetRange("Vendor Invoice No.", VendorInvoiceNo);
        if PurchaseHeader.FindFirst() then begin
            LogErrorMessage(EntryNo, PurchaseHeader, PurchaseHeader.FieldNo("No."),
              StrSubstNo(YouMustFirstPostTheRelatedInvoiceErr, VendorInvoiceNo, PurchaseHeader."No."));
            exit;
        end;

        LogErrorMessage(
          EntryNo, PurchInvHeader, PurchInvHeader.FieldNo("No."), StrSubstNo(UnableToFindRelatedInvoiceErr, VendorInvoiceNo));
    end;

    local procedure ProcessLine(EntryNo: Integer; HeaderRecordNo: Integer; RecordNo: Integer; VendorNo: Code[20])
    begin
        if IsDescriptionOnlyLine(EntryNo, HeaderRecordNo, RecordNo) then
            CleanDescriptionOnlyLine(EntryNo, HeaderRecordNo, RecordNo)
        else begin
            if not FindItemReferenceFromGTIN(EntryNo, HeaderRecordNo, RecordNo) then
                if not FindItemReferenceFromVendor(EntryNo, HeaderRecordNo, RecordNo, VendorNo) then
                    if not FindItemReferenceFromVendorItemNo(EntryNo, HeaderRecordNo, RecordNo, VendorNo) then
                        if not FindItemReferenceFromItemNo(EntryNo, HeaderRecordNo, RecordNo, VendorNo) then
                            if not FindItemReferenceFromItem(EntryNo, HeaderRecordNo, RecordNo) then
                                if not FindItemReferenceFromSubscriber(EntryNo, HeaderRecordNo, RecordNo, VendorNo) then
                                    if not CreateItemWorksheetLine(EntryNo, HeaderRecordNo, RecordNo, VendorNo) then
                                        if not FindGLAccountForLine(EntryNo, HeaderRecordNo, RecordNo) then
                                            LogErrorIfItemNotFound(EntryNo, HeaderRecordNo, RecordNo, VendorNo);
            ResolveUnitOfMeasure(EntryNo, HeaderRecordNo, RecordNo);
            ValidateLineDiscount(EntryNo, HeaderRecordNo, RecordNo);
        end;
    end;

    local procedure InsertLineForTotalDocumentAmount(EntryNo: Integer; HeaderRecordNo: Integer; RecordNo: Integer; VendorNo: Code[20])
    var
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        IntermediateDataImport: Record "Intermediate Data Import";
        LineDescription: Text[250];
    begin
        if not Vendor.Get(VendorNo) then
            exit;

        LineDescription := Vendor.Name;
        IntermediateDataImport.InsertOrUpdateEntry(EntryNo, DATABASE::"Purchase Line",
          PurchaseLine.FieldNo(Description), HeaderRecordNo, RecordNo, LineDescription);
        IntermediateDataImport.InsertOrUpdateEntry(EntryNo, DATABASE::"Purchase Line",
          PurchaseLine.FieldNo(Quantity), HeaderRecordNo, RecordNo, '1');
        IntermediateDataImport.InsertOrUpdateEntry(EntryNo, DATABASE::"Purchase Line",
          PurchaseLine.FieldNo("Direct Unit Cost"), HeaderRecordNo, RecordNo, GetTotalAmountExclVAT(EntryNo, HeaderRecordNo));
        FindGLAccountForLine(EntryNo, HeaderRecordNo, RecordNo);
    end;

    local procedure GetTotalAmountExclVAT(EntryNo: Integer; HeaderRecordNo: Integer): Text[250]
    var
        PurchaseHeader: Record "Purchase Header";
        IntermediateDataImport: Record "Intermediate Data Import";
    begin
        if not IntermediateDataImport.FindEntry(EntryNo, DATABASE::"Purchase Header", PurchaseHeader.FieldNo(Amount), 0, HeaderRecordNo) then begin
            LogSimpleErrorMessage(EntryNo, UnableToFindTotalAmountErr);
            exit('');
        end;
        exit(IntermediateDataImport.Value);
    end;

    local procedure FindItemReferenceFromGTIN(EntryNo: Integer; HeaderNo: Integer; RecordNo: Integer): Boolean
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        PurchaseLine: Record "Purchase Line";
        Item: Record Item;
        GTIN: Text;
    begin
        if not IntermediateDataImport.FindEntry(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo("No."), HeaderNo, RecordNo) then
            exit(false);

        GTIN := IntermediateDataImport.Value;
        if GTIN = '' then
            exit(false);

        Item.SetRange(GTIN, GTIN);
        if not Item.FindFirst() then
            exit(false);

        IntermediateDataImport.Value := Item."No.";
        IntermediateDataImport.Modify();

        IntermediateDataImport.InsertOrUpdateEntry(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo(Type),
          HeaderNo, RecordNo, Format(PurchaseLine.Type::Item, 0, 9));
        exit(true);
    end;

    local procedure FindItemReferenceFromVendor(EntryNo: Integer; HeaderRecordNo: Integer; RecordNo: Integer; VendorNo: Code[20]): Boolean
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        PurchaseLine: Record "Purchase Line";
        ItemReference: Record "Item Reference";
        Vendor: Record Vendor;
        ItemVariant: Record "Item Variant";
    begin
        if not Vendor.Get(VendorNo) then
            exit(false);

        if IntermediateDataImport.FindEntry(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo("Item Reference No."), HeaderRecordNo, RecordNo) then begin
            ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::Vendor);
            ItemReference.SetRange("Reference Type No.", VendorNo);
            ItemReference.SetRange("Reference No.", IntermediateDataImport.Value);
            if ItemReference.FindFirst() then begin
                IntermediateDataImport.InsertOrUpdateEntry(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo("No."),
                  HeaderRecordNo, RecordNo, Format(ItemReference."Item No.", 0, 9));
                IntermediateDataImport.InsertOrUpdateEntry(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo(Type),
                  HeaderRecordNo, RecordNo, Format(PurchaseLine.Type::Item, 0, 9));
                if ItemReference."Variant Code" <> '' then
                    if ItemVariant.Get(ItemReference."Item No.", ItemReference."Variant Code") then
                        if not ItemVariant."NPR Blocked" then
                            IntermediateDataImport.InsertOrUpdateEntry(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo("Variant Code"),
                              HeaderRecordNo, RecordNo, Format(ItemVariant.Code, 0, 9));
                exit(true);
            end;
        end;

        exit(false);
    end;

    local procedure FindItemReferenceFromVendorItemNo(EntryNo: Integer; HeaderRecordNo: Integer; RecordNo: Integer; VendorNo: Code[20]): Boolean
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        Item: Record Item;
    begin
        if not Vendor.Get(VendorNo) then
            exit(false);
        if IntermediateDataImport.FindEntry(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo("Item Reference No."), HeaderRecordNo, RecordNo) then begin
            Item.SetRange("Vendor No.", Vendor."No.");
            Item.SetRange("Vendor Item No.", IntermediateDataImport.Value);
            if Item.FindFirst() then begin
                IntermediateDataImport.InsertOrUpdateEntry(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo("No."),
                  HeaderRecordNo, RecordNo, Format(Item."No.", 0, 9));
                IntermediateDataImport.InsertOrUpdateEntry(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo(Type),
                  HeaderRecordNo, RecordNo, Format(PurchaseLine.Type::Item, 0, 9));
                exit(true);
            end;
        end;

        exit(false);
    end;

    local procedure FindItemReferenceFromItemNo(EntryNo: Integer; HeaderRecordNo: Integer; RecordNo: Integer; VendorNo: Code[20]): Boolean
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        PurchaseLine: Record "Purchase Line";
        Item: Record Item;
        Vendor: Record Vendor;
    begin
        if not Vendor.Get(VendorNo) then
            exit(false);

        if IntermediateDataImport.FindEntry(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo("Item Reference No."), HeaderRecordNo, RecordNo) then begin
            Item.SetRange("Vendor No.", VendorNo);
            Item.SetRange("No.", IntermediateDataImport.Value);
            if Item.FindFirst() then begin
                IntermediateDataImport.InsertOrUpdateEntry(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo("No."),
                  HeaderRecordNo, RecordNo, Format(Item."No.", 0, 9));
                IntermediateDataImport.InsertOrUpdateEntry(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo(Type),
                  HeaderRecordNo, RecordNo, Format(PurchaseLine.Type::Item, 0, 9));

                exit(true);
            end;
        end;

        exit(false);
    end;

    local procedure FindItemReferenceFromItem(EntryNo: Integer; HeaderRecordNo: Integer; RecordNo: Integer): Boolean
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        PurchaseLine: Record "Purchase Line";
        Item: Record Item;
    begin
        if IntermediateDataImport.FindEntry(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo("Item Reference No."), HeaderRecordNo, RecordNo) then begin
            Item.SetRange("No.", IntermediateDataImport.Value);
            if Item.FindFirst() then begin
                IntermediateDataImport.InsertOrUpdateEntry(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo("No."),
                  HeaderRecordNo, RecordNo, Format(Item."No.", 0, 9));
                IntermediateDataImport.InsertOrUpdateEntry(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo(Type),
                  HeaderRecordNo, RecordNo, Format(PurchaseLine.Type::Item, 0, 9));
                exit(true);
            end;
        end;

        exit(false);
    end;

    local procedure CreateItemWorksheetLine(EntryNo: Integer; HeaderRecordNo: Integer; RecordNo: Integer; VendorNo: Code[20]): Boolean
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        ItemWorksheet: Record "NPR Item Worksheet";
        ItemWorksheetLine: Record "NPR Item Worksheet Line";
        ItemGroupText: Text;
        VendorItemNo: Text;
        VendorItemDescription: Text;
        ItemWkshtDocExchange: Codeunit "NPR Item Wksht. Doc. Exch.";
        DirectUnitCost: Decimal;
    begin
        if not Vendor.Get(VendorNo) then
            exit(false);
        if IntermediateDataImport.FindEntry(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo("Item Reference No."), HeaderRecordNo, RecordNo) then begin
            ItemGroupText := IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo("Description 2"), HeaderRecordNo, RecordNo);
            if not Evaluate(DirectUnitCost, IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo("Direct Unit Cost"), HeaderRecordNo, RecordNo), 9) then
                DirectUnitCost := 0;
            VendorItemNo := IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo("Item Reference No."), HeaderRecordNo, RecordNo);
            VendorItemDescription := IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo(Description), HeaderRecordNo, RecordNo);
            ItemWkshtDocExchange.InsertItemWorksheetLine(ItemWorksheet, ItemWorksheetLine, VendorNo, VendorItemNo, VendorItemDescription, ItemGroupText, DirectUnitCost);
            LogErrorMessage(EntryNo, ItemWorksheetLine, ItemWorksheetLine.FieldNo("Vendor Item No."), VendorItemNo);
            LogErrorMessage(EntryNo, ItemWorksheetLine, ItemWorksheetLine.FieldNo("Item Category Code"), ItemGroupText);
            LogErrorMessage(EntryNo, ItemWorksheetLine, ItemWorksheetLine.FieldNo("Direct Unit Cost"), Format(DirectUnitCost, 0, 9));
            LogErrorMessage(EntryNo, ItemWorksheetLine, ItemWorksheetLine.FieldNo(Description), VendorItemDescription);
            LogErrorMessage(EntryNo, ItemWorksheetLine, ItemWorksheetLine.FieldNo("Vendor No."), VendorNo);
            exit(true);
        end;

        exit(false);
    end;

    local procedure IsDescriptionOnlyLine(EntryNo: Integer; HeaderRecordNo: Integer; RecordNo: Integer): Boolean
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        PurchaseLine: Record "Purchase Line";
        Qty: Decimal;
    begin
        if not IntermediateDataImport.FindEntry(EntryNo, DATABASE::"Purchase Line",
     PurchaseLine.FieldNo(Quantity), HeaderRecordNo, RecordNo)
then
            exit(true);

        Evaluate(Qty, IntermediateDataImport.Value, 9);
        if Qty = 0 then
            exit(true);

        exit(false);
    end;

    local procedure CleanDescriptionOnlyLine(EntryNo: Integer; HeaderRecordNo: Integer; RecordNo: Integer)
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        PurchaseLine: Record "Purchase Line";
    begin
        IntermediateDataImport.InsertOrUpdateEntry(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo(Type),
  HeaderRecordNo, RecordNo, Format(PurchaseLine.Type::" ", 0, 9));

        IntermediateDataImport.SetRange("Data Exch. No.", EntryNo);
        IntermediateDataImport.SetRange("Table ID", DATABASE::"Purchase Line");
        IntermediateDataImport.SetRange("Parent Record No.", HeaderRecordNo);
        IntermediateDataImport.SetRange("Record No.", RecordNo);
        IntermediateDataImport.SetFilter("Field ID", '<>%1&<>%2&<>%3',
          PurchaseLine.FieldNo(Type), PurchaseLine.FieldNo(Description), PurchaseLine.FieldNo("Description 2"));
        IntermediateDataImport.DeleteAll();
    end;

    local procedure LogErrorIfItemNotFound(EntryNo: Integer; HeaderRecordNo: Integer; RecordNo: Integer; VendorNo: Code[20]): Boolean
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        PurchaseLine: Record "Purchase Line";
        Item: Record Item;
        GTIN: Text[250];
        ItemName: Text[250];
        VendorItemNo: Text[250];
    begin
        GTIN := IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo("No."),
    HeaderRecordNo, RecordNo);

        VendorItemNo := IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo("Item Reference No."),
            HeaderRecordNo, RecordNo);

        ItemName := IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo(Description),
            HeaderRecordNo, RecordNo);

        if (GTIN <> '') and (VendorItemNo <> '') then begin
            LogErrorMessage(EntryNo, Item, Item.FieldNo("No."),
              StrSubstNo(ItemNotFoundErr, ItemName, VendorNo, VendorItemNo, GTIN));
            exit(false);
        end;

        if GTIN <> '' then begin
            LogErrorMessage(EntryNo, Item, Item.FieldNo("No."),
              StrSubstNo(ItemNotFoundByGTINErr, ItemName, GTIN));
            exit(false);
        end;

        if VendorItemNo <> '' then begin
            LogErrorMessage(EntryNo, Item, Item.FieldNo("No."),
              StrSubstNo(ItemNotFoundByVendorItemNoErr, ItemName, VendorNo, VendorItemNo));
            exit(false);
        end;

        exit(true);
    end;

    local procedure FindGLAccountForLine(EntryNo: Integer; HeaderRecordNo: Integer; RecordNo: Integer): Boolean
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        PurchaseLine: Record "Purchase Line";
        GLAccountNo: Code[20];
        LineDescription: Text[250];
        LineDirectUnitCostTxt: Text;
        LineDirectUnitCost: Decimal;
    begin
        LineDescription := IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo(Description), HeaderRecordNo, RecordNo);
        LineDirectUnitCostTxt :=
          IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo("Direct Unit Cost"), HeaderRecordNo, RecordNo);
        if LineDirectUnitCostTxt <> '' then
            Evaluate(LineDirectUnitCost, LineDirectUnitCostTxt, 9);
        GLAccountNo := FindAppropriateGLAccount(EntryNo, HeaderRecordNo, LineDescription, LineDirectUnitCost);

        if GLAccountNo <> '' then begin
            IntermediateDataImport.InsertOrUpdateEntry(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo("No."),
              HeaderRecordNo, RecordNo, GLAccountNo);
            IntermediateDataImport.InsertOrUpdateEntry(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo(Type),
              HeaderRecordNo, RecordNo, Format(PurchaseLine.Type::"G/L Account", 0, 9));
        end;
        exit(GLAccountNo <> '');
    end;

    local procedure ResolveUnitOfMeasure(EntryNo: Integer; HeaderRecordNo: Integer; RecordNo: Integer)
    var
        PurchaseLine: Record "Purchase Line";
        IntermediateDataImport: Record "Intermediate Data Import";
        UnitOfMeasure: Record "Unit of Measure";
    begin
        if not IntermediateDataImport.FindEntry(EntryNo, DATABASE::"Purchase Line",
     PurchaseLine.FieldNo("Unit of Measure"), HeaderRecordNo, RecordNo)
then
            LogSimpleErrorMessage(EntryNo, StrSubstNo(UOMMissingErr, RecordNo));

        UnitOfMeasure.SetRange("International Standard Code", IntermediateDataImport.Value);
        if not UnitOfMeasure.FindFirst() then
            LogErrorMessage(EntryNo, UnitOfMeasure, UnitOfMeasure.FieldNo(Code),
              StrSubstNo(UOMNotFoundErr, IntermediateDataImport.Value));

        IntermediateDataImport.Value := UnitOfMeasure.Code;
        IntermediateDataImport.Modify();
    end;

    local procedure ValidateLineDiscount(EntryNo: Integer; HeaderRecordNo: Integer; RecordNo: Integer)
    var
        PurchaseLine: Record "Purchase Line";
        IntermediateDataImport: Record "Intermediate Data Import";
        GLSetup: Record "General Ledger Setup";
        PurchaseHeader: Record "Purchase Header";
        Currency: Record Currency;
        LineDirectUnitCostTxt: Text;
        LineQuantityTxt: Text;
        LineAmountTxt: Text;
        LineDirectUnitCost: Decimal;
        LineAmount: Decimal;
        LineQuantity: Decimal;
        LineDiscountAmount: Decimal;
        DocumentCurrency: Text;
        LineDiscountPct: Decimal;
        UnitCostWithoutLineDiscount: Decimal;
    begin
        if IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo("Line Discount Amount"), HeaderRecordNo, RecordNo) <> ''
then
            exit;

        LineDirectUnitCostTxt :=
          IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo("Direct Unit Cost"), HeaderRecordNo, RecordNo);
        if LineDirectUnitCostTxt <> '' then
            Evaluate(LineDirectUnitCost, LineDirectUnitCostTxt, 9);
        LineQuantityTxt :=
          IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo(Quantity), HeaderRecordNo, RecordNo);
        if LineQuantityTxt <> '' then
            Evaluate(LineQuantity, LineQuantityTxt, 9);
        LineAmountTxt :=
          IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo(Amount), HeaderRecordNo, RecordNo);
        if LineAmountTxt <> '' then
            Evaluate(LineAmount, LineAmountTxt, 9);
        GLSetup.Get();
        DocumentCurrency := IntermediateDataImport.GetEntryValue(EntryNo, Database::"Purchase Header", PurchaseHeader.FieldNo("Currency Code"), 0, HeaderRecordNo);
        if (DocumentCurrency = '') or (DocumentCurrency = GLSetup."LCY Code") or not (Currency.Get(CopyStr(DocumentCurrency, 1, MaxStrLen(Currency.Code)))) then
            Currency.InitRoundingPrecision()
        else
            Currency.TestField("Amount Rounding Precision");
        LineDiscountAmount := Round(LineQuantity * LineDirectUnitCost, Currency."Amount Rounding Precision") - Round(LineAmount, Currency."Amount Rounding Precision");
        if (LineDiscountAmount <> 0) and (LineQuantity <> 0) then begin
            if Round(LineQuantity * LineDirectUnitCost, Currency."Amount Rounding Precision") <> 0 then
                LineDiscountPct := Round(LineDiscountAmount / Round(LineQuantity * LineDirectUnitCost, Currency."Amount Rounding Precision"), 0.00001);
            UnitCostWithoutLineDiscount := Round(LineAmount / LineQuantity, Currency."Unit-Amount Rounding Precision");
            if (LineDiscountPct < 0) or (LineDirectUnitCost = Round(UnitCostWithoutLineDiscount, UnitCostRoundingPrecision(LineDirectUnitCostTxt))) then begin
                LineDiscountAmount := 0;
                IntermediateDataImport.InsertOrUpdateEntry(EntryNo, Database::"Purchase Line", PurchaseLine.FieldNo("Direct Unit Cost"), HeaderRecordNo, RecordNo, Format(UnitCostWithoutLineDiscount, 0, 9));
            end;
        end;
        IntermediateDataImport.InsertOrUpdateEntry(EntryNo, DATABASE::"Purchase Line", PurchaseLine.FieldNo("Line Discount Amount"),
          HeaderRecordNo, RecordNo, Format(LineDiscountAmount, 0, 9));

        IntermediateDataImport.Modify();
    end;

    local procedure ExtractVatRegNo(VatRegNo: Text; CountryRegionCode: Text): Text
    var
        CompanyInformation: Record "Company Information";
    begin
        if CountryRegionCode = '' then begin
            CompanyInformation.Get();
            CountryRegionCode := CompanyInformation."Country/Region Code";
        end;
        VatRegNo := UpperCase(VatRegNo);
        VatRegNo := DelChr(VatRegNo, '=', DelChr(VatRegNo, '=', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'));
        if StrPos(VatRegNo, UpperCase(CountryRegionCode)) = 1 then
            VatRegNo := DelStr(VatRegNo, 1, StrLen(CountryRegionCode));
        exit(VatRegNo);
    end;

    local procedure FindDistinctRecordNos(var TempInteger: Record "Integer" temporary; DataExchEntryNo: Integer; TableID: Integer; ParentRecNo: Integer)
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        CurrRecNo: Integer;
    begin
        CurrRecNo := -1;
        Clear(TempInteger);
        TempInteger.DeleteAll();

        IntermediateDataImport.SetRange("Data Exch. No.", DataExchEntryNo);
        IntermediateDataImport.SetRange("Table ID", TableID);
        IntermediateDataImport.SetRange("Parent Record No.", ParentRecNo);
        IntermediateDataImport.SetCurrentKey("Record No.");
        if not IntermediateDataImport.FindSet() then
            exit;

        repeat
            if CurrRecNo <> IntermediateDataImport."Record No." then begin
                CurrRecNo := IntermediateDataImport."Record No.";
                Clear(TempInteger);
                TempInteger.Number := CurrRecNo;
                TempInteger.Insert();
            end;
        until IntermediateDataImport.Next() = 0;
    end;

    local procedure LogErrorMessage(EntryNo: Integer; RelatedRec: Variant; FieldNo: Integer; Message: Text)
    var
        ErrorMessage: Record "Error Message";
        DataExch: Record "Data Exch.";
        IncomingDocument: Record "Incoming Document";
    begin
        DataExch.Get(EntryNo);
        IncomingDocument.Get(DataExch."Incoming Entry No.");

        ErrorMessage.SetContext(IncomingDocument);
        ErrorMessage.LogMessage(RelatedRec, FieldNo, ErrorMessage."Message Type"::Error, Message);
    end;

    local procedure LogSimpleErrorMessage(EntryNo: Integer; Message: Text)
    var
        ErrorMessage: Record "Error Message";
        DataExch: Record "Data Exch.";
        IncomingDocument: Record "Incoming Document";
    begin
        DataExch.Get(EntryNo);
        IncomingDocument.Get(DataExch."Incoming Entry No.");

        ErrorMessage.SetContext(IncomingDocument);
        ErrorMessage.LogSimpleMessage(ErrorMessage."Message Type"::Error, Message);
    end;

    local procedure SetDocumentType(EntryNo: Integer; ParentRecNo: Integer; CurrRecNo: Integer)
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        PurchaseHeader: Record "Purchase Header";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        DocumentType: Text[250];
    begin
        DataExch.Get(EntryNo);
        DataExchDef.Get(DataExch."Data Exch. Def Code");
        if not IntermediateDataImport.FindEntry(EntryNo, DATABASE::"Purchase Header", PurchaseHeader.FieldNo("Document Type"), ParentRecNo, CurrRecNo) then
            LogErrorMessage(EntryNo, DataExchDef, DataExchDef.FieldNo(Code),
              ConstructDocumenttypeUnknownErr());

        case UpperCase(IntermediateDataImport.Value) of
            GetDocumentTypeOptionString(PurchaseHeader."Document Type"::Invoice),
            GetDocumentTypeOptionCaption(PurchaseHeader."Document Type"::Invoice):
                DocumentType := Format(PurchaseHeader."Document Type"::Invoice, 0, 9);
            GetDocumentTypeOptionString(PurchaseHeader."Document Type"::"Credit Memo"),
            GetDocumentTypeOptionCaption(PurchaseHeader."Document Type"::"Credit Memo"),
            'CREDIT NOTE':
                DocumentType := Format(PurchaseHeader."Document Type"::"Credit Memo", 0, 9);
            else
                LogErrorMessage(EntryNo, DataExchDef, DataExchDef.FieldNo(Code), ConstructDocumenttypeUnknownErr());
        end;

        IntermediateDataImport.InsertOrUpdateEntry(EntryNo, DATABASE::"Purchase Header",
          PurchaseHeader.FieldNo("Document Type"), ParentRecNo, CurrRecNo,
          DocumentType);
    end;

    local procedure GetDocumentType(EntryNo: Integer; CurrRecNo: Integer): Enum "Purchase Document Type"
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        PurchaseHeader: Record "Purchase Header";
        DocumentTypeTxt: Text[250];
        DocumentTypeOrdinal: Integer;
    begin
        DocumentTypeOrdinal := -1;
        DocumentTypeTxt := IntermediateDataImport.GetEntryValue(EntryNo, DATABASE::"Purchase Header", PurchaseHeader.FieldNo("Document Type"), 0, CurrRecNo);
        if Evaluate(DocumentTypeOrdinal, DocumentTypeTxt) then;
        exit(Enum::"Purchase Document Type".FromInteger(DocumentTypeOrdinal));
    end;

    procedure GetDocumentTypeOptionString(PurchDocType: Enum "Purchase Document Type"): Text[250]
    var
        EnumIndex: Integer;
        EnumValueName: Text;
    begin
        EnumIndex := PurchDocType.Ordinals().IndexOf(PurchDocType.AsInteger());
        PurchDocType.Names().Get(EnumIndex, EnumValueName);
        exit(UpperCase(EnumValueName));
    end;

    procedure GetDocumentTypeOptionCaption(PurchDocType: Enum "Purchase Document Type"): Text[250]
    begin
        exit(UpperCase(Format(PurchDocType)));
    end;

    procedure ConstructDocumenttypeUnknownErr(): Text
    var
        PurchaseHeader: Record "Purchase Header";
        DataExchColumnDef: Record "Data Exch. Column Def";
        DataExchColDefPart: Page "Data Exch Col Def Part";
        DataExchDefCard: Page "Data Exch Def Card";
    begin
        exit(StrSubstNo(DocumentTypeUnknownErr,
            DataExchColDefPart.Caption,
            DataExchDefCard.Caption,
            GetDocumentTypeOptionCaption(PurchaseHeader."Document Type"::Invoice),
            GetDocumentTypeOptionCaption(PurchaseHeader."Document Type"::"Credit Memo"),
            DataExchColumnDef.FieldCaption(Constant),
            PurchaseHeader.FieldCaption("Document Type"),
            PurchaseHeader.TableCaption));
    end;

    procedure FindAppropriateGLAccount(EntryNo: Integer; HeaderRecordNo: Integer; LineDescription: Text[250]; LineDirectUnitCost: Decimal): Code[20]
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        TextToAccountMapping: Record "Text-to-Account Mapping";
        PurchaseHeader: Record "Purchase Header";
        DocumentType: Enum "Purchase Document Type";
        DefaultGLAccount: Code[20];
    begin
        DocumentType := GetDocumentType(EntryNo, HeaderRecordNo);

        if TextToAccountMapping.FindSet() then
            repeat
                if UpperCase(TextToAccountMapping."Mapping Text") = UpperCase(LineDescription) then
                    case DocumentType of
                        PurchaseHeader."Document Type"::Invoice:
                            begin
                                if (LineDirectUnitCost >= 0) and (TextToAccountMapping."Debit Acc. No." <> '') then
                                    exit(TextToAccountMapping."Debit Acc. No.");
                                if (LineDirectUnitCost < 0) and (TextToAccountMapping."Credit Acc. No." <> '') then
                                    exit(TextToAccountMapping."Credit Acc. No.");
                            end;
                        PurchaseHeader."Document Type"::"Credit Memo":
                            begin
                                if (LineDirectUnitCost >= 0) and (TextToAccountMapping."Credit Acc. No." <> '') then
                                    exit(TextToAccountMapping."Credit Acc. No.");
                                if (LineDirectUnitCost < 0) and (TextToAccountMapping."Debit Acc. No." <> '') then
                                    exit(TextToAccountMapping."Debit Acc. No.");
                            end;
                    end
            until TextToAccountMapping.Next() = 0;

        PurchasesPayablesSetup.Get();
        case DocumentType of
            PurchaseHeader."Document Type"::Invoice:
                begin
                    if LineDirectUnitCost >= 0 then
                        DefaultGLAccount := PurchasesPayablesSetup."Debit Acc. for Non-Item Lines"
                    else
                        DefaultGLAccount := PurchasesPayablesSetup."Credit Acc. for Non-Item Lines";
                end;
            PurchaseHeader."Document Type"::"Credit Memo":
                begin
                    if LineDirectUnitCost >= 0 then
                        DefaultGLAccount := PurchasesPayablesSetup."Credit Acc. for Non-Item Lines"
                    else
                        DefaultGLAccount := PurchasesPayablesSetup."Debit Acc. for Non-Item Lines";
                end;
        end;
        if DefaultGLAccount = '' then
            LogErrorMessage(EntryNo, TextToAccountMapping, TextToAccountMapping.FieldNo("Mapping Text"),
              StrSubstNo(UnableToFindAppropriateAccountErr, LineDescription));
        exit(DefaultGLAccount)
    end;

    local procedure NormalizingFactor(): Integer
    begin
        exit(100)
    end;

    local procedure MatchThreshold(): Integer
    begin
        exit(4)
    end;

    local procedure RequiredNearness(): Integer
    begin
        exit(95)
    end;

    local procedure FindItemReferenceFromSubscriber(EntryNo: Integer; HeaderRecordNo: Integer; RecordNo: Integer; VendorNo: Code[20]) Identified: Boolean
    begin
        OnMapItemRecerenceToPurchaseLine(EntryNo, HeaderRecordNo, RecordNo, VendorNo, Identified);
    end;

    local procedure UnitCostRoundingPrecision(AmountTxt: Text): Decimal
    var
        NoOfDecimals: Integer;
    begin
        if AmountTxt = '' then
            exit(0.00001);
        if StrPos(AmountTxt, '.') = 0 then
            exit(1);
        NoOfDecimals := StrLen(AmountTxt) - StrPos(AmountTxt, '.');
        exit(Power(10, -NoOfDecimals));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnMapItemRecerenceToPurchaseLine(EntryNo: Integer; HeaderRecordNo: Integer; RecordNo: Integer; VendorNo: Code[20]; var Identified: Boolean)
    begin
    end;
}

