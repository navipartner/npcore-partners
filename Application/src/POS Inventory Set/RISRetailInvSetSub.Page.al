page 6151087 "NPR RIS Retail Inv. Set Sub."
{
    AutoSplitKey = true;
    Caption = 'Inventory Set Entries';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "NPR RIS Retail Inv. Set Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company Name field';
                }
                field("Location Filter"; Rec."Location Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Filter field';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enabled field';
                }
                field("Api Url"; Rec."Api Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Api Url field';
                }
                field("Api Username"; Rec."Api Username")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Api Username field';
                }
                field("Api Password"; Rec."Api Password")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Api Password field';
                }
                field("Api Domain"; Rec."Api Domain")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Api Domain field';
                }
                field("Processing Function"; Rec."Processing Function")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing Function field';
                }
                field("Processing Codeunit ID"; Rec."Processing Codeunit ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Processing Codeunit ID field';
                }
                field("Processing Codeunit Name"; Rec."Processing Codeunit Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing Codeunit Name field';
                }
            }
        }
    }
}