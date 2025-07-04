#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248487 "NPR MembershipListAgent" implements "NPR MembershipApiAddProperties"
{

    Access = Internal;

    procedure AddProperties(var Json: Codeunit "NPR JSON Builder"; var RecRef: RecordRef): Codeunit "NPR JSON Builder"
    var
        MembershipAgent: Codeunit "NPR MembershipApiAgent";
        Membership: Record "NPR MM Membership";
        EntryNo: Integer;
    begin
        if (not (Database::"NPR MM Membership" = RecRef.Number())) then
            Error('Unsupported record type %1', RecRef.Number);

        EntryNo := RecRef.Field(Membership.FieldNo("Entry No.")).Value();
        Membership.ReadIsolation := IsolationLevel::ReadCommitted;
        Membership.Get(EntryNo);
        exit(MembershipAgent.MembershipDTO(Json, Membership));
    end;

    procedure ListMemberships(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Membership: Record "NPR MM Membership";
        IssuedDate, IssuedFromDate, IssuedUntilDate : Date;
    begin

        if (Request.QueryParams().ContainsKey('communityCode')) then
            Membership.SetFilter("Community Code", '=%1', Request.QueryParams().Get('communityCode'));

        if (Request.QueryParams().ContainsKey('membershipCode')) then
            Membership.SetFilter("Membership Code", '=%1', Request.QueryParams().Get('membershipCode'));

        if (Request.QueryParams().ContainsKey('issueDate')) then
            if (Evaluate(IssuedDate, Request.QueryParams().Get('issueDate'))) then
                Membership.SetFilter("Issued Date", '=%1', IssuedDate);

        if (Request.QueryParams().ContainsKey('issuedFromDate')) then
            if (Evaluate(IssuedFromDate, Request.QueryParams().Get('issuedFromDate'))) then
                Membership.SetFilter("Issued Date", '>= %1', IssuedFromDate);

        if (Request.QueryParams().ContainsKey('issuedUntilDate')) then
            if (Evaluate(IssuedUntilDate, Request.QueryParams().Get('issuedUntilDate'))) then
                Membership.SetFilter("Issued Date", '<= %1', IssuedUntilDate);

        if (Request.QueryParams().ContainsKey('blocked')) then
            Membership.SetFilter("Blocked", '=%1', Request.QueryParams().Get('blocked').ToLower().StartsWith('true') or Request.QueryParams().Get('blocked').StartsWith('1'));

        if (Request.QueryParams().ContainsKey('customerNumber')) then
            Membership.SetFilter("Customer No.", '=%1', Request.QueryParams().Get('customerNumber'));

        exit(Response.RespondOK(GetData(Request, Membership, this)));
    end;

    procedure GetData(Request: Codeunit "NPR API Request"; Record: Variant; PropertyHandler: Interface "NPR MembershipApiAddProperties"): JsonObject
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Record);
        exit(GetRecords(Request, RecRef, PropertyHandler));
    end;

    local procedure GetRecords(Request: Codeunit "NPR API Request"; var RecRef: RecordRef; PropertyHandler: Interface "NPR MembershipApiAddProperties"): JsonObject
    var
        JsonArray: Codeunit "NPR JSON Builder";
        Limit: Integer;
        i: Integer;
        MoreRecords: Boolean;
        PageKey: Text;
        JsonObject: JsonObject;
        PageContinuation: Boolean;
        DataFound: Boolean;
    begin
        Limit := 100;
        if (Request.QueryParams().ContainsKey('pageSize')) then
            Evaluate(Limit, Request.QueryParams().Get('pageSize'));

        if (Limit < 1) or (Limit > 1000) then
            Limit := 1000;

        if (Request.QueryParams().ContainsKey('pageKey')) then begin
            Request.ApplyPageKey(Request.QueryParams().Get('pageKey'), RecRef);
            PageContinuation := true;
        end;

        JsonArray.StartArray('data');
        RecRef.ReadIsolation := IsolationLevel::ReadCommitted;

        if (PageContinuation) then begin
            DataFound := RecRef.Find('>');
        end else begin
            DataFound := RecRef.Find('-');
        end;

        if (DataFound) then begin
            repeat
                JsonArray.StartObject();
                PropertyHandler.AddProperties(JsonArray, RecRef);
                JsonArray.EndObject();

                i += 1;
                if (i = Limit) then begin
                    //Prepare next pageKey
                    PageKey := Request.GetPageKey(RecRef);
                end;
                MoreRecords := RecRef.Next() <> 0;
            until (not MoreRecords) or (i = Limit);
        end;
        JsonArray.EndArray();

        if (not MoreRecords) then
            PageKey := '';

        JsonObject.Add('morePages', MoreRecords);
        JsonObject.Add('nextPageKey', PageKey);
        JsonObject.Add('nextPageURL', Request.GetNextPageUrl(PageKey));
        JsonObject.Add('data', JsonArray.BuildAsArray());

        exit(JsonObject);
    end;
}
#endif