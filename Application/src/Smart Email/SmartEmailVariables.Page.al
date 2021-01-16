page 6059823 "NPR Smart Email Variables"
{
    // NPR5.38/THRO/20171018 CASE 286713 Object created
    // NPR5.55/THRO/20200511 CASE 343266 Added "Variable Type"

    UsageCategory = None;
    Caption = 'Smart Email Variables';
    PageType = ListPart;
    SourceTable = "NPR Smart Email Variable";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Variable Name"; "Variable Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variable Name field';
                }
                field("Variable Type"; "Variable Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Variable Type field';
                }
                field("Field No."; "Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field No. field';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        "Field": Record "Field";
                        TableFilter: Record "Table Filter";
                        FieldsLookup: Page "Fields Lookup";
                    begin
                        Field.SetRange(TableNo, "Merge Table ID");
                        FieldsLookup.SetTableView(Field);
                        FieldsLookup.LookupMode(true);

                        if FieldsLookup.RunModal = ACTION::LookupOK then begin
                            FieldsLookup.GetRecord(Field);
                            Validate("Field No.", Field."No.");
                        end;
                    end;
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Name field';
                }
                field("Const Value"; "Const Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Const Value field';
                }
            }
        }
    }

    actions
    {
    }
}

