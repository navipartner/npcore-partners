#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6150899 "NPR Ecom Doc Subpages Task"
{
    // Page background task that builds the data for all virtual-item subpages on the Ecom Sales
    // Document page in a single child session.
    // add one Build<Subpage>Payload procedure and one corresponding call in OnRun, plus a
    // ResultKeyTok() for the parent to fan out on completion.
    Access = Internal;

    trigger OnRun()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Params: Dictionary of [Text, Text];
        Result: Dictionary of [Text, Text];
        HeaderSystemId: Guid;
    begin
        Params := Page.GetBackgroundParameters();
        if not Evaluate(HeaderSystemId, Params.Get(HeaderSystemIdParamTok())) then
            exit;
        if not EcomSalesHeader.GetBySystemId(HeaderSystemId) then
            exit;

        BuildVouchersPayload(EcomSalesHeader, Result);
        BuildMembershipsPayload(EcomSalesHeader, Result);
        BuildTicketsPayload(EcomSalesHeader, Result);
        BuildCouponsPayload(EcomSalesHeader, Result);
        BuildWalletsPayload(EcomSalesHeader, Result);

        Page.SetBackgroundTaskResult(Result);
    end;

    local procedure BuildVouchersPayload(EcomSalesHeader: Record "NPR Ecom Sales Header"; var Result: Dictionary of [Text, Text])
    var
        TempVoucher: Record "NPR NpRv Voucher" temporary;
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
        VouchersJson: JsonArray;
        VoucherJson: JsonObject;
        VouchersJsonText: Text;
    begin
        VchrImpl.BuildVoucherTempBufferForDoc(EcomSalesHeader, TempVoucher);
        if TempVoucher.FindSet() then
            repeat
                Clear(VoucherJson);
                VoucherJson.Add('No', TempVoucher."No.");
                VoucherJson.Add('Ref', TempVoucher."Reference No.");
                VoucherJson.Add('Type', TempVoucher."Voucher Type");
                VoucherJson.Add('Desc', TempVoucher.Description);
                VoucherJson.Add('Start', TempVoucher."Starting Date");
                VoucherJson.Add('End', TempVoucher."Ending Date");
                VoucherJson.Add('Sid', TempVoucher.SystemId);
                VouchersJson.Add(VoucherJson);
            until TempVoucher.Next() = 0;
        VouchersJson.WriteTo(VouchersJsonText);
        Result.Add(VouchersResultKeyTok(), VouchersJsonText);
    end;

    local procedure BuildMembershipsPayload(EcomSalesHeader: Record "NPR Ecom Sales Header"; var Result: Dictionary of [Text, Text])
    var
        TempMembership: Record "NPR MM Membership" temporary;
        MMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MembershipsJson: JsonArray;
        MembershipJson: JsonObject;
        MembershipsJsonText: Text;
    begin
        MMShipImpl.BuildMembershipTempBufferForDoc(EcomSalesHeader, TempMembership);
        if TempMembership.FindSet() then
            repeat
                Clear(MembershipJson);
                MembershipJson.Add('No', TempMembership."Entry No.");
                MembershipJson.Add('Ext', TempMembership."External Membership No.");
                MembershipJson.Add('Code', TempMembership."Membership Code");
                MembershipJson.Add('Comm', TempMembership."Community Code");
                MembershipJson.Add('Cust', TempMembership."Customer No.");
                MembershipJson.Add('Blk', TempMembership.Blocked);
                MembershipJson.Add('Sid', TempMembership.SystemId);
                MembershipJson.Add('Disp', ResolveMembershipDisplayName(TempMembership."Entry No."));
                MembershipsJson.Add(MembershipJson);
            until TempMembership.Next() = 0;
        MembershipsJson.WriteTo(MembershipsJsonText);
        Result.Add(MembershipsResultKeyTok(), MembershipsJsonText);
    end;

    local procedure BuildTicketsPayload(EcomSalesHeader: Record "NPR Ecom Sales Header"; var Result: Dictionary of [Text, Text])
    var
        TempTicket: Record "NPR TM Ticket" temporary;
        TicketImpl: Codeunit "NPR EcomCreateTicketImpl";
        TicketsJson: JsonArray;
        TicketJson: JsonObject;
        TicketsJsonText: Text;
    begin
        TicketImpl.BuildTicketTempBufferForDoc(EcomSalesHeader, TempTicket);
        if TempTicket.FindSet() then
            repeat
                Clear(TicketJson);
                TicketJson.Add('No', TempTicket."No.");
                TicketJson.Add('Ext', TempTicket."External Ticket No.");
                TicketJson.Add('Type', TempTicket."Ticket Type Code");
                TicketJson.Add('Item', TempTicket."Item No.");
                TicketJson.Add('VFromD', TempTicket."Valid From Date");
                TicketJson.Add('VFromT', TempTicket."Valid From Time");
                TicketJson.Add('VToD', TempTicket."Valid To Date");
                TicketJson.Add('VToT', TempTicket."Valid To Time");
                TicketJson.Add('Sid', TempTicket.SystemId);
                TicketsJson.Add(TicketJson);
            until TempTicket.Next() = 0;
        TicketsJson.WriteTo(TicketsJsonText);
        Result.Add(TicketsResultKeyTok(), TicketsJsonText);
    end;

    local procedure BuildCouponsPayload(EcomSalesHeader: Record "NPR Ecom Sales Header"; var Result: Dictionary of [Text, Text])
    var
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        CouponImpl: Codeunit "NPR EcomCreateCouponImpl";
        CouponsJson: JsonArray;
        CouponJson: JsonObject;
        CouponsJsonText: Text;
    begin
        CouponImpl.BuildCouponTempBufferForDoc(EcomSalesHeader, TempCoupon);
        if TempCoupon.FindSet() then
            repeat
                Clear(CouponJson);
                CouponJson.Add('No', TempCoupon."No.");
                CouponJson.Add('Ref', TempCoupon."Reference No.");
                CouponJson.Add('Type', TempCoupon."Coupon Type");
                CouponJson.Add('Desc', TempCoupon.Description);
                CouponJson.Add('Start', TempCoupon."Starting Date");
                CouponJson.Add('End', TempCoupon."Ending Date");
                CouponJson.Add('Sid', TempCoupon.SystemId);
                CouponsJson.Add(CouponJson);
            until TempCoupon.Next() = 0;
        CouponsJson.WriteTo(CouponsJsonText);
        Result.Add(CouponsResultKeyTok(), CouponsJsonText);
    end;

    local procedure BuildWalletsPayload(EcomSalesHeader: Record "NPR Ecom Sales Header"; var Result: Dictionary of [Text, Text])
    var
        TempWallet: Record "NPR AttractionWallet" temporary;
        WalletMgt: Codeunit "NPR EcomCreateWalletMgt";
        WalletsJson: JsonArray;
        WalletJson: JsonObject;
        WalletsJsonText: Text;
    begin
        WalletMgt.BuildWalletTempBufferForDoc(EcomSalesHeader, TempWallet);
        if TempWallet.FindSet() then
            repeat
                Clear(WalletJson);
                WalletJson.Add('No', TempWallet.EntryNo);
                WalletJson.Add('Ref', TempWallet.ReferenceNumber);
                WalletJson.Add('Desc', TempWallet.Description);
                WalletJson.Add('Item', TempWallet.OriginatesFromItemNo);
                WalletJson.Add('Exp', TempWallet.ExpirationDate);
                WalletJson.Add('Sid', TempWallet.SystemId);
                WalletsJson.Add(WalletJson);
            until TempWallet.Next() = 0;
        WalletsJson.WriteTo(WalletsJsonText);
        Result.Add(WalletsResultKeyTok(), WalletsJsonText);
    end;

    local procedure ResolveMembershipDisplayName(MembershipEntryNo: Integer): Text[100]
    var
        MembershipRole: Record "NPR MM Membership Role";
    begin
        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipRole.SetFilter(Blocked, '=%1', false);
        MembershipRole.SetFilter("Member Role", '=%1|=%2', MembershipRole."Member Role"::ADMIN, MembershipRole."Member Role"::GUARDIAN);
        if MembershipRole.FindFirst() then begin
            MembershipRole.CalcFields("Member Display Name");
            exit(MembershipRole."Member Display Name");
        end;
        MembershipRole.SetFilter(Blocked, '=%1', true);
        if MembershipRole.FindFirst() then begin
            MembershipRole.CalcFields("Member Display Name");
            exit(MembershipRole."Member Display Name");
        end;
    end;

    internal procedure HeaderSystemIdParamTok(): Text
    var
        ParamTok: Label 'HeaderSystemId', Locked = true;
    begin
        exit(ParamTok);
    end;

    internal procedure VouchersResultKeyTok(): Text
    var
        ResultKeyTok: Label 'Vouchers', Locked = true;
    begin
        exit(ResultKeyTok);
    end;

    internal procedure MembershipsResultKeyTok(): Text
    var
        ResultKeyTok: Label 'Memberships', Locked = true;
    begin
        exit(ResultKeyTok);
    end;

    internal procedure TicketsResultKeyTok(): Text
    var
        ResultKeyTok: Label 'Tickets', Locked = true;
    begin
        exit(ResultKeyTok);
    end;

    internal procedure CouponsResultKeyTok(): Text
    var
        ResultKeyTok: Label 'Coupons', Locked = true;
    begin
        exit(ResultKeyTok);
    end;

    internal procedure WalletsResultKeyTok(): Text
    var
        ResultKeyTok: Label 'Wallets', Locked = true;
    begin
        exit(ResultKeyTok);
    end;
}
#endif
