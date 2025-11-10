page 6248203 "NPR NPDesignerManifestCard"
{
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR NPDesignerManifest";
    Caption = 'Designer Manifest Card';
    Editable = true;

    layout
    {
        area(Content)
        {
            group(Main)
            {

                field(ManifestId; Rec.ManifestId)
                {
                    ToolTip = 'Specifies the value of the Manifest Id field.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field(MasterTemplateId; Rec.MasterTemplateId)
                {
                    ToolTip = 'Specifies the value of the Master Template Id field.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
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

            part(ManifestLines; "NPR NPDesignerManifestLine")
            {
                Caption = 'Manifest Lines';
                ApplicationArea = NPRRetail;
                SubPageLink = EntryNo = FIELD(EntryNo);
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(ViewOnline)
            {
                Caption = 'View Online';
                Image = SendAsPDF;
                ToolTip = 'Opens the manifest in a web browser.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    DesignerFacade: Codeunit "NPR NPDesignerManifestFacade";
                    ManifestUrl: Text[250];
                    CreateUrlFailed: Label 'Unable to get the manifest URL.';
                begin
                    if (not DesignerFacade.GetManifestUrl(Rec.ManifestId, ManifestUrl)) then
                        Error(CreateUrlFailed);

                    Hyperlink(ManifestUrl);
                end;
            }
        }
    }
}