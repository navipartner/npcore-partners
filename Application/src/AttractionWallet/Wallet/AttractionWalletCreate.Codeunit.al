codeunit 6185076 "NPR AttractionWalletCreate"
{
    TableNo = "NPR POS Sale";
    Access = Internal;

    trigger OnRun()
    var
        Wallet: Codeunit "NPR AttractionWallet";
    begin
        if (not Wallet.IsWalletEnabled()) then
            exit;

        CreateWalletAssets(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnBeforeEndSale', '', true, true)]
    local procedure OnBeforeEndSale(var Sender: Codeunit "NPR POS Sale"; SaleHeader: Record "NPR POS Sale")
    var
        Wallet: Codeunit "NPR AttractionWallet";
    begin
        if (not Wallet.IsWalletEnabled()) then
            exit;

        CreateWalletAssets(SaleHeader);
    end;

    local procedure CreateWalletAssets(POSSale: Record "NPR POS Sale")
    var
        WalletAssetMgt: Codeunit "NPR AttractionWallet";
        POSSaleLine: Record "NPR POS Sale Line";
    begin
        POSSaleLine.SetCurrentKey("Register No.", "Sales Ticket No.");
        POSSaleLine.SetFilter("Register No.", '=%1', POSSale."Register No.");
        POSSaleLine.SetFilter("Sales Ticket No.", '=%1', POSSale."Sales Ticket No.");
        if (POSSaleLine.FindSet()) then begin
            repeat
                WalletAssetMgt.CreateAssetsFromPosSaleLine(POSSale, POSSaleLine);
            until (POSSaleLine.Next() = 0);
        end;
    end;

}