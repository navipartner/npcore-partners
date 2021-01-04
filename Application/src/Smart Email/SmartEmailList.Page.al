page 6059821 "NPR Smart Email List"
{
    // NPR5.38/THRO/20171018 CASE 286713 Object created
    // NPR5.55/THRO/20200511 CASE 343266 Added Provider

    Caption = 'Smart Email List';
    CardPageID = "NPR Smart Email Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Smart Email";
    UsageCategory = Lists;

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
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Provider; Provider)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Provider field';
                }
                field("Merge Table ID"; "Merge Table ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Merge Table ID field';
                }
                field("Table Caption"; "Table Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Caption field';
                }
                field("Smart Email Name"; "Smart Email Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Smart Email Name field';
                }
            }
        }
    }

    actions
    {
    }
}

