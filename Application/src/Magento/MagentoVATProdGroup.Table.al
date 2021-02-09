table 6151406 "NPR Magento VAT Prod. Group"
{
    Caption = 'Magento VAT Product Group';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "VAT Product Posting Group"; Code[20])
        {
            Caption = 'VAT Product Posting Group';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "VAT Product Posting Group";
        }
        field(2; Description; Text[50])
        {
            CalcFormula = Lookup("VAT Product Posting Group".Description WHERE(Code = FIELD("VAT Product Posting Group")));
            Caption = 'Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059810; "Magento Tax Class"; Text[250])
        {
            Caption = 'Magento Tax Class';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Tax Class" WHERE(Type = CONST(Item));
        }
    }

    keys
    {
        key(Key1; "VAT Product Posting Group")
        {
        }
    }
}