table 6059781 "NPR Sales Price Maint. Setup"
{
    Caption = 'Sales Price Maintenance Setup';
    DrillDownPageID = "NPR Sales Price Maint. Setup";
    LookupPageID = "NPR Sales Price Maint. Setup";
    DataClassification = CustomerContent;

    fields
    {
        field(1; Id; Integer)
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
        }
        field(10; "Sales Code"; Code[20])
        {
            Caption = 'Sales Code';
            TableRelation = IF ("Sales Type" = CONST("Customer Price Group")) "Customer Price Group"
            ELSE
            IF ("Sales Type" = CONST(Customer)) Customer
            ELSE
            IF ("Sales Type" = CONST(Campaign)) Campaign;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(11; "Sales Type"; Option)
        {
            Caption = 'Sales Type';
            OptionCaption = 'Customer,Customer Price Group,All Customers,Campaign';
            OptionMembers = Customer,"Customer Price Group","All Customers",Campaign;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Sales Type" = "Sales Type"::Campaign then
                    Error(Txt003);
            end;
        }
        field(12; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(13; "Prices Including VAT"; Boolean)
        {
            Caption = 'Prices Including VAT';
            DataClassification = CustomerContent;
        }
        field(14; "Allow Invoice Disc."; Boolean)
        {
            Caption = 'Allow Invoice Disc.';
            DataClassification = CustomerContent;
        }
        field(15; "Allow Line Disc."; Boolean)
        {
            Caption = 'Allow Line Disc.';
            DataClassification = CustomerContent;
        }
        field(16; "Internal Unit Price"; Option)
        {
            Caption = 'Internal Unit Price';
            OptionCaption = 'Unit Price,Unit Cost,Standard Cost,Last Direct Cost';
            OptionMembers = "Unit Price","Unit Cost","Standard Cost","Last Direct Cost";
            DataClassification = CustomerContent;
        }
        field(17; Factor; Decimal)
        {
            Caption = 'Factor';
            DataClassification = CustomerContent;
        }
        field(18; "VAT Bus. Posting Gr. (Price)"; Code[20])
        {
            Caption = 'VAT Bus. Posting Gr. (Price)';
            TableRelation = "VAT Business Posting Group";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Sales Type" = "Sales Type"::"All Customers" then begin
                    "Sales Code" := '';
                    if not "Prices Including VAT" then begin
                        "VAT Bus. Posting Gr. (Price)" := '';
                        Message(Txt001);
                    end;
                end else begin
                    "VAT Bus. Posting Gr. (Price)" := '';
                    Message(Txt002);
                end;
            end;
        }
        field(19; "Exclude Item Groups"; Integer)
        {
            CalcFormula = Count("NPR Sales Price Maint. Groups2" WHERE(Id = FIELD(Id)));
            Caption = 'Exclude Item Groups';
            FieldClass = FlowField;
        }
        field(20; "Exclude All Item Groups"; Boolean)
        {
            Caption = 'Exclude All Item Groups';
            DataClassification = CustomerContent;
        }
        field(30; "Price List Code"; Code[20])
        {
            Caption = 'Price List Code';
            DataClassification = CustomerContent;
            TableRelation = "Price List Header";
        }
    }

    keys
    {
        key(Key1; Id)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if "Sales Type" = "Sales Type"::"All Customers" then begin
            "Sales Code" := '';
            if "Prices Including VAT" then
                TestField("VAT Bus. Posting Gr. (Price)");
        end else
            TestField("Sales Code");

        if "Sales Type" = "Sales Type"::Campaign then
            Error(Txt003);
    end;

    var
        Txt001: Label 'When using "VAT Bus. Posting Gr. (Price)" "Price Includes VAT" must be set to True';
        Txt002: Label '"Sales Type" must be set to "All Customers" when using "VAT Bus. Posting Gr. (Price)"';
        Txt003: Label '"Sales Type" Campaign is not in use';
}
