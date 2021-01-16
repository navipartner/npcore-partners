page 6151305 "NPR NpEc Customer Mapping"
{
    // NPR5.53/MHA /20191205  CASE 380837 Object created - NaviPartner General E-Commerce

    Caption = 'Np E-commerce Customer Mapping';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR NpEc Customer Mapping";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Store Code"; "Store Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Store Code field';
                }
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country/Region Code field';
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Code field';
                }
                field("Config. Template Code"; "Config. Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Config. Template Code field';
                }
                field("Country/Region Name"; "Country/Region Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country/Region Code field';
                }
                field(City; City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the City field';
                }
            }
        }
    }

    actions
    {
    }
}

