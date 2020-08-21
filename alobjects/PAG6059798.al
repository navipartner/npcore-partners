page 6059798 "E-mail Template Reports"
{
    // PN1.01/MH/20140731  NAV-AddOn: PDF2NAV
    //   - Refactored module from the "Mail And Document Handler" Module.
    //   - This Page contains a additional Reports to be saved and attached as PDF in connection to sending E-mail Template.
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)

    Caption = 'Additional E-mail Template Reports';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "E-mail Template Report";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Report ID"; "Report ID")
                {
                    ApplicationArea = All;
                }
                field(Filename; Filename)
                {
                    ApplicationArea = All;
                }
                field("Report Name"; "Report Name")
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

