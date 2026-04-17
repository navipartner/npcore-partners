#if not BC17
report 6060127 "NPR MM Member Card Print QR"
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/MM Member Card Print QR.rdl';
    Caption = 'Std. Member Card Print (QR)';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("MM Member Card"; "NPR MM Member Card")
        {
            column(MemberType; MemberType) { }
            column(QRBlob; TempBlobBuffer."Buffer 1") { }
            column(RegisterPicture; TenantMedia.Content) { }
            column(MemberCardNo; "External Card No.") { }
            column(MembershipNo; MembershipNo) { }
            column(MembershipExpiryDate; MembershipExpiryDate) { }
            column(Company_Name; "Company Name") { }
            dataitem("MM Member"; "NPR MM Member")
            {
                DataItemLink = "Entry No." = FIELD("Member Entry No.");
                column(MemberName; MemberName) { }
                column(MemberNumber; "External Member No.") { }
                column(MemberPicture; TenantMediaMMMember.Content) { }

                trigger OnAfterGetRecord()
                begin
                    "MM Member".GetImageContent(TenantMediaMMMember);

                    Clear(MemberName);
                    if "MM Member"."Display Name" <> '' then
                        MemberName := "MM Member"."Display Name";
                end;
            }

            trigger OnAfterGetRecord()
            var
                BarcodeFontProvider: Codeunit "NPR Barcode Font Provider Mgt.";
                MMMembership: Record "NPR MM Membership";
                MMMembershipSetup: Record "NPR MM Membership Setup";
                MMMembershipMgt: Codeunit "NPR MM Membership Mgt.";
                MaxValidUntilDate: Date;
                Base64Image: Text;
                Base64Convert: Codeunit "Base64 Convert";
                OutStr: OutStream;
            begin
                Base64Image := BarcodeFontProvider.GenerateQRCodeAZ("MM Member Card"."External Card No.", 'H', 'UTF8', true, true, 2);
                TmpQR.CreateOutStream(OutStr);
                Base64Convert.FromBase64(Base64Image, OutStr);
                TempBlobBuffer.GetFromTempBlob(TmpQR, 1);

                Clear(MemberType);
                Clear(MembershipNo);
                Clear(MembershipExpiryDate);
                if MMMembership.Get("Membership Entry No.") then begin
                    MembershipNo := MMMembership."External Membership No.";
                    if MMMembershipSetup.Get(MMMembership."Membership Code") then
                        MemberType := MMMembershipSetup.Description;
                end;

                MMMembershipMgt.GetMembershipMaxValidUntilDate("Membership Entry No.", MaxValidUntilDate);
                if MaxValidUntilDate <> 0D then
                    MembershipExpiryDate := Format(MaxValidUntilDate, 0, '<Day,2>/<Month,2>/<Year4>');
            end;

            trigger OnPreDataItem()
            var
                POSViewProfile: Record "NPR POS View Profile";
            begin
                SetAutoCalcFields("Company Name");
                if POSUnit.Get(POSUnit.GetCurrentPOSUnit()) then
                    if POSUnit.GetProfile(POSViewProfile) then
                        POSViewProfile.GetImageContent(TenantMedia);
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
    }

    labels
    {
        ExpiryDate = 'Expiry date:';
    }

    var
        TmpQR: Codeunit "Temp Blob";
        MemberName: Text;
        MemberType: Text;
        MembershipNo: Text;
        MembershipExpiryDate: Text;
        POSUnit: Record "NPR POS Unit";
        TenantMedia, TenantMediaMMMember : Record "Tenant Media";
        TempBlobBuffer: Record "NPR BLOB buffer" temporary;
}
#endif
