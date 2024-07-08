table 6059821 "NPR RS VAT Post. Setup Mapping"
{
    Access = Internal;
    Caption = 'RS VAT Posting Setup Mapping';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR RS VAT Post. Setup Mapping";
    LookupPageId = "NPR RS VAT Post. Setup Mapping";

    fields
    {
        field(1; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
        }
        field(2; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Product Posting Group";
        }
        field(10; "VAT %"; Decimal)
        {
            CalcFormula = lookup("VAT Posting Setup"."VAT %" where("VAT Bus. Posting Group" = field("VAT Bus. Posting Group"), "VAT Prod. Posting Group" = field("VAT Prod. Posting Group")));
            Caption = 'VAT %';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
            MaxValue = 100;
            MinValue = 0;
        }
        field(15; "RS Tax Category Name"; Text[20])
        {
            Caption = 'RS Tax Category Name';
            DataClassification = CustomerContent;
            TableRelation = "NPR RS Allowed Tax Rates"."Tax Category Name";
            trigger OnValidate()
            var
                RSAllowedTaxRates: Record "NPR RS Allowed Tax Rates";
                VATMismatchErr: Label 'RS Tax Category can only be chosen on drill down page.';
            begin
                if "RS Tax Category Name" = '' then begin
                    Clear("RS Tax Category Label");
                    Clear("RS Tax Category Name");
                end else begin
                    RSAllowedTaxRates.Get("RS Tax Category Name", "RS Tax Category Label");
                    CalcFields("VAT %");
                    if RSAllowedTaxRates."Tax Category Rate" <> "VAT %" then
                        Error(VATMismatchErr);
                end;
            end;
        }
        field(20; "RS Tax Category Label"; Text[20])
        {
            Caption = 'RS Tax Category Label';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "NPR RS Allowed Tax Rates"."Tax Category Rate Label";
        }
    }

    keys
    {
        key(Key1; "VAT Bus. Posting Group", "VAT Prod. Posting Group")
        {
        }
    }
}