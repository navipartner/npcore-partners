table 6059806 "NPR Environment Information"
{
    Access = Internal;
    Caption = 'Environment Information';
    DataClassification = CustomerContent;


    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; "Environment Verified"; Boolean)
        {
            Caption = 'Environment Verified';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ActiveSession: Record "Active Session";
            begin
                if "Environment Verified" then begin
                    ActiveSession.Get(ServiceInstanceId(), SessionId());
                    "Environment Database Name" := ActiveSession."Database Name";
                    "Environment Company Name" := CopyStr(CompanyName(), 1, MaxStrLen("Environment Company Name"));
                    "Environment Tenant Name" := CopyStr(TenantId(), 1, MaxStrLen("Environment Tenant Name"));
                    Modify();
                end;
            end;
        }
        field(3; "Environment Database Name"; Text[250])
        {
            Caption = 'Environment Database Name';
            DataClassification = CustomerContent;
        }
        field(4; "Environment Company Name"; Text[250])
        {
            Caption = 'Environment Company Name';
            DataClassification = CustomerContent;
        }
        field(5; "Environment Tenant Name"; Text[250])
        {
            Caption = 'Environment Tenant Name';
            DataClassification = CustomerContent;
        }
        field(6; "Environment Type"; Enum "NPR Environment Type")
        {
            Caption = 'Environment Type';
            DataClassification = CustomerContent;
        }
        field(7; "Environment Template"; Boolean)
        {
            Caption = 'Environment Template';
            DataClassification = CustomerContent;
        }

    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}
