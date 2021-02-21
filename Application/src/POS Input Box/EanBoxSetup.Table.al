table 6060105 "NPR Ean Box Setup"
{

    Caption = 'Ean Box Setup';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Input Box Setups";
    LookupPageID = "NPR POS Input Box Setups";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(5; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "POS View"; Option)
        {
            Caption = 'POS View';
            DataClassification = CustomerContent;
            OptionCaption = 'Sale';
            OptionMembers = Sale;
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

    trigger OnDelete()
    var
        EanBoxSetupEvent: Record "NPR Ean Box Setup Event";
    begin
        EanBoxSetupEvent.SetRange("Setup Code", Code);
        if EanBoxSetupEvent.FindFirst then
            EanBoxSetupEvent.DeleteAll;
    end;
}

