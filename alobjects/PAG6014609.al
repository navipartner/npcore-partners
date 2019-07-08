page 6014609 "NPR Attribute Value Lookup"
{
    // NPR4.11/TSA/20150422 CASE209946 - Entity and Shortcut Attributes

    Caption = 'Client Attribute Value Lookup';
    DataCaptionFields = "Attribute Code";
    PageType = List;
    SourceTable = "NPR Attribute Lookup Value";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Attribute Code";"Attribute Code")
                {
                    Visible = false;
                }
                field("Attribute Value Code";"Attribute Value Code")
                {
                }
                field("Attribute Value Name";"Attribute Value Name")
                {
                }
                field("Attribute Value Description";"Attribute Value Description")
                {
                }
            }
        }
    }

    actions
    {
    }
}

