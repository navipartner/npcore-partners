#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248220 "NPR MemberApiAgent"
{
    Access = Internal;

    internal procedure FindMember(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Member: Record "NPR MM Member";
        ResponseJson: Codeunit "NPR JSON Builder";
        BirthDay: Date;
        MaxMemberCount, MemberCount : Integer;
    begin

        if (Request.QueryParams().ContainsKey('memberNumber')) then
            Member.SetFilter("External Member No.", '=%1', CopyStr(UpperCase(Request.QueryParams().Get('memberNumber')), 1, MaxStrLen(Member."External Member No.")));

        if (Request.QueryParams().ContainsKey('lastName')) then
            Member.SetFilter("Last Name", '=%1', CopyStr(Request.QueryParams().Get('lastName'), 1, MaxStrLen(Member."Last Name")));

        if (Request.QueryParams().ContainsKey('birthday')) then begin
            if (not Evaluate(BirthDay, Request.QueryParams().Get('birthday'))) then
                exit(Response.RespondBadRequest('Invalid birthday format'));
            Member.SetFilter("Birthday", '=%1', BirthDay);
        end;
        if (Request.QueryParams().ContainsKey('email')) then
            Member.SetFilter("E-Mail Address", '=%1', CopyStr(LowerCase(Request.QueryParams().Get('email')), 1, MaxStrLen(Member."E-Mail Address")));

        if (Request.QueryParams().ContainsKey('phone')) then
            Member.SetFilter("Phone No.", '=%1', CopyStr(Request.QueryParams().Get('phone'), 1, MaxStrLen(Member."Phone No.")));

        MaxMemberCount := 10;
        if (Request.QueryParams().ContainsKey('limit')) then begin
            if (not Evaluate(MaxMemberCount, Request.QueryParams().Get('limit'))) then
                exit(Response.RespondBadRequest('Invalid limit format'));
            if (MaxMemberCount < 1) then
                exit(Response.RespondBadRequest('Invalid limit value'));
            if (MaxMemberCount > 100) then
                exit(Response.RespondBadRequest('Limit value is too high'));
        end;
        ResponseJson.StartObject().StartArray('members');

        if (Member.FindSet()) then begin
            MemberCount := 0;
            repeat
                ResponseJson.AddObject(StartAnonymousMemberDTO(ResponseJson, Member));
                MemberCount += 1;
            until (Member.Next() = 0) or (MemberCount >= MaxMemberCount);
        end;

        ResponseJson.EndArray().EndObject();
        exit(Response.RespondOK(ResponseJson.Build()));

    end;

    internal procedure GetMemberById(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Member: Record "NPR MM Member";
        ResponseJson: Codeunit "NPR JSON Builder";
    begin
        if (not GetMemberById(Request, 3, Member)) then
            exit(InvalidMemberIdResponse());

        ResponseJson.StartObject()
            .AddObject(StartMemberDTO(ResponseJson, Member, true))
            .EndObject();

        exit(Response.RespondOK(ResponseJson.Build()));
    end;

    internal procedure BlockMember(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Member: Record "NPR MM Member";
        MembershipRole: Record "NPR MM Membership Role";
        ResponseJson: Codeunit "NPR JSON Builder";
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
    begin
        if (not GetMemberById(Request, 3, Member)) then
            exit(InvalidMemberIdResponse());

        MembershipRole.SetFilter("Member Entry No.", '=%1', Member."Entry No.");
        if (not MembershipRole.FindSet()) then
            exit(Response.RespondBadRequest('Member has no memberships'));

        repeat
            MembershipMgt.BlockMember(MembershipRole."Membership Entry No.", Member."Entry No.", true);
        until (MembershipRole.Next() = 0);

        Member.Get(Member."Entry No.");
        ResponseJson.StartObject()
            .AddObject(StartMemberDTO(ResponseJson, Member, false))
            .EndObject();

        exit(Response.RespondOK(ResponseJson.Build()));
    end;

    internal procedure UnblockMember(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Member: Record "NPR MM Member";
        MembershipRole: Record "NPR MM Membership Role";
        ResponseJson: Codeunit "NPR JSON Builder";
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
    begin
        if (not GetMemberById(Request, 3, Member)) then
            exit(InvalidMemberIdResponse());

        MembershipRole.SetFilter("Member Entry No.", '=%1', Member."Entry No.");
        if (not MembershipRole.FindSet()) then
            exit(Response.RespondBadRequest('Member has no memberships'));

        repeat
            MembershipMgt.BlockMember(MembershipRole."Membership Entry No.", Member."Entry No.", false);
        until (MembershipRole.Next() = 0);

        Member.Get(Member."Entry No.");
        ResponseJson.StartObject()
            .AddObject(StartMemberDTO(ResponseJson, Member, false))
            .EndObject();

        exit(Response.RespondOK(ResponseJson.Build()));
    end;

    internal procedure GetMemberImage(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Member: Record "NPR MM Member";
        ResponseJson: Codeunit "NPR JSON Builder";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        Base64StringImage: Text;
        ImageSize: text[20];
        HaveImage: Boolean;
    begin
        Member.SetLoadFields("Entry No.", Image);

        if (not GetMemberById(Request, 3, Member)) then
            exit(InvalidMemberIdResponse());

        if (not Member.Image.HasValue()) then
            exit(Response.RespondBadRequest('Member has no image'));

        if (Request.QueryParams().ContainsKey('size')) then
            ImageSize := CopyStr(Request.QueryParams().Get('size'), 1, MaxStrLen(ImageSize));

        case LowerCase(ImageSize) of
            'small':
                HaveImage := MembershipManagement.GetMemberImageThumbnail(Member."Entry No.", Base64StringImage, 70);
            'medium':
                HaveImage := MembershipManagement.GetMemberImageThumbnail(Member."Entry No.", Base64StringImage, 240);
            'large':
                HaveImage := MembershipManagement.GetMemberImageThumbnail(Member."Entry No.", Base64StringImage, 360);
            'embedded':
                HaveImage := MembershipManagement.GetMemberImageThumbnail(Member."Entry No.", Base64StringImage, 0);
            'original':
                HaveImage := MembershipManagement.GetMemberImage(Member."Entry No.", Base64StringImage);
            else
                HaveImage := MembershipManagement.GetMemberImageThumbnail(Member."Entry No.", Base64StringImage);
        end;

        if (not HaveImage) then
            exit(Response.RespondBadRequest('There was an error retrieving the image with that size, try one of these: small, medium, large, embedded, original'));

        ResponseJson.StartObject()
            .AddProperty('image', Base64StringImage)
            .EndObject();

        exit(Response.RespondOK(ResponseJson.Build()));
    end;

    internal procedure SetMemberImage(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Member: Record "NPR MM Member";
        ResponseJson: Codeunit "NPR JSON Builder";
        JObject: JsonObject;
        JToken: JsonToken;
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        if (not GetMemberById(Request, 3, Member)) then
            exit(InvalidMemberIdResponse());

        JObject := Request.BodyJson().AsObject();
        if (not JObject.Get('image', JToken)) then
            exit(Response.RespondBadRequest('Missing image property'));

        if (not MembershipManagement.UpdateMemberImage(Member."Entry No.", JToken.AsValue().AsText())) then
            exit(Response.RespondBadRequest('There was an error updating the image'));

        Member.Get(Member."Entry No.");
        ResponseJson.StartObject()
            .AddProperty('mediaId', Format(Member.Image.MediaId(), 0, 4).ToLower())
            .EndObject();

        exit(Response.RespondOK(ResponseJson.Build()));
    end;

    internal procedure AddMember(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        MemberInfoCapture: Record "NPR MM Member Info Capture";

        ResponseJson: Codeunit "NPR JSON Builder";
        MembershipAgent: Codeunit "NPR MembershipApiAgent";
        AttributeAgent: Codeunit "NPR MembershipAttributesAgent";
    begin
        if (not MembershipAgent.GetMembershipById(Request, 2, Membership)) then
            exit(Response.RespondBadRequest('Invalid Membership - Membership Id not valid.'));

        MemberInfoCapture.Init();
        MemberInfoCapture."Entry No." := 0;
        InitializeMemberInfoCapture(Membership, MemberInfoCapture);
        DeserializeMemberRequest(Request, MemberInfoCapture);
        MemberInfoCapture.Insert();

        AttributeAgent.ApplyInboundMemberAttributesToMemberInfoCapture(Request, MemberInfoCapture."Entry No.");

        if (CreateMemberWorker(MemberInfoCapture)) then begin
            Member.Get(MemberInfoCapture."Member Entry No");
            ResponseJson.StartObject()
                .AddObject(StartMemberDTO(ResponseJson, Membership."Entry No.", Member, false, true))
                .EndObject();
            MemberInfoCapture.Delete();
            exit(Response.RespondCreated(ResponseJson.Build()));
        end;

        MemberInfoCapture.Delete();
        exit(Response.RespondBadRequest('Member creation failed.'));

    end;

    internal procedure UpdateMember(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        MembershipRole: Record "NPR MM Membership Role";
        MemberInfoCapture: Record "NPR MM Member Info Capture";

        ResponseJson: Codeunit "NPR JSON Builder";
        AttributeAgent: Codeunit "NPR MembershipAttributesAgent";
    begin
        if (not GetMemberById(Request, 3, Member)) then
            exit(InvalidMemberIdResponse());

        // !Problem when member has multiple community memberships
        MembershipRole.SetFilter("Member Entry No.", '=%1', Member."Entry No.");
        if (not MembershipRole.FindSet()) then
            exit(Response.RespondBadRequest('Member has no memberships'));
        Membership.Get(MembershipRole."Membership Entry No.");

        MemberInfoCapture.Init();
        MemberInfoCapture."Entry No." := 0;
        InitializeMemberInfoCapture(Membership, MemberInfoCapture);
        InitializeMemberInfoCapture(Member, MemberInfoCapture);

        DeserializeMemberRequest(Request, MemberInfoCapture);
        MemberInfoCapture.Insert();

        AttributeAgent.ApplyInboundMemberAttributesToMemberInfoCapture(Request, MemberInfoCapture."Entry No.");

        if (UpdateMemberWorker(MemberInfoCapture)) then begin
            Member.Get(MemberInfoCapture."Member Entry No");
            ResponseJson.StartObject()
                .AddObject(StartMemberDTO(ResponseJson, Member, false))
                .EndObject();
            MemberInfoCapture.Delete();
            exit(Response.RespondOk(ResponseJson.Build()));
        end;

        MemberInfoCapture.Delete();
        exit(Response.RespondBadRequest('Member creation failed.'));

    end;

    internal procedure GetMemberNotes(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Member: Record "NPR MM Member";
    begin
        if (not GetMemberById(Request, 3, Member)) then
            exit(InvalidMemberIdResponse());

        exit(Response.RespondOK(MemberNotesDTO(Member).BuildAsArray()));

    end;

    internal procedure AddMemberNote(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Member: Record "NPR MM Member";
        RecordLink: Record "Record Link";
        RecordLinkManagement: Codeunit "Record Link Management";
        JToken: JsonToken;
        TitleText: Text;
        CommentText: Text;
        Body: JsonObject;
    begin

        if (not GetMemberById(Request, 3, Member)) then
            exit(InvalidMemberIdResponse());

        Body := Request.BodyJson().AsObject();

        if (Body.Get('title', JToken)) then
            TitleText := JToken.AsValue().AsText();

        Body.Get('comment', JToken);
        CommentText := JToken.AsValue().AsText();

        RecordLink.Get(Member.AddLink('', TitleText));
        RecordLink.Type := RecordLink.Type::Note;
        RecordLink."User ID" := CopyStr(UserId, 1, MaxStrLen(RecordLink."User ID"));
        RecordLinkManagement.WriteNote(RecordLink, CommentText);
        RecordLink.Modify(true);

        exit(Response.RespondOK(MemberNotesDTO(Member).BuildAsArray()));

    end;


    // *****************************************

    local procedure InvalidMemberIdResponse() Response: Codeunit "NPR API Response"
    begin
        exit(Response.RespondBadRequest('Invalid member ID'));
    end;


    internal procedure GetMemberById(var Request: Codeunit "NPR API Request"; PathPosition: Integer; var Member: Record "NPR MM Member"): Boolean
    var
        MemberIdText: Text[50];
        MemberId: Guid;
    begin
        MemberIdText := CopyStr(Request.Paths().Get(PathPosition), 1, MaxStrLen(MemberIdText));
        if (MemberIdText = '') then
            exit(false);

        if (not Evaluate(MemberId, MemberIdText)) then
            exit(false);

        if (not Member.GetBySystemId(MemberId)) then
            exit(false);

        exit(true);
    end;

    // *****************************************

    local procedure InitializeMemberInfoCapture(Membership: Record "NPR MM Membership"; var MemberInfoCapture: Record "NPR MM Member Info Capture")
    begin
        MemberInfoCapture."Membership Entry No." := Membership."Entry No.";
        MemberInfoCapture."External Membership No." := Membership."External Membership No.";
    end;

    local procedure InitializeMemberInfoCapture(Member: Record "NPR MM Member"; var MemberInfoCapture: Record "NPR MM Member Info Capture")
    begin
        MemberInfoCapture."Member Entry No" := Member."Entry No.";
        MemberInfoCapture."External Member No" := Member."External Member No.";

        MemberInfoCapture."First Name" := Member."First Name";
        MemberInfoCapture."Middle Name" := Member."Middle Name";
        MemberInfoCapture."Last Name" := Member."Last Name";
        MemberInfoCapture.Address := Member.Address;
        MemberInfoCapture."Post Code Code" := Member."Post Code Code";
        MemberInfoCapture.City := Member.City;
        MemberInfoCapture."Country Code" := Member."Country Code";
        MemberInfoCapture.Country := Member.Country;
        MemberInfoCapture."E-Mail Address" := Member."E-Mail Address";
        MemberInfoCapture."Phone No." := Member."Phone No.";
        MemberInfoCapture."Social Security No." := Member."Social Security No.";

        MemberInfoCapture.Gender := Member.Gender;
        MemberInfoCapture.Birthday := Member.Birthday;
        MemberInfoCapture."News Letter" := Member."E-Mail News Letter";
        MemberInfoCapture.PreferredLanguageCode := Member.PreferredLanguageCode;
        MemberInfoCapture."Notification Method" := Member."Notification Method";

        MemberInfoCapture."Store Code" := Member."Store Code";
    end;

# pragma warning disable AA0139
    local procedure DeserializeMemberRequest(var Request: Codeunit "NPR API Request"; var MemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        Body, MemberJson, CardJson : JsonObject;
        JToken: JsonToken;
        Language: Record "NPR MM Language";
    begin

        Body := Request.BodyJson().AsObject();
        if (not Body.Get('member', JToken)) then
            Error('Missing member property');

        MemberJson := JToken.AsObject();
        if (MemberJson.Get('address', JToken)) then
            MemberInfoCapture.Address := JToken.AsValue().AsText();

        if (MemberJson.Get('birthday', JToken)) then
            if (not JToken.AsValue().IsNull()) then
                MemberInfoCapture.Birthday := JToken.AsValue().AsDate();

        if (MemberJson.Get('city', JToken)) then
            if (not JToken.AsValue().IsNull()) then
                MemberInfoCapture.City := JToken.AsValue().AsText();

        if (MemberJson.Get('country', JToken)) then
            if (not JToken.AsValue().IsNull()) then
                MemberInfoCapture.Country := JToken.AsValue().AsText();

        if (MemberJson.Get('email', JToken)) then
            if (not JToken.AsValue().IsNull()) then
                MemberInfoCapture."E-Mail Address" := JToken.AsValue().AsText();

        if (MemberJson.Get('firstName', JToken)) then
            if (not JToken.AsValue().IsNull()) then
                MemberInfoCapture."First Name" := JToken.AsValue().AsText();

        if (MemberJson.Get('gender', JToken)) then
            if (not JToken.AsValue().IsNull()) then
                MemberInfoCapture.Gender := DecodeGender(JToken.AsValue().AsText());

        if (MemberJson.Get('lastName', JToken)) then
            if (not JToken.AsValue().IsNull()) then
                MemberInfoCapture."Last Name" := JToken.AsValue().AsText();

        if (MemberJson.Get('middleName', JToken)) then
            if (not JToken.AsValue().IsNull()) then
                MemberInfoCapture."Middle Name" := JToken.AsValue().AsText();

        if (MemberJson.Get('newsletter', JToken)) then begin
            if (not JToken.AsValue().IsNull()) then
                MemberInfoCapture."News Letter" := DecodeNewsLetter(JToken.AsValue().AsText());
        end;

        if (MemberJson.Get('phoneNo', JToken)) then
            if (not JToken.AsValue().IsNull()) then
                MemberInfoCapture."Phone No." := JToken.AsValue().AsText();

        if (MemberJson.Get('postCode', JToken)) then
            if (not JToken.AsValue().IsNull()) then
                MemberInfoCapture."Post Code Code" := JToken.AsValue().AsText();

        if (MemberInfoCapture."E-Mail Address" = '') and (MemberInfoCapture."Phone No." <> '') then
            MemberInfoCapture."Notification Method" := MemberInfoCapture."Notification Method"::SMS;

        if (MemberInfoCapture."E-Mail Address" <> '') and (MemberInfoCapture."Phone No." = '') then
            MemberInfoCapture."Notification Method" := MemberInfoCapture."Notification Method"::EMAIL;

        if (MemberInfoCapture."E-Mail Address" <> '') and (MemberInfoCapture."Phone No." <> '') then
            MemberInfoCapture."Notification Method" := MemberInfoCapture."Notification Method"::EMAIL;

        if (MemberJson.Get('preferredLanguage', JToken)) then
            if (not JToken.AsValue().IsNull()) then
                MemberInfoCapture.PreferredLanguageCode := JToken.AsValue().AsText();
        if (MemberInfoCapture.PreferredLanguageCode <> '') then begin
            if (not Language.Get(MemberInfoCapture.PreferredLanguageCode)) then
                MemberInfoCapture.PreferredLanguageCode := '';
        end;

        if (MemberJson.Get('gdprConsent', JToken)) then
            if (not JToken.AsValue().IsNull()) then
                MemberInfoCapture."GDPR Approval" := DecodeGdprConsent(JToken.AsValue().AsText());

        MemberInfoCapture."Member Card Type" := MemberInfoCapture."Member Card Type"::NONE;
        if (MemberJson.Get('card', JToken)) then begin

            CardJson := JToken.AsObject();
            if (CardJson.Get('cardNumber', JToken)) then
                if (not JToken.AsValue().IsNull()) then
                    MemberInfoCapture."External Card No." := JToken.AsValue().AsText();

            if (CardJson.Get('temporary', JToken)) then
                if (not JToken.AsValue().IsNull()) then
                    MemberInfoCapture."Temporary Member Card" := JToken.AsValue().AsBoolean();

            MemberInfoCapture."Valid Until" := CalcDate('<+10D>');
            if (CardJson.Get('expiryDate', JToken)) then
                if (not JToken.AsValue().IsNull()) then
                    MemberInfoCapture."Valid Until" := JToken.AsValue().AsDate();

            if (StrLen(MemberInfoCapture."External Card No.") >= 4) then
                MemberInfoCapture."External Card No. Last 4" := CopyStr(MemberInfoCapture."External Card No.", StrLen(MemberInfoCapture."External Card No.") - 3);
        end;

        if (MemberJson.Get('preassignedContactNumber', JToken)) then
            if (not JToken.AsValue().IsNull()) then
                MemberInfoCapture."Contact No." := JToken.AsValue().AsText();

        if (MemberJson.Get('storeCode', JToken)) then
            if (not JToken.AsValue().IsNull()) then
                MemberInfoCapture."Store Code" := JToken.AsValue().AsText();

        if (Request.QueryParams().ContainsKey('allowMergeOnConflict')) then
            MemberInfoCapture.AllowMergeOnConflict := (Request.QueryParams().Get('allowMergeOnConflict').ToLower() in ['true', '1']);

        MemberInfoCapture."Import Entry Document ID" := UpperCase(DelChr(Format(CreateGuid()), '=', '{}-'));
    end;
#pragma warning restore AA0139

    local procedure DecodeGdprConsent(ConsentText: Text): Option
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin
        case UpperCase(ConsentText) of
            'PENDING', '1', UpperCase(Format(MemberInfoCapture."GDPR Approval"::PENDING, 0, 9)):
                exit(MemberInfoCapture."GDPR Approval"::PENDING);
            'ACCEPT', 'ACCEPTED', '2', UpperCase(Format(MemberInfoCapture."GDPR Approval"::ACCEPTED, 0, 9)):
                exit(MemberInfoCapture."GDPR Approval"::ACCEPTED);
            'REJECT', 'REJECTED', '3', UpperCase(Format(MemberInfoCapture."GDPR Approval"::REJECTED, 0, 9)):
                exit(MemberInfoCapture."GDPR Approval"::REJECTED);
            else
                exit(MemberInfoCapture."GDPR Approval"::NA);
        end;
    end;

    local procedure DecodeGender(GenderText: Text): Option
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin
        case UpperCase(GenderText) of
            'MALE', '1', Format(MemberInfoCapture.Gender::MALE, 0, 9):
                exit(MemberInfoCapture.Gender::MALE);
            'FEMALE', '2', Format(MemberInfoCapture.Gender::FEMALE, 0, 9):
                exit(MemberInfoCapture.Gender::FEMALE);
            'OTHER', '3', Format(MemberInfoCapture.Gender::OTHER, 0, 9):
                exit(MemberInfoCapture.Gender::OTHER);
            else
                exit(MemberInfoCapture.Gender::NOT_SPECIFIED);
        end;
    end;

    local procedure DecodeNewsLetter(NewsLetter: Text): Option
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin
        case UpperCase(NewsLetter) of
            'YES', '1', Format(MemberInfoCapture."News Letter"::YES, 0, 9):
                exit(MemberInfoCapture."News Letter"::YES);
            'NO', '0', Format(MemberInfoCapture."News Letter"::NO, 0, 9):
                exit(MemberInfoCapture."News Letter"::NO);
            else
                exit(MemberInfoCapture."News Letter"::NOT_SPECIFIED);
        end;
    end;

    local procedure CreateMemberWorker(var MemberInfoCapture: Record "NPR MM Member Info Capture"): Boolean
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        ResponseMessage: Text;
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        MembershipEntry: Record "NPR MM Membership Entry";
    begin

        Membership.Get(MemberInfoCapture."Membership Entry No.");
        MemberInfoCapture.TestField("External Membership No.");

        // There should probably be date constraints here to figure out exactly which item controls the age constrains. 
        MembershipEntry.SetFilter("Membership Entry No.", '=%1', MemberInfoCapture."Membership Entry No.");
        MembershipEntry.SetFilter("Membership Code", '=%1', Membership."Membership Code");
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        MembershipEntry.SetFilter(Context, '%1|%2|%3|%4|%5', MembershipEntry.Context::NEW, MembershipEntry.Context::RENEW, MembershipEntry.Context::UPGRADE, MembershipEntry.Context::EXTEND, MembershipEntry.Context::AUTORENEW);
        if (MembershipEntry.FindLast()) then
            MemberInfoCapture."Item No." := MembershipEntry."Item No.";

        // TransferAttributes(Request, MemberInfoCapture);

        if (not (MembershipManagement.AddMemberAndCard(MemberInfoCapture."Membership Entry No.", MemberInfoCapture, true, MemberInfoCapture."Member Entry No", ResponseMessage))) then
            Error(ResponseMessage);

        MemberInfoCapture.Modify();

        Member.Get(MemberInfoCapture."Member Entry No");
        Member."Document ID" := MemberInfoCapture."Import Entry Document ID";
        Member.Modify();

        /*
        MembershipSetup.Get(Membership."Membership Code");
        MemberCard.Get(MemberInfoCapture."Card Entry No.");
        MemberCard.SetRecFilter();
        case MembershipSetup."Web Service Print Action" of
            MembershipSetup."Web Service Print Action"::DIRECT:
                MemberRetailIntegration.PrintMemberCardWorker(MemberCard, MembershipSetup);
            MembershipSetup."Web Service Print Action"::OFFLINE:
                MembershipManagement.PrintOffline(MemberInfoCapture."Information Context"::PRINT_CARD, MemberInfoCapture."Card Entry No.");
        end;
        */

        exit(true);
    end;

    local procedure UpdateMemberWorker(var MemberInfoCapture: Record "NPR MM Member Info Capture"): Boolean
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        Member: Record "NPR MM Member";
    begin
        MemberInfoCapture.TestField("External Member No");

        MembershipManagement.UpdateMember(MemberInfoCapture."Membership Entry No.", MemberInfoCapture."Member Entry No", MemberInfoCapture);
        MemberInfoCapture.Modify();

        Member.Get(MemberInfoCapture."Member Entry No");
        Member."Document ID" := MemberInfoCapture."Import Entry Document ID";
        Member.Modify();

        exit(true);
    end;

    // *****************************************
    local procedure StartMemberDTO(var ResponseJson: Codeunit "NPR JSON Builder"; var Member: Record "NPR MM Member"; IncludeMembership: Boolean): Codeunit "NPR JSON Builder"
    begin
        ResponseJson.StartObject('member')
            .AddObject(MemberDTO(ResponseJson, Member))
            .AddArray(MembershipsDTO(ResponseJson, Member."Entry No.", IncludeMembership))
            .EndObject();
    end;

    local procedure StartMemberDTO(var ResponseJson: Codeunit "NPR JSON Builder"; MembershipEntryNo: Integer; var Member: Record "NPR MM Member"; IncludeMembership: Boolean; IncludeCards: Boolean): Codeunit "NPR JSON Builder"
    begin
        ResponseJson.StartObject('member')
            .AddArray(MembershipsDTO(ResponseJson, Member."Entry No.", IncludeMembership))
            .AddObject(MemberDTO(ResponseJson, Member))
            .AddArray(MemberCardsDTO(ResponseJson, MembershipEntryNo, Member."Entry No.", IncludeCards))
            .EndObject();
    end;


    local procedure StartAnonymousMemberDTO(var ResponseJson: Codeunit "NPR JSON Builder"; var Member: Record "NPR MM Member"): Codeunit "NPR JSON Builder"
    begin
        ResponseJson.StartObject()
            .AddObject(MemberDTO(ResponseJson, Member))
            .EndObject();
    end;

    internal procedure MemberDTO(var ResponseJson: Codeunit "NPR JSON Builder"; Member: Record "NPR MM Member"): Codeunit "NPR JSON Builder"
    var
        Encode: Codeunit "NPR MembershipApiTranslation";
        MemberAttributes: Codeunit "NPR MembershipAttributesAgent";
    begin
        ResponseJson
            .AddProperty('memberId', Format(Member.SystemId, 0, 4).ToLower())
            .AddProperty('memberNumber', Member."External Member No.")
            .AddProperty('blocked', Member.Blocked)
            .AddProperty('firstName', Member."First Name")
            .AddProperty('middleName', Member."Middle Name")
            .AddProperty('lastName', Member."Last Name")
            .AddProperty('address', Member.Address)
            .AddProperty('postCode', Member."Post Code Code")
            .AddProperty('city', Member.City)
            .AddProperty('country', Member.Country)
            .AddProperty('gender', Encode.GenderAsText(Member.Gender))
            .AddProperty('newsletter', Encode.NewsLetterAsText(Member."E-Mail News Letter"))
            .AddProperty('email', Member."E-Mail Address")
            .AddProperty('phoneNo', Member."Phone No.")
            .AddObject(AddRequiredProperty(ResponseJson, 'birthday', Member.Birthday))
            .AddProperty('hasPicture', Member.Image.HasValue())
            .AddProperty('hasNotes', Member.HasLinks())
            .AddArray(MemberAttributes.MemberAttributesDTO(ResponseJson, Member."Entry No."));
        exit(ResponseJson);
    end;

    local procedure AddRequiredProperty(var ResponseJson: Codeunit "NPR JSON Builder"; PropertyName: Text; PropertyValue: Date): Codeunit "NPR JSON Builder"
    begin
        if (PropertyValue <> 0D) then
            ResponseJson.AddProperty(PropertyName, PropertyValue)
        else
            ResponseJson.AddProperty(PropertyName);

        exit(ResponseJson);
    end;

    local procedure MembershipsDTO(var ResponseJson: Codeunit "NPR JSON Builder"; MemberEntryNo: Integer; IncludeMembership: Boolean): Codeunit "NPR JSON Builder"
    var
        MembershipRole: Record "NPR MM Membership Role";
        Membership: Record "NPR MM Membership";
        Encode: Codeunit "NPR MembershipApiTranslation";
    begin
        if (not IncludeMembership) then
            exit(ResponseJson);

        MembershipRole.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
        if (not MembershipRole.FindSet()) then begin
            ResponseJson.StartArray('memberships').EndArray();
            exit(ResponseJson);
        end;

        ResponseJson.StartArray('memberships');
        repeat
            Membership.Get(MembershipRole."Membership Entry No.");
            ResponseJson.StartObject()
                .AddProperty('role', Encode.MemberRoleToText(MembershipRole."Member Role"))
                .AddProperty('contactNumber', MembershipRole."Contact No.")
                .AddObject(MembershipDTO(ResponseJson, Membership, MemberEntryNo, true))
                .EndObject();
        until (MembershipRole.Next() = 0);

        ResponseJson.EndArray();
        exit(ResponseJson);
    end;

    local procedure MembershipDTO(ResponseJson: Codeunit "NPR JSON Builder"; Membership: Record "NPR MM Membership"; MemberEntryNo: Integer; IncludeCards: Boolean): Codeunit "NPR JSON Builder"
    var
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
        ValidFrom, ValidUntil : Date;
        MembershipApiAgent: Codeunit "NPR MembershipApiAgent";
    begin

        MembershipMgt.GetConsecutiveTimeFrame(Membership."Entry No.", Today(), ValidFrom, ValidUntil);

        ResponseJson.StartObject('membership')
            .AddObject(MembershipApiAgent.MembershipDTO(ResponseJson, Membership))
            .AddArray(MemberCardsDTO(ResponseJson, Membership."Entry No.", MemberEntryNo, IncludeCards))
        .EndObject();

        exit(ResponseJson);
    end;

    local procedure MemberCardsDTO(ResponseJson: Codeunit "NPR JSON Builder"; MembershipEntryNo: Integer; MemberEntryNo: Integer; IncludeCards: Boolean): Codeunit "NPR JSON Builder"
    var
        MemberCard: Record "NPR MM Member Card";
    begin
        if (not IncludeCards) then
            exit(ResponseJson);

        ResponseJson.StartArray('cards');
        MemberCard.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MemberCard.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
        if (MemberCard.FindSet()) then begin
            repeat
                ResponseJson.StartObject()
                    .AddProperty('cardId', Format(MemberCard.SystemId, 0, 4).ToLower())
                    .AddProperty('cardNumber', MemberCard."External Card No.")
                    .AddProperty('expiryDate', MemberCard."Valid Until")
                    .AddProperty('temporary', MemberCard."Card Is Temporary")
                    .AddProperty('blocked', MemberCard.Blocked)
                    .AddProperty('createdAt', MemberCard.SystemCreatedAt)
                    .AddProperty('modifiedAt', MemberCard.SystemModifiedAt)
                    .EndObject();
            until (MemberCard.Next() = 0);
        end;

        ResponseJson.EndArray();
        exit(ResponseJson);
    end;


    local procedure MemberNotesDTO(Member: Record "NPR MM Member") ResponseJson: Codeunit "NPR JSON Builder";
    var
        RecordLink: Record "Record Link";
        RecordLinkManagement: Codeunit "Record Link Management";

        CommentText: Text;
    begin
        ResponseJson.StartArray();

        RecordLink.SetCurrentKey("Record ID");
        RecordLink.SetFilter("Record ID", '=%1', Member.RecordId());
        RecordLink.SetFilter(Type, '=%1', RecordLink.Type::Note);
        RecordLink.SetAutoCalcFields(Note);
        if (RecordLink.FindSet()) then begin
            repeat
                CommentText := RecordLinkManagement.ReadNote(RecordLink);
                ResponseJson
                    .StartObject('note')
                    .AddProperty('id', Format(RecordLink.SystemId, 0, 4).ToLower())
                    .AddProperty('title', RecordLink.Description)
                    .AddProperty('comment', CommentText)
                    .AddProperty('createdAt', RecordLink.SystemCreatedAt)
                    .AddProperty('modifiedAt', RecordLink.SystemModifiedAt)
                    .EndObject();

            until (RecordLink.Next() = 0);
        end;

        ResponseJson.EndArray();
        exit(ResponseJson);
    end;

}
#endif