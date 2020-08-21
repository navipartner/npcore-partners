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
                field("Area"; Area)
                {
                    ApplicationArea = All;
                }
                field("Field Type"; "Field Type")
                {
                    ApplicationArea = All;
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                }
                field("Field No."; "Field No.")
                {
                    ApplicationArea = All;
                }
                field("Field Length"; "Field Length")
                {
                    ApplicationArea = All;
                }
                field(Text; Text)
                {
                    ApplicationArea = All;
                }
                field(Placeholder; Placeholder)
                {
                    ApplicationArea = All;
                }
                field("Default Value"; "Default Value")
                {
                    ApplicationArea = All;
                }
                field("Format Value"; "Format Value")
                {
                    ApplicationArea = All;
                }
                field("Field Data Type"; "Field Data Type")
                {
                    ApplicationArea = All;
                }
                field("First Responder"; "First Responder")
                {
                    ApplicationArea = All;
                }
                field("Call UI"; "Call UI")
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

