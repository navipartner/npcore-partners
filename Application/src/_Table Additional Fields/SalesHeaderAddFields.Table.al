table 6014636 "NPR Sales Header Add. Fields"
{
    Access = Internal;
    Caption = 'Sales Header Relation';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Id; Guid)
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(10; "Document Type"; Enum "Sales Document Type")
        {
            Caption = 'Document Type';
            FieldClass = FlowField;
            CalcFormula = lookup("Sales Header"."Document Type" where(SystemId = field(Id)));
        }
        field(20; "No."; Code[20])
        {
            Caption = 'No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Sales Header"."No." where(SystemId = field(Id)));
        }
        field(30; "Magento Payment Amount"; Decimal)
        {
            CalcFormula = Sum("NPR Magento Payment Line".Amount WHERE("Document Table No." = CONST(36),
                                                                   "Document Type" = FIELD("Document Type"),
                                                                   "Document No." = FIELD("No.")));
            Caption = 'Payment Amount';
            Description = 'MAG2.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(40; "Bill-to Company"; Text[30])
        {
            Caption = 'Bill-to Company (IC)';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            TableRelation = Company;
        }
        field(50; "Package Code"; Code[20])
        {
            Caption = 'Package Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Package Code".Code;
        }
    }

    keys
    {
        key(Key1; Id)
        {
            Clustered = true;
        }
    }
}