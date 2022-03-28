table 6014646 "NPR Stripe Plan Tier"
{
    Access = Internal;
    Caption = 'Stripe Plan Tier';

    fields
    {
        field(1; "Plan Id"; Text[50])
        {
            Caption = 'Plan Id';
            DataClassification = CustomerContent;
        }
        field(2; "Tier No."; Integer)
        {
            Caption = 'Tier No.';
            DataClassification = CustomerContent;
        }
        field(3; "Up To"; Integer)
        {
            Caption = 'Up To';
            DataClassification = CustomerContent;
        }
        field(4; Amount; Integer)
        {
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
        }
        field(5; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Plan Id", "Tier No.")
        {
            Clustered = true;
        }
    }

    internal procedure PopulateFromJson(Data: JsonObject)
    var
        StripeJSONHelper: Codeunit "NPR Stripe JSON Helper";
        UnitAmount, UpTo : JsonValue;
    begin
        StripeJSONHelper.SetJsonObject(Data);
        UnitAmount := StripeJSONHelper.SelectJsonValue('unit_amount');
        if not UnitAmount.IsNull() then
            Amount := UnitAmount.AsDecimal();
        UpTo := StripeJSONHelper.GetJsonValue('up_to');
        if not UpTo.IsNull() then
            "Up To" := UpTo.AsInteger();
    end;
}