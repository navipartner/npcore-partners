page 6059933 "Doc. Exchange Paths"
{
    // NPR5.25/BR /20160804 CASE 244303 Object Created
    // NPR5.26/TJ/20160812 CASE 248831 Added new fields "Electronic Format Code" and "Localization Format Code"
    // NPR5.33/BR/20170216 CASE 266527 Added field "Use Export FTP Settings"

    Caption = 'Doc. Exchange Paths';
    PageType = List;
    SourceTable = "Doc. Exchange Path";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Enabled;Enabled)
                {
                }
                field(Direction;Direction)
                {
                }
                field("Use Export FTP Settings";"Use Export FTP Settings")
                {
                }
                field(Type;Type)
                {
                }
                field("No.";"No.")
                {
                }
                field(Path;Path)
                {
                }
                field("Archive Path";"Archive Path")
                {
                }
                field("Unmatched Items Wsht. Template";"Unmatched Items Wsht. Template")
                {
                }
                field("Unmatched Items Wsht. Name";"Unmatched Items Wsht. Name")
                {
                }
                field("Autom. Create Unmatched Items";"Autom. Create Unmatched Items")
                {
                }
                field("Autom. Query Item Information";"Autom. Query Item Information")
                {
                }
                field("Electronic Format Code";"Electronic Format Code")
                {
                }
                field("Localization Format Code";"Localization Format Code")
                {
                }
            }
        }
    }

    actions
    {
    }
}

