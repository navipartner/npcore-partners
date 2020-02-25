table 6150663 "NPRE Print Category"
{
    // NPR5.34/ANEN/2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN/20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category
    //                                   - Field Code: length changed from 10 to 20 and set to NotBlank

    Caption = 'Print Category';
    DrillDownPageID = "NPRE Print Categories";
    LookupPageID = "NPRE Print Categories";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2;"Print Tag";Text[100])
        {
            Caption = 'Print Tag';
            TableRelation = "Print Tags";
        }
        field(10;Description;Text[50])
        {
            Caption = 'Description';
            Description = 'NPR5.53';
        }
        field(11;"Kitchen Order Template";Code[20])
        {
            Caption = 'Kitchen Order Template';
            TableRelation = "RP Template Header".Code;
            ValidateTableRelation = true;
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

