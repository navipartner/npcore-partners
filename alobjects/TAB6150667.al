table 6150667 "NPRE Print Template"
{
    // NPR5.41/THRO/20180412 CASE 309873 Table created
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category
    //                                   - field "Print Category" added to primary key
    //                                   - field "Print Type": changed OptionString from 'Kitchen,Pre Receipt' to 'Kitchen Pre-Order,Kitchen Order,Pre Receipt'

    Caption = 'NPRE Print Template';
    DrillDownPageID = "NPRE Print Templates Subpage";
    LookupPageID = "NPRE Print Templates Subpage";

    fields
    {
        field(1;"Print Type";Option)
        {
            Caption = 'Print Type';
            OptionCaption = 'Kitchen Order,Serving Request,Pre Receipt';
            OptionMembers = "Kitchen Order","Serving Request","Pre Receipt";
        }
        field(2;"Seating Location";Code[20])
        {
            Caption = 'Seating Location';
            TableRelation = "NPRE Seating Location";
        }
        field(3;"Template Code";Code[20])
        {
            Caption = 'Template Code';
            TableRelation = "RP Template Header".Code;
        }
        field(4;"Print Category Code";Code[20])
        {
            Caption = 'Print Category Code';
            Description = 'NPR5.53';
            TableRelation = "NPRE Print Category";
        }
    }

    keys
    {
        key(Key1;"Print Type","Seating Location","Print Category Code","Template Code")
        {
        }
    }

    fieldgroups
    {
    }
}

