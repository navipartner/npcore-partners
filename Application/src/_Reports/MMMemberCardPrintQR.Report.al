#if BC17
report 6060127 "NPR MM Member Card Print QR"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/MM Member Card Print QR.rdlc';
    Caption = 'Member Card Print';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    dataset
    {
        dataitem("MM Member Card"; "NPR MM Member Card")
        {
            column(MemberDate; MemberDate)
            {
            }
            column(MemberType; MemberType)
            {
            }
            column(QRBlob; TempBlobBuffer."Buffer 1")
            {
            }
            column(RegisterPicture; TenantMedia.Content)
            {
            }
            dataitem("MM Member"; "NPR MM Member")
            {
                DataItemLink = "Entry No." = FIELD("Member Entry No.");
                column(MemberName; MemberName)
                {
                }
                column(MemberPicture; TenantMediaMMMember.Content)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    "MM Member".GetImageContent(TenantMediaMMMember);

                    Clear(MemberName);
                    if "MM Member"."First Name" <> '' then
                        MemberName += "MM Member"."First Name" + ' ';
                    if "MM Member"."Middle Name" <> '' then
                        MemberName += "MM Member"."Middle Name" + ' ';
                    if "MM Member"."Last Name" <> '' then
                        MemberName += "MM Member"."Last Name";
                end;
            }

            trigger OnAfterGetRecord()
            var
            
                BarcodeLib: Codeunit "NPR Barcode Image Library";
                MMMembershipRole: Record "NPR MM Membership Role";
            begin
                BarcodeLib.SetSizeX(2);
                BarcodeLib.SetSizeY(2);
                BarcodeLib.SetBarcodeType('QR');
                BarcodeLib.GenerateBarcode("MM Member Card"."External Card No.", TmpQR);
                TempBlobBuffer.GetFromTempBlob(TmpQR, 1);

                MemberDate := Format("MM Member Card"."Valid Until");

                Clear(MemberType);
                if MMMembershipRole.Get("Membership Entry No.", "Member Entry No.") then
                    MemberType := Format(MMMembershipRole."Member Role");
            end;

            trigger OnPreDataItem()
            var
                POSViewProfile: Record "NPR POS View Profile";
            begin
                if POSUnit.Get(POSUnit.GetCurrentPOSUnit()) then
                    if POSUnit.GetProfile(POSViewProfile) then
                        POSViewProfile.GetImageContent(TenantMedia);
            end;
        }
    }

    labels
    {
        ExpiryDate = 'Expiry date:';
    }

    var
        TmpQR: Codeunit "Temp Blob";
        MemberName: Text;
        MemberType: Text;
        MemberDate: Text;
        POSUnit: Record "NPR POS Unit";
        TenantMedia, TenantMediaMMMember : Record "Tenant Media";
        TempBlobBuffer: Record "NPR BLOB buffer" temporary;
}
#endif