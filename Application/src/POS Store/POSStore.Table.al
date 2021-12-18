table 6150614 "NPR POS Store"
{
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
            ObsoleteState = Removed;
            ObsoleteReason = 'Won''t be used anymore';
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
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anywhere';
        }
        field(21; "Posting Compression"; Option)
        {
            Caption = 'Posting Compression';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
            InitValue = "Per POS Entry";
            OptionCaption = 'Uncompressed,Per POS Entry,Per POS Period';
            OptionMembers = Uncompressed,"Per POS Entry","Per POS Period";
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to POS Posting Profile';
            ObsoleteTag = 'POS Store -> POS Posting Profile';
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
        field(50; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Business Posting Group";
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to dedicated POS Unit Profile';
            ObsoleteTag = 'NPR POS Store -> NPR POS Unit -> NPR POS Posting Profile';
        }
        field(51; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            DataClassification = CustomerContent;
            TableRelation = "Tax Area";
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to POS Posting Profile';
            ObsoleteTag = 'POS Store -> POS Posting Profile';
        }
        field(52; "Tax Liable"; Boolean)
        {
            Caption = 'Tax Liable';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to POS Posting Profile';
            ObsoleteTag = 'POS Store -> POS Posting Profile';
        }
        field(53; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to dedicated POS Unit Profile';
            ObsoleteTag = 'NPR POS Store -> NPR POS Unit -> NPR POS Posting Profile';
        }
        field(54; "Default POS Posting Setup"; Option)
        {
            Caption = 'Default POS Posting Setup';
            DataClassification = CustomerContent;
            OptionCaption = 'Store,Customer';
            OptionMembers = Store,Customer;
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to POS Posting Profile';
            ObsoleteTag = 'POS Store -> POS Posting Profile';
        }
        field(60; "Item Posting"; Option)
        {
            Caption = 'Item Posting';
            DataClassification = CustomerContent;
            Description = 'NPR5.32.10';
            OptionCaption = 'Post On Finalize Sale,Post on Close Register,No Posting';
            OptionMembers = "Post On Finalize Sale","Post on Close Register","No Posting";
        }
        field(65; "POS Period Register No. Series"; Code[20])
        {
            Caption = 'POS Period Register No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to dedicated POS Posting Profile';
            ObsoleteTag = 'NPR POS Store -> NPR POS Posting Profile';
        }
        field(70; "POS Entry Doc. No. Series"; Code[20])
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
        field(580; "POS Posting Profile"; Code[20])
        {
            Caption = 'POS Posting Profile';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Posting Profile";
            NotBlank = true;
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
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to POS Posting Profile';
            ObsoleteTag = 'POS Store -> POS Posting Profile';
        }

        field(860; "Auto Process Ext. POS Sales"; Boolean)
        {
            Caption = 'Auto Process External POS Sales';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to POS Posting Profile';
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
        fieldgroup(DropDown; Code, Name, City) { }
        fieldgroup(Brick; Code, Name, City) { }
    }

    trigger OnDelete()
    var
        POSPostingSetup: Record "NPR POS Posting Setup";
    begin
        POSPostingSetup.SetRange("POS Store Code", Code);
        POSPostingSetup.DeleteAll(true);
        DimMgt.DeleteDefaultDim(DATABASE::"NPR POS Store", Code);
    end;

    trigger OnInsert()
    begin
        DimMgt.UpdateDefaultDim(
          DATABASE::"NPR POS Store", Code,
          "Global Dimension 1 Code", "Global Dimension 2 Code");
    end;

    var
        PostCode: Record "Post Code";
        DimMgt: Codeunit DimensionManagement;

    local procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeValidateShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode, IsHandled);
        if IsHandled then
            exit;

        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        if not IsTemporary() then begin
            DimMgt.SaveDefaultDim(DATABASE::"NPR POS Store", Code, FieldNumber, ShortcutDimCode);
            Modify();
        end;

        OnAfterValidateShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode);
    end;

    procedure GetProfile(POSStoreNo: Code[10]; var POSPostingProfile: Record "NPR POS Posting Profile")
    begin
        Get(POSStoreNo);
        TestField("POS Posting Profile");
        POSPostingProfile.Get("POS Posting Profile");
    end;

    procedure GetProfile(var POSPostingProfile: Record "NPR POS Posting Profile"): Boolean
    begin
        Clear(POSPostingProfile);
        if "POS Posting Profile" = '' then
            exit;
        exit(POSPostingProfile.Get("POS Posting Profile"));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateShortcutDimCode(var POSStore: Record "NPR POS Store"; var xPOSStore: Record "NPR POS Store"; FieldNumber: Integer; var ShortcutDimCode: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateShortcutDimCode(var POSStore: Record "NPR POS Store"; xPOSStore: Record "NPR POS Store"; FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    end;
}

