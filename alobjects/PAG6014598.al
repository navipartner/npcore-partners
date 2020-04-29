page 6014598 "Managed Package Lookup"
{
    // NPR5.48/JDH /20181109 CASE 334163 Added Object Caption

    Caption = 'Managed Package Lookup';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = StandardDialog;
    SourceTable = "Managed Package Lookup";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name;Name)
                {
                }
                field(Version;Version)
                {
                }
                field(Description;Description)
                {
                }
                field(Status;Status)
                {
                }
                field(Tags;Tags)
                {
                }
            }
        }
    }

    actions
    {
    }
}

