page 6151119 "NPR NpIa ItemAddOn Sel. Vars."
{
    // NPR5.54/JAKUBV/20200408  CASE 374666 Transport NPR5.54 - 8 April 2020

    Caption = 'Select Variants';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    UsageCategory = Administration;
    SourceTable = "NPR NpIa Item AddOn Line";

    layout
    {
        area(content)
        {
            field(Control6014406; '')
            {
                ApplicationArea = All;
                CaptionClass = Format(GenerateInstructions());
                Editable = false;
                MultiLine = true;
                ShowCaption = false;
            }
            repeater(Group)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        Ok: Boolean;
    begin
        if CloseAction = ACTION::LookupOK then begin
            SetRange("Variant Code", '');
            Ok := IsEmpty;
            SetRange("Variant Code", '');
            if not Ok then
                Message(VariantIsRequiredTxt);
        end else
            Ok := true;
        exit(Ok);
    end;

    var
        InstructionTxt: Label 'Some of the Item Add-Ons require a variant code to be specified. Please fill in the variant codes in each of the following lines';
        VariantIsRequiredTxt: Label 'Variant Code must be specified in all lines.';

    local procedure GenerateInstructions(): Text
    begin
        exit(InstructionTxt);
    end;
}

