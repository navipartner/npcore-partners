table 6151410 "NPR Magento Inv. Company"
{
    Caption = 'Magento Inventory Company';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = Company;
        }
        field(5; "Location Filter"; Text[100])
        {
            Caption = 'Location Filter';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                Location: Record Location;
            begin
                if "Company Name" <> CompanyName then
                    if not Location.ChangeCompany("Company Name") then
                        exit;

                if PAGE.RunModal(PAGE::"Location List", Location) <> ACTION::LookupOK then
                    exit;

                "Location Filter" := Location.Code;
            end;

            trigger OnValidate()
            begin
                "Location Filter" := UpperCase("Location Filter");
            end;
        }
        field(10; "Api Url"; Text[250])
        {
            Caption = 'Api Url';
            DataClassification = CustomerContent;
        }

        field(14; AuthType; Enum "NPR API Auth. Type")
        {
            Caption = 'Auth. Type';
            DataClassification = CustomerContent;
        }
        field(15; "Api Username"; Text[100])
        {
            Caption = 'Api Username';
            DataClassification = CustomerContent;
        }
        field(20; "Api Password"; Text[100])
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'IsolatedStorage is in use.';
            Caption = 'Api Password';
            DataClassification = CustomerContent;
        }
        field(21; "Api Password Key"; Guid)
        {
            Caption = 'Api Password Key';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(22; "OAuth2 Setup Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "NPR OAuth Setup";
            Caption = 'OAuth2.0 Setup Code';
        }
        field(25; "Api Domain"; Text[100])
        {
            Caption = 'Api Domain';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
    }

    keys
    {
        key(Key1; "Company Name")
        {
        }
    }

    trigger OnInsert()
    begin
        SetApiUrl();
    end;

    trigger OnModify()
    begin
        SetApiUrl();
    end;

    trigger OnDelete()
    var
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
    begin
        if WebServiceAuthHelper.HasApiPassword(Rec."API Password Key") then
            WebServiceAuthHelper.RemoveApiPassword("API Password Key");
    end;

    procedure SetApiUrl()
    var
        Position: Integer;
    begin
        if "Api Url" = '' then begin
            "Api Url" := CopyStr(GetUrl(CLIENTTYPE::SOAP, "Company Name", OBJECTTYPE::Codeunit, CODEUNIT::"NPR Magento Webservice"), 1, MaxStrLen("Api Url"));
            if StrPos(LowerCase("Api Url"), 'https://') = 1 then begin
                Position := StrPos(CopyStr("Api Url", StrLen('https://')), ':');
                "Api Url" := 'https://localhost.dynamics-retail.com:' + CopyStr("Api Url", StrLen('https://') + Position);
            end;
        end;
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
                WebServiceAuthHelper.GetBasicAuthorizationParamsBuff(Copystr(Rec."Api Username", 1, 50), Rec."API Password Key", AuthParamsBuff);
            Rec.AuthType::OAuth2:
                WebServiceAuthHelper.GetOpenAuthorizationParamsBuff(Rec."OAuth2 Setup Code", AuthParamsBuff);
        end;
        iAuth.CheckMandatoryValues(AuthParamsBuff);
        iAuth.SetAuthorizationValue(RequestHeaders, AuthParamsBuff);
    end;
}