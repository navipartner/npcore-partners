table 6014455 "Shelves / Item Grp. Relation"
{
    // NPR5.38/MHA /20180104  CASE 301054 Removed non-existing Page6060077 from LookupPageID and DrillDownPageID

    Caption = 'Shelves / Item Grp. Relation';
    DataCaptionFields = Shelve;

    fields
    {
        field(1;Location;Code[10])
        {
            Caption = 'Location';
            TableRelation = Location.Code;
        }
        field(2;Shelve;Code[10])
        {
            Caption = 'Shelve';
            TableRelation = "Shoe Shelves"."No." WHERE (Location=FIELD(Location),
                                                        "No."=FIELD(Shelve));
        }
        field(3;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = ',Item Group,Vendors Item No.';
            OptionMembers = ,"Item Group","Vendors Item No.";
        }
        field(4;"No.";Code[10])
        {
            Caption = 'No.';
            TableRelation = IF (Type=CONST("Item Group")) "Item Group"."No.";
        }
    }

    keys
    {
        key(Key1;Location,Shelve,Type,"No.")
        {
        }
    }

    fieldgroups
    {
    }
}

