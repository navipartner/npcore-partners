page 6014580 "NPR Object Output Selection"
{
    Extensible = False;
    Caption = 'Print Template Output Setup';
    PageType = List;
    SourceTable = "NPR Object Output Selection";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;
    ContextSensitiveHelpPage = 'docs/retail/printing/print_template_setup/';


    layout
    {
        area(content)
        {
            repeater(Control6150620)
            {
                ShowCaption = false;
                field("User ID"; Rec."User ID")
                {
                    ToolTip = 'Specifies the user';
                    ApplicationArea = NPRRetail;
                }
                field("Object ID"; Rec."Object ID")
                {
                    ToolTip = 'Specifies the codeunit id';
                    ApplicationArea = NPRRetail;
                }
                field("Object Name"; Rec."Codeunit Name")
                {
                    ToolTip = 'Specifies the codeunit name based on the selection on Codeunit ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Print Template"; Rec."Print Template")
                {
                    ToolTip = 'Specifies the print template';
                    ApplicationArea = NPRRetail;
                }
                field("Output Type"; Rec."Output Type")
                {

                    ToolTip = 'Specifies the output type';
                    ApplicationArea = NPRRetail;
                }
                field("Output Path"; Rec."Output Path")
                {
                    ToolTip = 'Specifies the output path';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

