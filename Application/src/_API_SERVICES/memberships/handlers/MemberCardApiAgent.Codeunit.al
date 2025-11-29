#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248223 "NPR MemberCardApiAgent"
{
    Access = Internal;

    internal procedure GetMemberCardByNumber(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        MemberCard: Record "NPR MM Member Card";
        ResponseJson: Codeunit "NPR JSON Builder";
        RespondWithDetails: Boolean;
    begin
        if (not GetByCardNumber(Request, MemberCard)) then
            exit(Response.RespondBadRequest('Card not found'));

        RespondWithDetails := false;
        if (Request.QueryParams().ContainsKey('withDetails')) then
            RespondWithDetails := (Request.QueryParams().Get('withDetails').ToLower() in ['true', '1']);

        ResponseJson.StartObject()
            .AddObject(StartMemberCardDTO(ResponseJson, MemberCard, RespondWithDetails, RespondWithDetails))
            .EndObject();

        exit(Response.RespondOK(ResponseJson.Build()));
    end;

    internal procedure GetMemberCardById(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        MemberCard: Record "NPR MM Member Card";
        ResponseJson: Codeunit "NPR JSON Builder";
    begin
        if (not GetByCardId(Request, 3, MemberCard)) then
            exit(Response.RespondBadRequest('Card not found'));

        ResponseJson.StartObject()
            .AddObject(StartMemberCardDTO(ResponseJson, MemberCard, true, true))
            .EndObject();

        exit(Response.RespondOK(ResponseJson.Build()));

    end;

    internal procedure BlockMemberCard(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        MemberCard: Record "NPR MM Member Card";
        ResponseJson: Codeunit "NPR JSON Builder";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        if (not GetByCardId(Request, 3, MemberCard)) then
            exit(Response.RespondBadRequest('Card not found'));

        MembershipManagement.BlockMemberCard(MemberCard."Entry No.", true);
        MemberCard.Get(MemberCard."Entry No.");

        ResponseJson.StartObject()
            .AddObject(StartMemberCardDTO(ResponseJson, MemberCard, false, false))
            .EndObject();

        exit(Response.RespondOK(ResponseJson.Build()));
    end;

    internal procedure UnblockMemberCard(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        MemberCard: Record "NPR MM Member Card";
        ResponseJson: Codeunit "NPR JSON Builder";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        if (not GetByCardId(Request, 3, MemberCard)) then
            exit(Response.RespondBadRequest('Card not found'));

        MembershipManagement.BlockMemberCard(MemberCard."Entry No.", false);
        MemberCard.Get(MemberCard."Entry No.");

        ResponseJson.StartObject()
            .AddObject(StartMemberCardDTO(ResponseJson, MemberCard, false, false))
            .EndObject();

        exit(Response.RespondOK(ResponseJson.Build()));
    end;

    internal procedure AddMemberCard(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        MemberCard: Record "NPR MM Member Card";
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        ResponseJson: Codeunit "NPR JSON Builder";
        MemberApiAgent: Codeunit "NPR MemberApiAgent";
        MembershipApiAgent: Codeunit "NPR MembershipApiAgent";

    begin
        if (not MembershipApiAgent.GetMembershipById(Request, 2, Membership)) then
            exit(Response.RespondBadRequest('Invalid Membership - Membership Id not valid.'));

        if (not MemberApiAgent.GetMemberById(Request, 4, Member)) then
            exit(Response.RespondBadRequest('Member not found'));

        AddMemberCardWorker(Request, Member, Membership, MemberCard);

        ResponseJson.StartObject()
            .AddObject(StartMemberCardDTO(ResponseJson, MemberCard, false, false))
            .EndObject();

        exit(Response.RespondOK(ResponseJson.Build()));

    end;

    internal procedure ReplaceMemberCard(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        ReplaceCard, NewCard : Record "NPR MM Member Card";
        ResponseJson: Codeunit "NPR JSON Builder";
    begin
        if (not GetByCardId(Request, 3, ReplaceCard)) then
            exit(Response.RespondBadRequest('Card not found'));

        ReplaceCardWorker(Request, ReplaceCard, NewCard);

        ResponseJson.StartObject()
            .AddObject(StartMemberCardDTO(ResponseJson, NewCard, false, false))
            .EndObject();

        exit(Response.RespondOK(ResponseJson.Build()));
    end;

    internal procedure PatchMemberCard(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        MemberCard: Record "NPR MM Member Card";
        ResponseJson: Codeunit "NPR JSON Builder";

        BodyJson: JsonObject;
        jToken: JsonToken;
        CardAsText: Text;
    begin
        if (not GetByCardId(Request, 3, MemberCard)) then
            exit(Response.RespondBadRequest('Card not found'));

        CardAsText := Format(MemberCard);

        BodyJson := Request.BodyJson().AsObject();
        if (BodyJson.Get('temporary', jToken)) then
            MemberCard."Card Is Temporary" := jToken.AsValue().AsBoolean();

        if (BodyJson.Get('expiryDate', jToken)) then
            MemberCard."Valid Until" := jToken.AsValue().AsDate();

        if (BodyJson.Get('pinCode', jToken)) then
            MemberCard."Pin Code" := CopyStr(jToken.AsValue().AsText(), 1, MaxStrLen(MemberCard."Pin Code"));

        if (Format(MemberCard) <> CardAsText) then
            MemberCard.Modify();

        ResponseJson.StartObject()
            .AddObject(StartMemberCardDTO(ResponseJson, MemberCard, false, false))
            .EndObject();

        exit(Response.RespondOK(ResponseJson.Build()));
    end;

    internal procedure SendToWallet(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        MemberCard: Record "NPR MM Member Card";
        ResponseJson: Codeunit "NPR JSON Builder";
        MemberNotification: Codeunit "NPR MM Member Notification";
        MembershipNotification: Record "NPR MM Membership Notific.";
        MembershipNotificationEntry: Record "NPR MM Member Notific. Entry";
        NotificationEntryNo: Integer;
    begin
        if (not GetByCardId(Request, 3, MemberCard)) then
            exit(Response.RespondBadRequest('Card not found'));

        NotificationEntryNo := MemberNotification.CreateWalletWithoutSendingNotification(MemberCard."Membership Entry No.", MemberCard."Member Entry No.", MemberCard."Entry No.", Today());

        if (NotificationEntryNo = 0) then
            exit(Response.RespondBadRequest('eMemberCard is missing setup, notification not created.'));

        if (not MembershipNotification.Get(NotificationEntryNo)) then
            exit(Response.RespondBadRequest('eMemberCard is missing setup, notification not created.'));

        MemberNotification.HandleMembershipNotification(MembershipNotification);
        MembershipNotificationEntry.SetFilter("Notification Entry No.", '=%1', NotificationEntryNo);
        MembershipNotificationEntry.FindFirst();

        if (MembershipNotificationEntry."Notification Send Status" = MembershipNotificationEntry."Notification Send Status"::FAILED) then
            exit(Response.RespondBadRequest(StrSubstNo('Failed to send notification: %1', MembershipNotificationEntry."Failed With Message")));

        ResponseJson.StartObject()
            .AddProperty('cardId', Format(MemberCard.SystemId, 0, 4).ToLower())
            .AddProperty('notificationSent',
                ((MembershipNotificationEntry."Notification Method" in [MembershipNotificationEntry."Notification Method"::SMS, MembershipNotificationEntry."Notification Method"::EMAIL]) and
                 (MembershipNotificationEntry."Notification Send Status" = MembershipNotificationEntry."Notification Send Status"::SENT)))
            .AddProperty('email', MembershipNotificationEntry."E-Mail Address")
            .AddProperty('phoneNo', MembershipNotificationEntry."Phone No.")
            .AddProperty('landingUrl', MembershipNotificationEntry."Wallet Pass Landing URL")
            .AddProperty('androidUrl', MembershipNotificationEntry."Wallet Pass Andriod URL")
            .AddProperty('iosUrl', MembershipNotificationEntry."Wallet Pass Default URL")
            .EndObject();

        exit(Response.RespondOK(ResponseJson.Build()));
    end;

    // **********************



    local procedure AddMemberCardWorker(var Request: Codeunit "NPR API Request"; Member: Record "NPR MM Member"; Membership: Record "NPR MM Membership"; var NewCard: Record "NPR MM Member Card")
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        MemberNotification: Codeunit "NPR MM Member Notification";
        ReasonText: Text;
    begin
        MemberInfoCapture.Init();
        MemberInfoCapture."Entry No." := 0;
        MemberInfoCapture."Membership Entry No." := Membership."Entry No.";
        MemberInfoCapture."Member Entry No" := Member."Entry No.";
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::NEW;

        DeserializeMemberCardRequest(Request, MemberInfoCapture);
        MemberInfoCapture.Insert();

        if (MemberInfoCapture."External Card No." <> '') then begin
            NewCard.SetCurrentKey("External Card No.");
            NewCard.SetFilter("External Card No.", '=%1', MemberInfoCapture."External Card No.");
            if (not NewCard.IsEmpty()) then
                Error('Card %1 already exists', MemberInfoCapture."External Card No.");
        end;

        if (not MembershipManagement.IssueMemberCard(MemberInfoCapture, MemberInfoCapture."Card Entry No.", ReasonText)) then
            Error(ReasonText);

        MemberInfoCapture.Modify();

        NewCard.Get(MemberInfoCapture."Card Entry No.");
        if (NewCard."External Card No." = '') then
            Error('Card schema setup requires new card number to be provided, card number must not be blank');

        if (MemberInfoCapture."Member Card Type" in [MemberInfoCapture."Member Card Type"::CARD_PASSSERVER, MemberInfoCapture."Member Card Type"::PASSSERVER]) then
            MemberNotification.CreateWalletSendNotification(NewCard."Membership Entry No.", NewCard."Member Entry No.", NewCard."Entry No.", Today());

        MemberInfoCapture.Delete();

    end;

    local procedure ReplaceCardWorker(var Request: Codeunit "NPR API Request"; CardToReplace: Record "NPR MM Member Card"; var NewCard: Record "NPR MM Member Card")
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        MemberNotification: Codeunit "NPR MM Member Notification";
        ReasonText: Text;
    begin
        MemberInfoCapture.Init();
        MemberInfoCapture."Entry No." := 0;
        MemberInfoCapture."Membership Entry No." := CardToReplace."Membership Entry No.";
        MemberInfoCapture."Member Entry No" := CardToReplace."Member Entry No.";
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::NEW;

        DeserializeMemberCardRequest(Request, MemberInfoCapture);
        MemberInfoCapture."Replace External Card No." := CardToReplace."External Card No.";
        MemberInfoCapture.Insert();

        if (MemberInfoCapture."External Card No." <> '') then begin
            NewCard.SetCurrentKey("External Card No.");
            NewCard.SetFilter("External Card No.", '=%1', MemberInfoCapture."External Card No.");
            if (not NewCard.IsEmpty()) then
                Error('Card %1 already exists', MemberInfoCapture."External Card No.");
        end;

        if (not MembershipManagement.IssueMemberCard(MemberInfoCapture, MemberInfoCapture."Card Entry No.", ReasonText)) then
            Error(ReasonText);

        MemberInfoCapture.Modify();

        MembershipManagement.BlockMemberCard(CardToReplace."Entry No.", true);
        CardToReplace.Get(CardToReplace."Entry No.");

        NewCard.Get(MemberInfoCapture."Card Entry No.");
        if (NewCard."External Card No." = '') then
            Error('Card schema setup requires new card number to be provided, card number must not be blank');

        if (MemberInfoCapture."Member Card Type" in [MemberInfoCapture."Member Card Type"::CARD_PASSSERVER, MemberInfoCapture."Member Card Type"::PASSSERVER]) then
            MemberNotification.CreateWalletSendNotification(NewCard."Membership Entry No.", NewCard."Member Entry No.", NewCard."Entry No.", Today());

        MemberInfoCapture.Delete();
    end;


    // **********************
    local procedure StartMemberCardDTO(ResponseJson: Codeunit "NPR JSON Builder"; MemberCard: Record "NPR MM Member Card"; IncludeMembership: Boolean; IncludeMember: Boolean): Codeunit "NPR JSON Builder"
    var
    begin
        ResponseJson.StartObject('card')
            .AddProperty('cardId', Format(MemberCard.SystemId, 0, 4).ToLower())
            .AddProperty('cardNumber', MemberCard."External Card No.")
            .AddProperty('expiryDate', MemberCard."Valid Until")
            .AddProperty('temporary', MemberCard."Card Is Temporary")
            .AddProperty('blocked', MemberCard.Blocked)
            .AddProperty('pinCode', MemberCard."Pin Code")
            .AddProperty('createdAt', MemberCard.SystemCreatedAt)
            .AddProperty('modifiedAt', MemberCard.SystemModifiedAt)
            .AddObject(StartMemberDTO(ResponseJson, MemberCard."Member Entry No.", IncludeMember))
            .AddObject(StartMembershipDTO(ResponseJson, MemberCard."Membership Entry No.", IncludeMembership))
            .EndObject();
        exit(ResponseJson);
    end;

    local procedure StartMemberDTO(ResponseJson: Codeunit "NPR JSON Builder"; MemberEntryNo: Integer; IncludeMember: Boolean): Codeunit "NPR JSON Builder"
    var
        MemberApiAgent: Codeunit "NPR MemberApiAgent";
        Member: Record "NPR MM Member";
    begin
        if (not IncludeMember) then
            exit(ResponseJson);

        if (not Member.Get(MemberEntryNo)) then
            exit(ResponseJson);

        ResponseJson.StartObject('member')
            .AddObject(MemberApiAgent.MemberDTO(ResponseJson, Member))
            .EndObject();

        exit(ResponseJson);
    end;

    local procedure StartMembershipDTO(ResponseJson: Codeunit "NPR JSON Builder"; MembershipEntryNo: Integer; IncludeMembership: Boolean): Codeunit "NPR JSON Builder"
    var
        MembershipApiAgent: Codeunit "NPR MembershipApiAgent";
        Membership: Record "NPR MM Membership";
    begin
        if (not IncludeMembership) then
            exit(ResponseJson);

        if (not Membership.Get(MembershipEntryNo)) then
            exit(ResponseJson);

        ResponseJson.StartObject('membership')
            .AddObject(MembershipApiAgent.MembershipDTO(ResponseJson, Membership))
            .EndObject();

        exit(ResponseJson);
    end;

    local procedure DeserializeMemberCardRequest(var Request: Codeunit "NPR API Request"; var MemberInfoCapture: Record "NPR MM Member Info Capture"): Boolean
    var
        Body: JsonObject;
        JToken: JsonToken;
    begin

        Body := Request.BodyJson().AsObject();

# pragma warning disable AA0139
        if (Body.Get('cardNumber', JToken)) then begin
            if (not JToken.AsValue().IsNull()) then
                MemberInfoCapture."External Card No." := JToken.AsValue().AsText();
            MemberInfoCapture.TestField("External Card No.");
        end;
# pragma warning restore AA0139

        if (Body.Get('temporary', JToken)) then
            if (not JToken.AsValue().IsNull()) then
                MemberInfoCapture."Temporary Member Card" := JToken.AsValue().AsBoolean();

        MemberInfoCapture."Valid Until" := CalcDate('<+10D>');
        if (Body.Get('expiryDate', JToken)) then
            if (not JToken.AsValue().IsNull()) then
                MemberInfoCapture."Valid Until" := JToken.AsValue().AsDate();

        if (StrLen(MemberInfoCapture."External Card No.") >= 4) then
            MemberInfoCapture."External Card No. Last 4" := CopyStr(CopyStr(MemberInfoCapture."External Card No.", StrLen(MemberInfoCapture."External Card No.") - 3), 1, 4);

        if (MemberInfoCapture."External Card No." <> '') then
            MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::FOREIGN;
    end;

    local procedure GetByCardNumber(var Request: Codeunit "NPR API Request"; var MemberCard: Record "NPR MM Member Card"): Boolean
    var
    begin
        if (not Request.QueryParams().ContainsKey('cardNumber')) then
            exit(false);

        MemberCard.SetCurrentKey("External Card No.");
        MemberCard.SetFilter("External Card No.", '=%1', CopyStr(Request.QueryParams().Get('cardNumber'), 1, MaxStrLen(MemberCard."External Card No.")));
        if (not MemberCard.FindFirst()) then
            exit(false);

        exit(true);
    end;

    local procedure GetByCardId(var Request: Codeunit "NPR API Request"; PathPosition: Integer; var MemberCard: Record "NPR MM Member Card"): Boolean
    var
        CardId: Guid;
        CardIdText: Text[50];
    begin
        CardIdText := CopyStr(Request.Paths().Get(PathPosition), 1, MaxStrLen(CardIdText));
        if (CardIdText = '') then
            exit(false);

        if (not Evaluate(CardId, CardIdText)) then
            exit(false);

        if (not MemberCard.GetBySystemId(CardId)) then
            exit(false);

        exit(true);
    end;

}
#endif