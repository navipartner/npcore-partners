page 6014609 "NPR Attribute Value Lookup"
{
    // NPR4.11/TSA/20150422 CASE209946 - Entity and Shortcut Attributes

    Caption = 'Client Attribute Value Lookup';
    DataCaptionFields = "Attribute Code";
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Attribute Lookup Value";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Attribute Code"; Rec."Attribute Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Attribute Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Attribute Value Code"; Rec."Attribute Value Code")
                {

                    ToolTip = 'Specifies the value of the Attribute Value Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Attribute Value Name"; Rec."Attribute Value Name")
                {

                    ToolTip = 'Specifies the value of the Attribute Value Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Attribute Value Description"; Rec."Attribute Value Description")
                {

                    ToolTip = 'Specifies the value of the Attribute Value Description field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

