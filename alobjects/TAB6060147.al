table 6060147 "MM POS Sales Info"
{
    // MM1.23/TSA /20171025 CASE 257011 Initial Version
    // #334163/JDH /20181109 CASE 334163 Added caption to object
    // MM1.36/NPKNAV/20190125  CASE 343948 Transport MM1.36 - 25 January 2019

    Caption = 'MM POS Sales Info';

    fields
    {
        field(1;"Association Type";Option)
        {
            Caption = 'Association Type';
            OptionCaption = 'Header,Line';
            OptionMembers = HEADER,LINE;
        }
        field(2;"Receipt No.";Code[20])
        {
            Caption = 'Receipt No.';
        }
        field(3;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(10;"Membership Entry No.";Integer)
        {
            Caption = 'Membership Entry No.';
        }
        field(15;"Member Entry No.";Integer)
        {
            Caption = 'Member Entry No.';
        }
        field(20;"Member Card Entry No.";Integer)
        {
            Caption = 'Member Card Entry No.';
        }
        field(30;"Scanned Card Data";Text[200])
        {
            Caption = 'Scanned Card Data';
        }
    }

    keys
    {
        key(Key1;"Association Type","Receipt No.","Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

