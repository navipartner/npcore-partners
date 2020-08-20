table 6060156 "Event Attribute Row Value"
{
    // NPR5.31/NPKNAV/20170502  CASE 269162 Transport NPR5.31 - 2 May 2017
    // NPR5.33/TJ  /20170529 CASE 277946 Added delete check and Type/Formula modify checks
    // NPR5.38/TJ  /20171023 CASE 291965 Insert is also not possible if template has entries

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
                //-NPR5.33 [277946]
                if Type <> xRec.Type then
                    EventAttrMgt.TemplateHasEntries(0, "Template Name");
                //+NPR5.33 [277946]

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
                //-NPR5.33 [277946]
                if Formula <> xRec.Formula then
                    EventAttrMgt.TemplateHasEntries(0, "Template Name");
                //+NPR5.33 [277946]
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

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        //-NPR5.33 [277946]
        EventAttrMgt.TemplateHasEntries(0, "Template Name");
        EventAttrMgt.ExcludeRowFromFormula(Rec);
        //+NPR5.33 [277946]
    end;

    trigger OnInsert()
    begin
        //-NPR5.38 [291965]
        EventAttrMgt.TemplateHasEntries(0, "Template Name");
        //+NPR5.38 [291965]
    end;

    var
        EventAttrMgt: Codeunit "Event Attribute Management";

    procedure FormulaAssistEdit()
    begin
        EventAttrMgt.RowValueFormulaAssistEdit(Rec);
    end;
}

