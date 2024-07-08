page 6151475 "NPR NpIa ItemAddOn Lot Nos."
{
    Caption = 'Insert Lot No.';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    UsageCategory = Administration;
    SourceTable = "NPR NpIa Item AddOn Line";
    ApplicationArea = NPRRetail;

    layout
    {
        area(Content)
        {
            field(Control6014406; '')
            {

                CaptionClass = Format(GenerateInstructions());
                Editable = false;
                MultiLine = true;
                ShowCaption = false;
                ToolTip = 'Specifies the value of the '''' field';
                ApplicationArea = NPRRetail;
            }
            repeater(Group)
            {
                field("Item No."; Rec."Item No.")
                {

                    Editable = false;
                    ToolTip = 'Specifies the number of an item.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    Editable = false;
                    ToolTip = 'Specifies a description of the entry of the product transferred from item add-on line option.';
                    ApplicationArea = NPRRetail;
                }
                field("Lot No."; Rec."Lot No.")
                {

                    ToolTip = 'Specifies the Lot No. of the item on the line.';
                    ApplicationArea = NPRRetail;

                }
                field("Description 2"; Rec."Description 2")
                {

                    ToolTip = 'Specifies an additional description of the entry of the product.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field(Quantity; Rec.Quantity)
                {

                    Editable = false;
                    ToolTip = 'Specifies how many units are being sold.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        Ok: Boolean;
    begin
        if CloseAction = ACTION::LookupOK then begin
            Rec.SetRange("Lot No.", '');
            Ok := Rec.IsEmpty();
            Rec.SetRange("Lot No.");
            if not Ok then
                Message(LotIsRequiredMsg);
        end else
            Ok := true;
        exit(Ok);
    end;

    var
        InstructionTxt: Label 'Some of the Item Add-Ons require a Lot No. to be specified. Please fill in the serial nos. in each of the following lines';
        LotIsRequiredMsg: Label 'Lot No. must be specified in all lines.';

    local procedure GenerateInstructions(): Text
    begin
        exit(InstructionTxt);
    end;
}