table 6151131 "TM Seating Template"
{
    // //-TM1.45 [322432] Initial Version

    Caption = 'Seating Template';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(5;"Parent Entry No.";Integer)
        {
            Caption = 'Parent Entry No.';
        }
        field(7;Ordinal;Integer)
        {
            Caption = 'Ordinal';
        }
        field(8;Path;Text[250])
        {
            Caption = 'Path';
        }
        field(9;"Indent Level";Integer)
        {
            Caption = 'Indent Level';
        }
        field(10;Description;Text[80])
        {
            Caption = 'Description';
        }
        field(15;"Description 2";Text[80])
        {
            Caption = 'Description 2';
        }
        field(20;"Entry Type";Option)
        {
            Caption = 'Entry Type';
            OptionCaption = 'Node,Leaf';
            OptionMembers = NODE,LEAF;
        }
        field(30;Capacity;Integer)
        {
            Caption = 'Capacity';
        }
        field(40;"Reservation Category";Option)
        {
            Caption = 'Reservation Category';
            OptionCaption = ' ,Available,Blocked,Membership,External,Internal,Not Visible';
            OptionMembers = NA,AVAILABLE,BLOCKED,MEMBERSHIP,EXTERNAL,INTERNAL,HIDDEN;
        }
        field(50;"Unit Price";Decimal)
        {
            Caption = 'Unit Price';
        }
        field(60;"Admission Code";Code[20])
        {
            Caption = 'Admission Code';
            TableRelation = "TM Admission";
        }
        field(70;"Seating Code";Code[20])
        {
            Caption = 'Seating Code';
        }
        field(71;ElementId;Integer)
        {
            Caption = 'Element Id';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Admission Code",Path)
        {
        }
        key(Key3;"Parent Entry No.",Ordinal)
        {
        }
    }

    fieldgroups
    {
    }
}

