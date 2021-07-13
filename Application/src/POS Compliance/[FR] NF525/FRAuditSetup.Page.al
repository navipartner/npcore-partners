page 6184850 "NPR FR Audit Setup"
{
    Caption = 'FR Audit Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR FR Audit Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Certification No."; Rec."Certification No.")
                {

                    ToolTip = 'Specifies the value of the Certification No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Certification Category"; Rec."Certification Category")
                {

                    ToolTip = 'Specifies the value of the Certification Category field';
                    ApplicationArea = NPRRetail;
                }
                field("Signing Certificate Password"; Rec."Signing Certificate Password")
                {

                    ToolTip = 'Specifies the value of the Signing Certificate Password field';
                    ApplicationArea = NPRRetail;
                }
                field("Signing Certificate Thumbprint"; Rec."Signing Certificate Thumbprint")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Signing Certificate Thumbprint field';
                    ApplicationArea = NPRRetail;
                }
                field("Monthly Workshift Duration"; Rec."Monthly Workshift Duration")
                {

                    ToolTip = 'Specifies the value of the Monthly Workshift Duration field';
                    ApplicationArea = NPRRetail;
                }
                field("Yearly Workshift Duration"; Rec."Yearly Workshift Duration")
                {

                    ToolTip = 'Specifies the value of the Yearly Workshift Duration field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Auto Archived Workshift"; Rec."Last Auto Archived Workshift")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Last Auto Archived Workshift field';
                    ApplicationArea = NPRRetail;
                }
                field("Auto Archive URL"; Rec."Auto Archive URL")
                {

                    ToolTip = 'Specifies the value of the Auto Archive URL field';
                    ApplicationArea = NPRRetail;
                }
                field("Auto Archive API Key"; Rec."Auto Archive API Key")
                {

                    ToolTip = 'Specifies the value of the Auto Archive API Key field';
                    ApplicationArea = NPRRetail;
                }
                field("Auto Archive SAS"; Rec."Auto Archive SAS")
                {

                    ToolTip = 'Specifies the value of the Auto Archive SAS field';
                    ApplicationArea = NPRRetail;
                }
                field("Item VAT Identifier Filter"; Rec."Item VAT Identifier Filter")
                {

                    ToolTip = 'Specifies the value of the Item VAT Identifier Filter field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    var
                        FRAuditMgt: Codeunit "NPR FR Audit Mgt.";
                        NewFilter: Text;
                    begin
                        NewFilter := FRAuditMgt.GetItemVATIdentifierFilter(Rec."Item VAT Identifier Filter");
                        if NewFilter <> '' then
                            Rec."Item VAT Identifier Filter" := NewFilter;
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(UploadCertificate)
            {
                Caption = 'Upload Certificate';
                Image = ImportCodes;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Upload Certificate action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    FRCertificationMgt: Codeunit "NPR FR Audit Mgt.";
                begin
                    FRCertificationMgt.ImportCertificate();
                end;
            }
            action("Initialize JET")
            {
                Caption = 'Initialize JET';
                Image = CreateBins;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Initialize JET action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
                    POSUnit: Record "NPR POS Unit";
                begin
                    if PAGE.RunModal(0, POSUnit) <> ACTION::LookupOK then
                        exit;

                    POSAuditLogMgt.InitializeLog(POSUnit."No.");
                end;
            }
            action(LogPartnerModification)
            {
                Caption = 'Log Partner Modification';
                Image = SocialSecurity;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Log Partner Modification action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
                    POSUnit: Record "NPR POS Unit";
                    DescriptionOut: Text[250];
                    InputDialog: Page "NPR Input Dialog";
                    ID: Integer;
                begin
                    if PAGE.RunModal(0, POSUnit) <> ACTION::LookupOK then
                        exit;

                    repeat
                        Clear(InputDialog);
                        InputDialog.LookupMode := true;
                        InputDialog.SetInput(1, DescriptionOut, CAPTION_PARTNER_MOD);
                        if InputDialog.RunModal() = ACTION::LookupOK then
                            ID := InputDialog.InputText(1, DescriptionOut);
                    until (DescriptionOut <> '') or (ID = 0);
                    if (ID = 0) then
                        exit;

                    if DescriptionOut = '' then
                        exit;

                    POSAuditLogMgt.LogPartnerModification(POSUnit."No.", DescriptionOut);
                end;
            }
            action(UnitNoSeries)
            {
                Caption = 'Unit No. Series Setup';
                Image = NumberSetup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR FR Audit No. Series";

                ToolTip = 'Executes the Unit No. Series Setup action';
                ApplicationArea = NPRRetail;
            }
            action(POSEntryRelatedInfo)
            {
                Caption = 'POS Entry Related Info List';
                Image = CoupledQuote;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR FR POS Audit Log Aux. Info";

                ToolTip = 'Executes the POS Entry Related Info List action';
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;

    var
        CAPTION_PARTNER_MOD: Label 'Modification description';
}