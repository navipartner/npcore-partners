page 6184856 "NPR WalletTemplate"
{
    Extensible = False;
    Caption = 'Attraction Package Template';
    //ContextSensitiveHelpPage = 'docs/retail/pos_processes/reference/item_addon_ref/';
    CardPageID = "NPR WalletTemplateCard";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpIa Item AddOn";
    SourceTableView = where(WalletTemplate = CONST(true));
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the number of the involved entry or record.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the item.';
                    ApplicationArea = NPRRetail;
                }
                field(Enabled; Rec.Enabled)
                {
                    ToolTIp = 'Specifies if the current template is enabled.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

