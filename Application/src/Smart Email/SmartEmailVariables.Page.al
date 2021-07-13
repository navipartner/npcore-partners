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

                    ToolTip = 'Specifies the value of the Variable Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Variable Type"; Rec."Variable Type")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Variable Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Field No."; Rec."Field No.")
                {

                    ToolTip = 'Specifies the value of the Field No. field';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Specifies the value of the Field Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Const Value"; Rec."Const Value")
                {

                    ToolTip = 'Specifies the value of the Const Value field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

}

