page 6014580 "NPR Object Output Selection"
{
    Extensible = False;
    Caption = 'Print Template Output Setup';
    PageType = List;
    SourceTable = "NPR Object Output Selection";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Control6150620)
            {
                ShowCaption = false;
                field("User ID"; Rec."User ID")
                {

                    ToolTip = 'Specifies the value of the User ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Object ID"; Rec."Object ID")
                {

                    ToolTip = 'Specifies the value of the Object ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Object Name"; Rec."Codeunit Name")
                {

                    ToolTip = 'Specifies the value of the Object Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Print Template"; Rec."Print Template")
                {

                    ToolTip = 'Specifies the value of the Print Template field';
                    ApplicationArea = NPRRetail;
                }
                field("Output Type"; Rec."Output Type")
                {

                    ToolTip = 'Specifies the value of the Output Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Output Path"; Rec."Output Path")
                {

                    ToolTip = 'Specifies the value of the Output Path field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

