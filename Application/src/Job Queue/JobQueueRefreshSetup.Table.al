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
                HttpResponseMessage: HttpResponseMessage;
                ResponseText: Text;
                OnPremLbl: Label 'NP Retail External JQ Refresher integration is supported only on Cloud environment.\Current environment - ''OnPrem''.';
            begin
                if "Use External JQ Refresher" and EnvironmentInformation.IsOnPrem() then
                    Error(OnPremLbl);
                if "Use External JQ Refresher" then begin
                    ExternalJQRefresherMgt.CreateTenantWebService();
                    ExternalJQRefresherMgt.ManageExternalJQRefresherTenants(TenantManageOptions::create, HttpResponseMessage);
                end else
                    ExternalJQRefresherMgt.ManageExternalJQRefresherTenants(TenantManageOptions::delete, HttpResponseMessage);
                HttpResponseMessage.Content().ReadAs(ResponseText);
                Message(ResponseText);
            end;
        }
        field(50; "Default Refresher User"; Text[250])
        {
            Caption = 'Default JQ Runner User Name';
            DataClassification = CustomerContent;
            TableRelation = "AAD Application";

            trigger OnLookup()
            var
                ExternalJQRefresherMgt: Codeunit "NPR External JQ Refresher Mgt.";
            begin
                ExternalJQRefresherMgt.RequestJQRefresherUser("Default Refresher User");
            end;
        }
        field(60; "Create Missing Custom JQs"; Boolean)
        {
            Caption = 'Create Missing Custom JQs';
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
            Commit();
        end;
    end;
}