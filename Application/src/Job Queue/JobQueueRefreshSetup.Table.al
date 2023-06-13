table 6059870 "NPR Job Queue Refresh Setup"
{
    Access = Internal;
    Caption = 'Job Queue Refresh Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(20; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = OrganizationIdentifiableInformation;
            InitValue = true;
        }
        field(30; "Last Refreshed"; DateTime)
        {
            Caption = 'Last Refreshed';
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
}