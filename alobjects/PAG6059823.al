page 6059823 "Smart Email Variables"
{
    // NPR5.38/THRO/20171018 CASE 286713 Object created

    Caption = 'Smart Email Variables';
    PageType = ListPart;
    SourceTable = "Smart Email Variable";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Variable Name";"Variable Name")
                {
                }
                field("Field No.";"Field No.")
                {

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        "Field": Record "Field";
                        TableFilter: Record "Table Filter";
                        FieldsLookup: Page "Fields Lookup";
                    begin
                        Field.SetRange(TableNo,"Merge Table ID");
                        FieldsLookup.SetTableView(Field);
                        FieldsLookup.LookupMode(true);

                        if FieldsLookup.RunModal = ACTION::LookupOK then begin
                          FieldsLookup.GetRecord(Field);
                          Validate("Field No.",Field."No.");
                        end;
                    end;
                }
                field("Field Name";"Field Name")
                {
                }
                field("Const Value";"Const Value")
                {
                }
            }
        }
    }

    actions
    {
    }
}

