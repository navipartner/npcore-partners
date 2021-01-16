report 6014500 "NPR Register Used Goods"
{
    // NPR5.29/JLK /20161124  CASE 259090 Object created
    // NPR5.29/JLK /20170109  CASE 246761 Correcyed RDLC Header Issue
    UsageCategory = None;
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Register Used Goods.rdlc';

    Caption = 'Registrer Used Goods';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem(UsedGoodsRegistration; "NPR Used Goods Registration")
        {
            column(Picture_CompanyInformation; CompanyInformation.Picture)
            {
            }
            column(No_UsedGoodsRegistration; "No.")
            {
                IncludeCaption = true;
            }
            column(PurchaseDate_UsedGoodsRegistration; "Purchase Date")
            {
                IncludeCaption = true;
            }
            column(SalespersonCode_UsedGoodsRegistration; "Salesperson Code")
            {
                IncludeCaption = true;
            }
            column(PurchasedByCustomerNo_UsedGoodsRegistration; "Purchased By Customer No.")
            {
                IncludeCaption = true;
            }
            column(Name_UsedGoodsRegistration; Name)
            {
                IncludeCaption = true;
            }
            column(Address_UsedGoodsRegistration; Address)
            {
                IncludeCaption = true;
            }
            column(Address2_UsedGoodsRegistration; "Address 2")
            {
                IncludeCaption = true;
            }
            column(PostCode_UsedGoodsRegistration; "Post Code")
            {
                IncludeCaption = true;
            }
            column(By_UsedGoodsRegistration; By)
            {
                IncludeCaption = true;
            }
            column(Identification_UsedGoodsRegistration; Identification)
            {
                IncludeCaption = true;
            }
            column(IdentificationNumber_UsedGoodsRegistration; "Identification Number")
            {
                IncludeCaption = true;
            }
            column(AddressFooter1; DotDisplay + AddressLine + DotDisplay + Text001 + CompanyInformation."Phone No." + DotDisplay + Text002 + CompanyInformation."Fax No." + DotDisplay)
            {
            }
            column(AddressFooter2; DotDisplay + Text003 + CompanyInformation."E-Mail" + DotDisplay + Text004 + CompanyInformation."VAT Registration No." + DotDisplay)
            {
            }
            dataitem(UsedGoodsRegistration2; "NPR Used Goods Registration")
            {
                DataItemLink = Link = FIELD("No.");
                DataItemTableView = SORTING(Link) ORDER(Ascending);
                column(Subject_UsedGoodsRegistration2; Subject)
                {
                    IncludeCaption = true;
                }
                column(Serienummer_UsedGoodsRegistration2; Serienummer)
                {
                    IncludeCaption = true;
                }

                trigger OnAfterGetRecord()
                begin
                    UsedGoodsRegistration2."Fax til Kostercentralen" := false;
                    UsedGoodsRegistration2."Kostercentralen Registered" := Today;
                    UsedGoodsRegistration2.Modify;
                end;
            }

            trigger OnPreDataItem()
            begin
                FormatAddr.Company(CompanyAddr, CompanyInformation);

                AddressLine := '';
                for i := 1 to 4 do begin
                    if CompanyAddr[i] <> '' then begin
                        if StrLen(AddressLine) <> 0 then
                            AddressLine := AddressLine + '  ';
                        AddressLine := AddressLine + CompanyAddr[i];
                    end;
                end;
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
        ReportTitle = 'Used Goods Purchase';
        PageLbl = 'Page';
        SignatureLbl = 'Signature';
        DateLbl = 'Date';
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get;
        CompanyInformation.CalcFields(Picture);
        DotDisplay := '  ';
    end;

    var
        CompanyInformation: Record "Company Information";
        DotDisplay: Text;
        AddressLine: Text;
        Text001: Label 'Telephone: ';
        Text002: Label 'Fax No.: ';
        Text003: Label 'E-mail: ';
        Text004: Label 'CVR No.: ';
        i: Integer;
        FormatAddr: Codeunit "Format Address";
        CompanyAddr: array[8] of Text[30];
}

