page 6151171 "NPR NpGp Global POSSalesSetups"
{
    Caption = 'Global POS Sales Setups';
    CardPageID = "NPR NpGp POS Sales Setup Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpGp POS Sales Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Company Name"; "Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company Name field';
                }
                field("Service Url"; "Service Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Service Url field';
                }
                field("Sync POS Sales Immediately"; "Sync POS Sales Immediately")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sync POS Sales Immediately field';
                }
            }
        }
    }

    actions
    {
    }
}

