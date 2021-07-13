page 6014621 "NPR All Objects Select"
{
    Caption = 'All Objects';
    DataCaptionFields = "Object Type";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = AllObj;
    SourceTableTemporary = true;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Object Type"; Rec."Object Type")
                {

                    Caption = 'Object Type';
                    ToolTip = 'Specifies the type of the object.';
                    ApplicationArea = NPRRetail;
                }
                field("Object ID"; Rec."Object ID")
                {

                    Caption = 'Object ID';
                    ToolTip = 'Specifies the ID of the object.';
                    ApplicationArea = NPRRetail;
                }
                field("Object Name"; Rec."Object Name")
                {

                    Caption = 'Object Name';
                    ToolTip = 'Specifies the name of the object.';
                    ApplicationArea = NPRRetail;
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
