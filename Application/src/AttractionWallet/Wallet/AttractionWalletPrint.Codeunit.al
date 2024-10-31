codeunit 6185077 "NPR AttractionWalletPrint"
{
    TableNo = "NPR POS Sale";
    Access = Internal;

    trigger OnRun()
    var
        Wallet: Codeunit "NPR AttractionWallet";
    begin
        if (not Wallet.IsEndOfSalePrintEnabled()) then
            exit;

        Wallet.PrintWallets(Database::"NPR POS Entry", Rec.SystemId, Enum::"NPR WalletPrintType"::END_OF_SALE);
    end;
}