page 6151054 "POS Payment View Event Setup"
{
    // NPR5.51/MHA /20190723  CASE 351688 Object created
    // NPR5.51/MHA /20190823  CASE 359601 Added field 80 "Skip Popup on Dimension Value"

    Caption = 'POS Payment View Event Setup';
    PageType = Card;
    SourceTable = "POS Payment View Event Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Dimension Popup Enabled";"Dimension Popup Enabled")
                {
                }
                field("Dimension Code";"Dimension Code")
                {
                }
                field("Popup per";"Popup per")
                {
                }
                field("Popup every";"Popup every")
                {
                }
                field("Popup Start Time";"Popup Start Time")
                {
                }
                field("Popup End Time";"Popup End Time")
                {
                }
                field("Popup Mode";"Popup Mode")
                {
                }
                field("Create New Dimension Values";"Create New Dimension Values")
                {
                }
                field("Skip Popup on Dimension Value";"Skip Popup on Dimension Value")
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("POS Payment View Log Entries")
            {
                Caption = 'POS Payment View Log Entries';
                Image = History;
                RunObject = Page "POS Payment View Log Entries";
            }
            action("POS Sales Workflows")
            {
                Caption = 'POS Sales Workflows';
                Image = Setup;
                RunObject = Page "POS Sales Workflows";
            }
        }
    }

    trigger OnInit()
    begin
        if not Get then begin
          Init;
          Insert;
        end;
    end;
}

