table 6060106 "Ean Box Event"
{
    // NPR5.32/NPKNAV/20170526  CASE 272577 Transport NPR5.32 - 26 May 2017
    // NPR5.45/MHA /20180814  CASE 319706 Reworked Identifier Dissociation to Ean Box Event Handler

    Caption = 'Ean Box Event';
    DrillDownPageID = "Ean Box Events";
    LookupPageID = "Ean Box Events";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(5;"Module Name";Text[50])
        {
            Caption = 'Module Name';
        }
        field(10;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(15;"Action Code";Code[20])
        {
            Caption = 'Action Code';
            TableRelation = "POS Action";

            trigger OnValidate()
            var
                AllObj: Record AllObj;
                POSAction: Record "POS Action";
            begin
            end;
        }
        field(20;"Action Description";Text[250])
        {
            CalcFormula = Lookup("POS Action".Description WHERE (Code=FIELD("Action Code")));
            Caption = 'Action Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(25;"POS View";Option)
        {
            Caption = 'POS View';
            OptionCaption = 'Sale';
            OptionMembers = Sale;
        }
        field(35;"Event Codeunit";Integer)
        {
            Caption = 'Event Codeunit';
            Editable = false;
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

