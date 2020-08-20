table 6151424 "Magento Item Custom Option"
{
    // MAG1.22/TR/20160414  CASE 238563 Magento Custom Options
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.21/BHR/20190508 CASE 338087 Field 100 Price Excl. VAT

    Caption = 'Item Custom Option';
    DataClassification = CustomerContent;
    DrillDownPageID = "Magento Item Custom Options";
    LookupPageID = "Magento Item Custom Options";

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(5; "Custom Option No."; Code[20])
        {
            Caption = 'Custom Option No.';
            DataClassification = CustomerContent;
            TableRelation = "Magento Custom Option";
        }
        field(100; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
        }
        field(1010; Description; Text[50])
        {
            CalcFormula = Lookup ("Magento Custom Option".Description WHERE("No." = FIELD("Custom Option No.")));
            Caption = 'Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1020; Type; Option)
        {
            CalcFormula = Lookup ("Magento Custom Option".Type WHERE("No." = FIELD("Custom Option No.")));
            Caption = 'Type';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'TextField,,,SelectDropDown,SelectRadioButtons,SelectCheckbox,SelectMultiple';
            OptionMembers = TextField,TextArea,File,SelectDropDown,SelectRadioButtons,SelectCheckbox,SelectMultiple,Date,DateTime,Time;
        }
        field(1030; Required; Boolean)
        {
            CalcFormula = Lookup ("Magento Custom Option".Required WHERE("No." = FIELD("Custom Option No.")));
            Caption = 'Required';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1040; "Max Length"; Integer)
        {
            CalcFormula = Lookup ("Magento Custom Option"."Max Length" WHERE("No." = FIELD("Custom Option No.")));
            Caption = 'Max Length';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1050; Position; Integer)
        {
            CalcFormula = Lookup ("Magento Custom Option".Position WHERE("No." = FIELD("Custom Option No.")));
            Caption = 'Position';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1060; Price; Decimal)
        {
            CalcFormula = Lookup ("Magento Custom Option".Price WHERE("No." = FIELD("Custom Option No.")));
            Caption = 'Price';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1070; "Price Type"; Option)
        {
            CalcFormula = Lookup ("Magento Custom Option"."Sales Type" WHERE("No." = FIELD("Custom Option No.")));
            Caption = 'Price Type';
            FieldClass = FlowField;
            OptionCaption = 'Fixed,Percent';
            OptionMembers = "Fixed",Percent;
        }
        field(1100; "Enabled Option Values"; Integer)
        {
            CalcFormula = Count ("Magento Item Custom Opt. Value" WHERE("Item No." = FIELD("Item No."),
                                                                        "Custom Option No." = FIELD("Custom Option No."),
                                                                        Enabled = CONST(true)));
            Caption = 'Enabled Option Values';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1110; "Price Includes VAT"; Boolean)
        {
            CalcFormula = Lookup ("Magento Custom Option"."Price Includes VAT" WHERE("No." = FIELD("Custom Option No.")));
            Caption = 'Price Includes VAT';
            FieldClass = FlowField;
            InitValue = true;

            trigger OnValidate()
            var
                VATPostingSetup: Record "VAT Posting Setup";
                SalesSetup: Record "Sales & Receivables Setup";
            begin
            end;
        }
    }

    keys
    {
        key(Key1; "Item No.", "Custom Option No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ItemCustomOptValue: Record "Magento Item Custom Opt. Value";
    begin
        ItemCustomOptValue.SetRange("Item No.", "Item No.");
        ItemCustomOptValue.SetRange("Custom Option No.", "Custom Option No.");
        ItemCustomOptValue.DeleteAll;
    end;
}

