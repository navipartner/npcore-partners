page 6059793 "E-mail Template Subform"
{
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //   - Refactored module from the "Mail And Document Handler" Module.
    //   - This Page contains the e-mail body lines connected to the PDF2NAV E-mail Template.
    // PN1.05/MH/20141020  NAV-AddOn: PDF2NAV
    //   - Added AutoSplitKey.
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)

    AutoSplitKey = true;
    Caption = 'E-mail Template Subform';
    PageType = ListPart;
    SourceTable = "E-mail Template Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Mail Body Line"; "Mail Body Line")
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

