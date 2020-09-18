page 6059799 "NPR E-mail Templ. Choice List"
{
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //   - Refactored module from the "Mail And Document Handler" Module.
    //   - This Page is used for displaying a List on Default Document Specific E-mail Templates during Template Creation in E-mail Setup.
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)

    Caption = 'Choose E-mail Templates';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "Field";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                    Caption = 'Selected';
                }
                field("Field Caption"; "Field Caption")
                {
                    ApplicationArea = All;
                    Caption = 'E-mail Template';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }
}

