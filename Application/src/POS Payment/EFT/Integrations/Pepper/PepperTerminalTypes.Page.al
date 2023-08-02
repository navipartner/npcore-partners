page 6184495 "NPR Pepper Terminal Types"
{
    Extensible = False;

    Caption = 'Pepper Terminal Types';
    ContextSensitiveHelpPage = 'docs/retail/eft/how-to/new_terminal_type/';
    CardPageID = "NPR Pepper Terminal Type Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Pepper Terminal Type";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(ID; Rec.ID)
                {

                    ToolTip = 'Specifies the unique number of the Pepper Terminal Type';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the Description of the Pepper Terminal Type';
                    ApplicationArea = NPRRetail;
                }
                field(Active; Rec.Active)
                {

                    ToolTip = 'Specifies whether the Pepper Terminal Type is active';
                    ApplicationArea = NPRRetail;
                }
                field(Deprecated; Rec.Deprecated)
                {

                    ToolTip = 'Specifies whether the Pepper Terminal Type is deprecated';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}