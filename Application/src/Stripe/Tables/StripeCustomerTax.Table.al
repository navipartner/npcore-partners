table 6014639 "NPR Stripe Customer Tax"
{
    Access = Internal;
    Caption = 'Stripe Customer Tax';

    fields
    {
        field(1; Id; Text[50])
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
        }
        field(5; "Customer Id"; Text[50])
        {
            Caption = 'Customer Id';
            DataClassification = CustomerContent;
        }
        field(6; Type; Text[20])
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(7; Value; Text[20])
        {
            Caption = 'Value';
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

    internal procedure CreateCustomerTax(StripeCustomer: Record "NPR Stripe Customer"): Boolean
    var
        StripeWebService: Codeunit "NPR Stripe Web Service";
    begin
        exit(StripeWebService.CreateCustomerTax(StripeCustomer, Rec));
    end;

    internal procedure GetFormDataForCreateCustomerTax(StripeCustomer: Record "NPR Stripe Customer") Data: Text
    begin
        Data := 'type=' + GetEUVATType() +
                '&value=' + StripeCustomer."VAT Registration No.";
    end;

    internal procedure GetEUVATType(): Text
    var
        EUVATLbl: Label 'eu_vat';
    begin
        exit(EUVATLbl);
    end;

    internal procedure PopulateFromJson(Data: JsonObject)
    var
        StripeJSONHelper: Codeunit "NPR Stripe JSON Helper";
    begin
        StripeJSONHelper.SetJsonObject(Data);
        Id := CopyStr(StripeJSONHelper.GetJsonValue('id').AsText(), 1, MaxStrLen(Id));
        "Customer Id" := CopyStr(StripeJSONHelper.GetJsonValue('customer').AsText(), 1, MaxStrLen("Customer Id"));
        Type := CopyStr(StripeJSONHelper.GetJsonValue('type').AsText(), 1, MaxStrLen(Type));
        Value := CopyStr(StripeJSONHelper.GetJsonValue('value').AsText(), 1, MaxStrLen(Value));
    end;

    internal procedure ToJSON(): Text
    var
        JsonTextReaderWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextReaderWriter.WriteStartObject('');
        JsonTextReaderWriter.WriteStringProperty('id', Id);
        JsonTextReaderWriter.WriteStringProperty('customer', "Customer Id");
        JsonTextReaderWriter.WriteStringProperty('type', Type);
        JsonTextReaderWriter.WriteStringProperty('value', Value);
        JsonTextReaderWriter.WriteEndObject();
        exit(JsonTextReaderWriter.GetJSonAsText());
    end;

}