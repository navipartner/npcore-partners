table 6150663 "NPR NPRE Print/Prod. Cat."
{
    Access = Internal;
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
}
