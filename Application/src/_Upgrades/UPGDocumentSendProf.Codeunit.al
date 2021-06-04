codeunit 6014436 "NPR UPG Document Send. Prof."
{
    Subtype = Upgrade;

    var
        PrintProfileCode: Code[20];
        EmailProfileCode: Code[20];
        PrintAndEmailProfileCode: Code[20];
        OIOProfileCode: Code[20];

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Document Send. Prof.', 'OnUpgradePerCompany');

        if UpgradeTagMgt.HasUpgradeTag(GetMagentoPassUpgradeTag()) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;
        InsertDocumentSendingProfiles();
        UpgradeCustomerDocumentSendingProfiles();
        UpgradeVendorDocumentSendingProfiles();
        UpgradeTagMgt.SetUpgradeTag(GetMagentoPassUpgradeTag());

        LogMessageStopwatch.LogFinish();
    end;

    local procedure GetMagentoPassUpgradeTag(): Text
    begin
        exit('NPR_DocumentProcessing_DocumentSendingProfile_20210222');
    end;

    local procedure InsertDocumentSendingProfiles()
    var
        DocSendProfile: Record "Document Sending Profile";
    begin
        PrintProfileCode := '';
        EmailProfileCode := '';
        PrintAndEmailProfileCode := '';
        OIOProfileCode := '';

        if not HaveEmailProfile(DocSendProfile) then begin
            DocSendProfile.Init();
            DocSendProfile.Code := NprEmailLbl;
            DocSendProfile."E-Mail" := DocSendProfile."E-Mail"::"Yes (Prompt for Settings)";
            DocSendProfile."E-Mail Attachment" := DocSendProfile."E-Mail Attachment"::PDF;
            DocSendProfile.Insert(true);
        end; 
        EmailProfileCode := DocSendProfile.Code;

        if not HavePrintProfile(DocSendProfile) then begin
            DocSendProfile.Init();
            DocSendProfile.Code := NprPrintLbl;
            DocSendProfile.Printer := DocSendProfile.Printer::"Yes (Prompt for Settings)";
            DocSendProfile.Insert(true);
        end;
        PrintProfileCode := DocSendProfile.Code;

        if not HavePrintAndEmailProfile(DocSendProfile) then begin
            DocSendProfile.Code := NprPrintAndEmailLbl;
            DocSendProfile.Printer := DocSendProfile.Printer::"Yes (Prompt for Settings)";
            DocSendProfile."E-Mail" := DocSendProfile."E-Mail"::"Yes (Prompt for Settings)";
            DocSendProfile."E-Mail Attachment" := DocSendProfile."E-Mail Attachment"::PDF;
            DocSendProfile.Insert(true);
        end;
        PrintAndEmailProfileCode := DocSendProfile.Code;

        if DocSendProfile.Get('OIOUBL') then
            OIOProfileCode := DocSendProfile.Code;
    end;

    local procedure UpgradeCustomerDocumentSendingProfiles()
    var
        Customer: Record Customer;
    begin
        if Customer.FindSet(true) then
            repeat
                case Customer."NPR Document Processing" of
                    Customer."NPR Document Processing"::Print:
                        if PrintProfileCode <> '' then begin
                            Customer."Document Sending Profile" := PrintProfileCode;
                            Customer.Modify();
                        end;
                    Customer."NPR Document Processing"::Email:
                        if EmailProfileCode <> '' then begin
                            Customer."Document Sending Profile" := EmailProfileCode;
                            Customer.Modify();
                        end;
                    Customer."NPR Document Processing"::OIO:
                        if OIOProfileCode <> '' then begin
                            Customer."Document Sending Profile" := OIOProfileCode;
                            Customer.Modify();
                        end;
                    Customer."NPR Document Processing"::PrintAndEmail:
                        if PrintAndEmailProfileCode <> '' then begin
                            Customer."Document Sending Profile" := PrintAndEmailProfileCode;
                            Customer.Modify();
                        end;
                end;
            until Customer.Next() = 0;
    end;

    local procedure UpgradeVendorDocumentSendingProfiles()
    var
        Vendor: Record Vendor;
    begin
        if Vendor.FindSet(true) then
            repeat
                case Vendor."NPR Document Processing" of
                    Vendor."NPR Document Processing"::Print:
                        if PrintProfileCode <> '' then begin
                            Vendor."Document Sending Profile" := PrintProfileCode;
                            Vendor.Modify();
                        end;
                    Vendor."NPR Document Processing"::Email:
                        if EmailProfileCode <> '' then begin
                            Vendor."Document Sending Profile" := EmailProfileCode;
                            Vendor.Modify();
                        end;
                    Vendor."NPR Document Processing"::OIO:
                        if OIOProfileCode <> '' then begin
                            Vendor."Document Sending Profile" := OIOProfileCode;
                            Vendor.Modify();
                        end;
                    Vendor."NPR Document Processing"::PrintAndEmail:
                        if PrintAndEmailProfileCode <> '' then begin
                            Vendor."Document Sending Profile" := PrintAndEmailProfileCode;
                            Vendor.Modify();
                        end;
                end;
            until Vendor.Next() = 0;
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