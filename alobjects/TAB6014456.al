table 6014456 "Product / Button  Images"
{
    // NPR5.38/MHA /20180104  CASE 301054 Removed non-existing Page6014650 from LookupPageID

    Caption = 'Product / Button  Images';

    fields
    {
        field(1;Purpose;Option)
        {
            Caption = 'Purpose';
            OptionCaption = 'Item,Sales line,Purchase line,sale,Touch Screen,Gift Voucher';
            OptionMembers = Item,"Sales line","Purchase line",Sale,"Touch Screen","Gift Voucher";
        }
        field(2;"No.";Code[30])
        {
            Caption = 'No.';
            TableRelation = IF (Purpose=FILTER(<>"Touch Screen"&<>"Gift Voucher")) Item;
        }
        field(3;Image;BLOB)
        {
            Caption = 'Image';
            SubType = Bitmap;
        }
        field(4;Height;Integer)
        {
            Caption = 'Height';
        }
        field(5;Width;Integer)
        {
            Caption = 'Width';
        }
        field(6;Description;Text[50])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1;Purpose,"No.")
        {
        }
    }

    fieldgroups
    {
    }
}

