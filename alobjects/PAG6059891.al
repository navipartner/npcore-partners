page 6059891 "Npm Nav Field List"
{
    // NPR5.33/MHA /20170126  CASE 264348 Object created - Module: Np Page Manager

    Caption = 'Nav Field List';
    DataCaptionExpression = Format("No.") + ' ' + "Field Caption";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    SourceTable = "Field";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Selected;Selected)
                {
                    Caption = 'Selected';

                    trigger OnValidate()
                    begin
                        Mark(Selected);
                    end;
                }
                field("No.";"No.")
                {
                    Editable = false;
                }
                field(FieldName;FieldName)
                {
                    Editable = false;
                }
                field("Field Caption";"Field Caption")
                {
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        Selected := Mark;
    end;

    var
        Selected: Boolean;

    procedure FindMarked(var "Field": Record "Field")
    begin
        Clear(Field);
        Field.Copy(Rec);
        Field.MarkedOnly(true);
    end;
}

