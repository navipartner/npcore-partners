table 6060105 "Ean Box Setup"
{
    // NPR5.32/NPKNAV/20170526  CASE 272577 Transport NPR5.32 - 26 May 2017
    // NPR5.45/MHA /20180814  CASE 319706 Reworked Identifier Dissociation to Ean Box Event Handler

    Caption = 'Ean Box Setup';
    DrillDownPageID = "Ean Box Setups";
    LookupPageID = "Ean Box Setups";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(5;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(10;"POS View";Option)
        {
            Caption = 'POS View';
            OptionCaption = 'Sale';
            OptionMembers = Sale;
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

    trigger OnDelete()
    var
        EanBoxSetupEvent: Record "Ean Box Setup Event";
    begin
        EanBoxSetupEvent.SetRange("Setup Code",Code);
        if EanBoxSetupEvent.FindFirst then
          EanBoxSetupEvent.DeleteAll;
    end;
}

