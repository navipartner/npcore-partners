codeunit 6184669 "NPR DK Audit Mgt."
{
    Access = Internal;
    SingleInstance = true;

    var
        _DKFiscalizationSetup: Record "NPR DK Fiscalization Setup";

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        _SignatureKey: Codeunit "Signature Key";
#elif not (BC17 or BC1800 or BC1801 or BC1802 or BC1803 or BC1804)
        _SignatureKey: Record "Signature Key";
#else
        _X509Certificate2: DotNet NPRNetX509Certificate2;
        _RSACryptoServiceProvider: DotNet NPRNetRSACryptoServiceProvider;
#endif
        _Enabled: Boolean;
        _CertificateLoaded: Boolean;
        _Initialized: Boolean;
        _DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
        AdditionalInfoLbl: Label '%1:%2:%3', Locked = true, Comment = '%1 - specifies Item No., %2 - specifies old Unit Price, %3 - specifies new Unit Price';
        OVERWRITE_CERT_Qst: Label 'Are you sure you want to overwrite the existing certificate?';
        MISSING_KEY_Err: Label 'The selected certificate does not contain the private key';
        CERT_SUCCESS_Msg: Label 'Certificate with thumbprint %1 was uploaded successfully';
        VALIDATE_VERSION_Err: Label 'Can only validate entries created for implementation %1', Comment = '%1 - Fiscal Handler Code';
        VALIDATE_CERT_Err: Label 'Can only validate entries signed with certificate thumbprint %1', Comment = '%1 - Signing Certificate Thumbprint';

    #region DK Fiscal - POS Handling Subscribers

    [EventSubscriber(ObjectType::Page, Page::"NPR POS Audit Profiles", 'OnHandlePOSAuditProfileAdditionalSetup', '', true, true)]
    local procedure OnHandlePOSAuditProfileAdditionalSetup(POSAuditProfile: Record "NPR POS Audit Profile")
    begin
        if not IsDKAuditEnabled(POSAuditProfile.Code) then
            exit;
        OnActionShowSetup();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnLookupAuditHandler', '', true, true)]
    local procedure OnLookupAuditHandler(var tmpRetailList: Record "NPR Retail List")
    begin
        AddDKAuditHandler(tmpRetailList);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnHandleAuditLogBeforeInsert', '', true, true)]
    local procedure OnHandleAuditLogBeforeInsert(var POSAuditLog: Record "NPR POS Audit Log")
    begin
        HandleOnHandleAuditLogBeforeInsert(POSAuditLog);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Store", 'OnBeforeRenameEvent', '', false, false)]
    local procedure OnBeforeRenamePOSStore(var Rec: Record "NPR POS Store"; var xRec: Record "NPR POS Store"; RunTrigger: Boolean)
    begin
        ErrorOnRenameOfPOSStoreIfAlreadyUsed(xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Unit", 'OnBeforeRenameEvent', '', false, false)]
    local procedure OnBeforeRenamePOSUnit(var Rec: Record "NPR POS Unit"; var xRec: Record "NPR POS Unit"; RunTrigger: Boolean)
    begin
        ErrorOnRenameOfPOSUnitIfAlreadyUsed(xRec);
    end;
    #endregion

    #region Subscribers - POS Audit Logging
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Action: Run Page", 'OnBeforeRunPage', '', false, false)]
    local procedure NPRPOSActionRunPage_OnBeforeRunPage(PageId: Integer; RunModal: Boolean; Sale: Codeunit "NPR POS Sale");
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSSale: Record "NPR POS Sale";
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        AuditLogDescLbl: Label 'Price checked by %1', Comment = '%1 - Salesperson Code';
    begin
        if not IsDKFiscalActive() then
            exit;

        Sale.GetCurrentSale(POSSale);
        POSAuditLogMgt.CreateEntryExtended(POSSale.RecordId, POSAuditLog."Action Type"::PRICE_CHECK, 0, '', POSSale."Register No.", StrSubstNo(AuditLogDescLbl, POSSale."Salesperson Code"), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POSAction: Delete POS Line", 'OnBeforeDeleteSaleLinePOS', '', false, false)]
    local procedure NPRPOSActionDeletePOSLine_OnBeforeDeleteSaleLinePOS(POSSaleLine: Codeunit "NPR POS Sale Line");
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSSaleLineRecord: Record "NPR POS Sale Line";
        POSUnit: Record "NPR POS Unit";
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        AuditLogDescLbl: Label 'POS Sales Line deleted';
    begin
        POSSaleLine.GetCurrentSaleLine(POSSaleLineRecord);
        POSUnit.Get(POSSaleLineRecord."Register No.");
        if not IsDKAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        POSAuditLogMgt.CreateEntryExtended(POSSaleLineRecord.RecordId, POSAuditLog."Action Type"::DELETE_POS_SALE_LINE, 0, '', POSSaleLineRecord."Register No.", AuditLogDescLbl, '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POSAction: Cancel Sale B", 'OnBeforeDeletePOSSaleLine', '', false, false)]
    local procedure NPRPOSActionCancelSaleB_OnBeforeDeletePOSSaleLine(POSSaleLine: Codeunit "NPR POS Sale Line"; SalePOS: Record "NPR POS Sale");
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSUnit: Record "NPR POS Unit";
        POSEntry: Record "NPR POS Entry";
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        AuditLogDescLbl: Label 'POS Sales Line canceled';
        POSSaleLineRecord: Record "NPR POS Sale Line";
        Amount: Decimal;
    begin
        POSSaleLine.GetCurrentSaleLine(POSSaleLineRecord);
        if POSSaleLineRecord.IsEmpty() then
            exit;

        if not POSUnit.Get(POSSaleLineRecord."Register No.") then
            exit;

        if not IsDKAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        POSSaleLineRecord.FindSet();
        repeat
            UpdatePriceChangedLine(POSSaleLineRecord, Format(POSEntry."Entry Type"::"Cancelled Sale"));
        until POSSaleLineRecord.Next() = 0;

        POSSaleLineRecord.CalcSums("Amount Including VAT");
        Amount := POSSaleLineRecord."Amount Including VAT";
        POSAuditLogMgt.CreateEntryExtended(SalePOS.RecordId, POSAuditLog."Action Type"::CANCEL_POS_SALE_LINE, 0, '', SalePOS."Register No.", AuditLogDescLbl, Format(Amount, 0, 9));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Discount Events", 'OnBeforeSetDiscount', '', false, false)]
    local procedure NPRPOSActionDiscountB_OnBeforeSetDiscount(DiscountType: Option; var SalePOS: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line"; DiscountAmount: Decimal)
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSUnit: Record "NPR POS Unit";
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        AuditLogDescLblTxt, AdditionalInfoTxt : Text;
        AuditLogDescLblLbl: Label 'Price changed on Item: %1 from %2 to %3.', Comment = '%1 - specifies Item No., %2 - specifies old Unit Price, %3 - specifies new Unit Price';
    begin
        if DiscountType <> _DiscountType::LineUnitPrice then
            exit;

        if SaleLinePOS."Line Type" <> SaleLinePOS."Line Type"::Item then
            exit;

        if not POSUnit.Get(SaleLinePOS."Register No.") then
            exit;

        if not IsDKAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        AuditLogDescLblTxt := StrSubstNo(AuditLogDescLblLbl, SaleLinePOS."No.", SaleLinePOS."Unit Price", DiscountAmount);
        AdditionalInfoTxt := StrSubstNo(AdditionalInfoLbl, SaleLinePOS."No.", SaleLinePOS."Unit Price", DiscountAmount);

        POSAuditLogMgt.CreateEntryExtended(SaleLinePOS.RecordId, POSAuditLog."Action Type"::PRICE_CHANGE, 0, '', SalePOS."Register No.", AuditLogDescLblTxt, AdditionalInfoTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Create Entry", 'OnBeforeInsertPOSSalesLine', '', false, false)]
    local procedure NPRPOSCreateEntry_OnBeforeInsertPOSSalesLine(POSEntry: Record "NPR POS Entry"; SaleLinePOS: Record "NPR POS Sale Line")
    var
        POSUnit: Record "NPR POS Unit";
    begin
        if POSEntry."Entry Type" <> POSEntry."Entry Type"::"Direct Sale" then
            exit;

        if SaleLinePOS."Line Type" <> SaleLinePOS."Line Type"::Item then
            exit;

        if not POSUnit.Get(POSEntry."POS Unit No.") then
            exit;

        if not IsDKAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        UpdatePriceChangedLine(SaleLinePOS, Format(POSEntry."Entry Type"));
    end;

    #endregion

    #region DK Fiscal - Sandbox Env. Cleanup

#if not (BC17 or BC18 or BC19)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", 'OnClearCompanyConfig', '', false, false)]
    local procedure OnClearCompanyConfig(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    var
        DKFiscalizationSetup: Record "NPR DK Fiscalization Setup";
    begin
        if DestinationEnv <> DestinationEnv::Sandbox then
            exit;

        DKFiscalizationSetup.ChangeCompany(CompanyName);
        if DKFiscalizationSetup.Get() then
            DKFiscalizationSetup.Delete();
    end;
#endif

    #endregion

    #region DK Fiscal - Audit Profile Mgt
    local procedure AddDKAuditHandler(var tmpRetailList: Record "NPR Retail List")
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Choice := CopyStr(HandlerCode(), 1, MaxStrLen(tmpRetailList.Choice));
        tmpRetailList.Insert();
    end;

    local procedure HandleOnHandleAuditLogBeforeInsert(var POSAuditLog: Record "NPR POS Audit Log")
    var
        POSEntry: Record "NPR POS Entry";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
    begin
        if POSAuditLog."Active POS Unit No." = '' then
            POSAuditLog."Active POS Unit No." := POSAuditLog."Acted on POS Unit No.";

        if not POSUnit.Get(POSAuditLog."Active POS Unit No.") then
            exit;
        if not IsDKAuditEnabled(POSUnit."POS Audit Profile") then
            exit;
        if not POSStore.Get(POSUnit."POS Store Code") then
            exit;
        if not (POSAuditLog."Action Type" in [POSAuditLog."Action Type"::DIRECT_SALE_END]) then
            exit;

        POSEntry.Get(POSAuditLog."Record ID");
        if not (POSEntry."Post Item Entry Status" in [POSEntry."Post Item Entry Status"::"Not To Be Posted"]) then
            InsertDKPOSAuditLogAuxInfo(POSEntry, POSStore, POSUnit);

        LoadCertificate();
        //Shave off milliseconds from timestamp to prevent sql rounding on commit causing signature invalidation later.
        Evaluate(POSAuditLog."Log Timestamp", CopyStr(Format(POSAuditLog."Log Timestamp", 0, 9), 1, 19) + '.000Z', 9);

        case POSAuditLog."Action Type" of
            POSAuditLog."Action Type"::DIRECT_SALE_END:
                SignTicket(POSAuditLog);
        end;
    end;

    local procedure SignTicket(var POSAuditLog: Record "NPR POS Audit Log")
    var
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.Get(POSAuditLog."Record ID");

        //TICKET event might also trigger a "Non-item amount" custom JET event depending on sale contents:
        LogNonItemAmounts(POSEntry);

        POSAuditLog."External ID" := POSEntry."Fiscal No.";
        POSAuditLog."External Code" := '';
        POSAuditLog."External Type" := 'TICKET';

        if IsFullRMA(POSEntry) then
            POSAuditLog."External Description" := 'Cancellation (Ticket)'
        else
            POSAuditLog."External Description" := 'Sale (Ticket)';

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    procedure FillSignatureBaseValues(var POSAuditLog: Record "NPR POS Audit Log"; IsInitialHandling: Boolean)
    var
        PreviousEventLogRecord: Record "NPR POS Audit Log";
        InStream: InStream;
        OutStream: OutStream;
        BaseValue: Text;
        PreviousSignature: Text;
        PreviousSignatureChunk: Text;
    begin
        if IsInitialHandling then begin
            if GetLastUnitEventSignature(POSAuditLog."Active POS Unit No.", PreviousEventLogRecord, POSAuditLog."External Type") then
                POSAuditLog."Previous Electronic Signature" := PreviousEventLogRecord."Electronic Signature";
            POSAuditLog."External Implementation" := HandlerCode();
            POSAuditLog."Certificate Implementation" := 'RSA-SHA256-2048';
            POSAuditLog."Certificate Thumbprint" := _DKFiscalizationSetup."Signing Certificate Thumbprint";
            POSAuditLog."Handled by External Impl." := true;
        end;

        if POSAuditLog."External Implementation" <> HandlerCode() then //Can only validate the current version of the implementation as the rules & fields might have changed over time.
            Error(VALIDATE_VERSION_Err, HandlerCode());

        if POSAuditLog."Certificate Thumbprint" <> _DKFiscalizationSetup."Signing Certificate Thumbprint" then
            Error(VALIDATE_CERT_Err, _DKFiscalizationSetup."Signing Certificate Thumbprint");
        POSAuditLog."Previous Electronic Signature".CreateInStream(InStream, TextEncoding::UTF8);
        while (not InStream.EOS) do begin
            InStream.ReadText(PreviousSignatureChunk);
            PreviousSignature += PreviousSignatureChunk;
        end;

        case POSAuditLog."External Type" of
            'TICKET':
                BaseValue := FillTicketBase(POSAuditLog, PreviousSignature);
        end;
        POSAuditLog."Signature Base Value".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(BaseValue);

        if IsInitialHandling then
            POSAuditLog."Original Signature Base Value" := POSAuditLog."Signature Base Value";
    end;

    local procedure FillTicketBase(var POSAuditLog: Record "NPR POS Audit Log"; PreviousSignature: Text): Text
    var
        POSEntry: Record "NPR POS Entry";
        TaxTotalExclTax: Decimal;
        TaxTotalInclTax: Decimal;
        FillTicketBaseLbl: Label '%1;%2;%3;%4;%5', Locked = true;
    begin
        POSEntry.Get(POSAuditLog."Record ID");

        TaxTotalExclTax := GetSaleTotalExclTax(POSEntry, false);
        TaxTotalInclTax := GetSaleTotalInclTax(POSEntry, false);

        exit(StrSubstNo(FillTicketBaseLbl,
            FormatText(PreviousSignature),
            FormatDatetime(POSAuditLog."Log Timestamp"),
            FormatAlphanumeric(POSAuditLog."Acted on POS Entry Fiscal No."),
            FormatNumeric(TaxTotalInclTax),
            FormatNumeric(TaxTotalExclTax)));
    end;

    procedure GetLastUnitEventSignature(POSUnitNo: Code[10]; var POSAuditLogOut: Record "NPR POS Audit Log"; ExternalType: Code[20]): Boolean
    begin
        POSAuditLogOut.SetAutoCalcFields("Electronic Signature");
        POSAuditLogOut.SetCurrentKey("Active POS Unit No.", "External Type");
        POSAuditLogOut.SetRange("Active POS Unit No.", POSUnitNo);
        POSAuditLogOut.SetRange("External Type", ExternalType);
        exit(POSAuditLogOut.FindLast());
    end;

    local procedure LogNonItemAmounts(POSEntry: Record "NPR POS Entry")
    var
        POSSalesLine: Record "NPR POS Entry Sales Line";
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        Amount: Decimal;
        AddInfoLbl: Label '%1|%2', Locked = true;
        AddInfo: Text;
    begin
        POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSSalesLine.SetFilter(Type, '<>%1&<>%2&<>%3', POSSalesLine.Type::Item, POSSalesLine.Type::Rounding, POSSalesLine.Type::Comment);
        if POSSalesLine.IsEmpty then
            exit;

        Amount := GetSaleTotalInclTax(POSEntry, false) - GetSaleTotalInclTax(POSEntry, true);
        AddInfo := StrSubstNo(AddInfoLbl, POSEntry."Fiscal No.", Format(Amount, 0, '<Precision,2:2><Standard Format,9>'));

        POSAuditLogMgt.CreateEntryCustom(POSEntry.RecordId, 'DKN_ITEM_AMOUNT', POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.", 'Sale amount not from items', AddInfo);
    end;

    local procedure SignRecord(var POSAuditLog: Record "NPR POS Audit Log")
    var
        IStream: InStream;
        OStream: OutStream;
        BaseValue: Text;
        BaseValueChunk: Text;
        Signature: Text;
    begin
        POSAuditLog."Signature Base Value".CreateInStream(IStream, TextEncoding::UTF8);
        while (not IStream.EOS) do begin
            IStream.ReadText(BaseValueChunk);
            BaseValue += BaseValueChunk;
        end;

        Signature := SignData(BaseValue);
        POSAuditLog."Electronic Signature".CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.WriteText(EncodeBase64URL(Signature));
    end;

    local procedure EncodeBase64URL(Text: Text): Text
    begin
        exit(DelChr(ConvertStr(Text, '/+', '_-'), '=', '='));
    end;

    local procedure FormatAlphanumeric(Text: Text): Text
    begin
        //As per auditing consultant: Alphanumeric is not supposed to be a literal interpretation, so will be treated as text...
        exit(FormatText(Text));
    end;

    local procedure FormatNumeric(Decimal: Decimal): Text
    begin
        exit(DelChr(Format(Round(Decimal), 0, '<Precision,2:2><Standard Format,9>'), '=', '.'));
    end;

    local procedure FormatDatetime(DateTime: DateTime): Text
    begin
        exit(Format(DateTime, 0, '<Year4>-<Month,2>-<Day,2>;<Hours24,2><Filler Character,0>:<Minutes,2>:<Seconds,2>'));
    end;

    local procedure FormatText(Text: Text): Text
    begin
        exit(ConvertStr(Text, ', ', ';_'));
    end;

    local procedure GetSaleTotalInclTax(POSEntry: Record "NPR POS Entry"; OnlyIncludeItems: Boolean): Decimal
    begin
        if OnlyIncludeItems then
            exit(POSEntry."Item Sales (LCY)" + POSEntry."Item Returns (LCY)")
        else
            exit(POSEntry."Amount Incl. Tax");
    end;

    local procedure GetSaleTotalExclTax(POSEntry: Record "NPR POS Entry"; OnlyIncludeItems: Boolean): Decimal
    begin
        if OnlyIncludeItems then
            exit(POSEntry."Item Sales (LCY)" + POSEntry."Item Returns (LCY)")
        else
            exit(POSEntry."Amount Excl. Tax");
    end;

    local procedure IsFullRMA(POSEntry: Record "NPR POS Entry"): Boolean
    var
        POSSalesLine: Record "NPR POS Entry Sales Line";
        POSRMALine: Record "NPR POS RMA Line";
    begin
        POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSSalesLine.SetRange(Type, POSSalesLine.Type::Item);
        if not POSSalesLine.FindSet() then
            exit(false);

        repeat
            POSRMALine.SetRange("POS Entry No.", POSEntry."Entry No.");
            POSRMALine.SetRange("Return Line No.", POSSalesLine."Line No.");
            if POSRMALine.IsEmpty then
                exit(false);
        until POSSalesLine.Next() = 0;

        exit(true);
    end;

    local procedure InsertDKPOSAuditLogAuxInfo(POSEntry: Record "NPR POS Entry"; POSStore: Record "NPR POS Store"; POSUnit: Record "NPR POS Unit")
    var
        DKPOSAuditLogAuxInfo: Record "NPR DK POS Audit Log Aux. Info";
    begin
        DKPOSAuditLogAuxInfo.Init();
        DKPOSAuditLogAuxInfo."Audit Entry Type" := DKPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry";
        DKPOSAuditLogAuxInfo."POS Entry No." := POSEntry."Entry No.";
        DKPOSAuditLogAuxInfo."Entry Date" := POSEntry."Entry Date";
        DKPOSAuditLogAuxInfo."POS Store Code" := POSStore.Code;
        DKPOSAuditLogAuxInfo."POS Unit No." := POSUnit."No.";
        DKPOSAuditLogAuxInfo."Source Document No." := POSEntry."Document No.";
        DKPOSAuditLogAuxInfo.Insert();
    end;

    #endregion

    #region DK Fiscal - Procedures/Helper Functions

#if not (BC17 or BC1800 or BC1801 or BC1802 or BC1803 or BC1804)
    local procedure LoadCertificate()
    var
        X509Certificate2: Codeunit X509Certificate2;
        InStr: InStream;
        Base64Cert: Text;
        Base64Cert2: Text;
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        PasswordSecretText: SecretText;
#ENDIF
    begin
        if not _CertificateLoaded then begin
            _DKFiscalizationSetup.SetAutoCalcFields("Signing Certificate");
            _DKFiscalizationSetup.Get();
            _DKFiscalizationSetup.TestField("Signing Certificate Thumbprint");
            _DKFiscalizationSetup.TestField("Signing Certificate Password");
            _DKFiscalizationSetup."Signing Certificate".CreateInStream(InStr, TextEncoding::UTF8);
            InStr.ReadText(Base64Cert);
            Base64Cert2 := Base64Cert; //Prevent below VAR from messing up the cert

#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
            PasswordSecretText := _DKFiscalizationSetup."Signing Certificate Password";
            if not X509Certificate2.VerifyCertificate(Base64Cert, PasswordSecretText, "X509 Content Type"::Cert) then
                exit;
            _SignatureKey.FromBase64String(Base64Cert2, PasswordSecretText, true);
#ELSE
            if not X509Certificate2.VerifyCertificate(Base64Cert, _DKFiscalizationSetup."Signing Certificate Password", "X509 Content Type"::Cert) then
                exit;
            _SignatureKey.FromBase64String(Base64Cert2, _DKFiscalizationSetup."Signing Certificate Password", true);
#ENDIF
            _CertificateLoaded := true;
        end;
    end;

    procedure VerifySignature(Data: Text; HashAlgo: Enum "Hash Algorithm"; SignatureBase64: Text): Boolean
    var
        ConvertBase64: Codeunit "Base64 Convert";
        CryptoMgt: Codeunit "Cryptography Management";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStr: OutStream;
    begin
        LoadCertificate();
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        ConvertBase64.FromBase64(SignatureBase64, OutStr);
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        exit(CryptoMgt.VerifyData(Data, _SignatureKey, HashAlgo, InStream));
    end;

    procedure SignData(BaseValue: Text): Text
    var
        ConvertBase64: Codeunit "Base64 Convert";
        CryptoMgt: Codeunit "Cryptography Management";
        TempBLOB: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
    begin
        TempBLOB.CreateOutStream(OutStr, TextEncoding::UTF8);
        CryptoMgt.SignData(BaseValue, _SignatureKey, Enum::"Hash Algorithm"::SHA256, OutStr);
        TempBLOB.CreateInStream(InStr, TextEncoding::UTF8);
        exit(ConvertBase64.ToBase64(InStr));
    end;

    procedure CalculateHash(BaseValue: Text): Text
    var
        CryptoMgt: Codeunit "Cryptography Management";
    begin
        exit(CryptoMgt.GenerateHashAsBase64String(BaseValue, 2));
    end;

    procedure ImportCertificate()
    var
        Base64Convert: Codeunit "Base64 Convert";
        FileMgt: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        X509Certificate2: Codeunit X509Certificate2;
        IStream: InStream;
        DialCaptionLbl: Label 'Upload Certificate';
        ExtFilterLbl: Label 'pfx';
        FileFilterLbl: Label 'Certificate File (*.PFX)|*.PFX';
        OStream: OutStream;
        Base64Cert: Text;
        Base64Cert2: Text;
        CertificateThumbprint: Text;
        FileName: Text;
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        PasswordSecretText: SecretText;
#ENDIF
    begin
        _DKFiscalizationSetup.Get();
        if _DKFiscalizationSetup."Signing Certificate".HasValue() then begin
            if not Confirm(OVERWRITE_CERT_Qst) then
                exit;
            Clear(_DKFiscalizationSetup."Signing Certificate");
        end;
        FileName := FileMgt.BLOBImportWithFilter(TempBlob, DialCaptionLbl, '', FileFilterLbl, ExtFilterLbl);

        if FileName = '' then
            exit;

        TempBlob.CreateInStream(IStream);
        Base64Cert := Base64Convert.ToBase64(IStream);
        Base64Cert2 := Base64Cert;

#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        PasswordSecretText := _DKFiscalizationSetup."Signing Certificate Password";
        X509Certificate2.VerifyCertificate(Base64Cert2, PasswordSecretText, Enum::"X509 Content Type"::Cert);
        if (not X509Certificate2.HasPrivateKey(Base64Cert, PasswordSecretText)) then
#ELSE
        X509Certificate2.VerifyCertificate(Base64Cert2, _DKFiscalizationSetup."Signing Certificate Password", Enum::"X509 Content Type"::Cert);
        if (not X509Certificate2.HasPrivateKey(Base64Cert, _DKFiscalizationSetup."Signing Certificate Password")) then
#ENDIF
            Error(MISSING_KEY_Err);

        _DKFiscalizationSetup."Signing Certificate".CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.Write(Base64Cert);

        CertificateThumbprint := _DKFiscalizationSetup."Signing Certificate Thumbprint";
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        X509Certificate2.GetCertificateThumbprint(Base64Cert, PasswordSecretText, CertificateThumbprint);
#ELSE
        X509Certificate2.GetCertificateThumbprint(Base64Cert, _DKFiscalizationSetup."Signing Certificate Password", CertificateThumbprint);
#ENDIF
#pragma warning disable AA0139
        _DKFiscalizationSetup."Signing Certificate Thumbprint" := CertificateThumbprint;
#pragma warning restore AA0139
        _DKFiscalizationSetup.Modify(true);

        Message(CERT_SUCCESS_Msg, _DKFiscalizationSetup."Signing Certificate Thumbprint");
    end;
#else
    local procedure LoadCertificate()
    var
        InStream: InStream;
        OutStream: OutStream;
        TempBlob: Codeunit "Temp Blob";
        MemoryStream: DotNet NPRNetMemoryStream;
        Base64Convert: Codeunit "Base64 Convert";
        Base64Cert: Text;
    begin
        if not _CertificateLoaded then begin
            _DKFiscalizationSetup.SetAutoCalcFields("Signing Certificate");
            _DKFiscalizationSetup.Get();
            _DKFiscalizationSetup.TestField("Signing Certificate Thumbprint");
            _DKFiscalizationSetup.TestField("Signing Certificate Password");
            _DKFiscalizationSetup."Signing Certificate".CreateInStream(InStream, TextEncoding::UTF8);
            InStream.ReadText(Base64Cert);
            TempBlob.CreateOutStream(OutStream);
            Base64Convert.FromBase64(Base64Cert, OutStream);
            MemoryStream := MemoryStream.MemoryStream();
            TempBlob.CreateInStream(InStream);
            CopyStream(MemoryStream, InStream);
            _X509Certificate2 := _X509Certificate2.X509Certificate2(MemoryStream.ToArray(), _DKFiscalizationSetup."Signing Certificate Password");
            _RSACryptoServiceProvider := _X509Certificate2.PrivateKey;
#if not (BC17 or BC1800 or BC1801 or BC1802 or BC1803 or BC1804)
            _SignatureKey.FromBase64String(Base64Cert2, _DKFiscalizationSetup."Signing Certificate Password", true);
#endif
            _CertificateLoaded := true;
        end;
    end;

    procedure VerifySignature(Data: Text; HashAlgo: Text; SignatureBase64: Text): Boolean
    var
        CryptoConfig: DotNet NPRNetCryptoConfig;
        Convert: DotNet NPRNetConvert;
        Encoding: DotNet NPRNetEncoding;
    begin
        LoadCertificate();
        exit(_RSACryptoServiceProvider.VerifyData(Encoding.UTF8.GetBytes(Data), CryptoConfig.MapNameToOID(HashAlgo), Convert.FromBase64String(SignatureBase64)));
    end;

    procedure SignData(BaseValue: Text): Text
    var
        CryptoConfig: DotNet NPRNetCryptoConfig;
        Convert: DotNet NPRNetConvert;
        Encoding: DotNet Encoding;
    begin
        exit(Convert.ToBase64String(_RSACryptoServiceProvider.SignData(Encoding.UTF8.GetBytes(BaseValue), CryptoConfig.MapNameToOID('SHA256'))));
    end;

    procedure CalculateHash(BaseValue: Text): Text
    var
        SHA256: DotNet NPRNetSHA256Managed;
        Encoding: DotNet NPRNetEncoding;
        Convert: DotNet NPRNetConvert;
    begin
        SHA256.Initialize();
        exit(Convert.ToBase64String(SHA256.ComputeHash(Encoding.Unicode.GetBytes(BaseValue))));
    end;

    procedure ImportCertificate()
    var
        IStream: InStream;
        OStream: OutStream;
        Base64Cert: Text;
        Base64Cert2: Text;
        X509Certificate2: Codeunit X509Certificate2;
        Base64Convert: Codeunit "Base64 Convert";
        FileMgt: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        DialCaptionLbl: Label 'Upload Certificate';
        FileFilterLbl: Label 'Certificate File (*.PFX)|*.PFX';
        ExtFilterLbl: Label 'pfx';
        FileName: Text;
        CertificateThumbprint: Text;
    begin
        _DKFiscalizationSetup.Get();
        if _DKFiscalizationSetup."Signing Certificate".HasValue() then begin
            if not Confirm(OVERWRITE_CERT_Qst) then
                exit;
            Clear(_DKFiscalizationSetup."Signing Certificate");
        end;
        FileName := FileMgt.BLOBImportWithFilter(TempBlob, DialCaptionLbl, '', FileFilterLbl, ExtFilterLbl);

        if FileName = '' then
            exit;

        TempBlob.CreateInStream(IStream);
        Base64Cert := Base64Convert.ToBase64(IStream);
        Base64Cert2 := Base64Cert;

        X509Certificate2.VerifyCertificate(Base64Cert2, _DKFiscalizationSetup."Signing Certificate Password", Enum::"X509 Content Type"::Cert);
        if (not X509Certificate2.HasPrivateKey(Base64Cert, _DKFiscalizationSetup."Signing Certificate Password")) then
            Error(MISSING_KEY_Err);

        _DKFiscalizationSetup."Signing Certificate".CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.Write(Base64Cert);

        CertificateThumbprint := _DKFiscalizationSetup."Signing Certificate Thumbprint";
        X509Certificate2.GetCertificateThumbprint(Base64Cert, _DKFiscalizationSetup."Signing Certificate Password", CertificateThumbprint);
#pragma warning disable AA0139
        _DKFiscalizationSetup."Signing Certificate Thumbprint" := CertificateThumbprint;
#pragma warning restore AA0139
        _DKFiscalizationSetup.Modify(true);

        Message(CERT_SUCCESS_Msg, _DKFiscalizationSetup."Signing Certificate Thumbprint");
    end;
#endif

    internal procedure IsDKFiscalActive(): Boolean
    var
        DKFiscalSetup: Record "NPR DK Fiscalization Setup";
    begin
        if DKFiscalSetup.Get() then
            exit(DKFiscalSetup."Enable DK Fiscal");
    end;

    internal procedure IsDKAuditEnabled(POSAuditProfileCode: Code[20]): Boolean
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin
        if not POSAuditProfile.Get(POSAuditProfileCode) then
            exit(false);
        if POSAuditProfile."Audit Handler" <> HandlerCode() then
            exit(false);
        if _Initialized then
            exit(_Enabled);
        _Initialized := true;
        _Enabled := true;
        exit(true);
    end;

    internal procedure HandlerCode(): Text[20]
    var
        HandlerCodeTxt: Label 'DK_SKAT', Locked = true, MaxLength = 20;
    begin
        exit(HandlerCodeTxt);
    end;

    local procedure OnActionShowSetup()
    var
        DKFiscalizationSetup: Page "NPR DK Fiscalization Setup";
    begin
        DKFiscalizationSetup.RunModal();
    end;

    local procedure ErrorOnRenameOfPOSStoreIfAlreadyUsed(OldPOSStore: Record "NPR POS Store")
    var
        DKPOSAuditLogAuxInfo: Record "NPR DK POS Audit Log Aux. Info";
        CannotRenameErr: Label 'You cannot rename %1 %2 since there is at least one related %3 record and it can cause data discrepancy since it is being used for digital signature.', Comment = '%1 - POS Store table caption, %2 - POS Store Code value, %3 - DK POS Audit Log Aux. Info table caption';
    begin
        if not IsDKFiscalActive() then
            exit;

        DKPOSAuditLogAuxInfo.SetRange("POS Store Code", OldPOSStore.Code);
        if not DKPOSAuditLogAuxInfo.IsEmpty() then
            Error(CannotRenameErr, OldPOSStore.TableCaption(), OldPOSStore.Code, DKPOSAuditLogAuxInfo.TableCaption());
    end;

    local procedure ErrorOnRenameOfPOSUnitIfAlreadyUsed(OldPOSUnit: Record "NPR POS Unit")
    var
        DKPOSAuditLogAuxInfo: Record "NPR DK POS Audit Log Aux. Info";
        CannotRenameErr: Label 'You cannot rename %1 %2 since there is at least one related %3 record and it can cause data discrepancy since it is being used for digital signature.', Comment = '%1 - POS Unit table caption, %2 - POS Unit No. value, %3 - DK POS Audit Log Aux. Info table caption';
    begin
        if not IsDKAuditEnabled(OldPOSUnit."POS Audit Profile") then
            exit;

        DKPOSAuditLogAuxInfo.SetRange("POS Unit No.", OldPOSUnit."No.");
        if not DKPOSAuditLogAuxInfo.IsEmpty() then
            Error(CannotRenameErr, OldPOSUnit.TableCaption(), OldPOSUnit."No.", DKPOSAuditLogAuxInfo.TableCaption());
    end;
    #endregion

    local procedure UpdatePriceChangedLine(POSSaleLine: Record "NPR POS Sale Line"; EntryType: Text)
    var
        POSAuditLog: Record "NPR POS Audit Log";
    begin
        POSAuditLog.SetLoadFields("Additional Information");
        POSAuditLog.SetCurrentKey("Acted on POS Unit No.", "Action Type");
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::PRICE_CHANGE);
        POSAuditLog.SetRange("Table ID", Database::"NPR POS Sale Line");
        POSAuditLog.SetRange("Record ID", POSSaleLine.RecordId);

        if not POSAuditLog.FindFirst() then
            exit;

        POSAuditLog."Additional Information" += ':' + EntryType;
        POSAuditLog.Modify();
    end;
}