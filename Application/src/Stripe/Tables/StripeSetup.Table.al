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
}