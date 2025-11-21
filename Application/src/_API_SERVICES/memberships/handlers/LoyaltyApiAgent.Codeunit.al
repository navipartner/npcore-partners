#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248490 "NPR LoyaltyApiAgent"
{
    Access = Internal;

    var
        ReservationNotFoundLbl: Label 'The authorization code %1 is not valid.', Locked = true;

    internal procedure GetMembershipPoints(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Membership: Record "NPR MM Membership";
        TempLoyaltyPointsSetup: Record "NPR MM Loyalty Point Setup" temporary;
        MembershipApiAgent: Codeunit "NPR MembershipApiAgent";
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
        Redeemable: Integer;
        PointsValue: Decimal;
        ReasonText: Text;
    begin
        if (not MembershipApiAgent.GetMembershipById(Request, 2, Membership)) then
            exit(Response.RespondBadRequest('Invalid Membership - Membership Id not valid.'));
        if IsLoyaltyAsYouGo(Membership.SystemId) then begin
            Membership.CalcFields("Remaining Points");
            Redeemable := Membership."Remaining Points";
            PointsValue := Membership."Remaining Points" * LoyaltyBurnRate(Membership.SystemId);
        end else
            if (LoyaltyPointManagement.GetCouponToRedeemWS(Membership."Entry No.", TempLoyaltyPointsSetup, 1000000000, ReasonText)) then begin
                Redeemable := LoyaltyPointManagement.CalculateRedeemablePointsCurrentPeriod(Membership."Entry No.");
                TempLoyaltyPointsSetup.Reset();
                TempLoyaltyPointsSetup.SetCurrentKey(Code, "Amount LCY");
                TempLoyaltyPointsSetup.FindLast();
                PointsValue := Redeemable * TempLoyaltyPointsSetup."Point Rate";
            end;
        Response.RespondOK(PointBalance(Redeemable, PointsValue));
    end;

    internal procedure CreateReservationTransaction(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Membership: Record "NPR MM Membership";
        TempAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        TempRegSalesBuffer: Record "NPR MM Reg. Sales Buffer" temporary;
        MembershipApiAgent: Codeunit "NPR MembershipApiAgent";
    begin
        if (not MembershipApiAgent.GetMembershipById(Request, 2, Membership)) then
            exit(Response.RespondBadRequest('Invalid Membership - Membership Id not valid.'));

        ValidateReservePointsRequest(Membership.SystemId, Request, TempAuthorization, TempRegSalesBuffer);
        TempAuthorization.Modify(false);
        exit(ProcessReservePointsRequest(Membership.SystemId, TempAuthorization, TempRegSalesBuffer));
    end;

    internal procedure CancelReservationTransaction(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Membership: Record "NPR MM Membership";
        ReservationLedgerEntry: Record "NPR MM Loy. LedgerEntry (Srvr)";
        TempAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        TempCancelLine: Record "NPR MM Reg. Sales Buffer" temporary;
        TempPointsOut: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        MembershipApiAgent: Codeunit "NPR MembershipApiAgent";
        LoyaltyPointsMgrServer: Codeunit "NPR MM Loy. Point Mgr (Server)";
        JsonHelper: Codeunit "NPR Json Helper";
        Body: JsonToken;
        AuthorizationCode: Text;
        ResponseMessage: Text;
        ResponseMessageId: Text;
    begin
        if not MembershipApiAgent.GetMembershipById(Request, 2, Membership) then
            exit(Response.RespondBadRequest('Invalid Membership - Membership Id not valid.'));
        Body := Request.BodyJson();
        AuthorizationCode := JsonHelper.GetJText(Body, 'authorizationCode', true);
        if StrLen(AuthorizationCode) > MaxStrLen(ReservationLedgerEntry."Authorization Code") then
            exit(Response.RespondBadRequest(StrSubstNo(ReservationNotFoundLbl, AuthorizationCode)));

        if not GetReservationEntryFromAuthorization(ReservationLedgerEntry, AuthorizationCode) then
            exit(Response.RespondBadRequest(StrSubstNo(ReservationNotFoundLbl, AuthorizationCode)));
        MakeAuthorization(TempAuthorization, ReservationLedgerEntry);
        MakeRegSalesBuffer(TempCancelLine, AuthorizationCode, TempCancelLine.Type::CANCEL_RESERVATION);
        if LoyaltyPointsMgrServer.CancelReservation(TempAuthorization, TempCancelLine, TempPointsOut, ResponseMessage, ResponseMessageId, Membership.SystemId, 1) then
            exit(Response.RespondOK(ReservationResponse(TempPointsOut.Balance)))
        else
            exit(Response.RespondBadRequest(StrSubstNo('%1 %2', ResponseMessageId, ResponseMessage)));
    end;

    internal procedure RegisterSaleTransaction(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Membership: Record "NPR MM Membership";
        TempAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        TempSaleLineBuffer: Record "NPR MM Reg. Sales Buffer" temporary;
        TempPaymentLineBuffer: Record "NPR MM Reg. Sales Buffer" temporary;
        MembershipApiAgent: Codeunit "NPR MembershipApiAgent";

    begin
        if (not MembershipApiAgent.GetMembershipById(Request, 2, Membership)) then
            exit(Response.RespondBadRequest('Invalid Membership - Membership Id not valid.'));

        ValidateRegisterSaleRequest(Membership.SystemId, Request, TempAuthorization, TempSaleLineBuffer, TempPaymentLineBuffer);
        TempAuthorization.Modify(false);
        exit(ProcessRegisterSaleRequest(Membership.SystemId, TempAuthorization, TempSaleLineBuffer, TempPaymentLineBuffer));
    end;

    local procedure GetReservationEntryFromAuthorization(var ReservationLedgerEntry: Record "NPR MM Loy. LedgerEntry (Srvr)"; AuthorizationCode: Text): Boolean
    var
    begin
        ReservationLedgerEntry.SetCurrentKey("Authorization Code");
        ReservationLedgerEntry.SetRange("Authorization Code", AuthorizationCode);
        ReservationLedgerEntry.SetRange("Entry Type", ReservationLedgerEntry."Entry Type"::RESERVE);
        exit(ReservationLedgerEntry.FindFirst());
    end;

    local procedure MakeAuthorization(var TempAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary; ReservationLedgerEntry: Record "NPR MM Loy. LedgerEntry (Srvr)")
    begin
        TempAuthorization.Init();
        TempAuthorization."Entry No." := 0;
        TempAuthorization."Company Name" := ReservationLedgerEntry."Company Name";
        TempAuthorization."POS Store Code" := ReservationLedgerEntry."POS Store Code";
        TempAuthorization."POS Unit Code" := ReservationLedgerEntry."POS Unit Code";
        TempAuthorization."Reference Number" := ReservationLedgerEntry."Reference Number";
        TempAuthorization."Transaction Date" := Today;
        TempAuthorization."Transaction Time" := Time;
        TempAuthorization."Authorization Code" := '';
        TempAuthorization.Insert(false);
    end;

    local procedure MakeRegSalesBuffer(var TempCancelLine: Record "NPR MM Reg. Sales Buffer" temporary; AuthorizationCode: Text; Type: Integer)
    begin
        TempCancelLine.Init();
        TempCancelLine."Authorization Code" := CopyStr(AuthorizationCode, 1, MaxStrLen(TempCancelLine."Authorization Code"));
        TempCancelLine.Type := Type;
        TempCancelLine.Insert(false);
    end;

    local procedure PointBalance(RemainingPoints: Integer; PointsValue: Decimal): Codeunit "NPR Json Builder"
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        JsonBuilder: Codeunit "NPR Json Builder";
    begin
        GeneralLedgerSetup.SetLoadFields("LCY Code");
        GeneralLedgerSetup.Get();
        JsonBuilder.StartObject()
            .AddProperty('balance', RemainingPoints)
            .AddProperty('valueAsCurrency', PointsValue)
            .AddProperty('currencyCode', GeneralLedgerSetup."LCY Code")
            .EndObject();
        exit(JsonBuilder);
    end;

    local procedure ValidateReservePointsRequest(MembershipSystemId: Guid; var Request: Codeunit "NPR API Request"; var TempAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary; var TempRegSalesBuffer: Record "NPR MM Reg. Sales Buffer" temporary)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        JsonHelper: Codeunit "NPR Json Helper";
        Body: JsonToken;
        ExpiresAtMinutes: Integer;
        RequestType: Option WITHDRAW,DEPOSIT;
    begin
        Body := Request.BodyJson();
        TempAuthorization.Init();
#pragma warning disable AA0139        
        TempAuthorization."POS Store Code" := JsonHelper.GetJCode(Body, 'externalSystemIdentifier', true);
        TempAuthorization."Reference Number" := JsonHelper.GetJCode(Body, 'externalReferenceNo', true);
        TempAuthorization."Foreign Transaction Id" := JsonHelper.GetJText(Body, 'requestId', true);
        TempAuthorization."POS Unit Code" := JsonHelper.GetJCode(Body, 'externalSystemUserIdentifier', false);
        TempAuthorization."Company Name" := JsonHelper.GetJText(Body, 'externalBusinessUnitIdentifier', false);
#pragma warning restore AA0139        
        Evaluate(RequestType, JsonHelper.GetJText(Body, 'type', true));
        TempAuthorization."Transaction Date" := Today;
        TempAuthorization."Transaction Time" := Time;
        ExpiresAtMinutes := JsonHelper.GetJInteger(Body, 'timeoutPeriod', false);
        if ExpiresAtMinutes > 0 then
            TempAuthorization."Expires At" := CurrentDateTime + ExpiresAtMinutes * 60 * 1000;
        TempAuthorization."Entry Type" := TempAuthorization."Entry Type"::RESERVE;
        TempAuthorization.Insert();

        TempRegSalesBuffer.Init();
        TempRegSalesBuffer.Quantity := 1;
#pragma warning disable AA0139        
        TempRegSalesBuffer.Description := JsonHelper.GetJText(Body, 'reason', true);
#pragma warning restore AA0139        
        TempRegSalesBuffer."Total Points" := JsonHelper.GetJInteger(Body, 'pointsToReserve', true);
        if TempRegSalesBuffer."Total Points" < 0 then
            Error('pointsToReserve must be a positive integer');
        if RequestType = RequestType::WITHDRAW then
            TempRegSalesBuffer.Type := TempRegSalesBuffer.Type::PAYMENT
        else begin
            TempRegSalesBuffer.Type := TempRegSalesBuffer.Type::REFUND;
            TempRegSalesBuffer."Total Points" := -TempRegSalesBuffer."Total Points";
        end;
        TempRegSalesBuffer."Total Amount" := TempRegSalesBuffer."Total Points" * LoyaltyBurnRate(MembershipSystemId);

        GeneralLedgerSetup.SetLoadFields("LCY Code");
        GeneralLedgerSetup.Get();
        TempRegSalesBuffer."Currency Code" := GeneralLedgerSetup."LCY Code";
        TempRegSalesBuffer.Insert();

    end;

    local procedure ValidateRegisterSaleRequest(MembershipSystemId: Guid; var Request: Codeunit "NPR API Request"; var TempAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary; var TempSaleLineBuffer: Record "NPR MM Reg. Sales Buffer" temporary; var TempPaymentLineBuffer: Record "NPR MM Reg. Sales Buffer" temporary)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        ReservationLedgerEntry: Record "NPR MM Loy. LedgerEntry (Srvr)";
        JsonHelper: Codeunit "NPR Json Helper";
        Body: JsonToken;
        PointItems: JsonToken;
        PointItem: JsonToken;
        Reservations: JsonToken;
        Reservation: JsonToken;
        AuthorizationCode: Text;
    begin
        Body := Request.BodyJson();
        TempAuthorization.Init();
#pragma warning disable AA0139        
        TempAuthorization."POS Store Code" := JsonHelper.GetJCode(Body, 'externalSystemIdentifier', true);
        TempAuthorization."Reference Number" := JsonHelper.GetJCode(Body, 'externalReferenceNo', true);
        TempAuthorization."Foreign Transaction Id" := JsonHelper.GetJText(Body, 'requestId', true);
        TempAuthorization."POS Unit Code" := JsonHelper.GetJCode(Body, 'externalSystemUserIdentifier', false);
        TempAuthorization."Company Name" := JsonHelper.GetJText(Body, 'externalBusinessUnitIdentifier', false);
#pragma warning restore AA0139        
        TempAuthorization."Transaction Date" := Today;
        TempAuthorization."Transaction Time" := Time;
        TempAuthorization."Entry Type" := TempAuthorization."Entry Type"::RECEIPT;
        TempAuthorization.Insert();

        GeneralLedgerSetup.SetLoadFields("LCY Code");
        GeneralLedgerSetup.Get();

        if JsonHelper.GetJsonToken(Body, 'items', PointItems) then
            foreach PointItem in PointItems.AsArray() do begin
                TempSaleLineBuffer.Init();
                TempSaleLineBuffer."Entry No." += 1;
                TempSaleLineBuffer."Item No." := CopyStr(JsonHelper.GetJCode(PointItem, 'itemCode', true), 1, MaxStrLen(TempSaleLineBuffer."Item No."));
                TempSaleLineBuffer."Total Points" := JsonHelper.GetJInteger(PointItem, 'pointsEarned', true);
                if TempSaleLineBuffer."Total Points" >= 0 then
                    TempSaleLineBuffer.Type := TempSaleLineBuffer.Type::SALES
                else
                    TempSaleLineBuffer.Type := TempSaleLineBuffer.Type::RETURN;
                TempSaleLineBuffer."Variant Code" := CopyStr(JsonHelper.GetJCode(PointItem, 'variantCode', false), 1, MaxStrLen(TempSaleLineBuffer."Variant Code"));
                TempSaleLineBuffer.Quantity := JsonHelper.GetJDecimal(PointItem, 'quantity', false);
                TempSaleLineBuffer.Description := CopyStr(JsonHelper.GetJText(PointItem, 'description', false), 1, MaxStrLen(TempSaleLineBuffer.Description));
                TempSaleLineBuffer."Total Amount" := JsonHelper.GetJDecimal(PointItem, 'amountInclVAT', false);
                TempSaleLineBuffer."Currency Code" := GeneralLedgerSetup."LCY Code";
                TempSaleLineBuffer.Insert();
            end;
        if JsonHelper.GetJsonToken(Body, 'reservations', Reservations) then
            foreach Reservation in Reservations.AsArray() do begin
                TempPaymentLineBuffer.Init();
                TempPaymentLineBuffer."Entry No." += 1;
                AuthorizationCode := JsonHelper.GetJText(Reservation, 'authorizationCode', true);
                if StrLen(AuthorizationCode) > MaxStrLen(ReservationLedgerEntry."Authorization Code") then
                    Error(ReservationNotFoundLbl, AuthorizationCode);
                if not GetReservationEntryFromAuthorization(ReservationLedgerEntry, AuthorizationCode) then
                    Error(ReservationNotFoundLbl, AuthorizationCode);
                TempPaymentLineBuffer."Authorization Code" := CopyStr(AuthorizationCode, 1, MaxStrLen(TempPaymentLineBuffer."Authorization Code"));
                TempPaymentLineBuffer."Currency Code" := GeneralLedgerSetup."LCY Code";
                TempPaymentLineBuffer."Total Points" := -ReservationLedgerEntry."Burned Points";
                if TempSaleLineBuffer.IsEmpty then
                    TempPaymentLineBuffer.Type := TempPaymentLineBuffer.Type::CAPTURE
                else
                    if TempPaymentLineBuffer."Total Points" >= 0 then
                        TempPaymentLineBuffer.Type := TempPaymentLineBuffer.Type::PAYMENT
                    else
                        TempPaymentLineBuffer.Type := TempPaymentLineBuffer.Type::REFUND;
                TempPaymentLineBuffer."Total Amount" := TempPaymentLineBuffer."Total Points" * LoyaltyBurnRate(MembershipSystemId);
                TempPaymentLineBuffer.Insert();
            end;

    end;

    local procedure ProcessRegisterSaleRequest(MembershipSystemId: Guid; var TempAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary; var TempSalesLineBuffer: Record "NPR MM Reg. Sales Buffer" temporary; var TempPaymentLineBuffer: Record "NPR MM Reg. Sales Buffer" temporary) Response: Codeunit "NPR API Response"
    var
        TempPointsResponse: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        LoyaltyPointsMgrServer: Codeunit "NPR MM Loy. Point Mgr (Server)";
        ResponseMessage: Text;
        ResponseMessageId: Text;
        Success: Boolean;
    begin
        if TempSalesLineBuffer.IsEmpty then
            Success := LoyaltyPointsMgrServer.CaptureReservation(TempAuthorization, TempPaymentLineBuffer, TempPointsResponse, ResponseMessage, ResponseMessageId, MembershipSystemId, 1)
        else
            Success := LoyaltyPointsMgrServer.RegisterSales(TempAuthorization, TempSalesLineBuffer, TempPaymentLineBuffer, TempPointsResponse, ResponseMessage, ResponseMessageId, MembershipSystemId, 1);
        if Success then
            exit(Response.RespondOK(RegisterSaleResponse(TempPointsResponse."Earned Points", -TempPointsResponse."Burned Points", TempPointsResponse.Balance)))
        else
            exit(Response.RespondBadRequest(StrSubstNo('%1 %2', ResponseMessageId, ResponseMessage)));
    end;

    local procedure ProcessReservePointsRequest(MembershipSystemId: Guid; var TempAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary; var TempRegSalesBuffer: Record "NPR MM Reg. Sales Buffer" temporary) Response: Codeunit "NPR API Response"
    var
        TempPointsResponse: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        LoyaltyPointsMgrServer: Codeunit "NPR MM Loy. Point Mgr (Server)";
        ResponseMessage: Text;
        ResponseMessageId: Text;
    begin
        if (LoyaltyPointsMgrServer.ReservePoints(TempAuthorization, TempRegSalesBuffer, TempPointsResponse, ResponseMessage, ResponseMessageId, MembershipSystemId, 1)) then
            exit(Response.RespondOK(AuthorizeResponse(TempPointsResponse."Authorization Code", TempPointsResponse."Expires At")))
        else
            exit(Response.RespondBadRequest(StrSubstNo('%1 %2', ResponseMessageId, ResponseMessage)));
    end;

    local procedure AuthorizeResponse(AuthorizationCode: Text; ExpireAt: DateTime): Codeunit "NPR Json Builder"
    var
        JsonBuilder: Codeunit "NPR Json Builder";
    begin
        JsonBuilder.StartObject();
        if AuthorizationCode <> '' then
            JsonBuilder.AddProperty('authorizationCode', AuthorizationCode);
        if ExpireAt <> 0DT then
            JsonBuilder.AddProperty('expiresAt', ExpireAt);
        JsonBuilder.EndObject();
        exit(JsonBuilder);
    end;

    local procedure ReservationResponse(Balance: Integer): Codeunit "NPR Json Builder"
    var
        JsonBuilder: Codeunit "NPR Json Builder";
    begin
        JsonBuilder.StartObject()
            .AddProperty('newBalance', Balance)
            .EndObject();
        exit(JsonBuilder);
    end;

    local procedure RegisterSaleResponse(PointsEarned: Integer; PointsCaptured: Integer; Balance: Integer): Codeunit "NPR Json Builder"
    var
        JsonBuilder: Codeunit "NPR Json Builder";
    begin
        JsonBuilder.StartObject()
            .AddProperty('pointsEarned', PointsEarned)
            .AddProperty('pointsCaptured', PointsCaptured)
            .AddProperty('newBalance', Balance)
            .EndObject();
        exit(JsonBuilder);
    end;

    local procedure LoyaltyBurnRate(MembershipSystemId: Guid): Decimal
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        LoyaltySetup: Record "NPR MM Loyalty Setup";

    begin
        Membership.SetLoadFields("Membership Code");
        if not Membership.GetBySystemId(MembershipSystemId) then
            exit(0);
        MembershipSetup.SetLoadFields("Loyalty Code");
        if not MembershipSetup.Get(Membership."Membership Code") then
            exit(0);
        LoyaltySetup.SetLoadFields("Point Rate");
        if not LoyaltySetup.Get(MembershipSetup."Loyalty Code") then
            exit(0);
        exit(LoyaltySetup."Point Rate");
    end;

    local procedure IsLoyaltyAsYouGo(MembershipSystemId: Guid): Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        LoyaltySetup: Record "NPR MM Loyalty Setup";
    begin
        Membership.SetLoadFields("Membership Code");
        if not Membership.GetBySystemId(MembershipSystemId) then
            exit(false);
        MembershipSetup.SetLoadFields("Loyalty Code");
        if not MembershipSetup.Get(Membership."Membership Code") then
            exit(false);
        LoyaltySetup.SetRange(Code, MembershipSetup."Loyalty Code");
        LoyaltySetup.SetRange("Collection Period", LoyaltySetup."Collection Period"::AS_YOU_GO);
        exit(not LoyaltySetup.IsEmpty());
    end;

}
#endif