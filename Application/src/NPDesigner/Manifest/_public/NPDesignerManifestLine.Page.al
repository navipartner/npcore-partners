page 6248204 "NPR NPDesignerManifestLine"
{
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR NPDesignerManifestLine";
    Caption = 'Designer Manifest Line';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field(EntryNo; Rec.EntryNo)
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field(LineNo; Rec.LineNo)
                {
                    ToolTip = 'Specifies the value of the Line No. field.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }

                field(AssetTableNumber; Rec.AssetTableNumber)
                {
                    ToolTip = 'Specifies the value of the Asset Table Number field.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field(AssetId; Rec.AssetId)
                {
                    ToolTip = 'Specifies the value of the Asset Id field.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field(AssetPublicId; Rec.AssetPublicId)
                {
                    ToolTip = 'Specifies the value of the Asset Public Id field.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field(RenderWithTemplateId; Rec.RenderWithTemplateId)
                {
                    ToolTip = 'Specifies the value of the Render With Design Layout field.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }

                field(RenderGroup; Rec.RenderGroup)
                {
                    ToolTip = 'Specifies the value of the Group field.';
                    ApplicationArea = NPRRetail;
                    Editable = true;
                }
                field(RenderGroupOrder; Rec.RenderGroupOrder)
                {
                    ToolTip = 'Specifies the value of the Render Order field.';
                    ApplicationArea = NPRRetail;
                    Editable = true;
                }
            }
        }
    }
}