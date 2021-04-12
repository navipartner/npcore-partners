page 6059823 "NPR Smart Email Variables"
{
    Caption = 'Smart Email Variables';
    PageType = ListPart;
    SourceTable = "NPR Smart Email Variable";
    UsageCategory = None;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Variable Name"; Rec."Variable Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variable Name field';
                }
                field("Variable Type"; Rec."Variable Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Variable Type field';
                }
                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field No. field';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        "Field": Record "Field";
                        FieldsLookup: Page "Fields Lookup";
                    begin
                        Field.SetRange(TableNo, Rec."Merge Table ID");
                        FieldsLookup.SetTableView(Field);
                        FieldsLookup.LookupMode(true);

                        if FieldsLookup.RunModal() = ACTION::LookupOK then begin
                            FieldsLookup.GetRecord(Field);
                            Rec.Validate("Field No.", Field."No.");
                        end;
                    end;
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Name field';
                }
                field("Const Value"; Rec."Const Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Const Value field';
                }
            }
        }
    }

}

