table 6150656 "NPR POS Pricing Profile"
{
    Caption = 'POS Pricing Profile';
    DataClassification = CustomerContent;
    LookupPageID = "NPR POS Pricing Profiles";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Item Price Function"; Text[250])
        {
            Caption = 'Item Price Function';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                PriceCalcMgt: codeunit "NPR POS Sales Price Calc. Mgt.";
            begin
                PriceCalcMgt.SelectPublishedFunction(Rec);
            end;

            trigger OnValidate()
            var
                PriceCalcMgt: codeunit "NPR POS Sales Price Calc. Mgt.";
            begin
                PriceCalcMgt.SelectFirstSubscribedFunction(Rec);
            end;
        }
        field(21; "Item Price Codeunit ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Item Price Codeunit ID';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                PriceCalcMgt: codeunit "NPR POS Sales Price Calc. Mgt.";
            begin
                PriceCalcMgt.SelectPublishedFunction(Rec);
            end;

            trigger OnValidate()
            var
                PriceCalcMgt: codeunit "NPR POS Sales Price Calc. Mgt.";
            begin
                PriceCalcMgt.SelectFirstSubscribedFunction(Rec);
            end;
        }

        field(22; "Item Price Codeunit Name"; Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Codeunit),
                                                             "Object ID" = FIELD("Item Price Codeunit ID")));
            Caption = 'Item Price Codeunit Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(325; "Customer Disc. Group"; Code[20])
        {
            Caption = 'Customer Discount Group';
            DataClassification = CustomerContent;
            TableRelation = "Customer Discount Group";
        }
        field(328; "Customer Price Group"; Code[10])
        {
            Caption = 'Customer Price Group';
            DataClassification = CustomerContent;
            TableRelation = "Customer Price Group";
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }
}
