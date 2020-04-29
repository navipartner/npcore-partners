page 6060085 "MCS Recommendations Lines"
{
    // NPR5.30/BR  /20170228  CASE 252646 Object Created

    Caption = 'MCS Recommendations Lines';
    Editable = false;
    PageType = List;
    SourceTable = "MCS Recommendations Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No.";"Entry No.")
                {
                    Visible = false;
                }
                field("Model No.";"Model No.")
                {
                    Visible = false;
                }
                field("Log Entry No.";"Log Entry No.")
                {
                    Visible = false;
                }
                field("Seed Item No.";"Seed Item No.")
                {
                }
                field("Table No.";"Table No.")
                {
                    Visible = false;
                }
                field("Document Type";"Document Type")
                {
                    Visible = false;
                }
                field("Document No.";"Document No.")
                {
                    Visible = false;
                }
                field("Document Line No.";"Document Line No.")
                {
                    Visible = false;
                }
                field("Register No.";"Register No.")
                {
                    Visible = false;
                }
                field("Customer No.";"Customer No.")
                {
                    Visible = false;
                }
                field("Item No.";"Item No.")
                {
                }
                field(Description;Description)
                {
                }
                field(Rating;Rating)
                {
                    AutoFormatExpression = '<precision,0:2><Standard Format,0>%';
                    AutoFormatType = 10;
                }
                field("Date Time";"Date Time")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}

