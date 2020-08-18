report 6060123 "MM Member Card Std Print"
{
    // NPK1.00/JLK /20170215  CASE 266264 Object created
    // NPK1.01/JLK /20170413  CASE 272077 Barcode Text removed to replace with External Member Card No.
    // NPR5.55/JAKUBV/20200807  CASE 408787 Transport NPR5.55 - 31 July 2020
    DefaultLayout = RDLC;
    RDLCLayout = './layouts/MM Member Card Std Print.rdlc';

    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("MM Member Card"; "MM Member Card")
        {
            column(MemberDate; MemberDate)
            {
            }
            column(Barcode; ImageMemoryBuffer.Value)
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
            dataitem("MM Member"; "MM Member")
            {
                DataItemLink = "Entry No." = FIELD("Member Entry No.");
                DataItemTableView = SORTING("Entry No.");
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
                MMMembership: Record "MM Membership";
                MMMembershipSalesSetup: Record "MM Membership Sales Setup";
                MMMembershipSetup: Record "MM Membership Setup";
                PointTo: Integer;
            begin

                CalcFields("External Member No.");
                BarcodeLib.SetAntiAliasing(false);
                BarcodeLib.SetShowText(false);
                BarcodeLib.SetBarcodeType('CODE128');
                BarcodeLib.GenerateBarcode("MM Member Card"."External Card No.", TmpBarcode);

                Clear(ImageMemoryBuffer);
                ImageMemoryBuffer.init();
                ImageMemoryRecRef.GetTable(ImageMemoryBuffer);
                TmpBarcode.ToRecordRef(ImageMemoryRecRef, ImageMemoryBuffer.FieldNo(ImageMemoryBuffer.Value));

                Clear(MemberDate);
                Clear(MemberItem);
                Clear(CardType);
                Clear(CardCustomerType);
                MMMembershipEntry.SetRange("Membership Entry No.", "Membership Entry No.");
                MMMembershipEntry.SetRange(Blocked, false);
                if MMMembershipEntry.FindLast then begin
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

            trigger OnPreDataItem()
            var
                RetailFormCode: Codeunit "Retail Form Code";
            begin
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
    }

    var
        MemberCardNoCaption: Label 'Member No.:';
        ExpiryDateCaption: Label 'Expiry date: ';
        MemberName: Text;
        MemberDate: Text;
        TmpBarcode: Codeunit "Temp Blob";
        ImageMemoryBuffer: Record "NpXml Custom Value Buffer" temporary;
        ImageMemoryRecRef: RecordRef;
        CompanyInformation: Record "Company Information";
        MMMembershipEntry: Record "MM Membership Entry";
        MemberItem: Text;
        MemberNameCaption: Label 'Name: ';
        MemberType: Text;
        CardType: Text;
        CardCustomerType: Text;
}

