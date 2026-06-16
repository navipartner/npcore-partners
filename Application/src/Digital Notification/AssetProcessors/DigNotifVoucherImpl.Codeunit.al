#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6248199 "NPR DigNotif Voucher Impl" implements "NPR IDigNotifAssetProcessor"
{
    Access = Internal;

    procedure ProcessAsset(var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary; var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary; var Context: Codeunit "NPR DigNotif Manifest Context")
    var
        NpRvVoucherEntry: Record "NPR NpRv Voucher Entry";
        EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        NPDesignerManifestFacade: Codeunit "NPR NPDesignerManifestFacade";
        DigitalNotifSetup: Record "NPR Digital Notification Setup";
    begin
        DigitalNotifSetup := Context.Setup();
        if DigitalNotifSetup."Exclude Vouchers From Manifest" then
            exit;

        if TempHeaderBuffer."Document Type" = TempHeaderBuffer."Document Type"::"Ecom Sales Document" then begin
            EcomSalesVoucherLink.SetCurrentKey("Source System Id", "Source Line System Id");
            EcomSalesVoucherLink.SetRange("Source System Id", TempHeaderBuffer."Source Document Id");
            EcomSalesVoucherLink.SetRange("Source Line System Id", TempLineBuffer."Source Line System Id");
            EcomSalesVoucherLink.SetRange("Voucher State", EcomSalesVoucherLink."Voucher State"::Active);
            if EcomSalesVoucherLink.FindSet() then begin
                repeat
                    if NpRvVoucher.GetBySystemId(EcomSalesVoucherLink."Voucher System Id") then begin
                        NpRvVoucherType.SetLoadFields(PDFDesignerTemplateId);
                        if NpRvVoucherType.Get(NpRvVoucher."Voucher Type") and (NpRvVoucherType.PDFDesignerTemplateId <> '') then begin
                            NPDesignerManifestFacade.AddAssetToManifest(
                                Context.ManifestId(),
                                Database::"NPR NpRv Voucher",
                                NpRvVoucher.SystemId,
                                EcomSalesVoucherLink."Reference No.",
                                NpRvVoucherType.PDFDesignerTemplateId);
                            Context.RegisterAsset();
                        end;
                    end;
                until EcomSalesVoucherLink.Next() = 0;
                exit;
            end;
            // Legacy fallback for ecom docs created before the link table existed.
            // Active-only by design — archived legacy vouchers are intentionally skipped from the manifest.
            NpRvVoucher.SetLoadFields("Voucher Type", SystemId, "Reference No.");
            if NpRvVoucher.Get(TempLineBuffer."No.") then begin
                NpRvVoucherType.SetLoadFields(PDFDesignerTemplateId);
                if NpRvVoucherType.Get(NpRvVoucher."Voucher Type") and (NpRvVoucherType.PDFDesignerTemplateId <> '') then begin
                    NPDesignerManifestFacade.AddAssetToManifest(
                        Context.ManifestId(),
                        Database::"NPR NpRv Voucher",
                        NpRvVoucher.SystemId,
                        NpRvVoucher."Reference No.",
                        NpRvVoucherType.PDFDesignerTemplateId);
                    Context.RegisterAsset();
                end;
            end;
            exit;
        end;

        // Invoice / Credit Memo: find vouchers via voucher entries
        NpRvVoucherEntry.SetCurrentKey("Entry Type", "Document Type", "Document No.");
        NpRvVoucherEntry.SetFilter("Entry Type", '%1|%2',
            NpRvVoucherEntry."Entry Type"::"Issue Voucher",
            NpRvVoucherEntry."Entry Type"::"Top-up");

        case TempHeaderBuffer."Document Type" of
            TempHeaderBuffer."Document Type"::Invoice:
                NpRvVoucherEntry.SetRange("Document Type", NpRvVoucherEntry."Document Type"::Invoice);
            TempHeaderBuffer."Document Type"::"Credit Memo":
                NpRvVoucherEntry.SetRange("Document Type", NpRvVoucherEntry."Document Type"::"Credit Memo");
        end;

        NpRvVoucherEntry.SetRange("Document No.", TempHeaderBuffer."Posted Document No.");
        NpRvVoucherEntry.SetRange("Document Line No.", TempLineBuffer."Line No.");
        if not NpRvVoucherEntry.FindSet() then
            exit;

        repeat
            NpRvVoucher.SetLoadFields("Voucher Type", SystemId, "Reference No.");
            if NpRvVoucher.Get(NpRvVoucherEntry."Voucher No.") then begin
                NpRvVoucherType.SetLoadFields(PDFDesignerTemplateId);
                if NpRvVoucherType.Get(NpRvVoucher."Voucher Type") and (NpRvVoucherType.PDFDesignerTemplateId <> '') then begin
                    NPDesignerManifestFacade.AddAssetToManifest(
                        Context.ManifestId(),
                        Database::"NPR NpRv Voucher",
                        NpRvVoucher.SystemId,
                        NpRvVoucher."Reference No.",
                        NpRvVoucherType.PDFDesignerTemplateId
                    );
                    Context.RegisterAsset();
                end;
            end;
        until NpRvVoucherEntry.Next() = 0;
    end;
}
#endif
