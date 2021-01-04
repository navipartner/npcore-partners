page 6151087 "NPR RIS Retail Inv. Set Sub."
{
    // NPR5.40/MHA /20180320  CASE 307025 Object created - POS Inventory Set

    AutoSplitKey = true;
    Caption = 'Inventory Set Entries';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR RIS Retail Inv. Set Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Company Name"; "Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company Name field';
                }
                field("Location Filter"; "Location Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Filter field';
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enabled field';
                }
                field("Api Url"; "Api Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Api Url field';
                }
                field("Api Username"; "Api Username")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Api Username field';
                }
                field("Api Password"; "Api Password")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Api Password field';
                }
                field("Api Domain"; "Api Domain")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Api Domain field';
                }
                field("Processing Function"; "Processing Function")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing Function field';
                }
                field("Processing Codeunit ID"; "Processing Codeunit ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Processing Codeunit ID field';
                }
                field("Processing Codeunit Name"; "Processing Codeunit Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing Codeunit Name field';
                }
            }
        }
    }

    actions
    {
    }
}

