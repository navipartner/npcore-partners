table 6150681 "NPRE Restaurant"
{
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant

    Caption = 'Restaurant';
    DrillDownPageID = "NPRE Restaurants";
    LookupPageID = "NPRE Restaurants";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(10;Name;Text[50])
        {
            Caption = 'Name';
            Width = 50;
        }
        field(11;"Name 2";Text[50])
        {
            Caption = 'Name 2';
        }
        field(20;"Auto Send Kitchen Order";Option)
        {
            Caption = 'Auto Send Kitchen Order';
            OptionCaption = 'Default,No,Yes,Ask';
            OptionMembers = Default,No,Yes,Ask;
        }
        field(21;"Resend All On New Lines";Option)
        {
            Caption = 'Resend All On New Lines';
            OptionCaption = 'Default,No,Yes,Ask';
            OptionMembers = Default,No,Yes,Ask;
        }
        field(40;"Kitchen Printing Active";Option)
        {
            Caption = 'Kitchen Printing Active';
            OptionCaption = 'Default,No,Yes';
            OptionMembers = Default,No,Yes;
        }
        field(50;"KDS Active";Option)
        {
            Caption = 'KDS Active';
            OptionCaption = 'Default,No,Yes';
            OptionMembers = Default,No,Yes;
        }
        field(60;"Order ID Assign. Method";Option)
        {
            Caption = 'Order ID Assign. Method';
            OptionCaption = 'Default,Same for Source Document,New Each Time';
            OptionMembers = Default,"Same for Source Document","New Each Time";
        }
    }

    keys
    {
        key(Key1;Name)
        {
        }
    }

    fieldgroups
    {
    }
}

