page 6059794 "NPR E-mail Templ. Filters"
{
    Extensible = false;
    AutoSplitKey = true;
    Caption = 'E-mail Template Filters';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR E-mail Template Filter";
    ApplicationArea = NPRLegacyEmail;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Field No."; Rec."Field No.")
                {

                    ToolTip = 'Specifies the value of the Field No. field';
                    ApplicationArea = NPRLegacyEmail;
                }
                field("Field Name"; Rec."Field Name")
                {

                    ToolTip = 'Specifies the value of the Field Name field';
                    ApplicationArea = NPRLegacyEmail;
                }
                field(Value; Rec.Value)
                {

                    ToolTip = 'Specifies the value of the Value field';
                    ApplicationArea = NPRLegacyEmail;
                }
            }
        }
    }
}

