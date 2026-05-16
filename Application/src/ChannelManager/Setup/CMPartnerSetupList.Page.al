page 6150936 "NPR CMPartnerSetupList"
{
    Extensible = false;
    Caption = 'Channel Manager Partner Setup';
    PageType = List;
    SourceTable = "NPR CMPartnerSetup";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(PartnerId; Rec.PartnerId)
                {
                    ToolTip = 'Unique identifier the channel partner uses when calling the channel manager API.';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Display name for the channel partner.';
                    ApplicationArea = NPRRetail;
                }

                field(Active; Rec.Active)
                {
                    ToolTip = 'If disabled, the partner cannot create or modify orders via the API.';
                    ApplicationArea = NPRRetail;
                }

                field(NPDesignerTemplateLabel; Rec.NPDesignerTemplateLabel)
                {
                    Caption = 'Wallet Design Layout';
                    ToolTip = 'NPDesigner template used to render the per-order wallet manifest for this partner. Leave blank to skip manifest generation.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(NewPartnerId)
            {
                Caption = 'Assign New Partner Id';
                ToolTip = 'Generates a fresh GUID into the current row''s Partner Id (only works on a new row before save).';
                Image = NewItem;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.PartnerId := CreateGuid();
                end;
            }
        }
    }
}
