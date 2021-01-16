page 6059933 "NPR Doc. Exchange Paths"
{
    // NPR5.25/BR /20160804 CASE 244303 Object Created
    // NPR5.26/TJ/20160812 CASE 248831 Added new fields "Electronic Format Code" and "Localization Format Code"
    // NPR5.33/BR/20170216 CASE 266527 Added field "Use Export FTP Settings"

    Caption = 'Doc. Exchange Paths';
    PageType = List;
    SourceTable = "NPR Doc. Exchange Path";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enabled field';
                }
                field(Direction; Direction)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Direction field';
                }
                field("Use Export FTP Settings"; "Use Export FTP Settings")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Use Export FTP Settings field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Path; Path)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Path field';
                }
                field("Archive Path"; "Archive Path")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Archive Path field';
                }
                field("Unmatched Items Wsht. Template"; "Unmatched Items Wsht. Template")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unmatched Items Wsht. Template field';
                }
                field("Unmatched Items Wsht. Name"; "Unmatched Items Wsht. Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unmatched Items Wsht. Name field';
                }
                field("Autom. Create Unmatched Items"; "Autom. Create Unmatched Items")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Autom. Create Unmatched Items field';
                }
                field("Autom. Query Item Information"; "Autom. Query Item Information")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Autom. Query Item Information field';
                }
                field("Electronic Format Code"; "Electronic Format Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Electronic Format Code field';
                }
                field("Localization Format Code"; "Localization Format Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Localization Format Code field';
                }
            }
        }
    }

    actions
    {
    }
}

