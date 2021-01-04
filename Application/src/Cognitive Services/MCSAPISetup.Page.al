page 6059955 "NPR MCS API Setup"
{
    // NPR5.29/CLVA/20170125 CASE 264333 Added fields "Image Orientation" and "Use Cognitive Services"
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption

    Caption = 'MCS API Setup';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR MCS API Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(API; API)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the API field';
                }
                field("Key 1"; "Key 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Key 1 field';
                }
                field("Key 2"; "Key 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Key 2 field';
                }
                field("Image Orientation"; "Image Orientation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Image Orientation field';
                }
                field("Use Cognitive Services"; "Use Cognitive Services")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Use Cognitive Services field';
                }
            }
        }
    }

    actions
    {
    }
}

