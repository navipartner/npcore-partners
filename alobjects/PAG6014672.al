page 6014672 "Lookup Template Lines"
{
    // NPR5.20/VB/20160310 CASE 236519 Added support for configurable lookup templates.

    Caption = 'Lookup Template Lines';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Lookup Template Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Row No.";"Row No.")
                {
                }
                field("Col No.";"Col No.")
                {
                }
                field("Field No.";"Field No.")
                {
                }
                field("Field Name";"Field Name")
                {
                }
                field(Class;Class)
                {
                }
                field("Caption Type";"Caption Type")
                {
                }
                field("Caption Text";"Caption Text")
                {
                    Enabled = "Caption Type" = 0;
                }
                field("Caption Table No.";"Caption Table No.")
                {
                    Enabled = ("Caption Type" = 1) OR ("Caption Type" = 2);
                }
                field("Caption Table Name";"Caption Table Name")
                {
                }
                field("Caption Field No.";"Caption Field No.")
                {
                    Enabled = ("Caption Type" = 1) OR ("Caption Type" = 2);
                }
                field("Caption Field Name";"Caption Field Name")
                {
                }
                field("Related Table No.";"Related Table No.")
                {
                }
                field("Related Table Name";"Related Table Name")
                {
                }
                field("Related Field No.";"Related Field No.")
                {
                }
                field("Text Align";"Text Align")
                {
                }
                field("Font Size (pt)";"Font Size (pt)")
                {
                }
                field("Width (CSS)";"Width (CSS)")
                {
                }
                field("Number Format";"Number Format")
                {
                }
                field(Searchable;Searchable)
                {
                }
            }
        }
    }

    actions
    {
    }
}

