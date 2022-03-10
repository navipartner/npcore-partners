table 6014658 "NPR Stripe Tax Rate"
{
    Access = Internal;
    Caption = 'Stripe Tax Rate';

    fields
    {
        field(1; Id; Text[50])
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
        }
        field(3; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
        }
        field(4; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
        }
        field(6; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
        key(Key2; "Country/Region Code", Active)
        {

        }
    }

    internal procedure GetTaxRates(): Boolean
    var
        StripeWebService: Codeunit "NPR Stripe Web Service";
    begin
        exit(StripeWebService.GetTaxRates(Rec));
    end;

    internal procedure PopulateFromJson(Data: JsonObject)
    var
        StripeJSONHelper: Codeunit "NPR Stripe JSON Helper";
    begin
        StripeJSONHelper.SetJsonObject(Data);
        Id := CopyStr(StripeJSONHelper.GetJsonValue('id').AsText(), 1, MaxStrLen(Id));
        Active := StripeJSONHelper.GetJsonValue('active').AsBoolean();
        "Country/Region Code" := CopyStr(StripeJSONHelper.GetJsonValue('country').AsText(), 1, MaxStrLen("Country/Region Code"));
        Description := CopyStr(StripeJSONHelper.GetJsonValue('description').AsText(), 1, MaxStrLen(Description));
    end;

    internal procedure ToJSON(): Text
    var
        JsonTextReaderWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextReaderWriter.WriteStartObject('');
        JsonTextReaderWriter.WriteStringProperty('id', Id);
        JsonTextReaderWriter.WriteStringProperty('active', Active);
        JsonTextReaderWriter.WriteStringProperty('country', "Country/Region Code");
        JsonTextReaderWriter.WriteStringProperty('description', Description);
        JsonTextReaderWriter.WriteEndObject();
        exit(JsonTextReaderWriter.GetJSonAsText());
    end;
}