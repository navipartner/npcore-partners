table 6151422 "NPR Magento Custom Option"
{
    Caption = 'Magento Custom Option';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Magento Custom Option List";
    LookupPageID = "NPR Magento Custom Option List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; Type; Enum "NPR Magento Item Custom Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(30; Required; Boolean)
        {
            Caption = 'Required';
            DataClassification = CustomerContent;
        }
        field(40; "Max Length"; Integer)
        {
            BlankZero = true;
            Caption = 'Max Length';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(50; Position; Integer)
        {
            Caption = 'Position';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(60; Price; Decimal)
        {
            Caption = 'Price';
            DataClassification = CustomerContent;
        }
        field(70; "Price Type"; Enum "NPR Mag. Cust. Opt. Price Type")
        {
            Caption = 'Price Type';
            DataClassification = CustomerContent;
        }
        field(80; "Sales Type"; Enum "Sales Line Type")
        {
            Caption = 'Sales Type';
            DataClassification = CustomerContent;
        }
        field(90; "Sales No."; Code[20])
        {
            Caption = 'Sales No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Sales Type" = CONST(" ")) "Standard Text"
            ELSE
            IF ("Sales Type" = CONST("G/L Account")) "G/L Account"
            ELSE
            IF ("Sales Type" = CONST(Item)) Item
            ELSE
            IF ("Sales Type" = CONST(Resource)) Resource
            ELSE
            IF ("Sales Type" = CONST("Fixed Asset")) "Fixed Asset"
            ELSE
            IF ("Sales Type" = CONST("Charge (Item)")) "Item Charge";
        }
        field(100; "Price Includes VAT"; Boolean)
        {
            Caption = 'Price Includes VAT';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(107; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "No. Series";
        }
        field(1100; "Item Count"; Integer)
        {
            CalcFormula = Count("NPR Magento Item Custom Option" WHERE("Custom Option No." = FIELD("No."),
                                                                    Enabled = CONST(true)));
            Caption = 'Item Count';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }

    trigger OnDelete()
    var
        CustomOptionValue: Record "NPR Magento Custom Optn. Value";
        ItemCustomOption: Record "NPR Magento Item Custom Option";
        ItemCustomOptValue: Record "NPR Magento Itm Cstm Opt.Value";
    begin
        CustomOptionValue.SetRange("Custom Option No.", "No.");
        CustomOptionValue.DeleteAll();

        ItemCustomOption.SetRange("Custom Option No.", "No.");
        ItemCustomOption.DeleteAll();

        ItemCustomOptValue.SetRange("Custom Option No.", "No.");
        ItemCustomOptValue.DeleteAll();
    end;

    trigger OnInsert()
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        InitNoSeries();
        if "No." = '' then begin
            NoSeriesMgt.InitSeries("No. Series", xRec."No. Series", Today, "No.", "No. Series");
        end;
    end;

    trigger OnRename()
    begin
        TestField("No.");
    end;

    procedure InitNoSeries(): Boolean
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if "No. Series" <> '' then
            exit;

        MagentoSetup.Get();
        MagentoSetup.TestField("Custom Options No. Series");
        "No. Series" := MagentoSetup."Custom Options No. Series";
    end;
}