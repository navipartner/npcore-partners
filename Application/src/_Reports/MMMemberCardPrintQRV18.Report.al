#if not BC17
report 6060127 "NPR MM Member Card Print QR"
{
    Extensible = false;
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
                    Clear(TenantMediaMMMember);
                    "MM Member".GetImageContent(TenantMediaMMMember);

                    Clear(MemberName);
                    if "MM Member"."Display Name" <> '' then
                        MemberName := "MM Member"."Display Name";
                end;
            }

            trigger OnAfterGetRecord()
            var
                TempBarcodeEncodeSettings2D: Record "Barcode Encode Settings 2D" temporary;
                MMMembership: Record "NPR MM Membership";
                MMMembershipSetup: Record "NPR MM Membership Setup";
                MMMembershipMgt: Codeunit "NPR MM Membership Mgt.";
                TmpQR: Codeunit "Temp Blob";
                BarcodeImageProvider2D: Interface "Barcode Image Provider 2D";
                MaxValidUntilDate: Date;
            begin
                Clear(TempBlobBuffer);
                if "MM Member Card"."External Card No." <> '' then begin
                    BarcodeImageProvider2D := Enum::"Barcode Image Provider 2D"::Dynamics2D;

                    TempBarcodeEncodeSettings2D.Init();
                    TempBarcodeEncodeSettings2D."Error Correction Level" := TempBarcodeEncodeSettings2D."Error Correction Level"::High;
                    TempBarcodeEncodeSettings2D."Quite Zone Width" := 4;
                    TempBarcodeEncodeSettings2D."Code Page" := 65001;

                    TmpQR := BarcodeImageProvider2D.EncodeImage("MM Member Card"."External Card No.", Enum::"Barcode Symbology 2D"::"QR-Code", TempBarcodeEncodeSettings2D);
                    TempBlobBuffer.GetFromTempBlob(TmpQR, 1);
                end;

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
                UserSetup: Record "User Setup";
                POSViewProfile: Record "NPR POS View Profile";
            begin
                SetAutoCalcFields("Company Name");

                // The POS unit only supplies an optional register background image, so resolve it defensively.
                // POSUnit.GetCurrentPOSUnit() errors outright when the user has no User Setup record or no POS
                // unit assigned, and it is evaluated before the surrounding Get() can return false, so calling
                // it here aborted the whole print for any non-POS user.
                if not UserSetup.Get(UserId()) then
                    exit;
                if not POSUnit.Get(UserSetup."NPR POS Unit No.") then
                    exit;
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
        MemberName: Text;
        MemberType: Text;
        MembershipNo: Text;
        MembershipExpiryDate: Text;
        POSUnit: Record "NPR POS Unit";
        TenantMedia, TenantMediaMMMember : Record "Tenant Media";
        TempBlobBuffer: Record "NPR BLOB buffer" temporary;
}
#endif
