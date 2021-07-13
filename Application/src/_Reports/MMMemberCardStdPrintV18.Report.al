#if not BC17
report 6060123 "NPR MM Member Card Std Print"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/MM Member Card Std PrintV18.rdl';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;

    dataset
    {
        dataitem("MM Member Card"; "NPR MM Member Card")
        {
            column(MemberDate; MemberDate)
            {
            }
            column(Barcode; BarCodeEncodedText)
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
                // column(MemberPicture; TenantMediaMMMember.Content)
                column(MemberPicture; Picture)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    // "MM Member".GetImageContent(TenantMediaMMMember);
                    if "MM Member".Picture.HasValue() then
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
                Item: Record Item;
                MMMembership: Record "NPR MM Membership";
                MMMembershipSetup: Record "NPR MM Membership Setup";
                PointTo: Integer;
            begin
                CalcFields("External Member No.");
                BarcodeSimbiology := BarcodeSimbiology::Code128;

                BarCodeText := "MM Member Card"."External Card No.";
                BarCodeEncodedText := BarcodeFontProviderMgt.EncodeText(BarCodeText, BarcodeSimbiology, BarcodeFontProviderMgt.SetBarcodeSettings(0, true, true, false));

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

    var
        CompanyInformation: Record "Company Information";
        MMMembershipEntry: Record "NPR MM Membership Entry";
        BarcodeFontProviderMgt: Codeunit "NPR Barcode Font Provider Mgt.";
        BarcodeSimbiology: Enum "Barcode Symbology";
        // TenantMediaMMMember: Record "Tenant Media";
        BarCodeText: Text;
        BarCodeEncodedText: Text;
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