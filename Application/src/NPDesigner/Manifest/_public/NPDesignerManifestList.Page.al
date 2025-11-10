page 6248202 "NPR NPDesignerManifestList"
{
    PageType = List;
    ApplicationArea = NPRRetail;
    UsageCategory = Lists;
    SourceTable = "NPR NPDesignerManifest";
    CardPageId = "NPR NPDesignerManifestCard";
    Caption = 'Designer Manifest';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field(EntryNo; Rec.EntryNo)
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                    ApplicationArea = NPRRetail;
                }
                field(ManifestId; Rec.ManifestId)
                {
                    ToolTip = 'Specifies the value of the Manifest Id field.';
                    ApplicationArea = NPRRetail;
                }
                field(MasterTemplateId; Rec.MasterTemplateId)
                {
                    ToolTip = 'Specifies the value of the Master Template Id field.';
                    ApplicationArea = NPRRetail;
                }
                field(PreferredAssetLanguage; Rec.PreferredAssetLanguage)
                {
                    ToolTip = 'Specifies the value of the Preferred Asset Language field.';
                    ApplicationArea = NPRRetail;
                }
                field(ShowTableOfContents; Rec.ShowTableOfContents)
                {
                    ToolTip = 'Specifies the value of the Show Table Of Contents field.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}