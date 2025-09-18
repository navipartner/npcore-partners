#if not BC17
table 6150939 "NPR Spfy Metafield Mapping"
{
    Access = Public;
    Extensible = false;
    Caption = 'Shopify Metafield Mapping';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR Spfy Metafield Mappings";
    LookupPageId = "NPR Spfy Metafield Mappings";

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(10; "Table No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Table No.';

            trigger OnValidate()
            begin
                case "Table No." of
                    Database::"Item Attribute":
                        if not ("Owner Type" in ["Owner Type"::PRODUCT, "Owner Type"::PRODUCTVARIANT]) then
                            Validate("Owner Type", "Owner Type"::PRODUCT);
                    Database::"NPR Attribute":
                        Validate("Owner Type", "Owner Type"::CUSTOMER);
                end;
            end;
        }
        field(20; "Field No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Field No.';
        }
        field(30; "BC Record ID"; RecordId)
        {
            DataClassification = CustomerContent;
            Caption = 'BC Record ID';
        }
        field(40; "Shopify Store Code"; Code[20])
        {
            Caption = 'Shopify Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Spfy Store".Code;

            trigger OnValidate()
            begin
                if "Shopify Store Code" <> xRec."Shopify Store Code" then
                    Validate("Metafield ID", '');
            end;
        }
        field(50; "Owner Type"; Enum "NPR Spfy Metafield Owner Type")
        {
            Caption = 'Owner Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Owner Type" <> "Owner Type"::" " then begin
                    case "Table No." of
                        Database::"Item Attribute":
                            if not ("Owner Type" in ["Owner Type"::PRODUCT, "Owner Type"::PRODUCTVARIANT]) then
                                FieldError("Owner Type");
                        Database::"NPR Attribute":
                            TestField("Owner Type", "Owner Type"::CUSTOMER);
                    end;
                end;
                if "Owner Type" <> xRec."Owner Type" then
                    Validate("Metafield ID", '');
            end;
        }
        field(60; "Metafield ID"; Text[30])
        {
            Caption = 'Metafield ID';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping";
                SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
                DuplicateMappingErr: Label 'The same Shopify Metafield ID has already been mapped to a different entity (%1). Mapping to multiple entities is not allowed.';
            begin
                if "Metafield ID" <> '' then begin
                    TestField("Shopify Store Code");
                    TestField("Owner Type");
                    SpfyMetafieldMapping.SetRange("Shopify Store Code", "Shopify Store Code");
                    SpfyMetafieldMapping.SetRange("Owner Type", "Owner Type");
                    SpfyMetafieldMapping.SetRange("Metafield ID", "Metafield ID");
                    SpfyMetafieldMapping.SetFilter("Entry No.", '<>%1', "Entry No.");
                    if SpfyMetafieldMapping.FindFirst() then
                        if "Field No." <> 0 then
                            Error(DuplicateMappingErr, StrSubstNo('%1=%2, %3=%4', FieldCaption("Table No."), "Table No.", FieldCaption("Field No."), "Field No."))
                        else
                            Error(DuplicateMappingErr, Format("BC Record ID"));
                end;
                SpfyMetafieldMgt.ProcessMetafieldMappingChange(Rec, xRec."Metafield ID", "Metafield ID" = '', false);
            end;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Table No.", "Field No.", "BC Record ID", "Shopify Store Code", "Owner Type", "Metafield ID") { }
        key(Key3; "Shopify Store Code", "Owner Type", "Metafield ID") { }
    }

    trigger OnDelete()
    var
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
    begin
        SpfyMetafieldMgt.ProcessMetafieldMappingChange(Rec, "Metafield ID", true, false);
    end;
}
#endif