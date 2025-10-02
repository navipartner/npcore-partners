table 6014649 "NPR Stripe Setup"
{
    Access = Internal;
    Caption = 'Stripe Setup';
    ObsoleteState = Pending;
    ObsoleteTag = '2025-09-03';
    ObsoleteReason = 'Not used. Using POS Billing API integration to control licenses.';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Last Synchronized"; DateTime)
        {
            Caption = 'Last Synchronized';
            DataClassification = CustomerContent;
        }
        field(3; "Last Subscription Period Start"; DateTime)
        {
            Caption = 'Last Subscription Period Start';
            DataClassification = CustomerContent;
        }
        field(4; Disabled; Boolean)
        {
            Caption = 'Disabled';
            DataClassification = OrganizationIdentifiableInformation;
        }
        field(5; "Last Updated"; DateTime)
        {
            Caption = 'Last Updated';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {

        }
    }

    internal procedure GetSetup();
    begin
        if not Get() then begin
            Init();
            Insert();
        end;
    end;

    internal procedure RefreshData(): Boolean
    var
        StripeRefreshData: Codeunit "NPR Stripe Refresh Data";
    begin
        exit(StripeRefreshData.RefreshData(Rec));
    end;

    internal procedure IsStripeActive(): Boolean
    var
        StripeIntegration: Codeunit "NPR Stripe Integration";
    begin
        // Stripe can be disabled if Use Regular Invoicing is marked for the tenant in the case system
        GetSetup();
        exit(not Disabled and StripeIntegration.ShouldStripeBeUsed());
    end;
}