codeunit 6151056 "NPR CMOrderIssuer"
{
    Access = Internal;
    TableNo = "NPR CMOrder";

    trigger OnRun()
    var
        OrderWallet: Record "NPR CMOrderWallet";
        TempOrderWallet: Record "NPR CMOrderWallet" temporary;
    begin
        if (not Rec.Find()) then
            exit;

        if (not (Rec.Status in [Rec.Status::Scheduled, Rec.Status::Processing])) then
            exit;

        OrderWallet.SetFilter(OrderId, '=%1', Rec.OrderId);
        if (OrderWallet.FindSet()) then
            repeat
                TempOrderWallet := OrderWallet;
                TempOrderWallet.Insert();
            until (OrderWallet.Next() = 0);

        IssueForOrder(Rec, TempOrderWallet);
    end;

    #region Internal Facade
    internal procedure ProcessNewOrder(
        Synchronous: Boolean;
        var Order: Record "NPR CMOrder";
        var TempOrderLine: Record "NPR CMOrderLine" temporary;
        var TempOrderComponent: Record "NPR CMOrderComponent" temporary;
        var TempOrderWallet: Record "NPR CMOrderWallet" temporary)
    var
        DuplicateOrderErr: Label 'An order with sellToOrderReference ''%1'' already exists for the given partner.', Comment = '%1 = sellToOrderReference value';
    begin
        if (Order.DocumentNo = '') then
            Order.DocumentNo := GenerateDocumentNo(Order.PartnerId);

        Order.Status := Order.Status::Submitted;
        if (Synchronous) then
            Order.Status := Order.Status::Scheduled;

        Order.ReceivedAt := CurrentDateTime();
        if (not Order.Insert()) then
            Error(DuplicateOrderErr, Order.SellToOrderReference);

        PersistOrderLines(TempOrderLine);
        PersistOrderComponents(TempOrderComponent);
        PersistWalletShells(TempOrderWallet);

        if (Synchronous) then
            IssueForOrder(Order, TempOrderWallet);
    end;

    internal procedure ReplaceOrder(
        Synchronous: Boolean;
        var ExistingOrder: Record "NPR CMOrder";
        var ParsedOrder: Record "NPR CMOrder";
        var TempOrderLine: Record "NPR CMOrderLine" temporary;
        var TempOrderComponent: Record "NPR CMOrderComponent" temporary;
        var TempOrderWallet: Record "NPR CMOrderWallet" temporary)
    var
        InvalidStatusErr: Label 'Order cannot be replaced in status %1.', Comment = '%1 = current order status';
    begin
        if (not (ExistingOrder.Status in [ExistingOrder.Status::Draft, ExistingOrder.Status::Error])) then
            Error(InvalidStatusErr, ExistingOrder.Status);

        DestroyOrderAssets(ExistingOrder);

        ExistingOrder.SellToEmail := ParsedOrder.SellToEmail;
        ExistingOrder.SellToName := ParsedOrder.SellToName;
        ExistingOrder.SellToLanguage := ParsedOrder.SellToLanguage;
        ExistingOrder.PaymentReference := ParsedOrder.PaymentReference;

        ExistingOrder.Status := ExistingOrder.Status::Submitted;
        if (Synchronous) then
            ExistingOrder.Status := ExistingOrder.Status::Scheduled;

        ExistingOrder.Modify();

        PersistOrderLines(TempOrderLine);
        PersistOrderComponents(TempOrderComponent);
        PersistWalletShells(TempOrderWallet);

        if (Synchronous) then
            IssueForOrder(ExistingOrder, TempOrderWallet);
    end;

    internal procedure DeleteOrder(var Order: Record "NPR CMOrder") HeaderDeleted: Boolean
    var
        PriorStatus: Enum "NPR CMOrderStatus";
        InFlightErr: Label 'Order is mid-flight (status %1); retry once it has settled.', Comment = '%1 = current order status';
    begin
        // Block deletion while the order is queued, claimed, or actively being worked on.
        if (Order.Status in [Order.Status::Submitted, Order.Status::Scheduled, Order.Status::Processing]) then
            Error(InFlightErr, Order.Status);

        PriorStatus := Order.Status;
        DestroyOrderAssets(Order);

        if (PriorStatus in [Order.Status::Draft, Order.Status::Error]) then begin
            Order.Delete();
            exit(true);
        end;
        exit(false);
    end;

    internal procedure ConfirmOrder(var Order: Record "NPR CMOrder")
    var
        TicketIssuer: Codeunit "NPR CMTicketIssuer";
        CouponIssuer: Codeunit "NPR CMCouponIssuer";
    begin
        if (Order.PaymentReference = '') then
            exit;

        TicketIssuer.ConfirmTickets(Order);
        CouponIssuer.ConfirmCoupons(Order);

        Order.Status := Order.Status::Issued;
        Order.Modify();

        BuildManifestForOrder(Order);

        Commit();
    end;

    internal procedure DestroyOrderAssets(var Order: Record "NPR CMOrder")
    var
        TicketIssuer: Codeunit "NPR CMTicketIssuer";
        CouponIssuer: Codeunit "NPR CMCouponIssuer";
        WalletFacade: Codeunit "NPR AttractionWallet";
        NPDesignerFacade: Codeunit "NPR NPDesignerManifestFacade";
        WalletEntryNos: List of [Integer];
        CouponSystemIds: List of [Guid];
        WalletEntryNo: Integer;
    begin
        if (not IsNullGuid(Order.ManifestId)) then
            NPDesignerFacade.DeleteManifest(Order.ManifestId);

        CouponIssuer.CollectCouponSystemIdsForOrder(Order, CouponSystemIds);

        TicketIssuer.DeleteTicketImportJob(Order.JobId);

        CollectWallets(Order, WalletEntryNos);
        foreach WalletEntryNo in WalletEntryNos do
            WalletFacade.DeleteWallet(WalletEntryNo);

        CouponIssuer.DeleteCoupons(CouponSystemIds);

        DeleteOrderWallets(Order.OrderId);
        DeleteOrderComponents(Order.OrderId);
        DeleteOrderLines(Order.OrderId);

        Order.StatusMessage := '';
        Order.Status := Order.Status::Cancelled;
        Order.JobId := '';
        Clear(Order.ManifestId);
        Order.ManifestUrl := '';
        Order.Modify();
    end;

    #endregion

    // Helpers for the facade methods above and the page actions below
    local procedure IssueForOrder(var Order: Record "NPR CMOrder"; var TempOrderWallet: Record "NPR CMOrderWallet" temporary)
    var
        TicketIssuer: Codeunit "NPR CMTicketIssuer";
        TicketImportJobId: Code[40];
        TempImportHeader: Record "NPR TM ImportTicketHeader" temporary;
        TempImportLine: Record "NPR TM ImportTicketLine" temporary;
        FailureMessage: Text;
    begin
        Order.Status := Order.Status::Processing;
        Order.StatusMessage := '';
        Order.Modify();
        Commit();

        if (Order.JobId = '') then begin
            TicketIssuer.ReshapeToTicketImport(Order, TicketImportJobId, TempImportHeader, TempImportLine, TempOrderWallet);
            Commit();

            if (not TicketIssuer.RunTicketImport(TicketImportJobId, TempImportHeader, TempImportLine, FailureMessage)) then
                Error(FailureMessage);

            Order.JobId := TicketImportJobId;
            Order.Modify();
            Commit();
        end;

        WrapAssetsIntoWallets(Order, TempOrderWallet);

        if (Order.PaymentReference = '') then begin
            Order.Status := Order.Status::Draft;
            Order.Modify();
            Commit();
        end else
            ConfirmOrder(Order);
    end;

    local procedure WrapAssetsIntoWallets(var Order: Record "NPR CMOrder"; var TempOrderWallet: Record "NPR CMOrderWallet" temporary)
    var
        TicketIssuer: Codeunit "NPR CMTicketIssuer";
        CouponIssuer: Codeunit "NPR CMCouponIssuer";
        OrderLine: Record "NPR CMOrderLine";
        OrderWallet: Record "NPR CMOrderWallet";
        WalletFacade: Codeunit "NPR AttractionWallet";
        WalletEntryNo: Integer;
        WalletReferenceNumber: Text[50];
        WalletName: Text[100];
    begin
        TempOrderWallet.Reset();
        if (not TempOrderWallet.FindSet()) then
            exit;

        OrderWallet.SetFilter(OrderId, '=%1', Order.OrderId);
        OrderWallet.DeleteAll();

        repeat
            OrderLine.Get(TempOrderWallet.OrderId, TempOrderWallet.LineNo);

            WalletName := TempOrderWallet.WalletName;
            if (WalletName = '') then
                WalletName := DeriveDefaultWalletName(OrderLine);

            WalletEntryNo := WalletFacade.CreateWalletFromFacade(
                OrderLine.ItemNo,
                WalletName,
                WalletReferenceNumber,
                TempOrderWallet.ExternalReferenceNumber);

            TicketIssuer.AttachTicketsToWallet(Order.JobId, WalletEntryNo, OrderLine.LineNo, TempOrderWallet.SeqNo);
            CouponIssuer.IssueAndAttachCouponsForWallet(WalletEntryNo, Order, OrderLine, TempOrderWallet);

            OrderWallet.Init();
            OrderWallet.OrderId := TempOrderWallet.OrderId;
            OrderWallet.LineNo := TempOrderWallet.LineNo;
            OrderWallet.SeqNo := TempOrderWallet.SeqNo;
            OrderWallet.WalletEntryNo := WalletEntryNo;
            OrderWallet.WalletName := WalletName;
            WalletFacade.GetWalletExternalReferenceNumber(WalletEntryNo, OrderWallet.ExternalReferenceNumber);
            OrderWallet.UnitPriceExclVat := TempOrderWallet.UnitPriceExclVat;
            OrderWallet.UnitPriceInclVat := TempOrderWallet.UnitPriceInclVat;
            OrderWallet.CurrencyCode := TempOrderWallet.CurrencyCode;
            OrderWallet.IssuedAt := CurrentDateTime();
            OrderWallet.Insert();
        until (TempOrderWallet.Next() = 0);
    end;


    local procedure PersistWalletShells(var TempOrderWallet: Record "NPR CMOrderWallet" temporary)
    var
        OrderWallet: Record "NPR CMOrderWallet";
    begin
        TempOrderWallet.Reset();
        if (not TempOrderWallet.FindSet()) then
            exit;
        repeat
            OrderWallet := TempOrderWallet;
            OrderWallet.WalletEntryNo := 0;
            OrderWallet.Insert();
        until (TempOrderWallet.Next() = 0);
    end;

    local procedure PersistOrderLines(var TempOrderLine: Record "NPR CMOrderLine" temporary)
    var
        OrderLine: Record "NPR CMOrderLine";
    begin
        TempOrderLine.Reset();
        if (not TempOrderLine.FindSet()) then
            exit;
        repeat
            OrderLine := TempOrderLine;
            OrderLine.Insert();
        until (TempOrderLine.Next() = 0);
    end;

    local procedure PersistOrderComponents(var TempOrderComponent: Record "NPR CMOrderComponent" temporary)
    var
        OrderComponent: Record "NPR CMOrderComponent";
    begin
        TempOrderComponent.Reset();
        if (not TempOrderComponent.FindSet()) then
            exit;
        repeat
            OrderComponent := TempOrderComponent;
            OrderComponent.Insert();
        until (TempOrderComponent.Next() = 0);
    end;

    local procedure DeriveDefaultWalletName(var OrderLine: Record "NPR CMOrderLine"): Text[100]
    var
        Item: Record Item;
    begin
        Item.SetLoadFields(Description);
        if (Item.Get(OrderLine.ItemNo)) then
            exit(CopyStr(Item.Description, 1, 100));
        exit(CopyStr(OrderLine.ItemNo, 1, 100));
    end;

    local procedure BuildManifestForOrder(var Order: Record "NPR CMOrder")
    var
        PartnerSetup: Record "NPR CMPartnerSetup";
        OrderWallet: Record "NPR CMOrderWallet";
        Wallet: Record "NPR AttractionWallet";
        NPDesignerFacade: Codeunit "NPR NPDesignerManifestFacade";
        WalletAssets: Dictionary of [Guid, Text[100]];
        NotInsertedAssets: List of [Guid];
        ManifestId: Guid;
        ManifestUrl: Text[250];
        TemplateId: Text[40];
    begin

        if (not PartnerSetup.Get(Order.PartnerId)) then
            exit;

        TemplateId := PartnerSetup.NPDesignerTemplateId;
        if (TemplateId = '') then
            exit;

        OrderWallet.SetFilter(OrderId, '=%1', Order.OrderId);
        if (not OrderWallet.FindSet()) then
            exit;

        repeat
            if ((OrderWallet.WalletEntryNo <> 0) and Wallet.Get(OrderWallet.WalletEntryNo)) then
                if (not WalletAssets.ContainsKey(Wallet.SystemId)) then
                    WalletAssets.Add(Wallet.SystemId, CopyStr(Wallet.ReferenceNumber, 1, 100));
        until (OrderWallet.Next() = 0);

        if (WalletAssets.Count() = 0) then
            exit;

        ManifestId := NPDesignerFacade.CreateManifest(TemplateId, Order.SellToLanguage, true);
        if (IsNullGuid(ManifestId)) then
            exit;

        NPDesignerFacade.AddAssetToManifest(ManifestId, Database::"NPR AttractionWallet", WalletAssets, TemplateId, NotInsertedAssets);
        NPDesignerFacade.GetManifestUrl(ManifestId, ManifestUrl);

        Order.ManifestId := ManifestId;
        Order.ManifestUrl := ManifestUrl;
        Order.Modify();

        OrderWallet.Reset();
        OrderWallet.SetFilter(OrderId, '=%1', Order.OrderId);
        if (OrderWallet.FindSet()) then
            repeat
                if ((OrderWallet.WalletEntryNo <> 0) and Wallet.Get(OrderWallet.WalletEntryNo)) then begin
                    OrderWallet.ManifestId := NPDesignerFacade.CreateManifest(TemplateId, Order.SellToLanguage, false);
                    NPDesignerFacade.AddAssetToManifest(OrderWallet.ManifestId, Database::"NPR AttractionWallet", Wallet.SystemId, OrderWallet.ExternalReferenceNumber, TemplateId);
                    NPDesignerFacade.GetManifestUrl(OrderWallet.ManifestId, OrderWallet.ManifestUrl);
                    OrderWallet.Modify();
                end;
            until (OrderWallet.Next() = 0);
    end;

    local procedure CollectWallets(var Order: Record "NPR CMOrder"; var WalletEntryNos: List of [Integer])
    var
        OrderWallet: Record "NPR CMOrderWallet";
    begin
        OrderWallet.SetFilter(OrderId, '=%1', Order.OrderId);
        OrderWallet.SetLoadFields(WalletEntryNo);
        if (not OrderWallet.FindSet()) then
            exit;

        repeat
            if ((OrderWallet.WalletEntryNo <> 0) and (not WalletEntryNos.Contains(OrderWallet.WalletEntryNo))) then
                WalletEntryNos.Add(OrderWallet.WalletEntryNo);
        until (OrderWallet.Next() = 0);
    end;

    local procedure DeleteOrderWallets(OrderId: Guid)
    var
        OrderWallet: Record "NPR CMOrderWallet";
        InnerWallet: Record "NPR CMOrderWallet";
        TempKeys: Record "NPR CMOrderWallet" temporary;
        NpDesignerFacade: Codeunit "NPR NPDesignerManifestFacade";
    begin
        OrderWallet.SetFilter(OrderId, '=%1', OrderId);
        OrderWallet.SetLoadFields(OrderId, LineNo, SeqNo);
        if (OrderWallet.FindSet()) then
            repeat
                TempKeys := OrderWallet;
                TempKeys.Insert();
            until (OrderWallet.Next() = 0);

        TempKeys.Reset();
        if (TempKeys.FindSet()) then
            repeat
                if (InnerWallet.Get(TempKeys.OrderId, TempKeys.LineNo, TempKeys.SeqNo)) then begin
                    if (not IsNullGuid(InnerWallet.ManifestId)) then
                        NPDesignerFacade.DeleteManifest(InnerWallet.ManifestId);
                    InnerWallet.Delete(true);
                end;
            until (TempKeys.Next() = 0);
    end;

    local procedure DeleteOrderComponents(OrderId: Guid)
    var
        Component: Record "NPR CMOrderComponent";
        InnerComponent: Record "NPR CMOrderComponent";
        TempKeys: Record "NPR CMOrderComponent" temporary;
    begin
        Component.SetFilter(OrderId, '=%1', OrderId);
        Component.SetLoadFields(OrderId, LineNo, ComponentNo);
        if (Component.FindSet()) then
            repeat
                TempKeys := Component;
                TempKeys.Insert();
            until (Component.Next() = 0);

        TempKeys.Reset();
        if (TempKeys.FindSet()) then
            repeat
                if (InnerComponent.Get(TempKeys.OrderId, TempKeys.LineNo, TempKeys.ComponentNo)) then
                    InnerComponent.Delete(true);
            until (TempKeys.Next() = 0);
    end;

    local procedure DeleteOrderLines(OrderId: Guid)
    var
        Line: Record "NPR CMOrderLine";
        InnerLine: Record "NPR CMOrderLine";
        LineNos: List of [Integer];
        LineNo: Integer;
    begin
        Line.SetFilter(OrderId, '=%1', OrderId);
        Line.SetLoadFields(LineNo);
        if (Line.FindSet()) then
            repeat
                LineNos.Add(Line.LineNo);
            until (Line.Next() = 0);

        foreach LineNo in LineNos do
            if (InnerLine.Get(OrderId, LineNo)) then
                InnerLine.Delete(true);
    end;

    local procedure GenerateDocumentNo(PartnerId: Guid): Code[20]
    var
        PartnerSetup: Record "NPR CMPartnerSetup";
    begin
        if (PartnerSetup.Get(PartnerId) and (PartnerSetup.DocumentNoSeries <> '')) then
            exit(GetNextNoFromSeries(PartnerSetup.DocumentNoSeries));
        exit(GenerateDefaultDocumentNo());
    end;

    local procedure GenerateDefaultDocumentNo(): Code[20]
    var
        Suffix: Text[4];
    begin
        // 4 hex chars off a fresh Guid = 16 bits of crypto-random; independent across calls
        // (kernel-RNG, not time-seeded), so within-tick bursts don't collide. Same Guid-to-hex
        // pattern as NewJobId in CMTicketIssuer.
        Suffix := CopyStr(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')), 1, 4);
        exit(CopyStr('CM-' + Format(CurrentDateTime(), 0, '<Year,2><Month,2><Day,2><Hours24,2><Minutes,2><Seconds,2>') + '-' + Suffix, 1, 20));
    end;

#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
    local procedure GetNextNoFromSeries(NoSeries: Code[20]) Number: Code[20]
    var
        NoSeriesMgt: Codeunit "No. Series";
    begin
        Number := NoSeriesMgt.GetNextNo(NoSeries);
    end;
#ELSE
    local procedure GetNextNoFromSeries(NoSeries: Code[20]) Number: Code[20]
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        NoSeriesMgt.InitSeries(NoSeries, '', Today(), Number, NoSeries);
    end;
#ENDIF
}
