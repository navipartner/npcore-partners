table 6150667 "NPRE Print Template"
{
    // NPR5.41/THRO/20180412 CASE 309873 Table created

    Caption = 'NPRE Print Template';
    DrillDownPageID = "NPRE Print Templates Subpage";
    LookupPageID = "NPRE Print Templates Subpage";

    fields
    {
        field(1;"Print Type";Option)
        {
            Caption = 'Print Type';
            OptionCaption = 'Kitchen,Pre Receipt';
            OptionMembers = Kitchen,"Pre Receipt";
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
    }

    keys
    {
        key(Key1;"Print Type","Seating Location","Template Code")
        {
        }
    }

    fieldgroups
    {
    }
}

