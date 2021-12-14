table 6150907 "NPR POS HC Endpoint Setup"
{
    Caption = 'Endpoint Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(5; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
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
            OptionCaption = 'System,Named';
            OptionMembers = SYSTEM,NAMED;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not supported anymore. NTLM replaced with Basic or OAuth2.0';
        }
        field(21; "User Domain"; Text[100])
        {
            Caption = 'User Domain';
            DataClassification = CustomerContent;
            Description = 'NPR5.45';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(22; "User Account"; Text[100])
        {
            Caption = 'User Account';
            DataClassification = CustomerContent;
            Description = 'NPR5.45';
        }
        field(23; "User Password"; Text[100])
        {
            Caption = 'User Password';
            DataClassification = CustomerContent;
            Description = 'NPR5.45';
            ObsoleteState = Removed;
            ObsoleteReason = 'Replaced with Isolated Storage Password Key';
        }

        field(24; AuthType; Enum "NPR API Auth. Type")
        {
            Caption = 'Auth. Type';
            DataClassification = CustomerContent;
        }

        field(25; "API Password Key"; GUID)
        {
            Caption = 'User Password Key';
            DataClassification = EndUserPseudonymousIdentifiers;
        }

        field(26; "OAuth2 Setup Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "NPR OAuth Setup";
            Caption = 'OAuth2.0 Setup Code';
        }
        field(30; "Endpoint URI"; Text[200])
        {
            Caption = 'Endpoint URI';
            DataClassification = CustomerContent;
        }
        field(50; "Connection Timeout (ms)"; Integer)
        {
            Caption = 'Connection Timeout (ms)';
            DataClassification = CustomerContent;
            InitValue = 4000;
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
        if WebServiceAuthHelper.HasApiPassword(Rec."API Password Key") then
            WebServiceAuthHelper.RemoveApiPassword("API Password Key");
    end;

    procedure SetRequestHeadersAuthorization(var RequestHeaders: HttpHeaders)
    var
        AuthParamsBuff: Record "NPR Auth. Param. Buffer";
        iAuth: Interface "NPR API IAuthorization";
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
    begin
        iAuth := Rec.AuthType;
        case Rec.AuthType of
            Rec.AuthType::Basic:
                WebServiceAuthHelper.GetBasicAuthorizationParamsBuff(copystr(Rec."User Account", 1, 50), Rec."API Password Key", AuthParamsBuff);
            Rec.AuthType::OAuth2:
                WebServiceAuthHelper.GetOpenAuthorizationParamsBuff(Rec."OAuth2 Setup Code", AuthParamsBuff);
        end;
        iAuth.CheckMandatoryValues(AuthParamsBuff);
        iAuth.SetAuthorizationValue(RequestHeaders, AuthParamsBuff);
    end;
}

