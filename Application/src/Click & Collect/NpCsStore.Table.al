table 6151195 "NPR NpCs Store"
{
    Caption = 'Collect Store';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpCs Stores";
    LookupPageID = "NPR NpCs Stores";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(5; "Company Name"; Text[50])
        {
            Caption = 'Company Name';
            DataClassification = CustomerContent;
            TableRelation = Company;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                Company: Record Company;
                NpCsStoreStockDataMgt: Codeunit "NPR NpCs Store Stock Data Mgt.";
                Url: Text;
            begin
                if Name = '' then
                    Name := "Company Name";

                if not Company.Get("Company Name") then
                    exit;

                "Local Store" := CompanyName = "Company Name";
                "Store Stock Item Url" := NpCsStoreStockDataMgt.GetStoreStockItemUrl(Company.Name);
                "Store Stock Status Url" := NpCsStoreStockDataMgt.GetStoreStockStatusUrl(Company.Name);
                Url := GetUrl(CLIENTTYPE::SOAP, Company.Name, OBJECTTYPE::Codeunit, CODEUNIT::"NPR NpCs Collect WS");
                "Service Url" := CopyStr(Url, 1, MaxStrLen("Service Url"));
            end;
        }
        field(7; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(10; "Local Store"; Boolean)
        {
            Caption = 'Local Store';
            DataClassification = CustomerContent;
        }
        field(15; "Opening Hour Set"; Code[20])
        {
            Caption = 'Opening Hour Set';
            DataClassification = CustomerContent;
            Description = 'NPR5.51';
            TableRelation = "NPR NpCs Open. Hour Set";
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                NpCsOpenHourSet: Record "NPR NpCs Open. Hour Set";
            begin
                if NpCsOpenHourSet.ChangeCompany("Company Name") then;
                if PAGE.RunModal(0, NpCsOpenHourSet) = ACTION::LookupOK then
                    Validate("Opening Hour Set", NpCsOpenHourSet.Code);
            end;
        }
        field(20; "Magento Description"; BLOB)
        {
            Caption = 'Magento Description';
            DataClassification = CustomerContent;
        }
        field(25; "Store Url"; Text[250])
        {
            Caption = 'Store Url';
            DataClassification = CustomerContent;
        }
        field(95; "Store Stock Item Url"; Text[250])
        {
            Caption = 'Store Stock Item Url';
            DataClassification = CustomerContent;
        }
        field(100; "Store Stock Status Url"; Text[250])
        {
            Caption = 'Store Stock Status Url';
            DataClassification = CustomerContent;
        }
        field(105; "Service Url"; Text[250])
        {
            Caption = 'Service Url';
            DataClassification = CustomerContent;
        }
        field(110; "Service Username"; Text[250])
        {
            Caption = 'Service Username';
            DataClassification = CustomerContent;
        }
        field(115; "Service Password"; Text[250])
        {
            Caption = 'Service Password';
            DataClassification = CustomerContent;
        }
        field(120; "Geolocation Latitude"; Code[50])
        {
            Caption = 'Geolocation Latitude';
            DataClassification = CustomerContent;
        }
        field(125; "Geolocation Longitude"; Code[50])
        {
            Caption = 'Geolocation Longitude';
            DataClassification = CustomerContent;
        }
        field(130; "Distance (km)"; Decimal)
        {
            Caption = 'Distance (km)';
            DataClassification = CustomerContent;
        }
        field(135; "In Stock"; Boolean)
        {
            Caption = 'In Stock';
            DataClassification = CustomerContent;
        }
        field(140; "Requested Qty."; Decimal)
        {
            Caption = 'Requested Qty.';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.52';
        }
        field(150; "Fullfilled Qty."; Decimal)
        {
            Caption = 'Fullfilled Qty.';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.52';
        }
        field(200; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser";
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                SalespersonPurchaser: Record "Salesperson/Purchaser";
            begin
                if SalespersonPurchaser.ChangeCompany("Company Name") then;
                if PAGE.RunModal(0, SalespersonPurchaser) = ACTION::LookupOK then
                    Validate("Salesperson Code", SalespersonPurchaser.Code);
            end;
        }
        field(205; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                Location: Record Location;
            begin
                if Location.ChangeCompany("Company Name") then;
                Location.SetRange("Use As In-Transit", false);
                if PAGE.RunModal(0, Location) = ACTION::LookupOK then
                    Validate("Location Code", Location.Code);
            end;
        }
        field(210; "Bill-to Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                Customer: Record Customer;
            begin
                if Customer.ChangeCompany("Company Name") then;
                if PAGE.RunModal(0, Customer) = ACTION::LookupOK then
                    Validate("Bill-to Customer No.", Customer."No.");
            end;
        }
        field(215; "Prepayment Account No."; Code[20])
        {
            Caption = 'Prepayment Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true));
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                GLAccount: Record "G/L Account";
            begin
                if GLAccount.ChangeCompany("Company Name") then;
                GLAccount.SetRange("Direct Posting", true);
                if PAGE.RunModal(0, GLAccount) = ACTION::LookupOK then
                    Validate("Prepayment Account No.", GLAccount."No.");
            end;
        }
        field(300; "E-mail"; Text[80])
        {
            Caption = 'E-mail';
            DataClassification = CustomerContent;
        }
        field(305; "Mobile Phone No."; Text[30])
        {
            Caption = 'Mobile Phone No.';
            DataClassification = CustomerContent;
            ExtendedDatatype = PhoneNo;
        }
        field(400; "Contact Name"; Text[100])
        {
            Caption = 'Contact Name';
            DataClassification = CustomerContent;
        }
        field(405; "Contact Name 2"; Text[50])
        {
            Caption = 'Contact Name 2';
            DataClassification = CustomerContent;
        }
        field(410; "Contact Address"; Text[100])
        {
            Caption = 'Contact Address';
            DataClassification = CustomerContent;
        }
        field(415; "Contact Address 2"; Text[50])
        {
            Caption = 'Contact Address 2';
            DataClassification = CustomerContent;
        }
        field(420; "Contact Post Code"; Code[20])
        {
            Caption = 'Contact Post Code';
            DataClassification = CustomerContent;
            TableRelation = IF ("Contact Country/Region Code" = CONST('')) "Post Code".Code
            ELSE
            IF ("Contact Country/Region Code" = FILTER(<> '')) "Post Code".Code WHERE("Country/Region Code" = FIELD("Contact Country/Region Code"));
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                PostCode: Record "Post Code";
            begin
                PostCode.ValidatePostCode("Contact City", "Contact Post Code", "Contact County", "Contact Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(425; "Contact City"; Text[30])
        {
            Caption = 'Contact City';
            DataClassification = CustomerContent;
            TableRelation = IF ("Contact Country/Region Code" = CONST('')) "Post Code".City
            ELSE
            IF ("Contact Country/Region Code" = FILTER(<> '')) "Post Code".City WHERE("Country/Region Code" = FIELD("Contact Country/Region Code"));
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                PostCode: Record "Post Code";
            begin
                PostCode.ValidateCity("Contact City", "Contact Post Code", "Contact County", "Contact Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(430; "Contact Country/Region Code"; Code[10])
        {
            Caption = 'Contact Country/Region Code';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
        }
        field(435; "Contact County"; Text[30])
        {
            Caption = 'Contact County';
            DataClassification = CustomerContent;
        }
        field(440; "Contact Phone No."; Text[30])
        {
            Caption = 'Contact Phone No.';
            DataClassification = CustomerContent;
            ExtendedDatatype = PhoneNo;
        }
        field(445; "Contact E-mail"; Text[80])
        {
            Caption = 'Contact E-mail';
            DataClassification = CustomerContent;
        }
        field(450; "Contact Fax No."; Text[30])
        {
            Caption = 'Contact Fax No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
        key(Key2; "Distance (km)")
        {
        }
    }

    trigger OnDelete()
    var
        NpCsStorePOSRelation: Record "NPR NpCs Store POS Relation";
        NpCsStoreWorkflowRelation: Record "NPR NpCs Store Workflow Rel.";
    begin
        NpCsStoreWorkflowRelation.SetRange("Store Code", Code);
        if NpCsStoreWorkflowRelation.FindFirst() then
            NpCsStoreWorkflowRelation.DeleteAll();

        NpCsStorePOSRelation.SetRange("Store Code", Code);
        if NpCsStorePOSRelation.FindFirst() then
            NpCsStorePOSRelation.DeleteAll();
    end;

    procedure GetServiceName() ServiceName: Text
    var
        Position: Integer;
    begin
        if "Service Url" = '' then
            exit('');

        ServiceName := "Service Url";
        Position := StrPos(ServiceName, '/');
        while Position > 0 do begin
            ServiceName := DelStr(ServiceName, 1, Position);
            Position := StrPos(ServiceName, '/');
        end;
        Position := StrPos(ServiceName, '?');
        if Position > 0 then
            ServiceName := DelStr(ServiceName, Position);

        exit(ServiceName);
    end;
}
