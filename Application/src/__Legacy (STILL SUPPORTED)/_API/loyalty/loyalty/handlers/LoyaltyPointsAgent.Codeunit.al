#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248430 "NPR LoyaltyPointsAgent"
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-06-13';
    ObsoleteReason = 'This API is being phased out';

    var
        HelperFunctions: Codeunit "NPR Loyalty Helper Functions";
        ParametersMandatoryLbl: Label 'At least one parameter is mandatory in request.', Locked = true;

    trigger OnRun()
    begin

    end;

    internal procedure GetLoyaltyPoints(_Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        MembershipNumber, CardNumber, CustomerNumber : Text;
    begin
        MembershipNumber := HelperFunctions.GetQueryParameterFromRequest(_Request, 'membershipNumber');
        CardNumber := HelperFunctions.GetQueryParameterFromRequest(_Request, 'cardNumber');
        CustomerNumber := HelperFunctions.GetQueryParameterFromRequest(_Request, 'customerNumber');

        if (MembershipNumber = '') and (CardNumber = '') and (CustomerNumber = '') then
            exit(Response.RespondBadRequest(ParametersMandatoryLbl));

        Response := GetLoyaltyPoints(MembershipNumber, CardNumber, CustomerNumber);
    end;

    internal procedure GetLoyaltyPointEntries(_Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        CardNumber, MembershipNumber, CustomerNumber, TransactionsFromDateTxt : Text;
        TransactionsFromDate: Date;
    begin
        MembershipNumber := HelperFunctions.GetQueryParameterFromRequest(_Request, 'membershipNumber');
        CardNumber := HelperFunctions.GetQueryParameterFromRequest(_Request, 'cardNumber');
        CustomerNumber := HelperFunctions.GetQueryParameterFromRequest(_Request, 'customerNumber');
        TransactionsFromDateTxt := HelperFunctions.GetQueryParameterFromRequest(_Request, 'transactionsFromDate');

        if (TransactionsFromDateTxt <> '') then
            Evaluate(TransactionsFromDate, TransactionsFromDateTxt);

        if (TransactionsFromDate = 0D) then
            TransactionsFromDate := CalcDate('<-1M+CM+1D>', Today);

        if (MembershipNumber = '') and (CardNumber = '') and (CustomerNumber = '') then
            exit(Response.RespondBadRequest(ParametersMandatoryLbl));

        Response := GetLoyaltyPointEntries(CardNumber, MembershipNumber, CustomerNumber, TransactionsFromDate);
    end;

    procedure ReservePoints(_Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        TempAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        TempRegisterPaymentRequest: Record "NPR MM Reg. Sales Buffer" temporary;
        TempPointsResponse: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        LoyaltyPointsMgrServer: Codeunit "NPR MM Loy. Point Mgr (Server)";
        ResponseJson: Codeunit "NPR Json Builder";
        JToken, JTokReservationLines : JsonToken;
        ResponseMessage: Text;
        ResponseMessageId: Text;
    begin
        HelperFunctions.InsertAuthorizationHeader(_Request, TempAuthorization);

        JToken := _Request.BodyJson();
        JToken.SelectToken('reservation', JTokReservationLines);

        InsertPaymentRequest(JTokReservationLines, TempRegisterPaymentRequest);

        if (LoyaltyPointsMgrServer.ReservePoints(TempAuthorization, TempRegisterPaymentRequest, TempPointsResponse, ResponseMessage, ResponseMessageId)) then
            HelperFunctions.SetPointsResponse(TempPointsResponse)
        else
            HelperFunctions.SetErrorResponse(ResponseMessage, ResponseMessageId);

        if HelperFunctions.GetResponseCode() = 'OK' then
            exit(Response.RespondOK(HelperFunctions.GetResponseByFunctionName(ResponseJson, 'reservePoints')))
        else
            exit(Response.RespondBadRequest(HelperFunctions.GetErrorResponse()))
    end;

    internal procedure CancelReservePoints(_Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        TempAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        TempCancelReservationRequest: Record "NPR MM Reg. Sales Buffer" temporary;
        TempPointsResponse: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        LoyaltyPointsMgrServer: Codeunit "NPR MM Loy. Point Mgr (Server)";
        ResponseJson: Codeunit "NPR Json Builder";
        JToken, JTokCancelReservation : JsonToken;
        ResponseMessage: Text;
        ResponseMessageId: Text;
    begin
        HelperFunctions.InsertAuthorizationHeader(_Request, TempAuthorization);

        JToken := _Request.BodyJson();
        JToken.SelectToken('cancelReservation', JTokCancelReservation);

        InsertCancelReservation(JTokCancelReservation, TempCancelReservationRequest);

        if (LoyaltyPointsMgrServer.CancelReservation(TempAuthorization, TempCancelReservationRequest, TempPointsResponse, ResponseMessage, ResponseMessageId)) then
            HelperFunctions.SetPointsResponse(TempPointsResponse)
        else
            HelperFunctions.SetErrorResponse(ResponseMessage, ResponseMessageId);

        if HelperFunctions.GetResponseCode() = 'OK' then
            exit(Response.RespondOK(HelperFunctions.GetResponseByFunctionName(ResponseJson, 'cancelReservePoints')))
        else
            exit(Response.RespondBadRequest(HelperFunctions.GetErrorResponse()))
    end;

    internal procedure CaptureReservePoints(_Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        TempAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        TempCaptureReservationRequest: Record "NPR MM Reg. Sales Buffer" temporary;
        TempPointsResponse: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        LoyaltyPointsMgrServer: Codeunit "NPR MM Loy. Point Mgr (Server)";
        ResponseJson: Codeunit "NPR Json Builder";
        JToken, JTokCaptureReservation : JsonToken;
        ResponseMessage: Text;
        ResponseMessageId: Text;
    begin
        HelperFunctions.InsertAuthorizationHeader(_Request, TempAuthorization);

        JToken := _Request.BodyJson();
        JToken.SelectToken('captureReservation', JTokCaptureReservation);

        InsertCaptureReservation(JTokCaptureReservation, TempCaptureReservationRequest);

        if (LoyaltyPointsMgrServer.CaptureReservation(TempAuthorization, TempCaptureReservationRequest, TempPointsResponse, ResponseMessage, ResponseMessageId)) then
            HelperFunctions.SetPointsResponse(TempPointsResponse)
        else
            HelperFunctions.SetErrorResponse(ResponseMessage, ResponseMessageId);

        if HelperFunctions.GetResponseCode() = 'OK' then
            exit(Response.RespondOK(HelperFunctions.GetResponseByFunctionName(ResponseJson, 'captureReservePoints')))
        else
            exit(Response.RespondBadRequest(HelperFunctions.GetErrorResponse()))
    end;

    local procedure GetLoyaltyPoints(MembershipNumber: Text; CardNumber: Text; CustomerNumber: Text) Response: Codeunit "NPR API Response"
    var
        Membership: Record "NPR MM Membership";
        LoyaltySetup: Record "NPR MM Loyalty Setup";
        MembershipEntry: Record "NPR MM Membership Entry";
        MemberCommunity: Record "NPR MM Member Community";
        MembershipSetup: Record "NPR MM Membership Setup";
        Temp_MembershipPointsSummary: Record "NPR MM Members. Points Summary" temporary;
        ResponseJson: Codeunit "NPR JSON Builder";
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
        MembershipEntryNo: Integer;
        CommunityName, MembershipName, UpgradeToName, DowngradeToName, UpgradeToLevel, UpgradeThreshold, DowngradeToLevel, DowngradeThreshold : Text;
        PointsEarnedValue, PointsRemainingValue, PointsEarnedCurrencyCode, PointsRemainingCurrencyCode, SpendPeriodStart, SpendPeriodEnd : Text;
    begin
        MembershipEntryNo := HelperFunctions.GetMembershipEntryNo(CardNumber, MembershipNumber, CustomerNumber);

        if ((MembershipEntryNo = 0) or (not Membership.Get(MembershipEntryNo))) then
            exit(Response.RespondBadRequest('Invalid membership entry no.'));

        Membership.CalcFields("Awarded Points (Sale)", "Awarded Points (Refund)", "Redeemed Points (Withdrawl)", "Redeemed Points (Deposit)", "Expired Points", "Remaining Points");

        MemberCommunity.Get(Membership."Community Code");
        MembershipSetup.Get(Membership."Membership Code");
        CommunityName := MemberCommunity.Description;
        MembershipName := MembershipSetup.Description;

        if (MemberCommunity."Activate Loyalty Program") then begin
            if (LoyaltySetup.Get(MembershipSetup."Loyalty Code")) then begin
                LoyaltyPointManagement.CalculateFixedPeriodPointsTransaction(LoyaltySetup, Membership, 0, Temp_MembershipPointsSummary); // Current period
                LoyaltyPointManagement.CalculateFixedPeriodPointsTransaction(LoyaltySetup, Membership, -1, Temp_MembershipPointsSummary); // Previous period
            end;
        end;

        GetNextLoyaltyTier(MembershipEntryNo, true, UpgradeToLevel, UpgradeThreshold, UpgradeToName);
        GetNextLoyaltyTier(MembershipEntryNo, false, DowngradeToLevel, DowngradeThreshold, DowngradeToName);
        GetPointsAndPeriod(MembershipEntryNo, PointsEarnedValue, PointsRemainingValue, PointsEarnedCurrencyCode, PointsRemainingCurrencyCode, SpendPeriodStart, SpendPeriodEnd);

        MembershipEntry.SetRange("Membership Entry No.", MembershipEntryNo);
        if MembershipEntry.FindLast() then;

        ResponseJson := CreateMembershipResponse(ResponseJson, Membership, MembershipEntry, Temp_MembershipPointsSummary, LoyaltySetup,
                                                CommunityName, MembershipName, UpgradeToName, DowngradeToName, UpgradeToLevel, UpgradeThreshold,
                                                DowngradeToLevel, DowngradeThreshold, PointsEarnedValue, PointsRemainingValue, PointsEarnedCurrencyCode,
                                                PointsRemainingCurrencyCode, SpendPeriodStart, SpendPeriodEnd);

        exit(Response.RespondOK(ResponseJson));
    end;

    local procedure GetLoyaltyPointEntries(CardNumber: Text; MembershipNumber: Text; CustomerNumber: Text; TransactionsFromDate: Date) Response: Codeunit "NPR API Response"
    var
        Membership: Record "NPR MM Membership";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        ResponseJson: Codeunit "NPR JSON Builder";
        MembershipEntryNo: Integer;
        ValidFromDate, ValidUntilDate : Date;
    begin
        MembershipEntryNo := HelperFunctions.GetMembershipEntryNo(CardNumber, MembershipNumber, CustomerNumber);

        if ((MembershipEntryNo = 0) or (not Membership.Get(MembershipEntryNo))) then
            exit(Response.RespondBadRequest('Invalid membership entry no.'));

        Membership.SetFilter("Date Filter", '>%1', TransactionsFromDate);

        Membership.CalcFields("Awarded Points (Sale)", "Awarded Points (Refund)", "Redeemed Points (Withdrawl)", "Redeemed Points (Deposit)", "Expired Points", "Remaining Points");

        MembershipManagement.GetMembershipValidDate(Membership."Entry No.", Today(), ValidFromDate, ValidUntilDate);

        ResponseJson.StartObject('membership')
                        .AddObject(HelperFunctions.AddMembershipProperties(ResponseJson, false, Membership, ValidFromDate, ValidUntilDate))
                        .StartObject('accumulated')
                            .AddProperty('untilDate', Format(CalcDate('<-1D>', TransactionsFromDate), 0, 9))
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
                        .StartArray('transactions').AddObject(GetTransactionDTO(ResponseJson, Membership."Entry No.", TransactionsFromDate)).EndArray();
        ResponseJson.EndObject();

        exit(Response.RespondOK(ResponseJson));
    end;

    local procedure GetTransactionDTO(var ResponseJson: Codeunit "NPR JSON Builder"; MembershipEntryNo: Integer; TransactionsFromDate: Date): Codeunit "NPR Json Builder"
    var
        MembershipPointsEntry: Record "NPR MM Members. Points Entry";
        TypeTxt: Text;
    begin
        MembershipPointsEntry.SetRange("Membership Entry No.", MembershipEntryNo);
        MembershipPointsEntry.SetFilter("Posting Date", '>=%1', TransactionsFromDate);
        if MembershipPointsEntry.FindSet() then
            repeat
                Clear(TypeTxt);
                case MembershipPointsEntry."Entry Type" of
                    MembershipPointsEntry."Entry Type"::CAPTURE:
                        TypeTxt := 'capture';
                    MembershipPointsEntry."Entry Type"::EXPIRED:
                        TypeTxt := 'expired';
                    MembershipPointsEntry."Entry Type"::POINT_DEPOSIT:
                        TypeTxt := 'deposit';
                    MembershipPointsEntry."Entry Type"::POINT_WITHDRAW:
                        if (MembershipPointsEntry.Points > 0) then
                            TypeTxt := 'withdrawal (reversed)'
                        else
                            TypeTxt := 'withdrawal';
                    MembershipPointsEntry."Entry Type"::REFUND:
                        TypeTxt := 'refund';
                    MembershipPointsEntry."Entry Type"::RESERVE:
                        TypeTxt := 'reserve';
                    MembershipPointsEntry."Entry Type"::SYNCHRONIZATION:
                        TypeTxt := 'synchronization';
                    MembershipPointsEntry."Entry Type"::SALE:
                        TypeTxt := 'sale';
                end;

                ResponseJson.StartObject()
                                .AddProperty('date', MembershipPointsEntry."Posting Date")
                                .AddProperty('type', TypeTxt)
                                .AddProperty('reference', MembershipPointsEntry."Document No.")
                                .AddProperty('storeCode', MembershipPointsEntry."POS Store Code")
                                .AddProperty('points', MembershipPointsEntry.Points)
                                .AddProperty('itemNo', MembershipPointsEntry."Item No.")
                                .AddProperty('description', MembershipPointsEntry.Description)
                            .EndObject();
            until MembershipPointsEntry.Next() = 0;
        exit(ResponseJson);
    end;

    local procedure InsertCancelReservation(CancelReservationLine: JsonToken; var TempCancelReservationRequest: Record "NPR MM Reg. Sales Buffer" temporary)
    var
        JsonMgmt: Codeunit "NPR Json Helper";
    begin
        TempCancelReservationRequest.Init();
        TempCancelReservationRequest.Type := JsonMgmt.GetJInteger(CancelReservationLine, 'type', false);
        TempCancelReservationRequest."Authorization Code" := CopyStr(JsonMgmt.GetJCode(CancelReservationLine, 'authorizationCode', false), 1, MaxStrLen(TempCancelReservationRequest."Authorization Code"));
        TempCancelReservationRequest.Insert();
    end;

    local procedure InsertPaymentRequest(ReservationLines: JsonToken; var TempRegisterPaymentRequest: Record "NPR MM Reg. Sales Buffer" temporary)
    var
        JsonMgmt: Codeunit "NPR Json Helper";
    begin
        TempRegisterPaymentRequest.Init();
        TempRegisterPaymentRequest.Type := JsonMgmt.GetJInteger(ReservationLines, 'type', false);
        TempRegisterPaymentRequest.Description := CopyStr(JsonMgmt.GetJCode(ReservationLines, 'description', false), 1, MaxStrLen(TempRegisterPaymentRequest.Description));
        TempRegisterPaymentRequest."Currency Code" := CopyStr(JsonMgmt.GetJCode(ReservationLines, 'currencyCode', false), 1, MaxStrLen(TempRegisterPaymentRequest."Currency Code"));
        TempRegisterPaymentRequest."Total Amount" := JsonMgmt.GetJDecimal(ReservationLines, 'amount', false);
        TempRegisterPaymentRequest."Total Points" := JsonMgmt.GetJDecimal(ReservationLines, 'points', false);
        TempRegisterPaymentRequest.Insert();
    end;

    local procedure InsertCaptureReservation(CaptureReservationLine: JsonToken; var TempCaptureReservationRequest: Record "NPR MM Reg. Sales Buffer" temporary)
    var
        JsonMgmt: Codeunit "NPR Json Helper";
    begin
        TempCaptureReservationRequest.Init();
        TempCaptureReservationRequest.Type := JsonMgmt.GetJInteger(CaptureReservationLine, 'type', false);
        TempCaptureReservationRequest."Authorization Code" := CopyStr(JsonMgmt.GetJCode(CaptureReservationLine, 'authorizationCode', false), 1, MaxStrLen(TempCaptureReservationRequest."Authorization Code"));
        TempCaptureReservationRequest.Insert();
    end;

    local procedure AddPointsSummary(var ResponseJson: Codeunit "NPR Json Builder"; var TmpMembershipPointsSummary: Record "NPR MM Members. Points Summary" temporary): Codeunit "NPR Json Builder"
    begin
        ResponseJson.StartArray('pointsByPeriods');

        repeat
            ResponseJson.StartObject()
                            .AddProperty('relativePeriod', TmpMembershipPointsSummary."Relative Period")
                            .AddProperty('earnPeriodStart', TmpMembershipPointsSummary."Earn Period Start")
                            .AddProperty('earnPeriodEnd', TmpMembershipPointsSummary."Earn Period End")
                            .AddProperty('burnPeriodStart', TmpMembershipPointsSummary."Burn Period Start")
                            .AddProperty('burnPeriodEnd', TmpMembershipPointsSummary."Burn Period End")
                            .AddProperty('pointsEarned', TmpMembershipPointsSummary."Points Earned")
                            .AddProperty('pointsRedeemed', TmpMembershipPointsSummary."Points Redeemed")
                            .AddProperty('pointsRemaining', TmpMembershipPointsSummary."Points Remaining")
                            .AddProperty('pointsExpired', TmpMembershipPointsSummary."Points Expired")
                            .AddProperty('amountLcyEarned', TmpMembershipPointsSummary."Amount Earned (LCY)")
                            .AddProperty('amountLcyRedeemed', TmpMembershipPointsSummary."Amount Redeemed (LCY)")
                            .AddProperty('amountLcyRemaining', TmpMembershipPointsSummary."Amount Remaining (LCY)")
                        .EndObject();
        until TmpMembershipPointsSummary.Next() = 0;

        ResponseJson.EndArray();

        exit(ResponseJson);
    end;

    local procedure CreateMembershipResponse(var ResponseJson: Codeunit "NPR JSON Builder";
                                            var Membership: Record "NPR MM Membership";
                                            var MembershipEntry: Record "NPR MM Membership Entry";
                                            var TmpMembershipPointsSummary: Record "NPR MM Members. Points Summary" temporary;
                                            var LoyaltySetup: Record "NPR MM Loyalty Setup";
                                            CommunityName: Text; MembershipName: Text; UpgradeToName: Text; DowngradeToName: Text;
                                            UpgradeToLevel: Text; UpgradeThreshold: Text; DowngradeToLevel: Text; DowngradeThreshold: Text;
                                            PointsEarnedValue: Text; PointsRemainingValue: Text; PointsEarnedCurrencyCode: Text;
                                            PointsRemainingCurrencyCode: Text; SpendPeriodStart: Text; SpendPeriodEnd: Text): Codeunit "NPR JSON Builder"
    begin
        ResponseJson.StartObject('membership')
                        .AddObject(HelperFunctions.AddMembershipProperties(ResponseJson, false, Membership, MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date"))
                        .AddProperty('communityName', CommunityName)
                        .AddProperty('membershipName', MembershipName)
                        .AddProperty('loyaltyCode', LoyaltySetup.Code)
                        .AddProperty('loyaltyProgram', LoyaltySetup.Description)
                        .AddProperty('loyaltyCollectionPeriod', Format(LoyaltySetup."Collection Period", 0, 9))
                        .AddProperty('loyaltyCollectionPeriodName', Format(LoyaltySetup."Collection Period"))
                        .AddProperty('loyaltyPointSource', Format(LoyaltySetup."Voucher Point Source", 0, 9))
                        .AddProperty('loyaltyPointSourceName', Format(LoyaltySetup."Voucher Point Source"))
                        .StartObject('pointSummary')
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
                        .StartObject('previousPeriod')
                            .AddProperty('spendPeriodStart', SpendPeriodStart)
                            .AddProperty('spendPeriodEnd', SpendPeriodEnd)
                            .StartObject('pointsEarned')
                                .AddProperty('value', pointsEarnedValue)
                                .AddProperty('currencyCode', PointsEarnedCurrencyCode)
                            .EndObject()
                            .StartObject('pointsRemaining')
                                .AddProperty('value', PointsRemainingValue)
                                .AddProperty('currencyCode', PointsRemainingCurrencyCode)
                            .EndObject()
                        .EndObject()
                        .AddArray(AddPointsSummary(ResponseJson, TmpMembershipPointsSummary))
                        .StartObject('loyaltyTiers')
                            .StartObject('upgrade')
                                .AddProperty('toLevel', upgradeToLevel)
                                .AddProperty('threshold', upgradeThreshold)
                                .AddProperty('toName', upgradeToName)
                            .EndObject()
                            .StartObject('downgrade')
                                .AddProperty('toLevel', downgradeToLevel)
                                .AddProperty('threshold', downgradeThreshold)
                                .AddProperty('toName', downgradeToName)
                            .EndObject()
                        .EndObject()
                    .EndObject();

        exit(ResponseJson);
    end;

    local procedure GetNextLoyaltyTier(MembershipEntryNo: Integer; Upgrade: Boolean; var ToLevel: Text; var Threshold: Text; var ToName: Text)
    var
        MembershipSetupTiers: Record "NPR MM Membership Setup";
        LoyaltyAlterMembership: Record "NPR MM Loyalty Alter Members.";
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
    begin
        if (LoyaltyPointManagement.GetNextLoyaltyTier(MembershipEntryNo, Upgrade, LoyaltyAlterMembership)) then begin
            ToLevel := LoyaltyAlterMembership."To Membership Code";
            Threshold := Format(LoyaltyAlterMembership."Points Threshold", 0, 9);
            if (ToLevel <> '') then
                if (MembershipSetupTiers.Get(ToLevel)) then
                    ToName := MembershipSetupTiers.Description;
        end;
    end;

    local procedure GetPointsAndPeriod(MembershipEntryNo: Integer; var PointsEarnedValue: Text; var PointsRemainingValue: Text; var PointsEarnedCurrencyCode: Text; var PointsRemainingCurrencyCode: Text; var SpendPeriodStart: Text; var SpendPeriodEnd: Text)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        TempLoyaltyPointsSetup: Record "NPR MM Loyalty Point Setup" temporary;
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
        PeriodStart, PeriodEnd : Date;
        ReasonText: Text;
        Earned, Redeemable : Decimal;
    begin
        Earned := LoyaltyPointManagement.CalculateEarnedPointsCurrentPeriod(MembershipEntryNo);
        Redeemable := LoyaltyPointManagement.CalculateRedeemablePointsCurrentPeriod(MembershipEntryNo);
        if (LoyaltyPointManagement.GetCouponToRedeemWS(MembershipEntryNo, TempLoyaltyPointsSetup, 1000000000, ReasonText)) then begin
            TempLoyaltyPointsSetup.Reset();
            TempLoyaltyPointsSetup.SetCurrentKey(Code, "Amount LCY");
            TempLoyaltyPointsSetup.FindLast();
            PointsEarnedValue := Format(Round(Earned * TempLoyaltyPointsSetup."Point Rate", 1), 0, 9);
            PointsRemainingValue := Format(Round(Redeemable * TempLoyaltyPointsSetup."Point Rate", 1), 0, 9);

            GeneralLedgerSetup.Get();
            PointsEarnedCurrencyCode := GeneralLedgerSetup."LCY Code";
            PointsRemainingCurrencyCode := GeneralLedgerSetup."LCY Code";
        end;

        LoyaltyPointManagement.CalculateSpendPeriod(MembershipEntryNo, Today, PeriodStart, PeriodEnd);
        SpendPeriodStart := Format(PeriodStart, 0, 9);
        SpendPeriodEnd := Format(PeriodEnd, 0, 9);
    end;
}
#endif
