report 6014436 "Retail Rental Contract"
{
    // NPR70.00.00.00/LS/20150128  CASE 202874  Convert Report to 7.1
    // NPR4.14/TR/20150824 CASE 202874 Report footer inserted.
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    DefaultLayout = RDLC;
    RDLCLayout = './layouts/Retail Rental Contract.rdlc';

    Caption = 'Retail Rental Contract';
    PreviewMode = PrintLayout;
    UsageCategory = Documents;

    dataset
    {
        dataitem("Retail Document Header";"Retail Document Header")
        {
            RequestFilterFields = "Document Type";
            column(COMPANYNAME;CompanyName)
            {
            }
            column(CompanyInfoPicture;CompanyInformation.Picture)
            {
            }
            column(CustomerNo_RetailDocumentHeader;"Retail Document Header"."Customer No.")
            {
            }
            column(Name_RetailDocumentHeader;"Retail Document Header".Name)
            {
            }
            column(CompanyInfoName;CompanyInformation.Name)
            {
            }
            column(Firstname_RetailDocumentHeader;"Retail Document Header"."First Name")
            {
            }
            column(CompanyInfoName2;CompanyInformation."Name 2")
            {
            }
            column(Address_RetailDocumentHeader;"Retail Document Header".Address)
            {
            }
            column(CompanyInfoAddress;CompanyInformation.Address)
            {
            }
            column(Address2_RetailDocumentHeader;"Retail Document Header"."Address 2")
            {
            }
            column(CompanyInfoAddress2;CompanyInformation."Address 2")
            {
            }
            column(PostCodeCity_RetailDocumentHeader;"Post Code"+' '+City)
            {
            }
            column(Phone_RetailDocumentHeader;"Retail Document Header".Phone)
            {
            }
            column(No_RetailDocumentHeader;"Retail Document Header"."No.")
            {
            }
            column(CompanyInformationPostCodeCity;CompanyInformation."Post Code"+' '+CompanyInformation.City)
            {
            }
            column(CompanyInformationPhoneNo;CompanyInformation."Phone No.")
            {
            }
            column(CompanyInformationVAT;CompanyInformation."VAT Registration No.")
            {
            }
            column(RentDate_RetailDocumentHeader;"Retail Document Header"."Rent Date")
            {
            }
            column(RentTime_RetailDocumentHeader;"Retail Document Header"."Rent Time")
            {
            }
            column(Returndate_RetailDocumentHeader;"Retail Document Header"."Return Date")
            {
            }
            column(Returntime_RetailDocumentHeader;"Retail Document Header"."Return Time")
            {
            }
            column(TotalAmount;TotalAmount)
            {
            }
            column(Deposit_RetailDocumentHeader;"Retail Document Header".Deposit)
            {
            }
            column(DocumentType_RetailDocumentHeader;"Retail Document Header"."Document Type")
            {
            }
            dataitem("Retail Document Lines";"Retail Document Lines")
            {
                DataItemLink = "Document Type"=FIELD("Document Type"),"Document No."=FIELD("No.");
                column(Quantity_RetailDocumentLines;"Retail Document Lines".Quantity)
                {
                }
                column(No_RetailDocumentLines;"Retail Document Lines"."No.")
                {
                }
                column(Description_RetailDocumentLines;"Retail Document Lines".Description)
                {
                }
                column(Amount_RetailDocumentLines;"Retail Document Lines".Amount)
                {
                }
                column(Unitprice_RetailDocumentLines;"Retail Document Lines"."Unit price")
                {
                }
                column(DocumentType_RetailDocumentLines;"Retail Document Lines"."Document Type")
                {
                }
            }
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
        Report_Caption = 'Rent Contract';
        CustomerNo_Caption = 'Customer No.';
        Name_Caption = 'Name';
        Address_Caption = 'Address';
        PostCodeCity_Caption = 'Post Code/City';
        Phone_Caption = 'Phone';
        No_Caption = 'No.';
        TelNo_Caption = 'Tel. No.';
        CVR_Caption = 'CVR:';
        Quantity_Caption = 'Quantity';
        Returned_Caption = 'Returned';
        Description_Caption = 'Description';
        UnitPrice_Caption = 'Unit Price';
        Amount_Caption = 'Amount';
        Date_Caption = 'Date';
        Time_Caption = 'Time';
        Delivered_Caption = 'Delivered';
        Return_Caption = 'Return';
        TotalAmount_Caption = 'Total Amount:';
        Deposit_Caption = 'Deposit:';
        SignatureGoods_Caption = 'Signature for receipt of the rented goods:';
        SignatureDeposit_Caption = 'Signature for receipt of deposit:';
        SignatureHirer_Caption = 'Signature Hirer';
        SignatureOwner_Caption = 'Signature Owner';
    }

    trigger OnInitReport()
    begin
        CompanyInformation.Get;
        CompanyInformation.CalcFields(Picture);

        //-NPR5.39
        // Object.SETRANGE(ID, 6014436);
        // Object.SETRANGE(Type, 3);
        // Object.FIND('-');
        //-NPR5.39

        TotalAmount := 0;
    end;

    var
        CompanyInformation: Record "Company Information";
        TotalAmount: Decimal;
}

