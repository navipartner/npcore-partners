table 6151024 "NPR NpRv Partner"
{
    Access = Internal;
    Caption = 'Retail Voucher Partner';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpRv Partners";
    LookupPageID = "NPR NpRv Partners";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;

            trigger OnValidate()
            var
                NpRvPartnerMgt: Codeunit "NPR NpRv Partner Mgt.";
            begin
                NpRvPartnerMgt.InitLocalPartner(Rec);
            end;
        }
        field(5; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            TableRelation = Company;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                Company: Record Company;
                NpRvPartnerMgt: Codeunit "NPR NpRv Partner Mgt.";
                ServiceUrl: Text;
                ServiceURLErr: Label 'ServiceURL returned in GetGlobalVoucherWSUrl function is too big to be stored in "Service Url" field. Please contact administrator.';
            begin
                if StrLen(Name) <= MaxStrLen(Company.Name) then
                    if Company.Get(Name) then begin
                        ServiceUrl := NpRvPartnerMgt.GetGlobalVoucherWSUrl(Company.Name);
                        if StrLen(ServiceUrl) > MaxStrLen("Service Url") then
                            Error(ServiceURLErr) else
                            "Service Url" := CopyStr(ServiceUrl, 1, MaxStrLen("Service Url"));
                    end;
            end;
        }
        field(10; "Service Url"; Text[250])
        {
            Caption = 'Service Url';
            DataClassification = CustomerContent;
        }
        field(106; AuthType; Enum "NPR API Auth. Type")
        {
            Caption = 'Auth. Type';
            DataClassification = CustomerContent;
        }
        field(15; "Service Username"; Code[50])
        {
            Caption = 'Service Username';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName("Service Username");
            end;
        }
        field(20; "Service Password"; Text[100])
        {
            Caption = 'Service Password';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Use Isolated Storage';
        }

        field(25; "API Password Key"; GUID)
        {
            Caption = 'API Password Key';
            DataClassification = EndUserPseudonymousIdentifiers;
        }

        field(117; "OAuth2 Setup Code"; Code[20])
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
                WebServiceAuthHelper.GetBasicAuthorizationParamsBuff(Rec."Service Username", Rec."API Password Key", AuthParamsBuff);
            Rec.AuthType::OAuth2:
                WebServiceAuthHelper.GetOpenAuthorizationParamsBuff(Rec."OAuth2 Setup Code", AuthParamsBuff);
        end;
        iAuth.CheckMandatoryValues(AuthParamsBuff);
        iAuth.SetAuthorizationValue(RequestHeaders, AuthParamsBuff);
    end;
}