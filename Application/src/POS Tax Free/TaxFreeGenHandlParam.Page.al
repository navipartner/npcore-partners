page 6014646 "NPR Tax Free Gen. Handl. Param"
{
    // NPR5.30/NPKNAV/20170310  CASE 261964 Transport NPR5.30 - 26 January 2017
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module

    Caption = 'Tax Free Handler Parameters';
    DelayedInsert = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Tax Free Handler Param.";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Parameter; Parameter)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Parameter field';
                }
                field("Data Type"; "Data Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Data Type field';
                }
                field(Value; Value)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Value field';
                }
            }
        }
    }

    actions
    {
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

