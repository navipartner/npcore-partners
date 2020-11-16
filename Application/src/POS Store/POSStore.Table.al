table 6150614 "NPR POS Store"
{
    // NPR5.29/AP/20170126 CASE 261728 Recreated ENU-captions
    // NPR5.30/AP/20170207 CASE 265509 Added new fields for Geolocation
    // NPR5.31/AP/20170413 CASE 272321 Added fields primarily for BI measures and groupings (Fields 810..814)
    //                                 Changed Decimal Places for Geolocation fields (800+801) to '0:7' (Google-precision coordinates)
    // NPR5.32.10/BR/20170612 CASE 279551 Added fields and functions for Item Posting
    // NPR5.36/BR/20170627 CASE 279551 Removed fields Item Journal Template and Item Journal Batch, changed Optionstring of field Item Posting
    // NPR5.36/BR/20170914 CASE 289641 Added field VAT Customer No., Delete related POSPostingSetup records
    // NPR5.38/BR/20180125 CASE 302803 Added field Posting Compression, renamed field POS Ledger No. Series to POS Period Register No. Series
    // NPR5.48/MMV /20180615 CASE 318028 Added field 28 for countries with location specific registration no.
    // NPR5.51/TSA /20190722 CASE 361917 Removed unreferenced functions SendToJournal(), PostToEntries(), PostOnFinaliseSale(), PostOnClosePOS()
    // NPR5.53/ALPO/20191021 CASE 371956 Dimensions: POS Store & POS Unit integration
    // NPR5.55/ALPO/20200730 CASE 414938 POS Store/POS Unit - Restaurant link (added "POS Restaurant Profile")

    Caption = 'POS Store';
    DataClassification = CustomerContent;
    DataCaptionFields = "Code", Name;
    DrillDownPageID = "NPR POS Store List";
    LookupPageID = "NPR POS Store List";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(3; "Name 2"; Text[50])
        {
            Caption = 'Name 2';
            DataClassification = CustomerContent;
        }
        field(4; Address; Text[50])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(5; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;
        }
        field(6; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            DataClassification = CustomerContent;
            TableRelation = IF ("Country/Region Code" = CONST('')) "Post Code"
            ELSE
            IF ("Country/Region Code" = FILTER(<> '')) "Post Code" WHERE("Country/Region Code" = FIELD("Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                PostCode.ValidatePostCode(City, "Post Code", County, "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(7; City; Text[30])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
            TableRelation = IF ("Country/Region Code" = CONST('')) "Post Code".City
            ELSE
            IF ("Country/Region Code" = FILTER(<> '')) "Post Code".City WHERE("Country/Region Code" = FIELD("Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                PostCode.ValidateCity(City, "Post Code", County, "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(8; Contact; Text[50])
        {
            Caption = 'Contact';
            DataClassification = CustomerContent;
        }
        field(9; County; Text[30])
        {
            Caption = 'County';
            DataClassification = CustomerContent;
        }
        field(10; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
        }
        field(15; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
            ExtendedDatatype = PhoneNo;
        }
        field(16; "Fax No."; Text[30])
        {
            Caption = 'Fax No.';
            DataClassification = CustomerContent;
        }
        field(17; "E-Mail"; Text[80])
        {
            Caption = 'E-Mail';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;
        }
        field(18; "Home Page"; Text[80])
        {
            Caption = 'Home Page';
            DataClassification = CustomerContent;
            ExtendedDatatype = URL;
        }
        field(19; Picture; BLOB)
        {
            Caption = 'Picture';
            DataClassification = CustomerContent;
            SubType = Bitmap;
        }
        field(21; "Posting Compression"; Option)
        {
            Caption = 'Posting Compression';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
            InitValue = "Per POS Entry";
            OptionCaption = 'Uncompressed,Per POS Entry,Per POS Period';
            OptionMembers = Uncompressed,"Per POS Entry","Per POS Period";

            trigger OnValidate()
            begin
                //-NPR5.38 [302803]
                if "Posting Compression" = "Posting Compression"::"Per POS Period" then
                    TestField("POS Period Register No. Series");
                //+NPR5.38 [302803]
            end;
        }
        field(25; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
        }
        field(26; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            DataClassification = CustomerContent;
            TableRelation = Language;
        }
        field(27; "VAT Registration No."; Text[20])
        {
            Caption = 'VAT Registration No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                VATRegNoFormat: Record "VAT Registration No. Format";
                VATRegistrationLogMgt: Codeunit "VAT Registration Log Mgt.";
            begin
            end;
        }
        field(28; "Registration No."; Text[20])
        {
            Caption = 'Registration No.';
            DataClassification = CustomerContent;
        }
        field(30; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Global Dimension 1 Code");
            end;
        }
        field(31; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Global Dimension 2 Code");
            end;
        }
        field(50; "Gen. Bus. Posting Group"; Code[10])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Business Posting Group";

            trigger OnValidate()
            var
                GenBusPostingGrp: Record "Gen. Business Posting Group";
            begin
                if xRec."Gen. Bus. Posting Group" <> "Gen. Bus. Posting Group" then
                    if GenBusPostingGrp.ValidateVatBusPostingGroup(GenBusPostingGrp, "Gen. Bus. Posting Group") then
                        Validate("VAT Bus. Posting Group", GenBusPostingGrp."Def. VAT Bus. Posting Group");
            end;
        }
        field(51; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            DataClassification = CustomerContent;
            TableRelation = "Tax Area";
        }
        field(52; "Tax Liable"; Boolean)
        {
            Caption = 'Tax Liable';
            DataClassification = CustomerContent;
        }
        field(53; "VAT Bus. Posting Group"; Code[10])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
        }
        field(54; "Default POS Posting Setup"; Option)
        {
            Caption = 'Default POS Posting Setup';
            DataClassification = CustomerContent;
            OptionCaption = 'Store,Customer';
            OptionMembers = Store,Customer;
        }
        field(60; "Item Posting"; Option)
        {
            Caption = 'Item Posting';
            DataClassification = CustomerContent;
            Description = 'NPR5.32.10';
            OptionCaption = 'Post On Finalize Sale,Post on Close Register,No Posting';
            OptionMembers = "Post On Finalize Sale","Post on Close Register","No Posting";
        }
        field(65; "POS Period Register No. Series"; Code[10])
        {
            Caption = 'POS Period Register No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(70; "POS Entry Doc. No. Series"; Code[10])
        {
            Caption = 'POS Entry Doc. No. Series';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
            TableRelation = "No. Series";
        }
        field(570; "POS Restaurant Profile"; Code[20])
        {
            Caption = 'POS Restaurant Profile';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            TableRelation = "NPR POS NPRE Rest. Profile";
        }
        field(800; "Geolocation Latitude"; Decimal)
        {
            Caption = 'Geolocation Latitude';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 7;
            Description = 'NPR5.30,NPR5.31';
        }
        field(801; "Geolocation Longitude"; Decimal)
        {
            Caption = 'Geolocation Longitude';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 7;
            Description = 'NPR5.30,NPR5.31';
        }
        field(810; "Store Size"; Decimal)
        {
            Caption = 'Store Size';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.31';
        }
        field(811; "Opening Date"; Date)
        {
            Caption = 'Opening Date';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
        }
        field(812; "Store Group Code"; Code[20])
        {
            Caption = 'Store Group Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
            TableRelation = "NPR POS Entity Group".Code WHERE("Table ID" = CONST(6150614),
                                                           "Field No." = CONST(812));
        }
        field(813; "Store Category Code"; Code[20])
        {
            Caption = 'Store Category Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
            TableRelation = "NPR POS Entity Group".Code WHERE("Table ID" = CONST(6150614),
                                                           "Field No." = CONST(813));
        }
        field(814; "Store Locality Code"; Code[20])
        {
            Caption = 'Store Locality Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
            TableRelation = "NPR POS Entity Group".Code WHERE("Table ID" = CONST(6150614),
                                                           "Field No." = CONST(814));
        }
        field(850; "VAT Customer No."; Code[20])
        {
            Caption = 'VAT Customer No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
            TableRelation = Customer;
        }
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
        POSPostingSetup: Record "NPR POS Posting Setup";
    begin
        //-NPR5.36 [289641]
        POSPostingSetup.SetRange("POS Store Code", Code);
        POSPostingSetup.DeleteAll(true);
        //+NPR5.36 [289641]
        DimMgt.DeleteDefaultDim(DATABASE::"NPR POS Store", Code);  //NPR5.53 [371956]
    end;

    trigger OnInsert()
    begin
        //-NPR5.53 [371956]
        DimMgt.UpdateDefaultDim(
          DATABASE::"NPR POS Store", Code,
          "Global Dimension 1 Code", "Global Dimension 2 Code");
        //+NPR5.53 [371956]
    end;

    var
        PostCode: Record "Post Code";
        DimMgt: Codeunit DimensionManagement;

    local procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        DimMgt.SaveDefaultDim(DATABASE::"NPR POS Store", Code, FieldNumber, ShortcutDimCode);
        Modify;
    end;
}

