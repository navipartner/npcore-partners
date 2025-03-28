﻿page 6014578 "NPR Tax Free GB Countries"
{
    Extensible = False;

    Caption = 'Tax Free GB Countries';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR Tax Free GB Country";
    UsageCategory = None;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

