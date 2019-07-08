page 6060022 "GIM - Document Type Card"
{
    Caption = 'GIM - Document Type Card';
    PageType = Card;
    SourceTable = "GIM - Document Type";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code";Code)
                {
                }
                field("Sender ID";"Sender ID")
                {
                }
                field("Data Format Code";"Data Format Code")
                {
                }
                field("Preview Type";"Preview Type")
                {
                }
                field("Preview Provided Data Only";"Preview Provided Data Only")
                {
                }
            }
            group(Process)
            {
                field("Raw Data Reader";"Raw Data Reader")
                {
                }
                field("Data Type Validator";"Data Type Validator")
                {
                }
                field("Data Mapper";"Data Mapper")
                {
                }
                field("Data Verification";"Data Verification")
                {
                }
                field("Data Creation";"Data Creation")
                {
                }
            }
            group(Notification)
            {
                field("Default Notification Method";"Default Notification Method")
                {
                }
                field("Recipient E-mail";"Recipient E-mail")
                {
                }
            }
            group(FTP)
            {
                field("FTP Active";"FTP Active")
                {
                    Caption = 'Active';
                }
                field("FTP Search Folder";"FTP Search Folder")
                {
                    Caption = 'Search Folder';
                }
                field("FTP File Action After Read";"FTP File Action After Read")
                {
                    Caption = 'File Action After Read';
                }
                field("FTP Archive Folder";"FTP Archive Folder")
                {
                    Caption = 'Archive Folder';
                }
                field("FTP Local Folder";"FTP Local Folder")
                {
                    Caption = 'Local Folder';
                }
                field("FTP Host Name";"FTP Host Name")
                {
                    Caption = 'Host Name';
                }
                field("FTP Port";"FTP Port")
                {
                    Caption = 'Port';
                }
                field("FTP Username";"FTP Username")
                {
                    Caption = 'Username';
                }
                field("FTP Password";"FTP Password")
                {
                    Caption = 'Password';
                    ExtendedDatatype = Masked;
                }
            }
            group("Local Folder Upload")
            {
                Caption = 'Local Folder Upload';
                field("LFU Folder Active";"LFU Folder Active")
                {
                    Caption = 'Active';
                }
                field("LFU Search Folder";"LFU Search Folder")
                {
                    Caption = 'Search Folder';
                }
                field("LFU File Action After Read";"LFU File Action After Read")
                {
                    Caption = 'File Action After Read';
                }
                field("LFU Archive Folder";"LFU Archive Folder")
                {
                    Caption = 'Archive Folder';
                }
            }
            group("Web Service")
            {
                Caption = 'Web Service';
                field("WS Active";"WS Active")
                {
                    Caption = 'Active';
                }
            }
        }
    }

    actions
    {
    }
}

