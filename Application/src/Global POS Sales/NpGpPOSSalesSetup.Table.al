table 6151170 "NPR NpGp POS Sales Setup"
{
    Access = Internal;
    Caption = 'Global POS Sales Setup';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpGp Global POSSalesSetups";
    LookupPageID = "NPR NpGp Global POSSalesSetups";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(5; "Company Name"; Text[100])
        {
            Caption = 'Company Name';
            DataClassification = CustomerContent;
            TableRelation = Company;

            trigger OnValidate()
            var
                Company: Record Company;
                NpGpPOSSalesSyncMgt: Codeunit "NPR NpGp POS Sales Sync Mgt.";
                Url: Text;
            begin
                if StrLen("Company Name") > MaxStrLen(Company.Name) then
                    exit;
                if not Company.Get("Company Name") then
                    exit;

                NpGpPOSSalesSyncMgt.InitGlobalPosSalesService();
                Url := GetUrl(CLIENTTYPE::SOAP, Company.Name, OBJECTTYPE::Codeunit, CODEUNIT::"NPR NpGp POS Sales WS");
                "Service Url" := CopyStr(Url, 1, MaxStrLen("Service Url"));
            end;
        }
        field(10; "Service Url"; Text[250])
        {
            Caption = 'Service Url';
            DataClassification = CustomerContent;
        }

        field(14; AuthType; Enum "NPR API Auth. Type")
        {
            Caption = 'Auth. Type';
            DataClassification = CustomerContent;
        }

        field(15; "Service Username"; Text[250])
        {
            Caption = 'Service Username';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(20; "Service Password"; Guid)
        {
            Caption = 'Service Password Key';
            DataClassification = EndUserPseudonymousIdentifiers;
        }
        field(117; "OAuth2 Setup Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "NPR OAuth Setup";
            Caption = 'OAuth2.0 Setup Code';
        }
        field(25; "Sync POS Sales Immediately"; Boolean)
        {
            Caption = 'Sync POS Sales Immediately';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Discontinued in BC17';
        }
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
        field(30; "Use api"; Boolean)
        {
            Caption = 'Use api';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                NpGpExporttoAPI: Codeunit "NPR NpGp Export to API";
            begin
                if "Use api" and ("Service Url" <> '') and ("OData Base Url" = '') then
                    "OData Base Url" := SoapUrlToODataUrl("Service Url");
                if "Use api" then
                    NpGpExporttoAPI.InitExportControl(Rec.Code);
            end;
        }
#endif
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
        field(31; "OData Base Url"; Text[250])
        {
            Caption = 'OData Base Url';
            DataClassification = CustomerContent;
        }
#endif
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
        field(33; "Environment Type"; Option)
        {
            Caption = 'Environment Type';
            OptionMembers = Saas,OnPrem,Crane;
            OptionCaption = 'Saas,OnPrem,Crane';
            DataClassification = CustomerContent;
        }
#endif
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
        field(34; "Last exported POS Entry"; Integer)
        {
            Caption = 'Last exported POS Entry';
            FieldClass = FlowField;
            CalcFormula = lookup("NPR NpGp Export Control"."Last Entry No. Exported" where("POS Sales Setup Code" = field(Code)));
            Editable = false;
        }
#endif
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
        field(35; "Last exported"; DateTime)
        {
            Caption = 'Last exported';
            FieldClass = FlowField;
            CalcFormula = lookup("NPR NpGp Export Control"."Last Exported Date" where("POS Sales Setup Code" = field(Code)));
            Editable = false;
        }
#endif
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
    begin
        if WebServiceAuthHelper.HasApiPassword(Rec."Service Password") then
            WebServiceAuthHelper.RemoveApiPassword("Service Password");
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
                WebServiceAuthHelper.GetBasicAuthorizationParamsBuff(Rec."Service Username", Rec."Service Password", AuthParamsBuff);
            Rec.AuthType::OAuth2:
                WebServiceAuthHelper.GetOpenAuthorizationParamsBuff(Rec."OAuth2 Setup Code", AuthParamsBuff);
        end;
        iAuth.CheckMandatoryValues(AuthParamsBuff);
        iAuth.SetAuthorizationValue(RequestHeaders, AuthParamsBuff);
    end;

#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
    local procedure SoapUrlToODataUrl(SoapUrl: Text[250]): Text[250]
    var
        TenantID: Text;
        TenantGuid: Guid;
        EnvironmentName: Text;
        ServiceCompanyName: Text;
        TextList: List of [Text];
        Index: Integer;
    begin
        if not SoapUrl.ToLower().Contains('/codeunit/') then
            exit('');
        if not SoapUrl.ToLower().Contains('/ws/') then
            exit('');
        TextList := SoapUrl.ToLower().Split('/');
        Index := TextList.LastIndexOf('codeunit');
        if TextList.Get(Index - 2) <> 'ws' then
            exit('');
        TextList := SoapUrl.Split('/');
        ServiceCompanyName := TextList.Get(Index - 1);
        EnvironmentName := TextList.Get(Index - 3);
        if Evaluate(TenantGuid, TextList.Get(Index - 4)) then begin
            TenantID := TextList.Get(Index - 4);
            Rec."Environment Type" := Rec."Environment Type"::Saas;
        end else begin
            Index := Index - 4;
            while (Index > 0) and (not TextList.Get(Index).ToLower().Contains('.dynamics-retail')) do
                Index -= 1;
            TextList := TextList.Get(Index).Split('.');
            TenantID := TextList.Get(1);
            Rec."Environment Type" := Rec."Environment Type"::Crane;
        end;
#pragma warning disable AA0139
        exit(StrSubstNo('https://api.npretail.app/%1/%2/%3/', TenantID, EnvironmentName, ServiceCompanyName));
#pragma warning restore        
    end;
#endif
}

