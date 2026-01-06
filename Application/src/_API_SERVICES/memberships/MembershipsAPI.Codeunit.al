#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6185113 "NPR MembershipsAPI" implements "NPR API Request Handler"
{
    Access = Internal;

    var
        _ApiFunction: Enum "NPR MembershipApiFunctions";

    procedure Handle(var Request: Codeunit "NPR API Request"): Codeunit "NPR API Response"
    begin

        if (Request.Match('GET', '/membership')) then
            exit(Handle(_ApiFunction::GET_MEMBERSHIP_USING_NUMBER, Request));


        if (Request.Match('GET', '/membership/attributes')) then
            exit(Handle(_ApiFunction::LIST_MEMBERSHIP_ATTRIBUTES, Request));

        if (Request.Match('GET', '/membership/catalog')) then
            exit(Handle(_ApiFunction::GET_CATALOG, Request));

        if (Request.Match('GET', '/membership/list')) then
            exit(Handle(_ApiFunction::LIST_MEMBERSHIPS, Request));

        if (Request.Match('GET', '/membership/member')) then
            exit(Handle(_ApiFunction::FIND_MEMBER, Request));

        if (Request.Match('GET', '/membership/card')) then
            exit(Handle(_ApiFunction::FIND_MEMBER_CARD, Request));

        if (Request.Match('GET', '/membership/resolveIdentifier')) then
            exit(Handle(_ApiFunction::RESOLVE_IDENTIFIER, Request));

        if (Request.Match('GET', '/membership/:membershipId')) then
            exit(Handle(_ApiFunction::GET_MEMBERSHIP_USING_ID, Request));


        if (Request.Match('GET', '/membership/catalog/:storeCode')) then
            exit(Handle(_ApiFunction::GET_CATALOG, Request));

        if (Request.Match('GET', '/membership/card/:cardId')) then
            exit(Handle(_ApiFunction::GET_CARD_USING_ID, Request));

        if (Request.Match('GET', '/membership/member/attributes')) then
            exit(Handle(_ApiFunction::LIST_MEMBER_ATTRIBUTES, Request));

        if (Request.Match('GET', '/membership/member/:memberId')) then
            exit(Handle(_ApiFunction::GET_MEMBER_USING_ID, Request));

        if (Request.Match('GET', '/membership/paymentMethods/:paymentMethodId')) then
            exit(Handle(_ApiFunction::GET_PAYMENT_METHOD, Request));

        if (Request.Match('GET', '/membership/:membershipId/members')) then
            exit(Handle(_ApiFunction::GET_MEMBERSHIP_MEMBERS, Request));

        if (Request.Match('GET', '/membership/:membershipId/attributes')) then
            exit(Handle(_ApiFunction::GET_MEMBERSHIP_ATTRIBUTE_VALUES, Request));

        if (Request.Match('GET', '/membership/:membershipId/paymentMethods')) then
            exit(Handle(_ApiFunction::GET_ALL_PAYMENT_METHODS, Request));

        if (Request.Match('GET', '/membership/:membershipId/renewal')) then
            exit(Handle(_ApiFunction::GET_MEMBERSHIP_RENEWAL_INFO, Request));

        if (Request.Match('GET', '/membership/:membershipId/renewalOptions')) then
            exit(Handle(_ApiFunction::GET_RENEWAL_OPTIONS, Request));

        if (Request.Match('GET', '/membership/:membershipId/extendOptions')) then
            exit(Handle(_ApiFunction::GET_EXTEND_OPTIONS, Request));

        if (Request.Match('GET', '/membership/:membershipId/upgradeOptions')) then
            exit(Handle(_ApiFunction::GET_UPGRADE_OPTIONS, Request));

        if (Request.Match('GET', '/membership/:membershipId/cancelOptions')) then
            exit(Handle(_ApiFunction::GET_CANCEL_OPTIONS, Request));

        if (Request.Match('GET', '/membership/:membershipId/history')) then
            exit(Handle(_ApiFunction::GET_MEMBERSHIP_TIME_ENTRIES, Request));

        if (Request.Match('GET', '/membership/:membershipId/receiptList')) then
            exit(Handle(_ApiFunction::GET_MEMBERSHIP_RECEIPT_LIST, Request));

        if (Request.Match('POST', '/membership/:membershipId/activate')) then
            exit(Handle(_ApiFunction::ACTIVATE_MEMBERSHIP, Request));

        if (Request.Match('GET', '/membership/:membershipId/subscription')) then
            exit(Handle(_ApiFunction::GET_SUBSCRIPTION, Request));


        if (Request.Match('GET', '/membership/member/:memberId/attributes')) then
            exit(Handle(_ApiFunction::GET_MEMBER_ATTRIBUTE_VALUES, Request));

        if (Request.Match('GET', '/membership/member/:memberId/image')) then
            exit(Handle(_ApiFunction::GET_MEMBER_IMAGE, Request));

        if (Request.Match('GET', '/membership/member/:memberId/notes')) then
            exit(Handle(_ApiFunction::GET_MEMBER_NOTES, Request));

        if Request.Match('GET', '/membership/:membershipId/points') then
            exit(Handle(_ApiFunction::POINTS_GET_BALANCE, Request));

        // ************************************************************

        if (Request.Match('POST', '/membership')) then
            exit(Handle(_ApiFunction::CREATE_MEMBERSHIP, Request));


        if (Request.Match('POST', '/membership/:membershipId/block')) then
            exit(Handle(_ApiFunction::BLOCK_MEMBERSHIP, Request));

        if (Request.Match('POST', '/membership/:membershipId/unblock')) then
            exit(Handle(_ApiFunction::UNBLOCK_MEMBERSHIP, Request));

        if (Request.Match('POST', '/membership/:membershipId/attributes')) then
            exit(Handle(_ApiFunction::SET_MEMBERSHIP_ATTRIBUTE_VALUES, Request));

        if (Request.Match('POST', '/membership/:membershipId/paymentMethods')) then
            exit(Handle(_ApiFunction::CREATE_PAYMENT_METHOD, Request));

        if (Request.Match('POST', '/membership/:membershipId/addMember')) then
            exit(Handle(_ApiFunction::ADD_MEMBER, Request));

        if (Request.Match('POST', '/membership/:membershipId/renew')) then
            exit(Handle(_ApiFunction::RENEW_MEMBERSHIP, Request));

        if (Request.Match('POST', '/membership/:membershipId/upgrade')) then
            exit(Handle(_ApiFunction::UPGRADE_MEMBERSHIP, Request));

        if (Request.Match('POST', '/membership/:membershipId/extend')) then
            exit(Handle(_ApiFunction::EXTEND_MEMBERSHIP, Request));

        if (Request.Match('POST', '/membership/:membershipId/cancel')) then
            exit(Handle(_ApiFunction::CANCEL_MEMBERSHIP, Request));

        if (Request.Match('POST', '/membership/:membershipId/regret')) then
            exit(Handle(_ApiFunction::REGRET_MEMBERSHIP, Request));


        if (Request.Match('POST', '/membership/member/:memberId/block')) then
            exit(Handle(_ApiFunction::BLOCK_MEMBER, Request));

        if (Request.Match('POST', '/membership/member/:memberId/unblock')) then
            exit(Handle(_ApiFunction::UNBLOCK_MEMBER, Request));

        if (Request.Match('POST', '/membership/member/:memberId/note')) then
            exit(Handle(_ApiFunction::ADD_MEMBER_NOTE, Request));

        if (Request.Match('POST', '/membership/member/:memberId/attributes')) then
            exit(Handle(_ApiFunction::SET_MEMBER_ATTRIBUTE_VALUES, Request));


        if (Request.Match('POST', '/membership/card/:cardId/block')) then
            exit(Handle(_ApiFunction::BLOCK_CARD, Request));

        if (Request.Match('POST', '/membership/card/:cardId/unblock')) then
            exit(Handle(_ApiFunction::UNBLOCK_CARD, Request));

        if (Request.Match('POST', '/membership/card/:cardId/replaceCard')) then
            exit(Handle(_ApiFunction::REPLACE_CARD, Request));

        if (Request.Match('POST', '/membership/card/:cardId/sendToWallet')) then
            exit(Handle(_ApiFunction::SEND_TO_WALLET, Request));

        if (Request.Match('POST', '/membership/:membershipId/member/:memberId/addCard')) then
            exit(Handle(_ApiFunction::ADD_CARD, Request));


        if Request.Match('POST', '/membership/:membershipId/points/reserve') then
            exit(Handle(_ApiFunction::POINTS_RESERVE, Request));

        if Request.Match('POST', '/membership/:membershipId/points') then
            exit(Handle(_ApiFunction::POINTS_REGISTER_SALE, Request));


        if (Request.Match('POST', '/membership/:membershipId/subscription/start')) then
            exit(Handle(_ApiFunction::ENTER_SUBSCRIPTION, Request));

        if (Request.Match('POST', '/membership/:membershipId/subscription/terminate')) then
            exit(Handle(_ApiFunction::TERMINATE_SUBSCRIPTION, Request));

        // ************************************************************

        if (Request.Match('PUT', '/membership/member/:memberId/image')) then
            exit(Handle(_ApiFunction::SET_MEMBER_IMAGE, Request));


        if (Request.Match('PATCH', '/membership/paymentMethods/:paymentMethodId')) then
            exit(Handle(_ApiFunction::UPDATE_PAYMENT_METHOD, Request));

        if (Request.Match('PATCH', '/membership/member/:memberId')) then
            exit(Handle(_ApiFunction::UPDATE_MEMBER, Request));

        if (Request.Match('PATCH', '/membership/card/:cardId')) then
            exit(Handle(_ApiFunction::PATCH_CARD, Request));

        // ************************************************************

        if Request.Match('DELETE', '/membership/:membershipId/points/reserve') then
            exit(Handle(_ApiFunction::POINTS_CANCEL_RESERVATION, Request));

        if (Request.Match('DELETE', '/membership/member/:memberId/attributes')) then
            exit(Handle(_ApiFunction::DELETE_MEMBER_ATTRIBUTE_VALUES, Request));

        if (Request.Match('DELETE', '/membership/paymentMethods/:paymentMethodId')) then
            exit(Handle(_ApiFunction::DELETE_PAYMENT_METHOD, Request));

        if (Request.Match('DELETE', '/membership/:membershipId/attributes')) then
            exit(Handle(_ApiFunction::DELETE_MEMBERSHIP_ATTRIBUTE_VALUES, Request));


        // ************************************************************
    end;

    local procedure Handle(ApiFunction: Enum "NPR MembershipApiFunctions"; var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        MembershipApiHandler: Codeunit "NPR MembershipApiHandler";
        StartTime: Time;
        ResponseMessage: Text;
        ApiError: Enum "NPR API Error Code";
    begin
        StartTime := Time();
        Commit();
        ClearLastError();

        Request.SkipCacheIfNonStickyRequest(MembershipTransactionTables());

        MembershipApiHandler.SetRequest(ApiFunction, Request);
        if (MembershipApiHandler.Run()) then begin
            Response := MembershipApiHandler.GetResponse();
            LogMessage(Request, ApiFunction, (Time() - StartTime), Response.GetStatusCode(), Response);
            exit(Response);
        end;

        ResponseMessage := GetLastErrorText();
        ApiError := ErrorToEnum(ResponseMessage);

        Response.CreateErrorResponse(ApiError, ResponseMessage);
        LogMessage(Request, ApiFunction, (Time() - StartTime), Response.GetStatusCode(), Response);
        exit(Response);
    end;

    local procedure ErrorToEnum(ErrorMessage: Text): Enum "NPR API Error Code"
    begin
        if (ErrorMessage.StartsWith('[-127001]')) then
            exit(Enum::"NPR API Error Code"::member_count_exceeded);

        if (ErrorMessage.StartsWith('[-127002]')) then
            exit(Enum::"NPR API Error Code"::member_card_exists);

        if (ErrorMessage.StartsWith('[-127003]')) then
            exit(Enum::"NPR API Error Code"::no_admin_member);

        if (ErrorMessage.StartsWith('[-127004]')) then
            exit(Enum::"NPR API Error Code"::member_card_blank);

        if (ErrorMessage.StartsWith('[-127005]')) then
            exit(Enum::"NPR API Error Code"::invalid_contact);

        if (ErrorMessage.StartsWith('[-127006]')) then
            exit(Enum::"NPR API Error Code"::age_verification_setup);

        if (ErrorMessage.StartsWith('[-127007]')) then
            exit(Enum::"NPR API Error Code"::age_verification);

        if (ErrorMessage.StartsWith('[-127008]')) then
            exit(Enum::"NPR API Error Code"::allow_member_merge_not_set);

        if (ErrorMessage.StartsWith('[-127009]')) then
            exit(Enum::"NPR API Error Code"::member_unique_id_violation);

        exit(Enum::"NPR API Error Code"::generic_error);
    end;

    local procedure LogMessage(Request: Codeunit "NPR API Request";
        Function: Enum "NPR MembershipApiFunctions";
        DurationMs: Decimal;
        HttpStatusCode: Integer;
        Response: Codeunit "NPR API Response")
    var
        CustomDimensions: Dictionary of [Text, Text];
        ActiveSession: Record "Active Session";
        JsonObj: JsonObject;
        JToken: JsonToken;
        ResponseMessage: Text;
    begin
        if (not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId())) then
            ActiveSession.Init();

        CustomDimensions.Add('NPR_FunctionName', Function.Names.Get(Function.Ordinals.IndexOf(Function.AsInteger())));
        CustomDimensions.Add('NPR_DurationMs', Format(DurationMs, 0, 9));

        CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
        CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
        CustomDimensions.Add('NPR_TenantId', Database.TenantId());
        CustomDimensions.Add('NPR_CompanyName', CompanyName());
        CustomDimensions.Add('NPR_UserID', ActiveSession."User ID");
        CustomDimensions.Add('NPR_SessionId', Format(Database.SessionId(), 0, 9));
        CustomDimensions.Add('NPR_StickyCache', CheckStickyCache(Request));
        CustomDimensions.Add('NPR_ClientComputerName', ActiveSession."Client Computer Name");

        if (HttpStatusCode in [200 .. 299]) then begin
            ResponseMessage := StrSubstNo('Success - HTTP %1', HttpStatusCode);
            CustomDimensions.Add('NPR_ErrorText', '');
            CustomDimensions.Add('NPR_ErrorCodeName', '');

            Session.LogMessage('NPR_API_Membership', ResponseMessage, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
        end else begin
            JsonObj := Response.GetJson(); // Note: This will throw an error if the response is not JSON Object which might be true for some success responses
            ResponseMessage := StrSubstNo('Failure - HTTP %1', HttpStatusCode);
            if (JsonObj.Get('message', JToken)) then
                CustomDimensions.Add('NPR_ErrorText', JToken.AsValue().AsText());
            if (JsonObj.Get('code', JToken)) then
                CustomDimensions.Add('NPR_ErrorCodeName', JToken.AsValue().AsText());

            Session.LogMessage('NPR_API_Membership', ResponseMessage, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
        end;
    end;

    local procedure CheckStickyCache(var Request: Codeunit "NPR API Request"): Text
    var
        RequestServerId: Integer;
    begin
        if (Request.Headers().ContainsKey('x-server-cache-id')) then
            if (Evaluate(RequestServerId, Request.Headers().Get('x-server-cache-id'))) then
                if (RequestServerId = ServiceInstanceId()) then
                    exit('sticky-cache [match]')
                else
                    exit(StrSubstNo('sticky-cache [%1 <> %2]', RequestServerId, ServiceInstanceId()));

        exit('sticky-cache [no header]');
    end;

    internal procedure MembershipTransactionTables() TableList: List of [Integer]
    begin
        TableList.Add(Database::"NPR MM Member Info Capture");
        TableList.Add(Database::"NPR MM Member");
        TableList.Add(Database::"NPR MM Member Card");
        TableList.Add(Database::"NPR MM Membership");
        TableList.Add(Database::"NPR MM Membership Entry");
        TableList.Add(Database::"NPR MM Membership Role");

        TableList.Add(Database::"NPR MM Admis. Scanner Stations");
        TableList.Add(Database::"NPR MM Admis. Service Entry");
        TableList.Add(Database::"NPR MM Admis. Service Log");

        TableList.Add(Database::"NPR MM Language");
        TableList.Add(Database::"NPR MM Member Communication");
        TableList.Add(Database::"NPR MM Membership Notific.");
        TableList.Add(Database::"NPR MMMemberNotificEntryBuf");
        TableList.Add(Database::"NPR MM Member Notific. Entry");
        TableList.Add(Database::"NPR MM Member Arr. Log Entry");

        TableList.Add(Database::"NPR MM Members. Alter. Group");
        TableList.Add(Database::"NPR MM Members. Alter. Line");

        TableList.Add(Database::"NPR MM Pending Customer Update");
        TableList.Add(Database::"NPR MM POS Sales Info");

        TableList.Add(Database::"NPR MM Request Member Update");
        TableList.Add(Database::"NPR MM Sponsors. Ticket Entry");

        TableList.Add(Database::"NPR MM AchActivity");
        TableList.Add(Database::"NPR MM AchActivityCondition");
        TableList.Add(Database::"NPR MM AchActivityEntry");
        TableList.Add(Database::"NPR MM AchGoal");
        TableList.Add(Database::"NPR MM Achievement");
        TableList.Add(Database::"NPR MM AchReward");

        TableList.Add(Database::"NPR MM POS Loyalty Profile");
        TableList.Add(Database::"NPR MM Loyalty Setup");
        TableList.Add(Database::"NPR MM Loy. Item Point Setup");
        TableList.Add(Database::"NPR MM Loyalty Sales Channel");
        TableList.Add(Database::"NPR MM LoyaltyRetryQueue");
        TableList.Add(Database::"NPR MM Loyalty Store Setup");
        TableList.Add(Database::"NPR MM Loy. LedgerEntry (Srvr)");
        TableList.Add(Database::"NPR MM Loyalty Alter Members.");
        TableList.Add(Database::"NPR MM Loyalty Point Setup");
        TableList.Add(Database::"NPR MM MembershipLoyaltyJnl");
        TableList.Add(Database::"NPR MM Members. Points Entry");
        TableList.Add(Database::"NPR MM Members. Points Summary");

        TableList.Add(Database::"NPR MM Member Payment Method");
        TableList.Add(Database::"NPR MM MembershipPmtMethodMap");
        TableList.Add(Database::"NPR MM Renewal Sched Hdr");
        TableList.Add(Database::"NPR MM Renewal Sched Line");
        TableList.Add(Database::"NPR MM Subs Adyen PG Setup");
        TableList.Add(Database::"NPR MM Subscription");
        TableList.Add(Database::"NPR MM Subscription Log");
        TableList.Add(Database::"NPR MM Subscription Template");
        TableList.Add(Database::"NPR MM Subscription Transact.");
        TableList.Add(Database::"NPR MM Subscr. Request");
        TableList.Add(Database::"NPR MM Subs Req Log Entry");
        TableList.Add(Database::"NPR MM Subscr. Payment Request");
        TableList.Add(Database::"NPR MM Subs. Payment Gateway");
        TableList.Add(Database::"NPR MM Subs Pay Req Log Entry");
        TableList.Add(Database::"NPR MM Add. Info. Request");
        TableList.Add(Database::"NPR MM Add. Info. Response");
        TableList.Add(Database::"NPR MM VippsMP Login Setup");
        TableList.Add(Database::"NPR MM Payment Reconci.");
        TableList.Add(Database::"NPR MM Recur. Paym. Setup");
        TableList.Add(Database::"NPR MM Membership Auto Renew");
        TableList.Add(Database::"NPR MM Membership Entry Link");
    end;

}
#endif