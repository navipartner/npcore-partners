page 6184850 "FR Audit Setup"
{
    // NPR5.48/MMV /20181025 CASE 318028 Created object

    Caption = 'FR Audit Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "FR Audit Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Certification No.";"Certification No.")
                {
                }
                field("Certification Category";"Certification Category")
                {
                }
                field("Signing Certificate Password";"Signing Certificate Password")
                {
                }
                field("Signing Certificate Thumbprint";"Signing Certificate Thumbprint")
                {
                    Editable = false;
                }
                field("Workshift Period Duration";"Workshift Period Duration")
                {
                }
                field("Last Auto Archived Workshift";"Last Auto Archived Workshift")
                {
                    Editable = false;
                }
                field("Auto Archive URL";"Auto Archive URL")
                {
                }
                field("Auto Archive API Key";"Auto Archive API Key")
                {
                }
                field("Auto Archive SAS";"Auto Archive SAS")
                {
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
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    FRCertificationMgt: Codeunit "FR Audit Mgt.";
                begin
                    FRCertificationMgt.ImportCertificate();
                end;
            }
            action("Initialize JET")
            {
                Caption = 'Initialize JET';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    FRCertificationMgt: Codeunit "FR Audit Mgt.";
                begin
                    FRCertificationMgt.InitializeJET();
                end;
            }
            action(LogPartnerModification)
            {
                Caption = 'Log Partner Modification';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    FRCertificationMgt: Codeunit "FR Audit Mgt.";
                begin
                    FRCertificationMgt.LogPartnerModification();
                end;
            }
            action(UnitNoSeries)
            {
                Caption = 'Unit No. Series Setup';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "FR Audit No. Series";
            }
            action(POSEntryRelatedInfo)
            {
                Caption = 'POS Entry Related Info List';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "FR POS Audit Log Aux. Info";
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
}

