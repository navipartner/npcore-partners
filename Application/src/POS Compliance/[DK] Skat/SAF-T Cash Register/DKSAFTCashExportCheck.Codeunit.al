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
    begin
        if not DKFiscalizationSetup.Get() then
            exit;

        if not POSUnit.FindSet() then
            exit;
        repeat
            if DKAuditMgt.IsDKAuditEnabled(POSUnit."POS Audit Profile") then begin
                POSEntry.SetCurrentKey("POS Store Code", "POS Unit No.");
                POSEntry.SetRange("POS Unit No.", POSUnit."No.");
                POSEntry.SetRange("Entry Date", SAFTExportHeader."Starting Date", SAFTExportHeader."Ending Date");
                POSEntry.SetFilter("Entry Type", '%1|%2', POSEntry."Entry Type"::"Credit Sale", POSEntry."Entry Type"::"Direct Sale");
                POSEntry.SetFilter("Fiscal No.", '<>%1', '');
                if POSEntry.FindSet() then
                    repeat
                        CheckSignature(POSEntry, DKFiscalizationSetup, Warnings);
                        CheckPaymentReferences(POSEntry, GenSAFTCashFile, Warnings);
                    until POSEntry.Next() = 0;
            end;
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
}
