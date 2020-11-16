page 6014609 "NPR Attribute Value Lookup"
{
    // NPR4.11/TSA/20150422 CASE209946 - Entity and Shortcut Attributes

    Caption = 'Client Attribute Value Lookup';
    DataCaptionFields = "Attribute Code";
    PageType = List;
    UsageCategory = Administration;
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
                }
                field("Attribute Value Code"; "Attribute Value Code")
                {
                    ApplicationArea = All;
                }
                field("Attribute Value Name"; "Attribute Value Name")
                {
                    ApplicationArea = All;
                }
                field("Attribute Value Description"; "Attribute Value Description")
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

