table 6014647 "NPR Stripe Product"
{
    Access = Internal;
    Caption = 'Stripe Product';

    fields
    {
        field(1; Id; Text[50])
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
        }
        field(2; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(3; "Unit Name"; Text[50])
        {
            Caption = 'Unit Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }

    internal procedure GetProducts(): Boolean
    var
        StripeWebService: Codeunit "NPR Stripe Web Service";
    begin
        exit(StripeWebService.GetProducts(Rec));
    end;

    internal procedure PopulateFromJson(Data: JsonObject): Boolean
    var
        StripeJSONHelper: Codeunit "NPR Stripe JSON Helper";
    begin
        StripeJSONHelper.SetJsonObject(Data);
        Id := CopyStr(StripeJSONHelper.GetJsonValue('id').AsText(), 1, MaxStrLen(Id));
        Name := CopyStr(StripeJSONHelper.GetJsonValue('name').AsText(), 1, MaxStrLen(Name));
        "Unit Name" := CopyStr(StripeJSONHelper.GetJsonValue('unit_label').AsText(), 1, MaxStrLen("Unit Name"));

        exit('POS' = UpperCase(StripeJSONHelper.SelectJsonValue('$.metadata.app').AsText()));
    end;

    internal procedure ToJSON(): Text
    var
        JsonTextReaderWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextReaderWriter.WriteStartObject('');
        JsonTextReaderWriter.WriteStringProperty('id', Id);
        JsonTextReaderWriter.WriteStringProperty('name', Name);
        JsonTextReaderWriter.WriteStringProperty('unit_label', "Unit Name");
        JsonTextReaderWriter.WriteEndObject();
        exit(JsonTextReaderWriter.GetJSonAsText());
    end;
}