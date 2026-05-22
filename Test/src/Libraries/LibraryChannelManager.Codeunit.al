codeunit 85254 "NPR Library Channel Manager"
{
    Access = Internal;

    // Helpers for tests around the Channel Manager module. The pattern is:
    //   1. The caller already has a ticket-bearing item (typically from NPR Library - Ticket
    //      Module.CreateScenario_SmokeTest or similar).
    //   2. CreatePartner() to get a fresh CMPartnerSetup.
    //   3. InitOrder() / AddOrderLine() / AddOrderWallet() to populate the in-memory records
    //      that the internal facade NPR CMOrderIssuer.CreateOrder consumes.
    //   4. Call NPR CMOrderIssuer.CreateOrder directly — same entry point the API agent uses.

    internal procedure CreatePartner() PartnerId: Guid
    var
        PartnerSetup: Record "NPR CMPartnerSetup";
        SuffixIdx: Integer;
    begin
        PartnerSetup.Init();
        PartnerSetup.Name := CopyStr('Test Partner ' + Format(CurrentDateTime(), 0, '<Year,2><Month,2><Day,2><Hours24,2><Minutes,2><Seconds,2>'), 1, MaxStrLen(PartnerSetup.Name));
        for SuffixIdx := 1 to 4 do
            PartnerSetup.Name := PartnerSetup.Name + CopyStr('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ', Random(36), 1);
        PartnerSetup.Active := true;
        PartnerSetup.Insert(true);   // OnInsert generates PartnerId
        exit(PartnerSetup.PartnerId);
    end;

    internal procedure InitWalletSetup()
    var
        WalletSetup: Record "NPR WalletAssetSetup";
    begin
        if (not WalletSetup.Get('')) then begin
            WalletSetup.Init();
            WalletSetup.Insert();
        end;

        WalletSetup.Enabled := true;
        WalletSetup.ReferencePattern := 'WI-[S]';
        WalletSetup.ExtReferencePattern := 'WIE-[S]';
        WalletSetup.UpdateAssetPrintedInformation := true;
        WalletSetup.Modify();
    end;

    internal procedure InitOrder(PartnerId: Guid; SellToOrderReference: Code[50]; PaymentReference: Code[20]; var Order: Record "NPR CMOrder")
    begin
        Order.Init();
        Order.OrderId := CreateGuid();
        Order.PartnerId := PartnerId;
        Order.SellToOrderReference := SellToOrderReference;
        Order.SellToEmail := 'test@navipartner.dk';
        Order.SellToName := 'Test Customer';
        Order.SellToLanguage := '';   // language code optional; blank avoids requiring Language table seed
        Order.PaymentReference := PaymentReference;
    end;

    internal procedure AddOrderLine(OrderId: Guid; LineNo: Integer; ItemNo: Code[20]; Quantity: Integer; VisitDate: Date; VisitTime: Time; var TempOrderLine: Record "NPR CMOrderLine" temporary)
    begin
        TempOrderLine.Init();
        TempOrderLine.OrderId := OrderId;
        TempOrderLine.LineNo := LineNo;
        TempOrderLine.ItemNo := ItemNo;
        TempOrderLine.IsPackage := false;
        TempOrderLine.IsGroupTicket := false;
        TempOrderLine.Quantity := Quantity;
        TempOrderLine.VisitDate := VisitDate;
        TempOrderLine.VisitTime := VisitTime;
        TempOrderLine.Name := 'Test';
        TempOrderLine.NotificationAddress := 'test@navipartner.dk';
        TempOrderLine.Language := '';
        TempOrderLine.Insert();
    end;

    internal procedure AddOrderWallet(OrderId: Guid; LineNo: Integer; SeqNo: Integer; var TempOrderWallet: Record "NPR CMOrderWallet" temporary)
    begin
        TempOrderWallet.Init();
        TempOrderWallet.OrderId := OrderId;
        TempOrderWallet.LineNo := LineNo;
        TempOrderWallet.SeqNo := SeqNo;
        TempOrderWallet.Insert();
    end;
}
