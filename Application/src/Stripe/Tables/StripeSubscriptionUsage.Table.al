table 6014651 "NPR Stripe Subscription Usage"
{
    Access = Internal;
    Caption = 'Stripe Subscription Usage';

    fields
    {
        field(1; "Subscription Id"; Text[50])
        {
            Caption = 'Subscription Id';
            DataClassification = CustomerContent;
        }
        field(2; "POS User ID"; Code[50])
        {
            Caption = 'CS User Name';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "NPR Stripe POS User";
        }
        field(3; "Current Period Start"; BigInteger)
        {
            Caption = 'Current Period Start';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Subscription Id", "POS User ID", "Current Period Start")
        {
            Clustered = true;
        }
    }

    internal procedure CopyFromSubscription(StripeSubscription: Record "NPR Stripe Subscription")
    begin
        "Subscription Id" := StripeSubscription.Id;
        "Current Period Start" := StripeSubscription."Current Period Start";
    end;
}