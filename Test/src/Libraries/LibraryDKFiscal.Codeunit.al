codeunit 85489 "NPR Library DK Fiscal"
{
    procedure CreateDKAuditSetup(var POSUnit: Record "NPR POS Unit")
    var
        DKAuditMgt: Codeunit "NPR DK Audit Mgt.";
    begin
        CreateDKAuditSetupWithoutCertificate(POSUnit);
        DKAuditMgt.SetSigningCertificate(GetRSA3072TestCert());
    end;

    procedure StoreExistingRSA2048SigningCertificate()
    var
        DKFiscalizationSetup: Record "NPR DK Fiscalization Setup";
        DKAuditMgt: Codeunit "NPR DK Audit Mgt.";
        OutStr: OutStream;
    begin
        // Uploading a valid certificate first clears the signing key cached in the single-instance audit codeunit.
        DKAuditMgt.SetSigningCertificate(GetRSA3072TestCert());

        // Uploading a 2048-bit key asks for confirmation, which this helper cannot answer, so store the certificate the way it was stored before the key-size check existed.
        DKFiscalizationSetup.Get();
        DKFiscalizationSetup."Signing Certificate".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.Write(GetRSA2048TestCert());
        DKFiscalizationSetup."Signing Certificate Thumbprint" := GetRSA2048TestCertThumbprint();
        DKFiscalizationSetup.Modify();
    end;

    procedure CreateDKAuditSetupWithoutCertificate(var POSUnit: Record "NPR POS Unit")
    var
        DKFiscalizationSetup: Record "NPR DK Fiscalization Setup";
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        DKAuditMgt: Codeunit "NPR DK Audit Mgt.";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        LibraryPOSMasterData.CreatePOSSetup(POSSetup);
        LibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
        LibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
        LibraryPOSMasterData.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);

        POSAuditProfile.Get(POSUnit."POS Audit Profile");
        POSAuditProfile."Audit Handler" := DKAuditMgt.HandlerCode();
        POSAuditProfile."Audit Log Enabled" := true;
        POSAuditProfile.Modify();

        if not DKFiscalizationSetup.Get() then begin
            DKFiscalizationSetup.Init();
            DKFiscalizationSetup.Insert();
        end;
        DKFiscalizationSetup."Enable DK Fiscal" := true;
        DKFiscalizationSetup."Signing Certificate Password" := GetTestCertPassword();
        // Test isolation is per codeunit, so clear the certificate an earlier test in the same codeunit may have stored.
        Clear(DKFiscalizationSetup."Signing Certificate");
        DKFiscalizationSetup."Signing Certificate Thumbprint" := '';
        DKFiscalizationSetup.Modify();
    end;

    procedure GetRSA3072TestCert(): Text
    begin
        // Self-signed test certificate with a 3072-bit RSA key, the key size Skattestyrelsen requires.
        exit('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');
    end;

    procedure GetRSA2048TestCert(): Text
    begin
        // Self-signed test certificate with a 2048-bit RSA key, which Skattestyrelsen does not accept.
        exit('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');
    end;

    procedure GetECTestCert(): Text
    begin
        // Self-signed test certificate with an EC P-256 key, which is not RSA.
        exit('MIIEbAIBAzCCBCIGCSqGSIb3DQEHAaCCBBMEggQPMIIECzCCAroGCSqGSIb3DQEHBqCCAqswggKnAgEAMIICoAYJKoZIhvcNAQcBMF8GCSqGSIb3DQEFDTBSMDEGCSqGSIb3DQEFDDAkBBDfFRkrTuzQkwVCydU6KM3SAgIIADAMBggqhkiG9w0CCQUAMB0GCWCGSAFlAwQBKgQQGbAb8I0OJUHlAbzbDWnwMYCCAjD5ae5niA1SgopUQlfN9wtwzR4OiB1w/zmTsL5bPB2mOWVPClq1ORx0kmlkY375Zs3nAtxNbJAlnAvXzLRY7ymv96JKE5d0p64slTp+Id59pIwoX2INmz5tfVfiB2vsTqyTZYtZg/wR0FOL/mOLdP7+YcOuTPNXNc7pJTQR5YFz9NcLzWcD0dJvpkwUuFotD8XYsPuQzKp94elCzzls1ZFaVDAQoSrZTrnj7XJmurTA3cPy1Zay6A2mb5mhSJwqsioLAIFTI3aRpzx9vE5qRpqnO1+6esXx/3V0mLSUOeg+2Rwaeo6aGtdwSvZJwtzRFQwddT2vEXalCj8BHZbZWh8QX5TfGl0D/odjUKgnOHDIj9NdweCJa+2X4BnWfJrRWfQdQFP9Y8hxjFbVMC4GQlW3sg5VTfdjFbLTMXY/6m47vwQUGSaIGcv79c12Fw9E7UhHbHw1JjETU0JNcOzBVNHZGIxCrv5z2ANkX/iX0I6o8zkyEsXvrIXzYwzO/VEPDkRV1lXiqFLYAx+Yv8YnDw5Wc+faeiSjrZynajaifURQTXrHrFItQb40wvMPHi7gSwZ/GJj/wL6Zs22cauc7uZCZteCQt8+gaSd4Fbljt84azbQvhdYXhDY1Jy5qc+lq+mFg7YCmrVhF5k22LRYuGV46ELsUWPtqZ83jrSdmuG4oL2rbEsRuAGBj5zPlsdNf/kV9NidRSx4TIHayH1YLIM6tAbSeO4GiYzeRb2sB/RDEqTCCAUkGCSqGSIb3DQEHAaCCAToEggE2MIIBMjCCAS4GCyqGSIb3DQEMCgECoIH3MIH0MF8GCSqGSIb3DQEFDTBSMDEGCSqGSIb3DQEFDDAkBBDL5r2Uc8nACWu+UUz9DkV8AgIIADAMBggqhkiG9w0CCQUAMB0GCWCGSAFlAwQBKgQQ+FColXYNlB7l61Ll/T54kQSBkJdAcykdDgrPeN3MHnC03/nUh/gkDUvzfQWJahAmt0g27/IHdebBSQkTM3clWyftZkBmmmfs8AtjLY6bkw1nH2MBRaI9eNzwNgjZoBCvWJ2eXIBJLqQaUEYN/enp3ccMuQ7VUE4IT2eUz0J88eApkydrP2iZqSyL83gos+aNkDJGvMU9/GGwTBR9e6jlqnUMvzElMCMGCSqGSIb3DQEJFTEWBBTL1oxWF+bFo5ISNL53ttoTmC3LPTBBMDEwDQYJYIZIAWUDBAIBBQAEIMTmBCTrk8ppPLkPY4IDezpqgjaJtXnva4irYiX1MiVnBAgQYh1cdBZ8bgICCAA=');
    end;

    procedure GetTestCertPassword(): Text[250]
    begin
        exit('DKSkatTest');
    end;

    procedure GetRSA3072TestCertThumbprint(): Text
    begin
        exit('BDF21BB734776D0A0CC15CD03AF922F39B54B3DB');
    end;

    procedure GetRSA2048TestCertThumbprint(): Text[250]
    begin
        exit('79EC4C69894309EEF993542934A204DE029CDA3A');
    end;
}
