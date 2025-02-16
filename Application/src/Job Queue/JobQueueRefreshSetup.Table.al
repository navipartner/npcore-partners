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
        field(40; "Use External JQ Refresher"; Boolean)
        {
            Caption = 'Use External JQ Refresher';
            DataClassification = CustomerContent;
            Editable = false;

            trigger OnValidate()
            var
                ExternalJQRefresherMgt: Codeunit "NPR External JQ Refresher Mgt.";
                EnvironmentInformation: Codeunit "Environment Information";
                TenantManageOptions: Enum "NPR Ext. JQ Refresher Options";
                ResponseText: Text;
                OnPremLbl: Label 'NP Retail External JQ Refresher integration is supported only on Cloud environment.\Current environment - ''OnPrem''.';
            begin
                if "Use External JQ Refresher" and EnvironmentInformation.IsOnPrem() then
                    Error(OnPremLbl);

                ExternalJQRefresherMgt.ToggleTenantWebService("Use External JQ Refresher");

                if "Use External JQ Refresher" then
                    ResponseText := ExternalJQRefresherMgt.ManageExternalJQRefresherTenants(TenantManageOptions::create)
                else
                    ResponseText := ExternalJQRefresherMgt.ManageExternalJQRefresherTenants(TenantManageOptions::delete);

                Message(ResponseText);
            end;
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