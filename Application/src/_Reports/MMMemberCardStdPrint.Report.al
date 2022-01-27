#if BC17
report 6060123 "NPR MM Member Card Std Print"
{
    #IF NOT BC17 
    Extensible = False; 
    #ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/MM Member Card Std Print.rdl';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("MM Member Card"; "NPR MM Member Card")
        {
            column(MemberDate; MemberDate)
            {
            }
            column(Barcode; TempBlobBuffer."Buffer 1")
            {
            }
            column(ExternalMemberNo; "External Member No.")
            {
            }
            column(MemberCardNoCaption; MemberCardNoCaption)
            {
            }
            column(PictureCompanyInfo; CompanyInformation.Picture)
            {
            }
            column(MemberItem; MemberItem)
            {
            }
            column(ExpiryDateCaption; ExpiryDateCaption)
            {
            }
            column(MemberNameCaption; MemberNameCaption)
            {
            }
            column(MemberType; MemberType)
            {
            }
            column(CardType; CardType)
            {
            }
            column(CardCustomerType; CardCustomerType)
            {
            }
            column(ExternalCardNo; "External Card No.")
            {
            }
            dataitem("MM Member"; "NPR MM Member")
            {
                DataItemLink = "Entry No." = FIELD("Member Entry No.");
                DataItemTableView = SORTING("Entry No.");
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
                Item: Record Item;
                MMMembership: Record "NPR MM Membership";
                MMMembershipSetup: Record "NPR MM Membership Setup";
                BarcodeLib: Codeunit "NPR Barcode Image Library";
                PointTo: Integer;
                Code128Lbl: Label 'CODE128', Locked = true;
            begin
                CalcFields("External Member No.");
                BarcodeLib.SetAntiAliasing(false);
                BarcodeLib.SetShowText(false);
                BarcodeLib.SetBarcodeType(Code128Lbl);
                BarcodeLib.GenerateBarcode("MM Member Card"."External Card No.", TmpBarcode);

                TempBlobBuffer.GetFromTempBlob(TmpBarcode, 1);
                Clear(MemberDate);
                Clear(MemberItem);
                Clear(CardType);
                Clear(CardCustomerType);
                MMMembershipEntry.SetRange("Membership Entry No.", "Membership Entry No.");
                MMMembershipEntry.SetRange(Blocked, false);
                if MMMembershipEntry.FindLast() then begin
                    MemberDate := Format(MMMembershipEntry."Valid Until Date", 0, '<Closing><Day,2>-<Month,2>-<Year4>');
                    Clear(MemberType);
                    if MMMembership.Get(MMMembershipEntry."Membership Entry No.") then
                        MemberType := MMMembership.Description;
                    if MMMembershipEntry."Item No." <> '' then begin
                        if Item.Get(MMMembershipEntry."Item No.") then
                            MemberItem := Item.Description;
                        if MMMembershipSetup.Get(MMMembershipEntry."Membership Code") then begin
                            PointTo := StrPos(MMMembershipSetup.Description, ' ');
                            if PointTo > 0 then begin
                                CardType := CopyStr(MMMembershipSetup.Description, 1, PointTo);
                                CardCustomerType := CopyStr(MMMembershipSetup.Description, PointTo + 1);
                            end;
                        end;
                    end;
                end;
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
    }

    var
        CompanyInformation: Record "Company Information";
        MMMembershipEntry: Record "NPR MM Membership Entry";
        TempBlobBuffer: Record "NPR BLOB buffer" temporary;
        TenantMediaMMMember: Record "Tenant Media";
        TmpBarcode: Codeunit "Temp Blob";
        ExpiryDateCaption: Label 'Expiry date: ';
        MemberCardNoCaption: Label 'Member No.:';
        MemberNameCaption: Label 'Name: ';
        CardCustomerType: Text;
        CardType: Text;
        MemberDate: Text;
        MemberItem: Text;
        MemberName: Text;
        MemberType: Text;
}
#endif
