page 6151563 "NpXml Template Change History"
{
    // NC1.21/TTH/20151020 CASE 224528 New Object
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect

    Caption = 'NpXml Template Change History';
    Editable = false;
    PageType = List;
    SourceTable = "NpXml Template History";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Description;Description)
                {
                    Importance = Promoted;
                }
                field("Version Description";"Version Description")
                {
                }
                field("Template Version No.";"Template Version No.")
                {
                    Editable = false;
                }
                field("Event Type";"Event Type")
                {
                }
                field("Changed by";"Changed by")
                {
                    Editable = false;
                }
                field("Change at";"Change at")
                {
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }
}

