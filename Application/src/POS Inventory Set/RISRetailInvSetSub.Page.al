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
                }
                field("Location Filter"; "Location Filter")
                {
                    ApplicationArea = All;
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                }
                field("Api Url"; "Api Url")
                {
                    ApplicationArea = All;
                }
                field("Api Username"; "Api Username")
                {
                    ApplicationArea = All;
                }
                field("Api Password"; "Api Password")
                {
                    ApplicationArea = All;
                }
                field("Api Domain"; "Api Domain")
                {
                    ApplicationArea = All;
                }
                field("Processing Function"; "Processing Function")
                {
                    ApplicationArea = All;
                }
                field("Processing Codeunit ID"; "Processing Codeunit ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Processing Codeunit Name"; "Processing Codeunit Name")
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

