#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248450 "NPR Loyalty Helper Functions"
{
    Access = Internal;

    var
        Temp_LoyaltySetup: Record "NPR MM Loyalty Setup" temporary;
        Temp_PointsResponse: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        Temp_LoyaltyPointsSetup: Record "NPR MM Loyalty Point Setup" temporary;
        Temp_Coupon: Record "NPR NpDc Coupon" temporary;
        _ResponseMessage, _ResponseCode, _ExecutionTime, _MessageCode : Text;
        _StartTime: Time;
        _ExecutionTimeLbl: Label '%1 (ms)', Locked = true;

    internal procedure SetResponse(ResponseCode: Text)
    begin
        SetResponse(ResponseCode, '', '', '');
    end;

    internal procedure SetResponse(ResponseCode: Text; ResponseMessage: Text)
    begin
        SetResponse(ResponseCode, ResponseMessage, '', '');
    end;

    internal procedure SetResponse(ResponseCode: Text; ResponseMessage: Text; MessageCode: Text)
    begin
        SetResponse(ResponseCode, ResponseMessage, MessageCode, '');
    end;

    internal procedure SetResponse(ResponseCode: Text; ResponseMessage: Text; MessageCode: Text; ExecutionTime: Text)
    begin
        _ResponseCode := ResponseCode;
        _ResponseMessage := ResponseMessage;
        _MessageCode := MessageCode;
        if _StartTime <> 0T then
            _ExecutionTime := StrSubstNo(_ExecutionTimeLbl, Format(Time - _StartTime, 0, 9));
    end;

    internal procedure SetErrorResponse(ResponseMessageIn: Text; MessageId: Text)
    begin
        SetResponse('ERROR', ResponseMessageIn, MessageId);
    end;

    internal procedure SetStartTime(StartTime: Time)
    begin
        if StartTime <> 0T then
            _StartTime := StartTime;
    end;

    internal procedure GetResponseCode(): Text
    begin
        exit(_ResponseCode);
    end;

    internal procedure GetStatusResponse(var ResponseJson: Codeunit "NPR JSON Builder"): Codeunit "NPR JSON Builder"
    begin
        ResponseJson.StartObject('status')
                        .AddProperty('responseCode', _ResponseCode)
                        .AddProperty('responseMessage', _ResponseMessage);

        if _MessageCode <> '' then
            ResponseJson.AddProperty('messageCode', _MessageCode);

        if _ExecutionTime <> '' then
            ResponseJson.AddProperty('executionTime', _ExecutionTime);

        ResponseJson.EndObject();

        exit(ResponseJson);
    end;

    internal procedure GetErrorResponse(): Text
    var
        ResponseJson: Codeunit "NPR JSON Builder";
    begin
        ResponseJson.StartObject('status')
                        .AddProperty('responseCode', _ResponseCode)
                        .AddProperty('responseMessage', _ResponseMessage)
                        .AddProperty('messageCode', _MessageCode)
                    .EndObject();

        exit(ResponseJson.BuildAsText());
    end;

    internal procedure GetMembershipEntryNo(CardNumber: Text; MembershipNumber: Text; CustomerNumber: Text) MembershipEntryNo: Integer
    var
        Membership: Record "NPR MM Membership";
        MemberCard: Record "NPR MM Member Card";
    begin
        if MembershipNumber <> '' then begin
            Membership.SetRange("External Membership No.", MembershipNumber);
            if Membership.FindFirst() then
                MembershipEntryNo := Membership."Entry No.";
        end;

        if CardNumber <> '' then begin
            MemberCard.SetRange("External Card No.", CardNumber);
            if MemberCard.FindFirst() then
                MembershipEntryNo := MemberCard."Membership Entry No.";
        end;

        if CustomerNumber <> '' then begin
            Membership.SetFilter("Customer No.", '=%1', CustomerNumber);
            Membership.SetFilter(Blocked, '=%1', false);
            if Membership.FindFirst() then
                MembershipEntryNo := Membership."Entry No.";
        end;
    end;

    internal procedure GetResponseByFunctionName(var ResponseJson: Codeunit "NPR JSON Builder"; FunctionName: Text): Codeunit "NPR Json Builder"
    begin
        case FunctionName of
            'getLoyaltyConfiguration':
                begin
                    ResponseJson.StartObject('configuration')
                                    .AddProperty('code', Temp_LoyaltySetup.Code)
                                    .AddProperty('earnRatio', Temp_LoyaltySetup."Amount Factor")
                                    .AddProperty('burnRatio', Temp_LoyaltySetup."Point Rate")
                                .EndObject();
                end;
            'registerSale':
                begin
                    ResponseJson.StartObject('points')
                        .AddProperty('referenceNumber', Temp_PointsResponse."Entry No.")
                        .AddProperty('authorizationNumber', Temp_PointsResponse."Authorization Code")
                        .AddProperty('pointsEarned', Temp_PointsResponse."Earned Points")
                        .AddProperty('pointsSpent', Temp_PointsResponse."Burned Points")
                        .AddProperty('newPointBalance', Temp_PointsResponse.Balance)
                    .EndObject();
                end;
        end;

        exit(ResponseJson);
    end;

    internal procedure SetPointsResponse(var TmpPointsResponse: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary)
    begin
        if (not TmpPointsResponse.FindFirst()) then begin
            SetErrorResponse('Registering the sales failed.', '-1098');
            exit;
        end;

        Temp_PointsResponse.TransferFields(TmpPointsResponse);
        Temp_PointsResponse.Insert();

        SetResponse('OK', 'Success');
    end;

    internal procedure SetLoyaltyResponse(var TempLoyaltySetup: Record "NPR MM Loyalty Setup" temporary)
    begin
        if (not TempLoyaltySetup.FindFirst()) then begin
            SetErrorResponse('Loyalty Setup not found.', '-1098');
            exit;
        end;

        Temp_LoyaltySetup.TransferFields(TempLoyaltySetup);
        Temp_LoyaltySetup.Insert();

        SetResponse('OK', 'Success');
    end;

    internal procedure SetCouponResponse(MembershipEntryNo: Integer; var TempCoupon: Record "NPR NpDc Coupon" temporary; ResponseMessage: Text)
    var
        Membership: Record "NPR MM Membership";
    begin
        if ((MembershipEntryNo <= 0) or (not Membership.Get(MembershipEntryNo))) then begin
            SetErrorResponse('Invalid membership entry no.', '');
            exit;
        end;

        if ResponseMessage = '' then
            ResponseMessage := 'Success';

        Temp_Coupon.TransferFields(TempCoupon);
        Temp_Coupon.Insert();

        SetResponse('OK', ResponseMessage);

        if TempCoupon.IsEmpty() then
            SetResponse('WARNING', ResponseMessage);
    end;

    internal procedure SetLoyaltyPointsSetupResponse(MembershipEntryNo: Integer; var TempLoyaltyPointsSetup: Record "NPR MM Loyalty Point Setup" temporary; ResponseMessage: Text)
    var
        Membership: Record "NPR MM Membership";
    begin
        if ((MembershipEntryNo <= 0) or (not Membership.Get(MembershipEntryNo))) then begin
            SetErrorResponse('Invalid membership entry no.', '');
            exit;
        end;

        if ResponseMessage = '' then
            ResponseMessage := 'Success';

        Temp_LoyaltyPointsSetup.TransferFields(TempLoyaltyPointsSetup);
        Temp_LoyaltyPointsSetup.Insert();

        SetResponse('OK', ResponseMessage);

        if TempLoyaltyPointsSetup.IsEmpty() then
            SetResponse('WARNING', ResponseMessage);
    end;

    internal procedure GetQueryParameterFromRequest(_Request: Codeunit "NPR API Request"; ParameterName: Text): Text
    begin
        exit(GetQueryParameterFromRequest(_Request, ParameterName, 0));
    end;

    internal procedure GetQueryParameterFromRequest(_Request: Codeunit "NPR API Request"; ParameterName: Text; MaxLength: Integer) Value: Text
    begin
        if ParameterName <> '' then
            if (_Request.QueryParams().ContainsKey(ParameterName)) then
                if MaxLength > 0 then
                    Value := CopyStr(_Request.QueryParams().Get(ParameterName), 1, MaxLength)
                else
                    Value := _Request.QueryParams().Get(ParameterName);
        exit(Value);
    end;

#pragma warning disable AA0139
    internal procedure InsertAuthorizationHeader(var _Request: Codeunit "NPR API Request"; var TempAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary)
    var
        DateTxt, TimeTxt : Text;
    begin
        TempAuthorization.Init();
        TempAuthorization."Company Name" := GetQueryParameterFromRequest(_Request, 'posCompanyName');
        TempAuthorization."POS Store Code" := GetQueryParameterFromRequest(_Request, 'posStoreCode');
        TempAuthorization."POS Unit Code" := GetQueryParameterFromRequest(_Request, 'posUnitCode');
        TempAuthorization."Authorization Code" := GetQueryParameterFromRequest(_Request, 'token');
        TempAuthorization."Card Number" := GetQueryParameterFromRequest(_Request, 'clientCardNumber');

        if GetQueryParameterFromRequest(_Request, 'receiptNumber') <> '' then
            TempAuthorization."Reference Number" := GetQueryParameterFromRequest(_Request, 'receiptNumber');

        if GetQueryParameterFromRequest(_Request, 'transactionId') <> '' then
            TempAuthorization."Foreign Transaction Id" := GetQueryParameterFromRequest(_Request, 'transactionId');

        if GetQueryParameterFromRequest(_Request, 'date') <> '' then
            DateTxt := GetQueryParameterFromRequest(_Request, 'date');

        if GetQueryParameterFromRequest(_Request, 'time') <> '' then
            TimeTxt := GetQueryParameterFromRequest(_Request, 'time');

        if GetQueryParameterFromRequest(_Request, 'retailId') <> '' then
            TempAuthorization."Retail Id" := GetQueryParameterFromRequest(_Request, 'retailId');

        if DateTxt <> '' then
            Evaluate(TempAuthorization."Transaction Date", DateTxt);
        if TimeTxt <> '' then
            Evaluate(TempAuthorization."Transaction Time", TimeTxt);

        TempAuthorization.Insert();
    end;
#pragma warning restore

    internal procedure AddMembershipProperties(var ResponseJson: Codeunit "NPR JSON Builder"; StartNewObject: Boolean; var Membership: Record "NPR MM Membership"; DateValidFromDate: Date; DateValidUntilDate: Date): Codeunit "NPR JSON Builder"
    begin
        if StartNewObject then
            ResponseJson.StartObject('membership');

        ResponseJson.AddProperty('communityCode', Membership."Community Code")
                    .AddProperty('membershipCode', Membership."Membership Code")
                    .AddProperty('membershipNumber', Membership."External Membership No.")
                    .AddProperty('issueDate', Membership."Issued Date")
                    .AddProperty('validFromDate', Format(DateValidFromDate, 0, 9))
                    .AddProperty('validUntilDate', Format(DateValidUntilDate, 0, 9));

        if StartNewObject then
            ResponseJson.EndObject();

        exit(ResponseJson);
    end;
}
#endif