page 6014621 "NPR All Objects Select"
{
    Caption = 'All Objects';
    DataCaptionFields = "Object Type";
    Editable = false;
    PageType = List;
    SourceTable = AllObj;
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Object Type"; "Object Type")
                {
                    ApplicationArea = All;
                    Caption = 'Object Type';
                    ToolTip = 'Specifies the type of the object.';
                }
                field("Object ID"; "Object ID")
                {
                    ApplicationArea = All;
                    Caption = 'Object ID';
                    ToolTip = 'Specifies the ID of the object.';
                }
                field("Object Name"; "Object Name")
                {
                    ApplicationArea = All;
                    Caption = 'Object Name';
                    ToolTip = 'Specifies the name of the object.';
                }
            }
        }
    }
    procedure SetRec(var TempAllObj: Record AllObj)
    begin
        Rec.DeleteAll();

        if TempAllObj.FindSet() then
            repeat
                Rec := TempAllObj;
                Rec.Insert();
            until TempAllObj.Next() = 0;

        if Rec.FindSet() then;
    end;
}