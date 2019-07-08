page 6059794 "E-mail Template Filters"
{
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //   - Refactored module from the "Mail And Document Handler" Module.
    //   - This Page contains Field Filters for defining detailed Link with Table Records.
    // 
    // PN1.06/TSA/20150812 CASE 220535  autosplit key was <no>, changed to yes
    // PN1.07/TTH/20151005 CASE 222376 Added the field "Field Name"
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)

    AutoSplitKey = true;
    Caption = 'E-mail Template Filters';
    PageType = List;
    SourceTable = "E-mail Template Filter";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field No.";"Field No.")
                {
                }
                field("Field Name";"Field Name")
                {
                }
                field(Value;Value)
                {
                }
            }
        }
    }

    actions
    {
    }
}

