table 6060156 "NPR Event Attr. Row Value"
{
    Caption = 'Event Attribute Row Value';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Template Name"; Code[20])
        {
            Caption = 'Template Name';
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Sum';
            OptionMembers = " ","Sum";

            trigger OnValidate()
            begin
                if Type <> xRec.Type then
                    EventAttrMgt.TemplateHasEntries(0, "Template Name");

                if Type = Type::" " then
                    Formula := '';
            end;
        }
        field(30; Formula; Text[250])
        {
            Caption = 'Formula';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Formula <> xRec.Formula then
                    EventAttrMgt.TemplateHasEntries(0, "Template Name");
            end;
        }
        field(40; Promote; Boolean)
        {
            Caption = 'Promote';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Template Name", "Line No.")
        {
        }
    }

    trigger OnDelete()
    begin
        EventAttrMgt.TemplateHasEntries(0, "Template Name");
        EventAttrMgt.ExcludeRowFromFormula(Rec);
    end;

    trigger OnInsert()
    begin
        EventAttrMgt.TemplateHasEntries(0, "Template Name");
    end;

    var
        EventAttrMgt: Codeunit "NPR Event Attribute Mgt.";

    procedure FormulaAssistEdit()
    begin
        EventAttrMgt.RowValueFormulaAssistEdit(Rec);
    end;
}

