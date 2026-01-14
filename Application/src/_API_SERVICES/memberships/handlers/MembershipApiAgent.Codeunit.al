#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22   
codeunit 6185123 "NPR MembershipApiAgent"
{
    Access = Internal;

    internal procedure GetMembershipByNumber(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Number: Code[20];
    begin

        if (Request.QueryParams().ContainsKey('membershipNumber')) then begin
            Number := CopyStr(UpperCase(Request.QueryParams().Get('membershipNumber')), 1, MaxStrLen(Number));
            exit(GetMembershipByNumber(Number));
        end;

        if (Request.QueryParams().ContainsKey('customerNumber')) then begin
            Number := CopyStr(UpperCase(Request.QueryParams().Get('customerNumber')), 1, MaxStrLen(Number));
            exit(GetMembershipByCustomerNumber(Number));
        end;

        exit(Response.RespondBadRequest('membershipNumber or customerNumber is required.'));
    end;

    internal procedure GetMembershipById(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Membership: Record "NPR MM Membership";
        ResponseJson: Codeunit "NPR JSON Builder";
    begin
        if (not GetMembershipById(Request, 2, Membership)) then
            exit(Response.RespondBadRequest('Invalid Membership - Membership Id not valid.'));

        ResponseJson.StartObject()
            .AddObject(StartMembershipDTO(ResponseJson, Membership, false))
            .EndObject();

        exit(Response.RespondOK(ResponseJson.Build()));

    end;

    internal procedure CreateMembership(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        Membership: Record "NPR MM Membership";
        ResponseJson: Codeunit "NPR JSON Builder";
        AttributeAgent: Codeunit "NPR MembershipAttributesAgent";
    begin
        MemberInfoCapture.Init();
        MemberInfoCapture."Entry No." := 0;
        DeserializeCreateMembershipRequest(Request, MemberInfoCapture);
        MemberInfoCapture.Insert();

        AttributeAgent.ApplyInboundMembershipAttributesToMemberInfoCapture(Request, MemberInfoCapture);

        if (CreateMembershipWorker(MemberInfoCapture)) then begin
            Membership.Get(MemberInfoCapture."Membership Entry No.");
            ResponseJson.StartObject()
                .AddObject(StartMembershipDTO(ResponseJson, Membership, false))
                .EndObject();
            MemberInfoCapture.Delete();
            exit(Response.RespondCreated(ResponseJson.Build()));
        end;

        MemberInfoCapture.Delete();
        exit(Response.RespondBadRequest('Membership creation failed.'));
    end;

    internal procedure BlockMembership(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Membership: Record "NPR MM Membership";
        ResponseJson: Codeunit "NPR JSON Builder";
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
    begin
        if (not GetMembershipById(Request, 2, Membership)) then
            exit(Response.RespondBadRequest('Invalid Membership - Membership Id not valid.'));

        MembershipMgt.BlockMembership(Membership."Entry No.", true);

        Membership.Get(Membership."Entry No.");
        ResponseJson.StartObject()
            .AddObject(StartMembershipDTO(ResponseJson, Membership, false))
            .EndObject();

        exit(Response.RespondOK(ResponseJson.Build()));

    end;

    internal procedure UnblockMembership(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Membership: Record "NPR MM Membership";
        ResponseJson: Codeunit "NPR JSON Builder";
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
    begin
        if (not GetMembershipById(Request, 2, Membership)) then
            exit(Response.RespondBadRequest('Invalid Membership - Membership Id not valid.'));

        MembershipMgt.BlockMembership(Membership."Entry No.", false);

        Membership.Get(Membership."Entry No.");
        ResponseJson.StartObject()
            .AddObject(StartMembershipDTO(ResponseJson, Membership, false))
            .EndObject();

        exit(Response.RespondOK(ResponseJson.Build()));

    end;

    internal procedure GetMembershipMembers(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Membership: Record "NPR MM Membership";
        ResponseJson: Codeunit "NPR JSON Builder";
    begin
        if (not GetMembershipById(Request, 2, Membership)) then
            exit(Response.RespondBadRequest('Invalid Membership - Membership Id not valid.'));

        ResponseJson.StartObject()
            .AddObject(StartMembershipDTO(ResponseJson, Membership, true))
            .EndObject();
        exit(Response.RespondOK(ResponseJson.Build()));
    end;

    internal procedure GetMembershipRenewalInfo(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        Subscription: Record "NPR MM Subscription";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
        RequestSubscrRenewal: Codeunit "NPR MM Subscr. Renew: Request";
        ResponseJson: Codeunit "NPR JSON Builder";
        MembershipID: Text;
        SubscriptionRequestFound: Boolean;
    begin
        MembershipID := Request.Paths().Get(2);
        if MembershipID = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: membershipId'));

        Membership.ReadIsolation := IsolationLevel::ReadCommitted;
        if not Membership.GetBySystemId(MembershipID) then
            exit(Response.RespondResourceNotFound(StrSubstNo('Membership %1', MembershipID)));

        Subscription.SetRange("Membership Entry No.", Membership."Entry No.");
        if not Subscription.FindFirst() then begin
            Subscription.Init();
            Subscription."Membership Code" := Membership."Membership Code";
            Subscription."Membership Entry No." := Membership."Entry No.";
            MembershipMgt.GetConsecutiveTimeFrame(Membership."Entry No.", Today(), Subscription."Valid From Date", Subscription."Valid Until Date");
        end;

        if Subscription."Entry No." <> 0 then begin
            SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
            SubscriptionRequest.SetFilter("Processing Status", '%1|%2', SubscriptionRequest."Processing Status"::Pending, SubscriptionRequest."Processing Status"::Error);
            SubscriptionRequest.SetFilter(Status, '<>%1', SubscriptionRequest.Status::Cancelled);
            SubscriptionRequestFound := SubscriptionRequest.FindLast();
        end else
            SubscriptionRequestFound := false;

        if not SubscriptionRequestFound then begin
            if Subscription."Membership Ledger Entry No." = 0 then begin
                MembershipEntry.SetCurrentKey("Entry No.");
                MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
                MembershipEntry.SetRange(Blocked, false);
                MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
                MembershipEntry.SetLoadFields("Entry No.");
                if not MembershipEntry.FindLast() then
                    exit(Response.RespondResourceNotFound(StrSubstNo('The time entries for the membership %1 on which the calculation can be based were', MembershipID)));
                Subscription."Membership Ledger Entry No." := MembershipEntry."Entry No.";
            end;
            RequestSubscrRenewal.CalculateSubscriptionRenewal(Subscription, SubscriptionRequest);
        end;

        ResponseJson.StartObject()
            .StartObject('membership')
                .AddProperty('membershipId', Format(Membership.SystemId, 0, 4).ToLower())
                .AddProperty('membershipNumber', Membership."External Membership No.")
                .AddProperty('expiryDate', Subscription."Valid Until Date")
                .AddProperty('newValidFromDate', SubscriptionRequest."New Valid From Date")
                .AddProperty('newValidUntilDate', SubscriptionRequest."New Valid Until Date")
                .AddProperty('amountInclVat', SubscriptionRequest.Amount)
            .EndObject()
        .EndObject();

        exit(Response.RespondOK(ResponseJson));
    end;

    // ************
    # region Private Methods
    local procedure GetMembershipByNumber(MembershipNumber: Code[20]) Response: Codeunit "NPR API Response"
    var
        Membership: Record "NPR MM Membership";
        ResponseJson: Codeunit "NPR JSON Builder";
    begin
        Membership.SetCurrentKey("External Membership No.");
        Membership.SetFilter("External Membership No.", '=%1', MembershipNumber);
        if (not Membership.FindFirst()) then
            exit(Response.RespondResourceNotFound('Membership not found.'));

        ResponseJson.StartObject()
            .AddObject(StartMembershipDTO(ResponseJson, Membership, false))
        .EndObject();

        exit(Response.RespondOK(ResponseJson.Build()));
    end;

    local procedure GetMembershipByCustomerNumber(CustomerNumber: Code[20]) Response: Codeunit "NPR API Response"
    var
        Membership: Record "NPR MM Membership";
        ResponseJson: Codeunit "NPR JSON Builder";
    begin
        Membership.SetCurrentKey("Customer No.");
        Membership.SetFilter("Customer No.", '=%1', CustomerNumber);
        Membership.SetFilter("Blocked", '=%1', false);
        if (not Membership.FindFirst()) then
            exit(Response.RespondResourceNotFound('Membership not found.'));

        ResponseJson.StartObject()
            .AddObject(StartMembershipDTO(ResponseJson, Membership, false))
        .EndObject();

        exit(Response.RespondOK(ResponseJson.Build()));
    end;

    local procedure StartMembershipDTO(ResponseJson: Codeunit "NPR JSON Builder"; Membership: Record "NPR MM Membership"; IncludeMembers: Boolean): Codeunit "NPR JSON Builder"
    begin
        ResponseJson.StartObject('membership')
            .AddObject(MembershipDTO(ResponseJson, Membership))
            .AddArray(MembershipToMembersDTO(ResponseJson, Membership, IncludeMembers))
        .EndObject();

        exit(ResponseJson);
    end;

    internal procedure MembershipDTO(ResponseJson: Codeunit "NPR JSON Builder"; Membership: Record "NPR MM Membership"): Codeunit "NPR JSON Builder"
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
        AttributeAgent: Codeunit "NPR MembershipAttributesAgent";
        ValidFrom, ValidUntil : Date;
    begin
        MembershipMgt.GetConsecutiveTimeFrame(Membership."Entry No.", Today(), ValidFrom, ValidUntil);

        MembershipSetup.SetLoadFields(Description);
        if (not (MembershipSetup.Get(Membership."Membership Code"))) then
            MembershipSetup.Init();

        ResponseJson
            .AddProperty('membershipId', Format(Membership.SystemId, 0, 4).ToLower())
            .AddProperty('membershipNumber', Membership."External Membership No.")
            .AddProperty('communityCode', Membership."Community Code")
            .AddProperty('membershipCode', Membership."Membership Code")
            .AddProperty('membershipDescription', MembershipSetup.Description)
            .AddProperty('issueDate', Membership."Issued Date")
            .AddProperty('blocked', Membership.Blocked)
            .AddObject(AddRequiredProperty(ResponseJson, 'validFromDate', ValidFrom))
            .AddObject(AddRequiredProperty(ResponseJson, 'validUntilDate', ValidUntil))
            .AddProperty('customerNumber', Membership."Customer No.")
            .AddProperty('autoRenewalActivated', Membership."Auto-Renew" <> Membership."Auto-Renew"::NO)
            .AddArray(AttributeAgent.MembershipAttributesDTO(ResponseJson, Membership."Entry No."));
        exit(ResponseJson);
    end;

    local procedure AddRequiredProperty(var ResponseJson: Codeunit "NPR JSON Builder"; PropertyName: Text; PropertyValue: Date): Codeunit "NPR JSON Builder"
    begin
        if (PropertyValue = 0D) then
            exit(ResponseJson.AddProperty(PropertyName));

        exit(ResponseJson.AddProperty(PropertyName, PropertyValue));
    end;

    local procedure MembershipToMembersDTO(ResponseJson: Codeunit "NPR JSON Builder"; Membership: Record "NPR MM Membership"; IncludeMembers: Boolean): Codeunit "NPR JSON Builder"
    var
        MembershipRole: Record "NPR MM Membership Role";
        Member: Record "NPR MM Member";
        Encode: Codeunit "NPR MembershipApiTranslation";
    begin
        if (not IncludeMembers) then
            exit(ResponseJson);

        ResponseJson.StartArray('members');

        MembershipRole.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        if (MembershipRole.FindSet()) then begin
            repeat
                Member.Get(MembershipRole."Member Entry No.");
                ResponseJson.StartObject()
                    .AddProperty('role', Encode.MemberRoleToText(MembershipRole."Member Role"))
                    .AddProperty('contactNumber', MembershipRole."Contact No.")
                    .AddObject(StartMemberDTO(ResponseJson, Membership."Entry No.", Member, true))
                    .EndObject();
            until (MembershipRole.Next() = 0);

            ResponseJson.EndArray();
            exit(ResponseJson);
        end;
    end;

    local procedure StartMemberDTO(ResponseJson: Codeunit "NPR JSON Builder"; MembershipEntryNo: Integer; Member: Record "NPR MM Member"; IncludeCards: Boolean): Codeunit "NPR JSON Builder"
    var
        MemberAgent: Codeunit "NPR MemberApiAgent";
    begin
        ResponseJson.StartObject('member')
            .AddObject(MemberAgent.MemberDTO(ResponseJson, Member))
            .AddArray(MemberCardsDTO(ResponseJson, MembershipEntryNo, Member."Entry No.", IncludeCards))
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
                    .AddProperty('pinCode', MemberCard."Pin Code")
                    .AddProperty('createdAt', MemberCard.SystemCreatedAt)
                    .AddProperty('modifiedAt', MemberCard.SystemModifiedAt)
                    .EndObject();
            until (MemberCard.Next() = 0);
        end;

        ResponseJson.EndArray();
        exit(ResponseJson);
    end;

    internal procedure GetMembershipById(var Request: Codeunit "NPR API Request"; PathPosition: Integer; var Membership: Record "NPR MM Membership"): Boolean
    var
        MembershipIdText: Text[50];
        MembershipId: Guid;
    begin
        MembershipIdText := CopyStr(Request.Paths().Get(PathPosition), 1, MaxStrLen(MembershipIdText));
        if (MembershipIdText = '') then
            exit(false);

        if (not Evaluate(MembershipId, MembershipIdText)) then
            exit(false);

        if (not Membership.GetBySystemId(MembershipId)) then
            exit(false);

        exit(true);
    end;

    local procedure CreateMembershipWorker(var MemberInfoCapture: Record "NPR MM Member Info Capture"): Boolean
    var
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        Membership: Record "NPR MM Membership";

        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin

        MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, MemberInfoCapture."Item No.");
        MembershipSalesSetup.TestField(Blocked, false);

        if (MemberInfoCapture.Amount = 0) then begin
            Item.Get(MemberInfoCapture."Item No.");
            MemberInfoCapture."Unit Price" := Item."Unit Price";

            VATPostingSetup.SetFilter("VAT Bus. Posting Group", '=%1', Item."VAT Bus. Posting Gr. (Price)");
            VATPostingSetup.SetFilter("VAT Prod. Posting Group", '=%1', Item."VAT Prod. Posting Group");
            if (not VATPostingSetup.FindFirst()) then
                VATPostingSetup.Init();

            if (Item."Price Includes VAT") then begin
                MemberInfoCapture."Amount Incl VAT" := Item."Unit Price";
                MemberInfoCapture.Amount := Round(MemberInfoCapture."Amount Incl VAT" / ((100 + VATPostingSetup."VAT %") / 100.0), 0.01);
            end else begin
                MemberInfoCapture.Amount := Item."Unit Price";
                MemberInfoCapture."Amount Incl VAT" := Round(MemberInfoCapture.Amount * ((100 + VATPostingSetup."VAT %") / 100.0), 0.01);
            end;
        end;

        MemberInfoCapture."Membership Entry No." := MembershipManagement.CreateMembership(MembershipSalesSetup, MemberInfoCapture, true);

        Membership.Get(MemberInfoCapture."Membership Entry No.");
        Membership."Document ID" := MemberInfoCapture."Import Entry Document ID";
        Membership.Modify();

        MemberInfoCapture."External Membership No." := Membership."External Membership No.";
        MemberInfoCapture.Modify();

        /*
        MembershipSetup.Get(Membership."Membership Code");
        case MembershipSetup."Web Service Print Action" of
            MembershipSetup."Web Service Print Action"::DIRECT:
                MemberRetailIntegration.PrintMembershipSalesReceiptWorker(Membership, MembershipSetup);
            MembershipSetup."Web Service Print Action"::OFFLINE:
                MembershipManagement.PrintOffline(MemberInfoCapture."Information Context"::PRINT_MEMBERSHIP, MemberInfoCapture."Membership Entry No.");
        end;
        */

        exit(true);
    end;

# pragma warning disable AA0139
    local procedure CreateDocumentId(): Text[50]
    begin
        exit(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')));
    end;

    local procedure DeserializeCreateMembershipRequest(var Request: Codeunit "NPR API Request"; var MemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        Body: JsonObject;
        JToken: JsonToken;
    begin
        Body := Request.BodyJson().AsObject();

        if (Body.Get('itemNumber', JToken)) then
            MemberInfoCapture."Item No." := JToken.AsValue().AsText();

        if (Body.Get('activationDate', JToken)) then
            if (not JToken.AsValue().IsNull()) then
                MemberInfoCapture."Document Date" := JToken.AsValue().AsDate();

        if (Body.Get('companyName', JToken)) then
            if (not JToken.AsValue().IsNull()) then
                MemberInfoCapture."Company Name" := JToken.AsValue().AsText();

        if (Body.Get('preassignedCustomerNumber', JToken)) then
            if (not JToken.AsValue().IsNull()) then
                MemberInfoCapture."Customer No." := JToken.AsValue().AsText();

        if (Body.Get('documentNo', JToken)) then
            if (not JToken.AsValue().IsNull()) then
                MemberInfoCapture."Document No." := JToken.AsValue().AsText();

        MemberInfoCapture."Import Entry Document ID" := CreateDocumentId();
        MemberInfoCapture.TestField("Item No.");

    end;

    #endregion Private Methods

#pragma warning restore AA0139
}
#endif
