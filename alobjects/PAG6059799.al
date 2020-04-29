page 6059799 "E-mail Template Choice List"
{
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //   - Refactored module from the "Mail And Document Handler" Module.
    //   - This Page is used for displaying a List on Default Document Specific E-mail Templates during Template Creation in E-mail Setup.
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)

    Caption = 'Choose E-mail Templates';
    PageType = List;
    SourceTable = "Field";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Enabled;Enabled)
                {
                    Caption = 'Selected';
                }
                field("Field Caption";"Field Caption")
                {
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

