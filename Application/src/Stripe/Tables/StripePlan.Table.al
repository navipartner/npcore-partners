table 6014645 "NPR Stripe Plan"
{
    Access = Internal;
    Caption = 'Stripe Plan';

    fields
    {
        field(1; Id; Text[50])
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
        }
        field(2; "Product Id"; Text[50])
        {
            Caption = 'Product Id';
            DataClassification = CustomerContent;
        }
        field(3; Amount; Integer)
        {
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
        }
        field(4; "Currency Code"; Code[3])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
        }
        field(5; Interval; Option)
        {
            Caption = 'Interval';
            DataClassification = CustomerContent;
            OptionCaption = 'day,week,month,year';
            OptionMembers = day,week,month,year;
        }
        field(6; "Interval Count"; Integer)
        {
            Caption = 'Interval count';
            DataClassification = CustomerContent;
        }
        field(7; "Trial Period Days"; Integer)
        {
            Caption = 'Trial Period (Days)';
            DataClassification = CustomerContent;
        }
        field(8; Select; Boolean)
        {
            Caption = 'Select';
            DataClassification = CustomerContent;
        }
        field(9; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
        }
        field(20; "Product Name"; Text[50])
        {
            CalcFormula = lookup("NPR Stripe Product".Name where(Id = field("Product Id")));
            Caption = 'Product Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(21; "Unit Name"; Text[50])
        {
            CalcFormula = lookup("NPR Stripe Product"."Unit Name" where(Id = field("Product Id")));
            Caption = 'Unit Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
        key(key2; Select)
        {

        }
        key(key3; "Trial Period Days")
        {

        }
    }

    internal procedure GetPlans(): Boolean
    var
        StripeWebService: Codeunit "NPR Stripe Web Service";
    begin
        exit(StripeWebService.GetPlans(Rec));
    end;

    internal procedure PopulateFromJson(Data: JsonObject): Boolean
    var
        StripeProduct: Record "NPR Stripe Product";
        StripeJSONHelper: Codeunit "NPR Stripe JSON Helper";
        TrialPeriondDays: JsonValue;
    begin
        StripeJSONHelper.SetJsonObject(Data);
        Id := CopyStr(StripeJSONHelper.GetJsonValue('id').AsText(), 1, MaxStrLen(Id));
        Active := StripeJSONHelper.GetJsonValue('active').AsBoolean();
        "Product Id" := CopyStr(StripeJSONHelper.GetJsonValue('product').AsText(), 1, MaxStrLen("Product Id"));
        Amount := StripeJSONHelper.SelectJsonValue('tiers[0].unit_amount').AsDecimal();
        "Currency Code" := CopyStr(StripeJSONHelper.GetJsonValue('currency').AsCode(), 1, MaxStrLen("Currency Code"));
        Evaluate(Interval, StripeJSONHelper.GetJsonValue('interval').AsText());
        "Interval Count" := StripeJSONHelper.GetJsonValue('interval_count').AsInteger();

        TrialPeriondDays := StripeJSONHelper.GetJsonValue('trial_period_days');
        if not TrialPeriondDays.IsNull() then
            "Trial Period Days" := TrialPeriondDays.AsInteger();

        exit(StripeProduct.Get("Product Id"));
    end;

    internal procedure ToJSON(): Text
    var
        JsonTextReaderWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextReaderWriter.WriteStartObject('');
        JsonTextReaderWriter.WriteStringProperty('id', Id);
        JsonTextReaderWriter.WriteStringProperty('active', Active);
        JsonTextReaderWriter.WriteStringProperty('product', "Product Id");
        JsonTextReaderWriter.WriteStringProperty('currency', "Currency Code");
        JsonTextReaderWriter.WriteStringProperty('interval', Interval);
        JsonTextReaderWriter.WriteNumberProperty('interval_count', "Interval Count");
        JsonTextReaderWriter.WriteEndObject();
        exit(JsonTextReaderWriter.GetJSonAsText());
    end;
}