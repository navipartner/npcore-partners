page 6151087 "NPR RIS Retail Inv. Set Sub."
{
    UsageCategory = None;
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

                    ToolTip = 'Specifies the value of the Company Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Location Filter"; Rec."Location Filter")
                {

                    ToolTip = 'Specifies the value of the Location Filter field';
                    ApplicationArea = NPRRetail;
                }
                field(Enabled; Rec.Enabled)
                {

                    ToolTip = 'Specifies the value of the Enabled field';
                    ApplicationArea = NPRRetail;
                }
                field("Api Url"; Rec."Api Url")
                {

                    ToolTip = 'Specifies the value of the Api Url field';
                    ApplicationArea = NPRRetail;
                }
                field("Api Username"; Rec."Api Username")
                {

                    ToolTip = 'Specifies the value of the Api Username field';
                    ApplicationArea = NPRRetail;
                }
                field("Api Password"; Rec."Api Password")
                {

                    ToolTip = 'Specifies the value of the Api Password field';
                    ApplicationArea = NPRRetail;
                }
                field("Api Domain"; Rec."Api Domain")
                {

                    ToolTip = 'Specifies the value of the Api Domain field';
                    ApplicationArea = NPRRetail;
                }
                field("Processing Function"; Rec."Processing Function")
                {

                    ToolTip = 'Specifies the value of the Processing Function field';
                    ApplicationArea = NPRRetail;
                }
                field("Processing Codeunit ID"; Rec."Processing Codeunit ID")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Processing Codeunit ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Processing Codeunit Name"; Rec."Processing Codeunit Name")
                {

                    ToolTip = 'Specifies the value of the Processing Codeunit Name field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
