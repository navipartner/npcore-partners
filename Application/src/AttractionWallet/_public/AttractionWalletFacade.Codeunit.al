codeunit 6185061 "NPR AttractionWalletFacade"
{

    procedure PrintWallet(WalletEntryNoList: List of [Integer]; PrintContext: Enum "NPR WalletPrintType");
    var
        Wallet: Codeunit "NPR AttractionWallet";
    begin
        Wallet.PrintWallets(WalletEntryNoList, PrintContext);
    end;

    procedure IncrementPrintCount(WalletEntryNo: Integer)
    var
        Setup: Record "NPR WalletAssetSetup";
    begin
        if (not Setup.Get()) then
            Setup.Init();

        IncrementPrintCount(WalletEntryNo, Setup.UpdateAssetPrintedInformation);
    end;

    procedure IncrementPrintCount(WalletEntryNo: Integer; CascadeUpdateAssets: Boolean)
    var
        Wallet: Codeunit "NPR AttractionWallet";
    begin
        Wallet.IncrementPrintCount(WalletEntryNo, CascadeUpdateAssets);
    end;

    // This event allows PTE to control the printing of the wallet - set Handled to true to prevent the wallet from being printed by the standard code
    [IntegrationEvent(false, false)]
    internal procedure OnPrint(WalletEntryNoList: List of [Integer]; PrintContext: Enum "NPR WalletPrintType"; var Handled: Boolean);
    begin
    end;


    procedure CreateWallet(Name: Text[100]; var WalletReferenceNumber: Text[50]) WalletEntryNo: Integer
    begin
        WalletEntryNo := CreateWallet('', Name, WalletReferenceNumber);
    end;

    procedure CreateWallet(OriginatesFromItemNo: Code[20]; Name: Text[100]; var WalletReferenceNumber: Text[50]) WalletEntryNo: Integer
    var
        WalletManagement: Codeunit "NPR AttractionWallet";
    begin
        WalletEntryNo := WalletManagement.CreateWalletFromFacade(OriginatesFromItemNo, Name, WalletReferenceNumber);
    end;

    procedure CreateWallet(OriginatesFromItemNo: Code[20]; Name: Text[100]; var WalletReferenceNumber: Text[50]; ExternalReferenceNumber: Text[100]) WalletEntryNo: Integer
    var
        WalletManagement: Codeunit "NPR AttractionWallet";
    begin
        WalletEntryNo := WalletManagement.CreateWalletFromFacade(OriginatesFromItemNo, Name, WalletReferenceNumber, ExternalReferenceNumber);
    end;

    procedure ExpireWallet(WalletEntryNo: Integer)
    var
        WalletManagement: Codeunit "NPR AttractionWallet";
    begin
        WalletManagement.ExpireWallet(WalletEntryNo);
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

    procedure AddCouponsToWallets(WalletEntryNo: Integer; CouponIds: List of [Guid]; ItemNo: Code[20]; DocumentNumber: Code[20])
    var
        WalletManagement: Codeunit "NPR AttractionWallet";
    begin
        WalletManagement.AddCouponsToWallet(WalletEntryNo, CouponIds, ItemNo, DocumentNumber);
    end;

    procedure AddVouchersToWallets(WalletEntryNo: Integer; VoucherIds: List of [Guid]; ItemNo: Code[20]; DocumentNumber: Code[20])
    var
        WalletManagement: Codeunit "NPR AttractionWallet";
    begin
        WalletManagement.AddVouchersToWallet(WalletEntryNo, VoucherIds, ItemNo, DocumentNumber);
    end;

    procedure SetWalletReferenceNumber(WalletEntryNo: Integer; TableId: Integer; SystemId: Guid; Reference: Text[100])
    var
        WalletManagement: Codeunit "NPR AttractionWallet";
    begin
        WalletManagement.AddHeaderReference(WalletEntryNo, TableId, SystemId, Reference);
    end;

    procedure SetWalletExternalReference(WalletEntryNo: Integer; ExternalReference: Text[100]; BlockExisting: Boolean): Boolean
    var
        WalletManagement: Codeunit "NPR AttractionWallet";
    begin
        exit(WalletManagement.SetWalletExternalReference(WalletEntryNo, ExternalReference, BlockExisting));
    end;

    procedure UpdateEmailAddressOnAllWallets(FromEmail: Text[100]; ToEmail: Text[100])
    var
        WalletManagement: Codeunit "NPR AttractionWallet";
    begin
        WalletManagement.UpdateEmailAddressOnAllWallets(FromEmail, ToEmail);
    end;

    procedure GetWalletAssets(WalletReferenceNumber: Text[100]; var WalletAssets: Query "NPR AttractionWalletAssets")
    begin
        WalletAssets.SetFilter(WalletAssets.WalletReferenceNumber, '=%1', WalletReferenceNumber);
        WalletAssets.Open();
    end;

    procedure FindWalletByReferenceNumber(ReferenceNumber: Text[100]; var Wallets: Query "NPR FindAttractionWallets")
    var
        WalletExternalReference: Record "NPR AttractionWalletExtRef";
        Wallet: Record "NPR AttractionWallet";
    begin
        WalletExternalReference.SetLoadFields(WalletEntryNo);
        WalletExternalReference.SetFilter(ExternalReference, '=%1', ReferenceNumber);
        WalletExternalReference.SetFilter(BlockedAt, '=%1', 0DT);
        WalletExternalReference.SetFilter(ExpiresAt, '>%1|=%2', CurrentDateTime(), 0DT);
        if (WalletExternalReference.FindFirst()) then begin
            Wallet.Get(WalletExternalReference.WalletEntryNo);
            Wallets.SetFilter(Wallets.ReferenceNumber, '=%1', Wallet.ReferenceNumber);
        end else
            Wallets.SetFilter(Wallets.ReferenceNumber, '=%1', ReferenceNumber);

        Wallets.SetFilter(Wallets.ExpirationDate, '>%1|=%2', CurrentDateTime(), 0DT);
        Wallets.Open();
    end;

    procedure OpenWalletCardPage(ExternalReferenceNo: Text[100])
    var
        AttractionWalletExtRef: Record "NPR AttractionWalletExtRef";
        Wallet: Record "NPR AttractionWallet";
    begin
        if not (AttractionWalletExtRef.Get(ExternalReferenceNo)) then
            exit;

        if not (Wallet.Get(AttractionWalletExtRef.WalletEntryNo)) then
            exit;

        Page.Run(Page::"NPR AttractionWalletCard", Wallet);
    end;

    procedure GetOriginatesFromItemNo(WalletEntryNo: Integer; var OriginatesFromItemNo: Code[20]): Boolean
    var
        Wallet: Record "NPR AttractionWallet";
    begin
        if (not Wallet.Get(WalletEntryNo)) then
            exit(false);

        OriginatesFromItemNo := Wallet.OriginatesFromItemNo;
        exit(true);
    end;

    procedure GetDesignerTemplate(WalletEntryNo: Integer; var TemplateLabel: Text[80]; var TemplateId: Text[40]): Boolean
    var
        WalletManagement: Codeunit "NPR AttractionWallet";
    begin
        exit(WalletManagement.GetDesignerTemplate(WalletEntryNo, TemplateLabel, TemplateId));
    end;
}