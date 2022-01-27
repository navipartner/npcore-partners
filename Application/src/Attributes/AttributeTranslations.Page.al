page 6014606 "NPR Attribute Translations"
{
    Extensible = False;
    // NPR4.11/TSA/20150422 CASE209946 - Entity and Shortcut Attributes

    Caption = 'Client Attribute Translations';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Attribute Translation";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Attribute Code"; Rec."Attribute Code")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Attribute Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Language ID"; Rec."Language ID")
                {

                    ToolTip = 'Specifies the value of the Language ID field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Code Caption"; Rec."Code Caption")
                {

                    ToolTip = 'Specifies the value of the Code Caption field';
                    ApplicationArea = NPRRetail;
                }
                field("Filter Caption"; Rec."Filter Caption")
                {

                    ToolTip = 'Specifies the value of the Filter Caption field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

