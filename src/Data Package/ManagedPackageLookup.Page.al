page 6014598 "NPR Managed Package Lookup"
{
    // NPR5.48/JDH /20181109 CASE 334163 Added Object Caption

    Caption = 'Managed Package Lookup';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = StandardDialog;
    SourceTable = "NPR Managed Package Lookup";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field(Version; Version)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field(Tags; Tags)
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

