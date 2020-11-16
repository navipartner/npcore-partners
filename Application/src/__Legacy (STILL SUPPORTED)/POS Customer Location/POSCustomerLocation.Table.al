table 6014530 "NPR POS Customer Location"
{
    // NPR5.22/MMV/20160404 CASE 232067 Created table
    // NPR5.29/MMV /20161214 CASE 261034 Added field 3.
    // NPR5.31/MMV /20170316 CASE 264109 Added field 4.

    Caption = 'POS Customer Location';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Contains Sales"; Boolean)
        {
            CalcFormula = Exist ("NPR Sale POS" WHERE("Saved Sale" = CONST(true),
                                                  "Customer Location No." = FIELD("No.")));
            Caption = 'Contains Sales';
            FieldClass = FlowField;
        }
        field(4; "Total Amount"; Decimal)
        {
            CalcFormula = Sum ("NPR Sale Line POS"."Amount Including VAT" WHERE("Customer Location No." = FIELD("No.")));
            Caption = 'Total Amount';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }

    fieldgroups
    {
    }
}

