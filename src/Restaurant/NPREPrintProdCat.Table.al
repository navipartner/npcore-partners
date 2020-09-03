table 6150663 "NPR NPRE Print/Prod. Cat."
{
    // NPR5.34/ANEN/2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN/20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category
    //                                   - Field Code: length changed from 10 to 20 and set to NotBlank
    // NPR5.55/ALPO/20200708 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)
    //                                   - Removed field 11 "Kitchen Order Template"
    //                                   - Table renamed from "NPRE Print Category" to "NPRE Print/Prod. Category"

    Caption = 'Print/Production Category';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NPRE Slct Prnt Cat.";
    LookupPageID = "NPR NPRE Slct Prnt Cat.";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "Print Tag"; Text[100])
        {
            Caption = 'Print Tag';
            DataClassification = CustomerContent;
            TableRelation = "NPR Print Tags";
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            Description = 'NPR5.53';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
}

