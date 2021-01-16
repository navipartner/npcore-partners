page 6014609 "NPR Attribute Value Lookup"
{
    // NPR4.11/TSA/20150422 CASE209946 - Entity and Shortcut Attributes

    Caption = 'Client Attribute Value Lookup';
    DataCaptionFields = "Attribute Code";
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Attribute Lookup Value";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Attribute Code"; "Attribute Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Attribute Code field';
                }
                field("Attribute Value Code"; "Attribute Value Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Attribute Value Code field';
                }
                field("Attribute Value Name"; "Attribute Value Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Attribute Value Name field';
                }
                field("Attribute Value Description"; "Attribute Value Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Attribute Value Description field';
                }
            }
        }
    }

    actions
    {
    }
}

