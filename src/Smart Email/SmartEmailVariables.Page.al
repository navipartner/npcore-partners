page 6059823 "NPR Smart Email Variables"
{
    // NPR5.38/THRO/20171018 CASE 286713 Object created
    // NPR5.55/THRO/20200511 CASE 343266 Added "Variable Type"

    Caption = 'Smart Email Variables';
    PageType = ListPart;
    UsageCategory = Administration;
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
                }
                field("Variable Type"; "Variable Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Field No."; "Field No.")
                {
                    ApplicationArea = All;

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
                }
                field("Const Value"; "Const Value")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

