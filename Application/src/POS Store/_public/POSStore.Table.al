﻿table 6150614 "NPR POS Store"
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
            ObsoleteTag = '2023-06-28';
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
            ObsoleteTag = '2023-06-28';
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
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Moved to POS Posting Profile';
        }
        field(25; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
            trigger OnLookup()
            var
                Location: Record Location;
                LocationList: Page "Location List";
                IsHandled: Boolean;
            begin
                OnBeforeNormalLookupLocationCode(Rec, IsHandled);
                if IsHandled then
                    exit;

                // Normal Lookup if any condition from subscriber procedures above is not met.
                LocationList.LookupMode := true;
                Location.FilterGroup(2);
                Location.SetRange("Use As In-Transit", false);
                Location.FilterGroup(0);
                LocationList.SetTableView(Location);
                if not (LocationList.RunModal() = Action::LookupOK) then
                    exit;
                LocationList.GetRecord(Location);
                Rec.Validate("Location Code", Location.Code);
            end;
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
        field(28; "Registration No."; Text[50])
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
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Moved to dedicated POS Unit Profile';
        }
        field(51; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Moved to POS Posting Profile';
        }
        field(52; "Tax Liable"; Boolean)
        {
            Caption = 'Tax Liable';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Moved to POS Posting Profile';
        }
        field(53; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Moved to dedicated POS Unit Profile';
        }
        field(54; "Default POS Posting Setup"; Option)
        {
            Caption = 'Default POS Posting Setup';
            DataClassification = CustomerContent;
            OptionCaption = 'Store,Customer';
            OptionMembers = Store,Customer;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Moved to POS Posting Profile';
        }
        field(60; "Item Posting"; Option)
        {
            Caption = 'Item Posting';
            DataClassification = CustomerContent;
            Description = 'NPR5.32.10';
            OptionCaption = 'Post On Finalize Sale,Post on Close Register,No Posting';
            OptionMembers = "Post On Finalize Sale","Post on Close Register","No Posting";
            ObsoleteState = Pending;
            ObsoleteTag = '2024-06-28';
            ObsoleteReason = 'No longer used. All item related POS entry postings are now done via job queue.';
        }
        field(65; "POS Period Register No. Series"; Code[20])
        {
            Caption = 'POS Period Register No. Series';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Moved to dedicated POS Posting Profile';
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
            ObsoleteState = Pending;
            ObsoleteTag = '2025-01-21';
            ObsoleteReason = 'Use POS Store Group instead.';
        }
        field(813; "Store Category Code"; Code[20])
        {
            Caption = 'Store Category Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
            TableRelation = "NPR POS Entity Group".Code WHERE("Table ID" = CONST(6150614),
                                                           "Field No." = CONST(813));
            ObsoleteState = Pending;
            ObsoleteTag = '2025-01-21';
            ObsoleteReason = 'Use POS Store Group instead.';
        }
        field(814; "Store Locality Code"; Code[20])
        {
            Caption = 'Store Locality Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
            TableRelation = "NPR POS Entity Group".Code WHERE("Table ID" = CONST(6150614),
                                                           "Field No." = CONST(814));
            ObsoleteState = Pending;
            ObsoleteTag = '2025-01-21';
            ObsoleteReason = 'Use POS Store Group instead.';
        }
        field(850; "VAT Customer No."; Code[20])
        {
            Caption = 'VAT Customer No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Moved to POS Posting Profile';
        }

        field(860; "Auto Process Ext. POS Sales"; Boolean)
        {
            Caption = 'Auto Process External POS Sales';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Moved to POS Posting Profile';
        }
        field(870; Inactive; Boolean)
        {
            Caption = 'Inactive';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                POSUnit: Record "NPR POS Unit";
                ActivePosUnitError: Label 'There are still active POS Unit(s) with status Open or EOD. Please, close them first.';
            begin
                if Rec.Inactive then begin
                    POSUnit.SetRange("POS Store Code", Rec.Code);
                    POSUnit.SetFilter(Status, '%1|%2', POSUnit.Status::OPEN, POSUnit.Status::EOD);
                    if not POSUnit.IsEmpty then
                        Error(ActivePosUnitError);

                    POSUnit.SetRange(Status);
                    POSUnit.ModifyAll(Status, POSUnit.Status::INACTIVE);
                end;

            end;
        }
        field(880; "POS Shipment Profile"; Code[20])
        {
            Caption = 'POS Shipment Profile';
            DataClassification = CustomerContent;
            TableRelation = "NPR Store Ship. Profile Header".Code;
        }
        field(5700; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            DataClassification = CustomerContent;
            TableRelation = "Responsibility Center";
        }
        field(5710; "Exchange Label EAN Code"; Code[3])
        {
            Caption = 'Exchange Label EAN Code';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NumericErr: label 'Exchange Label EAN Code field should be numeric';
            begin
                if StrLen(DelChr(LowerCase("Exchange Label EAN Code"), '=', '1234567890')) <> 0 then
                    Error(NumericErr);
            end;
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

    internal procedure GetProfile(POSStoreNo: Code[10]; var POSPostingProfile: Record "NPR POS Posting Profile")
    begin
        Get(POSStoreNo);
        TestField("POS Posting Profile");
        POSPostingProfile.Get("POS Posting Profile");
    end;

    internal procedure GetProfile(var POSPostingProfile: Record "NPR POS Posting Profile"): Boolean
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

    [IntegrationEvent(false, false)]
    local procedure OnBeforeNormalLookupLocationCode(var POSStore: Record "NPR POS Store"; var IsHandled: Boolean)
    begin
    end;
}

