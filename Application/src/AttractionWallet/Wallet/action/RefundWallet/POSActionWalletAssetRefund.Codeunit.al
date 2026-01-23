codeunit 6150904 "NPR POSActionWalletAssetRefund" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        _ActionDescription: Label 'Allows the user to refund a wallets balance back to the customer''s payment method. Assets associated with the refund will be voided.';
        _CreatedSalesLineIds: List of [Guid];
        _RefundPrefix: Label 'Refund: ';
        _WalletNotFound: Label 'No wallet could be found from specified reference number.';
        _NoAssetsToRefund: Label 'The wallet has no assets to refund.';
        _UnlinkFromHolderWallet: Boolean;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config")
    var
        InputWalletRefernceLbl: Label 'Input Wallet Reference';
        UnlinkAssetFromWalletLbl: Label 'Unlink asset from holder wallet';
        UnlinkAssetFromWalletDescLbl: Label 'When enabled, refunded assets are removed from the holder wallet and will instead appear in the owner wallet (as Owner, not Holder)';
    begin
        WorkflowConfig.AddActionDescription(_ActionDescription);
        WorkflowConfig.AddLabel('inputReference', InputWalletRefernceLbl);
        WorkflowConfig.AddBooleanParameter('unlinkAssetFromHolderWallet', true, UnlinkAssetFromWalletLbl, UnlinkAssetFromWalletDescLbl);

        WorkflowConfig.AddJavascript(GetActionScript());
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'refundAllWalletAssets':
                begin
                    FrontEnd.WorkflowResponse(RefundAllAssetsFromWallet(Context));
                end;
            else
                FrontEnd.WorkflowResponse(RespondFail('Invalid Step. Thanks for finding - this is a programming error and we will fix it.'));
        end;
    end;

    local procedure RefundAllAssetsFromWallet(Context: Codeunit "NPR POS JSON Helper"): JsonObject
    var
        WalletAssets: Query "NPR AttractionWalletAssets";
        Wallet: Query "NPR FindAttractionWallets";
        WalletFacade: Codeunit "NPR AttractionWalletFacade";
        ReferenceNumber: Text[50];
        WalletRelativeNumber: Integer;
        SaleSystemId: Guid;
        RefundCounter: Integer;
    begin

        ReferenceNumber := CopyStr(Context.GetString('input'), 1, MaxStrLen(ReferenceNumber));
        if (ReferenceNumber = '') then
            exit(RespondFail(_WalletNotFound));

        _UnlinkFromHolderWallet := Context.GetBooleanParameter('unlinkAssetFromHolderWallet');

        WalletFacade.FindWalletByReferenceNumber(ReferenceNumber, Wallet);
        if (Wallet.Read()) then begin
            WalletFacade.GetWalletAssets(Wallet.WalletReferenceNumber, WalletAssets);
            CreateMainSalesLine(Wallet.WalletReferenceNumber, Wallet.WalletEntryNo, Wallet.WalletOriginatesFromItemNo, '', StrSubstNo('%1%2', _RefundPrefix, ReferenceNumber), -1, 0, SaleSystemId, WalletRelativeNumber);

            while (WalletAssets.Read()) do begin
                if (WalletAssets.AssetType = WalletAssets.AssetType::TICKET) then
                    if (RefundOneTicket(SaleSystemId, WalletRelativeNumber, WalletAssets.AssetReferenceNumber, WalletAssets.AssetSystemId)) then
                        RefundCounter += 1;

                if (WalletAssets.AssetType = WalletAssets.AssetType::COUPON) then
                    if (RefundOneCoupon(SaleSystemId, WalletRelativeNumber, WalletAssets.AssetSystemId)) then
                        RefundCounter += 1;
            end;
        end else begin
            exit(RespondFail(_WalletNotFound));
        end;

        if (RefundCounter = 0) then begin
            CleanupCreatedLines(SaleSystemId);
            exit(RespondFail(_NoAssetsToRefund));
        end;

        exit(RespondSuccess());
    end;

    local procedure RefundOneTicket(SalesSystemId: Guid; WalletRelativeNumber: Integer; ReferenceNumber: Text[100]; TicketSystemId: Guid): Boolean
    var
        TicketManagement: Codeunit "NPR POS Action - Ticket Mgt B.";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePos: Record "NPR POS Sale Line";
        WalletSaleLine: Record "NPR AttractionWalletSaleLine";
        TicketReferenceNumber: Text[50];
        SaleLineSystemId: Guid;
        ResponseMessage: Text;
        ResponseCode: Integer;
    begin
        TicketReferenceNumber := CopyStr(ReferenceNumber, 1, MaxStrLen(TicketReferenceNumber));
        ResponseCode := TicketManagement.RevokeTicketReservation(POSSession, TicketReferenceNumber, false, SaleLineSystemId, ResponseMessage);

        if (ResponseCode < 0) then
            exit;

        _CreatedSalesLineIds.Add(SaleLineSystemId);
        SaleLinePos.GetBySystemId(SaleLineSystemId);

        WalletSaleLine.SaleHeaderSystemId := SalesSystemId;
        WalletSaleLine.LineNumber := SaleLinePos."Line No.";
        WalletSaleLine.WalletNumber := WalletRelativeNumber;
        WalletSaleLine.SaleLineId := SaleLineSystemId;

        WalletSaleLine.ActionType := WalletSaleLine.ActionType::REVOKE;
        if (_UnlinkFromHolderWallet) then
            WalletSaleLine.ActionType := WalletSaleLine.ActionType::REVOKE_AND_REMOVE_HOLDER;

        WalletSaleLine.AssetTableId := DATABASE::"NPR TM Ticket";
        WalletSaleLine.AssetSystemId := TicketSystemId;
        WalletSaleLine.Insert();

        exit(true);
    end;

    local procedure RefundOneCoupon(SalesSystemId: Guid; WalletRelativeNumber: Integer; CouponSystemId: Guid): Boolean
    var
        WalletSaleLine: Record "NPR AttractionWalletSaleLine";
        Coupon: Record "NPR NpDc Coupon";
        CouponType: Record "NPR NpDc Coupon Type";
        WalletCouponSetup: Record "NPR WalletCouponSetup";
        SaleLinePos: Record "NPR POS Sale Line";
        SaleLineSystemId: Guid;
    begin
        if (not Coupon.GetBySystemId(CouponSystemId)) then
            exit;

        CouponType.Get(Coupon."Coupon Type");
        if not (WalletCouponSetup.Get(Coupon."Coupon Type")) then
            exit;

        SaleLineSystemId := CreateSalesLine(0, WalletCouponSetup.TriggerOnItemNo, '', StrSubstNo('%1%2', _RefundPrefix, Coupon."Reference No."), -1, 0);

        _CreatedSalesLineIds.Add(SaleLineSystemId);
        SaleLinePos.GetBySystemId(SaleLineSystemId);

        WalletSaleLine.SaleHeaderSystemId := SalesSystemId;
        WalletSaleLine.LineNumber := SaleLinePos."Line No.";
        WalletSaleLine.WalletNumber := WalletRelativeNumber;
        WalletSaleLine.SaleLineId := SaleLineSystemId;

        WalletSaleLine.ActionType := WalletSaleLine.ActionType::REVOKE;
        if (_UnlinkFromHolderWallet) then
            WalletSaleLine.ActionType := WalletSaleLine.ActionType::REVOKE_AND_REMOVE_HOLDER;

        WalletSaleLine.AssetTableId := DATABASE::"NPR NpDc Coupon";
        WalletSaleLine.AssetSystemId := CouponSystemId;
        WalletSaleLine.Insert();

        exit(true);
    end;


    local procedure CreateSalesLine(LineNo: Integer; ItemNo: Code[20]; VariantCode: Code[10]; Description2: Text; Quantity: Decimal; UnitPrice: Decimal): Guid
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePos: Record "NPR POS Sale Line";
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(SaleLinePos);

        SaleLinePos."Line Type" := SaleLinePos."Line Type"::Item;
        SaleLinePos."Line No." := LineNo;
        SaleLinePos."No." := ItemNo;
        SaleLinePos."Variant Code" := VariantCode;
        SaleLinePos.Quantity := Quantity;
        SaleLinePos."Description 2" := CopyStr(Description2, 1, MaxStrLen(SaleLinePos."Description 2"));

        if (UnitPrice <> 0) then
            SaleLinePos."Unit Price" := UnitPrice;

        POSSaleLine.InsertLine(SaleLinePos);

        exit(SaleLinePos.SystemId);
    end;


    local procedure CreateMainSalesLine(ReferenceNumber: Code[50]; WalletEntryNo: Integer; ItemNo: Code[20]; VariantCode: Code[10]; Description2: Text; Quantity: Decimal; UnitPrice: Decimal; var SaleSystemId: Guid; var WalletRelativeNumber: Integer): Guid
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSaleHdr: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";

        SaleHdrPos: Record "NPR POS Sale";
        SaleLinePos: Record "NPR POS Sale Line";

        WalletSaleHeader: Record "NPR AttractionWalletSaleHdr";
    begin
        POSSession.GetSale(POSSaleHdr);
        POSSaleHdr.GetCurrentSale(SaleHdrPos);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(SaleLinePos);

        SaleLinePos."Line Type" := SaleLinePos."Line Type"::Item;
        SaleLinePos."No." := ItemNo;
        SaleLinePos."Variant Code" := VariantCode;
        SaleLinePos.Quantity := Quantity;
        SaleLinePos."Description 2" := CopyStr(Description2, 1, MaxStrLen(SaleLinePos."Description 2"));
        SaleLinePos."Unit Price" := UnitPrice;
        if (UnitPrice = 0) then
            SaleLinePos."Manual Item Sales Price" := true;

        POSSaleLine.InsertLine(SaleLinePos);

        _CreatedSalesLineIds.Add(SaleLinePos.SystemId);

        WalletSaleHeader.SetFilter(SaleHeaderSystemId, '=%1', SaleHdrPos.SystemId);
        WalletRelativeNumber := WalletSaleHeader.Count() + 1;

        SaleSystemId := SaleHdrPos.SystemId;
        WalletSaleHeader.SaleHeaderSystemId := SaleSystemId;
        WalletSaleHeader.WalletNumber := WalletRelativeNumber;
        WalletSaleHeader.ReferenceNumber := ReferenceNumber;
        WalletSaleHeader.WalletEntryNo := WalletEntryNo;
        WalletSaleHeader.Insert();

        exit(SaleLinePos.SystemId);
    end;

    local procedure CleanupCreatedLines(SaleHdrSystemId: Guid)
    var
        SaleLinePos: Record "NPR POS Sale Line";
        SaleSystemId: Guid;
        WalletSaleHeader: Record "NPR AttractionWalletSaleHdr";
        WalletSaleLine: Record "NPR AttractionWalletSaleLine";
    begin
        foreach SaleSystemId in _CreatedSalesLineIds do begin
            SaleLinePos.GetBySystemId(SaleSystemId);
            SaleLinePos.Delete(true);

            WalletSaleLine.SetFilter(SaleHeaderSystemId, '=%1', SaleHdrSystemId);
            WalletSaleLine.SetFilter(SaleLineId, '=%1', SaleSystemId);
            WalletSaleLine.DeleteAll();
        end;

        WalletSaleLine.Reset();
        WalletSaleLine.SetFilter(SaleHeaderSystemId, '=%1', SaleHdrSystemId);
        if (WalletSaleLine.IsEmpty()) then begin
            WalletSaleHeader.SetFilter(SaleHeaderSystemId, '=%1', SaleHdrSystemId);
            WalletSaleHeader.DeleteAll();
        end;
        Clear(_CreatedSalesLineIds);
    end;

    local procedure RespondFail(reason: Text) Params: JsonObject
    begin
        Params.Add('success', false);
        Params.Add('reason', reason);
    end;

    local procedure RespondSuccess() Params: JsonObject
    begin
        Params.Add('success', true);
        Params.Add('reason', '');
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionWalletAssetRefund.js###
'const main=async({popup:e,captions:s,workflow:t})=>{const n=await e.input(s.inputReference);if(!n)return;const{success:a,reason:r}=await t.respond("refundAllWalletAssets",{input:n});a||await e.message(r)};'
);
    end;
}