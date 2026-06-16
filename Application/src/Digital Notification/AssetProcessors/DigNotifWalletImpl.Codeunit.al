#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6248205 "NPR DigNotif Wallet Impl" implements "NPR IDigNotifAssetProcessor"
{
    Access = Internal;

    procedure ProcessAsset(var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary; var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary; var Context: Codeunit "NPR DigNotif Manifest Context")
    var
        WalletAssetHeaderRef: Record "NPR WalletAssetHeaderReference";
        WalletAssetHeader: Record "NPR WalletAssetHeader";
        WalletAssetLine: Record "NPR WalletAssetLine";
        Wallet: Record "NPR AttractionWallet";
    begin
        // Wallet asset emission is Ecom-exclusive.
        // For Magento/Shopify, wallets are not part of the digital notification manifest by product decision.
        if TempHeaderBuffer."Document Type" <> TempHeaderBuffer."Document Type"::"Ecom Sales Document" then
            exit;

        WalletAssetHeaderRef.SetCurrentKey(LinkToTableId, LinkToSystemId);
        WalletAssetHeaderRef.SetRange(LinkToTableId, Database::"NPR Ecom Sales Line");
        WalletAssetHeaderRef.SetRange(LinkToSystemId, TempLineBuffer."Source Line System Id");
        if not WalletAssetHeaderRef.FindSet() then
            exit;

        repeat
            if WalletAssetHeader.Get(WalletAssetHeaderRef.WalletHeaderEntryNo) then begin
                WalletAssetLine.SetCurrentKey(TransactionId);
                WalletAssetLine.SetRange(TransactionId, WalletAssetHeader.TransactionId);
                WalletAssetLine.SetRange(Type, WalletAssetLine.Type::WALLET);
                if WalletAssetLine.FindSet() then
                    repeat
                        if Wallet.GetBySystemId(WalletAssetLine.LineTypeSystemId) then
                            TryAddWalletAssetToManifest(Wallet, Context);
                    until WalletAssetLine.Next() = 0;
            end;
        until WalletAssetHeaderRef.Next() = 0;
    end;

    local procedure TryAddWalletAssetToManifest(
        Wallet: Record "NPR AttractionWallet";
        var Context: Codeunit "NPR DigNotif Manifest Context"): Boolean
    var
        AttractionWallet: Codeunit "NPR AttractionWallet";
        NPDesignerManifestFacade: Codeunit "NPR NPDesignerManifestFacade";
        TemplateLabel: Text[80];
        TemplateId: Text[40];
    begin
        if not AttractionWallet.GetDesignerTemplate(Wallet.EntryNo, TemplateLabel, TemplateId) then
            exit(false);

        NPDesignerManifestFacade.AddAssetToManifest(
            Context.ManifestId(),
            Database::"NPR AttractionWallet",
            Wallet.SystemId,
            Wallet.ReferenceNumber,
            TemplateId);
        Context.RegisterAsset();
        exit(true);
    end;
}
#endif
