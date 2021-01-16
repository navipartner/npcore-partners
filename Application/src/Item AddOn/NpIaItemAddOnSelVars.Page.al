page 6151119 "NPR NpIa ItemAddOn Sel. Vars."
{
    Caption = 'Select Variants';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                ToolTip = 'Specifies the value of the '''' field';
            }
            repeater(Group)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the number of an item.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies a description of the entry of the product transferred from item add-on line option.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the variant of the item on the line.';
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies an additional description of the entry of the product.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies how many units are being sold.';
                }
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        Ok: Boolean;
    begin
        if CloseAction = ACTION::LookupOK then begin
            Rec.SetRange("Variant Code", '');
            Ok := Rec.IsEmpty();
            Rec.SetRange("Variant Code", '');
            if not Ok then
                Message(VariantIsRequiredMsg);
        end else
            Ok := true;
        exit(Ok);
    end;

    var
        InstructionTxt: Label 'Some of the Item Add-Ons require a variant code to be specified. Please fill in the variant codes in each of the following lines';
        VariantIsRequiredMsg: Label 'Variant Code must be specified in all lines.';

    local procedure GenerateInstructions(): Text
    begin
        exit(InstructionTxt);
    end;
}

