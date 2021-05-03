table 6151405 "NPR Magento VAT Bus. Group"
{
    Caption = 'Magento VAT Business Group';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "VAT Business Posting Group"; Code[20])
        {
            Caption = 'VAT Product Posting Group';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "VAT Business Posting Group";
        }
        field(2; Description; Text[50])
        {
            CalcFormula = Lookup("VAT Business Posting Group".Description WHERE(Code = FIELD("VAT Business Posting Group")));
            Caption = 'Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059809; "Magento Tax Class"; Text[250])
        {
            Caption = 'Magento Tax Class';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Tax Class" WHERE(Type = CONST(Customer));
        }
    }

    keys
    {
        key(Key1; "VAT Business Posting Group")
        {
        }
    }
}
