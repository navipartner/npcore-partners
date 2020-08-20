table 6151059 "Distribution Setup"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Distribution Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Distribution Group"; Code[20])
        {
            Caption = 'Distribution Group';
            DataClassification = CustomerContent;
            TableRelation = "Distribution Group";
        }
        field(2; "Item Hiearachy"; Code[20])
        {
            Caption = 'Item Hiearachy';
            DataClassification = CustomerContent;
            TableRelation = "Item Hierarchy";
        }
        field(5; "Distribution Type"; Option)
        {
            Caption = 'Distribution Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Manual,Blocked';
            OptionMembers = Manual,Blocked;
        }
        field(10; "Create SKU Per Location"; Boolean)
        {
            Caption = 'Create SKU Per Location';
            DataClassification = CustomerContent;
        }
        field(20; "Default SKU Repl. Setup"; Boolean)
        {
            Caption = 'Default SKU Repl. Setup';
            DataClassification = CustomerContent;
        }
        field(30; "Default Value 1"; Integer)
        {
            Caption = 'Default Value 1';
            DataClassification = CustomerContent;
        }
        field(40; "Replenishment Grace Period"; DateFormula)
        {
            Caption = 'Replenishment Grace Period';
            DataClassification = CustomerContent;
        }
        field(50; "Include Variants"; Boolean)
        {
            Caption = 'Include Variants';
            DataClassification = CustomerContent;
        }
        field(60; "Required Delivery Date"; Date)
        {
            Caption = 'Required Delivery Date';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Distribution Group", "Item Hiearachy")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        DistributionHeaders: Record "Distribution Headers";
    begin
        DistributionHeaders.SetRange("Distribution Group", "Distribution Group");
        DistributionHeaders.SetRange("Item Hiearachy", "Item Hiearachy");
        DistributionHeaders.SetRange("Distribution Type", "Distribution Type");
        DistributionHeaders.DeleteAll(true);
    end;
}

