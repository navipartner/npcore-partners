table 6151422 "Magento Custom Option"
{
    // MAG1.22/TR/20160414  CASE 238563 Magento Custom Options
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.21/BHR/20190508 CASE 338087 Field 100 Price Excl. VAT

    Caption = 'Magento Custom Option';
    DataClassification = CustomerContent;
    DrillDownPageID = "Magento Custom Option List";
    LookupPageID = "Magento Custom Option List";

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
        field(20; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Text Field,,,Select Drop-Down,Select Radio Buttons,Select Checkbox,Select Multiple';
            OptionMembers = TextField,TextArea,File,SelectDropDown,SelectRadioButtons,SelectCheckbox,SelectMultiple,Date,DateTime,Time;
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
        field(70; "Price Type"; Option)
        {
            Caption = 'Price Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Fixed,Percent';
            OptionMembers = "Fixed",Percent;
        }
        field(80; "Sales Type"; Option)
        {
            Caption = 'Sales Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,G/L Account,Item,Resource,Fixed Asset,Charge (Item)';
            OptionMembers = " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)";
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

            trigger OnValidate()
            var
                VATPostingSetup: Record "VAT Posting Setup";
                SalesSetup: Record "Sales & Receivables Setup";
            begin
            end;
        }
        field(107; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "No. Series";
        }
        field(1100; "Item Count"; Integer)
        {
            CalcFormula = Count ("Magento Item Custom Option" WHERE("Custom Option No." = FIELD("No."),
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

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        CustomOptionValue: Record "Magento Custom Option Value";
        ItemCustomOption: Record "Magento Item Custom Option";
        ItemCustomOptValue: Record "Magento Item Custom Opt. Value";
    begin
        CustomOptionValue.SetRange("Custom Option No.", "No.");
        CustomOptionValue.DeleteAll;

        ItemCustomOption.SetRange("Custom Option No.", "No.");
        ItemCustomOption.DeleteAll;

        ItemCustomOptValue.SetRange("Custom Option No.", "No.");
        ItemCustomOptValue.DeleteAll;
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
        MagentoSetup: Record "Magento Setup";
    begin
        if "No. Series" <> '' then
            exit;

        MagentoSetup.Get;
        MagentoSetup.TestField("Custom Options No. Series");
        "No. Series" := MagentoSetup."Custom Options No. Series";
    end;
}

