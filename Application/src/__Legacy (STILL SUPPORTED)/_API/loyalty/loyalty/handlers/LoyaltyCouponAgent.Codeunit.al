#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248431 "NPR LoyaltyCouponAgent"
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-06-13';
    ObsoleteReason = 'This API is being phased out';

    trigger OnRun()
    begin

    end;

    var
        HelperFunctions: Codeunit "NPR Loyalty Helper Functions";

    internal procedure GetCouponEligibility(_Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        MembershipNumber, CustomerNumber : Code[20];
        CardNumber: Text[100];
        OrderValueText: Text;
        OrderValue: Decimal;
        DocumentDate: Date;
    begin
#pragma warning disable AA0139
        MembershipNumber := HelperFunctions.GetQueryParameterFromRequest(_Request, 'membershipNumber');
        CardNumber := HelperFunctions.GetQueryParameterFromRequest(_Request, 'cardNumber');
        CustomerNumber := HelperFunctions.GetQueryParameterFromRequest(_Request, 'customerNumber');
#pragma warning restore
        OrderValueText := HelperFunctions.GetQueryParameterFromRequest(_Request, 'orderValue');

        if OrderValueText <> '' then
            Evaluate(OrderValue, OrderValueText);

        DocumentDate := Today();

        Response := GetCouponEligibility(MembershipNumber, CardNumber, CustomerNumber, OrderValue, DocumentDate);
    end;

    internal procedure CreateCoupon(_Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Coupon: Record "NPR NpDc Coupon";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        TempLoyaltyPointsSetupRequest: Record "NPR MM Loyalty Point Setup" temporary;
        TempLoyaltyPointsSetupEligible: Record "NPR MM Loyalty Point Setup" temporary;
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
        ResponseJson: Codeunit "NPR Json Builder";
        MembershipNumber, DocumentNo : Code[20];
        DocumentDateTxt, OrderValueText : Text;
        MembershipEntryNo: Integer;
        OrderValue: Decimal;
        DocumentDate: Date;
        JToken, JTokCoupons : JsonToken;
        ResponseMessage: Text;
        DateValidFromDate, DateValidUntilDate : Date;
    begin
#pragma warning disable AA0139
        MembershipNumber := HelperFunctions.GetQueryParameterFromRequest(_Request, 'membershipNumber');
        DocumentNo := HelperFunctions.GetQueryParameterFromRequest(_Request, 'documentNo');
#pragma warning restore
        DocumentDateTxt := HelperFunctions.GetQueryParameterFromRequest(_Request, 'documentDate');
        OrderValueText := HelperFunctions.GetQueryParameterFromRequest(_Request, 'orderValue');

        if (MembershipNumber <> '') then
            MembershipEntryNo := MembershipManagement.GetMembershipFromExtMembershipNo(MembershipNumber);

        if OrderValueText <> '' then
            Evaluate(OrderValue, OrderValueText);

        if DocumentDateTxt <> '' then
            Evaluate(DocumentDate, DocumentDateTxt)
        else
            DocumentDate := Today();

        JToken := _Request.BodyJson();
        JToken.SelectToken('coupon', JTokCoupons);

        GetCouponLines(JTokCoupons, TempLoyaltyPointsSetupRequest);
        MembershipManagement.GetMembershipValidDate(MembershipEntryNo, Today, DateValidFromDate, DateValidUntilDate);

        if (MembershipEntryNo > 0) then begin
            TempLoyaltyPointsSetupRequest.Reset();
            if (TempLoyaltyPointsSetupRequest.FindSet()) then
                repeat
                    TempLoyaltyPointsSetupEligible.DeleteAll();
                    LoyaltyPointManagement.GetCouponToRedeemWS(MembershipEntryNo, TempLoyaltyPointsSetupEligible, OrderValue, ResponseMessage);
                    if (TempLoyaltyPointsSetupEligible.Get(TempLoyaltyPointsSetupRequest.Code, TempLoyaltyPointsSetupRequest."Line No.")) then begin
                        TempLoyaltyPointsSetupRequest.TransferFields(TempLoyaltyPointsSetupEligible, true);

                        if (Coupon.Get(LoyaltyPointManagement.IssueOneCoupon(MembershipEntryNo, TempLoyaltyPointsSetupRequest, DocumentNo, DocumentDate, OrderValue))) then begin
                            TempCoupon.TransferFields(Coupon, true);
                            TempCoupon.Insert();
                        end;
                    end;
                until (TempLoyaltyPointsSetupRequest.Next() = 0);

            if (not TempCoupon.IsEmpty()) then begin
                HelperFunctions.SetCouponResponse(MembershipEntryNo, TempCoupon, ResponseMessage);
                Commit();
            end else
                HelperFunctions.SetErrorResponse('No coupons created.', '');
        end else
            HelperFunctions.SetErrorResponse('Invalid Search Value.', '');

        if (HelperFunctions.GetResponseCode() = 'OK') or (HelperFunctions.GetResponseCode() = 'WARNING') then begin
            ResponseJson := CreateCoupon(ResponseJson, TempCoupon, MembershipEntryNo, DateValidFromDate, DateValidUntilDate, DocumentDate);
            exit(Response.RespondOK(ResponseJson));
        end else
            Response.RespondBadRequest(HelperFunctions.GetErrorResponse());
    end;

    internal procedure ListCoupon(_Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Membership: Record "NPR MM Membership";
        Coupon: Record "NPR NpDc Coupon";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        ResponseJson: Codeunit "NPR Json Builder";
        MembershipEntryNo: Integer;
        MembershipNumber: Code[20];
        ResponseMessage: Text;
        DateValidFromDate, DateValidUntilDate : Date;
    begin
#pragma warning disable AA0139
        MembershipNumber := HelperFunctions.GetQueryParameterFromRequest(_Request, 'membershipNumber');
#pragma warning restore

        if (MembershipNumber <> '') then
            MembershipEntryNo := MembershipManagement.GetMembershipFromExtMembershipNo(MembershipNumber);

        if (MembershipEntryNo > 0) then begin
            if (Membership.Get(MembershipEntryNo)) then
                if (Membership."Customer No." <> '') then begin
                    Coupon.SetFilter("Customer No.", '=%1', Membership."Customer No.");
                    Coupon.SetFilter("Starting Date", '=%1|<=%2', 0DT, CurrentDateTime());
                    Coupon.SetFilter("Ending Date", '=%1|>=%2', 0DT, CurrentDateTime());
                    Coupon.SetAutoCalcFields("In-use Quantity", "Remaining Quantity");
                    if (Coupon.FindSet()) then
                        repeat
                            TempCoupon.TransferFields(Coupon, true);
                            if (Coupon."In-use Quantity" < Coupon."Remaining Quantity") then
                                TempCoupon.Insert();
                        until (Coupon.Next() = 0);
                end;

            if (not TempCoupon.IsEmpty()) then begin
                HelperFunctions.SetCouponResponse(MembershipEntryNo, TempCoupon, ResponseMessage);
                Commit();
            end else
                HelperFunctions.SetErrorResponse('No coupons available.', '');
        end else
            HelperFunctions.SetErrorResponse('Invalid Search Value.', '');

        if (HelperFunctions.GetResponseCode() = 'OK') or (HelperFunctions.GetResponseCode() = 'WARNING') then begin
            MembershipManagement.GetMembershipValidDate(MembershipEntryNo, Today, DateValidFromDate, DateValidUntilDate);

            ResponseJson := GetListCoupon(ResponseJson, TempCoupon, Membership, DateValidFromDate, DateValidUntilDate);
            exit(Response.RespondOK(ResponseJson));
        end else
            Response.RespondBadRequest(HelperFunctions.GetErrorResponse());
    end;

    internal procedure DeleteCoupon(_Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Membership: Record "NPR MM Membership";
        Coupon: Record "NPR NpDc Coupon";
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcExtCouponReservation: Record "NPR NpDc Ext. Coupon Reserv.";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
        ResponseJson: Codeunit "NPR Json Builder";
        MembershipEntryNo, CurrSaleCouponCount : Integer;
        MembershipNumber: Code[20];
        CouponReferenceNo: Text;
        DocumentDate: Date;
    begin
#pragma warning disable AA0139
        MembershipNumber := _Request.Paths().Get(4);
        CouponReferenceNo := _Request.Paths().Get(5);
#pragma warning restore
        DocumentDate := Today();

        if (MembershipNumber <> '') then
            MembershipEntryNo := MembershipManagement.GetMembershipFromExtMembershipNo(MembershipNumber);

        if (MembershipEntryNo > 0) then begin
            if (Membership.Get(MembershipEntryNo)) then
                if (Membership."Customer No." <> '') then begin
                    Coupon.SetFilter("Customer No.", '=%1', Membership."Customer No.");
                    Coupon.SetFilter("Starting Date", '=%1|<=%2', 0DT, CurrentDateTime());
                    Coupon.SetFilter("Ending Date", '=%1|>=%2', 0DT, CurrentDateTime());
                    Coupon.SetFilter("Reference No.", '=%1', CouponReferenceNo);
                    Coupon.SETAUTOCALCFIELDS("In-use Quantity", "Remaining Quantity");
                    if (Coupon.FindFirst()) then begin
                        NpDcSaleLinePOSCoupon.SetFilter(Type, '=%1', NpDcSaleLinePOSCoupon.Type::Coupon);
                        NpDcSaleLinePOSCoupon.SetFilter("Coupon No.", '=%1', Coupon."No.");
                        CurrSaleCouponCount := NpDcSaleLinePOSCoupon.Count();

                        NpDcExtCouponReservation.SetFilter("Coupon No.", '=%1', Coupon."No.");
                        CurrSaleCouponCount += NpDcExtCouponReservation.Count();

                        if (CurrSaleCouponCount > 0) then
                            HelperFunctions.SetErrorResponse('Coupon has been applied to a sale, coupon reservation must be cancelled before it can be deleted.', '')
                        else
                            if (LoyaltyPointManagement.UnRedeemPointsCoupon(0, '', Today(), Coupon."No.")) then begin
                                Coupon.Delete();
                                HelperFunctions.SetResponse('OK');
                                Commit();
                            end;
                    end else
                        HelperFunctions.SetErrorResponse('Invalid coupon reference.', '');
                end;
        end else
            HelperFunctions.SetErrorResponse('Invalid Search Value.', '');

        if (HelperFunctions.GetResponseCode() = 'OK') or (HelperFunctions.GetResponseCode() = 'WARNING') then begin
            ResponseJson.StartObject('response')
                            .AddObject(HelperFunctions.GetStatusResponse(ResponseJson))
                        .EndObject();

            exit(Response.RespondOK(ResponseJson));
        end else
            exit(Response.RespondBadRequest(HelperFunctions.GetErrorResponse()));
    end;

    local procedure GetCouponEligibility(MembershipNumber: Code[20]; CardNumber: Text[100]; CustomerNumber: Code[20]; OrderValue: Decimal; DocumentDate: Date) Response: Codeunit "NPR API Response"
    var
        Membership: Record "NPR MM Membership";
        TempLoyaltyPointsSetup: Record "NPR MM Loyalty Point Setup" temporary;
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
        ResponseJson: Codeunit "NPR JSON Builder";
        MembershipEntryNo: Integer;
        DateValidFromDate, DateValidUntilDate : Date;
        ResponseMessage: Text;
    begin
        if (CardNumber <> '') then
            MembershipEntryNo := MembershipManagement.GetMembershipFromExtCardNo(CardNumber, Today, ResponseMessage);

        if (MembershipNumber <> '') then
            MembershipEntryNo := MembershipManagement.GetMembershipFromExtMembershipNo(MembershipNumber);

        if (CustomerNumber <> '') then
            MembershipEntryNo := MembershipManagement.GetMembershipFromCustomerNo(CustomerNumber);

        if (MembershipEntryNo > 0) then begin
            LoyaltyPointManagement.GetCouponToRedeemWS(MembershipEntryNo, TempLoyaltyPointsSetup, OrderValue, ResponseMessage);

            Clear(Membership);
            Membership.SetRange("Entry No.", MembershipEntryNo);
            Membership.SetFilter("Date Filter", '..%1', DocumentDate);
            Membership.FindFirst();
            Membership.CalcFields("Awarded Points (Sale)", "Awarded Points (Refund)", "Redeemed Points (Withdrawl)", "Redeemed Points (Deposit)", "Expired Points", "Remaining Points");

            MembershipManagement.GetMembershipValidDate(Membership."Entry No.", Today(), DateValidFromDate, DateValidUntilDate);

            HelperFunctions.SetLoyaltyPointsSetupResponse(MembershipEntryNo, TempLoyaltyPointsSetup, ResponseMessage);
        end else begin
            HelperFunctions.SetErrorResponse('Invalid Search Value.', '');
        end;

        if (HelperFunctions.GetResponseCode() = 'OK') or (HelperFunctions.GetResponseCode() = 'WARNING') then begin
            ResponseJson := AddMembershipResponse(ResponseJson, Membership, TempLoyaltyPointsSetup, DateValidFromDate, DateValidUntilDate, DocumentDate);
            exit(Response.RespondOK(ResponseJson));
        end else
            exit(Response.RespondBadRequest(HelperFunctions.GetErrorResponse()));
    end;

    local procedure AddMembershipResponse(var ResponseJson: Codeunit "NPR JSON Builder"; var Membership: Record "NPR MM Membership"; var TempLoyaltyPointsSetup: Record "NPR MM Loyalty Point Setup" temporary; DateValidFromDate: Date; DateValidUntilDate: Date; DocumentDate: Date): Codeunit "NPR Json Builder"
    begin
        ResponseJson.StartObject('response')
                        .AddObject(HelperFunctions.GetStatusResponse(ResponseJson))
                        .StartObject('membership')
                            .AddObject(HelperFunctions.AddMembershipProperties(ResponseJson, false, Membership, DateValidFromDate, DateValidUntilDate))
                            .StartObject('accumulated')
                                .AddProperty('untilDate', Format(CalcDate('<-1D>', DocumentDate), 0, 9))
                                .StartObject('awarded')
                                    .AddProperty('sales', Membership."Awarded Points (Sale)")
                                    .AddProperty('refund', Membership."Awarded Points (Refund)")
                                .EndObject()
                                .StartObject('redeemed')
                                    .AddProperty('withdrawal', Membership."Redeemed Points (Withdrawl)")
                                    .AddProperty('deposit', Membership."Redeemed Points (Deposit)")
                                .EndObject()
                                .AddProperty('expired', Membership."Expired Points")
                                .AddProperty('remaining', Membership."Remaining Points")
                            .EndObject()
                        .EndObject()
                        .AddObject(GetCouponsDTO(ResponseJson, TempLoyaltyPointsSetup))
                    .EndObject();

        exit(ResponseJson);
    end;

    local procedure GetCouponsDTO(var ResponseJson: Codeunit "NPR JSON Builder"; var TmpLoyaltyPointsSetupResponse: Record "NPR MM Loyalty Point Setup" temporary): Codeunit "NPR Json Builder"
    begin
        ResponseJson.StartArray('coupons');

        repeat
            ResponseJson.StartObject()
                            .AddProperty('code', TmpLoyaltyPointsSetupResponse.Code)
                            .AddProperty('line', TmpLoyaltyPointsSetupResponse."Line No.")
                            .AddProperty('description', TmpLoyaltyPointsSetupResponse.Description)
                            .AddProperty('points', TmpLoyaltyPointsSetupResponse."Points Threshold")
                            .AddProperty('amount', TmpLoyaltyPointsSetupResponse."Amount LCY")
                            .AddProperty('discountPercent', TmpLoyaltyPointsSetupResponse."Discount %")
                            .AddProperty('discountAmount', TmpLoyaltyPointsSetupResponse."Discount Amount")
                        .EndObject();
        until TmpLoyaltyPointsSetupResponse.Next() = 0;

        ResponseJson.EndArray();
        exit(ResponseJson);
    end;

    local procedure GetCouponLines(JTokCoupons: JsonToken; var TmpLoyaltyPointsSetupRequest: Record "NPR MM Loyalty Point Setup" temporary)
    var
        JsonMgmt: Codeunit "NPR Json Helper";
        Line: JsonToken;
    begin
        if JTokCoupons.AsArray().Count <= 0 then
            exit;

        foreach Line in JTokCoupons.AsArray() do begin
            TmpLoyaltyPointsSetupRequest.Init();
            TmpLoyaltyPointsSetupRequest.Code := CopyStr(JsonMgmt.GetJCode(Line, 'code', false), 1, MaxStrLen(TmpLoyaltyPointsSetupRequest.Code));
            TmpLoyaltyPointsSetupRequest."Line No." := JsonMgmt.GetJInteger(Line, 'line', false);
            TmpLoyaltyPointsSetupRequest.Insert();
        end;
    end;

    local procedure CreateCoupon(var ResponseJson: Codeunit "NPR JSON Builder"; var TempCoupon: Record "NPR NpDc Coupon" temporary; MembershipEntryNo: Integer; DateValidFromDate: Date; DateValidUntilDate: Date; DocumentDate: Date): Codeunit "NPR Json Builder"
    var
        Membership: Record "NPR MM Membership";
    begin
        if ((MembershipEntryNo <= 0) or (not Membership.Get(MembershipEntryNo))) then begin
            HelperFunctions.SetErrorResponse('Invalid membership entry no.', '');
            exit;
        end;

        Membership.SetRange("Entry No.", MembershipEntryNo);
        Membership.SetFilter("Date Filter", '..%1', DocumentDate);
        Membership.FindFirst();
        Membership.CalcFields("Awarded Points (Sale)", "Awarded Points (Refund)", "Redeemed Points (Withdrawl)", "Redeemed Points (Deposit)", "Expired Points", "Remaining Points");

        ResponseJson.StartObject('response')
                        .AddObject(HelperFunctions.GetStatusResponse(ResponseJson))
                        .StartObject('membership')
                            .AddObject(HelperFunctions.AddMembershipProperties(ResponseJson, false, Membership, DateValidFromDate, DateValidUntilDate))
                            .StartObject('accumulated')
                                .AddProperty('untilDate', Format(CalcDate('<-1D>', DocumentDate), 0, 9))
                                .StartObject('awarded')
                                    .AddProperty('sales', Membership."Awarded Points (Sale)")
                                    .AddProperty('refund', Membership."Awarded Points (Refund)")
                                .EndObject()
                                .StartObject('redeemed')
                                    .AddProperty('withdrawal', Membership."Redeemed Points (Withdrawl)")
                                    .AddProperty('deposit', Membership."Redeemed Points (Deposit)")
                                .EndObject()
                                .AddProperty('expired', Membership."Expired Points")
                                .AddProperty('remaining', Membership."Remaining Points")
                            .EndObject()
                        .EndObject()
                        .StartObject('coupons')
                            .AddObject(GetCouponsResponseDTO(ResponseJson, TempCoupon))
                        .EndObject()
                    .EndObject();

        exit(ResponseJson);
    end;

    local procedure GetCouponsResponseDTO(var ResponseJson: Codeunit "NPR JSON Builder"; var TempCoupon: Record "NPR NpDc Coupon" temporary): Codeunit "NPR Json Builder"
    begin
        ResponseJson.StartArray('coupon');

        repeat
            ResponseJson.StartObject()
                            .AddProperty('reference', TempCoupon."Reference No.")
                            .AddProperty('description', TempCoupon.Description)
                            .AddProperty('discountType', TempCoupon."Discount Type")
                            .AddProperty('discountAmount', TempCoupon."Discount Amount")
                            .AddProperty('discountPercent', TempCoupon."Discount %")
                        .EndObject();
        until TempCoupon.Next() = 0;

        ResponseJson.EndArray();
        exit(ResponseJson);
    end;

    local procedure GetListCoupon(var ResponseJson: Codeunit "NPR JSON Builder"; var TempCoupon: Record "NPR NpDc Coupon" temporary; Membership: Record "NPR MM Membership"; DateValidFromDate: Date; DateValidUntilDate: Date): Codeunit "NPR Json Builder"
    begin
        ResponseJson.StartObject('response')
                        .AddObject(HelperFunctions.GetStatusResponse(ResponseJson))
                        .AddObject(HelperFunctions.AddMembershipProperties(ResponseJson, true, Membership, DateValidFromDate, DateValidUntilDate))
                        .AddArray(GetAvailableCouponsDTO(ResponseJson, TempCoupon))
                    .EndObject();

        exit(ResponseJson);
    end;

    local procedure GetAvailableCouponsDTO(var ResponseJson: Codeunit "NPR JSON Builder"; var TempCoupon: Record "NPR NpDc Coupon" temporary): Codeunit "NPR Json Builder"
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        ResponseJson.StartArray('availableCoupons');
        GeneralLedgerSetup.Get();

        repeat
            ResponseJson.StartObject()
                            .AddProperty('reference', TempCoupon."Reference No.")
                            .AddProperty('description', TempCoupon.Description)
                            .AddProperty('discountType', TempCoupon."Discount Type")
                            .AddProperty('discountAmount', TempCoupon."Discount Amount")
                            .AddProperty('currencyCode', GeneralLedgerSetup."LCY Code")
                            .AddProperty('discountPercent', TempCoupon."Discount %")
                        .EndObject();
        until TempCoupon.Next() = 0;

        ResponseJson.EndArray();

        exit(ResponseJson);
    end;
}
#endif