page 6059955 "MCS API Setup"
{
    // NPR5.29/CLVA/20170125 CASE 264333 Added fields "Image Orientation" and "Use Cognitive Services"
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption

    Caption = 'MCS API Setup';
    PageType = List;
    SourceTable = "MCS API Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(API; API)
                {
                    ApplicationArea = All;
                }
                field("Key 1"; "Key 1")
                {
                    ApplicationArea = All;
                }
                field("Key 2"; "Key 2")
                {
                    ApplicationArea = All;
                }
                field("Image Orientation"; "Image Orientation")
                {
                    ApplicationArea = All;
                }
                field("Use Cognitive Services"; "Use Cognitive Services")
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

