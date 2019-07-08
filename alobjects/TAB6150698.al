table 6150698 "Audit Roll to POS Entry Link"
{
    // NPR5.36/AP  /20170420  CASE 262628  Tabel to store relation between old Audit Roll and new POS Entry during
    //                                   phase in of new data model.
    // NPR5.38/BR  /20171214  CASE 299888 Renamed from POS Ledg. Register No. to POS Period Register No. (incl. Captions)
    // NPR5.38/BR  /20180109  CASE 301600 Added option field "Item Entry Posted By" and "Posted By"

    Caption = 'Audit Roll to POS Entry Link';

    fields
    {
        field(1;"Link Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Link Entry No.';
        }
        field(2;"Audit Roll Clustered Key";Integer)
        {
            Caption = 'Audit Roll Clustered Key';
            TableRelation = "Audit Roll"."Clustered Key";
        }
        field(3;"POS Entry No.";Integer)
        {
            Caption = 'POS Entry No.';
            TableRelation = "POS Entry";
        }
        field(4;"Line Type";Option)
        {
            Caption = 'Line Type';
            OptionCaption = ' ,Sale,Payment,Balancing';
            OptionMembers = " ",Sale,Payment,Balancing;
        }
        field(5;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(10;"Link Source";Option)
        {
            Caption = 'Link Source';
            OptionCaption = 'Data Model Upgrade,Finish Sale';
            OptionMembers = "Data Model Upgrade","Finish Sale";
        }
        field(11;"Data Model Build";Integer)
        {
            Caption = 'Data Model Build';
        }
        field(12;"Upgrade Step";Integer)
        {
            Caption = 'Upgrade Step';
        }
        field(20;"POS Period Register No.";Integer)
        {
            Caption = 'POS Period Register No.';
        }
        field(21;"POS Unit No.";Code[10])
        {
            Caption = 'POS Unit No.';
            TableRelation = "POS Unit";
        }
        field(30;"Item Entry Posted By";Option)
        {
            Caption = 'Item Entry Posted By';
            Description = 'NPR5.38';
            OptionCaption = ' ,POS Entry,Audit Roll';
            OptionMembers = " ","POS Entry","Audit Roll";
        }
        field(31;"Posted By";Option)
        {
            Caption = 'Posted By';
            Description = 'NPR5.38';
            OptionCaption = ' ,POS Entry,Audit Roll';
            OptionMembers = " ","POS Entry","Audit Roll";
        }
    }

    keys
    {
        key(Key1;"Link Entry No.")
        {
        }
        key(Key2;"Audit Roll Clustered Key")
        {
        }
        key(Key3;"POS Entry No.","Line Type","Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

