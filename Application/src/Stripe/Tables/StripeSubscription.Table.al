table 6014650 "NPR Stripe Subscription"
{
    Access = Internal;
    Caption = 'Stripe Subscription';

    fields
    {
        field(1; Id; Text[50])
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
        }
        field(2; Created; BigInteger)
        {
            Caption = 'Created';
            DataClassification = CustomerContent;
        }
        field(3; "Current Period Start"; BigInteger)
        {
            Caption = 'Current Period Start';
            DataClassification = CustomerContent;
        }
        field(4; "Current Period End"; BigInteger)
        {
            Caption = 'Current Period End';
            DataClassification = CustomerContent;
        }
        field(5; "Subscription Item Id"; Text[50])
        {
            Caption = 'Subscription Item Id';
            DataClassification = CustomerContent;
        }
        field(6; "Ended At"; BigInteger)
        {
            Caption = 'Ended At';
            DataClassification = CustomerContent;
        }
        field(7; "Plan Id"; Text[50])
        {
            Caption = 'Plan Id';
            DataClassification = CustomerContent;
        }
        field(8; Quantity; Integer)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(9; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionCaption = 'Trialing,Active,Past Due,Canceled,Unpaid';
            OptionMembers = trialing,active,past_due,canceled,unpaid;
        }
        field(10; "Trial Start"; Integer)
        {
            Caption = 'Trial Start';
            DataClassification = CustomerContent;
        }
        field(11; "Trial End"; Integer)
        {
            Caption = 'Trial End';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
        key(Key2; SystemCreatedAt)
        {

        }
    }

    internal procedure RefreshSubscription(): Boolean
    var
        StripeWebService: Codeunit "NPR Stripe Web Service";
    begin
        exit(StripeWebService.RefreshSubscription(Rec));
    end;

    internal procedure CreateSubscription(StripeCustomer: Record "NPR Stripe Customer"; StripePlan: Record "NPR Stripe Plan"; Trial: Boolean): Boolean
    var
        StripeWebService: Codeunit "NPR Stripe Web Service";
    begin
        exit(StripeWebService.CreateSubscription(StripeCustomer, StripePlan, Rec, Trial));
    end;

    internal procedure CreateTrialSubscription(): Boolean
    var
        StripeCreateTrialSubs: Codeunit "NPR Stripe Create Trial Subs.";
    begin
        exit(StripeCreateTrialSubs.CreateTrialSubscription(Rec));
    end;

    internal procedure UpdateSubscription(StripeCustomer: Record "NPR Stripe Customer"; StripePlan: Record "NPR Stripe Plan"): Boolean
    var
        StripeWebService: Codeunit "NPR Stripe Web Service";
    begin
        exit(StripeWebService.UpdateSubscription(StripeCustomer, StripePlan, Rec));
    end;

    internal procedure UpdateSubscriptionUsage(Quantity: Integer): Boolean
    var
        StripeWebService: Codeunit "NPR Stripe Web Service";
    begin
        exit(StripeWebService.UpdateSubscriptionUsage(Rec, Quantity));
    end;

    internal procedure UpdateLastSubscriptionPeriodStartOnStripeSetup()
    var
        StripeSetup: Record "NPR Stripe Setup";
    begin
        StripeSetup.GetSetup();
        if SetLastSubscriptionPeriodStartOnStripeSetup(StripeSetup) then
            StripeSetup.Modify();
    end;

    internal procedure SetLastSubscriptionPeriodStartOnStripeSetup(var StripeSetup: Record "NPR Stripe Setup"): Boolean
    var
        CurrentPeriodStartDateTime: DateTime;
    begin
        CurrentPeriodStartDateTime := GetCurrentPeriodStartDateTime();
        if StripeSetup."Last Subscription Period Start" <> CurrentPeriodStartDateTime then begin
            StripeSetup."Last Subscription Period Start" := CurrentPeriodStartDateTime;
            exit(true);
        end;
    end;

    internal procedure GetFormDataForCreateTrialSubscription(StripeCustomer: Record "NPR Stripe Customer"; StripePlan: Record "NPR Stripe Plan") Data: Text
    begin
        Data := 'items[0][plan]=' + StripePlan.Id +
                '&customer=' + StripeCustomer.Id +
                '&trial_period_days=' + Format(StripePlan."Trial Period Days");
    end;

    internal procedure GetFormDataForCreateSubscription(StripeCustomer: Record "NPR Stripe Customer"; StripePlan: Record "NPR Stripe Plan") Data: Text
    begin
        Data := 'items[0][plan]=' + StripePlan.Id +
                '&customer=' + StripeCustomer.Id;

        if StripeCustomer.VATRegistrationNoMandatory() then
            Data += '&default_tax_rates[0]=' + GetTaxRateId();
    end;

    internal procedure GetFormDataForUpdateSubscription(StripeCustomer: Record "NPR Stripe Customer"; StripePlan: Record "NPR Stripe Plan") Data: Text
    begin
        if "Plan Id" <> '' then
            Data :=
                'items[0][id]=' + "Subscription Item Id" +
                '&items[0][clear_usage]=true' +
                '&items[0][deleted]=true' +
                '&items[1][plan]=' + StripePlan.Id +
                '&trial_end=now'
        else
            Data := 'items[0][plan]=' + StripePlan.Id;

        if StripeCustomer.VATRegistrationNoMandatory() then
            Data += '&default_tax_rates[0]=' + GetTaxRateId();
    end;

    local procedure GetTaxRateId(): Text[50]
    var
        StripeTaxRate: Record "NPR Stripe Tax Rate";
    begin
        StripeTaxRate.SetCurrentKey("Country/Region Code", Active);
        StripeTaxRate.SetRange("Country/Region Code", 'DK');
        StripeTaxRate.SetRange(Active, true);
        StripeTaxRate.FindFirst();
        exit(StripeTaxRate.Id)
    end;

    internal procedure GetFormDataForUpdateSubscriptionUsage(Quantity: Integer; Timestamp: BigInteger) Data: Text
    begin
        Data := 'quantity=' + Format(Quantity) +
                '&timestamp=' + Format(Timestamp);
    end;

    internal procedure PopulateFromJson(Data: JsonObject)
    var
        StripeJSONHelper: Codeunit "NPR Stripe JSON Helper";
    begin
        StripeJSONHelper.SetJsonObject(Data);
        Id := CopyStr(StripeJSONHelper.GetJsonValue('id').AsText(), 1, MaxStrLen(Id));
        Created := StripeJSONHelper.GetJsonValue('created').AsBigInteger();
        "Current Period Start" := StripeJSONHelper.GetJsonValue('current_period_start').AsBigInteger();
        if not StripeJSONHelper.IsNullValue('current_period_end') then
            "Current Period End" := StripeJSONHelper.GetJsonValue('current_period_end').AsBigInteger();
        if not StripeJSONHelper.IsNullValue('ended_at') then
            "Ended At" := StripeJSONHelper.GetJsonValue('ended_at').AsInteger();

        Evaluate(Status, StripeJSONHelper.GetJsonValue('status').AsText());

        if not StripeJSONHelper.IsNullValue('trial_start') then
            "Trial Start" := StripeJSONHelper.GetJsonValue('trial_start').AsBigInteger();
        if not StripeJSONHelper.IsNullValue('trial_end') then
            "Trial End" := StripeJSONHelper.GetJsonValue('trial_end').AsBigInteger();

        Quantity := StripeJSONHelper.GetJsonValue('quantity').AsInteger();
        "Subscription Item Id" := CopyStr(StripeJSONHelper.SelectJsonValue('$.items.data[0].id').AsText(), 1, MaxStrLen("Subscription Item Id"));
        "Plan Id" := CopyStr(StripeJSONHelper.SelectJsonValue('$.plan.id').AsText(), 1, MaxStrLen("Plan Id"));
    end;

    internal procedure TrialDaysLeft() ReturnValue: Integer
    var
        TypeHelper: Codeunit "Type Helper";
        TrialEndDate: Date;
    begin
        TrialEndDate := DT2Date(TypeHelper.EvaluateUnixTimestamp("Trial End"));
        ReturnValue := TrialEndDate - Today();
    end;

    internal procedure CurrentPeriodDaysLeft() ReturnValue: Integer
    var
        TypeHelper: Codeunit "Type Helper";
        PeriodEndDate: Date;
    begin
        PeriodEndDate := DT2Date(TypeHelper.EvaluateUnixTimestamp("Current Period End"));
        ReturnValue := PeriodEndDate - Today();
    end;

    internal procedure PastDueDays() ReturnValue: Integer
    begin
        if CurrentPeriodDaysLeft() < 0 then
            ReturnValue := Abs(CurrentPeriodDaysLeft());
    end;

    internal procedure GetCurrentPeriodStartDateTime(): DateTime
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(TypeHelper.EvaluateUnixTimestamp("Current Period Start"));
    end;

    internal procedure GetCurrentPeriodEndDateTime(): DateTime
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(TypeHelper.EvaluateUnixTimestamp("Current Period End"));
    end;
}