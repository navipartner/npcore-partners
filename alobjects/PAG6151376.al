page 6151376 "CS UI Subform"
{
    // NPR5.41/CLVA/20180313 CASE 306407 Object created - NP Capture Service
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018
    // NPR5.48/CLVA  /20181207  CASE 336403 Added field "Format Value"

    AutoSplitKey = true;
    Caption = 'CS UI Subform';
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "CS UI Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Area";Area)
                {
                }
                field("Field Type";"Field Type")
                {
                }
                field("Table No.";"Table No.")
                {
                }
                field("Field No.";"Field No.")
                {
                }
                field("Field Length";"Field Length")
                {
                }
                field(Text;Text)
                {
                }
                field(Placeholder;Placeholder)
                {
                }
                field("Default Value";"Default Value")
                {
                }
                field("Format Value";"Format Value")
                {
                }
                field("Field Data Type";"Field Data Type")
                {
                }
                field("First Responder";"First Responder")
                {
                }
                field("Call UI";"Call UI")
                {
                }
            }
        }
    }

    actions
    {
    }
}

