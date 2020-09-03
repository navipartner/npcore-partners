table 6060153 "NPR Event Attribute Template"
{
    // NPR5.31/NPKNAV/20170502  CASE 269162 Transport NPR5.31 - 2 May 2017
    // NPR5.33/TJ  /20170529 CASE 277946 Additional checks for delete and changing row/column template

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
                //-NPR5.33 [277946]
                if "Row Template Name" <> xRec."Row Template Name" then
                    EventAttrMgt.TemplateHasEntries(2, Name);
                //+NPR5.33 [277946]
            end;
        }
        field(30; "Column Template Name"; Code[20])
        {
            Caption = 'Column Template Name';
            DataClassification = CustomerContent;
            TableRelation = "NPR Event Attr. Col. Template";

            trigger OnValidate()
            begin
                //-NPR5.33 [277946]
                if "Column Template Name" <> xRec."Column Template Name" then
                    EventAttrMgt.TemplateHasEntries(2, Name);
                //+NPR5.33 [277946]
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
        //-NPR5.33 [277946]
        EventAttrMgt.TemplateHasEntries(2, Name);
        //+NPR5.33 [277946]
    end;

    var
        EventAttrMgt: Codeunit "NPR Event Attribute Mgt.";
}

