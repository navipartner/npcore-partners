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
                VoucherJson.Add('Start', Format(TempVoucher."Starting Date", 0, 9));
                VoucherJson.Add('End', Format(TempVoucher."Ending Date", 0, 9));
                VoucherJson.Add('Sid', Format(TempVoucher.SystemId, 0, 4));
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
                MembershipJson.Add('Sid', Format(TempMembership.SystemId, 0, 4));
                MembershipJson.Add('Disp', ResolveMembershipDisplayName(TempMembership."Entry No."));
                MembershipsJson.Add(MembershipJson);
            until TempMembership.Next() = 0;
        MembershipsJson.WriteTo(MembershipsJsonText);
        Result.Add(MembershipsResultKeyTok(), MembershipsJsonText);
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
}
#endif
