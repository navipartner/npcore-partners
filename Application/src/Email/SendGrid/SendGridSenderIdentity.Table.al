#if not (BC17 or BC18 or BC19 or BC20 or BC21)
table 6151042 "NPR SendGrid Sender Identity"
{
    Access = Internal;
    Caption = 'SendGrid Sender Identity';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Id; Integer)
        {
            Caption = 'Id';
            DataClassification = SystemMetadata;
        }
        field(14; NPEmailAccountId; Integer)
        {
            Caption = 'NP Email Account Id';
            DataClassification = SystemMetadata;
            TableRelation = "NPR NP Email Account".AccountId;
        }
        field(2; Nickname; Text[250])
        {
            Caption = 'Nickname';
        }
        field(3; FromName; Text[250])
        {
            Caption = 'From Name';
        }
        field(4; FromEmailAddress; Text[250])
        {
            Caption = 'From E-mail Address';
        }
        field(5; ReplyToName; Text[250])
        {
            Caption = 'From Reply-to Name';
        }
        field(6; ReplyToEmailAddress; Text[250])
        {
            Caption = 'Reply-to E-mail Address';
        }
        field(7; Address; Text[100])
        {
            Caption = 'Address';
        }
        field(8; Address2; Text[100])
        {
            Caption = 'Address 2';
        }
        field(9; City; Text[100])
        {
            Caption = 'City';
        }
        field(10; State; Text[100])
        {
            Caption = 'State';
        }
        field(11; Zip; Text[100])
        {
            Caption = 'Zip';
        }
        field(12; Country; Text[100])
        {
            Caption = 'Country';
        }
        field(13; Verified; Boolean)
        {
            Caption = 'Verified';
            DataClassification = SystemMetadata;
        }
    }

    internal procedure FromJson(pNPEmailAccountId: Integer; Json: JsonToken)
    var
        JsonHelper: Codeunit "NPR Json Helper";
    begin
        Rec.Id := JsonHelper.GetJInteger(Json, 'id', true);
        Rec.NPEmailAccountId := pNPEmailAccountId;
        Rec.Nickname := CopyStr(JsonHelper.GetJText(Json, 'nickname', true), 1, MaxStrLen(Rec.Nickname));
        Rec.FromName := CopyStr(JsonHelper.GetJText(Json, 'from.name', false), 1, MaxStrLen(Rec.FromName));
#pragma warning disable AA0139
        Rec.FromEmailAddress := JsonHelper.GetJText(Json, 'from.email', false);
#pragma warning restore AA0139
        Rec.ReplyToName := CopyStr(JsonHelper.GetJText(Json, 'reply_to.name', false), 1, MaxStrLen(Rec.ReplyToName));
#pragma warning disable AA0139
        Rec.ReplyToEmailAddress := JsonHelper.GetJText(Json, 'reply_to.email', false);
#pragma warning restore AA0139
        Rec.Address := CopyStr(JsonHelper.GetJText(Json, 'address', true), 1, MaxStrLen(Rec.Address));
        Rec.Address2 := CopyStr(JsonHelper.GetJText(Json, 'address_2', false), 1, MaxStrLen(Rec.Address2));
        Rec.City := CopyStr(JsonHelper.GetJText(Json, 'city', true), 1, MaxStrLen(Rec.City));
        Rec.Country := CopyStr(JsonHelper.GetJText(Json, 'country', false), 1, MaxStrLen(Rec.Country));
        Rec.Zip := CopyStr(JsonHelper.GetJText(Json, 'zip', false), 1, MaxStrLen(Rec.Zip));
        Rec.Verified := JsonHelper.GetJBoolean(Json, 'verified.status', true);
    end;

    internal procedure AddFromJson(pNPEmailAccountId: Integer; Json: JsonToken)
    begin
        Rec.Init();
        Rec.FromJson(pNPEmailAccountId, Json);
        Rec.Insert();
    end;

    internal procedure ToRequestJson(): JsonObject
    var
        Json: Codeunit "NPR Json Builder";
    begin
        Rec.TestField(Nickname);
        Rec.TestField(Address);
        Rec.TestField(City);
        Rec.TestField(Country);

        Json.StartObject()
                .AddProperty('nickname', Rec.Nickname)
                .AddProperty('address', Rec.Address)
                .AddProperty('city', Rec.City)
                .AddProperty('country', Rec.Country);

        if (Rec.FromName <> '') or (Rec.FromEmailAddress <> '') then begin
            Json.StartObject('from');
            if (Rec.FromName <> '') then
                Json.AddProperty('name', Rec.FromName);
            if (Rec.FromEmailAddress <> '') then
                Json.AddProperty('email', Rec.FromEmailAddress);
            Json.EndObject();
        end;

        if (Rec.ReplyToName <> '') or (Rec.ReplyToEmailAddress <> '') then begin
            Json.StartObject('reply_to');
            if (Rec.ReplyToName <> '') then
                Json.AddProperty('name', Rec.ReplyToName);
            if (Rec.ReplyToEmailAddress <> '') then
                Json.AddProperty('email', Rec.ReplyToEmailAddress);
            Json.EndObject();
        end;

        if (Rec.Address2 <> '') then
            Json.AddProperty('address_2', Rec.Address2);
        if (Rec."State" <> '') then
            Json.AddProperty('state', Rec."State");
        if (Rec."Zip" <> '') then
            Json.AddProperty('zip', Rec."Zip");

        Json.EndObject();
        exit(Json.Build());
    end;

    internal procedure UpdateFromIdentities(var TempSenderIdentities: Record "NPR SendGrid Sender Identity" temporary)
    var
        AlreadyExists: Boolean;
    begin
        if (TempSenderIdentities.FindSet()) then
            repeat
                AlreadyExists := Rec.Get(TempSenderIdentities.Id);
                Rec := TempSenderIdentities;

                if (AlreadyExists) then
                    Rec.Modify()
                else
                    Rec.Insert();
            until TempSenderIdentities.Next() = 0;

        Rec.Reset();
        if (Rec.FindSet(true)) then
            repeat
                if (not TempSenderIdentities.Get(Rec.Id)) then
                    Rec.Delete();
            until Rec.Next() = 0;
    end;
}
#endif