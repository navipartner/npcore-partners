﻿page 6184850 "NPR FR Audit Setup"
{
    Extensible = False;
    Caption = 'FR Compliance Setup';
    ContextSensitiveHelpPage = 'docs/fiscalization/france/how-to/setup/';
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
                field(FiscalVersion; FRAuditMgt.GetFiscalVersion())
                {
                    ToolTip = 'Specifies the value of the NP Retail Fiscal Version field';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    Caption = 'NPRetail Fiscal Version';
                }
                field(ComplianceVersion; FRAuditMgt.GetComplianceVersion())
                {
                    ToolTip = 'Specifies the value of the Infocert NF525 compliance targeted by current NPRetail Fiscal version';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    Caption = 'Infocert Compliance Version';
                }
                field(CertificationNumber; FRAuditMgt.GetCertificationNumber())
                {
                    ToolTip = 'Specifies the value of the NP Retail certification number';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    Caption = 'NP Retail Certification Number';
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
                field("Item VAT Identifier Filter"; VATIDFilter)
                {

                    ToolTip = 'Specifies the value of the Item VAT Identifier Filter field';
                    ApplicationArea = NPRRetail;
                    Caption = 'Item VAT Identifier Filter';
                    trigger OnValidate()
                    begin
                        Rec.SetVATIDFilter(VATIDFilter);
                        Rec.Modify();
                    end;

                    trigger OnAssistEdit()
                    var
                        FRAuditMgt: Codeunit "NPR FR Audit Mgt.";
                        NewFilter: Text;
                    begin
                        NewFilter := FRAuditMgt.GetItemVATIdentifierFilter(VATIDFilter);
                        if NewFilter <> '' then begin
                            VATIDFilter := NewFilter;
                            Rec.SetVATIDFilter(NewFilter);
                            Rec.Modify();
                        end;
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
                    DescriptionOut: Text;
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

                    POSAuditLogMgt.LogPartnerModification(POSUnit."No.", CopyStr(DescriptionOut, 1, 250));
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
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
        VATIDFilter := Rec.GetItemVATIDFilter();
    end;

    var
        FRAuditMgt: Codeunit "NPR FR Audit Mgt.";
        CAPTION_PARTNER_MOD: Label 'Modification description';
        VATIDFilter: Text;
}
