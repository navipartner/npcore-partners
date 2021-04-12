page 6014598 "NPR Managed Package Lookup"
{
    // NPR5.48/JDH /20181109 CASE 334163 Added Object Caption

    Caption = 'Managed Package Lookup';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = StandardDialog;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Managed Package Lookup";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(Version; Rec.Version)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Version field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field(Tags; Rec.Tags)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tags field';
                }
            }
        }
    }

    actions
    {
    }
}

