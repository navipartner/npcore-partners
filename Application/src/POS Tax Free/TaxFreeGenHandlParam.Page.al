page 6014646 "NPR Tax Free Gen. Handl. Param"
{

    Caption = 'Tax Free Handler Parameters';
    DelayedInsert = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Tax Free Handler Param.";
    SourceTableTemporary = true;
    UsageCategory = None;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Parameter; Rec.Parameter)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Parameter field';
                }
                field("Data Type"; Rec."Data Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Data Type field';
                }
                field(Value; Rec.Value)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Value field';
                }
            }
        }
    }
    procedure SetRec(var tmpHandlerParameter: Record "NPR Tax Free Handler Param." temporary)
    begin
        if not tmpHandlerParameter.IsTemporary then
            exit;

        Rec.Copy(tmpHandlerParameter, true);
    end;

    procedure GetRec(var tmpHandlerParameter: Record "NPR Tax Free Handler Param." temporary)
    begin
        if not tmpHandlerParameter.IsTemporary then
            exit;

        tmpHandlerParameter.Copy(Rec, true);
    end;
}

