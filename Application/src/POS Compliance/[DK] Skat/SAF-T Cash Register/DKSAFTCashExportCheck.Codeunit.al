codeunit 6184671 "NPR DK SAF-T Cash Export Check"
{
    Access = Internal;
    TableNo = "NPR DK SAF-T Cash Exp. Header";

    trigger OnRun()
    var
        DKFiscalizationSetup: Record "NPR DK Fiscalization Setup";
        ErrorMessageManagement: Codeunit "Error Message Management";
    begin
        Rec.TestField("Starting Date");
        Rec.TestField("Ending Date");
        DKFiscalizationSetup.Get();
        If DKFiscalizationSetup."SAF-T Contact No." = '' then
            ErrorMessageManagement.LogErrorMessage(
                0, StrSubstNo(FieldValueIsNotSpecifiedErr, DKFiscalizationSetup.FieldCaption("SAF-T Contact No.")),
                DKFiscalizationSetup, DKFiscalizationSetup.FieldNo("SAF-T Contact No."), '');
    end;

    var
        FieldValueIsNotSpecifiedErr: Label '%1 is not specified';

    internal procedure GetSKATValidationWarnings(SAFTExportHeader: Record "NPR DK SAF-T Cash Exp. Header"; var Warnings: List of [Text])
    var
        DKFiscalizationSetup: Record "NPR DK Fiscalization Setup";
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        DKAuditMgt: Codeunit "NPR DK Audit Mgt.";
        GenSAFTCashFile: Codeunit "NPR DK Gen. SAF-T Cash File";
        VATCodeIsZeroRated: Dictionary of [Code[20], Boolean];
        ReportedVATCodes: List of [Code[20]];
        ReportedVATSetups: List of [Text];
        IsDKAudited: Boolean;
    begin
        if not DKFiscalizationSetup.Get() then
            exit;

        if not POSUnit.FindSet() then
            exit;
        repeat
            // The file holds the fiscal sales of every POS unit, so the VAT codes are checked on all of them. Only DK audited units sign their sales.
            IsDKAudited := DKAuditMgt.IsDKAuditEnabled(POSUnit."POS Audit Profile");
            POSEntry.SetCurrentKey("POS Store Code", "POS Unit No.");
            POSEntry.SetRange("POS Store Code", POSUnit."POS Store Code");
            POSEntry.SetRange("POS Unit No.", POSUnit."No.");
            POSEntry.SetRange("Entry Date", SAFTExportHeader."Starting Date", SAFTExportHeader."Ending Date");
            POSEntry.SetFilter("Entry Type", '%1|%2', POSEntry."Entry Type"::"Credit Sale", POSEntry."Entry Type"::"Direct Sale");
            POSEntry.SetFilter("Fiscal No.", '<>%1', '');
            if POSEntry.FindSet() then
                repeat
                    if IsDKAudited then begin
                        CheckSignature(POSEntry, DKFiscalizationSetup, Warnings);
                        CheckPaymentReferences(POSEntry, GenSAFTCashFile, Warnings);
                    end;
                    CheckVATCodes(POSEntry, VATCodeIsZeroRated, ReportedVATCodes, ReportedVATSetups, Warnings);
                until POSEntry.Next() = 0;
        until POSUnit.Next() = 0;
    end;

    local procedure CheckSignature(POSEntry: Record "NPR POS Entry"; DKFiscalizationSetup: Record "NPR DK Fiscalization Setup"; var Warnings: List of [Text])
    var
        POSAuditLog: Record "NPR POS Audit Log";
        NotSignedLbl: Label '%1 %2 has no digital signature.', Comment = '%1 = POS Entry table caption, %2 = fiscal number';
        ReplacedCertificateLbl: Label '%1 %2 was signed with a certificate that is no longer in %3, so the certificate cannot be exported with it.', Comment = '%1 = POS Entry table caption, %2 = fiscal number, %3 = DK Fiscalization Setup table caption';
    begin
        POSAuditLog.SetRange("Acted on POS Entry No.", POSEntry."Entry No.");
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::DIRECT_SALE_END);
        POSAuditLog.SetLoadFields("Certificate Thumbprint");
        POSAuditLog.SetAutoCalcFields("Electronic Signature");
        if not POSAuditLog.FindFirst() then begin
            Warnings.Add(StrSubstNo(NotSignedLbl, POSEntry.TableCaption(), POSEntry."Fiscal No."));
            exit;
        end;
        if not POSAuditLog."Electronic Signature".HasValue() then begin
            Warnings.Add(StrSubstNo(NotSignedLbl, POSEntry.TableCaption(), POSEntry."Fiscal No."));
            exit;
        end;
        if POSAuditLog."Certificate Thumbprint" <> DKFiscalizationSetup."Signing Certificate Thumbprint" then
            Warnings.Add(StrSubstNo(ReplacedCertificateLbl, POSEntry.TableCaption(), POSEntry."Fiscal No.", DKFiscalizationSetup.TableCaption()));
    end;

    local procedure CheckPaymentReferences(POSEntry: Record "NPR POS Entry"; var GenSAFTCashFile: Codeunit "NPR DK Gen. SAF-T Cash File"; var Warnings: List of [Text])
    var
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        MissingPaymentReferenceLbl: Label '%1 %2 has a %3 payment without the payment terminal reference.', Comment = '%1 = POS Entry table caption, %2 = fiscal number, %3 = POS payment method code';
    begin
        POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntryPaymentLine.SetLoadFields("POS Payment Method Code");
        if POSEntryPaymentLine.FindSet() then
            repeat
                if GenSAFTCashFile.IsPaymentReferenceRequired(POSEntryPaymentLine."POS Payment Method Code") then
                    if GenSAFTCashFile.GetEFTTransactionID(POSEntry, POSEntryPaymentLine) = '' then
                        Warnings.Add(StrSubstNo(MissingPaymentReferenceLbl, POSEntry.TableCaption(), POSEntry."Fiscal No.", POSEntryPaymentLine."POS Payment Method Code"));
            until POSEntryPaymentLine.Next() = 0;
    end;

    local procedure CheckVATCodes(POSEntry: Record "NPR POS Entry"; var VATCodeIsZeroRated: Dictionary of [Code[20], Boolean]; var ReportedVATCodes: List of [Code[20]]; var ReportedVATSetups: List of [Text]; var Warnings: List of [Text])
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetFilter(Type, '<>%1&<>%2', POSEntrySalesLine.Type::Comment, POSEntrySalesLine.Type::Rounding);
        POSEntrySalesLine.SetLoadFields("VAT Identifier", "VAT %", "VAT Bus. Posting Group", "VAT Prod. Posting Group");
        if POSEntrySalesLine.FindSet() then
            repeat
                if POSEntrySalesLine."VAT Identifier" <> '' then
                    CheckVATCodeRate(POSEntrySalesLine, VATCodeIsZeroRated, ReportedVATCodes, Warnings)
                else
                    // Customer deposits and vouchers have no VAT setup, so only lines taxed through a VAT posting setup need a VAT identifier.
                    if POSEntrySalesLine."VAT Prod. Posting Group" <> '' then
                        CheckVATIdentifierIsSet(POSEntrySalesLine, ReportedVATSetups, Warnings);
            until POSEntrySalesLine.Next() = 0;
    end;

    local procedure CheckVATCodeRate(POSEntrySalesLine: Record "NPR POS Entry Sales Line"; var VATCodeIsZeroRated: Dictionary of [Code[20], Boolean]; var ReportedVATCodes: List of [Code[20]]; var Warnings: List of [Text])
    var
        VATCodeWithSeveralRatesLbl: Label '%1 %2 is used for both zero-rated and VAT-liable lines, so the SAF-T file cannot map it to one standard VAT code. Give each VAT rate its own %1.', Comment = '%1 = VAT Identifier field caption, %2 = VAT identifier';
        IsZeroRated: Boolean;
    begin
        // SKAT's standard VAT codes are 1 (25 %) and 0 (0 %), and Business Central only keeps one VAT % per VAT identifier within a VAT business posting group.
        IsZeroRated := POSEntrySalesLine."VAT %" = 0;
        if not VATCodeIsZeroRated.ContainsKey(POSEntrySalesLine."VAT Identifier") then begin
            VATCodeIsZeroRated.Add(POSEntrySalesLine."VAT Identifier", IsZeroRated);
            exit;
        end;
        if (VATCodeIsZeroRated.Get(POSEntrySalesLine."VAT Identifier") <> IsZeroRated) and not ReportedVATCodes.Contains(POSEntrySalesLine."VAT Identifier") then begin
            ReportedVATCodes.Add(POSEntrySalesLine."VAT Identifier");
            Warnings.Add(StrSubstNo(VATCodeWithSeveralRatesLbl, POSEntrySalesLine.FieldCaption("VAT Identifier"), POSEntrySalesLine."VAT Identifier"));
        end;
    end;

    local procedure CheckVATIdentifierIsSet(POSEntrySalesLine: Record "NPR POS Entry Sales Line"; var ReportedVATSetups: List of [Text]; var Warnings: List of [Text])
    var
        VATPostingSetup: Record "VAT Posting Setup";
        VATSetupWithoutIdentifierLbl: Label 'Lines with %1 %2 and %3 %4 have no %5, so the SAF-T file cannot declare their VAT code. Set a %5 on that %6.', Comment = '%1 = VAT Bus. Posting Group field caption, %2 = VAT business posting group, %3 = VAT Prod. Posting Group field caption, %4 = VAT product posting group, %5 = VAT Identifier field caption, %6 = VAT Posting Setup table caption';
        VATSetupKey: Text;
    begin
        // The line gets no vatCode, and when no exported line has one, the mandatory vatCodeDetails section is left out of the file.
        VATSetupKey := POSEntrySalesLine."VAT Bus. Posting Group" + '|' + POSEntrySalesLine."VAT Prod. Posting Group";
        if ReportedVATSetups.Contains(VATSetupKey) then
            exit;
        ReportedVATSetups.Add(VATSetupKey);
        Warnings.Add(StrSubstNo(VATSetupWithoutIdentifierLbl,
            POSEntrySalesLine.FieldCaption("VAT Bus. Posting Group"), POSEntrySalesLine."VAT Bus. Posting Group",
            POSEntrySalesLine.FieldCaption("VAT Prod. Posting Group"), POSEntrySalesLine."VAT Prod. Posting Group",
            POSEntrySalesLine.FieldCaption("VAT Identifier"), VATPostingSetup.TableCaption()));
    end;
}
