table 6151086 "NPR RIS Retail Inv. Set Entry"
{
    Caption = 'Retail Inventory Set Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Set Code"; Code[20])
        {
            Caption = 'Set Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR RIS Retail Inv. Set";
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = Company;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(15; "Location Filter"; Text[100])
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

                if PAGE.RunModal(PAGE::"Location List", Location) = ACTION::LookupOK then
                    "Location Filter" := Location.Code;
            end;

            trigger OnValidate()
            begin
                "Location Filter" := UpperCase("Location Filter");
            end;
        }
        field(20; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
        }
        field(100; "Api Url"; Text[250])
        {
            Caption = 'Api Url';
            DataClassification = CustomerContent;
        }

        field(101; AuthType; Enum "NPR API Auth. Type")
        {
            Caption = 'Auth. Type';
            DataClassification = CustomerContent;
        }
        field(105; "Api Username"; Text[100])
        {
            Caption = 'Api Username';
            DataClassification = CustomerContent;
        }

        field(110; "Api Password"; Text[100])
        {
            Caption = 'Api Password';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Replaced with Isolated Storage Password Key';
        }

        field(111; "API Password Key"; GUID)
        {
            Caption = 'User Password Key';
            DataClassification = EndUserPseudonymousIdentifiers;
        }

        field(112; "OAuth2 Setup Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "NPR OAuth Setup";
            Caption = 'OAuth2.0 Setup Code';
        }

        field(115; "Api Domain"; Text[100])
        {
            Caption = 'Api Domain';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(120; "Processing Codeunit ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Processing Codeunit ID';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR RIS Retail Inv. Set Mgt.");
                EventSubscription.SetRange("Published Function", 'OnProcessInventorySetEntry');
                if PAGE.RunModal(PAGE::"Event Subscriptions", EventSubscription) <> ACTION::LookupOK then
                    exit;

                "Processing Codeunit ID" := EventSubscription."Subscriber Codeunit ID";
                "Processing Function" := EventSubscription."Subscriber Function";
            end;

            trigger OnValidate()
            var
                EventSubscription: Record "Event Subscription";
            begin
                if "Processing Codeunit ID" = 0 then begin
                    "Processing Function" := '';
                    exit;
                end;

                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR RIS Retail Inv. Set Mgt.");
                EventSubscription.SetRange("Published Function", 'OnProcessInventorySetEntry');
                EventSubscription.SetRange("Subscriber Codeunit ID", "Processing Codeunit ID");
                if "Processing Function" <> '' then
                    EventSubscription.SetRange("Subscriber Function", "Processing Function");
                EventSubscription.FindFirst();
            end;
        }
        field(125; "Processing Codeunit Name"; Text[249])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Codeunit),
                                                             "Object ID" = FIELD("Processing Codeunit ID")));
            Caption = 'Processing Codeunit Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(130; "Processing Function"; Text[250])
        {
            Caption = 'Processing Function';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR RIS Retail Inv. Set Mgt.");
                EventSubscription.SetRange("Published Function", 'OnProcessInventorySetEntry');
                if PAGE.RunModal(PAGE::"Event Subscriptions", EventSubscription) <> ACTION::LookupOK then
                    exit;

                "Processing Codeunit ID" := EventSubscription."Subscriber Codeunit ID";
                "Processing Function" := EventSubscription."Subscriber Function";
            end;

            trigger OnValidate()
            var
                EventSubscription: Record "Event Subscription";
            begin
                if "Processing Function" = '' then begin
                    "Processing Codeunit ID" := 0;
                    exit;
                end;

                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR RIS Retail Inv. Set Mgt.");
                EventSubscription.SetRange("Published Function", 'OnProcessInventorySetEntry');
                EventSubscription.SetRange("Subscriber Codeunit ID", "Processing Codeunit ID");
                if "Processing Function" <> '' then
                    EventSubscription.SetRange("Subscriber Function", "Processing Function");
                EventSubscription.FindFirst();
            end;
        }
    }

    keys
    {
        key(Key1; "Set Code", "Line No.")
        {
        }
    }

    trigger OnInsert()
    var
        RetailInvSetMgt: codeunit "NPR RIS Retail Inv. Set Mgt.";
    begin
        RetailInvSetMgt.SetApiUrl(Rec);
    end;

    trigger OnModify()
    var
        RetailInvSetMgt: codeunit "NPR RIS Retail Inv. Set Mgt.";
    begin
        RetailInvSetMgt.SetApiUrl(Rec);
    end;

    trigger OnDelete()
    begin
        RemoveApiPassword();
    end;

    internal procedure RemoveApiPassword()
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
                WebServiceAuthHelper.GetBasicAuthorizationParamsBuff(copystr(Rec."Api Username", 1, 50), Rec."API Password Key", AuthParamsBuff);
            Rec.AuthType::OAuth2:
                WebServiceAuthHelper.GetOpenAuthorizationParamsBuff(Rec."OAuth2 Setup Code", AuthParamsBuff);
        end;
        iAuth.CheckMandatoryValues(AuthParamsBuff);
        iAuth.SetAuthorizationValue(RequestHeaders, AuthParamsBuff);
    end;
}
