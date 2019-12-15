table 6151086 "RIS Retail Inventory Set Entry"
{
    // NPR5.40/MHA /20180320  CASE 307025 Object created - Retail Inventory Set

    Caption = 'Retail Inventory Set Entry';

    fields
    {
        field(1;"Set Code";Code[20])
        {
            Caption = 'Set Code';
            NotBlank = true;
            TableRelation = "RIS Retail Inventory Set";
        }
        field(5;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(10;"Company Name";Text[30])
        {
            Caption = 'Company Name';
            NotBlank = true;
            TableRelation = Company;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(15;"Location Filter";Text[100])
        {
            Caption = 'Location Filter';

            trigger OnLookup()
            var
                Location: Record Location;
            begin
                if "Company Name" <> CompanyName then
                  if not Location.ChangeCompany("Company Name") then
                    exit;

                if PAGE.RunModal(PAGE::"Location List",Location) = ACTION::LookupOK then
                  "Location Filter" := Location.Code;
            end;

            trigger OnValidate()
            begin
                "Location Filter" := UpperCase("Location Filter");
            end;
        }
        field(20;Enabled;Boolean)
        {
            Caption = 'Enabled';
        }
        field(100;"Api Url";Text[250])
        {
            Caption = 'Api Url';
        }
        field(105;"Api Username";Text[100])
        {
            Caption = 'Api Username';
        }
        field(110;"Api Password";Text[100])
        {
            Caption = 'Api Password';
        }
        field(115;"Api Domain";Text[100])
        {
            Caption = 'Api Domain';
        }
        field(120;"Processing Codeunit ID";Integer)
        {
            BlankZero = true;
            Caption = 'Processing Codeunit ID';

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                EventSubscription.SetRange("Publisher Object Type",EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID",CODEUNIT::"RIS Retail Inventory Set Mgt.");
                EventSubscription.SetRange("Published Function",'OnProcessInventorySetEntry');
                if PAGE.RunModal(PAGE::"Event Subscriptions",EventSubscription) <> ACTION::LookupOK then
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

                EventSubscription.SetRange("Publisher Object Type",EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID",CODEUNIT::"RIS Retail Inventory Set Mgt.");
                EventSubscription.SetRange("Published Function",'OnProcessInventorySetEntry');
                EventSubscription.SetRange("Subscriber Codeunit ID","Processing Codeunit ID");
                if "Processing Function" <> '' then
                  EventSubscription.SetRange("Subscriber Function","Processing Function");
                EventSubscription.FindFirst;
            end;
        }
        field(125;"Processing Codeunit Name";Text[249])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE ("Object Type"=CONST(Codeunit),
                                                             "Object ID"=FIELD("Processing Codeunit ID")));
            Caption = 'Processing Codeunit Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(130;"Processing Function";Text[250])
        {
            Caption = 'Processing Function';

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                EventSubscription.SetRange("Publisher Object Type",EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID",CODEUNIT::"RIS Retail Inventory Set Mgt.");
                EventSubscription.SetRange("Published Function",'OnProcessInventorySetEntry');
                if PAGE.RunModal(PAGE::"Event Subscriptions",EventSubscription) <> ACTION::LookupOK then
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

                EventSubscription.SetRange("Publisher Object Type",EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID",CODEUNIT::"RIS Retail Inventory Set Mgt.");
                EventSubscription.SetRange("Published Function",'OnProcessInventorySetEntry');
                EventSubscription.SetRange("Subscriber Codeunit ID","Processing Codeunit ID");
                if "Processing Function" <> '' then
                  EventSubscription.SetRange("Subscriber Function","Processing Function");
                EventSubscription.FindFirst;
            end;
        }
    }

    keys
    {
        key(Key1;"Set Code","Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        SetApiUrl();
    end;

    trigger OnModify()
    begin
        SetApiUrl();
    end;

    procedure SetApiUrl()
    var
        MagentoWebservice: Codeunit "Magento Webservice";
        Position: Integer;
    begin
        if "Api Url" = '' then
          "Api Url" := GetUrl(CLIENTTYPE::SOAP,"Company Name",OBJECTTYPE::Codeunit,CODEUNIT::"Magento Webservice");
    end;
}

