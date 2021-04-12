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
                field("Attribute Code"; Rec."Attribute Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Attribute Code field';
                }
                field("Attribute Value Code"; Rec."Attribute Value Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Attribute Value Code field';
                }
                field("Attribute Value Name"; Rec."Attribute Value Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Attribute Value Name field';
                }
                field("Attribute Value Description"; Rec."Attribute Value Description")
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

