table 6060146 "NPR MM NPR Remote Endp. Setup"
{
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
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not supported anymore. NTLM replaced with Basic or OAuth2.0';
        }
        field(21; "User Domain"; Text[30])
        {
            Caption = 'User Domain';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
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
            ObsoleteTag = '2023-06-28';
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
        field(32; "Rest Api Endpoint URI"; Text[200])
        {
            Caption = 'Rest Api Endpoint URI';
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

    procedure SetRequestHeadersAuthorization(var RequestHeaders: HttpHeaders)
    var
        AuthParamsBuff: Record "NPR Auth. Param. Buffer";
        iAuth: Interface "NPR API IAuthorization";
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
    begin
        iAuth := Rec.AuthType;
        case Rec.AuthType of
            Rec.AuthType::Basic:
                WebServiceAuthHelper.GetBasicAuthorizationParamsBuff(copystr(Rec."User Account", 1, 50), Rec."User Password Key", AuthParamsBuff);
            Rec.AuthType::OAuth2:
                WebServiceAuthHelper.GetOpenAuthorizationParamsBuff(Rec."OAuth2 Setup Code", AuthParamsBuff);
        end;
        iAuth.CheckMandatoryValues(AuthParamsBuff);
        iAuth.SetAuthorizationValue(RequestHeaders, AuthParamsBuff);
    end;

    procedure SoapUriToRestUri(SoapEndpointURI: Text[200]): Text[200]
    var
        UriParts: List of [Text];
        Position: Integer;
        SoapApiLbl: Label 'api.businesscentral.dynamics.com/v2.0', Locked = true;
        RestApiLbl: Label 'https://api.npretail.app/%1/%2/%3', Locked = true;
        Tenant: Text;
        Environment: Text;
        Company: Text;
        GuidValue: Guid;
    begin
        SoapEndpointURI := SoapEndpointURI.ToLower();
        Position := StrPos(SoapEndpointURI, SoapApiLbl);
        if Position = 0 then
            exit('');
#pragma warning disable AA0139
        SoapEndpointURI := CopyStr(SoapEndpointURI, Position + StrLen(SoapApiLbl) + 1);
#pragma warning restore AA0139
        UriParts := SoapEndpointURI.Split('/');
        if not UriParts.Get(1, Tenant) then
            exit('');
        if not Evaluate(GuidValue, Tenant) then
            exit('');
        if not UriParts.Get(2, Environment) then
            exit('');
        if not UriParts.Get(4, Company) then
            exit('');
        exit(StrSubstNo(RestApiLbl, Tenant, Environment, Company));
    end;

}

