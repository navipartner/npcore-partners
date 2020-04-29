page 6014632 "RP Import Worksheet"
{
    // NPR5.38/MMV /20171212 CASE 294095 Created object.

    Caption = 'Import Worksheet';
    DelayedInsert = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Worksheet;
    ShowFilter = false;
    SourceTable = "RP Import Worksheet";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Template;Template)
                {
                    Editable = false;
                    StyleExpr = Style;
                    Width = 80;
                }
                field("New Template";"New Template")
                {
                    Editable = false;
                }
                field("Action";Action)
                {

                    trigger OnValidate()
                    begin
                        Style := SetStyle();
                    end;
                }
                field("Existing Version";"Existing Version")
                {
                    Editable = false;
                }
                field("Existing Description";"Existing Description")
                {
                    Editable = false;
                }
                field("Existing Last Modified At";"Existing Last Modified At")
                {
                    Editable = false;
                }
                field("New Version";"New Version")
                {
                    Editable = false;
                }
                field("New Description";"New Description")
                {
                    Editable = false;
                }
                field("New Last Modified At";"New Last Modified At")
                {
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        Style := SetStyle();
    end;

    var
        Style: Text;
}

