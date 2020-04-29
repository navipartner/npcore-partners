page 6014646 "Tax Free Gen. Handler Params"
{
    // NPR5.30/NPKNAV/20170310  CASE 261964 Transport NPR5.30 - 26 January 2017
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module

    Caption = 'Tax Free Handler Parameters';
    DelayedInsert = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Tax Free Handler Parameters";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Parameter;Parameter)
                {
                    Editable = false;
                }
                field("Data Type";"Data Type")
                {
                    Editable = false;
                }
                field(Value;Value)
                {
                }
            }
        }
    }

    actions
    {
    }

    procedure SetRec(var tmpHandlerParameter: Record "Tax Free Handler Parameters" temporary)
    begin
        if not tmpHandlerParameter.IsTemporary then
          exit;

        Rec.Copy(tmpHandlerParameter, true);
    end;

    procedure GetRec(var tmpHandlerParameter: Record "Tax Free Handler Parameters" temporary)
    begin
        if not tmpHandlerParameter.IsTemporary then
          exit;

        tmpHandlerParameter.Copy(Rec, true);
    end;
}

