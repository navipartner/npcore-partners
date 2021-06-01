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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Certification No. field';
                }
                field("Certification Category"; Rec."Certification Category")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Certification Category field';
                }
                field("Signing Certificate Password"; Rec."Signing Certificate Password")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Signing Certificate Password field';
                }
                field("Signing Certificate Thumbprint"; Rec."Signing Certificate Thumbprint")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Signing Certificate Thumbprint field';
                }
                field("Monthly Workshift Duration"; Rec."Monthly Workshift Duration")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Monthly Workshift Duration field';
                }
                field("Yearly Workshift Duration"; Rec."Yearly Workshift Duration")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Yearly Workshift Duration field';
                }
                field("Last Auto Archived Workshift"; Rec."Last Auto Archived Workshift")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Last Auto Archived Workshift field';
                }
                field("Auto Archive URL"; Rec."Auto Archive URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto Archive URL field';
                }
                field("Auto Archive API Key"; Rec."Auto Archive API Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto Archive API Key field';
                }
                field("Auto Archive SAS"; Rec."Auto Archive SAS")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto Archive SAS field';
                }
                field("Item VAT Identifier Filter"; Rec."Item VAT Identifier Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item VAT Identifier Filter field';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Upload Certificate action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Initialize JET action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Log Partner Modification action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Unit No. Series Setup action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the POS Entry Related Info List action';
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