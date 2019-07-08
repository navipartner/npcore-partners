table 6059969 "Description Control"
{
    // NPR5.29/JDH /20170105 CASE 260472 Description Control is now possible on different types of documents

    Caption = 'Description Control';
    DrillDownPageID = "Description Control";
    LookupPageID = "Description Control";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
        }
        field(10;"Setup Type";Option)
        {
            Caption = 'Setup Type';
            OptionCaption = 'Simple,Advanced';
            OptionMembers = Simple,Advanced;
        }
        field(11;"Disable Item Translations";Boolean)
        {
            Caption = 'Disable Item Translations';
        }
        field(20;"Description 1 Var (Simple)";Option)
        {
            Caption = 'Description 1 Var (Simple)';
            OptionCaption = ' ,Item Description,Item Description 2,Variant Description,Variant Description 2,Vendor Item No.';
            OptionMembers = " ",ItemDescription1,ItemDescription2,VariantDescription1,VariantDescription2,VendorItemNo;
        }
        field(21;"Description 2 Var (Simple)";Option)
        {
            Caption = 'Description 2 Var (Simple)';
            OptionCaption = ' ,Item Description,Item Description 2,Variant Description,Variant Description 2,Vendor Item No.';
            OptionMembers = " ",ItemDescription1,ItemDescription2,VariantDescription1,VariantDescription2,VendorItemNo;
        }
        field(22;"Description 1 Std (Simple)";Option)
        {
            Caption = 'Description 1 Std (Simple)';
            OptionCaption = ' ,Item Description,Item Description 2,,,Vendor Item No.';
            OptionMembers = " ",ItemDescription1,ItemDescription2,,,VendorItemNo;
        }
        field(23;"Description 2 Std (Simple)";Option)
        {
            Caption = 'Description 2 Std (Simple)';
            OptionCaption = ' ,Item Description,Item Description 2,,,Vendor Item No.';
            OptionMembers = " ",ItemDescription1,ItemDescription2,,,VendorItemNo;
        }
        field(30;"Description 1 Var (Adv)";Text[30])
        {
            Caption = 'Description 1 Var (Adv)';
        }
        field(31;"Description 2 Var (Adv)";Text[30])
        {
            Caption = 'Description 2 Var (Adv)';
        }
        field(32;"Description 1 Std (Adv)";Text[30])
        {
            Caption = 'Description 1 Std (Adv)';
        }
        field(33;"Description 2 Std (Adv)";Text[30])
        {
            Caption = 'Description 2 Std (Adv)';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }
}

