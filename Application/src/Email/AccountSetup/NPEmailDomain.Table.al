#if not (BC17 or BC18 or BC19 or BC20 or BC21)
table 6151108 "NPR NP Email Domain"
{
    Access = Internal;
    Caption = 'NP Email Domain';

    fields
    {
        field(1; Id; Integer)
        {
            Caption = 'Id';
            DataClassification = SystemMetadata;
        }
        field(2; Domain; Text[300])
        {
            Caption = 'Domain';
            DataClassification = SystemMetadata;
        }
        field(3; AccountId; Integer)
        {
            Caption = 'Account Id';
            DataClassification = SystemMetadata;
            TableRelation = "NPR NP Email Account".AccountId;
        }
        field(4; Valid; Boolean)
        {
            Caption = 'Verified';
            DataClassification = SystemMetadata;
        }
    }

    internal procedure FromJson(JToken: JsonToken)
    var
        JHelper: Codeunit "NPR Json Helper";
    begin
        Rec.Id := JHelper.GetJInteger(JToken, 'id', true);
        Rec.AccountId := JHelper.GetJInteger(JToken, 'user_id', true);
#pragma warning disable AA0139
        Rec.Domain := JHelper.GetJText(JToken, 'domain', true);
#pragma warning restore AA0139
        Rec.Valid := JHelper.GetJBoolean(JToken, 'valid', true);
    end;
}
#endif