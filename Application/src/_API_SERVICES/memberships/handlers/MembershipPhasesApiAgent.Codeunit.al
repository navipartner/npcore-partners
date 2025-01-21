#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248225 "NPR MembershipPhasesApiAgent"
{
    Access = Internal;

    internal procedure GetMembershipTimeEntries(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Membership: Record "NPR MM Membership";
        MembershipApiAgent: Codeunit "NPR MembershipApiAgent";
    begin
        if (not MembershipApiAgent.GetMembershipById(Request, 2, Membership)) then
            exit(Response.RespondBadRequest('Invalid Membership - Membership Id not valid.'));

        exit(Response.RespondOK(StartMembershipTimeEntriesDTO(Membership).Build()));
    end;

    internal procedure ActivateMembership(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Membership: Record "NPR MM Membership";
        MembershipApiAgent: Codeunit "NPR MembershipApiAgent";
        MembershipMgr: Codeunit "NPR MM MembershipMgtInternal";
    begin
        if (not MembershipApiAgent.GetMembershipById(Request, 2, Membership)) then
            exit(Response.RespondBadRequest('Invalid Membership - Membership Id not valid.'));

        MembershipMgr.IsMembershipActive(Membership."Entry No.", Today(), true);
        exit(Response.RespondOK(StartMembershipTimeEntriesDTO(Membership).Build()));

    end;

    internal procedure GetRenewalOptions(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
    begin
        exit(GetOptions(MembershipAlterationSetup."Alteration Type"::RENEW, Request));
    end;

    internal procedure GetExtendOptions(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
    begin
        exit(GetOptions(MembershipAlterationSetup."Alteration Type"::EXTEND, Request));
    end;

    internal procedure GetUpgradeOptions(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
    begin
        exit(GetOptions(MembershipAlterationSetup."Alteration Type"::UPGRADE, Request));
    end;

    internal procedure GetCancelOptions(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
    begin
        exit(GetOptions(MembershipAlterationSetup."Alteration Type"::CANCEL, Request));
    end;

    // internal procedure GetRegretOptions(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    // var
    //     MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
    // begin
    //     exit(GetOptions(MembershipAlterationSetup."Alteration Type"::REGRET, Request));
    // end;

    internal procedure RenewMembership(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    begin
        exit(ChangeMembership(Request));
    end;

    internal procedure ExtendMembership(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    begin
        exit(ChangeMembership(Request));
    end;

    internal procedure UpgradeMembership(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    begin
        exit(ChangeMembership(Request));
    end;

    internal procedure CancelMembership(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    begin
        exit(ChangeMembership(Request));
    end;

    internal procedure RegretMembership(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipApiAgent: Codeunit "NPR MembershipApiAgent";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        Body: JsonObject;
        JToken: JsonToken;
        EntryId: Guid;
    begin
        if (not MembershipApiAgent.GetMembershipById(Request, 2, Membership)) then
            exit(Response.RespondBadRequest('Invalid Membership - membershipId not valid.'));

        Body := Request.BodyJson().AsObject();
        if (not Body.Get('entryId', JToken)) then
            exit(Response.RespondBadRequest('Invalid Request - entryId not provided.'));

        Evaluate(EntryId, JToken.AsValue().AsText());
        MembershipEntry.GetBySystemId(EntryId);

        MembershipEntry.Reset();
        MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        if (not MembershipEntry.FindLast()) then
            exit(Response.RespondBadRequest('Invalid Request - no active time that could be regretted was found.'));

        if (EntryId <> MembershipEntry.SystemId) then
            exit(Response.RespondBadRequest('Invalid Request - only the last active time entry can be regretted.'));

        MembershipManagement.DoRegretTimeframe(MembershipEntry);

        exit(Response.RespondOK(StartMembershipTimeEntriesDTO(Membership).Build()));
    end;


    // ************************************************************

    local procedure ChangeMembership(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Membership: Record "NPR MM Membership";
        MembershipApiAgent: Codeunit "NPR MembershipApiAgent";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        OptionId: Guid;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";

        Body: JsonObject;
        JToken: JsonToken;
        MembershipStartDate: Date;
        MembershipUntilDate: Date;
        UnitPrice: Decimal;
    begin
        MemberInfoCapture.Init();
        MemberInfoCapture."Entry No." := 0;

        if (not MembershipApiAgent.GetMembershipById(Request, 2, Membership)) then
            exit(Response.RespondBadRequest('Invalid Membership - Membership Id not valid.'));

#pragma warning disable AA0139
        Body := Request.BodyJson().AsObject();
        if (not Body.Get('optionId', JToken)) then
            exit(Response.RespondBadRequest('Invalid Request - optionId not provided.'));

        Evaluate(OptionId, JToken.AsValue().AsText());
        MembershipAlterationSetup.GetBySystemId(OptionId);

        if (Body.Get('documentNo', JToken)) then
            MemberInfoCapture."Document No." := JToken.AsValue().AsText();

        MemberInfoCapture."Import Entry Document ID" := UpperCase(DelChr(Format(CreateGuid()), '=', '{}-'));
#pragma warning restore AA0139

        MemberInfoCapture."Membership Entry No." := Membership."Entry No.";
        MemberInfoCapture."Item No." := MembershipAlterationSetup."Sales Item No.";
        case MembershipAlterationSetup."Alteration Type" of
            MembershipAlterationSetup."Alteration Type"::REGRET:
                MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::REGRET;
            MembershipAlterationSetup."Alteration Type"::RENEW:
                MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::RENEW;
            MembershipAlterationSetup."Alteration Type"::UPGRADE:
                MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::UPGRADE;
            MembershipAlterationSetup."Alteration Type"::EXTEND:
                MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::EXTEND;
            MembershipAlterationSetup."Alteration Type"::CANCEL:
                MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::CANCEL;
        end;
        // MemberInfoCapture.Insert();

        case MemberInfoCapture."Information Context" of

            MemberInfoCapture."Information Context"::REGRET:
                MembershipManagement.RegretMembership(MemberInfoCapture, true, true, MembershipStartDate, MembershipUntilDate, UnitPrice);

            MemberInfoCapture."Information Context"::RENEW:
                MembershipManagement.RenewMembership(MemberInfoCapture, true, true, MembershipStartDate, MembershipUntilDate, UnitPrice);

            MemberInfoCapture."Information Context"::UPGRADE:
                MembershipManagement.UpgradeMembership(MemberInfoCapture, true, true, MembershipStartDate, MembershipUntilDate, UnitPrice);

            MemberInfoCapture."Information Context"::EXTEND:
                MembershipManagement.ExtendMembership(MemberInfoCapture, true, true, MembershipStartDate, MembershipUntilDate, UnitPrice);

            MemberInfoCapture."Information Context"::CANCEL:
                MembershipManagement.CancelMembership(MemberInfoCapture, true, true, MembershipStartDate, MembershipUntilDate, UnitPrice);

        end;

        //MemberInfoCapture.Delete();

        exit(Response.RespondOK(StartMembershipTimeEntriesDTO(Membership).Build()));
    end;


    local procedure GetOptions(AlterationType: Option; var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Membership: Record "NPR MM Membership";
        MembershipApiAgent: Codeunit "NPR MembershipApiAgent";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        TempMembershipEntry: Record "NPR MM Membership Entry" temporary;
        ResponseJson: Codeunit "NPR Json Builder";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin

        if (not MembershipApiAgent.GetMembershipById(Request, 2, Membership)) then
            exit(Response.RespondBadRequest('Invalid Membership - Membership Id not valid.'));

        MembershipAlterationSetup.SetFilter("From Membership Code", '=%1', Membership."Membership Code");
        MembershipAlterationSetup.SetFilter("Not Available Via Web Service", '=%1', false);
        MembershipAlterationSetup.SetFilter("Alteration Type", '=%1', AlterationType);
        MembershipManagement.GetMembershipChangeOptions(Membership."Entry No.", '', MembershipAlterationSetup, TempMembershipEntry);

        exit(Response.RespondOK(StartOptionsDTO(ResponseJson, Membership, TempMembershipEntry).Build()));
    end;

    local procedure StartMembershipTimeEntriesDTO(Membership: Record "NPR MM Membership"): Codeunit "NPR Json Builder"
    var
        MembershipApiAgent: Codeunit "NPR MembershipApiAgent";
        ResponseJson: Codeunit "NPR Json Builder";
    begin
        ResponseJson.StartObject()
            .StartObject('membership')
            .AddObject(MembershipApiAgent.MembershipDTO(ResponseJson, Membership))
            .AddArray(StartTimeEntriesDTO(ResponseJson, Membership))
            .EndObject()
            .EndObject();
        exit(ResponseJson);
    end;

    local procedure StartOptionsDTO(ResponseJson: Codeunit "NPR Json Builder"; Membership: Record "NPR MM Membership"; var TempMembershipEntry: Record "NPR MM Membership Entry" temporary): Codeunit "NPR Json Builder"
    var
        MembershipApiAgent: Codeunit "NPR MembershipApiAgent";
        TargetMembershipSetup: Record "NPR MM Membership Setup";
        ItemTranslation: Record "Item Translation";
        Translation: Codeunit "NPR MembershipApiTranslation";
    begin
        ResponseJson.StartObject()
            .StartObject('membership')
            .AddObject(MembershipApiAgent.MembershipDTO(ResponseJson, Membership))
            .StartArray('options');

        TempMembershipEntry.Reset();
        if (TempMembershipEntry.FindSet()) then begin
            repeat
                if (not TargetMembershipSetup.Get(TempMembershipEntry."Membership Code")) then
                    TargetMembershipSetup."Membership Member Cardinality" := 1;

                ResponseJson.StartObject()
                    .AddProperty('optionId', Format(TempMembershipEntry.SystemId, 0, 4).ToLower())
                    .AddProperty('itemNumber', TempMembershipEntry."Item No.")
                    .AddProperty('lifecycleAction', Translation.MembershipEntryContextToText(TempMembershipEntry.Context))
                    .AddProperty('description', TempMembershipEntry.Description)
                    .AddProperty('targetMembershipCode', TempMembershipEntry."Membership Code")
                    .AddProperty('periodStart', TempMembershipEntry."Valid From Date")
                    .AddProperty('periodEnd', TempMembershipEntry."Valid Until Date")
                    .AddProperty('unitPrice', TempMembershipEntry."Unit Price")
                    .AddProperty('amount', TempMembershipEntry."Amount Incl VAT")
                    .AddProperty('amountInclVat', TempMembershipEntry."Amount Incl VAT")
                    .AddProperty('memberCardinality', TargetMembershipSetup."Membership Member Cardinality")
                    .AddProperty('presentationOrder', TempMembershipEntry."Line No.")
                    .StartArray('translations');

                ItemTranslation.SetFilter("Item No.", '=%1', TempMembershipEntry."Item No.");
                if (ItemTranslation.FindSet()) then
                    repeat
                        ResponseJson.StartObject()
                            .AddProperty('languageCode', ItemTranslation."Language Code")
                            .AddProperty('description', ItemTranslation.Description)
                            .EndObject();
                    until (ItemTranslation.Next() = 0);

                ResponseJson.EndArray().EndObject();

            until (TempMembershipEntry.Next() = 0)
        end;

        ResponseJson.EndArray().EndObject();
        exit(ResponseJson);
    end;

    local procedure StartTimeEntriesDTO(ResponseJson: Codeunit "NPR Json Builder"; Membership: Record "NPR MM Membership"): Codeunit "NPR Json Builder"
    var
        MembershipEntry: Record "NPR MM Membership Entry";
        Translation: Codeunit "NPR MembershipApiTranslation";
    begin
        MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        if (MembershipEntry.FindSet()) then begin
            ResponseJson.StartArray('entries');
            repeat
                if (MembershipEntry."Document No." = '') then
                    MembershipEntry."Document No." := MembershipEntry."Receipt No.";

                ResponseJson.StartObject()
                    .AddProperty('entryId', Format(MembershipEntry.SystemId, 0, 4).ToLower())
                    .AddProperty('itemNumber', MembershipEntry."Item No.")
                    .AddProperty('lifecycleAction', Translation.MembershipEntryContextToText(MembershipEntry.Context))
                    .AddProperty('blocked', MembershipEntry."Blocked")
                    .AddProperty('membershipCode', MembershipEntry."Membership Code")
                    .AddProperty('description', MembershipEntry.Description)
                    .AddProperty('validFromDate', MembershipEntry."Valid From Date")
                    .AddProperty('validUntilDate', MembershipEntry."Valid Until Date")
                    .AddProperty('createdAt', MembershipEntry."Created At")

                    .AddProperty('documentNumber', MembershipEntry."Document No.")
                    .AddProperty('documentId', MembershipEntry."Import Entry Document ID")
                    .AddProperty('unitPrice', MembershipEntry."Unit Price")
                    .AddProperty('amount', MembershipEntry."Amount")
                    .AddProperty('amountInclVat', MembershipEntry."Amount Incl VAT")
                    .AddProperty('activateOnFirstUse', MembershipEntry."Activate On First Use")

                    .EndObject();
            until (MembershipEntry.Next() = 0);
            ResponseJson.EndArray();
        end;

    end;

}
#endif