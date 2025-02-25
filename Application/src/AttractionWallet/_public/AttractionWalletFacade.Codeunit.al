codeunit 6185061 "NPR AttractionWalletFacade"
{

    procedure PrintWallet(WalletEntryNoList: List of [Integer]; PrintContext: Enum "NPR WalletPrintType");
    var
        Wallet: Codeunit "NPR AttractionWallet";
    begin
        Wallet.PrintWallets(WalletEntryNoList, PrintContext);
    end;


    // This event allows PTE to control the printing of the wallet - set Handled to true to prevent the wallet from being printed by the standard code
    [IntegrationEvent(false, false)]
    internal procedure OnPrint(WalletEntryNoList: List of [Integer]; PrintContext: Enum "NPR WalletPrintType"; var Handled: Boolean);
    begin
    end;


    procedure CreateWallet(Name: Text[100]; var WalletReferenceNumber: Text[50]) WalletEntryNo: Integer
    var
        WalletManagement: Codeunit "NPR AttractionWallet";
    begin
        WalletEntryNo := WalletManagement.CreateWalletFromFacade(Name, WalletReferenceNumber);
    end;

    procedure AddTicketsToWallet(WalletEntryNo: Integer; TicketIds: List of [Guid])
    var
        WalletManagement: Codeunit "NPR AttractionWallet";
    begin
        WalletManagement.AddTicketsToWallet(WalletEntryNo, TicketIds);
    end;

    procedure AddMemberCardsToWallet(WalletEntryNo: Integer; MemberCardIds: List of [Guid])
    var
        WalletManagement: Codeunit "NPR AttractionWallet";
    begin
        WalletManagement.AddMemberCardsToWallet(WalletEntryNo, MemberCardIds);
    end;

    procedure SetWalletReferenceNumber(WalletEntryNo: Integer; TableId: Integer; SystemId: Guid; Reference: Text[100])
    var
        WalletManagement: Codeunit "NPR AttractionWallet";
    begin
        WalletManagement.AddHeaderReference(WalletEntryNo, TableId, SystemId, Reference);
    end;

    procedure GetWalletAssets(WalletReferenceNumber: Text[100]; var WalletAssets: Query "NPR AttractionWalletAssets")
    begin
        WalletAssets.SetFilter(WalletAssets.WalletReferenceNumber, '=%1', WalletReferenceNumber);
        WalletAssets.Open();
    end;

    procedure FindWalletByReferenceNumber(ReferenceNumber: Text[100]; var Wallets: Query "NPR FindAttractionWallets")
    begin
        Wallets.SetFilter(Wallets.ReferenceNumber, '=%1', ReferenceNumber);
        Wallets.Open();
    end;

}