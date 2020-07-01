report 6060127 "MM Member Card Print"
{
    // MM80.1.02/TSA/20151228  CASE 229684 Touch-up and enchancements
    // MM1.37/TJ  /20190201  CASE 350288 Using POS View Profile for register picture
    DefaultLayout = RDLC;
    RDLCLayout = './layouts/MM Member Card Print.rdlc';

    Caption = 'Member Card Print';

    dataset
    {
        dataitem("MM Member Card"; "MM Member Card")
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
            dataitem("MM Member"; "MM Member")
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
                BarcodeLib: Codeunit "Barcode Library";
                Item: Record Item;
                MMMembershipRole: Record "MM Membership Role";
            begin
                //BarcodeLib.SetAntiAliasing(FALSE);
                //BarcodeLib.SetShowText(FALSE);
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
                RetailFormCode: Codeunit "Retail Form Code";
            begin
                //-MM1.37 [350288]
                /*
                IF Register.GET(RetailFormCode.FetchRegisterNumber) THEN
                  IF Register.Picture.HASVALUE THEN
                    Register.CALCFIELDS(Picture);
                */
                if POSUnit.Get(RetailFormCode.FetchRegisterNumber) then
                    if POSViewProfile.Get(POSUnit."POS View Profile") and POSViewProfile.Picture.HasValue then
                        POSViewProfile.CalcFields(Picture);
                //+MM1.37 [350288]

            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
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
        POSUnit: Record "POS Unit";
        POSViewProfile: Record "POS View Profile";
        BlobBuffer: Record "BLOB Buffer" temporary;
}

