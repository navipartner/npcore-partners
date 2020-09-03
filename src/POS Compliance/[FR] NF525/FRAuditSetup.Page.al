page 6184850 "NPR FR Audit Setup"
{
    // NPR5.48/MMV /20181025 CASE 318028 Created object
    // NPR5.51/MMV /20190611 CASE 356076 Added field 35 & action icons.

    Caption = 'FR Audit Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR FR Audit Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Certification No."; "Certification No.")
                {
                    ApplicationArea = All;
                }
                field("Certification Category"; "Certification Category")
                {
                    ApplicationArea = All;
                }
                field("Signing Certificate Password"; "Signing Certificate Password")
                {
                    ApplicationArea = All;
                }
                field("Signing Certificate Thumbprint"; "Signing Certificate Thumbprint")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Monthly Workshift Duration"; "Monthly Workshift Duration")
                {
                    ApplicationArea = All;
                }
                field("Yearly Workshift Duration"; "Yearly Workshift Duration")
                {
                    ApplicationArea = All;
                }
                field("Last Auto Archived Workshift"; "Last Auto Archived Workshift")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Auto Archive URL"; "Auto Archive URL")
                {
                    ApplicationArea = All;
                }
                field("Auto Archive API Key"; "Auto Archive API Key")
                {
                    ApplicationArea = All;
                }
                field("Auto Archive SAS"; "Auto Archive SAS")
                {
                    ApplicationArea = All;
                }
                field("Item VAT Identifier Filter"; "Item VAT Identifier Filter")
                {
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    var
                        FRAuditMgt: Codeunit "NPR FR Audit Mgt.";
                        NewFilter: Text;
                    begin
                        NewFilter := FRAuditMgt.GetItemVATIdentifierFilter("Item VAT Identifier Filter");
                        if NewFilter <> '' then
                            "Item VAT Identifier Filter" := NewFilter;
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
                PromotedCategory = Process;
                PromotedIsBig = true;

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
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
                    POSUnit: Record "NPR POS Unit";
                begin
                    //-NPR5.51 [356076]
                    if PAGE.RunModal(0, POSUnit) <> ACTION::LookupOK then
                        exit;

                    POSAuditLogMgt.InitializeLog(POSUnit."No.");
                    //+NPR5.51 [356076]
                end;
            }
            action(LogPartnerModification)
            {
                Caption = 'Log Partner Modification';
                Image = SocialSecurity;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
                    POSUnit: Record "NPR POS Unit";
                    DescriptionOut: Text[250];
                    InputDialog: Page "NPR Input Dialog";
                    ID: Integer;
                begin
                    //-NPR5.51 [356076]
                    if PAGE.RunModal(0, POSUnit) <> ACTION::LookupOK then
                        exit;

                    repeat
                        Clear(InputDialog);
                        InputDialog.LookupMode := true;
                        InputDialog.SetInput(1, DescriptionOut, CAPTION_PARTNER_MOD);
                        if InputDialog.RunModal = ACTION::LookupOK then
                            ID := InputDialog.InputText(1, DescriptionOut);
                    until (DescriptionOut <> '') or (ID = 0);
                    if (ID = 0) then
                        exit;

                    if DescriptionOut = '' then
                        exit;

                    POSAuditLogMgt.LogPartnerModification(POSUnit."No.", DescriptionOut);
                    //+NPR5.51 [356076]
                end;
            }
            action(UnitNoSeries)
            {
                Caption = 'Unit No. Series Setup';
                Image = NumberSetup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR FR Audit No. Series";
            }
            action(POSEntryRelatedInfo)
            {
                Caption = 'POS Entry Related Info List';
                Image = CoupledQuote;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR FR POS Audit Log Aux. Info";
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Get then begin
            Init;
            Insert;
        end;
    end;

    var
        CAPTION_PARTNER_MOD: Label 'Modification description';
}

