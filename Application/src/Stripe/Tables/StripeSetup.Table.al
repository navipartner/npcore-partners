table 6014649 "NPR Stripe Setup"
{
    Access = Internal;
    Caption = 'Stripe Setup';

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
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        // Following line makes sure that Stripe is used only for app installed in production SaaS environment. 
        // Apps in sandbox do not integrate with Stripe in this case.
        // Stripe can be disabled if Use Regular Invoicing is marked for the tenant in the case system
        // Note: if need to test this in own container comment the code below
        GetSetup();
        exit(not Disabled and EnvironmentInformation.IsProduction() and EnvironmentInformation.IsSaaS());
    end;
}