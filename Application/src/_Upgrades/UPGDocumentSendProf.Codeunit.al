codeunit 6014436 "NPR UPG Document Send. Prof."
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        if UpgradeTagMgt.HasUpgradeTag(GetMagentoPassUpgradeTag()) then
            exit;
        InsertDocumentSendingProfiles();
        UpgradeDocumentSendingProfiles();
        UpgradeTagMgt.SetUpgradeTag(GetMagentoPassUpgradeTag());
    end;

    local procedure GetMagentoPassUpgradeTag(): Text
    begin
        exit('NPR_DocumentProcessing_DocumentSendingProfile_20210222');
    end;

    local procedure InsertDocumentSendingProfiles()
    var
        DocSendProfile: Record "Document Sending Profile";
    begin
        if not HaveEmailProfile(DocSendProfile) then begin
            DocSendProfile.Init();
            DocSendProfile.Code := NprEmailLbl;
            DocSendProfile."E-Mail" := DocSendProfile."E-Mail"::"Yes (Prompt for Settings)";
            DocSendProfile."E-Mail Attachment" := DocSendProfile."E-Mail Attachment"::PDF;
            DocSendProfile.Insert(true);
        end;
        if not HavePrintProfile(DocSendProfile) then begin
            DocSendProfile.Init();
            DocSendProfile.Code := NprPrintLbl;
            DocSendProfile.Printer := DocSendProfile.Printer::"Yes (Prompt for Settings)";
            DocSendProfile.Insert(true);
        end;
        if not HavePrintAndEmailProfile(DocSendProfile) then begin
            DocSendProfile.Code := NprPrintAndEmailLbl;
            DocSendProfile.Printer := DocSendProfile.Printer::"Yes (Prompt for Settings)";
            DocSendProfile."E-Mail" := DocSendProfile."E-Mail"::"Yes (Prompt for Settings)";
            DocSendProfile."E-Mail Attachment" := DocSendProfile."E-Mail Attachment"::PDF;
            DocSendProfile.Insert(true);
        end;
    end;

    local procedure UpgradeDocumentSendingProfiles()
    var
        CustomerVar: Record Customer;
        VendorVar: Record Vendor;
        DocSendProfile: Record "Document Sending Profile";
    begin
        CustomerVar.SetRange("Document Sending Profile", '');
        if CustomerVar.FindSet() then
            repeat
                case CustomerVar."NPR Document Processing" of
                    CustomerVar."NPR Document Processing"::Print:
                        begin
                            if HavePrintProfile(DocSendProfile) then begin
                                CustomerVar."Document Sending Profile" := DocSendProfile.Code;
                                CustomerVar.Modify();
                            end;
                        end;
                    CustomerVar."NPR Document Processing"::Email:
                        begin
                            if HaveEmailProfile(DocSendProfile) then begin
                                CustomerVar."Document Sending Profile" := DocSendProfile.Code;
                                CustomerVar.Modify();
                            end;
                        end;
                    CustomerVar."NPR Document Processing"::OIO:
                        if DocSendProfile.Get('OIOUBL') then begin
                            CustomerVar."Document Sending Profile" := DocSendProfile.Code;
                            CustomerVar.Modify();
                        end;
                    CustomerVar."NPR Document Processing"::PrintAndEmail:
                        begin
                            if HavePrintAndEmailProfile(DocSendProfile) then begin
                                CustomerVar."Document Sending Profile" := DocSendProfile.Code;
                                CustomerVar.Modify();
                            end;
                        end;
                end;
            until CustomerVar.Next() = 0;

        VendorVar.SetRange("Document Sending Profile", '');
        if VendorVar.FindSet() then
            repeat
                case VendorVar."NPR Document Processing" of
                    VendorVar."NPR Document Processing"::Print:
                        begin
                            if HavePrintProfile(DocSendProfile) then begin
                                VendorVar."Document Sending Profile" := DocSendProfile.Code;
                                VendorVar.Modify();
                            end;
                        end;
                    VendorVar."NPR Document Processing"::Email:
                        begin
                            if HaveEmailProfile(DocSendProfile) then begin
                                VendorVar."Document Sending Profile" := DocSendProfile.Code;
                                VendorVar.Modify();
                            end;
                        end;
                    VendorVar."NPR Document Processing"::OIO:
                        if DocSendProfile.Get('OIOUBL') then begin
                            VendorVar."Document Sending Profile" := DocSendProfile.Code;
                            VendorVar.Modify();
                        end;
                    VendorVar."NPR Document Processing"::PrintAndEmail:
                        begin
                            if HavePrintAndEmailProfile(DocSendProfile) then begin
                                VendorVar."Document Sending Profile" := DocSendProfile.Code;
                                VendorVar.Modify();
                            end;
                        end;
                end;
            until VendorVar.Next() = 0;
    end;

    local procedure HavePrintProfile(var DocSendProfilePar: Record "Document Sending Profile"): Boolean
    begin
        DocSendProfilePar.Reset();
        DocSendProfilePar.SetFilter(Printer, '<> %1', DocSendProfilePar.Printer::No);
        DocSendProfilePar.SetFilter("E-Mail", '= %1', DocSendProfilePar."E-Mail"::No);
        DocSendProfilePar.SetFilter(Disk, '= %1', DocSendProfilePar.Disk::No);
        DocSendProfilePar.SetFilter("Electronic Document", '= %1', DocSendProfilePar."Electronic Document"::No);
        if DocSendProfilePar.FindFirst() then
            exit(true);
        exit(false);
    end;

    local procedure HaveEmailProfile(var DocSendProfilePar: Record "Document Sending Profile"): Boolean
    begin
        DocSendProfilePar.Reset();
        DocSendProfilePar.SetFilter(Printer, '= %1', DocSendProfilePar.Printer::No);
        DocSendProfilePar.SetFilter("E-Mail", '<> %1', DocSendProfilePar."E-Mail"::No);
        DocSendProfilePar.SetFilter(Disk, '= %1', DocSendProfilePar.Disk::No);
        DocSendProfilePar.SetFilter("Electronic Document", '= %1', DocSendProfilePar."Electronic Document"::No);
        if DocSendProfilePar.FindFirst() then
            exit(true);
        exit(false);
    end;

    local procedure HavePrintAndEmailProfile(var DocSendProfilePar: Record "Document Sending Profile"): Boolean
    begin
        DocSendProfilePar.Reset();
        DocSendProfilePar.SetFilter(Printer, '<> %1', DocSendProfilePar.Printer::No);
        DocSendProfilePar.SetFilter("E-Mail", '<> %1', DocSendProfilePar."E-Mail"::No);
        DocSendProfilePar.SetFilter(Disk, '= %1', DocSendProfilePar.Disk::No);
        DocSendProfilePar.SetFilter("Electronic Document", '= %1', DocSendProfilePar."Electronic Document"::No);
        if DocSendProfilePar.FindFirst() then
            exit(true);
        exit(false);
    end;

    var
        NprPrintLbl: Label 'PRINT NPR';
        NprEmailLbl: Label 'EMAIL NPR';
        NprPrintAndEmailLbl: Label 'PRINT AND EMAIL NPR';
}