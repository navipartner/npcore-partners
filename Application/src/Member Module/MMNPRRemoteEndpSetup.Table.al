table 6060146 "NPR MM NPR Remote Endp. Setup"
{
    Access = Internal;

    Caption = 'MM NPR Remote Endpoint Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Member Services,Loyalty Services';
            OptionMembers = MemberServices,LoyaltyServices;
        }
        field(5; "Community Code"; Code[20])
        {
            Caption = 'Community Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Member Community";
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Credentials Type"; Option)
        {
            Caption = 'Credentials Type';
            DataClassification = CustomerContent;
            OptionCaption = 'System,Named,Basic Authentication';
            OptionMembers = SYSTEM,NAMED,BASIC;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not supported anymore. NTLM replaced with Basic or OAuth2.0';
        }
        field(21; "User Domain"; Text[30])
        {
            Caption = 'User Domain';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not supported anymore. NTLM replaced with Basic or OAuth2.0';
        }
        field(22; "User Account"; Text[50])
        {
            Caption = 'User Name';
            DataClassification = CustomerContent;
        }
        field(23; "User Password"; Text[30])
        {
            Caption = 'User Password';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Replaced with Isolated Storage Password Key';
        }
        field(24; "User Password Key"; GUID)
        {
            Caption = 'User Password Key';
            DataClassification = EndUserPseudonymousIdentifiers;
        }

        field(30; "Endpoint URI"; Text[200])
        {
            Caption = 'Endpoint URI';
            DataClassification = CustomerContent;
        }
        field(40; Disabled; Boolean)
        {
            Caption = 'Disabled';
            DataClassification = CustomerContent;
        }
        field(50; "Connection Timeout (ms)"; Integer)
        {
            Caption = 'Connection Timeout (ms)';
            DataClassification = CustomerContent;
        }

        field(60; AuthType; Enum "NPR API Auth. Type")
        {
            Caption = 'Auth. Type';
            DataClassification = CustomerContent;
        }

        field(65; "OAuth2 Setup Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "NPR OAuth Setup";
            Caption = 'OAuth2.0 Setup Code';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    trigger OnDelete()
    var
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
    begin
        if WebServiceAuthHelper.HasApiPassword(Rec."User Password Key") then
            WebServiceAuthHelper.RemoveApiPassword("User Password Key");
    end;
}

