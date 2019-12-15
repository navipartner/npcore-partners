table 6060157 "Event Attribute Column Value"
{
    // NPR5.31/NPKNAV/20170502  CASE 269162 Transport NPR5.31 - 2 May 2017
    // NPR5.33/TJ  /20170529 CASE Added delete check and Type modify check

    Caption = 'Event Attribute Column Value';

    fields
    {
        field(1;"Template Name";Code[20])
        {
            Caption = 'Template Name';
        }
        field(2;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(10;Description;Text[30])
        {
            Caption = 'Description';
        }
        field(20;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Text,Decimal';
            OptionMembers = Text,Decimal;

            trigger OnValidate()
            begin
                //-NPR5.33 [277946]
                if Type <> xRec.Type then
                  EventAttrMgt.TemplateHasEntries(1,"Template Name");
                //+NPR5.33 [277946]
            end;
        }
        field(30;"Include in Formula";Boolean)
        {
            Caption = 'Include in Formula';
        }
        field(40;Promote;Boolean)
        {
            Caption = 'Promote';
        }
    }

    keys
    {
        key(Key1;"Template Name","Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        //-NPR5.33 [277946]
        EventAttrMgt.TemplateHasEntries(1,"Template Name");
        //+NPR5.33 [277946]
    end;

    var
        EventAttrMgt: Codeunit "Event Attribute Management";
}

