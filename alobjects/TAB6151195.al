table 6151195 "NpCs Store"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store
    // NPR5.51/MHA /20190719  CASE 362443 Added field 15 "Opening Hour Set"
    // NPR5.52/MHA /20191002  CASE 369476 Added fields 140 "Requested Qty.", 150 "Fulfilled Qty."

    Caption = 'Collect Store';
    DrillDownPageID = "NpCs Stores";
    LookupPageID = "NpCs Stores";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(5;"Company Name";Text[50])
        {
            Caption = 'Company Name';
            TableRelation = Company;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                Company: Record Company;
                Url: Text;
            begin
                if Name = '' then
                  Name := "Company Name";

                if not Company.Get("Company Name") then
                  exit;

                "Local Store" := CompanyName = "Company Name";
                Url := GetUrl(CLIENTTYPE::SOAP,Company.Name,OBJECTTYPE::Codeunit,CODEUNIT::"NpCs Collect Webservice");
                "Service Url" := CopyStr(Url,1,MaxStrLen("Service Url"));
            end;
        }
        field(7;Name;Text[50])
        {
            Caption = 'Name';
        }
        field(10;"Local Store";Boolean)
        {
            Caption = 'Local Store';
        }
        field(15;"Opening Hour Set";Code[20])
        {
            Caption = 'Opening Hour Set';
            Description = 'NPR5.51';
            TableRelation = "NpCs Open. Hour Set";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                NpCsOpenHourSet: Record "NpCs Open. Hour Set";
            begin
                //-NPR5.51 [362443]
                if NpCsOpenHourSet.ChangeCompany("Company Name") then;
                if PAGE.RunModal(0,NpCsOpenHourSet) = ACTION::LookupOK then
                  Validate("Opening Hour Set",NpCsOpenHourSet.Code);
                //+NPR5.51 [362443]
            end;
        }
        field(105;"Service Url";Text[250])
        {
            Caption = 'Service Url';
        }
        field(110;"Service Username";Text[250])
        {
            Caption = 'Service Username';
        }
        field(115;"Service Password";Text[250])
        {
            Caption = 'Service Password';
        }
        field(120;"Geolocation Latitude";Code[50])
        {
            Caption = 'Geolocation Latitude';
        }
        field(125;"Geolocation Longitude";Code[50])
        {
            Caption = 'Geolocation Longitude';
        }
        field(130;"Distance (km)";Decimal)
        {
            Caption = 'Distance (km)';
        }
        field(135;"In Stock";Boolean)
        {
            Caption = 'In Stock';
        }
        field(140;"Requested Qty.";Decimal)
        {
            Caption = 'Requested Qty.';
            DecimalPlaces = 0:5;
            Description = 'NPR5.52';
        }
        field(150;"Fullfilled Qty.";Decimal)
        {
            Caption = 'Fullfilled Qty.';
            DecimalPlaces = 0:5;
            Description = 'NPR5.52';
        }
        field(200;"Salesperson Code";Code[10])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                SalespersonPurchaser: Record "Salesperson/Purchaser";
            begin
                if SalespersonPurchaser.ChangeCompany("Company Name") then;
                if PAGE.RunModal(0,SalespersonPurchaser) = ACTION::LookupOK then
                  Validate("Salesperson Code",SalespersonPurchaser.Code);
            end;
        }
        field(205;"Location Code";Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                Location: Record Location;
            begin
                if Location.ChangeCompany("Company Name") then;
                Location.SetRange("Use As In-Transit",false);
                if PAGE.RunModal(0,Location) = ACTION::LookupOK then
                  Validate("Location Code",Location.Code);
            end;
        }
        field(210;"Bill-to Customer No.";Code[20])
        {
            Caption = 'Bill-to Customer No.';
            TableRelation = Customer;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                Customer: Record Customer;
            begin
                if Customer.ChangeCompany("Company Name") then;
                if PAGE.RunModal(0,Customer) = ACTION::LookupOK then
                  Validate("Bill-to Customer No.",Customer."No.");
            end;
        }
        field(215;"Prepayment Account No.";Code[20])
        {
            Caption = 'Prepayment Account No.';
            TableRelation = "G/L Account" WHERE ("Direct Posting"=CONST(true));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                GLAccount: Record "G/L Account";
            begin
                if GLAccount.ChangeCompany("Company Name") then;
                GLAccount.SetRange("Direct Posting",true);
                if PAGE.RunModal(0,GLAccount) = ACTION::LookupOK then
                  Validate("Prepayment Account No.",GLAccount."No.");
            end;
        }
        field(300;"E-mail";Text[80])
        {
            Caption = 'E-mail';
        }
        field(305;"Mobile Phone No.";Text[30])
        {
            Caption = 'Mobile Phone No.';
            ExtendedDatatype = PhoneNo;
        }
        field(400;"Contact Name";Text[50])
        {
            Caption = 'Contact Name';
        }
        field(405;"Contact Name 2";Text[50])
        {
            Caption = 'Contact Name 2';
        }
        field(410;"Contact Address";Text[50])
        {
            Caption = 'Contact Address';
        }
        field(415;"Contact Address 2";Text[50])
        {
            Caption = 'Contact Address 2';
        }
        field(420;"Contact Post Code";Code[20])
        {
            Caption = 'Contact Post Code';
            TableRelation = IF ("Contact Country/Region Code"=CONST('')) "Post Code".Code
                            ELSE IF ("Contact Country/Region Code"=FILTER(<>'')) "Post Code".Code WHERE ("Country/Region Code"=FIELD("Contact Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                PostCode: Record "Post Code";
            begin
                PostCode.ValidatePostCode("Contact City","Contact Post Code","Contact County","Contact Country/Region Code",(CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(425;"Contact City";Text[30])
        {
            Caption = 'Contact City';
            TableRelation = IF ("Contact Country/Region Code"=CONST('')) "Post Code".City
                            ELSE IF ("Contact Country/Region Code"=FILTER(<>'')) "Post Code".City WHERE ("Country/Region Code"=FIELD("Contact Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                PostCode: Record "Post Code";
            begin
                PostCode.ValidateCity("Contact City","Contact Post Code","Contact County","Contact Country/Region Code",(CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(430;"Contact Country/Region Code";Code[10])
        {
            Caption = 'Contact Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(435;"Contact County";Text[30])
        {
            Caption = 'Contact County';
        }
        field(440;"Contact Phone No.";Text[30])
        {
            Caption = 'Contact Phone No.';
            ExtendedDatatype = PhoneNo;
        }
        field(445;"Contact E-mail";Text[80])
        {
            Caption = 'Contact E-mail';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
        key(Key2;"Distance (km)")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        NpCsStorePOSRelation: Record "NpCs Store POS Relation";
        NpCsStoreWorkflowRelation: Record "NpCs Store Workflow Relation";
    begin
        NpCsStoreWorkflowRelation.SetRange("Store Code",Code);
        if NpCsStoreWorkflowRelation.FindFirst then
          NpCsStoreWorkflowRelation.DeleteAll;

        NpCsStorePOSRelation.SetRange("Store Code",Code);
        if NpCsStorePOSRelation.FindFirst then
          NpCsStorePOSRelation.DeleteAll;
    end;

    procedure GetServiceName() ServiceName: Text
    var
        Position: Integer;
    begin
        if "Service Url" = '' then
          exit('');

        ServiceName := "Service Url";
        Position := StrPos(ServiceName,'/');
        while Position > 0 do begin
          ServiceName := DelStr(ServiceName,1,Position);
          Position := StrPos(ServiceName,'/');
        end;
        Position := StrPos(ServiceName,'?');
        if Position > 0 then
          ServiceName := DelStr(ServiceName,Position);

        exit(ServiceName);
    end;
}

