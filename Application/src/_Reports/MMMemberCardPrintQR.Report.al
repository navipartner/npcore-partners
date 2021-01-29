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
            column(QRBlob; BlobBuffer."Buffer 1")
            {
            }
            column(RegisterPicture; POSViewProfile.Picture)
            {
            }
            dataitem("MM Member"; "NPR MM Member")
            {
                DataItemLink = "Entry No." = FIELD("Member Entry No.");
                column(MemberName; MemberName)
                {
                }
                column(MemberPicture; "MM Member".Picture)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if "MM Member".Picture.HasValue then
                        "MM Member".CalcFields(Picture);

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
                BarcodeLib: Codeunit "NPR Barcode Library";
                Item: Record Item;
                MMMembershipRole: Record "NPR MM Membership Role";
            begin
                BarcodeLib.SetSizeX(2);
                BarcodeLib.SetSizeY(2);
                BarcodeLib.SetBarcodeType('QR');
                BarcodeLib.GenerateBarcode("MM Member Card"."External Card No.", TmpQR);
                BlobBuffer.GetFromTempBlob(TmpQR, 1);

                MemberDate := Format("MM Member Card"."Valid Until");

                Clear(MemberType);
                if MMMembershipRole.Get("Membership Entry No.", "Member Entry No.") then
                    MemberType := Format(MMMembershipRole."Member Role");
            end;

            trigger OnPreDataItem()
            var
                RetailFormCode: Codeunit "NPR Retail Form Code";
            begin
                if POSUnit.Get(RetailFormCode.FetchRegisterNumber) then
                    if POSViewProfile.Get(POSUnit."POS View Profile") and POSViewProfile.Picture.HasValue then
                        POSViewProfile.CalcFields(Picture);
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
        POSViewProfile: Record "NPR POS View Profile";
        BlobBuffer: Record "NPR BLOB buffer" temporary;
}

