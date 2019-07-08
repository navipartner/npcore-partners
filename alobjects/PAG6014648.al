page 6014648 "Package Module Admin"
{
    // 
    // NPR-Package1.0, NPK, DL, 04-04-08, Form created
    //                      DL, 02-05-08, Added some fields
    // NPR5.41/TS  /20180105 CASE 300893 Removed Caption on ActionContainer

    Caption = 'Package Module Admin';
    SourceTable = "Package Module Configuration";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            grid(General)
            {
                Caption = 'General';
                group(Control6150615)
                {
                    ShowCaption = false;
                    field("Normal No. Series";"Normal No. Series")
                    {
                    }
                    field("DHL No. Series";"DHL No. Series")
                    {
                    }
                    field("DHL AWB No. Series";"DHL AWB No. Series")
                    {
                    }
                    field("DHL Customer No";"DHL Customer No")
                    {
                    }
                    field("COD No. Series";"COD No. Series")
                    {
                    }
                    field("CV No. Series";"CV No. Series")
                    {
                    }
                    field("Barcode39 Path";"Barcode39 Path")
                    {
                    }
                    field("Has EDI contract";"Has EDI contract")
                    {
                    }
                    field("Business Service Code";"Business Service Code")
                    {
                    }
                    field("Private Service Code";"Private Service Code")
                    {
                    }
                }
                group(Control6150626)
                {
                    ShowCaption = false;
                    field("DHL ftp address";"DHL ftp address")
                    {
                    }
                    field("DHL ftp username";"DHL ftp username")
                    {
                    }
                    field("DHL ftp password";"DHL ftp password")
                    {
                    }
                }
            }
            grid(EDI)
            {
                Caption = 'EDI';
                group(Control6150630)
                {
                    ShowCaption = false;
                    field("EDI Sender Identifier";"EDI Sender Identifier")
                    {
                    }
                    field("EDI Sender SMS";"EDI Sender SMS")
                    {
                    }
                    field("EDI Recipient SMS";"EDI Recipient SMS")
                    {
                    }
                    field("EDI Sender Email";"EDI Sender Email")
                    {
                    }
                    field("EDI Recipient Email";"EDI Recipient Email")
                    {
                    }
                    field("EDI FTP username";"EDI FTP username")
                    {
                    }
                    field("EDI FTP password";"EDI FTP password")
                    {
                    }
                }
            }
        }
    }

    actions
    {
    }
}

