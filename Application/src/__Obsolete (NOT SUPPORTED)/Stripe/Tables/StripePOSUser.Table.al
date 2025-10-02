table 6014549 "NPR Stripe POS User"
{
    Access = Internal;
    Caption = 'POS User';
    DrillDownPageId = "NPR Stripe POS Users";
    LookupPageId = "NPR Stripe POS Users";
    ObsoleteState = Pending;
    ObsoleteTag = '2025-09-03';
    ObsoleteReason = 'Not used. Using POS Billing API integration to control licenses.';

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            NotBlank = true;
            TableRelation = "User Setup";

        }
    }

    keys
    {
        key(PK; "User ID")
        {
            Clustered = true;
        }
    }
}