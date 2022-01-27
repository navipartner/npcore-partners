table 6060153 "NPR Event Attribute Template"
{
    Access = Internal;
    Caption = 'Event Attribute Template';
    DataClassification = CustomerContent;
    LookupPageID = "NPR Event Attribute Templ.";

    fields
    {
        field(1; Name; Code[20])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Row Template Name"; Code[20])
        {
            Caption = 'Row Template Name';
            DataClassification = CustomerContent;
            TableRelation = "NPR Event Att. Row Templ.";

            trigger OnValidate()
            begin
                if "Row Template Name" <> xRec."Row Template Name" then
                    EventAttrMgt.TemplateHasEntries(2, Name);
            end;
        }
        field(30; "Column Template Name"; Code[20])
        {
            Caption = 'Column Template Name';
            DataClassification = CustomerContent;
            TableRelation = "NPR Event Attr. Col. Template";

            trigger OnValidate()
            begin
                if "Column Template Name" <> xRec."Column Template Name" then
                    EventAttrMgt.TemplateHasEntries(2, Name);
            end;
        }
    }

    keys
    {
        key(Key1; Name)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Name, Description, "Row Template Name", "Column Template Name")
        {
        }
    }

    trigger OnDelete()
    begin
        EventAttrMgt.TemplateHasEntries(2, Name);
    end;

    var
        EventAttrMgt: Codeunit "NPR Event Attribute Mgt.";
}

