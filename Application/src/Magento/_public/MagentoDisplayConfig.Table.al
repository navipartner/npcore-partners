table 6151435 "NPR Magento Display Config"
{
    Caption = 'Magento Display Config';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Magento Display Config";
    LookupPageID = "NPR Magento Display Config";

    fields
    {
        field(10; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST(Item)) Item
            ELSE
            IF (Type = CONST("Item Group")) "NPR Magento Category"
            ELSE
            IF (Type = CONST(Brand)) "NPR Magento Brand";
        }
        field(20; Type; Enum "NPR Mag. Display Config Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(30; "Sales Code"; Text[32])
        {
            Caption = 'Sales Code';
            DataClassification = CustomerContent;
            TableRelation = IF ("Sales Type" = CONST(Customer)) Customer
            ELSE
            IF ("Sales Type" = CONST("Display Group")) "NPR Magento Display Group";
        }
        field(40; "Sales Type"; Enum "NPR Mag. Dis. Conf. Sales Type")
        {
            Caption = 'Sales Type';
            DataClassification = CustomerContent;
        }
        field(50; "Is Visible"; Boolean)
        {
            Caption = 'Is Visible';
            DataClassification = CustomerContent;
        }
        field(60; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
            DataClassification = CustomerContent;
        }
        field(70; "Starting Time"; Time)
        {
            Caption = 'Starting Time';
            DataClassification = CustomerContent;
        }
        field(80; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
            DataClassification = CustomerContent;
        }
        field(90; "Ending Time"; Time)
        {
            Caption = 'Ending Time';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "No.", Type, "Sales Code", "Sales Type", "Starting Date", "Starting Time", "Ending Date", "Ending Time")
        {
        }
    }

    trigger OnInsert()
    begin
        if "Sales Type" = "Sales Type"::"All Customers" then
            "Sales Code" := ''
        else
            TestField("Sales Code");

        TestField("No.");
    end;

    trigger OnRename()
    begin
        if "Sales Type" <> "Sales Type"::"All Customers" then
            TestField("Sales Code");

        TestField("No.");
    end;
}
